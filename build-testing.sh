#!/bin/bash
VERSION="1.0.0"
cargo build --target aarch64-apple-ios || exit 1
ldid2 -Svenusflytrap/general.xml target/aarch64-apple-ios/debug/venusflytrap || exit 1
rm -rf .theos/_ || true
gmake stage DEBUG=1 DRM=1 || exit 1
mkdir -p .theos/_/DEBIAN || exit 1
cp -f control .theos/_/DEBIAN/control || exit 1
cp -f prerm .theos/_/DEBIAN/prerm || exit 1
chmod +x .theos/_/DEBIAN/prerm || exit 1
cp -f postinst .theos/_/DEBIAN/postinst || exit 1
chmod +x .theos/_/DEBIAN/postinst || exit 1
mkdir -p .theos/_/usr/lib/aspenuwu || exit 1
cp -f target/aarch64-apple-ios/debug/venusflytrap .theos/_/usr/lib/aspenuwu/me.aspenuwu.zinnia.bs || exit 1
dpkg-deb -Zgzip -b .theos/_ target/me.aspenuwu.zinnia_"$VERSION"+debug_iphoneos-arm64.deb || exit 1
