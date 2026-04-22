#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")/.."

APP_NAME="CCWatchBar"
BUNDLE_ID="eu.tomaskral.ccwatch"
TEAM_ID="N3ZB9269M7"
SIGNING_IDENTITY="Developer ID Application: Tomas Kral (${TEAM_ID})"
APP_DIR="${APP_NAME}.app"
CONTENTS_DIR="${APP_DIR}/Contents"
MACOS_DIR="${CONTENTS_DIR}/MacOS"
RESOURCES_DIR="${CONTENTS_DIR}/Resources"

# --- Build ---
echo "==> Building release binary..."
swift build -c release

BINARY=".build/release/${APP_NAME}"
if [ ! -f "$BINARY" ]; then
    echo "Error: binary not found at $BINARY"
    exit 1
fi

# --- Package .app bundle ---
echo "==> Packaging ${APP_DIR}..."
rm -rf "$APP_DIR"
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR"
cp "$BINARY" "$MACOS_DIR/${APP_NAME}"
cp "Sources/${APP_NAME}/Info.plist" "$CONTENTS_DIR/Info.plist"

# --- Sign ---
echo "==> Signing with: ${SIGNING_IDENTITY}..."
codesign --force --deep --options runtime \
    --sign "$SIGNING_IDENTITY" \
    --entitlements CCWatchBar.entitlements \
    --identifier "$BUNDLE_ID" \
    "$APP_DIR"

codesign --verify --deep --strict "$APP_DIR"
echo "    Signature verified."

# --- Notarize ---
echo "==> Notarizing (this may take a few minutes)..."
ditto -c -k --keepParent "$APP_DIR" "${APP_NAME}.zip"

xcrun notarytool submit "${APP_NAME}.zip" \
    --keychain-profile "ccwatch-notary" \
    --wait

xcrun stapler staple "$APP_DIR"
echo "    Notarization stapled."

# --- Final zip ---
rm -f "${APP_NAME}.zip"
ditto -c -k --keepParent "$APP_DIR" "${APP_NAME}.zip"

echo ""
echo "Done! Outputs:"
echo "  ${APP_DIR}        (signed + notarized app)"
echo "  ${APP_NAME}.zip   (ready to distribute)"
