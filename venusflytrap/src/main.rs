use chacha20poly1305::{
	aead::{Aead, NewAead},
	ChaCha20Poly1305, Key, Nonce,
};
use deku::prelude::*;
use obfstr::obfstr;
use std::{
	io::{Read, Write},
	time::Duration,
};
use venusflytrap::{AuthStatus, AuthorizationRequest, AuthorizationTicket};

const DRM_URL: &str = "https://aiwass.aspenuwu.me/authorize";
const TWEAK_NAME: &str = "Zinnia";

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
	_a4: [u8; 30],
	_a5: [u8; 30],
	_udid_size: u64,
	_a6: [u8; 30],
	#[deku(count = "_udid_size")]
	udid: Vec<u8>,
	_model_size: u64,
	_a7: [u8; 29],
	_a8: [u8; 29],
	_a9: [u8; 29],
	#[deku(count = "_model_size")]
	model: Vec<u8>,
	_a10: [u8; 29],
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
			.unwrap_or_else(|| std::process::exit(1 << 2))
	}

	#[inline(always)]
	fn get_model(&self) -> String {
		let key = self.get_key();
		let nonce = self.get_nonce(&self.model_nonce);
		let cc20 = ChaCha20Poly1305::new(&key);
		cc20.decrypt(&nonce, self.model.as_ref())
			.ok()
			.and_then(|decrypted| String::from_utf8(decrypted).ok())
			.unwrap_or_else(|| std::process::exit(1 << 3))
	}
}

#[tokio::main]
async fn main() {
	let mut data = String::with_capacity(std::mem::size_of::<StartupData>() * 2);
	let stdin = std::io::stdin();
	let mut stdin = stdin.lock();

	let mut byte = [0u8];
	obfstr! {
		let table = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
	};
	while stdin.read_exact(&mut byte).is_ok() {
		let c = byte[0] as char;
		if !table.contains(c) {
			break;
		}
		data.push(c);
	}

	let data = StartupData::from_bytes((
		&base64::decode(&data).unwrap_or_else(|_| std::process::exit(1 << 3)),
		0,
	))
	.unwrap_or_else(|_| std::process::exit(1 << 5))
	.1;

	let udid = data.get_udid();
	let model = data.get_model();
	let request = AuthorizationRequest::new(
		&udid,
		&model,
		obfstr!(TWEAK_NAME),
		obfstr!(env!("CARGO_PKG_VERSION")),
	);
	let response = reqwest::Client::new()
		.post(obfstr!(DRM_URL))
		.timeout(Duration::from_secs(15))
		.header(
			obfstr!("User-Agent"),
			[obfstr!(TWEAK_NAME), obfstr!(env!("CARGO_PKG_VERSION"))].join("-"),
		)
		.header(obfstr!("Content-Type"), obfstr!("application/json"))
		.json(&request)
		.send()
		.await
		.unwrap_or_else(|_| std::process::exit(1 << 6));
	let ticket: AuthorizationTicket = response
		.json()
		.await
		.unwrap_or_else(|_| std::process::exit(1 << 7));
	if ticket.validate(obfstr!(TWEAK_NAME), &udid, &model) != AuthStatus::Valid {
		std::process::exit(0);
	}
	let json = serde_json::to_string(&ticket).unwrap_or_else(|_| std::process::exit(1 << 8));
	let stdout = std::io::stdout();
	stdout
		.lock()
		.write_all(json.as_bytes())
		.unwrap_or_else(|_| std::process::exit(1 << 9));
}
