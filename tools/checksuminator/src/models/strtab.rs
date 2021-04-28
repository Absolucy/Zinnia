use super::DecryptionKey;
use crate::shuffle::perfect_shuffle;
use bytemuck::{Pod, Zeroable};
use chacha20::{
	cipher::{NewStreamCipher, SyncStreamCipher},
	ChaCha20, Key, Nonce,
};
use trim_in_place::TrimInPlace;

#[derive(Debug, Copy, Clone, Pod, Zeroable)]
#[repr(C)]
pub struct StringEntry {
	length: u32,
	keys: DecryptionKey,
}

impl StringEntry {
	pub fn new(string: String) -> (Self, Vec<u8>) {
		let mut data = preprocessor_handle_file(&string)
			.or_else(|| preprocessor_handle_base64(&string))
			.or_else(|| preprocessor_handle_b3sum(&string))
			.or_else(|| preprocessor_handle_env(&string))
			.or_else(|| preprocessor_handle_if(&string))
			.unwrap_or_else(|| preprocessor_handle_string(string));

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

fn preprocessor_handle_file(string: &str) -> Option<Vec<u8>> {
	string
		.strip_prefix("[")
		.and_then(|s| s.strip_suffix("]"))
		.map(|filename| {
			let filename = filename.trim();
			std::fs::read(filename)
				.unwrap_or_else(|err| panic!("failed to read file '{}':\n{:?}", filename, err))
		})
}

fn preprocessor_handle_base64(string: &str) -> Option<Vec<u8>> {
	string
		.strip_prefix("base64:")
		.and_then(|b64| base64::decode(b64.trim()).ok())
}

fn preprocessor_handle_b3sum(string: &str) -> Option<Vec<u8>> {
	string.strip_prefix("b3sum:").map(|filename| {
		let filename = filename.trim();
		let contents = std::fs::read(filename)
			.unwrap_or_else(|err| panic!("failed to read file '{}':\n{:?}", filename, err));
		Into::<[u8; 32]>::into(blake3::hash(&contents)).to_vec()
	})
}

fn preprocessor_handle_env(string: &str) -> Option<Vec<u8>> {
	string
		.strip_prefix("env:")
		.map(|var| preprocessor_handle_string(std::env::var(var.trim()).unwrap_or_default()))
}

fn preprocessor_handle_if(string: &str) -> Option<Vec<u8>> {
	string.strip_prefix("if:").and_then(|var| {
		let mut stuff = var.splitn(3, ':');
		let (condition, if_true, if_false) = (stuff.next()?, stuff.next()?, stuff.next()?);
		let condition_var = std::env::var(condition.trim())
			.map(|value| {
				let value = value.trim();
				!(value.is_empty() || value == "0" || value.to_lowercase() == "false")
			})
			.unwrap_or(false);
		Some(preprocessor_handle_string(if condition_var {
			if_true.to_string()
		} else {
			if_false.to_string()
		}))
	})
}

fn preprocessor_handle_string(mut string: String) -> Vec<u8> {
	string.trim_in_place();
	let mut string = string.into_bytes();
	string.push(0);
	string
}
