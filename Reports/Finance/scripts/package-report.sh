#!/bin/zsh

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SOURCE_DIR="$ROOT_DIR/Financial Report"
EXPORT_DIR="$ROOT_DIR/Exports/Server Packages"
OUTPUT_ZIP="$EXPORT_DIR/Financial Report - ready.zip"

mkdir -p "$EXPORT_DIR"
rm -f "$OUTPUT_ZIP"
ditto -c -k --sequesterRsrc --keepParent "$SOURCE_DIR" "$OUTPUT_ZIP"
ls -lh "$OUTPUT_ZIP"
