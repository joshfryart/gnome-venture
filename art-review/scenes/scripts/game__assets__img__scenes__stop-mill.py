"""Remove the two baked-in ducks from the mill stream; rebuild bank edge, grass and water."""
from PIL import Image
import numpy as np

SRC = "/home/user/gnome-venture/game/assets/img/scenes/stop-mill.png"
OUT = "/home/user/gnome-venture/art-review/scenes/out/game__assets__img__scenes__stop-mill.png"
CMP = "/home/user/gnome-venture/art-review/scenes/out/game__assets__img__scenes__stop-mill-cmp.png"

orig = Image.open(SRC)
mode = orig.mode
a = np.array(orig.convert("RGBA"))
src = a.copy()

GRASS = src[205, 440].copy()
WATER = src[230, 390].copy()
DARK = src[201, 379].copy()
LIGHT = src[238, 395].copy()

# bank-edge top row per column (continues the original staircase)
t = {}
for x, v in [(396, 212), (397, 212), (398, 212), (399, 212), (400, 214), (401, 214),
             (402, 216), (403, 216)] + [(x, 220) for x in range(404, 410)]:
    t[x] = v
for i, x in enumerate(range(410, 422)):
    t[x] = 222 + 2 * (i // 2)
for x in range(422, 424): t[x] = 234
for x in range(424, 428): t[x] = 234
for x in range(428, 430): t[x] = 236
for x in range(430, 434): t[x] = 238
for x in range(434, 450): t[x] = 240
for x in range(450, 456): t[x] = 242
for x in range(456, 460): t[x] = 244

def band_end(x):
    n = t.get(x + 2, t[x])
    return (n + 1) if n - t[x] <= 2 else t[x] + 1

boxes = [(398, 214, 428, 238), (426, 228, 458, 254)]  # x0,y0,x1(excl),y1(excl)
for x0, y0, x1, y1 in boxes:
    for y in range(y0, y1):
        for x in range(x0, x1):
            if (src[y, x, :3] == LIGHT[:3]).all():
                continue  # keep existing water sparkle streaks
            if y < t[x]:
                a[y, x] = GRASS
            elif y <= band_end(x):
                a[y, x] = DARK
            else:
                a[y, x] = WATER

# a couple of sparkle streaks where the ducks floated, matching existing ones
for y, xs in [(244, range(404, 412)), (245, range(404, 412)), (250, range(436, 444)), (251, range(436, 444))]:
    for x in xs:
        if (a[y, x, :3] == WATER[:3]).all():
            a[y, x] = LIGHT

out = Image.fromarray(a, "RGBA")
if mode != "RGBA":
    out = out.convert(mode)
out.save(OUT)

w, h = orig.size
cmp_ = Image.new("RGBA", (w * 4 + 8, h * 2), (0, 0, 0, 255))
cmp_.paste(orig.convert("RGBA").resize((w * 2, h * 2), Image.NEAREST), (0, 0))
cmp_.paste(out.convert("RGBA").resize((w * 2, h * 2), Image.NEAREST), (w * 2 + 8, 0))
cmp_.save(CMP)
