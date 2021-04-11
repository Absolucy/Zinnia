use obfstr::obfstr;
use std::time::Duration;
use venusflytrap::{AuthorizationRequest, AuthorizationTicket};

const DRM_URL: &str = "https://aiwass.aspenuwu.me/authorize";

#[tokio::main]
async fn main() {
	let request =
		AuthorizationRequest::new(udid, model, obfstr!(env!("CARGO_PKG_VERSION")).to_string());
	let response = match reqwest::Client::new()
		.post(obfstr!(DRM_URL))
		.timeout(Duration::from_secs(15))
		.json(&request)
		.send()
		.await
	{
		Ok(r) => r,
		_ => return,
	};
	let ticket: AuthorizationTicket = match response.json().await {
		Ok(s) => s,
		_ => return,
	};
	let json = serde_json::to_string(&ticket).unwrap_or_else(|_| unreachable!());
}
