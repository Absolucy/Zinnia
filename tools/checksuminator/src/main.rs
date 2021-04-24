mod crc;
mod encrypt_code;
mod string_table;

use bytemuck::{Pod, Zeroable};
use goblin::mach::{Mach, MachO};
use rand::RngCore;
use std::path::PathBuf;
use structopt::StructOpt;

#[derive(Debug, Copy, Clone, Pod, Zeroable)]
#[repr(C)]
pub struct DecryptionKey {
	key: [u32; 8],
	nonce: [u32; 3],
	xor_key: [u32; 8],
	xor_nonce: [u32; 3],
}

impl DecryptionKey {
	pub fn shuffle(&mut self) {
		self.key
			.iter_mut()
			.zip(self.xor_key.iter())
			.for_each(|(a, b)| *a = perfect_shuffle(*a ^ *b));
		self.nonce
			.iter_mut()
			.zip(self.xor_nonce.iter())
			.for_each(|(a, b)| *a = perfect_shuffle(*a ^ *b));
		self.xor_key
			.iter_mut()
			.for_each(|byte| *byte = perfect_shuffle(*byte));
		self.xor_nonce
			.iter_mut()
			.for_each(|byte| *byte = perfect_shuffle(*byte));
	}
}

impl Default for DecryptionKey {
	fn default() -> Self {
		let mut bytes = [0u8; std::mem::size_of::<Self>()];
		rand::thread_rng().fill_bytes(&mut bytes);
		*bytemuck::from_bytes(&bytes)
	}
}

pub fn perfect_shuffle(mut x: u32) -> u32 {
	x = (x & (0xff0000ff)) | ((x & (0x00ff0000)) >> 8) | ((x & (0x0000ff00)) << 8);
	x = (x & (0xf00ff00f)) | ((x & (0x0f000f00)) >> 4) | ((x & (0x00f000f0)) << 4);
	x = (x & (0xc3c3c3c3)) | ((x & (0x30303030)) >> 2) | ((x & (0x0c0c0c0c)) << 2);
	x = (x & (0x99999999)) | ((x & (0x44444444)) >> 1) | ((x & (0x22222222)) << 1);
	x
}

#[derive(StructOpt, Debug)]
pub struct Opt {
	#[structopt(long)]
	init: bool,
	#[structopt(long, parse(from_os_str))]
	string: PathBuf,
	#[structopt(parse(from_os_str))]
	path: PathBuf,
}

fn handle_slice(macho: MachO, offset: usize, binary: &mut Vec<u8>, opt: &Opt) {
	string_table::handle(&macho, offset, binary, opt);
	crc::handle(&macho, offset, binary, opt.init);
	encrypt_code::handle(&macho, offset, binary);
}

fn main() {
	let opt = Opt::from_args();

	println!();

	let binary = std::fs::read(&opt.path).unwrap();
	let mut out_binary = binary.clone();
	let fat = Mach::parse(&binary).expect("failed to parse mach-o binary");
	match fat {
		Mach::Fat(fat) => {
			for (index, slice) in fat
				.arches()
				.expect("failed to get fat arches")
				.into_iter()
				.enumerate()
			{
				let macho = fat
					.get(index)
					.expect("failed to get mach-o binary for fat slice");
				handle_slice(macho, slice.offset as usize, &mut out_binary, &opt);
			}
		}
		Mach::Binary(macho) => {
			handle_slice(macho, 0, &mut out_binary, &opt);
		}
	}

	std::fs::write(opt.path, out_binary).expect("failed to write");

	println!();
}
