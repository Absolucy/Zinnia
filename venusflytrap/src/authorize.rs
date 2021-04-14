use super::{StartupData, DRM_AUTH_URL, HTTP_CLIENT, TWEAK_NAME};
use deku::DekuContainerRead;
use libaiwass::{AuthStatus, AuthorizationRequest, AuthorizationTicket};
use obfstr::{obfstr, xref};
use std::io::{Read, StdinLock, Write};

pub async fn authorize(mut stdin: StdinLock<'_>) {
	let mut data = String::with_capacity(std::mem::size_of::<StartupData>() * 2);

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
		&base64::decode(&data).unwrap_or_else(|_| std::process::exit(3)),
		0,
	))
	.unwrap_or_else(|_| std::process::exit(4))
	.1;

	let udid = data.get_udid();
	let model = data.get_model();
	let request = AuthorizationRequest::new(
		&udid,
		&model,
		obfstr!(TWEAK_NAME),
		obfstr!(env!("CARGO_PKG_VERSION")),
	);
	let response = xref!(&HTTP_CLIENT)
		.post(obfstr!(DRM_AUTH_URL))
		.json(&request)
		.send()
		.await
		.unwrap_or_else(|_| std::process::exit(5));
	let ticket: AuthorizationTicket = response
		.json()
		.await
		.unwrap_or_else(|_| std::process::exit(6));
	if ticket.validate(obfstr!(TWEAK_NAME), &udid, &model) != AuthStatus::Valid {
		std::process::exit(7);
	}
	let json = serde_json::to_string(&ticket).unwrap_or_else(|_| std::process::exit(8));
	let stdout = std::io::stdout();
	stdout
		.lock()
		.write_all(json.as_bytes())
		.unwrap_or_else(|_| std::process::exit(9));
}
