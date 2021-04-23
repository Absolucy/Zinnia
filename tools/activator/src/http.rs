use crate::{handle_err, pin::tls_config, validate::model, TWEAK_NAME};
use obfstr::{obfstr, xref};
use static_init::dynamic;
use std::{ops::Deref, path::Path, time::Duration};

#[dynamic(drop)]
static mut HTTP_CLIENT: reqwest::Client = {
	static TIMEOUT: u64 = 15;
	let mut headers = reqwest::header::HeaderMap::new();
	headers.insert(
		handle_err!(
			reqwest::header::HeaderName::from_bytes(obfstr!("User-Agent").as_bytes()),
			1
		),
		handle_err!(
			format!(
				"{}/{} ({}; {}; iOS {})",
				obfstr!(TWEAK_NAME),
				obfstr!(env!("CARGO_PKG_VERSION")),
				model(),
				jailbreak(),
				ios_version()
			)
			.parse(),
			1
		),
	);
	headers.insert(
		handle_err!(
			reqwest::header::HeaderName::from_bytes(obfstr!("Content-Type").as_bytes()),
			1
		),
		handle_err!(obfstr!("application/json").to_string().parse(), 1),
	);
	handle_err!(
		reqwest::ClientBuilder::new()
			.timeout(Duration::from_secs(*xref!(&TIMEOUT)))
			.default_headers(headers)
			.use_preconfigured_tls(tls_config())
			.build(),
		1
	)
};

pub fn ios_version() -> String {
	#[repr(C)]
	struct VersionInfo {
		major: i64,
		minor: i64,
		patch: i64,
	}
	extern "C" {
		fn get_version_info() -> VersionInfo;
	}

	let info = unsafe { get_version_info() };
	if info.patch > 0 {
		[
			info.major.to_string(),
			info.minor.to_string(),
			info.patch.to_string(),
		]
		.join("")
	} else {
		[info.major.to_string(), info.minor.to_string()].join("")
	}
}

pub fn jailbreak() -> String {
	if Path::new(obfstr!("/taurine/jailbreakd")).exists() {
		obfstr!("Taurine").to_string()
	} else if Path::new(obfstr!("/usr/libexec/libhooker/pspawn_payload.dylib")).exists()
		&& Path::new(obfstr!("/.procursus_strapped")).exists()
	{
		obfstr!("odysseyra1n").to_string()
	} else if Path::new(obfstr!("/usr/libexec/libhooker/pspawn_payload.dylib")).exists() {
		obfstr!("unknown libhooker jb").to_string()
	} else if Path::new(obfstr!("/var/checkra1n.dmg")).exists() {
		obfstr!("checkra1n").to_string()
	} else if Path::new(obfstr!("/usr/libexec/substrated")).exists() {
		obfstr!("unc0ver").to_string()
	} else {
		obfstr!("unknown").to_string()
	}
}

pub fn client() -> reqwest::Client {
	HTTP_CLIENT.read().deref().clone()
}
