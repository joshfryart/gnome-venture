"""Remove the baked-in gnome from town/place-board.png and put a small tree stump in its place."""
from PIL import Image
import numpy as np

SRC = "/home/user/gnome-venture/game/assets/img/town/place-board.png"
OUT = "/home/user/gnome-venture/art-review/scenes/out/town__place-board.png"
CMP = "/home/user/gnome-venture/art-review/scenes/out/town__place-board-cmp.png"

im = Image.open(SRC)
mode = im.mode
a = np.array(im.convert("RGBA"))

SKY = (207, 232, 230, 255)
HILL = (94, 138, 68, 255)
LIGHT = (156, 192, 112, 255)
GRASS = (126, 168, 90, 255)
OUTL = (74, 44, 26, 255)
WOOD = (138, 90, 46, 255)
SHADE = (90, 58, 30, 255)
TOP = (192, 138, 82, 255)
RING = (160, 106, 58, 255)


def hill_top(x):
    # left hill top at y52, steps down toward the right hill (y56/y58)
    if x < 36:
        return 52
    if x < 44:
        return 54
    if x < 50:
        return 56
    return 58


# 1. rebuild background where the gnome stood (x 24..49, y 46..85)
for y in range(46, 86):
    for x in range(24, 50):
        if y < hill_top(x):
            c = SKY
        elif y < 82:
            c = HILL
        elif y < 84:
            c = LIGHT
        else:
            c = GRASS
        a[y, x] = c

# 2. tree stump prop, drawn in 2px blocks like the rest of the image
X0, Y0 = 28, 74  # top-left in pixels
stump = [
    "..OOOOO..",
    ".OTTRTTO.",
    ".OTRTRTO.",
    ".OWTTTSO.",
    ".OWWWSSO.",
    ".OWWWSSO.",
    "OOWWWSSOO",
]
pal = {"O": OUTL, "T": TOP, "R": RING, "W": WOOD, "S": SHADE}
for r, row in enumerate(stump):
    for c, ch in enumerate(row):
        if ch in pal:
            yy, xx = Y0 + r * 2 - 2, X0 + c * 2 - 4
            a[yy:yy + 2, xx:xx + 2] = pal[ch]

out = Image.fromarray(a, "RGBA").convert(mode)
out.save(OUT)

w, h = im.size
cmp = Image.new("RGBA", (w * 4 + 8, h * 2), (40, 40, 40, 255))
cmp.paste(im.convert("RGBA").resize((w * 2, h * 2), Image.NEAREST), (0, 0))
cmp.paste(out.convert("RGBA").resize((w * 2, h * 2), Image.NEAREST), (w * 2 + 8, 0))
cmp.save(CMP)
