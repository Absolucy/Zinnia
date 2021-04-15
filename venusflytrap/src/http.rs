use crate::{handle_err, pin::tls_config, validate::model, TWEAK_NAME};
use obfstr::{obfstr, xref};
use static_init::dynamic;
use std::{ops::Deref, time::Duration};

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
			[
				model().as_str(),
				obfstr!(TWEAK_NAME),
				obfstr!(env!("CARGO_PKG_VERSION"))
			]
			.join(obfstr!(" "))
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

pub fn client() -> reqwest::Client {
	HTTP_CLIENT.read().deref().clone()
}
