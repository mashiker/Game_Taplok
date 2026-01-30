#!/usr/bin/env python3
"""Generate Indonesian TTS (kid-friendly) with Piper.

Prereqs (already downloaded in this repo by Lyn):
- Piper binary: tools/tts/piper/piper/piper
- Model:
  tools/tts/models/id_ID/news_tts/medium/id_ID-news_tts-medium.onnx
  tools/tts/models/id_ID/news_tts/medium/id_ID-news_tts-medium.onnx.json

Usage:
  python3 tools/tts_generate_id_piper.py --out assets/sounds/words/id/transport \
    "Mobil" "Cari Mobil" "Tap Mobil" "Pintar!" "Coba lagi"

Outputs WAV files (Godot-friendly). You can later convert to OGG if desired.
"""

from __future__ import annotations

import argparse
import pathlib
import re
import subprocess

ROOT = pathlib.Path(__file__).resolve().parents[0]
PIPER_BIN = ROOT / "tts" / "piper" / "piper" / "piper"
MODEL = ROOT / "tts" / "models" / "id_ID" / "news_tts" / "medium" / "id_ID-news_tts-medium.onnx"


def slugify(s: str) -> str:
    s = s.strip().lower()
    s = s.replace("&", " dan ")
    s = re.sub(r"[^a-z0-9]+", "_", s)
    s = re.sub(r"_+", "_", s).strip("_")
    return s or "line"


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", required=True, help="Output folder")
    ap.add_argument("--rate", type=int, default=22050, help="Sample rate")
    ap.add_argument("lines", nargs="+", help="Text lines")
    args = ap.parse_args()

    out_dir = pathlib.Path(args.out)
    out_dir.mkdir(parents=True, exist_ok=True)

    if not PIPER_BIN.exists():
        raise SystemExit(f"Missing piper binary: {PIPER_BIN}")
    if not MODEL.exists():
        raise SystemExit(f"Missing model: {MODEL}")

    for line in args.lines:
        out_path = out_dir / f"{slugify(line)}.wav"
        # Piper reads text from stdin
        cmd = [str(PIPER_BIN), "--model", str(MODEL), "--output_file", str(out_path)]
        subprocess.run(cmd, input=(line + "\n").encode("utf-8"), check=True)
        print(f"Wrote: {out_path}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
