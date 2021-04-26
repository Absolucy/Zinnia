use crate::models::DecryptionKey;
use chacha20::{
	cipher::{NewStreamCipher, SyncStreamCipher},
	ChaCha20, Key, Nonce,
};
use goblin::mach::MachO;

pub fn handle(macho: &MachO, offset: usize, binary: &mut Vec<u8>) {
	let mut section_key = DecryptionKey::default();
	let section = macho
		.segments
		.into_iter()
		.find(|x| x.name().unwrap() == "__TEXT")
		.expect("failed to find target segment")
		.sections()
		.expect("failed to get sections")
		.into_iter()
		.find(|(section, _)| section.name().unwrap() == "__text")
		.map(|(section, _)| {
			let range = offset + section.offset as usize
				..offset + section.offset as usize + section.size as usize;
			&mut binary[range]
		})
		.expect("failed to find target section");
	ChaCha20::new(
		&Key::from_slice(bytemuck::cast_slice(&section_key.key)),
		&Nonce::from_slice(bytemuck::cast_slice(&section_key.nonce)),
	)
	.apply_keystream(section);

	println!("encrypted __TEXT,__text ({} bytes)", section.len());

	section_key.shuffle();
	let section_key: &[u8] = bytemuck::bytes_of(&section_key);

	let key_range = macho
		.segments
		.into_iter()
		.find(|x| x.name().unwrap() == "__TEXT")
		.expect("failed to find data segment")
		.sections()
		.expect("failed to get sections")
		.into_iter()
		.find(|(section, _)| section.name().unwrap() == "__godzillakay")
		.map(|(section, _)| {
			offset + section.offset as usize
				..offset + section.offset as usize + section.size as usize
		})
		.expect("failed to find text encryption key section");

	binary.splice(key_range, section_key.iter().copied());
}
