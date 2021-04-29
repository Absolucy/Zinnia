#!/bin/bash
# Setup environment
source scripts/env.sh
# Copy files to tmpdir
cp -R Makefile "$TARGET_DIR" || exit 1
cp -R Package.swift "$TARGET_DIR" || exit 1
cp -R Sources "$TARGET_DIR" || exit 1
cp -R Zinnia.plist "$TARGET_DIR" || exit 1
cp -R zinniaprefs "$TARGET_DIR" || exit 1
# Run preprocessor on source
fd -t f -e swift . -X target/release/checksuminator source --string-table res/strings.plist {} || exit 1
# Compile our temporary directory
cd "$TARGET_DIR"
gmake stage DEBUG=1 DRM=1 || exit 1
cd "$INITIAL_DIR"
# Run the checksuminator; then strip and re-sign
target/release/checksuminator binary --string-table res/strings.plist --init "$TARGET_DIR/.theos/_/Library/MobileSubstrate/DynamicLibraries/Zinnia.dylib" || exit 1
strip -x -S -T "$TARGET_DIR/.theos/_/Library/MobileSubstrate/DynamicLibraries/Zinnia.dylib" || exit 1
ldid2 -S "$TARGET_DIR/.theos/_/Library/MobileSubstrate/DynamicLibraries/Zinnia.dylib" || exit 1
# Run the checksuminator on the prefs bundle; then strip and re-sign
target/release/checksuminator binary --string-table res/strings.plist "$TARGET_DIR/.theos/_/Library/PreferenceBundles/ZinniaPrefs.bundle/ZinniaPrefs" || exit 1
strip -x -S -T "$TARGET_DIR/.theos/_/Library/PreferenceBundles/ZinniaPrefs.bundle/ZinniaPrefs" || exit 1
ldid2 -S "$TARGET_DIR/.theos/_/Library/PreferenceBundles/ZinniaPrefs.bundle/ZinniaPrefs" || exit 1
# Pack the deb
mkdir -p "$TARGET_DIR/.theos/_/DEBIAN" || exit 1
cp -f deb/control.full "$TARGET_DIR/.theos/_/DEBIAN/control" || exit 1
dpkg-deb -Zxz -b "$TARGET_DIR/.theos/_" target/me.aspenuwu.zinnia_"$VERSION"+debug_iphoneos-arm64.deb || exit 1
