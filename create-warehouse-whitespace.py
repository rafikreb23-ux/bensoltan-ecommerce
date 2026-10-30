"""
Build warehouse-office-blue-v2.png from the original artwork:
  - keep the silhouette (drop the background + drop shadow)
  - keep the white artwork details (house + ring) as whitespace
  - recolour the body with the exact timber-import gradient #152E82 -> #5FA4F9
"""
from PIL import Image
import numpy as np
from collections import deque

SRC = r"C:\Users\PC\Desktop\New folder (3)\Warehouse & Office.jpg"
DST = r"C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\warehouse-office-blue-v2.png"

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

c_sat = sat[cy0:cy1 + 1, cx0:cx1 + 1]
c_pink = pink[cy0:cy1 + 1, cx0:cx1 + 1]
h, w = c_pink.shape

# ---- flood fill the background (bg + shine + shadow) from the border ----
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

# ---- enclosed white regions = real artwork details (house + ring) -------
detail = (~c_pink) & (~outside)
print(f"white-detail pixels: {int(detail.sum())}")

# ---- soft anti-aliased edge on the silhouette ----------------------------
near = np.zeros_like(c_pink)
near[1:, :] |= c_pink[:-1, :]
near[:-1, :] |= c_pink[1:, :]
near[:, 1:] |= c_pink[:, :-1]
near[:, :-1] |= c_pink[:, 1:]

alpha = np.zeros((h, w), dtype=np.float32)
alpha[c_pink] = 1.0
alpha[detail] = 1.0
edge = near & (~c_pink) & (~detail)
alpha[edge] = np.clip((c_sat[edge].astype(np.float32) - 18.0) / 42.0, 0.0, 1.0)

# ---- scale into a square canvas ------------------------------------------
scale = min((SIZE * PADDING) / w, (SIZE * PADDING) / h)
dw, dh = int(round(w * scale)), int(round(h * scale))
ox, oy = (SIZE - dw) // 2, (SIZE - dh) // 2

a_img = Image.fromarray((alpha * 255).astype(np.uint8), "L").resize((dw, dh), Image.LANCZOS)
d_img = Image.fromarray((detail * 255).astype(np.uint8), "L").resize((dw, dh), Image.NEAREST)

final_alpha = np.zeros((SIZE, SIZE), dtype=np.float32)
final_detail = np.zeros((SIZE, SIZE), dtype=bool)
final_alpha[oy:oy + dh, ox:ox + dw] = np.asarray(a_img).astype(np.float32) / 255.0
final_detail[oy:oy + dh, ox:ox + dw] = np.asarray(d_img) > 128

rows = np.where(final_alpha.max(axis=1) > 0.01)[0]
fy0, fy1 = rows.min(), rows.max()
span = max(fy1 - fy0, 1)
print(f"final bbox Y={fy0}..{fy1} (span {span})")

# ---- exact timber-import gradient ----------------------------------------
rgb = np.zeros((SIZE, SIZE, 3), dtype=np.uint8)
for y in range(fy0, fy1 + 1):
    t = (y - fy0) / span
    rgb[y, :, :] = [int(round(TOP[i] + (BOT[i] - TOP[i]) * t)) for i in range(3)]
rgb[final_detail] = 255  # whitespace stays white

rgba = np.dstack([rgb, (final_alpha * 255).astype(np.uint8)])
Image.fromarray(rgba, "RGBA").save(DST)
print("saved", DST)
