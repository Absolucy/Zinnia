pub(crate) mod crc;
pub(crate) mod encrypt;
pub(crate) mod string_table;

use goblin::mach::{Mach, MachO};
use std::path::Path;

fn handle_slice(
	macho: MachO,
	offset: usize,
	binary: &mut Vec<u8>,
	string_table: &Path,
	init: bool,
) {
	string_table::handle(&macho, offset, binary, string_table);
	crc::handle(&macho, offset, binary, init);
	encrypt::handle(&macho, offset, binary);
}

pub fn handle(init: bool, string_table: &Path, path: &Path) {
	let binary = std::fs::read(&path).unwrap();
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
				handle_slice(
					macho,
					slice.offset as usize,
					&mut out_binary,
					&string_table,
					init,
				);
			}
		}
		Mach::Binary(macho) => {
			handle_slice(macho, 0, &mut out_binary, &string_table, init);
		}
	}
	std::fs::write(path, out_binary).expect("failed to write");
}
