#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")/.."

VERSION=$(node -p "require('./package.json').version")
OUTDIR="build"
ENTRY="src/index.ts"

TARGETS=(
    "bun-darwin-arm64"
    "bun-darwin-x64"
    "bun-linux-arm64"
    "bun-linux-x64"
)

rm -rf "$OUTDIR"
mkdir -p "$OUTDIR"

for TARGET in "${TARGETS[@]}"; do
    # bun-darwin-arm64 -> darwin-arm64
    SUFFIX="${TARGET#bun-}"
    OUTFILE="${OUTDIR}/ccwatch-${SUFFIX}"

    echo "==> Building ${SUFFIX}..."
    bun build --compile --minify --target="$TARGET" "$ENTRY" --outfile "$OUTFILE"
done

echo ""
echo "Builds (v${VERSION}):"
ls -lh "$OUTDIR"/ccwatch-*
