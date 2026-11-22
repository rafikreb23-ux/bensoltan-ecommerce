"""Finalize warehouse/office icon PNGs from the verified browser-rendered SVG design.

Design source: original 'Warehouse & Office.png' (map pin + circle + house),
rendered as line-art with a single vertical gradient (#152E82 -> #5FA4F9),
exactly like the site's other contact icons (location, email, phone).
The 512px render came from the exact SVG now stored as icons/warehouse-office.svg
(rendered in-page via canvas, saved under temp/dep-check).
"""
import io
import os
import re

from PIL import Image

ROOT = os.path.dirname(os.path.abspath(__file__))
ICONS = os.path.join(ROOT, "public", "images", "icons")
SRC_RENDER = r"C:\Users\PC\AppData\Local\Temp\opencode\dep-check\final-transparent-256.png"

OUTS = {
    "warehouse-office-gradient-transparent.png": None,
    "warehouse-office-gradient-white.png": (255, 255, 255),
    "warehouse-office-gradient-gray.png": (226, 232, 240),
}

alpha = Image.open(SRC_RENDER).convert("RGBA")
print("source render:", alpha.size)

for name, bg in OUTS.items():
    dst = os.path.join(ICONS, name)
    if bg is None:
        alpha.save(dst)
    else:
        tile = Image.new("RGBA", alpha.size, bg + (255,))
        tile.alpha_composite(alpha)
        tile.convert("RGB").save(dst)
    print("saved", dst)

# report
for name in OUTS:
    p = os.path.join(ICONS, name)
    img = Image.open(p)
    kb = os.path.getsize(p) / 1024
    print(f"{name}: {img.size} {img.mode} {kb:.1f}KB")
