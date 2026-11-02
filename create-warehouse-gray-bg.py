"""
Give the "Warehouse & Office" icon a solid GREY background (#e2e8f0).

Input : icon-preview-assets/warehouse-office-transparent.png
        (RGBA, transparent outside the pin, blue gradient body, white house+ring)
Output: public/images/icons/warehouse-office-blue-v2.png
        (RGB, the very same artwork composited over a flat #e2e8f0 canvas)

Why compositing instead of just painting the alpha-0 pixels:
  the icon has a 1 px anti-aliased border whose pixels are partially transparent.
  Compositing keeps that border smooth against the new grey background, so no
  white halo and no jagged edge appears.

The transparent master is kept in icon-preview-assets/ so the file can always
be rebuilt and so create-location-solid-pin.py still has a transparent donor.
"""

import os

import numpy as np
from PIL import Image

ROOT = os.path.dirname(os.path.abspath(__file__))
ICONS = os.path.join(ROOT, "public", "images", "icons")
ASSETS = os.path.join(ROOT, "icon-preview-assets")

MASTER = os.path.join(ASSETS, "warehouse-office-transparent.png")
DST = os.path.join(ICONS, "warehouse-office-blue-v2.png")
BACKUP = os.path.join(ICONS, "_backup-before-gray-bg")
PREVIEW = r"C:\Users\PC\Documents\Default Project\warehouse-icon-preview.png"

GREY = (226, 232, 240)        # #e2e8f0  (= --color-border of the website)

os.makedirs(BACKUP, exist_ok=True)
if os.path.exists(DST):
    import shutil
    shutil.copy2(DST, os.path.join(BACKUP, "warehouse-office-blue-v2.png"))
    print("backup ->", BACKUP)

master = Image.open(MASTER).convert("RGBA")

# ------------------------------------------------------------- composite
canvas = Image.new("RGBA", master.size, GREY + (255,))
canvas.alpha_composite(master)
out = canvas.convert("RGB")
out.save(DST)
print("saved:", DST, out.size, "background", GREY)

# ------------------------------------------------------------- verification
chk = np.asarray(out).astype(int)
print("corner colour:", chk[0, 0].tolist(), chk[-1, -1].tolist())
print("unique corner/edge greys:", np.unique(chk[0, :, :].reshape(-1, 3), axis=0)[:3].tolist())

# ----------------------------------------------------------------- preview
tile_grey = Image.new("RGB", (220, 220), GREY)
tile_grey.paste(out.resize((176, 176), Image.LANCZOS), (22, 22))

tile_white = Image.new("RGB", (220, 220), (255, 255, 255))
tile_white.paste(out.resize((176, 176), Image.LANCZOS), (22, 22))

tile_site = Image.new("RGB", (220, 220), (248, 250, 252))
tile_site.paste(out.resize((176, 176), Image.LANCZOS), (22, 22))

sheet = Image.new("RGB", (700, 250), "white")
sheet.paste(tile_white, (10, 20))
sheet.paste(tile_grey, (240, 20))
sheet.paste(tile_site, (470, 20))
sheet.save(PREVIEW)
print("saved preview:", PREVIEW)
