"""
Build warehouse-office-blue-v2.png from the original artwork:
  - silhouette only (background + drop shadow removed)
  - interior artwork (house + ring) cut out as TRANSPARENT whitespace,
    exactly like the location-on-map icon (blue body, everything else transparent)
  - the 3D specular highlight is NOT a cut-out (it is pink-tinted, not white)
  - body recoloured with the exact timber-import gradient #152E82 -> #5FA4F9
"""
from PIL import Image
import numpy as np
from collections import deque
from scipy import ndimage

SRC = r"C:\Users\PC\Desktop\New folder (3)\Warehouse & Office.jpg"
DST = r"C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\warehouse-office-blue-v2.png"
DEBUG = r"C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\debug-warehouse-mask.png"

TOP = (21, 46, 130)    # #152E82
BOT = (95, 164, 249)   # #5FA4F9
SIZE = 256
PADDING = 0.85

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

# ---- flood fill the background (bg + shadow) from the border --------------
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

# ---- enclosed regions, split into artwork vs. specular highlight ---------
enclosed = (~c_pink) & (~outside)
labels, nlab = ndimage.label(enclosed)
print(f"enclosed regions: {nlab}")

# pinkness: pure white artwork -> ~0, pink-tinted 3D shine -> clearly > 0
pinkness = c_rgb[:, :, 0] - (c_rgb[:, :, 1] + c_rgb[:, :, 2]) / 2.0

keep = np.zeros((h, w), dtype=bool)
for i in range(1, nlab + 1):
    region = labels == i
    area = int(region.sum())
    mean_pink = float(pinkness[region].mean())
    frac_pink = float((pinkness[region] > 6).mean())
    ys_i, xs_i = np.where(region)
    print(f"  region {i}: area={area:6d} meanPink={mean_pink:7.2f} fracPink={frac_pink:.2f} "
          f"bbox=({xs_i.min()},{ys_i.min()})-({xs_i.max()},{ys_i.max()})")
    if area >= 300 and frac_pink < 0.35:
        keep |= region

print(f"kept as artwork whitespace: {int(keep.sum())} px")
Image.fromarray((keep * 255).astype(np.uint8)).save(DEBUG)

# ---- 1 px band around the silhouette (soft anti-aliased edges) -----------
near = np.zeros_like(c_pink)
near[1:, :] |= c_pink[:-1, :]
near[:-1, :] |= c_pink[1:, :]
near[:, 1:] |= c_pink[:, :-1]
near[:, :-1] |= c_pink[:, 1:]

ramp = np.clip((c_sat.astype(np.float32) - 18.0) / 42.0, 0.0, 1.0)

alpha = np.zeros((h, w), dtype=np.float32)
alpha[c_pink] = 1.0                       # solid body
band = near & (~c_pink)                   # edge band (outer edge + hole edge)
alpha[band] = ramp[band]                  # soft fade -> holes stay transparent
alpha[keep] = 0.0                         # artwork cut-outs are fully transparent

# ---- scale into a square canvas ------------------------------------------
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

# ---- exact timber-import gradient ----------------------------------------
rgb = np.zeros((SIZE, SIZE, 3), dtype=np.uint8)
for y in range(fy0, fy1 + 1):
    t = (y - fy0) / span
    rgb[y, :, :] = [int(round(TOP[i] + (BOT[i] - TOP[i]) * t)) for i in range(3)]

rgba = np.dstack([rgb, (final_alpha * 255).astype(np.uint8)])
Image.fromarray(rgba).save(DST)
print("saved", DST)
