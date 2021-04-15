#!/bin/bash
VERSION="1.0.0"
RUSTC=/opt/rust-hikari/bin/rustc \
	RUSTFLAGS="-C llvm-args=--enable-bcfobf -C llvm-args=--enable-splitobf -C llvm-args=--enable-cffobf -C llvm-args=--enable-strcry" \
	/opt/rust-hikari/bin/cargo build --release --target aarch64-apple-ios || exit 1
strip target/aarch64-apple-ios/release/venusflytrap || exit 1
ldid2 -Svenusflytrap/general.xml target/aarch64-apple-ios/release/venusflytrap || exit 1
rm -rf .theos/_ || true
gmake stage FINALPACKAGE=1 || exit 1
mkdir -p .theos/_/DEBIAN || exit 1
cp -f control .theos/_/DEBIAN/control || exit 1
mkdir -p .theos/_/usr/lib/aspenuwu || exit 1
cp -f target/aarch64-apple-ios/release/venusflytrap .theos/_/usr/lib/aspenuwu/me.aspenuwu.zinnia.bs || exit 1
dpkg-deb -Zgzip -b .theos/_ target/me.aspenuwu.zinnia_"$VERSION"_iphoneos-arm64.deb || exit 1
