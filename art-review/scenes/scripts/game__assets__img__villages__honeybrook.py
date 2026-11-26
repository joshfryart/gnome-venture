"""Remove baked creatures from honeybrook backdrop (gnome, bees, birds, duck, fish)."""
from PIL import Image
import numpy as np

SRC = '/home/user/gnome-venture/game/assets/img/villages/honeybrook.png'
OUT = '/home/user/gnome-venture/art-review/scenes/out/game__assets__img__villages__honeybrook.png'
CMP = '/home/user/gnome-venture/art-review/scenes/out/game__assets__img__villages__honeybrook-cmp.png'

im = Image.open(SRC).convert('RGBA')
a = np.array(im)
orig = a.copy()

def px(x, y):
    return orig[y, x].copy()

SKY = px(140, 3)
OUTL = px(66, 60)          # dark outline
WOOD = px(67, 61)          # bridge brown
WOODD = px(67, 64)         # darker grain
GRASS = px(60, 58)
LGRASS = px(60, 52)
WATER = px(110, 92)
DGREEN = px(46, 72)        # dark green (p)
MGREEN = px(57, 62)        # mid green (r)
SPARK = px(98, 45)         # cream (sparkle)
GREY = px(88, 82)
WHITE = px(85, 82)

def same(p, q):
    return tuple(p) == tuple(q)

def left_fill(x0, x1, y0, y1, bad):
    """Replace pixels whose colour is in `bad` with nearest left good pixel in the row."""
    for y in range(y0, y1 + 1):
        for x in range(x0, x1 + 1):
            if any(same(a[y, x], b) for b in bad):
                xx = x - 1
                while any(same(a[y, xx], b) for b in bad):
                    xx -= 1
                a[y, x] = a[y, xx]

# --- birds in sky (blue 'v' shapes) ---
BIRD = px(135, 6)
left_fill(125, 150, 2, 12, [BIRD])

# --- bees over hills (x92-97, y42-46) and (x83-89, y47-51) + sparkles ---
BEE_COLS = [px(94, 42), px(95, 44), px(96, 44), px(94, 45), SPARK, px(84, 50)]
BEE_COLS = [c for c in BEE_COLS]
def fill_box_left(x0, x1, y0, y1):
    for y in range(y0, y1 + 1):
        src = a[y, x0 - 1].copy()
        for x in range(x0, x1 + 1):
            a[y, x] = src
fill_box_left(94, 95, 42, 42)
fill_box_left(93, 96, 43, 43)
fill_box_left(92, 97, 44, 44)
fill_box_left(92, 98, 45, 45)
a[45, 98] = OUTL           # restore roof outline step
fill_box_left(93, 96, 46, 46)
fill_box_left(85, 86, 47, 47)
fill_box_left(89, 89, 47, 47)
fill_box_left(84, 87, 48, 48)
fill_box_left(83, 88, 49, 49)
fill_box_left(83, 88, 50, 50)
fill_box_left(84, 87, 51, 51)
fill_box_left(80, 80, 51, 51)

# --- bee on the thatched roof: copy roof texture from 8 px to the right (period 4) ---
for (x0, x1, y) in [(103, 104, 46), (108, 108, 46), (101, 105, 47), (100, 106, 48),
                    (101, 106, 49), (102, 105, 50), (107, 107, 44)]:
    for x in range(x0, x1 + 1):
        a[y, x] = orig[y, x + 8]

# --- gnome on bridge (x69-78, y51-63) ---
for y in range(51, 60):
    for x in range(68, 80):
        c = a[y, x]
        if not (same(c, GRASS) or same(c, LGRASS)):
            if y <= 53 or (y == 54 and x <= 74):
                a[y, x] = LGRASS
            else:
                a[y, x] = GRASS
# rail: row 60 outline, row 61 wood, row 62 underside / middle post, row 63 post
for x in range(70, 80):
    a[60, x] = OUTL
for x in range(66, 83):
    a[61, x] = WOOD
for x in range(70, 79):
    a[62, x] = GRASS
    a[63, x] = GRASS
for y in (62, 63):
    a[y, 73] = OUTL; a[y, 74] = WOODD; a[y, 75] = OUTL
# little lantern on the middle post (prop where the gnome stood)
LANT = px(83, 54) if False else px(70, 57)  # warm yellow from gnome lantern colour 'k'
GLOW = LANT
DARKAMB = px(71, 60)  # 'm' amber
a[56, 74] = OUTL
for x in (73, 74, 75): a[57, x] = OUTL
a[58, 73] = OUTL; a[58, 74] = GLOW; a[58, 75] = OUTL
a[59, 73] = OUTL; a[59, 74] = DARKAMB; a[59, 75] = OUTL

# --- fish shapes (grey plus shapes) ---
for (cx, cy, fill) in [(48, 68, None), (86, 82, WATER), (100, 90, WATER)]:
    for (dx, dy) in [(0, -1), (-2, 0), (-1, 0), (0, 0), (1, 0), (2, 0), (0, 1)]:
        x, y = cx + dx, cy + dy
        c = a[y, x]
        if same(c, GREY) or same(c, WHITE):
            a[y, x] = GRASS if fill is None else fill

# --- duck (x104-112, y80-86) + wake + bee in water (x116-119, y87-90) ---
for y in range(80, 87):
    for x in range(103, 116):
        c = a[y, x]
        if not (same(c, WATER) or same(c, px(111, 82)) or same(c, px(60, 72))):
            a[y, x] = WATER
a[84, 114] = WATER
for y in range(87, 91):
    for x in range(115, 120):
        a[y, x] = WATER

# lily pad where the duck floated
PAD = MGREEN
PADL = px(56, 62) if False else GRASS
pad = [".pp.pp.",
       "prrqqrp",
       ".ppppp."]
for j, row in enumerate(pad):
    for i, ch in enumerate(row):
        if ch == 'p': a[82 + j, 104 + i] = DGREEN
        elif ch == 'r': a[82 + j, 104 + i] = MGREEN
        elif ch == 'q': a[82 + j, 104 + i] = GRASS
a[82, 108] = px(45, 80) if False else a[82, 108]

out = Image.fromarray(a, 'RGBA')
assert out.size == im.size
out.save(OUT)
w, h = im.size
cmp_ = Image.new('RGBA', (w * 4 + 8, h * 2), (40, 40, 40, 255))
cmp_.paste(im.resize((w * 2, h * 2), Image.NEAREST), (0, 0))
cmp_.paste(out.resize((w * 2, h * 2), Image.NEAREST), (w * 2 + 8, 0))
cmp_.save(CMP)
print('ok', len(set(map(tuple, a.reshape(-1, 4)))), set(a[..., 3].ravel()))
