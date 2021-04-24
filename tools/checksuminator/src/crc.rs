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

fn jmp_section(
	target_segment: &str,
	target_section: &str,
	target_fn: &str,
	macho: &MachO,
	offsets: &[(String, Nlist)],
	offset: usize,
	binary: &[u8],
) -> CrcLookup {
	let (text, text_crc) = macho
		.segments
		.into_iter()
		.find(|x| x.name().unwrap() == target_segment)
		.expect("failed to find target segment")
		.sections()
		.expect("failed to get sections")
		.into_iter()
		.find(|(section, _)| section.name().unwrap() == target_section)
		.map(|(section, _)| {
			let checksum = crc(
				0xFFFFFFFFFFFFFFFF,
				&binary[offset + section.offset as usize
					..offset + section.offset as usize + section.size as usize],
			);
			(section, checksum)
		})
		.expect("failed to find target section");
	println!(
		"crc({},{}) = 0x{:X}",
		target_segment, target_section, text_crc
	);
	let ckey = rand::random();
	let jkey = rand::random();
	CrcLookup {
		ckey,
		checksum: text_crc ^ ckey,
		size: text.size,
		jkey,
		jmp: offsets
			.iter()
			.find(|(name, _)| name == target_fn)
			.expect("failed to find target function")
			.1
			.n_value ^ jkey,
	}
}

fn jmp_section_multi(
	target_segments: &[&str],
	target_sections: &[&str],
	target_fn: &str,
	macho: &MachO,
	offsets: &[(String, Nlist)],
	offset: usize,
	binary: &[u8],
) -> Vec<CrcLookup> {
	assert_eq!(target_segments.len(), target_sections.len());
	let mut out = Vec::<CrcLookup>::with_capacity(target_segments.len());

	let mut target_offset = offsets
		.iter()
		.find(|(name, _)| name == target_fn)
		.expect("failed to find target function")
		.1
		.n_value;

	println!("target_offset = 0x{:X}", target_offset);

	target_segments
		.iter()
		.zip(target_sections.iter())
		.for_each(|(segment_name, section_name)| {
			let (sect, sect_crc) = macho
				.segments
				.into_iter()
				.find(|x| x.name().unwrap() == *segment_name)
				.expect("failed to find target segment")
				.sections()
				.expect("failed to get sections")
				.into_iter()
				.find(|(section, _)| section.name().unwrap() == *section_name)
				.map(|(section, _)| {
					let checksum = crc(
						0xFFFFFFFFFFFFFFFF,
						&binary[offset + section.offset as usize
							..offset + section.offset as usize + section.size as usize],
					);
					(section, checksum)
				})
				.expect("failed to find target section");
			println!("crc({},{}) = 0x{:X}", segment_name, section_name, sect_crc);
			target_offset ^= sect_crc;
			let ckey = rand::random();
			out.push(CrcLookup {
				ckey,
				checksum: sect_crc ^ ckey,
				size: sect.size,
				jkey: rand::random::<u64>() & !(1 << 0),
				jmp: rand::random::<u64>(),
			});
		});

	println!("target_offset ^ all crcs = 0x{:X}", target_offset);

	let mut last = out.iter_mut().last().unwrap();
	last.jkey |= 1 << 0;
	last.jmp = target_offset ^ last.jkey;

	out
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
	let mut rng = rand::thread_rng();
	/*
	let mut offsets_iter = offsets.iter().peekable();
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
	*/

	crc_table.truncate(1020);

	crc_table.push(jmp_section(
		"__TEXT",
		"__text",
		"_initTweakFunc",
		&macho,
		&offsets,
		offset,
		binary,
	));
	crc_table.extend_from_slice(&jmp_section_multi(
		&["__DATA", "__DATA", "__TEXT"],
		&["__godzillatoc", "__godzillastrtb", "__godzilladk"],
		"_initialize_string_table",
		&macho,
		&offsets,
		offset,
		&binary,
	));

	assert!(crc_table.len() <= 1024);
	crc_table.resize_with(1024, || CrcLookup {
		ckey: rng.gen(),
		checksum: rng.gen(),
		size: rng.gen_range(8..256),
		jkey: rng.gen(),
		jmp: rng.gen(),
	});
	crc_table.shuffle(&mut rng);

	let crc_table_range = macho
		.segments
		.into_iter()
		.find(|x| x.name().unwrap() == "__TEXT")
		.expect("failed to find text segment")
		.sections()
		.expect("failed to get sections")
		.into_iter()
		.find(|(section, _)| section.name().unwrap() == "__godzillacrc")
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
