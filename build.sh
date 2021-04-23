#!/bin/bash
VERSION="1.0.0"
RUSTC=/opt/rust-hikari/bin/rustc \
	RUSTFLAGS="-C llvm-args=--enable-bcfobf -C llvm-args=--enable-splitobf -C llvm-args=--enable-cffobf -C llvm-args=--enable-strcry" \
	/opt/rust-hikari/bin/cargo build --release --target aarch64-apple-ios --package activator || exit 1
strip -x -S -T target/aarch64-apple-ios/release/activator || exit 1
ldid2 -Stools/activator/general.xml target/aarch64-apple-ios/release/activator || exit 1
rm -rf .theos/_ || true
gmake stage FINALPACKAGE=1 DRM=1 SHOULD_STRIP=0 || exit 1
target/x86_64-apple-darwin/release/checksuminator .theos/_/Library/MobileSubstrate/DynamicLibraries/Zinnia.dylib || exit 1
strip -x -S -T .theos/_/Library/MobileSubstrate/DynamicLibraries/Zinnia.dylib || exit 1
ldid2 -S .theos/_/Library/MobileSubstrate/DynamicLibraries/Zinnia.dylib || exit 1
strip -x -S -T .theos/_/Library/PreferenceBundles/ZinniaPrefs.bundle/ZinniaPrefs || exit 1
ldid2 -S .theos/_/Library/PreferenceBundles/ZinniaPrefs.bundle/ZinniaPrefs || exit 1
mkdir -p .theos/_/DEBIAN || exit 1
cp -f control .theos/_/DEBIAN/control || exit 1
cp -f prerm .theos/_/DEBIAN/prerm || exit 1
chmod +x .theos/_/DEBIAN/prerm || exit 1
cp -f postinst .theos/_/DEBIAN/postinst || exit 1
chmod +x .theos/_/DEBIAN/postinst || exit 1
mkdir -p .theos/_/usr/lib/aspenuwu || exit 1
cp -f target/aarch64-apple-ios/release/activator .theos/_/usr/lib/aspenuwu/me.aspenuwu.zinnia.bs || exit 1
dpkg-deb -Zxz -b .theos/_ target/me.aspenuwu.zinnia_"$VERSION"_iphoneos-arm64.deb || exit 1
