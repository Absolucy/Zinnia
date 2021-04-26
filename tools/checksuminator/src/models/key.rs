use crate::shuffle::perfect_shuffle;
use bytemuck::{Pod, Zeroable};
use rand::RngCore;

#[derive(Debug, Copy, Clone, Pod, Zeroable)]
#[repr(C)]
pub struct DecryptionKey {
	pub key: [u32; 8],
	pub nonce: [u32; 3],
	pub xor_key: [u32; 8],
	pub xor_nonce: [u32; 3],
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
