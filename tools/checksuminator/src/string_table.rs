use bytemuck::{Pod, Zeroable};
use chacha20::{
	cipher::{NewStreamCipher, SyncStreamCipher},
	ChaCha20, Key, Nonce,
};
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

impl StringEntry {
	pub fn new(string: &str) -> (Self, Vec<u8>) {
		let mut string = string.as_bytes().to_vec();
		let mut rng = rand::thread_rng();
		let mut key = vec![0u8; 32];
		let mut xor_key = vec![0u32; 8];
		let mut nonce = vec![0u8; 12];
		let mut xor_nonce = vec![0u32; 3];
		rng.fill_bytes(&mut key);
		rng.fill_bytes(bytemuck::cast_slice_mut(&mut xor_key));
		rng.fill_bytes(&mut nonce);
		rng.fill_bytes(bytemuck::cast_slice_mut(&mut xor_nonce));

		ChaCha20::new(&Key::from_slice(&key), &Nonce::from_slice(&nonce))
			.apply_keystream(&mut string);

		let key: &[u32] = bytemuck::cast_slice(&key);
		assert_eq!(key.len(), 8);
		let nonce: &[u32] = bytemuck::cast_slice(&nonce);
		assert_eq!(key.len(), 3);

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
