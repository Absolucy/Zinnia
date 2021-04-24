#!/bin/bash
source scripts/env.sh
cargo build --target aarch64-apple-ios --package activator --features trial || exit 1
ldid2 -Stools/activator/general.xml target/aarch64-apple-ios/debug/activator || exit 1
rm -rf .theos/_ || true
gmake stage DEBUG=1 DRM=1 TRIAL=1 || exit 1
target/x86_64-apple-darwin/release/checksuminator --init --string strings.txt .theos/_/Library/MobileSubstrate/DynamicLibraries/Zinnia.dylib || exit 1
ldid2 -S .theos/_/Library/MobileSubstrate/DynamicLibraries/Zinnia.dylib || exit 1
target/x86_64-apple-darwin/release/checksuminator --string strings.txt .theos/_/Library/PreferenceBundles/ZinniaPrefs.bundle/ZinniaPrefs || exit 1
ldid2 -S .theos/_/Library/PreferenceBundles/ZinniaPrefs.bundle/ZinniaPrefs || exit 1
mkdir -p .theos/_/DEBIAN || exit 1
cp -f deb/control.trial .theos/_/DEBIAN/control || exit 1
cp -f deb/prerm .theos/_/DEBIAN/prerm || exit 1
chmod +x .theos/_/DEBIAN/prerm || exit 1
cp -f deb/postinst .theos/_/DEBIAN/postinst || exit 1
chmod +x .theos/_/DEBIAN/postinst || exit 1
mkdir -p .theos/_/usr/lib/aspenuwu || exit 1
cp -f target/aarch64-apple-ios/debug/activator .theos/_/usr/lib/aspenuwu/me.aspenuwu.zinnia.bs || exit 1
dpkg-deb -Zxz -b .theos/_ target/me.aspenuwu.zinnia.trial_"$VERSION"+debug_iphoneos-arm64.deb || exit 1
