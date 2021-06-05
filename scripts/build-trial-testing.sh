#!/bin/bash
set -e
# Setup environment
source scripts/env.sh
# Compile Brimstone
env TRIAL=1 brimstone-processor \
	compile \
	--state "$TARGET_DIR/.brimstone-state.json" \
	--code "$TARGET_DIR" \
	--config config.toml \
	--string res/strings/main.plist \
	--string res/strings/drm.production.plist \
	--output "$TARGET_DIR/libbrimstone.a"

# Copy files to tmpdir
cp -R Makefile "$TARGET_DIR"
cp -R Package.swift "$TARGET_DIR"
cp -R Sources "$TARGET_DIR"
cp -R Zinnia.plist "$TARGET_DIR"
cp -R zinniaprefs "$TARGET_DIR"
# Run preprocessor on source
brimstone-processor \
	preprocess \
	--state "$TARGET_DIR/.brimstone-state.json" \
	--code "$TARGET_DIR"
# Compile our temporary directory
cd "$TARGET_DIR"
gmake stage DEBUG=1 DRM=1 TRIAL=1
cd "$INITIAL_DIR"
# Run the checksuminator; then strip and re-sign
brimstone-processor \
	process \
	--state "$TARGET_DIR/.brimstone-state.json" \
	--code "$TARGET_DIR" \
	"$TARGET_DIR/.theos/_/Library/MobileSubstrate/DynamicLibraries/Zinnia.dylib"
ldid2 -S "$TARGET_DIR/.theos/_/Library/MobileSubstrate/DynamicLibraries/Zinnia.dylib"
# Run the checksuminator on the prefs bundle; then strip and re-sign
brimstone-processor \
	process \
	--state "$TARGET_DIR/.brimstone-state.json"  \
	--code "$TARGET_DIR" \
	"$TARGET_DIR/.theos/_/Library/PreferenceBundles/ZinniaPrefs.bundle/ZinniaPrefs"
ldid2 -S "$TARGET_DIR/.theos/_/Library/PreferenceBundles/ZinniaPrefs.bundle/ZinniaPrefs"
# Pack the deb
mkdir -p "$TARGET_DIR/.theos/_/DEBIAN"
cp -f deb/control.trial "$TARGET_DIR/.theos/_/DEBIAN/control"
dpkg-deb -Zxz -b "$TARGET_DIR/.theos/_" target/me.aspenuwu.zinnia.trial_"$VERSION"+debug_iphoneos-arm64.deb
