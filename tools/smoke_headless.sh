#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

GODOT_BIN="./godot_console.exe"
if [ ! -x "$GODOT_BIN" ]; then
  GODOT_BIN="$(command -v godot || true)"
fi
if [ -z "$GODOT_BIN" ]; then
  echo "No Godot binary found (expected ./godot_console.exe or godot in PATH)" >&2
  exit 1
fi

out=$("$GODOT_BIN" --headless --import --path . 2>&1 || true)
echo "$out"
if echo "$out" | grep -q "SCRIPT ERROR"; then
  echo "SMOKE_FAIL (import)" >&2
  exit 2
fi

out=$("$GODOT_BIN" --headless --quit --path . 2>&1 || true)
echo "$out"
if echo "$out" | grep -q "SCRIPT ERROR"; then
  echo "SMOKE_FAIL (run)" >&2
  exit 3
fi

echo "SMOKE_OK"
