mod crc;
mod string_table;

use goblin::mach::{Mach, MachO};

fn handle_slice(macho: MachO, offset: usize, binary: &mut Vec<u8>) {
	string_table::handle(&macho, offset, binary);
	crc::handle(&macho, offset, binary);
}

fn main() {
	let x = std::env::args().collect::<Vec<_>>();

	println!();

	let binary = std::fs::read(&x[1]).unwrap();
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
				handle_slice(macho, slice.offset as usize, &mut out_binary);
			}
		}
		Mach::Binary(macho) => {
			handle_slice(macho, 0, &mut out_binary);
		}
	}

	std::fs::write(&x[1], out_binary).expect("failed to write");

	println!();
}
