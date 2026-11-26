"""Redo of game/assets/img/scenes/fight-generic.png (staging only).

The original is a flat placeholder: red debug border, the debug text
"PLACEHOLDER fight backdrop 480x270" and two debug ellipses marking the
fighter spots. This script loads the original, keeps its size/mode and base
palette (sky blue, two grass greens, dark horizon green) and repaints it as a
painted pixel-art meadow: banded sky, clouds, distant hills, treeline, textured
grass, a trampled dirt arena where the two fighters stand, a rock, a small tree
and a fence. Hard edges only, opaque RGB, light from the upper left.
"""
import math
import os
import random
import sys

import numpy as np
from PIL import Image

SRC = "/home/user/gnome-venture/game/assets/img/scenes/fight-generic.png"
OUT_DIR = "/home/user/gnome-venture/art-review/scenes/out"
STEM = "game__assets__img__scenes__fight-generic"

src = Image.open(SRC)
mode, (W, H) = src.mode, src.size
a = np.array(src.convert("RGB")).copy()
rng = random.Random(4711)


def sample(x, y):
    return tuple(int(v) for v in a[y, x])


SKY = sample(240, 50)          # (150,190,215)
HOR = sample(240, 113)         # (80,110,64)
GRASS = sample(240, 150)       # (122,160,96)
GRASS_D = sample(240, 200)     # (104,140,82)


def shade(c, f):
    return tuple(max(0, min(255, int(round(v * f)))) for v in c)


def mix(c, d, t):
    return tuple(int(round(c[i] * (1 - t) + d[i] * t)) for i in range(3))


WARM = (240, 232, 210)
SKY_BANDS = [shade(SKY, .84), shade(SKY, .92), SKY, mix(SKY, WARM, .25), mix(SKY, WARM, .45)]
CL_HI, CL_MID, CL_SH = (238, 236, 226), mix(WARM, SKY, .35), mix(SKY, (200, 200, 222), .55)
MTN_SH, MTN, MTN_HI = mix(SKY, (110, 120, 150), .6), mix(SKY, (120, 135, 160), .45), mix(SKY, WARM, .15)
MTN_HI = mix(MTN, SKY, .5)
TREE_D, TREE_M, TREE_L = HOR, shade(mix(HOR, GRASS, .45), 1.0), mix(GRASS, (190, 200, 120), .2)
OUTL_G = shade(HOR, .72)
GR_HI, GR_LO = mix(GRASS, (200, 210, 130), .22), shade(GRASS, .9)
GD_HI, GD_LO = mix(GRASS_D, GRASS, .6), shade(GRASS_D, .86)
DIRT, DIRT_D, DIRT_L, DIRT_O = (156, 128, 90), (132, 106, 74), (178, 152, 110), (104, 84, 60)
BARK, BARK_D, BARK_L = (128, 96, 66), (98, 72, 50), (156, 122, 86)
OUTL_B = (74, 58, 42)
ROCK, ROCK_D, ROCK_L = (150, 150, 146), (118, 118, 120), (182, 180, 170)
OUTL_R = (82, 80, 84)
FLOWERS = [(232, 206, 120), (226, 160, 150), (240, 236, 222), (186, 170, 218)]

yy, xx = np.mgrid[0:H, 0:W]

# --- sky: wavy horizontal bands --------------------------------------------
HZ = 113  # horizon row of the original
band_edges = [22, 44, 64, 82]
wav = np.array([int(2 * math.sin(x / 23.0) + 1.5 * math.sin(x / 9.0 + 1)) for x in range(W)])
for y in range(HZ):
    for x in range(W):
        yv = y + wav[x]
        k = sum(1 for e in band_edges if yv >= e)
        a[y, x] = SKY_BANDS[k]


def ellipse_mask(cx, cy, rx, ry):
    return ((xx - cx) / rx) ** 2 + ((yy - cy) / ry) ** 2 <= 1.0


