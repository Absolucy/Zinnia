mod authorize;
mod udid;
mod validate;

use chacha20poly1305::{
	aead::{Aead, NewAead},
	ChaCha20Poly1305, Key, Nonce,
};
use deku::prelude::*;
use obfstr::{obfstr, xref};
use once_cell::sync::Lazy;
use std::{io::Read, time::Duration};

const DRM_AUTH_URL: &str = "https://aiwass.aspenuwu.me/v1/authorize";
const DRM_VALIDATE_URL: &str = "https://aiwass.aspenuwu.me/v1/authorize";
const TWEAK_NAME: &str = "me.aspenuwu.zinnia";
const TICKET_LOCATION: &str = "/var/mobile/Library/Application Support/TWEAK_NAME/.goldenticket";

static HTTP_CLIENT: Lazy<reqwest::Client> = Lazy::new(|| {
	static TIMEOUT: u64 = 15;
	let mut headers = reqwest::header::HeaderMap::new();
	headers.insert(
		reqwest::header::HeaderName::from_bytes(obfstr!("User-Agent").as_bytes())
			.unwrap_or_else(|_| std::process::exit(1)),
		[obfstr!(TWEAK_NAME), obfstr!(env!("CARGO_PKG_VERSION"))]
			.join(obfstr!(" "))
			.parse()
			.unwrap_or_else(|_| std::process::exit(1)),
	);
	headers.insert(
		reqwest::header::HeaderName::from_bytes(obfstr!("Content-Type").as_bytes())
			.unwrap_or_else(|_| std::process::exit(1)),
		obfstr!("application/json")
			.to_string()
			.parse()
			.unwrap_or_else(|_| std::process::exit(1)),
	);
	reqwest::ClientBuilder::new()
		.timeout(Duration::from_secs(*xref!(&TIMEOUT)))
		.default_headers(headers)
		.build()
		.unwrap_or_else(|_| std::process::exit(1))
});

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
				.map(|(byte, key)| *byte ^ *key)
				.collect::<Vec<u8>>(),
		)
	}

	#[inline(always)]
	fn get_nonce(&self, nonce: &[u8; 12]) -> Nonce {
		*Nonce::from_slice(
			&nonce
				.iter()
				.zip(self.nonce_xor.iter())
				.map(|(byte, key)| *byte ^ *key)
				.collect::<Vec<u8>>(),
		)
	}

	#[inline(always)]
	fn get_udid(&self) -> String {
		let key = self.get_key();
		let nonce = self.get_nonce(&self.udid_nonce);
		let cc20 = ChaCha20Poly1305::new(&key);
		cc20.decrypt(&nonce, self.udid.as_ref())
			.ok()
			.and_then(|decrypted| String::from_utf8(decrypted).ok())
			.unwrap_or_else(|| std::process::exit(1))
	}

	#[inline(always)]
	fn get_model(&self) -> String {
		let key = self.get_key();
		let nonce = self.get_nonce(&self.model_nonce);
		let cc20 = ChaCha20Poly1305::new(&key);
		cc20.decrypt(&nonce, self.model.as_ref())
			.ok()
			.and_then(|decrypted| String::from_utf8(decrypted).ok())
			.unwrap_or_else(|| std::process::exit(1))
	}
}

#[tokio::main]
async fn main() {
	let stdin = std::io::stdin();
	let mut stdin = stdin.lock();
	let mut byte = [0u8];
	stdin
		.read_exact(&mut byte)
		.unwrap_or_else(|_| std::process::exit(1));
	let input = byte[0] as char;
	match input {
		'a' => authorize::authorize(stdin).await,
		'v' => validate::validate().await,
		_ => std::process::exit(1),
	}
	std::process::exit(0);
}
