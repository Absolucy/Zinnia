use bytemuck::{Pod, Zeroable};
use chacha20::{
	cipher::{NewStreamCipher, SyncStreamCipher},
	ChaCha20, Key, Nonce,
};
use goblin::mach::MachO;
use rand::RngCore;
use std::convert::TryInto;

#[derive(Debug, Copy, Clone, Pod, Zeroable)]
#[repr(C)]
pub struct StringEntry {
	length: u32,
	key: [u32; 8],
	nonce: [u32; 3],
	xor_key: [u32; 8],
	xor_nonce: [u32; 3],
}

pub fn handle(macho: &MachO, offset: usize, binary: &mut Vec<u8>) {
	let strings = std::fs::read_to_string("strings.txt")
		.unwrap()
		.split("---")
		.map(|x| x.trim().to_string())
		.collect::<Vec<String>>();

	let total_len = strings.iter().fold(0, |x, s| x + s.len() + 1);
	let mut table = Vec::<StringEntry>::with_capacity(strings.len());
	let mut raw_strings = Vec::<u8>::with_capacity(total_len);
	assert!(total_len <= 32768);
	assert!(strings.len() <= 100);

	strings.into_iter().for_each(|string| {
		let (entry, encrypted) = StringEntry::new(&string);
		table.push(entry);
		raw_strings.extend_from_slice(&encrypted);
	});

	let mut raw_table = bytemuck::cast_slice::<_, u8>(&table).to_vec();

	assert!(raw_table.len() <= 100 * std::mem::size_of::<StringEntry>());
	assert!(raw_strings.len() <= 32768);
	raw_table.resize_with(100 * std::mem::size_of::<StringEntry>(), rand::random);
	raw_strings.resize_with(32768, rand::random);

	let table_range = macho
		.segments
		.into_iter()
		.find(|x| x.name().unwrap() == "__TEXT")
		.expect("failed to find text segment")
		.sections()
		.expect("failed to get sections")
		.into_iter()
		.find(|(section, _)| section.name().unwrap() == "__GODZILLATOC")
		.map(|(section, _)| {
			offset + section.offset as usize
				..offset + section.offset as usize + section.size as usize
		})
		.expect("failed to find string table of contents section");
	let strings_range = macho
		.segments
		.into_iter()
		.find(|x| x.name().unwrap() == "__TEXT")
		.expect("failed to find text segment")
		.sections()
		.expect("failed to get sections")
		.into_iter()
		.find(|(section, _)| section.name().unwrap() == "__GODZILLASTRTB")
		.map(|(section, _)| {
			offset + section.offset as usize
				..offset + section.offset as usize + section.size as usize
		})
		.expect("failed to find encrypted string table section");

	println!(
		"__GZTOC = {}, raw_table = {}",
		table_range.len(),
		raw_table.len()
	);
	println!(
		"__GZSTB = {}, raw_strings = {}",
		strings_range.len(),
		raw_strings.len()
	);

	binary.splice(table_range, raw_table.iter().copied());
	binary.splice(strings_range, raw_strings.iter().copied());
}

impl StringEntry {
	pub fn new(string: &str) -> (Self, Vec<u8>) {
		let mut string = string.as_bytes().to_vec();
		string.push(0);
		let mut rng = rand::thread_rng();
		let mut key = vec![0u8; 32];
		let mut nonce = vec![0u8; 12];
		let mut xor_key = vec![0u8; 32];
		let mut xor_nonce = vec![0u8; 12];
		rng.fill_bytes(&mut key);
		rng.fill_bytes(&mut nonce);
		rng.fill_bytes(&mut xor_key);
		rng.fill_bytes(&mut xor_nonce);

		ChaCha20::new(&Key::from_slice(&key), &Nonce::from_slice(&nonce))
			.apply_keystream(&mut string);

		let key: [u32; 8] = bytemuck::cast_slice::<_, u32>(&key).try_into().unwrap();
		let nonce: [u32; 3] = bytemuck::cast_slice::<_, u32>(&nonce).try_into().unwrap();
		let xor_key: [u32; 8] = bytemuck::cast_slice::<_, u32>(&xor_key).try_into().unwrap();
		let xor_nonce: [u32; 3] = bytemuck::cast_slice::<_, u32>(&xor_nonce)
			.try_into()
			.unwrap();

		(
			Self {
				length: string.len() as u32,
				key: key
					.iter()
					.zip(xor_key.iter())
					.map(|(a, b)| perfect_shuffle(*a ^ *b))
					.collect::<Vec<u32>>()
					.try_into()
					.unwrap(),
				nonce: nonce
					.iter()
					.zip(xor_nonce.iter())
					.map(|(a, b)| perfect_shuffle(*a ^ *b))
					.collect::<Vec<u32>>()
					.try_into()
					.unwrap(),
				xor_key: xor_key
					.iter()
					.map(|byte| perfect_shuffle(*byte))
					.collect::<Vec<u32>>()
					.try_into()
					.unwrap(),
				xor_nonce: xor_nonce
					.iter()
					.map(|byte| perfect_shuffle(*byte))
					.collect::<Vec<u32>>()
					.try_into()
					.unwrap(),
			},
			string,
		)
	}
}

pub fn perfect_shuffle(mut x: u32) -> u32 {
	x = (x & (0xff0000ff)) | ((x & (0x00ff0000)) >> 8) | ((x & (0x0000ff00)) << 8);
	x = (x & (0xf00ff00f)) | ((x & (0x0f000f00)) >> 4) | ((x & (0x00f000f0)) << 4);
	x = (x & (0xc3c3c3c3)) | ((x & (0x30303030)) >> 2) | ((x & (0x0c0c0c0c)) << 2);
	x = (x & (0x99999999)) | ((x & (0x44444444)) >> 1) | ((x & (0x22222222)) << 1);
	x
}
