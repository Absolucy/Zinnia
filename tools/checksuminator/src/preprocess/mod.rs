pub(crate) mod parser;
pub(crate) mod templates;

use plist::Value;
use regex::{Captures, Regex};
use std::{
	collections::BTreeMap,
	path::{Path, PathBuf},
};

pub fn process_string_table(table: BTreeMap<String, Value>) -> BTreeMap<String, Vec<u8>> {
	table
		.into_iter()
		.map(|(key, v)| {
			let new_value = match v {
				Value::Array(arr) => {
					let mut string_list = Vec::<String>::with_capacity(arr.len());
					for value in arr {
						if let Value::String(s) = value {
							string_list.push(s);
						}
					}
					let mut string_list_bytes = string_list.join("$").into_bytes();
					string_list_bytes.push(0);
					string_list_bytes
				}
				Value::Boolean(b) => {
					vec![b as u8]
				}
				Value::Data(data) => data,
				Value::Integer(int) => {
					if let Some(int) = int.as_signed() {
						int.to_le_bytes().to_vec()
					} else if let Some(int) = int.as_unsigned() {
						(int.max(i64::MAX as u64) as i64).to_le_bytes().to_vec()
					} else {
						unreachable!()
					}
				}
				Value::String(string) => templates::all(string),
				_ => unimplemented!(),
			};
			(key, new_value)
		})
		.collect()
}

pub fn preprocess(string_table_path: &Path, files: &[PathBuf]) {
	let getx_regex = Regex::new(r#"(getStr|getList|getData)\("(.*?)"\)"#)
		.expect("failed to create preprocessor regex");
	let string_table = Value::from_file(string_table_path).expect("failed to read string table");
	let mut processed_string_table = BTreeMap::<String, Value>::new();
	parser::parse(&mut processed_string_table, vec![], string_table);
	let processed_string_table = process_string_table(processed_string_table);
	let mut string_table_keys = processed_string_table
		.keys()
		.cloned()
		.collect::<Vec<String>>();
	string_table_keys.sort();
	for file in files {
		let full_path = file
			.canonicalize()
			.unwrap()
			.display()
			.to_string()
			.to_lowercase();
		if full_path.contains("home")
			|| full_path.contains("users")
			|| full_path.contains("aspen")
			|| full_path.contains("code")
		{
			panic!("DON'T RUN THIS IN HOME FOLDER!");
		}
		let code = std::fs::read_to_string(file)
			.unwrap_or_else(|err| panic!("failed to read file '{}': {:?}", file.display(), err));
		let code = getx_regex.replace_all(&code, |caps: &Captures| {
			let function = caps[1].trim();
			let capture = caps[2].trim();
			let index = string_table_keys
				.iter()
				.enumerate()
				.find(|(_, key)| key.eq_ignore_ascii_case(capture))
				.unwrap_or_else(|| panic!("failed to find string table entry for '{}'", capture))
				.0;
			format!("{}({})", function, index)
		});
		eprintln!("writing {}", file.display());
		std::fs::write(file, code.as_bytes()).unwrap_or_else(|err| {
			panic!(
				"failed to write back to file '{}': {:?}",
				file.display(),
				err
			)
		});
	}
}
