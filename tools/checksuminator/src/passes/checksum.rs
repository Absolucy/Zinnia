#![allow(clippy::too_many_arguments)]
use crate::{models::CrcLookup, shuffle::perfect_shuffle};
use goblin::mach::{symbols::Nlist, MachO};
use rand::{prelude::SliceRandom, Rng, RngCore};
use std::convert::TryInto;

/*
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
*/

fn jmp_section(
	target_segment: &str,
	target_section: &str,
	target_fn: &str,
	macho: &MachO,
	offsets: &[(String, Nlist)],
	offset: usize,
	hasher: &mut blake3::Hasher,
	binary: &[u8],
) -> CrcLookup {
	let (sect, mut sect_hash) = macho
		.segments
		.into_iter()
		.find(|x| x.name().unwrap() == target_segment)
		.expect("failed to find target segment")
		.sections()
		.expect("failed to get sections")
		.into_iter()
		.find(|(section, _)| section.name().unwrap() == target_section)
		.map(|(section, _)| {
			hasher.update(
				&binary[offset + section.offset as usize
					..offset + section.offset as usize + section.size as usize],
			);
			let hash: [u8; 12] = hasher.finalize().as_bytes()[..12]
				.to_vec()
				.try_into()
				.unwrap();
			hasher.reset();
			(section, hash)
		})
		.expect("failed to find target section");

	info!(
		"checksum of {},{}: {} (u64 value is {:#010X})",
		target_segment,
		target_section,
		hex::encode(&sect_hash),
		u64::from_le_bytes(sect_hash[..8].try_into().unwrap())
			^ (u32::from_le_bytes(sect_hash[8..].try_into().unwrap()) as u64)
	);

	let ckey: u32 = rand::random();
	let jkey = rand::random();
	bytemuck::cast_slice_mut::<_, u32>(&mut sect_hash)
		.iter_mut()
		.enumerate()
		.for_each(|(idx, byte)| {
			let mul = (idx + 1) as u32;
			*byte = perfect_shuffle(*byte ^ ckey.wrapping_mul(mul))
		});

	CrcLookup {
		ckey: perfect_shuffle(ckey),
		checksum: sect_hash,
		size: sect.size,
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
	hasher: &mut blake3::Hasher,
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

	target_segments
		.iter()
		.zip(target_sections.iter())
		.for_each(|(segment_name, section_name)| {
			let (sect, mut sect_hash) = macho
				.segments
				.into_iter()
				.find(|x| x.name().unwrap() == *segment_name)
				.expect("failed to find target segment")
				.sections()
				.expect("failed to get sections")
				.into_iter()
				.find(|(section, _)| section.name().unwrap() == *section_name)
				.map(|(section, _)| {
					hasher.update(
						&binary[offset + section.offset as usize
							..offset + section.offset as usize + section.size as usize],
					);
					let hash: [u8; 12] = hasher.finalize().as_bytes()[..12]
						.to_vec()
						.try_into()
						.unwrap();
					hasher.reset();
					(section, hash)
				})
				.expect("failed to find target section");

			info!(
				"checksum of {},{}: {} (u64 value is {:#010X})",
				segment_name,
				section_name,
				hex::encode(&sect_hash),
				u64::from_le_bytes(sect_hash[..8].try_into().unwrap())
					^ (u32::from_le_bytes(sect_hash[8..].try_into().unwrap()) as u64)
			);

			let first_half =
				(perfect_shuffle(u32::from_le_bytes(sect_hash[0..4].try_into().unwrap())) as u64)
					<< 32;
			let second_half =
				perfect_shuffle(u32::from_le_bytes(sect_hash[8..12].try_into().unwrap())) as u64;
			let xorkey = (first_half | second_half)
				^ (u32::from_le_bytes(sect_hash[4..8].try_into().unwrap()) as u64);

			target_offset ^= xorkey;
			let ckey: u32 = rand::random();

			bytemuck::cast_slice_mut::<_, u32>(&mut sect_hash)
				.iter_mut()
				.enumerate()
				.for_each(|(idx, byte)| {
					let mul = (idx + 1) as u32;
					*byte = perfect_shuffle(*byte ^ ckey.wrapping_mul(mul))
				});

			out.push(CrcLookup {
				ckey: perfect_shuffle(ckey),
				checksum: sect_hash,
				size: sect.size,
				jkey: rand::random::<u64>() & !(1 << 0),
				jmp: rand::random::<u64>(),
			});
		});

	let mut last = out.iter_mut().last().unwrap();
	last.jkey |= 1 << 0;
	last.jmp = target_offset ^ last.jkey;

	out
}

pub fn handle(macho: &MachO, offset: usize, binary: &mut Vec<u8>, init: bool) {
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

	let mut hash_key = [0u8; 32];
	rng.fill_bytes(&mut hash_key);

	let mut hasher = blake3::Hasher::new_keyed(&hash_key);

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

	if init {
		crc_table.push(jmp_section(
			"__TEXT",
			"__text",
			"_initTweakFunc",
			&macho,
			&offsets,
			offset,
			&mut hasher,
			binary,
		));
	}
	crc_table.extend_from_slice(&jmp_section_multi(
		&["__DATA", "__DATA", "__TEXT"],
		&["__godzillatoc", "__godzillastrtb", "__godzilladk"],
		"_initialize_string_table",
		&macho,
		&offsets,
		offset,
		&mut hasher,
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

	let mut hash_key = hash_key.to_vec();
	hash_key.resize_with(16 * std::mem::size_of::<u32>(), || rng.gen());
	bytemuck::cast_slice_mut::<_, u32>(&mut hash_key)
		.iter_mut()
		.for_each(|byte| *byte = perfect_shuffle(*byte));
	let blake_key_range = macho
		.segments
		.into_iter()
		.find(|x| x.name().unwrap() == "__TEXT")
		.expect("failed to find text segment")
		.sections()
		.expect("failed to get sections")
		.into_iter()
		.find(|(section, _)| section.name().unwrap() == "__godzillahka")
		.map(|(section, _)| {
			offset + section.offset as usize
				..offset + section.offset as usize + section.size as usize
		})
		.expect("failed to find blake3 key section");
	binary.splice(
		blake_key_range,
		bytemuck::cast_slice(&hash_key).iter().copied(),
	);
}