def cloud(cx, cy, s):
    parts = [(0, 0, 18, 7), (-14, 3, 11, 5), (14, 2, 13, 6), (-5, -5, 10, 6), (7, -4, 9, 5)]
    m = np.zeros((H, W), bool)
    for dx, dy, rx, ry in parts:
        m |= ellipse_mask(cx + dx * s, cy + dy * s, rx * s, ry * s)
    m &= yy <= cy + 4 * s           # flat bottom
    sh = m & (yy >= cy + 1 * s)
    hi = np.zeros((H, W), bool)
    for dx, dy, rx, ry in parts:
        hi |= ellipse_mask(cx + dx * s - 2 * s, cy + dy * s - 2 * s, rx * s * .8, ry * s * .7)
    hi &= m
    a[m] = CL_MID
    a[sh] = CL_SH
    a[hi & ~sh] = CL_HI


cloud(170, 28, 1.9)
cloud(385, 20, 1.4)
cloud(440, 62, 1.0)
cloud(300, 70, 0.8)

# --- distant hills ------------------------------------------------------------
def ridge(x, base, amp, f, ph):
    return base - amp * (0.6 * math.sin(x / f + ph) + 0.4 * math.sin(x / (f * 0.43) + ph * 2))


for x in range(W):
    top = int(ridge(x, 92, 10, 40, .7))
    for y in range(max(0, top), HZ):
        a[y, x] = MTN
    # lit left-facing slopes: where the ridge rises toward the right
    # left-facing slopes catch the light: lit band between the ridge and a copy shifted right
    lit_bottom = int(ridge(x - 10, 92, 10, 40, .7)) + 1
    for y in range(max(0, top), min(HZ, lit_bottom)):
        a[y, x] = MTN_HI
    if top >= 0:
        a[top, x] = MTN_SH if x % 2 == 0 and False else a[top, x]

# --- treeline: bumpy dark green crowns along the horizon ------------------------
bumps = []
x = -6
while x < W + 6:
    r = rng.randint(5, 9)
    bumps.append((x, HZ - rng.randint(4, 9), r))
    x += rng.randint(6, 11)
tl = np.zeros((H, W), bool)
for cx, cy, r in bumps:
    tl |= ellipse_mask(cx, cy, r, r * .8)
tl |= (yy >= HZ - 4) & (yy < HZ)
tl &= yy < HZ
a[tl] = TREE_M
for cx, cy, r in bumps:   # light on the upper-left of each crown
    hm = ellipse_mask(cx - 2, cy - 2, r * .55, r * .45) & tl
    a[hm] = TREE_L
shadow = tl & (yy >= HZ - 3)
a[shadow] = TREE_D
# 1px darker rim on top of treeline
edge = tl & ~np.roll(tl, 1, axis=0)
a[edge] = TREE_D
a[HZ:HZ + 2, :] = HOR

# --- grass fields -------------------------------------------------------------
FG = 194
fgw = np.array([FG + int(3 * math.sin(x / 31.0) + 2 * math.sin(x / 11.0 + 2)) for x in range(W)])
for x in range(W):
    a[HZ + 2:fgw[x], x] = GRASS
    a[fgw[x]:, x] = GRASS_D
    a[fgw[x], x] = GD_HI


def tuft(x, y, c_hi, c_lo, h):
    pts = [(0, 0), (0, -1), (-1, -1), (1, -1)] + ([(0, -2), (-1, -2), (1, -2), (-2, -2), (2, -3)] if h > 2 else [])
    for dx, dy in pts:
        X, Y = x + dx, y + dy
        if 0 <= X < W and 0 <= Y < H:
            a[Y, X] = c_lo if dy == 0 else c_hi


def speck(x, y, c, w=2):
    if 0 <= x < W - w and 0 <= y < H:
        a[y, x:x + w] = c


# mid field: short horizontal strokes, denser toward the bottom
for _ in range(520):
    y = rng.randint(HZ + 3, FG - 2)
    x = rng.randint(0, W - 3)
    speck(x, y, GR_HI if rng.random() < .55 else GR_LO, rng.choice([1, 2, 2, 3]))
