#!/usr/bin/env python3
"""
Process the ORIGINAL Warehouse & Office.png to create icon
matching location-blue-v3.png: vertical gradient, solid filled shape.
"""
import os
import shutil
import numpy as np
from PIL import Image, ImageFilter
from scipy import ndimage

SRC = r"C:\Users\PC\Desktop\New folder (3)\New folder (2)\Warehouse & Office.png"

ROOT = os.path.dirname(os.path.abspath(__file__))
ICONS = os.path.join(ROOT, "public", "images", "icons")

DST_TRANSPARENT = os.path.join(ICONS, "warehouse-office-gradient-transparent.png")
DST_WHITE = os.path.join(ICONS, "warehouse-office-gradient-white.png")
DST_GRAY = os.path.join(ICONS, "warehouse-office-gradient-gray.png")

BACKUP_DIR = os.path.join(ICONS, "_backup-warehouse-gradient")
PREVIEW = os.path.join(os.path.expanduser("~"), "Documents", "Default Project", "warehouse-icon-preview.png")

GRADIENT_TOP = (21, 46, 130)      # #152E82
GRADIENT_BOTTOM = (95, 164, 249)   # #5FA4F9
WHITE = (255, 255, 255)
GRAY = (226, 232, 240)
SIZE = 256
PADDING = 0.75

os.makedirs(ICONS, exist_ok=True)
os.makedirs(BACKUP_DIR, exist_ok=True)

for dst in (DST_TRANSPARENT, DST_WHITE, DST_GRAY):
    if os.path.exists(dst):
        shutil.copy2(dst, os.path.join(BACKUP_DIR, os.path.basename(dst)))

# Load original
src_img = Image.open(SRC).convert("RGBA")
print(f"Source: {src_img.size}, mode: {src_img.mode}")
src_arr = np.asarray(src_img).astype(np.float32) / 255.0
alpha = src_arr[:, :, 3]
rgb = src_arr[:, :, :3]

# If no alpha, create from luminance
if alpha.max() == alpha.min():
    lum = 0.299*rgb[:,:,0] + 0.587*rgb[:,:,1] + 0.114*rgb[:,:,2]
    alpha = 1.0 - lum
    alpha = np.clip(alpha * 3.0, 0, 1)
    print("Created alpha from luminance")

# Find content bbox
ys, xs = np.where(alpha > 0.05)
x0, x1, y0, y1 = xs.min(), xs.max(), ys.min(), ys.max()
print(f"Bbox: x={x0}-{x1}, y={y0}-{y1}")

# Crop with padding
pad = 20
x0c, y0c = max(0, x0-pad), max(0, y0-pad)
x1c, y1c = min(alpha.shape[1], x1+pad), min(alpha.shape[0], y1+pad)
cropped_alpha = alpha[y0c:y1c, x0c:x1c]
cropped_rgb = rgb[y0c:y1c, x0c:x1c]
ch, cw = cropped_alpha.shape
print(f"Cropped: {cw}x{ch}")

# Scale to target
scale = min((SIZE * PADDING) / cw, (SIZE * PADDING) / ch)
dw, dh = int(round(cw * scale)), int(round(ch * scale))
ox, oy = (SIZE - dw) // 2, (SIZE - dh) // 2
print(f"Scaled: {dw}x{dh} at ({ox}, {oy})")

# Resize
alpha_img = Image.fromarray((cropped_alpha * 255).astype(np.uint8))
alpha_resized = alpha_img.resize((dw, dh), Image.LANCZOS)
alpha_final = np.zeros((SIZE, SIZE), np.float32)
alpha_final[oy:oy+dh, ox:ox+dw] = np.asarray(alpha_resized) / 255.0

# ---- Create SOLID SILHOUETTE (fill holes) ----
# Binary fill holes to make solid shape
binary = (alpha_final > 0.1)
solid = ndimage.binary_fill_holes(binary)
solid = ndimage.binary_closing(solid, structure=np.ones((3,3)))

