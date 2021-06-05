#!/bin/bash
VERSION="1.1.1"
TARGET_DIR=$(mktemp -d)
INITIAL_DIR="$PWD"

export VERSION
export TARGET_DIR
export INITIAL_DIR

cleanup() {
	echo "[::] Cleaning up $TARGET_DIR"
	[ -d "$TARGET_DIR" ] && rm -rf "$TARGET_DIR"
	cd "$INITIAL_DIR"
	unset VERSION
	unset TARGET_DIR
	unset INITIAL_DIR
}

trap cleanup EXIT
