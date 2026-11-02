"""
Make the background of the "Warehouse & Office" icon TRANSPARENT so it matches
the "Location on the map" icon (location-blue-v2.png), which is RGBA with a
transparent background.

Input : public/images/icons/warehouse-office-blue-v2.png
        (RGB, pure-white background, blue gradient pin, white house + ring)
Output: same file as RGBA
        - everything outside the pin silhouette  -> alpha 0
        - the pin body                           -> keeps the site gradient
        - the white house + ring artwork         -> stays opaque white
        - the outer edge is re-mixed against the body colour so the anti-
          aliased border has no white halo on any background.

Algorithm
  1. whiteish  = pixels close to pure white
  2. flood fill the whiteish pixels starting from the image border
     -> that region is the outer background
  3. white pixels *inside* the silhouette = the artwork (house + ring) and
     stay opaque white
  4. per row the body colour G(y) = median colour of the saturated body pixels
  5. for the 1 px edge band the alpha coverage is recovered by unmixing
     p = a * G + (1 - a) * 255
"""

import os
import shutil
from collections import deque

import numpy as np
from PIL import Image
from scipy import ndimage

ROOT = os.path.dirname(os.path.abspath(__file__))
ICONS = os.path.join(ROOT, "public", "images", "icons")
ASSETS = os.path.join(ROOT, "icon-preview-assets")
SRC = os.path.join(ASSETS, "warehouse-office-white.png")     # white-bg intermediate
DST = os.path.join(ASSETS, "warehouse-office-transparent.png")  # transparent master
BACKUP = os.path.join(ASSETS, "_backup-before-transparent-bg")
PREVIEW = r"C:\Users\PC\Documents\Default Project\warehouse-icon-transparent-preview.png"

os.makedirs(BACKUP, exist_ok=True)
if os.path.exists(DST):
    shutil.copy2(DST, os.path.join(BACKUP, "warehouse-office-transparent.png"))
    print("backup ->", BACKUP)

img = Image.open(SRC).convert("RGB")
arr = np.asarray(img).astype(np.float32)
H, W, _ = arr.shape

# ------------------------------------------------------------------ 1. white
whiteish = arr.min(axis=2) >= 250.0

# ------------------------------------------------- 2. flood fill outer white
outer = np.zeros((H, W), dtype=bool)
dq = deque()


def seed(y, x):
    if whiteish[y, x] and not outer[y, x]:
        outer[y, x] = True
        dq.append((y, x))


for x in range(W):
    seed(0, x)
    seed(H - 1, x)
for y in range(H):
    seed(y, 0)
    seed(y, W - 1)

while dq:
    y, x = dq.popleft()
    if x > 0:
        seed(y, x - 1)
    if x < W - 1:
        seed(y, x + 1)
    if y > 0:
        seed(y - 1, x)
    if y < H - 1:
        seed(y + 1, x)

print("outer background pixels:", int(outer.sum()))

# --------------------------------------------------------- 3. silhouette split
body = ~outer                      # pin body + artwork + anti-aliased edges
art = body & whiteish              # white artwork inside the pin (house/ring)
sat = arr.max(axis=2) - arr.min(axis=2)
core = body & (~art) & (sat > 30)  # saturated blue body pixels

print("artwork (white house + ring):", int(art.sum()))
print("body pixels:", int(body.sum()))

# --------------------------------------------- 4. per row body colour G(y)
G = np.zeros((H, 3), dtype=np.float32)
valid_rows = []
for y in range(H):
    sel = core[y]
    if int(sel.sum()) >= 3:
        G[y] = np.median(arr[y][sel], axis=0)
        valid_rows.append(y)

if not valid_rows:
    raise SystemExit("no body pixels found - aborting")

first, last = valid_rows[0], valid_rows[-1]
for y in range(H):
    if y in valid_rows:
        continue
    if y < first:
        G[y] = G[first]
    elif y > last:
        G[y] = G[last]
    else:
        lo = max(v for v in valid_rows if v < y)
        hi = min(v for v in valid_rows if v > y)
        t = (y - lo) / float(hi - lo)
        G[y] = G[lo] + (G[hi] - G[lo]) * t

# --------------------------------- 5. alpha: 0 outside, 1 inside, ramp on edge
alpha = np.zeros((H, W), dtype=np.float32)
alpha[body] = 1.0

band = ndimage.binary_dilation(outer, structure=np.ones((3, 3))) & body
band &= ~art

num = 255.0 - arr
den = 255.0 - G[:, None, :]
usable = den > 40.0
ratio = np.where(usable, num / np.maximum(den, 1e-6), 0.0)
cnt = usable.sum(axis=2)
cov = np.where(cnt > 0, ratio.sum(axis=2) / np.maximum(cnt, 1), 0.0)
cov = np.clip(cov, 0.0, 1.0)

alpha[band] = cov[band]

out = np.zeros((H, W, 4), dtype=np.uint8)
out[..., :3] = np.clip(arr, 0, 255).astype(np.uint8)
out[..., 3] = (alpha * 255).astype(np.uint8)

# the anti-aliased edge pixels are re-mixed against the pure body colour so no
# white halo survives when the icon is placed on a coloured background
for y in range(H):
    sel = band[y]
    if sel.any():
        out[y, sel, :3] = np.clip(G[y], 0, 255).astype(np.uint8)
# the artwork keeps pure white + full opacity
out[art, :3] = 255
out[art, 3] = 255

Image.fromarray(out, "RGBA").save(DST)
print("saved:", DST, "mode RGBA")

# ------------------------------------------------------------- verification
chk = np.asarray(Image.open(DST).convert("RGBA"))
a = chk[..., 3]
print("alpha extrema:", a.min(), a.max())
print("transparent pixels: %.1f%%" % (100.0 * (a == 0).mean()))
print("corners:", chk[0, 0].tolist(), chk[-1, -1].tolist())

# preview: the two icons on the same light-blue square used by the website
loc = Image.open(os.path.join(ICONS, "location-blue-v2.png")).convert("RGBA")
wh = Image.open(DST).convert("RGBA")
tile = Image.new("RGBA", (220, 220), (255, 255, 255, 255))
tile.alpha_composite(Image.new("RGBA", (220, 220), (240, 244, 252, 255)))
tile.alpha_composite(loc.resize((176, 176), Image.LANCZOS), (22, 22))
tile2 = Image.new("RGBA", (220, 220), (255, 255, 255, 255))
tile2.alpha_composite(Image.new("RGBA", (220, 220), (240, 244, 252, 255)))
tile2.alpha_composite(wh.resize((176, 176), Image.LANCZOS), (22, 22))
sheet = Image.new("RGB", (460, 260), "white")
sheet.paste(tile.convert("RGB"), (10, 40))
sheet.paste(tile2.convert("RGB"), (230, 40))
sheet.save(PREVIEW)
print("saved preview:", PREVIEW)
