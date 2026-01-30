#!/usr/bin/env python3
"""Generate image assets using fal.ai HTTP queue API.

Usage:
  export FAL_KEY=...
  cd /mnt/d/Playground/Game_Taplok
  python3 tools/generate_assets_falai_http.py [manifest_path] [asset_id1 asset_id2 ...]

Defaults:
  manifest_path = tools/fal_ai_asset_manifest.json

This script:
- reads a manifest JSON
- POSTs to https://queue.fal.run/<model>
- polls until completed
- downloads the image(s) and writes to the manifest output paths

Notes:
- gpt-image-1.5 schema guarantees `prompt` and `image_size`.
- We keep payload conservative for stability.
"""

from __future__ import annotations

import json
import os
import pathlib
import time
import sys
from typing import Any

import requests


def require_env(name: str) -> str:
    v = os.environ.get(name)
    if not v:
        raise SystemExit(f"Missing env {name}. Export it first.")
    return v


def auth_headers() -> dict[str, str]:
    key = require_env("FAL_KEY")
    return {"Authorization": f"Key {key}", "Content-Type": "application/json"}


def submit(queue_base: str, prompt: str, *, image_size: str | None = None, aspect_ratio: str | None = None, output_format: str = "png") -> str:
    payload: dict[str, Any] = {"prompt": prompt, "output_format": output_format}
    # Some models (e.g. gpt-image-1.5) use image_size; FLUX uses aspect_ratio.
    if image_size is not None:
        payload["image_size"] = image_size
    if aspect_ratio is not None:
        payload["aspect_ratio"] = aspect_ratio
    r = requests.post(queue_base, headers=auth_headers(), json=payload, timeout=60)
    r.raise_for_status()
    data = r.json()
    rid = data.get("request_id")
    if not rid:
        raise RuntimeError(f"No request_id in response: {data}")
    return rid


def wait_result(queue_base: str, request_id: str, timeout_s: int = 300) -> dict[str, Any]:
    deadline = time.time() + timeout_s
    status_url = f"{queue_base}/requests/{request_id}/status"
    result_url = f"{queue_base}/requests/{request_id}"

    while True:
        if time.time() > deadline:
            raise TimeoutError(f"Timed out waiting for {request_id}")

        s = requests.get(status_url, headers=auth_headers(), timeout=30)
        s.raise_for_status()
        st = s.json()

        if st.get("status") == "COMPLETED":
            r = requests.get(result_url, headers=auth_headers(), timeout=60)
            r.raise_for_status()
            return r.json()

        if st.get("status") in {"FAILED", "CANCELED"}:
            raise RuntimeError(f"Request {request_id} failed: {st}")

        time.sleep(2)


def download_first_image(result: dict[str, Any], out_path: pathlib.Path) -> None:
    images = result.get("images") or []
    if not images:
        raise RuntimeError(f"No images in result: {result}")

    first = images[0]
    url = first.get("url")
    if not url:
        raise RuntimeError(f"No url in first image: {first}")

    resp = requests.get(url, timeout=120)
    resp.raise_for_status()
    out_path.write_bytes(resp.content)


def resize_if_needed(out_path: pathlib.Path, target_size: list[int] | None) -> None:
    if not target_size:
        return
    try:
        from PIL import Image

        tw, th = int(target_size[0]), int(target_size[1])
        im = Image.open(out_path)
        im = im.resize((tw, th), Image.LANCZOS)
        im.save(out_path)
    except Exception:
        return


def main() -> int:
    manifest_path = pathlib.Path(sys.argv[1]) if len(sys.argv) > 1 and sys.argv[1].endswith('.json') else pathlib.Path(__file__).with_name("fal_ai_asset_manifest.json")
    argv_ids = sys.argv[2:] if manifest_path != pathlib.Path(__file__).with_name("fal_ai_asset_manifest.json") else sys.argv[1:]

    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    outputs = manifest.get("outputs", {})

    model = manifest.get("style", {}).get("model", "fal-ai/gpt-image-1.5")
    queue_submit_base = f"https://queue.fal.run/{model}"

    # Some fal queue endpoints use a different base for status/result (notably flux-pro)
    if model.startswith("fal-ai/flux-pro/"):
        queue_status_base = "https://queue.fal.run/fal-ai/flux-pro"
    else:
        queue_status_base = queue_submit_base

    only_ids = set(argv_ids) if len(argv_ids) > 0 else None

    for asset in manifest["assets"]:
        if only_ids is not None and asset.get("id") not in only_ids:
            continue

        out_path = pathlib.Path(asset["out"])
        out_path.parent.mkdir(parents=True, exist_ok=True)

        t = asset["type"]
        # Size hints
        # gpt-image-1.5 validates specific sizes; FLUX accepts width/height via `image_size` in many cases.
        # We'll keep using these common sizes and then resize to manifest targets.
        if t == "background":
            image_size = "1024x1536"
            target = outputs.get("background", {}).get("size") or outputs.get("backgrounds", {}).get("size")
        else:
            image_size = "1024x1024"
            target = outputs.get(t + "s", {}).get("size") or outputs.get("icons", {}).get("size")

        prompt = asset["prompt"]
        neg = asset.get("negative")
        if neg:
            prompt = f"{prompt}\n\nAvoid: {neg}"

        is_flux = "flux" in model
        if is_flux:
            # FLUX models use aspect_ratio instead of image_size
            aspect_ratio = "16:9" if t == "background" else "1:1"
            print(f"Generating {asset['id']} -> {out_path} (aspect {aspect_ratio})")
            rid = submit(queue_submit_base, prompt, aspect_ratio=aspect_ratio, output_format="png")
        else:
            print(f"Generating {asset['id']} -> {out_path} ({image_size})")
            rid = submit(queue_submit_base, prompt, image_size=image_size, output_format="png")
        result = wait_result(queue_status_base, rid, timeout_s=900)
        download_first_image(result, out_path)
        resize_if_needed(out_path, target)

    print("Done.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
