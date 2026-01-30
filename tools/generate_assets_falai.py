#!/usr/bin/env python3
"""Generate image assets using fal.ai.

Reads tools/fal_ai_asset_manifest.json and calls fal-ai/gpt-image-1.

Usage:
  export FAL_KEY=...
  python3 tools/generate_assets_falai.py

Note: This script assumes the `fal_client` package is installed.
Install:
  python3 -m pip install --user fal-client

Docs (may change): https://fal.ai
"""

import base64
import json
import os
import pathlib
import sys

MANIFEST_PATH = pathlib.Path(__file__).with_name("fal_ai_asset_manifest.json")


def _require_env(name: str) -> str:
    v = os.environ.get(name)
    if not v:
        raise SystemExit(f"Missing env {name}. Export it first.")
    return v


def main() -> int:
    _require_env("FAL_KEY")

    try:
        import fal_client  # type: ignore
    except Exception as e:
        print("fal_client not installed. Run: python3 -m pip install --user fal-client", file=sys.stderr)
        raise

    manifest = json.loads(MANIFEST_PATH.read_text(encoding="utf-8"))
    model = manifest["style"]["model"]

    for asset in manifest["assets"]:
        out_path = pathlib.Path(asset["out"])
        out_path.parent.mkdir(parents=True, exist_ok=True)

        prompt = asset["prompt"]
        negative = asset.get("negative", "")

        # gpt-image style inputs can vary; fal.ai wraps models.
        # We use a conservative payload that commonly works: prompt + image_size.
        # If your fal endpoint expects different fields, adjust here.
        payload = {
            "prompt": prompt,
            "negative_prompt": negative,
        }

        # Size hints for fal-ai/gpt-image-1.5
        # The endpoint validates `image_size` as one of: 1024x1024, 1536x1024, 1024x1536
        t = asset["type"]
        if t == "background":
            payload["image_size"] = "1024x1536"  # portrait
        else:
            payload["image_size"] = "1024x1024"  # square

        print(f"Generating {asset['id']} -> {out_path} ...")

        result = fal_client.run(model, arguments=payload)

        # Result formats vary. Try common shapes.
        img_b64 = None
        if isinstance(result, dict):
            if "image" in result and isinstance(result["image"], dict) and "base64" in result["image"]:
                img_b64 = result["image"]["base64"]
            elif "images" in result and result["images"]:
                first = result["images"][0]
                if isinstance(first, dict) and "base64" in first:
                    img_b64 = first["base64"]
                elif isinstance(first, dict) and "url" in first:
                    # If only URL is returned, you can fetch with requests.
                    import requests  # type: ignore

                    r = requests.get(first["url"], timeout=60)
                    r.raise_for_status()
                    out_path.write_bytes(r.content)
                    continue

        if not img_b64:
            raise RuntimeError(f"Unhandled response format for {asset['id']}: {result}")

        out_path.write_bytes(base64.b64decode(img_b64))

        # Optional: resize to the target size declared in the manifest outputs
        try:
            from PIL import Image  # type: ignore

            outputs = manifest.get("outputs", {})
            target = None
            if t == "icon":
                target = outputs.get("icons", {}).get("size")
            elif t == "background":
                target = outputs.get("backgrounds", {}).get("size")
            elif t == "mascot":
                target = outputs.get("mascot", {}).get("size")

            if target and isinstance(target, list) and len(target) == 2:
                tw, th = int(target[0]), int(target[1])
                im = Image.open(out_path)
                # Use contain for backgrounds (avoid cropping), direct resize for icons/mascot
                if t == "background":
                    im = im.resize((tw, th), Image.LANCZOS)
                else:
                    im = im.resize((tw, th), Image.LANCZOS)
                im.save(out_path)
        except Exception:
            # Pillow not installed or resize failed; keep original
            pass

    print("Done.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
