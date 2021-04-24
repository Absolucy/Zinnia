use bytemuck::{Pod, Zeroable};
use goblin::mach::{symbols::Nlist, MachO};
use rand::{prelude::SliceRandom, Rng};

#[derive(Debug, Copy, Clone, Pod, Zeroable)]
#[repr(C)]
struct CrcLookup {
	ckey: u64,
	checksum: u64,
	size: u64,
	jkey: u64,
	jmp: u64,
}

fn crc(initial: u64, data: &[u8]) -> u64 {
	let polynomial = 0xA17870F5D4F51B49;
	data.iter().fold(initial, |crc, byte| {
		let mut crc = crc ^ ((*byte as u64) << 56);
		for _ in 0..8 {
			if (crc & 0x8000000000000000) != 0 {
				crc = (crc << 1) ^ polynomial;
			} else {
				crc <<= 1;
			}
		}
		crc
	})
}

pub fn handle(macho: &MachO, offset: usize, binary: &mut Vec<u8>) {
	let mut offsets: Vec<(String, Nlist)> = Vec::new();
	for x in macho.symbols() {
		let (name, nlist) = x.unwrap();
		if nlist.n_value != 0 && nlist.n_sect == 0x1 {
			offsets.push((name.to_string(), nlist.clone()));
		}
	}
	offsets.sort_by(|(_, a), (_, b)| a.n_value.cmp(&b.n_value));
	let mut crc_table: Vec<CrcLookup> = Vec::with_capacity(offsets.len());
	let mut offsets_iter = offsets.iter().peekable();
	let mut rng = rand::thread_rng();
	while let Some((name, symbol)) = offsets_iter.next() {
		let next_offset = match offsets_iter.peek() {
			Some((_, next_sym)) => next_sym.n_value as usize,
			None => (symbol.n_value as usize) + 12,
		};
		if !symbol.is_undefined()
			&& !symbol.is_weak()
			&& !name.trim().is_empty()
			&& !name.to_lowercase().contains("swift")
			&& !name.contains('/')
			&& symbol.n_sect == 0x1
			&& symbol.n_value != 0
		{
			let size = next_offset - (symbol.n_value as usize);
			if size == 0 {
				continue;
			}

			let checksum = crc(
				0xFFFFFFFFFFFFFFFF,
				&binary[symbol.n_value as usize..next_offset],
			);
			let ckey = rng.gen();
			let entry = CrcLookup {
				ckey,
				checksum: checksum ^ ckey,
				size: size as u64,
				jkey: rng.gen(),
				jmp: rng.gen(),
			};
			crc_table.push(entry);
		}
	}

	let (text, text_crc) = macho
		.segments
		.into_iter()
		.find(|x| x.name().unwrap() == "__TEXT")
		.expect("failed to find text segment")
		.sections()
		.expect("failed to get sections")
		.into_iter()
		.find(|(section, _)| section.name().unwrap() == "__text")
		.map(|(section, bytes)| (section, crc(0xFFFFFFFFFFFFFFFF, bytes)))
		.expect("failed to find text section");
	println!("crc of text is 0x{:010x}", text_crc);
	let ckey = rng.gen();
	let jkey = rng.gen();
	let entry = CrcLookup {
		ckey,
		checksum: text_crc ^ ckey,
		size: text.size,
		jkey,
		jmp: offsets
			.iter()
			.find(|(name, _)| name == "_initTweakFunc")
			.expect("failed to find initTweakFunc")
			.1
			.n_value ^ jkey,
	};
	println!("{:#?}", entry);
	crc_table.push(entry);

	crc_table.shuffle(&mut rng);

	crc_table.resize_with(1024, || CrcLookup {
		ckey: rng.gen(),
		checksum: rng.gen(),
		size: rng.gen_range(8..256),
		jkey: rng.gen(),
		jmp: rng.gen(),
	});

	let crc_table_range = macho
		.segments
		.into_iter()
		.find(|x| x.name().unwrap() == "__TEXT")
		.expect("failed to find text segment")
		.sections()
		.expect("failed to get sections")
		.into_iter()
		.find(|(section, _)| section.name().unwrap() == "__GODZILLACRC")
		.map(|(section, _)| {
			offset + section.offset as usize
				..offset + section.offset as usize + section.size as usize
		})
		.expect("failed to find crc table section");

	binary.splice(
		crc_table_range,
		bytemuck::cast_slice(&crc_table).iter().copied(),
	);
}
