use chrono::{DateTime, Duration, Utc};
use ed25519_dalek::{Keypair, PublicKey, Signature, Signer};
use serde::{Deserialize, Serialize};
use uuid::Uuid;

#[inline(always)]
fn pubkey() -> PublicKey {
	let bytes = [
		81, 111, 82, 186, 165, 142, 31, 71, 247, 233, 205, 194, 115, 207, 35, 143, 231, 244, 141,
		16, 103, 196, 210, 56, 242, 208, 204, 196, 131, 210, 79, 133,
	]
	.iter()
	.map(|x| *x ^ 42)
	.collect::<Vec<_>>();
	PublicKey::from_bytes(&bytes).expect("failed to get public key")
}

#[derive(Deserialize, Serialize, Debug)]
pub struct AuthorizationRequest {
	#[serde(rename = "u")]
	pub udid: String,
	#[serde(rename = "m")]
	pub model: String,
	#[serde(rename = "a")]
	pub at: DateTime<Utc>,
	#[serde(rename = "t")]
	pub tweak: String,
	#[serde(rename = "v")]
	pub version: String,
}

impl AuthorizationRequest {
	#[inline(always)]
	pub fn new(udid: &str, model: &str, tweak: &str, version: &str) -> Self {
		let at = Utc::now();
		AuthorizationRequest {
			at,
			udid: udid.to_string(),
			model: model.to_string(),
			tweak: tweak.to_string(),
			version: version.to_string(),
		}
	}

	pub fn sign_request(&self, kp: &Keypair) -> AuthorizationTicket {
		let uuid = Uuid::new_v4();
		let issued = Utc::now();
		let until = issued + Duration::days(30);
		// Generate our signature
		let mut bytes = Vec::<u8>::with_capacity(
			std::mem::size_of::<AuthorizationTicket>() - std::mem::size_of::<Signature>(),
		);
		bytes.extend_from_slice(uuid.as_bytes());
		bytes.extend_from_slice(self.udid.as_bytes());
		bytes.extend_from_slice(self.model.as_bytes());
		bytes.extend_from_slice(self.tweak.to_uppercase().as_bytes());
		bytes.extend_from_slice(&issued.timestamp().to_le_bytes());
		bytes.extend_from_slice(&until.timestamp().to_le_bytes());
		bytes.iter_mut().for_each(|byte| *byte ^= 42);
		let signature = kp.sign(&bytes);
		AuthorizationTicket {
			uuid,
			issued,
			until,
			signature,
		}
	}
}

#[derive(Debug, PartialEq, Eq)]
pub enum AuthStatus {
	Valid,
	TooSoon,
	Expired,
	Invalid,
}

#[derive(Deserialize, Serialize, Clone, Debug)]
pub struct AuthorizationTicket {
	#[serde(rename = "x")]
	pub uuid: Uuid,
	// udid + model + tweak is signed in here
	#[serde(rename = "i")]
	pub issued: DateTime<Utc>,
	#[serde(rename = "e")]
	pub until: DateTime<Utc>,
	#[serde(rename = "s")]
	pub signature: Signature,
}

impl AuthorizationTicket {
	#[inline(always)]
	pub fn validate(&self, tweak: &str, udid: &str, model: &str) -> AuthStatus {
		let mut bytes = Vec::<u8>::with_capacity(
			std::mem::size_of::<AuthorizationTicket>() - std::mem::size_of::<Signature>(),
		);
		bytes.extend_from_slice(self.uuid.as_bytes());
		bytes.extend_from_slice(udid.as_bytes());
		bytes.extend_from_slice(model.as_bytes());
		bytes.extend_from_slice(tweak.to_uppercase().as_bytes());
		bytes.extend_from_slice(&self.issued.timestamp().to_le_bytes());
		bytes.extend_from_slice(&self.until.timestamp().to_le_bytes());
		let now = Utc::now();
		bytes.iter_mut().for_each(|byte| *byte ^= 42);
		if now > self.until {
			AuthStatus::Expired
		} else if now < self.issued {
			AuthStatus::TooSoon
		} else if pubkey().verify_strict(&bytes, &self.signature).is_ok() {
			AuthStatus::Valid
		} else {
			AuthStatus::Invalid
		}
	}

	pub fn expires_in(&self) -> i64 {
		(self.until - Utc::now()).num_days()
	}
}
