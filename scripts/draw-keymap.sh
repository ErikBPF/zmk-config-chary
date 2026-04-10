#!/usr/bin/env bash
# Draw the Charybdis keymap as an SVG locally.
# Requires: pip install keymap-drawer (or pipx install keymap-drawer)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

KEYMAP="$ROOT_DIR/config/charybdis.keymap"
PARSED="$ROOT_DIR/docs/keymap/charybdis_parsed.yaml"
OUTPUT="$ROOT_DIR/docs/keymap/charybdis.svg"

if ! command -v keymap &>/dev/null; then
    echo "keymap-drawer not found. Install with: pip install keymap-drawer"
    exit 1
fi

echo "Parsing $KEYMAP ..."
keymap parse -z "$KEYMAP" -c 12 > "$PARSED" 2>/dev/null

# Replace zmk_keyboard with ortho_layout (charybdis isn't in keymap-drawer's DB)
sed -i 's/zmk_keyboard: charybdis/ortho_layout: {split: true, rows: 3, columns: 6, thumbs: 3}/' "$PARSED"

echo "Drawing SVG ..."
keymap draw "$PARSED" > "$OUTPUT"

echo "Done → $OUTPUT"
