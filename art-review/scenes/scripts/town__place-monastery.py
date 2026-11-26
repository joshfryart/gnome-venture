"""Remove baked-in gnome + satchel from place-monastery; add a wooden bench."""
from PIL import Image
import numpy as np

SRC = "/home/user/gnome-venture/game/assets/img/town/place-monastery.png"
OUT = "/home/user/gnome-venture/art-review/scenes/out/town__place-monastery.png"
CMP = "/home/user/gnome-venture/art-review/scenes/out/town__place-monastery-cmp.png"

im = Image.open(SRC)
mode, size = im.mode, im.size
a = np.array(im.convert("RGBA"))

LIGHT = (170, 170, 178, 255)   # mountain ridge highlight
ROCK = tuple(a[60, 70])        # mountain body (138,138,146)
BASE = tuple(a[81, 70])        # mountain shadow base (98,98,108)
OUTL = (42, 26, 16, 255)       # existing dark outline
WOOD = (116, 70, 42, 255)
WOOD_D = (90, 58, 34, 255)

# 1. erase gnome and satchel: x 26..55, y 48..83, right of the ridge highlight
for y in range(48, 84):
    xs = [x for x in range(8, 60) if tuple(a[y, x]) == LIGHT]
    start = max(26, (max(xs) + 1) if xs else 26)
    for x in range(start, 56):
        a[y, x] = BASE if y >= 80 else ROCK

# 2. wooden bench, drawn on the 2x2 cell grid of the art
def cell(hx, hy, c):
    a[hy*2:hy*2+2, hx*2:hx*2+2] = c

# backrest plank
for hx in range(15, 26):
    cell(hx, 32, OUTL); cell(hx, 34, OUTL)
    cell(hx, 33, WOOD if 15 < hx < 25 else OUTL)
# seat plank
for hx in range(15, 26):
    cell(hx, 36, OUTL); cell(hx, 38, OUTL)
    cell(hx, 37, WOOD if 15 < hx < 25 else OUTL)
# posts (backrest supports) and legs
for hy in (35, 39, 40, 41):
    for lx in (16, 22):
        cell(lx, hy, OUTL); cell(lx + 1, hy, WOOD_D); cell(lx + 2, hy, OUTL)

out = Image.fromarray(a, "RGBA").convert(mode)
assert out.size == size
out.save(OUT)

w, h = size
cmp = Image.new("RGBA", (w * 4 + 8, h * 2), (0, 0, 0, 255))
cmp.paste(im.convert("RGBA").resize((w * 2, h * 2), Image.NEAREST), (0, 0))
cmp.paste(out.convert("RGBA").resize((w * 2, h * 2), Image.NEAREST), (w * 2 + 8, 0))
cmp.save(CMP)
