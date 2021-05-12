use super::DecryptionKey;
use crate::shuffle::perfect_shuffle;
use bytemuck::{Pod, Zeroable};
use chacha20::{
	cipher::{NewCipher, StreamCipher},
	ChaCha20, Key, Nonce,
};

#[derive(Debug, Copy, Clone, Pod, Zeroable)]
#[repr(C)]
pub struct StringEntry {
	length: u32,
	keys: DecryptionKey,
}

impl StringEntry {
	pub fn new(mut data: Vec<u8>) -> (Self, Vec<u8>) {
		let mut keys = DecryptionKey::default();
		ChaCha20::new(
			&Key::from_slice(bytemuck::cast_slice(&keys.key)),
			&Nonce::from_slice(bytemuck::cast_slice(&keys.nonce)),
		)
		.apply_keystream(&mut data);
		keys.shuffle();

		(
			Self {
				length: perfect_shuffle(data.len() as u32),
				keys,
			},
			data,
		)
	}
}
