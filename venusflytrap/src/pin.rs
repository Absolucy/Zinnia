use super::handle_err;
use chrono::{TimeZone, Utc};
use include_crypt::{include_crypt, EncryptedFile};
use obfstr::{obfstmt, obfstr, xref};
use rustls::{ciphersuite::TLS13_CHACHA20_POLY1305_SHA256, ClientConfig, ProtocolVersion};
use rustls_pin::PinnedServerCertVerifier;
use std::{
	io::{BufReader, Cursor},
	sync::Arc,
};

static CLOUDFLARE_PEM: EncryptedFile = include_crypt!("cloudflare.pem");

pub fn tls_config() -> ClientConfig {
	let mut tls = ClientConfig::with_ciphersuites(&[xref!(&TLS13_CHACHA20_POLY1305_SHA256)]);
	obfstmt! {
		tls.versions = vec![ProtocolVersion::TLSv1_3];
		tls.set_protocols(&[obfstr!("h2").into(), obfstr!("http/1.1").into()]);
		tls.root_store
			.add_server_trust_anchors(xref!(&webpki_roots::TLS_SERVER_ROOTS));
	};

	debug_assert!(Utc::now().date() < Utc.ymd(2021, 8, 8));
	if Utc::now().date() < Utc.ymd(2021, 8, 8) {
		let mut pem = BufReader::new(Cursor::new(xref!(&CLOUDFLARE_PEM).decrypt()));
		let pinned_cert = handle_err!(rustls::internal::pemfile::certs(&mut pem), 99);
		let verifier = Arc::new(PinnedServerCertVerifier::new(pinned_cert));
		tls.dangerous().set_certificate_verifier(verifier);
	}

	tls
}
