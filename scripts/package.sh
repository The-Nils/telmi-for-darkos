#!/bin/bash
# Builds dist/telmi-for-darkos-<version>.zip : the content to unzip at the root of the card's roms partition.
set -euo pipefail
cd "$(dirname "$0")/.."
VERSION="${1:-dev}"
OUT="dist/telmi-for-darkos-${VERSION}.zip"
mkdir -p dist
rm -f "$OUT"
(cd sdcard && zip -qr "../$OUT" . -x '*.DS_Store' -x '*/.gitkeep' -x '.gitkeep')
echo "Built $OUT ($(du -h "$OUT" | cut -f1))"
