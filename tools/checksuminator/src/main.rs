pub(crate) mod models;
pub(crate) mod passes;
pub(crate) mod shuffle;

use goblin::mach::{Mach, MachO};
use std::path::PathBuf;
use structopt::StructOpt;

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
	passes::string_table::handle(&macho, offset, binary, opt);
	passes::crc::handle(&macho, offset, binary, opt.init);
	passes::encrypt::handle(&macho, offset, binary);
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