for _ in range(60):
    tuft(rng.randint(2, W - 3), rng.randint(HZ + 20, FG - 2), GR_HI, GR_LO, 2)

# --- fence on the mid-right ----------------------------------------------------
fy = HZ + 14
for x in range(300, 478):
    a[fy, x] = BARK_L
    a[fy + 1, x] = BARK_D
    a[fy + 5, x] = BARK_L
    a[fy + 6, x] = BARK_D
for px in range(302, 478, 14):
    a[fy - 3:fy + 10, px:px + 2] = BARK
    a[fy - 3:fy + 10, px] = BARK_L
    a[fy - 3, px:px + 2] = BARK_L
    a[fy + 10, px - 1:px + 3] = GR_LO

# --- foreground texture --------------------------------------------------------
for _ in range(700):
    y = rng.randint(FG + 4, H - 1)
    x = rng.randint(0, W - 3)
    speck(x, y, GD_HI if rng.random() < .5 else GD_LO, rng.choice([1, 2, 2, 3]))

# --- dirt arena where the fighters stand ---------------------------------------
arena = np.zeros((H, W), bool)
for cx, cy, rx, ry in [(120, 217, 46, 12), (360, 217, 46, 12), (240, 220, 110, 10),
                       (180, 214, 40, 9), (300, 223, 40, 8)]:
    arena |= ellipse_mask(cx, cy, rx, ry)
# ragged edge: nibble the border in 2x1 steps
nib = np.zeros((H, W), bool)
for _ in range(500):
    x, y = rng.randint(50, 430), rng.randint(198, 236)
    nib[y, x:x + rng.randint(2, 4)] = True
border = arena & ~(np.roll(arena, 2, 0) & np.roll(arena, -2, 0) & np.roll(arena, 3, 1) & np.roll(arena, -3, 1))
arena &= ~(nib & border)
a[arena] = DIRT
# underside shade and top-left light
low = arena & ~np.roll(arena, -2, axis=0)
a[low] = DIRT_D
top = arena & ~np.roll(arena, 1, axis=0)
a[top] = DIRT_O
top2 = arena & ~np.roll(arena, 2, axis=0) & ~top
a[top2] = DIRT_D
for _ in range(220):
    x, y = rng.randint(60, 420), rng.randint(204, 234)
    if arena[y, x] and arena[y, min(W - 1, x + 2)]:
        a[y, x:x + 2] = DIRT_L if rng.random() < .55 else DIRT_D
# a few pebbles
for _ in range(14):
    x, y = rng.randint(70, 410), rng.randint(206, 232)
    if arena[y, x] and arena[y + 1, x + 1]:
        a[y, x:x + 2] = ROCK_L
        a[y + 1, x:x + 2] = ROCK_D

# --- tree on the left ----------------------------------------------------------
tx = 36
trunk = (xx >= tx - 5 + (yy < 160)) & (xx <= tx + 5 - (yy < 160)) & (yy >= 110) & (yy <= 206)
roots = ellipse_mask(tx, 206, 12, 4) & (yy <= 206)
tm = trunk | roots
a[tm] = BARK
a[tm & (xx <= tx - 2)] = BARK_L
a[tm & (xx >= tx + 3)] = BARK_D
for y in range(128, 204, 9):
    a[y, tx - 1:tx + 2] = BARK_D
out = tm & ~(np.roll(tm, 1, 1) & np.roll(tm, -1, 1) & np.roll(tm, 1, 0) & np.roll(tm, -1, 0))
a[out] = OUTL_B
crown = np.zeros((H, W), bool)
blobs = [(tx, 100, 36, 26), (tx - 28, 116, 20, 14), (tx + 30, 114, 22, 15), (tx - 8, 76, 24, 16), (tx + 18, 84, 20, 14), (tx + 4, 124, 22, 10)]
for cx, cy, rx, ry in blobs:
    crown |= ellipse_mask(cx, cy, rx, ry)
