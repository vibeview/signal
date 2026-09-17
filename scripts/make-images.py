#!/usr/bin/env python3
"""Generate every image the channel ships: Roku icons and splash screens plus
one 16:9 tile per show. Flat colours only. Requires Pillow.

    python3 scripts/make-images.py
"""
import json
import os
from PIL import Image, ImageDraw, ImageFont

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
IMAGES = os.path.join(ROOT, "images")
BG = "#101318"
INK = "#F1EFE8"
INK2 = "#9AA0AC"
ACCENT = "#F2A33A"

FONT_CANDIDATES = [
    "/System/Library/Fonts/Supplemental/Arial Bold.ttf",
    "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
    "/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf",
]


def font(size):
    for path in FONT_CANDIDATES:
        if os.path.exists(path):
            return ImageFont.truetype(path, size)
    return ImageFont.load_default()


def centered(draw, box, text, fnt, fill):
    x0, y0, x1, y1 = box
    l, t, r, b = draw.textbbox((0, 0), text, font=fnt)
    w, h = r - l, b - t
    draw.text((x0 + (x1 - x0 - w) / 2 - l, y0 + (y1 - y0 - h) / 2 - t), text, font=fnt, fill=fill)


def brand(size, path, word_scale=0.28):
    w, h = size
    img = Image.new("RGB", size, BG)
    d = ImageDraw.Draw(img)
    fnt = font(int(h * word_scale))
    centered(d, (0, 0, w, h * 0.92), "Signal", fnt, INK)
    r = max(3, int(h * 0.05))
    d.ellipse((w * 0.5 - r, h * 0.72 - r, w * 0.5 + r, h * 0.72 + r), fill=ACCENT)
    img.save(path)


def tile(show, path, size=(640, 360)):
    w, h = size
    img = Image.new("RGB", size, show["color"])
    d = ImageDraw.Draw(img)
    initials = "".join(p[0] for p in show["title"].split() if p[0].isalpha() and p.lower() != "the")[:3].upper()
    centered(d, (0, 0, w, h * 0.78), initials, font(int(h * 0.42)), INK)
    strip = Image.new("RGBA", (w, int(h * 0.2)), (0, 0, 0, 90))
    img.paste(Image.new("RGB", (w, int(h * 0.2)), show["color"]), (0, int(h * 0.8)))
    img.paste(strip, (0, int(h * 0.8)), strip)
    centered(d, (0, h * 0.8, w, h), show["title"], font(int(h * 0.09)), INK)
    img.save(path)


def main():
    os.makedirs(os.path.join(IMAGES, "shows"), exist_ok=True)
    brand((540, 405), os.path.join(IMAGES, "icon_fhd.png"))
    brand((290, 218), os.path.join(IMAGES, "icon_hd.png"))
    brand((214, 144), os.path.join(IMAGES, "icon_sd.png"))
    brand((1920, 1080), os.path.join(IMAGES, "splash_fhd.png"), 0.16)
    brand((1280, 720), os.path.join(IMAGES, "splash_hd.png"), 0.16)
    brand((720, 480), os.path.join(IMAGES, "splash_sd.png"), 0.16)
    with open(os.path.join(ROOT, "data", "shows.json")) as f:
        shows = json.load(f)
    for show in shows:
        tile(show, os.path.join(IMAGES, "shows", show["id"] + ".png"))
    print("wrote %d tiles + 3 icons + 3 splash screens" % len(shows))


if __name__ == "__main__":
    main()
