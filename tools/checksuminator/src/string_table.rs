use bytemuck::{Pod, Zeroable};
use chacha20::{
	cipher::{NewStreamCipher, SyncStreamCipher},
	ChaCha20, Key, Nonce,
};
use goblin::mach::MachO;
use rand::RngCore;

#[derive(Debug, Copy, Clone, Pod, Zeroable)]
#[repr(C)]
struct DecryptionKey {
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

#[derive(Debug, Copy, Clone, Pod, Zeroable)]
#[repr(C)]
pub struct StringEntry {
	length: u32,
	keys: DecryptionKey,
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
	let mut section_keys = [DecryptionKey::default(), DecryptionKey::default()];
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

	ChaCha20::new(
		&Key::from_slice(bytemuck::cast_slice(&section_keys[0].key)),
		&Nonce::from_slice(bytemuck::cast_slice(&section_keys[0].nonce)),
	)
	.apply_keystream(&mut raw_table);
	ChaCha20::new(
		&Key::from_slice(bytemuck::cast_slice(&section_keys[1].key)),
		&Nonce::from_slice(bytemuck::cast_slice(&section_keys[1].nonce)),
	)
	.apply_keystream(&mut raw_strings);

	section_keys[0].shuffle();
	section_keys[1].shuffle();
	let section_keys: &[u8] = bytemuck::cast_slice(&section_keys);

	let table_range = macho
		.segments
		.into_iter()
		.find(|x| x.name().unwrap() == "__DATA")
		.expect("failed to find data segment")
		.sections()
		.expect("failed to get sections")
		.into_iter()
		.find(|(section, _)| section.name().unwrap() == "__godzillatoc")
		.map(|(section, _)| {
			offset + section.offset as usize
				..offset + section.offset as usize + section.size as usize
		})
		.expect("failed to find string table of contents section");
	let strings_range = macho
		.segments
		.into_iter()
		.find(|x| x.name().unwrap() == "__DATA")
		.expect("failed to find data segment")
		.sections()
		.expect("failed to get sections")
		.into_iter()
		.find(|(section, _)| section.name().unwrap() == "__godzillastrtb")
		.map(|(section, _)| {
			offset + section.offset as usize
				..offset + section.offset as usize + section.size as usize
		})
		.expect("failed to find encrypted string table section");
	let keys_range = macho
		.segments
		.into_iter()
		.find(|x| x.name().unwrap() == "__TEXT")
		.expect("failed to find text segment")
		.sections()
		.expect("failed to get sections")
		.into_iter()
		.find(|(section, _)| section.name().unwrap() == "__godzilladk")
		.map(|(section, _)| {
			offset + section.offset as usize
				..offset + section.offset as usize + section.size as usize
		})
		.expect("failed to find string table keys section");

	binary.splice(table_range, raw_table.iter().copied());
	binary.splice(strings_range, raw_strings.iter().copied());
	binary.splice(keys_range, section_keys.iter().copied());
}

impl StringEntry {
	pub fn new<S: AsRef<[u8]>>(string: S) -> (Self, Vec<u8>) {
		Self::new_impl(string.as_ref().to_vec())
	}

	fn new_impl(mut string: Vec<u8>) -> (Self, Vec<u8>) {
		string.push(0);

		let mut keys = DecryptionKey::default();
		ChaCha20::new(
			&Key::from_slice(bytemuck::cast_slice(&keys.key)),
			&Nonce::from_slice(bytemuck::cast_slice(&keys.nonce)),
		)
		.apply_keystream(&mut string);
		keys.shuffle();

		(
			Self {
				length: perfect_shuffle(string.len() as u32),
				keys,
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
