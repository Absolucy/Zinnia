use crate::{
	models::{DecryptionKey, StringEntry},
	preprocess,
};
use chacha20::{
	cipher::{NewCipher, StreamCipher},
	ChaCha20, Key, Nonce,
};
use goblin::mach::MachO;
use plist::Value;
use std::{collections::BTreeMap, path::PathBuf};

pub fn handle(macho: &MachO, offset: usize, binary: &mut Vec<u8>, string_table_paths: &[PathBuf]) {
	let strings = {
		let mut processed_string_table = BTreeMap::<String, Value>::new();
		for path in string_table_paths {
			info!("loading string table entries from {}", path.display());
			let string_table = Value::from_file(path).expect("failed to read string table");
			preprocess::parser::parse(&mut processed_string_table, vec![], string_table);
		}
		let processed_string_table = preprocess::process_string_table(processed_string_table);
		let mut string_table_keys = processed_string_table
			.keys()
			.cloned()
			.collect::<Vec<String>>();
		string_table_keys.sort();
		string_table_keys
			.into_iter()
			.map(|key| processed_string_table.get(&key).unwrap().clone())
			.collect::<Vec<Vec<u8>>>()
	};

	let total_len = strings.iter().fold(0, |x, s| x + s.len() + 1);
	let mut table = Vec::<StringEntry>::with_capacity(strings.len());
	let mut raw_strings = Vec::<u8>::with_capacity(total_len);
	let mut section_keys = [DecryptionKey::default(), DecryptionKey::default()];
	assert!(total_len <= 32768);
	assert!(strings.len() <= 100);

	strings.into_iter().for_each(|data| {
		let (entry, encrypted) = StringEntry::new(data);
		table.push(entry);
		raw_strings.extend_from_slice(&encrypted);
	});

	let mut raw_table = bytemuck::cast_slice::<_, u8>(&table).to_vec();

	assert!(raw_table.len() <= 100 * std::mem::size_of::<StringEntry>());
	assert!(raw_strings.len() <= 32768);
	raw_table.resize_with(100 * std::mem::size_of::<StringEntry>(), rand::random);
	raw_strings.resize_with(32768, rand::random);

	ChaCha20::new(
		&Key::from_slice(bytemuck::cast_slice(&section_keys[0].key)),
		&Nonce::from_slice(bytemuck::cast_slice(&section_keys[0].nonce)),
	)
	.apply_keystream(&mut raw_table);
	ChaCha20::new(
		&Key::from_slice(bytemuck::cast_slice(&section_keys[1].key)),
		&Nonce::from_slice(bytemuck::cast_slice(&section_keys[1].nonce)),
	)
	.apply_keystream(&mut raw_strings);

	info!("encrypted string table of contents");
	info!(
		"key: {}",
		hex::encode(bytemuck::cast_slice(&section_keys[0].key))
	);
	info!(
		"nonce: {}",
		hex::encode(bytemuck::cast_slice(&section_keys[0].nonce))
	);
	info!("encrypted string table entries");
	info!(
		"key: {}",
		hex::encode(bytemuck::cast_slice(&section_keys[1].key))
	);
	info!(
		"nonce: {}",
		hex::encode(bytemuck::cast_slice(&section_keys[1].nonce))
	);

	section_keys[0].shuffle();
	section_keys[1].shuffle();
	let section_keys: &[u8] = bytemuck::cast_slice(&section_keys);

	let table_range = macho
		.segments
		.into_iter()
		.find(|x| x.name().unwrap() == "__DATA")
		.expect("failed to find data segment")
		.sections()
		.expect("failed to get sections")
		.into_iter()
		.find(|(section, _)| section.name().unwrap() == "__godzillatoc")
		.map(|(section, _)| {
			offset + section.offset as usize
				..offset + section.offset as usize + section.size as usize
		})
		.expect("failed to find string table of contents section");
	let strings_range = macho
		.segments
		.into_iter()
		.find(|x| x.name().unwrap() == "__DATA")
		.expect("failed to find data segment")
		.sections()
		.expect("failed to get sections")
		.into_iter()
		.find(|(section, _)| section.name().unwrap() == "__godzillastrtb")
		.map(|(section, _)| {
			offset + section.offset as usize
				..offset + section.offset as usize + section.size as usize
		})
		.expect("failed to find encrypted string table section");
	let keys_range = macho
		.segments
		.into_iter()
		.find(|x| x.name().unwrap() == "__TEXT")
		.expect("failed to find text segment")
		.sections()
		.expect("failed to get sections")
		.into_iter()
		.find(|(section, _)| section.name().unwrap() == "__godzilladk")
		.map(|(section, _)| {
			offset + section.offset as usize
				..offset + section.offset as usize + section.size as usize
		})
		.expect("failed to find string table keys section");

	binary.splice(table_range, raw_table.iter().copied());
	binary.splice(strings_range, raw_strings.iter().copied());
	binary.splice(keys_range, section_keys.iter().copied());
}
