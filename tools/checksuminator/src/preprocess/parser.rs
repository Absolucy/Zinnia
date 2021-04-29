use plist::Value;
use std::collections::BTreeMap;

pub fn parse(map: &mut BTreeMap<String, Value>, stack: Vec<String>, value: Value) {
	match &value {
		Value::Array(_) => {
			map.insert(stack.join("->"), value);
		}
		Value::Dictionary(dict) => {
			for (key, val) in dict {
				let mut new_stack = stack.clone();
				new_stack.push(key.clone());
				parse(map, new_stack, val.clone());
			}
		}
		Value::Boolean(_) => {
			map.insert(stack.join("->"), value);
		}
		Value::Data(_) => {
			map.insert(stack.join("->"), value);
		}
		Value::Integer(_) => {
			map.insert(stack.join("->"), value);
		}
		Value::String(_) => {
			map.insert(stack.join("->"), value);
		}
		_ => unimplemented!(),
	}
}
