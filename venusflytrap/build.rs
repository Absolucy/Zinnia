fn main() {
	cc::Build::new()
		.file("udid/udid.c")
		.compiler("/opt/apple-llvm-hikari/bin/clang")
		.include("udid")
		.static_flag(true)
		.shared_flag(false)
		.opt_level_str("s")
		.flag("-mllvm")
		.flag("--enable-bcfobf")
		.flag("-mllvm")
		.flag("--enable-splitobf")
		.flag("-mllvm")
		.flag("--enable-strcry")
		.flag("-mllvm")
		.flag("--enable-funcwra")
		.flag("-mllvm")
		.flag("--enable-subobf")
		.compile("udid");
}
