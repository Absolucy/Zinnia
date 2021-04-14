use super::{udid::get_udid, DRM_VALIDATE_URL, HTTP_CLIENT, TICKET_LOCATION, TWEAK_NAME};
use chacha20poly1305::{
	aead::{Aead, NewAead, Payload},
	ChaCha20Poly1305, Key, Nonce,
};
use libaiwass::{AuthorizationTicket, ValidationRequest};
use obfstr::{
	bytes::{deobfuscate, keystream, obfuscate},
	obfstr, random, xref,
};
use sha2::{Digest, Sha256};

static BAD_EXIT_CODE: i32 = 89;

#[inline(always)]
fn model() -> String {
	uname::uname()
		.unwrap_or_else(|_| std::process::exit(1))
		.machine
}

fn get_key() -> Vec<u8> {
	const KEYSTREAM: [u8; 32] = keystream(random!(u32));
	const KEY: [u8; 32] = obfuscate(b"\xaa\x8d\x5e\x80\x8d\x0c\xf3\x81\x84\x99\x29\x67\x61\x8e\x38\x5f\xe0\x89\x82\x57\x6d\xfd\x25\xce\xaf\xd2\xac\xe2\xf2\xb8\xd7\x30", &KEYSTREAM);
	let key = deobfuscate(&KEY, &KEYSTREAM);
	let mut hasher = Sha256::new();
	hasher.update(get_udid());
	hasher
		.finalize()
		.into_iter()
		.zip(key.iter())
		.map(|(byte, key)| byte ^ key)
		.collect()
}

fn get_aad() -> Vec<u8> {
	const KEYSTREAM: [u8; 32] = keystream(random!(u32));
	const KEY: [u8; 32] = obfuscate(b"\xb3\x05\x4f\x6b\xeb\x87\x75\xa6\x7b\x4b\xc5\xfc\x2f\xef\x82\xf6\x1f\x45\x46\xe1\xae\x64\xe1\x53\xf7\xd3\xdb\x80\x4e\x70\xff\x8f", &KEYSTREAM);
	let key = deobfuscate(&KEY, &KEYSTREAM);
	let mut hasher = Sha256::new();
	hasher.update(model());
	hasher
		.finalize()
		.into_iter()
		.zip(key.iter())
		.map(|(byte, key)| byte ^ key)
		.collect()
}

pub async fn validate() {
	let encrypted_ticket = tokio::fs::read(
		obfstr!(TICKET_LOCATION).replace(obfstr!("TWEAK_NAME"), obfstr!(TWEAK_NAME)),
	)
	.await
	.unwrap_or_else(|_| std::process::exit(1));

	let key = get_key();
	let nonce = Nonce::from_slice(&encrypted_ticket[..12]);
	let aad = get_aad();
	let ciphertext = Payload {
		msg: &encrypted_ticket[12..],
		aad: &aad,
	};

	let ticket: AuthorizationTicket = ChaCha20Poly1305::new(Key::from_slice(&key))
		.decrypt(nonce, ciphertext)
		.ok()
		.and_then(|decrypted| serde_json::from_slice(&decrypted).ok())
		.unwrap_or_else(|| std::process::exit(1));

	let validation_request = ValidationRequest {
		uuid: ticket.uuid,
		udid: get_udid(),
		model: model(),
		tweak: obfstr!(TWEAK_NAME).to_string(),
	};

	let response = xref!(&HTTP_CLIENT)
		.post(obfstr!(DRM_VALIDATE_URL))
		.json(&validation_request)
		.send()
		.await
		.unwrap_or_else(|_| std::process::exit(1));

	if response.status().is_success() {
		let response = response
			.bytes()
			.await
			.map(|bytes| bytes.to_vec())
			.unwrap_or_else(|_| std::process::exit(1));
		debug_assert!(!response.is_empty());
		debug_assert!(response.len() <= 9);
		if response.is_empty() || response.len() > 9 {
			std::process::exit(1);
		}
		let flag = vint64::decode(&mut response.as_ref()).unwrap_or_else(|_| std::process::exit(1));
		if flag & (1 << (flag & 0xFF)) != 0 {
			std::mem::drop(
				tokio::fs::remove_file(
					obfstr!(TICKET_LOCATION).replace(obfstr!("TWEAK_NAME"), obfstr!(TWEAK_NAME)),
				)
				.await,
			);
			std::process::exit(*xref!(&BAD_EXIT_CODE));
		}
	}
}
