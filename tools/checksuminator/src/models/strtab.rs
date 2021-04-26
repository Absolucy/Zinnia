use super::DecryptionKey;
use crate::shuffle::perfect_shuffle;
use bytemuck::{Pod, Zeroable};
use chacha20::{
	cipher::{NewStreamCipher, SyncStreamCipher},
	ChaCha20, Key, Nonce,
};

#[derive(Debug, Copy, Clone, Pod, Zeroable)]
#[repr(C)]
pub struct StringEntry {
	length: u32,
	keys: DecryptionKey,
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
