"""Remove baked creatures from welcome/stage-backdrop.png (staging only).

Removes: 3 birds in the sky, a butterfly over the left meadow, the frog sitting
on the big front-left toadstool (cap top redrawn), and the purple-eyed bug face
on the right toadstool cluster (repainted as plain cap).
"""
from PIL import Image
import numpy as np

SRC = "/home/user/gnome-venture/game/assets/img/welcome/stage-backdrop.png"
OUT = "/home/user/gnome-venture/art-review/scenes/out/game__assets__img__welcome__stage-backdrop.png"
CMP = "/home/user/gnome-venture/art-review/scenes/out/game__assets__img__welcome__stage-backdrop-cmp.png"

im = Image.open(SRC)
mode, size = im.mode, im.size
a = np.array(im.convert("RGBA"))
rgb = a[..., :3]

# --- birds: sky only (y < 40). Fill each bird pixel with nearest non-bird pixel to its left.
BIRD = np.array([116, 117, 140])
for y in range(0, 40):
    for x in range(size[0]):
        if (rgb[y, x] == BIRD).all():
            sx = x - 1
            while sx >= 0 and (rgb[y, sx] == BIRD).all():
                sx -= 1
            a[y, x] = a[y, sx]

# --- butterfly (x52-61, y138-141): wing/body colours -> meadow base green
GRASS = [124, 195, 90, 255]
butter = {(255, 227, 138), (245, 184, 46), (217, 131, 34), (43, 28, 38)}
for y in range(138, 142):
    for x in range(52, 62):
        if tuple(int(v) for v in a[y, x, :3]) in butter:
            a[y, x] = GRASS

# --- frog on big toadstool (x14-39, y172-189)
orig = a.copy()
OUTL = [43, 28, 38, 255]
LITE = [255, 138, 92, 255]
RED = [232, 73, 59, 255]
# grass fill: tile the clean grass texture of columns 0..13 (same rows)
for y in range(172, 190):
    for x in range(14, 40):
        a[y, x] = orig[y, (x - 14) % 14]
# cap top outline per 2px column pair (dome rising toward x38 where cap top is y182)
top = {18: 190, 20: 188, 22: 188, 24: 186, 26: 186, 28: 186,
       30: 184, 32: 184, 34: 184, 36: 184, 38: 182}
for x0, ty in top.items():
    for x in (x0, x0 + 1):
        if ty >= 190:
            continue  # existing outline row already there
        for y in range(ty, 190):
            if x >= 38:
                continue  # x38-39 keep original from y182 down
            if y < ty + 2:
                a[y, x] = OUTL
            elif y < ty + 4:
                a[y, x] = LITE
            else:
                a[y, x] = RED
# restore original x38-39 below y182 except frog belly/body colours
for y in range(182, 190):
    for x in (38, 39):
        a[y, x] = orig[y, x] if y >= 184 else OUTL
a[182:184, 38:40] = OUTL  # x38-39 behaves like x40: outline y182, highlight, red
a[184:186, 38:40] = LITE
a[186:190, 38:40] = RED
# small cream spot on the newly exposed cap
a[188:190, 26:30] = [255, 244, 214, 255]

# --- bug face on right toadstool (x316-325, y150-153): eyes -> cap red, keep highlight
for y in range(150, 154):
    for x in range(316, 326):
        c = tuple(int(v) for v in a[y, x, :3])
        if c in {(201, 178, 240), (138, 111, 208), (90, 69, 158), (43, 28, 38)}:
            a[y, x] = RED

out = Image.fromarray(a, "RGBA")
if mode != "RGBA":
    out = out.convert(mode)
assert out.size == size
out.save(OUT)

w, h = size
cmp_img = Image.new("RGBA", (w * 4 + 8, h * 2), (40, 40, 40, 255))
cmp_img.paste(im.convert("RGBA").resize((w * 2, h * 2), Image.NEAREST), (0, 0))
cmp_img.paste(out.convert("RGBA").resize((w * 2, h * 2), Image.NEAREST), (w * 2 + 8, 0))
cmp_img.save(CMP)
print("ok", mode, size)
