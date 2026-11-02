"""
Rebuild the "Location on the map" icon as a SOLID filled map-pin marker.

Problem: location-blue-v2.png was an outline-only drawing (blue strokes, fully
transparent interior) which looked inconsistent next to warehouse-office-blue-v2.png
(a solid filled map pin).

Solution: reuse the EXACT silhouette + row gradient of warehouse-office-blue-v2.png,
fill every interior hole (house + ring cut-outs) so the whole pin body is solid
blue, and keep smooth anti-aliased edges.

Output: public/images/icons/location-blue-v2.png
"""

import os
import shutil
from collections import Counter

import numpy as np
from PIL import Image
from scipy import ndimage

ROOT = os.path.dirname(os.path.abspath(__file__))
ICONS = os.path.join(ROOT, "public", "images", "icons")
ASSETS = os.path.join(ROOT, "icon-preview-assets")
SRC = os.path.join(ASSETS, "warehouse-office-transparent.png")   # silhouette + gradient donor
OUT = os.path.join(ICONS, "location-blue-v2.png")
BACKUP = os.path.join(ICONS, "_backup-before-location-solid")

# the donor keeps the transparent background; the delivered PNG in ICONS has a
# flat grey canvas, so it can no longer be used as an alpha donor

os.makedirs(BACKUP, exist_ok=True)
if os.path.exists(OUT):
    shutil.copy2(OUT, os.path.join(BACKUP, "location-blue-v2.png"))

src = Image.open(SRC).convert("RGBA")
a = np.array(src)
alpha = a[..., 3].astype(np.float32)
rgb = a[..., :3].astype(np.float32)
H, W = alpha.shape

# The donor may sit on a solid white background (and the house + ring artwork is
# white as well).  In that case the coverage alpha is recovered by unmixing the
# pixel against the per-row body colour:  p = a * G + (1 - a) * 255.
white_bg = bool(alpha.min() > 250 and rgb[0, 0].min() > 250 and rgb[-1, -1].min() > 250)
print("donor background:", "solid white" if white_bg else "transparent")

if white_bg:
    dist = (255.0 - rgb).sum(axis=2)
    idx = dist.argmax(axis=1)
    G = rgb[np.arange(H), idx]                     # body colour of every row
    num = 255.0 - rgb
    den = 255.0 - G[:, None, :]
    usable = den > 30.0
    ratio = np.where(usable, num / np.maximum(den, 1e-6), 0.0)
    cnt = usable.sum(axis=2)
    cov = np.where(cnt > 0, ratio.sum(axis=2) / np.maximum(cnt, 1), 0.0)
    cov = np.clip(cov, 0.0, 1.0)
    core = cov > 0.5
else:
    core = alpha > 128

# ---------------------------------------------------------------- 1. silhouette
solid = ndimage.binary_fill_holes(core)          # closes house + ring cut-outs
solid = ndimage.binary_closing(solid, structure=np.ones((3, 3)))

# signed distance -> smooth anti-aliased alpha (1px feather)
inside = ndimage.distance_transform_edt(solid)
outside = ndimage.distance_transform_edt(~solid)
signed = inside - outside
edge_alpha = np.clip(0.5 + signed, 0.0, 1.0) * 255.0

# ---------------------------------------------------------------- 2. gradient
# The donor icon uses a pure per-row vertical gradient (colour depends on y only).
row_color = {}
for y in range(a.shape[0]):
    if white_bg:
        c = G[y]
        if (255.0 - c).sum() > 30.0:               # the row really holds body pixels
            row_color[y] = tuple(int(round(v)) for v in c)
    else:
        # only the saturated blue body pixels define the row colour - the white
        # artwork (house + ring) must never win, otherwise a white cap shows up
        # at the top of the pin
        px = a[y][alpha[y] > 200][:, :3].astype(np.float32)
        if len(px):
            sat = px.max(axis=1) - px.min(axis=1)
            body = px[sat > 30]
            if len(body):
                row_color[y] = tuple(int(round(v)) for v in np.median(body, axis=0))

ys = sorted(row_color)
for y in range(a.shape[0]):
    if y in row_color:
        continue
    if y < ys[0]:
        row_color[y] = row_color[ys[0]]
    elif y > ys[-1]:
        row_color[y] = row_color[ys[-1]]
    else:
        lo = max(v for v in ys if v < y)
        hi = min(v for v in ys if v > y)
        t = (y - lo) / float(hi - lo)
        c0, c1 = row_color[lo], row_color[hi]
        row_color[y] = tuple(int(round(c0[i] + (c1[i] - c0[i]) * t)) for i in range(3))

out = np.zeros((a.shape[0], a.shape[1], 4), dtype=np.uint8)
for y in range(a.shape[0]):
    r, g, b = row_color[y]
    out[y, :, 0] = r
    out[y, :, 1] = g
    out[y, :, 2] = b
    out[y, :, 3] = edge_alpha[y].astype(np.uint8)

# keep the pin centred / same footprint as the donor icon
Image.fromarray(out, "RGBA").save(OUT)

print("saved:", OUT)
print("opaque pixels:", int((out[..., 3] > 128).sum()))
