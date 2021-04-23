/*
	Copyright (c) aspen 2021
	All rights reserved.
*/

use core_foundation::{
	base::TCFType,
	string::{CFString, CFStringRef},
};
use libloading::{Library, Symbol};
use obfstr::{obfstr, xref};
use sha1::Sha1;
use static_init::dynamic;

type MgCopyAnswer = extern "C" fn(name: CFStringRef) -> CFStringRef;

#[dynamic]
static LIBMOBILEGESTALT: Library =
	unsafe { Library::new(obfstr!("libMobileGestalt.dylib")).unwrap() };
#[dynamic]
static MGCOPYANSWER: Symbol<'static, MgCopyAnswer> = unsafe {
	xref!(&LIBMOBILEGESTALT)
		.get::<MgCopyAnswer>(obfstr!("MGCopyAnswer").as_bytes())
		.unwrap()
};

extern "C" {
	fn get_ecid(arm64e: bool) -> CFStringRef;
	fn get_chip_id() -> CFStringRef;
	fn get_serial() -> CFStringRef;
}

#[inline(always)]
fn mg_copy_answer(question: &str) -> CFStringRef {
	let cf = CFString::new(question);
	xref!(&MGCOPYANSWER)(cf.as_concrete_TypeRef())
}

#[inline(always)]
fn mg_copy_string(question: &str) -> String {
	unsafe { CFString::wrap_under_get_rule(mg_copy_answer(question)).to_string() }
}

// Actual UDID code
#[inline(always)]
fn get_udid_arm64() -> String {
	let serial = unsafe { CFString::wrap_under_get_rule(get_serial()) }.to_string();
	let ecid = unsafe { CFString::wrap_under_get_rule(get_ecid(false)) }.to_string();
	let wifi_mac = mg_copy_string(obfstr!("WifiAddress"));
	let bt_mac = mg_copy_string(obfstr!("BluetoothAddress"));
	hex::encode(
		Sha1::from([serial, ecid, wifi_mac, bt_mac].join("").as_bytes())
			.digest()
			.bytes(),
	)
	.to_lowercase()
}

#[inline(always)]
fn get_udid_arm64e() -> String {
	let chip_id = unsafe { CFString::wrap_under_get_rule(get_chip_id()) }.to_string();
	let ecid = unsafe { CFString::wrap_under_get_rule(get_ecid(true)) }.to_string();
	[chip_id, ecid].join(obfstr!("-")).to_uppercase()
}

#[inline(always)]
pub fn get_udid() -> String {
	let architecture = mg_copy_string(obfstr!("CPUArchitecture"));
	if architecture == obfstr!("arm64") {
		get_udid_arm64()
	} else if architecture == obfstr!("arm64e") {
		get_udid_arm64e()
	} else {
		unreachable!()
	}
}
