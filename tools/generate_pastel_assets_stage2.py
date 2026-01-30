#!/usr/bin/env python3
"""Generate simple flat pastel assets for remaining mini-games.
Creates backgrounds (1080x1920) and simple sprites (keys/circles/tiles/icons).
"""

from __future__ import annotations

import os
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "assets" / "textures" / "games"


def _ensure(p: Path) -> None:
    p.mkdir(parents=True, exist_ok=True)


def _linear_gradient(size, top, bottom):
    w, h = size
    img = Image.new("RGBA", size, top)
    dr = ImageDraw.Draw(img)
    for y in range(h):
        t = y / max(1, h - 1)
        c = tuple(int(top[i] * (1 - t) + bottom[i] * t) for i in range(4))
        dr.line([(0, y), (w, y)], fill=c)
    return img


def _rounded_rect(draw: ImageDraw.ImageDraw, box, radius, fill, outline=None, width=1):
    # PIL rounded_rectangle exists; keep compatibility.
    draw.rounded_rectangle(box, radius=radius, fill=fill, outline=outline, width=width)


def _save(img: Image.Image, path: Path) -> None:
    _ensure(path.parent)
    img.save(path, format="PNG")


def _try_font(size: int):
    # Use DejaVu if present, else default.
    for name in [
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
        "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
    ]:
        if os.path.exists(name):
            return ImageFont.truetype(name, size=size)
    return ImageFont.load_default()


def make_background(out_dir: Path, name: str, top, bottom, blobs):
    img = _linear_gradient((1080, 1920), top, bottom)
    d = ImageDraw.Draw(img)
    for (cx, cy, r, col) in blobs:
        d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=col)
    _save(img, out_dir / name)


def make_key_sprite(out_dir: Path, name: str, fill, accent):
    img = Image.new("RGBA", (256, 512), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # shadow
    _rounded_rect(d, (18, 18, 238, 498), 36, fill=(0, 0, 0, 35))
    # body
    _rounded_rect(d, (12, 12, 236, 492), 36, fill=fill, outline=(255, 255, 255, 180), width=3)
    # top accent band
    _rounded_rect(d, (24, 24, 224, 96), 24, fill=accent)
    _save(img, out_dir / name)


def make_circle_sprite(out_dir: Path, name: str, fill):
    img = Image.new("RGBA", (256, 256), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.ellipse((12, 14, 244, 246), fill=(0, 0, 0, 35))
    d.ellipse((8, 8, 248, 248), fill=fill, outline=(255, 255, 255, 180), width=4)
    _save(img, out_dir / name)


def make_tile_sprite(out_dir: Path, name: str, base):
    img = Image.new("RGBA", (256, 256), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    _rounded_rect(d, (18, 22, 244, 248), 40, fill=(0, 0, 0, 35))
    _rounded_rect(d, (12, 12, 244, 244), 40, fill=base, outline=(255, 255, 255, 160), width=4)
    _save(img, out_dir / name)


def make_icon(out_dir: Path, name: str, letter: str, fill, text_col=(40, 40, 60, 255)):
    img = Image.new("RGBA", (256, 256), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.ellipse((16, 18, 240, 242), fill=(0, 0, 0, 30))
    d.ellipse((12, 12, 244, 244), fill=fill, outline=(255, 255, 255, 180), width=4)

    font = _try_font(120)
    w, h = d.textbbox((0, 0), letter, font=font)[2:]
    d.text(((256 - w) / 2, (256 - h) / 2 - 8), letter, font=font, fill=text_col)
    _save(img, out_dir / name)


def main():
    # Pastel palettes
    pastel_blue_top = (223, 242, 255, 255)
    pastel_blue_bottom = (255, 245, 253, 255)

    # Piano
    piano_dir = ASSETS / "piano"
    make_background(
        piano_dir,
        "bg_piano_1080x1920.png",
        top=pastel_blue_top,
        bottom=pastel_blue_bottom,
        blobs=[
            (220, 340, 240, (255, 220, 235, 120)),
            (880, 520, 280, (210, 245, 230, 120)),
            (540, 1480, 360, (245, 235, 255, 130)),
        ],
    )
    make_key_sprite(piano_dir, "key_piano_256x512.png", fill=(252, 252, 255, 255), accent=(240, 248, 255, 255))
    icons = [
        ("komodo", "K", (232, 232, 255, 255)),
        ("orangutan", "O", (255, 235, 220, 255)),
        ("burung", "B", (225, 250, 255, 255)),
        ("paus", "P", (225, 240, 255, 255)),
        ("belalang", "L", (230, 255, 235, 255)),
    ]
    for iid, letter, col in icons:
        make_icon(piano_dir, f"icon_{iid}_256.png", letter, fill=col)

    # Creative backgrounds (Coloring/FingerPaint)
    creative_dir = ASSETS / "creative"
    make_background(
        creative_dir,
        "bg_creative_1080x1920.png",
        top=(255, 245, 230, 255),
        bottom=(235, 250, 255, 255),
        blobs=[
            (280, 420, 260, (255, 220, 200, 120)),
            (860, 360, 240, (220, 245, 255, 120)),
            (540, 1500, 380, (230, 255, 235, 120)),
        ],
    )

    # Rhythm
    rhythm_dir = ASSETS / "rhythm"
    make_background(
        rhythm_dir,
        "bg_rhythm_1080x1920.png",
        top=(240, 230, 255, 255),
        bottom=(230, 255, 248, 255),
        blobs=[
            (260, 520, 260, (255, 235, 250, 120)),
            (860, 540, 260, (220, 235, 255, 120)),
            (540, 1480, 420, (255, 250, 220, 120)),
        ],
    )
    for i, col in enumerate([(232, 74, 61, 255), (56, 189, 248, 255), (251, 191, 36, 255), (52, 211, 153, 255)]):
        make_circle_sprite(rhythm_dir, f"circle_{i+1}_256.png", fill=col)

    # Shape Match
    shape_dir = ASSETS / "shape_match"
    make_background(
        shape_dir,
        "bg_shape_match_1080x1920.png",
        top=(245, 250, 255, 255),
        bottom=(255, 245, 235, 255),
        blobs=[
            (220, 420, 280, (230, 255, 245, 120)),
            (900, 420, 280, (255, 235, 220, 120)),
            (540, 1500, 440, (245, 235, 255, 120)),
        ],
    )
    make_tile_sprite(shape_dir, "tile_option_256.png", base=(250, 250, 255, 255))
    make_tile_sprite(shape_dir, "tile_silhouette_512.png", base=(235, 240, 250, 255))

    # simple puzzle icons (letters)
    for iid, letter in [
        ("joglo", "J"), ("gadang", "G"), ("tongkonan", "T"), ("kampoeng", "K"),
        ("komodo", "K"), ("orangutan", "O"), ("burung", "B"), ("paus", "P"),
    ]:
        make_icon(shape_dir, f"icon_{iid}_256.png", letter, fill=(255, 255, 255, 255))

    print("Generated pastel assets into", ASSETS)


if __name__ == "__main__":
    main()
