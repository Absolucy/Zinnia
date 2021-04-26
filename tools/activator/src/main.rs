#![feature(asm)]

pub(crate) mod authorize;
#[allow(dead_code)]
pub(crate) mod crc;
pub(crate) mod http;
pub(crate) mod pin;
pub(crate) mod udid;
pub(crate) mod validate;

#[macro_export]
#[cfg(not(debug_assertions))]
macro_rules! handle_err {
	($x:expr, $code:expr) => {
		$x.unwrap_or_else(|_| std::process::exit($code));
	};
}

#[macro_export]
#[cfg(not(debug_assertions))]
macro_rules! handle_nil {
	($x:expr, $code:expr) => {
		$x.unwrap_or_else(|| std::process::exit($code));
	};
}

#[macro_export]
#[cfg(debug_assertions)]
macro_rules! handle_err {
	($x:expr, $code:expr) => {
		$x.expect(&format!("error #{}", $code))
	};
}

#[macro_export]
#[cfg(debug_assertions)]
macro_rules! handle_nil {
	($x:expr, $code:expr) => {
		$x.expect(&format!("nil #{}", $code))
	};
}

use chacha20poly1305::{
	aead::{Aead, NewAead},
	ChaCha20Poly1305, Key, Nonce,
};
use deku::prelude::*;
use obfstr::obfstr;
use std::io::Read;

const DRM_AUTH_URL: &str = "https://aiwass.aspenuwu.me/v1/authorize";
const DRM_VALIDATE_URL: &str = "https://aiwass.aspenuwu.me/v1/authorize";
#[cfg(not(feature = "trial"))]
const TWEAK_NAME: &str = "me.aspenuwu.zinnia";
#[cfg(feature = "trial")]
const TWEAK_NAME: &str = "me.aspenuwu.zinnia.trial";
const TICKET_LOCATION: &str = "/var/mobile/Library/Application Support/TWEAK_NAME/.goldenticket";

#[derive(DekuRead)]
#[deku(endian = "little", magic = b"\x2A\x2A\x2A\x2A")]
struct StartupData {
	_a1: [u8; 15],
	key_xor: [u8; 32],
	key: [u8; 32],
	_a2: [u8; 5],
	nonce_xor: [u8; 12],
	_a3: [u8; 3],
	udid_nonce: [u8; 12],
	_a4: [u8; 60],
	_udid_size: u64,
	_a5: [u8; 30],
	#[deku(count = "_udid_size")]
	udid: Vec<u8>,
	_model_size: u64,
	_a6: [u8; 87],
	#[deku(count = "_model_size")]
	model: Vec<u8>,
	_a7: [u8; 29],
	model_nonce: [u8; 12],
}

impl StartupData {
	#[inline(always)]
	fn get_key(&self) -> Key {
		*Key::from_slice(
			&self
				.key
				.iter()
				.zip(self.key_xor.iter())
				.enumerate()
				.map(|(idx, (byte, key))| *byte ^ key.wrapping_mul(idx as u8 + 1))
				.collect::<Vec<u8>>(),
		)
	}

	#[inline(always)]
	fn get_nonce(&self, nonce: &[u8; 12]) -> Nonce {
		*Nonce::from_slice(
			&nonce
				.iter()
				.zip(self.nonce_xor.iter())
				.enumerate()
				.map(|(idx, (byte, key))| *byte ^ key.wrapping_mul(idx as u8 + 1))
				.collect::<Vec<u8>>(),
		)
	}

	#[inline(always)]
	fn get_udid(&self) -> String {
		let key = self.get_key();
		let nonce = self.get_nonce(&self.udid_nonce);
		let cc20 = ChaCha20Poly1305::new(&key);
		handle_nil!(
			cc20.decrypt(&nonce, self.udid.as_ref())
				.ok()
				.and_then(|decrypted| String::from_utf8(decrypted).ok()),
			-2
		)
	}

	#[inline(always)]
	fn get_model(&self) -> String {
		let key = self.get_key();
		let nonce = self.get_nonce(&self.model_nonce);
		let cc20 = ChaCha20Poly1305::new(&key);
		handle_nil!(
			cc20.decrypt(&nonce, self.model.as_ref())
				.ok()
				.and_then(|decrypted| String::from_utf8(decrypted).ok()),
			-3
		)
	}
}

#[tokio::main]
async fn main() {
	let input = std::env::args()
		.collect::<Vec<String>>()
		.get(1)
		.and_then(|s| s.chars().next())
		.filter(|c| {
			c.is_ascii_alphabetic()
				&& obfstr!("______________________________a___v___________________________________")
					.contains(*c)
		});
	let stdin = std::io::stdin();
	let mut stdin = stdin.lock();
	let input = match input {
		Some(arg) => arg,
		None => {
			let mut byte = [0u8];
			handle_err!(stdin.read_exact(&mut byte), 1);
			byte[0] as char
		}
	};
	match input {
		'a' => authorize::authorize(stdin).await,
		'v' => validate::validate().await,
		_ => std::process::exit(2),
	}
	std::process::exit(0);
}
