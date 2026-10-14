#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ./build_map.sh /path/to/rokehan_38.2600_140.8833.glb /path/to/INKBOUND
#
# The generated parts stay below GitHub's 25 MiB browser-upload limit.

INPUT_GLB="${1:-rokehan_38.2600_140.8833.glb}"
DEST="${2:-.}"
BASE="rokehan_38.2600_140.8833.glb.gz"
CHUNK=$((19 * 1024 * 1024))

if [[ ! -f "$INPUT_GLB" ]]; then
  echo "GLB not found: $INPUT_GLB" >&2
  exit 1
fi

mkdir -p "$DEST"
gzip -c "$INPUT_GLB" > "$DEST/$BASE"
split -b "$CHUNK" -d -a 1 "$DEST/$BASE" "$DEST/$BASE.part"

mv "$DEST/$BASE.part0" "$DEST/$BASE.part1"
mv "$DEST/$BASE.part1" "$DEST/$BASE.part2"
rm "$DEST/$BASE"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "$SCRIPT_DIR/index2.html" && "$DEST" != "$SCRIPT_DIR" ]]; then
  cp "$SCRIPT_DIR/index2.html" "$DEST/index2.html"
fi

echo "Created compressed map parts in: $DEST"
ls -lh "$DEST/$BASE.part1" "$DEST/$BASE.part2"
echo "Upload index2.html and both .part files to the same GitHub Pages folder."
