#!/bin/bash
set -euo pipefail

APP_NAME="CCWatchBar"
BUNDLE_ID="eu.tomaskral.ccwatch"
APP_DIR="${APP_NAME}.app"
CONTENTS_DIR="${APP_DIR}/Contents"
MACOS_DIR="${CONTENTS_DIR}/MacOS"
RESOURCES_DIR="${CONTENTS_DIR}/Resources"

# Build release binary
swift build -c release

# Find the built binary
BINARY=".build/release/${APP_NAME}"
if [ ! -f "$BINARY" ]; then
    echo "Error: binary not found at $BINARY"
    exit 1
fi

# Create .app bundle structure
rm -rf "$APP_DIR"
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR"

# Copy binary
cp "$BINARY" "$MACOS_DIR/${APP_NAME}"

# Copy Info.plist
cp "Sources/${APP_NAME}/Info.plist" "$CONTENTS_DIR/Info.plist"

echo "Built ${APP_DIR}"