a[crown] = TREE_M
for cx, cy, rx, ry in blobs:
    a[ellipse_mask(cx - 4, cy - 4, rx * .6, ry * .55) & crown] = TREE_L
under = crown & ~np.roll(crown, -3, axis=0)
a[under] = TREE_D
for _ in range(90):   # leaf clusters
    x, y = rng.randint(0, tx + 52), rng.randint(60, 134)
    if 0 <= x < W - 2 and crown[y, x] and crown[y, x + 2]:
        a[y, x:x + 2] = TREE_D if y > 104 or rng.random() < .4 else TREE_L
cout = crown & ~(np.roll(crown, 1, 1) & np.roll(crown, -1, 1) & np.roll(crown, 1, 0) & np.roll(crown, -1, 0))
a[cout] = OUTL_G
# trunk shadow on grass
sh = ellipse_mask(tx + 10, 207, 18, 3) & ~tm & ~arena
a[sh] = GD_LO

# --- rock on the right ---------------------------------------------------------
rk = np.zeros((H, W), bool)
for cx, cy, rx, ry in [(446, 206, 22, 16), (428, 214, 12, 8), (462, 214, 14, 9)]:
    rk |= ellipse_mask(cx, cy, rx, ry)
rk &= yy <= 220
a[ellipse_mask(448, 221, 30, 3) & ~rk] = GD_LO
a[rk] = ROCK
a[rk & ellipse_mask(438, 198, 14, 8)] = ROCK_L
a[rk & (yy >= 214)] = ROCK_D
for y0, x0, x1 in [(204, 448, 456), (210, 440, 446), (212, 456, 464)]:
    a[y0, x0:x1] = ROCK_D
moss = rk & ellipse_mask(450, 190, 14, 4) & (yy <= 192)
a[moss] = GR_HI
rout = rk & ~(np.roll(rk, 1, 1) & np.roll(rk, -1, 1) & np.roll(rk, 1, 0) & np.roll(rk, -1, 0))
a[rout] = OUTL_R

# --- flowers and foreground tufts ----------------------------------------------
for _ in range(70):
    x, y = rng.randint(2, W - 3), rng.randint(FG + 4, H - 2)
    if not (arena[y, x] or rk[y, x] or tm[y, x]):
        c = rng.choice(FLOWERS)
        a[y, x] = c
        if rng.random() < .4 and not arena[y, x + 1]:
            a[y, x + 1] = c
for _ in range(40):
    x, y = rng.randint(2, W - 3), rng.randint(FG + 3, H - 1)
    if not (arena[max(0, y - 3):y + 1, max(0, x - 2):x + 3].any() or rk[y, x] or tm[y, x]):
        tuft(x, y, GD_HI, GD_LO, 3)
# tall grass clumps in the bottom corners (frame the stage)
for base_x, n in [(4, 14), (436, 14)]:
    for i in range(n):
        x = base_x + i * 3 + rng.randint(-1, 1)
        h = rng.randint(10, 20)
        lean = rng.choice([-1, 1])
        for k in range(h):
            X = x + (lean * k) // 6
            Y = H - 1 - k
            if 0 <= X < W:
                a[Y, X] = OUTL_G if k < h // 2 else GD_HI

res = Image.fromarray(a, "RGB")
if mode != "RGB":
    res = res.convert(mode)
assert res.size == (W, H)
os.makedirs(OUT_DIR, exist_ok=True)
out = os.path.join(OUT_DIR, STEM + ".png")
res.save(out)
cmp = Image.new("RGB", (W * 4 + 8, H * 2), (40, 40, 40))
cmp.paste(src.convert("RGB").resize((W * 2, H * 2), Image.NEAREST), (0, 0))
cmp.paste(res.convert("RGB").resize((W * 2, H * 2), Image.NEAREST), (W * 2 + 8, 0))
cmp.save(os.path.join(OUT_DIR, STEM + "-cmp.png"))
print(out, res.mode, res.size, len(res.getcolors(1 << 20)))
