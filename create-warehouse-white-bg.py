"""
Build the "Warehouse & Office" icon on a PURE WHITE background.

Source : Desktop\\New folder (3)\\Warehouse & Office.png  (626x626)
          - glossy magenta map-pin, white house + ring inside
          - white page + a GREY drop-shadow / soft halo around the pin
            -> that grey backdrop is what makes the "background look grey"
Result  : the same artwork with the site gradient (#152E82 -> #5FA4F9) and a
          forced pure-white (#FFFFFF) background: the grey shadow is dropped,
          the anti-aliased edges are re-mixed against white (no grey halo).

Algorithm (same silhouette extraction as create-warehouse-whitespace.py):
  1. body    = saturated magenta pixels (sat > 60)
  2. flood fill from the border  -> everything outside the pin
     (white page + grey shadow) is background
  3. enclosed regions inside the pin = the white artwork (house + ring);
     the pink-tinted specular highlight stays part of the body
  4. 1 px edge band gets a soft alpha ramp from the pixel saturation
  5. the body is filled with the vertical site gradient and composited over white
"""

import os
import shutil
from collections import deque

import numpy as np
from PIL import Image
from scipy import ndimage

SRC = r"C:\Users\PC\Desktop\New folder (3)\Warehouse & Office.png"
ASSETS = r"C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\icon-preview-assets"
DST = os.path.join(ASSETS, "warehouse-office-white.png")
BACKUP = os.path.join(ASSETS, "_backup-before-white-bg", "warehouse-office-white.png")
PREVIEW = r"C:\Users\PC\Documents\Default Project\warehouse-icon-preview.png"

TOP = (21, 46, 130)    # #152E82
BOT = (95, 164, 249)   # #5FA4F9
WHITE = 255
SIZE = 256
PADDING = 0.85

os.makedirs(os.path.dirname(BACKUP), exist_ok=True)
if os.path.exists(DST):
    shutil.copy2(DST, BACKUP)
    print("backup ->", BACKUP)

img = Image.open(SRC).convert("RGB")
arr = np.asarray(img).astype(np.int16)
sat = arr.max(axis=2) - arr.min(axis=2)
pink = sat > 60

ys, xs = np.where(pink)
cy0, cy1, cx0, cx1 = ys.min(), ys.max(), xs.min(), xs.max()
print(f"source {img.size}  silhouette bbox X={cx0}..{cx1} Y={cy0}..{cy1}")

c_rgb = arr[cy0:cy1 + 1, cx0:cx1 + 1]
c_sat = sat[cy0:cy1 + 1, cx0:cx1 + 1]
c_pink = pink[cy0:cy1 + 1, cx0:cx1 + 1]
h, w = c_pink.shape

# ---- flood fill the background (white page + grey shadow) from the border --
outside = np.zeros((h, w), dtype=bool)
dq = deque()


def seed(y, x):
    if not c_pink[y, x] and not outside[y, x]:
        outside[y, x] = True
        dq.append((y, x))


for x in range(w):
    seed(0, x)
    seed(h - 1, x)
for y in range(h):
    seed(y, 0)
    seed(y, w - 1)

while dq:
    y, x = dq.popleft()
    if x > 0:
        seed(y, x - 1)
    if x < w - 1:
        seed(y, x + 1)
    if y > 0:
        seed(y - 1, x)
    if y < h - 1:
        seed(y + 1, x)

# ---- enclosed regions: white artwork vs. pink-tinted specular highlight ---
enclosed = (~c_pink) & (~outside)
labels, nlab = ndimage.label(enclosed)
print(f"enclosed regions: {nlab}")

pinkness = c_rgb[:, :, 0] - (c_rgb[:, :, 1] + c_rgb[:, :, 2]) / 2.0

artwork = np.zeros((h, w), dtype=bool)
for i in range(1, nlab + 1):
    region = labels == i
    area = int(region.sum())
    frac_pink = float((pinkness[region] > 6).mean())
    ys_i, xs_i = np.where(region)
    print(f"  region {i}: area={area:6d} fracPink={frac_pink:.2f} "
          f"bbox=({xs_i.min()},{ys_i.min()})-({xs_i.max()},{ys_i.max()})")
    if area >= 300 and frac_pink < 0.35:
        artwork |= region

print(f"artwork (house + ring) kept white: {int(artwork.sum())} px")

# ---- soft 1 px anti-aliased edge ------------------------------------------
near = np.zeros_like(c_pink)
near[1:, :] |= c_pink[:-1, :]
near[:-1, :] |= c_pink[1:, :]
near[:, 1:] |= c_pink[:, :-1]
near[:, :-1] |= c_pink[:, 1:]

ramp = np.clip((c_sat.astype(np.float32) - 18.0) / 42.0, 0.0, 1.0)

alpha = np.zeros((h, w), dtype=np.float32)
alpha[c_pink] = 1.0                              # solid body
band = near & (~c_pink)                          # outer edge + artwork edge
alpha[band] = ramp[band]
alpha[artwork] = 0.0                             # artwork stays white

# ---- scale into a square canvas -------------------------------------------
scale = min((SIZE * PADDING) / w, (SIZE * PADDING) / h)
dw, dh = int(round(w * scale)), int(round(h * scale))
ox, oy = (SIZE - dw) // 2, (SIZE - dh) // 2

a_img = Image.fromarray((alpha * 255).astype(np.uint8)).resize((dw, dh), Image.LANCZOS)

final_alpha = np.zeros((SIZE, SIZE), dtype=np.float32)
final_alpha[oy:oy + dh, ox:ox + dw] = np.asarray(a_img).astype(np.float32) / 255.0

rows = np.where(final_alpha.max(axis=1) > 0.01)[0]
fy0, fy1 = rows.min(), rows.max()
span = max(fy1 - fy0, 1)
print(f"final bbox Y={fy0}..{fy1} (span {span})")

# ---- exact site gradient, composited over pure white ----------------------
grad = np.zeros((SIZE, SIZE, 3), dtype=np.float32)
for y in range(fy0, fy1 + 1):
    t = (y - fy0) / span
    grad[y, :, :] = [TOP[i] + (BOT[i] - TOP[i]) * t for i in range(3)]

a3 = final_alpha[:, :, None]
out = a3 * grad + (1.0 - a3) * WHITE
out = np.clip(out, 0, 255).astype(np.uint8)

Image.fromarray(out, "RGB").save(DST)
print("saved", DST)

# ---- preview: source | result ---------------------------------------------
src_small = img.convert("RGB").resize((320, 320), Image.LANCZOS)
res_small = Image.open(DST).convert("RGB").resize((320, 320), Image.LANCZOS)
sheet = Image.new("RGB", (650, 320), "white")
sheet.paste(src_small, (5, 0))
sheet.paste(res_small, (330, 0))
sheet.save(PREVIEW)
print("saved", PREVIEW)

# ---- verification ----------------------------------------------------------
chk = np.asarray(Image.open(DST).convert("RGB")).astype(int)
gray_px = int(((np.abs(chk[:, :, 0] - chk[:, :, 1]) < 6) &
               (np.abs(chk[:, :, 1] - chk[:, :, 2]) < 6) &
               (chk[:, :, 0] > 100) & (chk[:, :, 0] < 250)).sum())
print("neutral-grey pixels left in the result:", gray_px)
print("corner colours:", chk[0, 0].tolist(), chk[-1, -1].tolist())
print("mode:", Image.open(DST).mode, "size:", Image.open(DST).size)
