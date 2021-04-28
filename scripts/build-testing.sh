#!/bin/bash
source scripts/env.sh
rm -rf .theos/_ || true
gmake stage DEBUG=1 DRM=1 || exit 1
target/x86_64-apple-darwin/release/checksuminator --init --string res/strings.txt .theos/_/Library/MobileSubstrate/DynamicLibraries/Zinnia.dylib || exit 1
ldid2 -S .theos/_/Library/MobileSubstrate/DynamicLibraries/Zinnia.dylib || exit 1
target/x86_64-apple-darwin/release/checksuminator --string res/strings.txt .theos/_/Library/PreferenceBundles/ZinniaPrefs.bundle/ZinniaPrefs || exit 1
ldid2 -S .theos/_/Library/PreferenceBundles/ZinniaPrefs.bundle/ZinniaPrefs || exit 1
mkdir -p .theos/_/DEBIAN || exit 1
cp -f deb/control.full .theos/_/DEBIAN/control || exit 1
dpkg-deb -Zxz -b .theos/_ target/me.aspenuwu.zinnia_"$VERSION"+debug_iphoneos-arm64.deb || exit 1