# Smooth anti-aliased edges
inside = ndimage.distance_transform_edt(solid)
outside = ndimage.distance_transform_edt(~solid)
signed = inside - outside
edge_alpha = np.clip(0.5 + signed, 0.0, 1.0)
alpha_final = edge_alpha.astype(np.float32)

print(f"Solid alpha pixels: {(alpha_final > 0.01).sum()}")

# ---- Vertical gradient (per row) matching location pin ----
icon_rows = np.where(alpha_final.max(axis=1) > 0.01)[0]
fy0, fy1 = icon_rows[0], icon_rows[-1]
span = max(fy1 - fy0, 1)
print(f"Gradient span: y={fy0}-{fy1}")

grad = np.zeros((SIZE, SIZE, 3), np.float32)
tr = np.array(GRADIENT_TOP, np.float32) / 255.0
br = np.array(GRADIENT_BOTTOM, np.float32) / 255.0

for y in range(fy0, fy1 + 1):
    t = (y - fy0) / span
    grad[y] = tr + (br - tr) * t

def comp(gr, al, bg):
    a3 = al[:, :, None]
    bg = np.array(bg, np.float32) / 255.0
    return np.clip((a3 * gr + (1 - a3) * bg) * 255, 0, 255).astype(np.uint8)

# Save transparent
trans = np.zeros((SIZE, SIZE, 4), np.uint8)
trans[:, :, :3] = (grad * 255).astype(np.uint8)
trans[:, :, 3] = (alpha_final * 255).astype(np.uint8)
Image.fromarray(trans).save(DST_TRANSPARENT)
print(f"Saved: {DST_TRANSPARENT}")

Image.fromarray(comp(grad, alpha_final, WHITE)).save(DST_WHITE)
print(f"Saved: {DST_WHITE}")

Image.fromarray(comp(grad, alpha_final, GRAY)).save(DST_GRAY)
print(f"Saved: {DST_GRAY}")

# Preview
src_small = src_img.convert("RGB").resize((320, 320), Image.LANCZOS)
tr_img = Image.fromarray(trans[:, :, :3]).resize((320, 320), Image.LANCZOS)
checker = Image.new("RGB", (320, 320), "white")
for y in range(0, 320, 20):
    for x in range(0, 320, 20):
        if (x // 20 + y // 20) % 2 == 0:
            checker.paste((200, 200, 200), (x, y, x+20, y+20))
a_small = Image.fromarray((alpha_final * 255).astype(np.uint8)).resize((320, 320), Image.LANCZOS)
checker.paste(tr_img, (0, 0), a_small.convert("L"))

w_img = Image.fromarray(comp(grad, alpha_final, WHITE)).resize((320, 320), Image.LANCZOS)
g_img = Image.fromarray(comp(grad, alpha_final, GRAY)).resize((320, 320), Image.LANCZOS)

sheet = Image.new("RGB", (1300, 340), "white")
sheet.paste(src_small, (10, 10))
sheet.paste(checker, (340, 10))
sheet.paste(w_img, (670, 10))
sheet.paste(g_img, (1000, 10))

from PIL import ImageDraw, ImageFont
dr = ImageDraw.Draw(sheet)
try:
    f = ImageFont.truetype("arial.ttf", 18)
except:
    f = ImageFont.load_default()
dr.text((10, 310), "Original PNG", fill="black", font=f)
dr.text((340, 310), "Transparent (Gradient)", fill="black", font=f)
dr.text((670, 310), "White", fill="black", font=f)
dr.text((1000, 310), "Gray #e2e8f0", fill="black", font=f)

sheet.save(PREVIEW)
print(f"Preview: {PREVIEW}")

for n, p in [("White", DST_WHITE), ("Gray", DST_GRAY), ("Trans", DST_TRANSPARENT)]:
    c = np.asarray(Image.open(p).convert("RGB"))
    print(f"{n}: {Image.open(p).size}, corners={c[0,0].tolist()}/{c[-1,-1].tolist()}")
    if n == "Trans":
        rgba = np.asarray(Image.open(p).convert("RGBA"))
        print(f"  alpha: {rgba[:,:,3].min()}-{rgba[:,:,3].max()}, non-zero: {(rgba[:,:,3]>0).sum()}")