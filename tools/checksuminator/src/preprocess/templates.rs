use trim_in_place::TrimInPlace;

pub fn all(value: String) -> Vec<u8> {
	file(&value)
		.or_else(|| b3sum(&value))
		.or_else(|| env(&value))
		.or_else(|| if_else(&value))
		.unwrap_or_else(|| string(value))
}

pub fn file(value: &str) -> Option<Vec<u8>> {
	value
		.strip_prefix("[")
		.and_then(|s| s.strip_suffix("]"))
		.map(|filename| {
			let filename = filename.trim();
			std::fs::read(filename)
				.unwrap_or_else(|err| panic!("failed to read file '{}':\n{:?}", filename, err))
		})
}

pub fn b3sum(value: &str) -> Option<Vec<u8>> {
	value.strip_prefix("b3sum:").map(|filename| {
		let filename = filename.trim();
		let contents = std::fs::read(filename)
			.unwrap_or_else(|err| panic!("failed to read file '{}':\n{:?}", filename, err));
		Into::<[u8; 32]>::into(blake3::hash(&contents)).to_vec()
	})
}

pub fn env(value: &str) -> Option<Vec<u8>> {
	value
		.strip_prefix("env:")
		.map(|var| string(std::env::var(var.trim()).unwrap_or_default()))
}

pub fn if_else(value: &str) -> Option<Vec<u8>> {
	value.strip_prefix("if:").and_then(|var| {
		let mut stuff = var.splitn(3, ':');
		let (condition, if_true, if_false) = (stuff.next()?, stuff.next()?, stuff.next()?);
		let condition_var = std::env::var(condition.trim())
			.map(|value| {
				let value = value.trim();
				!(value.is_empty() || value == "0" || value.to_lowercase() == "false")
			})
			.unwrap_or(false);
		Some(string(if condition_var {
			if_true.to_string()
		} else {
			if_false.to_string()
		}))
	})
}

pub fn string(mut value: String) -> Vec<u8> {
	value.trim_in_place();
	let mut value = value.into_bytes();
	value.push(0);
	value
}
