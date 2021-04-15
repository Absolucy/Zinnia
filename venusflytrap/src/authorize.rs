use super::{handle_err, http, StartupData, DRM_AUTH_URL, TWEAK_NAME};
use deku::DekuContainerRead;
use libaiwass::{AnalyticsInfo, AuthStatus, AuthorizationRequest, AuthorizationTicket};
use obfstr::obfstr;
use objc::runtime::Object;
use objc_foundation::{INSString, NSString};
use std::io::{Read, StdinLock, Write};

#[inline(always)]
pub fn ios_version() -> String {
	unsafe {
		let process_info: &Object = msg_send![class!(NSProcessInfo), processInfo];
		let version: &NSString = msg_send![process_info, operatingSystemVersionString];
		let version = version.as_str();
		version.strip_prefix(obfstr!("Version ")).unwrap_or(version)
	}
	.to_string()
}

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

	let data = handle_err!(
		StartupData::from_bytes((&handle_err!(base64::decode(&data), 3), 0)),
		4
	)
	.1;

	let info = AnalyticsInfo {
		ios_version: ios_version(),
		..AnalyticsInfo::default()
	};

	let udid = data.get_udid();
	let model = data.get_model();
	let request = AuthorizationRequest::new(
		&udid,
		&model,
		obfstr!(TWEAK_NAME),
		obfstr!(env!("CARGO_PKG_VERSION")),
		info,
	);
	let response = handle_err!(
		http::client()
			.post(obfstr!(DRM_AUTH_URL))
			.json(&request)
			.send()
			.await,
		5
	);
	let ticket: AuthorizationTicket = handle_err!(response.json().await, 6);
	if ticket.validate(obfstr!(TWEAK_NAME), &udid, &model) != AuthStatus::Valid {
		std::process::exit(7);
	}
	let json = handle_err!(serde_json::to_string(&ticket), 8);
	let stdout = std::io::stdout();
	handle_err!(stdout.lock().write_all(json.as_bytes()), 9);
}
