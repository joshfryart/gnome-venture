"""Jigsaw picture: THORNACRE SAVANNA (draft v0): game/assets/img/jigsaw/thornacre.jpg (+ -thumb). Usage: python3 -B aseprite-source/scenes-pil/jigsaw_thornacre.py [outdir]
Sunrise on the savanna: banded gold-orange sky with a half-risen sun and streaky clouds, Snowcrown Peak glowing pink on the far right-centre,
the Great Migration snaking across the far plain, a granite kopje with a carved stone-head watcher and a gnome with a spyglass (left),
two giraffes browsing a flat-topped acacia hung with weaver nests, a thatched round-hut village with the Coffee Ceremony Hut (a gnome roasting
beans, a clay coffee pot and three cups on fresh grass), the Baobab Inn (right), red termite mounds and a waterhole with flamingos (front left),
a red-clay path, and zebras and wildebeest crossing the front right.
"""
import sys

from jigsaw_common import *  # noqa: F401,F403

# palette: gold grass, umber, sky-orange, red clay (four dominant), plus small accents
GOLD = ramp('#e8a317', '#b07a10', '#f5cf6a')
GRASS = ramp('#e2a93e', '#c08a2a', '#f2c86a')
DGRASS = ramp('#cf8f2c', '#a8701c', '#e8b04a')
UMBER = ramp('#7a4a1f', '#5c3420', '#9a6b3f')
BARK = ramp('#8a6a52', '#6a4e3c', '#ab8a6e')
CLAY = ramp('#b8502a', '#8a3a1f', '#d9764a')
THATCH = ramp('#d9a35a', '#a8743a', '#f2cf8a')
MUD = ramp('#c9875a', '#9a603a', '#e2a87a')
GRANITE = ramp('#b9a088', '#8a7464', '#dccab0')
LEAF = ramp('#7a8a3a', '#55652a', '#a4b05a')
SKIN = ramp('#f2c8a0', '#d9a07a', '#fff0d8')
BEARD = ramp('#f1ece0', '#c9c5bc', '#ffffff')
TEAL = ramp('#3f8fb0', '#25637d', '#a9d6ea')
GREENT = ramp('#4f9a45', '#2f6a3a', '#7ab55c')
RED = ramp('#d6322b', '#a8241f', '#f08a24')
PURP = ramp('#7a5cc0', '#4e3a8a', '#c3b2ea')
GIR = ramp('#f0b048', '#c98a2a', '#f8d88a')
ZEB = ramp('#f1ece0', '#c9c5bc', '#ffffff')
WILD = ramp('#6a5a52', '#4a3c36', '#8a7a70')
PINK = ramp('#f08aa0', '#c8607a', '#f8c0c8')
WATER = ramp('#4f93b8', '#2f6f92', '#8cc4dc')
DARK = '#2a1a10'

cv = new_canvas('#8fbfd6')
r = rnd(1717)
r2 = rnd(4242)


def shadow(x0, y0, x1, y1, col=None):
    cv.fill(ell(x0, y0, x1, y1), col or GRASS['s'])


def wavy(y, amp, ph, step=12):
    """Polygon mask of everything below a gently waving line at height y (a sky band edge)."""
    pts = []
    for x in range(-step, W + step + 1, step):
        k = ((x // step) + ph) % 4
        pts.append((x, y + (0, amp, 0, -amp)[k]))
    return poly(pts + [(W + step, H), (-step, H)])


# ---------------------------------------------------------------- sky bands (dawn: pale blue top to sky-orange at the horizon)
for y, col, ph in ((12, '#b9d3d6', 0), (24, '#f2dcb0', 1), (40, '#f5c88a', 2), (56, '#f5b46a', 3), (72, '#f29a4a', 0)):
    cv.fill(wavy(y, 2, ph), col)

# sun rays (alternating hard wedges) then the half-risen sun
SX, SY = 70, 90
import math  # noqa: E402
for k in range(14):
    a0 = math.pi + k * math.pi / 14
    a1 = a0 + math.pi / 30
    rays = poly([(SX, SY), (SX + 200 * math.cos(a0), SY + 200 * math.sin(a0)), (SX + 200 * math.cos(a1), SY + 200 * math.sin(a1))])
    cv.fill(rays & rect(0, 30, W, 92) & ~ell(SX - 60, SY - 60, SX + 60, SY + 60) | (rays & ell(SX - 60, SY - 60, SX + 60, SY + 60) & rect(0, 0, W, 92)), '#f8c870' if k % 2 else '#f8d890')
cv.fill(ell(SX - 26, SY - 26, SX + 26, SY + 26) & ~ell(SX - 24, SY - 24, SX + 24, SY + 24), '#fbe0a0')   # halo ring
sun = ell(SX - 18, SY - 18, SX + 18, SY + 18)
cv.fill(sun, '#ffe58a')
cv.fill(sun & ~shift(sun, 2, 2), '#fff4c8')
for k, yy in enumerate((76, 80, 84)):   # warm bars across the sun
    cv.fill(sun & rect(0, yy, W, yy), '#f8c860')

# streaky clouds with pink-orange bellies
CLOUDS = ((30, 8, 46), (120, 16, 60), (210, 6, 50), (272, 22, 36), (88, 36, 40), (160, 48, 44), (14, 52, 30), (246, 44, 40), (128, 62, 30), (290, 66, 24), (186, 28, 26))
for cx, cy, w in CLOUDS:
    m = ell(cx - w // 2, cy - 3, cx + w // 2, cy + 3) | ell(cx - w // 4, cy - 6, cx + w // 6, cy + 2) | ell(cx + w // 8, cy - 5, cx + w // 2 - 4, cy + 2)
    cv.fill(m, '#fbe6c8')
    cv.fill(m & ~shift(m, 0, -2), '#f0a080')   # warm underside
    cv.fill(m & ~shift(m, 0, -1), '#d9705a')
    cv.fill(m & ~shift(m, 2, 1) & ~shift(m, 0, 1), '#fff6e4')   # lit top-left rim
for bx, by in ((60, 20), (66, 17), (72, 21), (54, 24), (78, 25), (150, 6), (156, 9), (236, 30), (242, 33), (104, 50), (196, 14)):   # birds (a flock of storks heading out)
    cv.dots([(bx, by), (bx + 1, by - 1), (bx + 2, by), (bx + 3, by - 1), (bx + 4, by)], '#5c3420')
# a vulture circling high on the right
cv.fill(line([(270, 6), (276, 9), (280, 8), (284, 9), (290, 6)], 2), '#4a3c36')

# ---------------------------------------------------------------- Snowcrown Peak (right-centre), glowing pink at dawn
peak = poly([(120, 96), (168, 52), (180, 40), (196, 36), (210, 40), (226, 54), (262, 80), (300, 92), (300, 98), (120, 98)])
cv.fill(peak, '#9a7a8a')
cv.fill(peak & ~shift(peak, -4, 0) & rect(196, 0, W, H), '#7a5c70')   # shaded right flank
for gx0, gy0, gx1, gy1 in ((186, 52, 194, 80), (214, 56, 220, 82), (200, 60, 204, 88), (238, 68, 244, 86)):   # gullies
    cv.fill(line([(gx0, gy0), (gx1, gy1)]) & peak, '#7a5c70')
snow = peak & poly([(150, 70), (170, 54), (180, 46), (196, 44), (210, 48), (230, 60), (220, 62), (208, 56), (200, 62), (192, 56), (184, 62), (172, 60), (162, 68)])
snow |= peak & rect(160, 0, 240, 47)
cv.fill(snow, '#fbe0d8')
cv.fill(snow & ~shift(snow, -3, 0) & rect(200, 0, W, H), '#e0b0b8')
cv.fill(snow & ~shift(snow, 0, 1) & rect(0, 0, 199, H), '#ffffff')
lowhill = poly([(0, 94), (40, 86), (90, 92), (130, 84), (170, 92), (200, 88), (260, 90), (300, 86), (300, 100), (0, 100)])
cv.fill(lowhill, '#c98a6a')
cv.fill(lowhill & ~shift(lowhill, 0, 2), '#e0a07a')

# ---------------------------------------------------------------- far plain with the Great Migration and far acacias
plain = rect(0, 94, W - 1, H - 1)
cv.fill(rect(0, 94, W - 1, 112), '#e8b45a')
cv.fill(rect(0, 94, W - 1, 95), '#d99a4a')
x = 0
while x < W:   # far acacia silhouettes: little flat tops on stalks
    x += r(10, 30)
    ty = 92 + r(0, 4)
    w = r(5, 9)
    cv.fill(rect(x, ty, x, ty + 5), '#6a4a3a')
    cv.fill(rect(x - w // 2, ty - 1, x + w // 2, ty), '#6a5a3a')
    cv.dots([(x - w // 2 - 1, ty)], '#6a5a3a')
# the herd: a long dark ribbon of tiny animals with dust above it
herd_y = lambda xx: 104 + int(4 * math.sin(xx / 22.0)) - (xx // 60)   # noqa: E731
for k in range(260):
    hx = r(0, W - 1)
    hy = herd_y(hx) + r(-2, 2)
    col = ('#4a3c36', '#5c3420', '#3d2a1c', '#f1ece0')[r(0, 3)] if r(0, 5) else '#2a1a10'
    cv.dots([(hx, hy), (hx + 1, hy), (hx + 2, hy), (hx, hy + 1), (hx + 2, hy + 1), (hx + 2, hy - 1)], col)
for k in range(40):
    dx = r(0, W - 1)
    dy = herd_y(dx) - r(3, 6)
    cv.fill(ell(dx - 4, dy - 1, dx + 4, dy + 1), '#f2c88a')

# ---------------------------------------------------------------- savanna grass (mid and front) with tufts
cv.fill(rect(0, 110, W - 1, H - 1), GRASS['b'])
cv.fill(wavy(146, 3, 1, 16), DGRASS['b'])
for y in range(108, H):
    for _ in range(9):
        gx = r(0, W - 1)
        front = y >= 146
        c = (DGRASS['s'] if r(0, 2) else DGRASS['r']) if front else (GRASS['s'] if r(0, 2) else GRASS['r'])
        if front:
            cv.dots([(gx, y), (gx, y - 1), (gx, y - 2), (gx + 1, y - 1), (gx - 1, y - 1)], c)
        else:
            cv.dots([(gx, y), (gx, y - 1)], c)

# ---------------------------------------------------------------- red clay path from the front edge up to the village
path = poly([(150, 156), (168, 156), (164, 166), (154, 176), (150, 186), (156, 199), (124, 199), (126, 186), (136, 174), (146, 164)])
cv.fill(path, CLAY['b'])
cv.fill(path & ~shift(path, -2, 0), CLAY['s'])
cv.fill(path & ~shift(path, 2, 0), CLAY['r'])
for _ in range(50):
    px, py = r(120, 170), r(156, 199)
    if path[py, px]:
        cv.dots([(px, py)], ('#8a3a1f', '#d9764a', '#9a603a')[r(0, 2)])


# ---------------------------------------------------------------- flat-topped acacia with weaver nests (behind the giraffes)
def acacia(tx, ty, top, hw, nests=0):
    """A flat-topped acacia: forked trunk from (tx, ty) up to a wide flat canopy at `top`."""
    o = cv.obj()
    o.part(line([(tx, ty), (tx, ty - 14), (tx - hw // 2, top + 6)], 3) | line([(tx, ty - 14), (tx + hw // 2, top + 5)], 3) | line([(tx, ty - 22), (tx + 4, top + 4)], 2), BARK, d=1)
    o.part(rect(tx - 2, ty - 16, tx + 2, ty), BARK, d=1)
    o.draw()
    can = blank()
    for k in range(9):
        cx = tx - hw + k * hw // 4 + r(-3, 3)
        can |= ell(cx - 9, top + r(-2, 1), cx + 9, top + 7 + r(0, 2))
    can &= rect(tx - hw - 4, top - 4, tx + hw + 4, top + 10)
    o = cv.obj()
    o.part(can, LEAF, d=2)
    o.draw()
    ys, xs = np.nonzero(can)
    for k in range(int(len(xs) / 14)):
        i = r(0, len(xs) - 1)
        cv.dots([(int(xs[i]), int(ys[i])), (int(xs[i]) + 1, int(ys[i]))], LEAF['r'] if k % 3 else '#c9a96e')
    cv.fill(can & ~shift(can, 0, -1), LEAF['s'])
    for k in range(nests):   # woven ball nests hanging on twigs, a yellow weaver at the door
        nx = tx - hw + 8 + k * (2 * hw - 16) // max(1, nests - 1)
        ny = top + 14 + (k % 2) * 4
        cv.fill(rect(nx + 2, top + 8, nx + 2, ny - 1), BARK['s'])
        o = cv.obj()
        o.part(ell(nx - 2, ny - 1, nx + 6, ny + 6), THATCH, d=1)
        o.draw()
        cv.dots([(nx + 1, ny + 5), (nx + 2, ny + 6), (nx + 3, ny + 5)], DARK)
        cv.dots([(nx, ny + 2), (nx + 4, ny + 1)], THATCH['s'])
        if k % 2 == 0:
            cv.fill(rect(nx + 6, ny + 2, nx + 8, ny + 4), '#f5d020')
            cv.dots([(nx + 9, ny + 3)], '#3d2a1c')
            cv.dots([(nx + 7, ny + 2)], DARK)


acacia(120, 122, 58, 34, nests=5)


# ---------------------------------------------------------------- giraffes browsing the acacia
def giraffe(x, y, f, h=62):
    """Giraffe with feet at y, facing f (+1 right / -1 left)."""
    by = y - 30
    body = ell(x - 14, by - 7, x + 14, by + 7)
    legs = blank()
    for lx in (-11, -6, 6, 11):
        legs |= rect(x + lx * f - 1, by + 2, x + lx * f + 1, y)
    neck = poly([(x + 8 * f, by - 4), (x + 13 * f, by - 2), (x + 22 * f, by - h + 34), (x + 17 * f, by - h + 32)])
    head = ell(min(x + 16 * f, x + 30 * f), by - h + 26, max(x + 16 * f, x + 30 * f), by - h + 33)
    o = cv.obj()
    o.part(legs, GIR, d=1)
    o.part(body | neck, GIR, d=2)
    o.part(head, GIR, d=1)
    o.part(line([(x - 14 * f, by - 2), (x - 18 * f, by + 10)]), GIR, d=0)
    o.draw()
    blob = body | neck
    ys, xs = np.nonzero(blob & ~shift(blob, 0, 0) | blob)
    for k in range(26):   # patches
        i = r2(0, len(xs) - 1)
        px, py = int(xs[i]), int(ys[i])
        pm = rect(px, py, px + 2, py + 1) | rect(px + 1, py + 2, px + 2, py + 2)
        cv.fill(pm & blob & ~shift(~blob, 1, 1) & ~shift(~blob, -1, -1), '#9a5a24')
    for lx in (-11, -6, 6, 11):
        cv.fill(rect(x + lx * f - 1, y - 1, x + lx * f + 1, y), DARK)
    hx0 = x + 22 * f
    cv.fill(rect(hx0 - 1, by - h + 22, hx0 - 1, by - h + 26) | rect(hx0 + 2 * f - 1 + (f < 0) * 2, by - h + 22, hx0 + 2 * f - 1 + (f < 0) * 2, by - h + 26), '#7a4a1f')   # ossicones
    cv.dots([(hx0 - 1, by - h + 21), (hx0 + 2 * f - 1 + (f < 0) * 2, by - h + 21)], DARK)
    cv.dots([(x + 24 * f, by - h + 28)], DARK)   # eye
    cv.fill(line([(x + 12 * f, by - 3), (x + 18 * f, by - h + 33)]), '#9a5a24')   # mane
    cv.dots([(x - 18 * f, by + 10), (x - 18 * f, by + 11)], DARK)


shadow(56, 116, 96, 121)
giraffe(76, 118, 1, 64)
shadow(152, 108, 186, 112)
giraffe(170, 110, -1, 58)

# ---------------------------------------------------------------- granite kopje (left) with the stone-head watcher and a lookout gnome
kop = blank()
for bx0, by0, bx1, by1 in ((-16, 94, 46, 146), (22, 112, 72, 152), (-10, 130, 34, 166), (38, 136, 60, 154)):
    bm = ell(bx0, by0, bx1, by1)
    o = cv.obj()
    o.part(bm, GRANITE, d=4)
    o.draw()
    kop |= bm
    for k in range(3):   # cracks and exfoliating sheets
        ax, ay = r(bx0 + 6, bx1 - 10), r(by0 + 8, by1 - 10)
        cv.fill(line([(ax, ay), (ax + r(4, 12), ay + r(-2, 5))]) & bm & ~dil4(~bm), GRANITE['s'])
for k in range(50):   # lichen and specks
    lx, ly = r(0, 70), r(96, 164)
    if kop[ly, lx]:
        cv.dots([(lx, ly), (lx + 1, ly)], ('#e8a317', '#dccab0', '#8a7464', '#a4b05a', '#f08a24')[k % 5])
# the watcher: a tall carved head looking out over the plain
hx, hy = 14, 60
o = cv.obj()
o.part(rect(hx - 4, hy + 34, hx + 22, hy + 40), GRANITE, d=1)   # plinth
o.part(rrect(hx, hy + 4, hx + 16, hy + 34, 2), GRANITE, d=3)   # long face
o.part(rect(hx - 1, hy, hx + 17, hy + 6), GRANITE, d=1)   # flat cap
o.part(poly([(hx + 16, hy + 12), (hx + 21, hy + 22), (hx + 16, hy + 24)]), GRANITE, d=1)   # nose
o.draw()
cv.fill(rect(hx + 8, hy + 12, hx + 14, hy + 12), GRANITE['s'])   # brow
cv.fill(rect(hx + 10, hy + 14, hx + 13, hy + 15), '#5c4a3c')   # deep eye
cv.fill(rect(hx + 10, hy + 27, hx + 16, hy + 28), '#6a5444')   # mouth
cv.fill(rect(hx + 1, hy + 10, hx + 2, hy + 24), GRANITE['r'])
for yy in (hy + 2, hy + 4):
    cv.fill(rect(hx, yy, hx + 16, yy) & ~rect(hx + 3, yy, hx + 4, yy), GRANITE['s'])
cv.dots([(hx + 4, hy + 30), (hx + 6, hy + 31), (hx + 3, hy + 18)], '#a4b05a')   # moss
cv.fill(rect(hx + 3, hy + 2, hx + 6, hy + 3), '#f5d020')   # a weaver bird perched on top
cv.dots([(hx + 7, hy + 2)], '#3d2a1c')


def gnome(gx, gy, tunic, hat, lean=-5, s=1.0, arm=None):
    """Standing gnome, feet at (gx, gy). s scales the figure; arm=(dx, dy) puts a hand out."""
    def S(v):
        return int(round(v * s))
    o = cv.obj()
    o.part(rect(gx - S(7), gy - S(3), gx - S(2), gy) | rect(gx + S(1), gy - S(3), gx + S(6), gy), UMBER, d=1)
    o.part(rrect(gx - S(7), gy - S(16), gx + S(7), gy - S(3), 2), tunic, d=2, contour=True)
    o.part(rect(gx - S(7), gy - S(7), gx + S(7), gy - S(6)), ramp('#7a4a1f', '#5c3420'), d=0)
    o.part(poly([(gx - S(7), gy - S(20)), (gx + S(7), gy - S(20)), (gx + 1, gy - S(6))]), BEARD, d=1, contour=True)
    o.part(rect(gx - S(5), gy - S(25), gx + S(5), gy - S(19)), SKIN, d=1)
    o.part(poly([(gx - S(8), gy - S(23)), (gx + S(8), gy - S(23)), (gx + S(lean), gy - S(40))]), hat, d=2, contour=True)
    if arm and arm[0] > 0:
        o.part(rect(gx + S(5), gy - S(15), gx + S(5) + arm[0], gy - S(12)), tunic, d=1)
    elif arm:
        o.part(rect(gx - S(5) + arm[0], gy - S(15), gx - S(5), gy - S(12)), tunic, d=1)
    o.draw()
    cv.fill(rect(gx - S(8), gy - S(24), gx + S(8), gy - S(23)), hat['s'])
    cv.dots([(gx - S(2), gy - S(22)), (gx + S(2), gy - S(22))], DARK)
    cv.dots([(gx, gy - S(21)), (gx + 1, gy - S(21))], '#e0907a')
    cv.dots([(gx - S(4), gy - S(20)), (gx + S(4), gy - S(20))], '#f0a0a0')
    cv.fill(rect(gx - 1, gy - S(7), gx + 1, gy - S(6)), '#f5cf6a')


# lookout gnome on the kopje with a spyglass toward the herds
gnome(50, 104, TEAL, RED, lean=-4, s=0.8)
o = cv.obj()
o.part(line([(55, 92), (66, 88)], 2), ramp('#d9a22a', '#a8741a', '#f2d46a'), d=0)
o.draw()

# ---------------------------------------------------------------- Baobab Inn (right): fat trunk, stubby root-like crown, door, window, pods
bt = poly([(236, 156), (240, 120), (238, 96), (242, 76), (248, 64), (276, 64), (282, 76), (286, 96), (284, 120), (290, 156)])
br = (line([(250, 66), (236, 50), (226, 46)], 4) | line([(256, 64), (252, 44), (246, 34)], 4) | line([(268, 64), (274, 42), (282, 34)], 4)
      | line([(276, 66), (292, 50), (300, 48)], 4) | line([(238, 50), (230, 36)], 2) | line([(274, 46), (266, 30)], 2) | line([(290, 52), (296, 40)], 2))
shadow(228, 152, 300, 160, DGRASS['s'])
o = cv.obj()
o.part(br, BARK, d=2)
o.part(bt, BARK, d=4)
o.draw()
for xx in range(244, 284, 6):   # vertical bark folds
    cv.fill(line([(xx, 72 + (xx % 5)), (xx + (xx % 3) - 1, 150)]) & bt & ~shift(bt, 3, 0), BARK['s'])
for cx, cy in ((226, 44), (230, 34), (246, 32), (266, 28), (282, 32), (296, 38), (300, 46)):   # sparse leaf tufts
    o = cv.obj(outline=False)
    o.part(ell(cx - 5, cy - 3, cx + 5, cy + 3), LEAF, d=1)
    o.draw()
    cv.dots([(cx - 2, cy - 1), (cx + 1, cy)], LEAF['r'])
for px, py in ((236, 54), (258, 46), (284, 54), (270, 38)):   # hanging velvet pods
    cv.fill(rect(px, py, px, py + 3), BARK['s'])
    o = cv.obj()
    o.part(ell(px - 2, py + 3, px + 2, py + 11), ramp('#a4b05a', '#7a8a3a', '#c9d08a'), d=1)
    o.draw()
o = cv.obj()   # arched door, open, warm light
o.part(ell(252, 124, 272, 160) & rect(0, 0, W, 154), ramp('#f5cf6a', '#e8a317', '#fff4c0'), d=2)
o.draw()
cv.fill(rect(252, 150, 272, 154) & ell(252, 124, 272, 160), '#e8a317')
cv.fill(rect(261, 128, 263, 154), '#b07a10')   # doorway post
o = cv.obj()   # round window up the trunk
o.part(ell(256, 88, 268, 100), ramp('#f5cf6a', '#e8a317', '#fff4c0'), d=1)
o.draw()
cv.fill(rect(261, 88, 262, 100) | rect(256, 93, 268, 94), '#4a2c1a')
for lx, ly in ((246, 116), (278, 112)):   # lanterns on pegs
    cv.fill(rect(lx, ly - 4, lx, ly - 1), DARK)
    o = cv.obj()
    o.part(rrect(lx - 2, ly, lx + 2, ly + 5, 1), ramp('#f08a24', '#b85a14', '#f5cf6a'), d=1)
    o.draw()
o = cv.obj()   # ladder up to the window
o.part(rect(240, 100, 241, 156) | rect(248, 100, 249, 156), UMBER, d=1)
for yy in range(104, 156, 7):
    o.part(rect(240, yy, 249, yy + 1), UMBER, d=0)
o.draw()
for _ in range(10):   # little flowers at the inn foot
    fx, fy = r(232, 298), r(152, 160)
    cv.dots([(fx, fy), (fx + 1, fy)], ('#d6322b', '#f6b8cf', '#7a5cc0')[r(0, 2)])


# ---------------------------------------------------------------- thatched round-hut village
def hut(x0, x1, wy0, wy1, apex, door=True, deco=0):
    """Round hut: mud wall x0..x1 from wy0 to wy1, cone thatch roof up to apex y."""
    cx = (x0 + x1) // 2
    o = cv.obj()
    o.part(rrect(x0, wy0, x1, wy1, 3), MUD, d=3)
    o.draw()
    for k in range(3):   # painted wall band (ochre zigzag)
        yy = wy0 + 8
        for xx in range(x0 + 3, x1 - 3, 4):
            cv.dots([(xx, yy + (xx // 4) % 2)], (CLAY['b'], '#f2e4c0', CLAY['s'])[deco % 3])
    if door:
        o = cv.obj()
        o.part(rrect(cx - 4, wy1 - 14, cx + 4, wy1, 2), ramp('#4a2c1a', '#2a1a10', '#74462a'), d=1)
        o.draw()
    roof = poly([(x0 - 6, wy0 + 4), (cx, apex), (x1 + 6, wy0 + 4)]) | ell(x0 - 6, wy0 - 2, x1 + 6, wy0 + 8)
    o = cv.obj()
    o.part(roof, THATCH, d=3)
    o.draw()
    for k in range(1, 6):   # thatch rings
        yy = apex + (wy0 + 4 - apex) * k // 6
        hw = (x1 - x0 + 12) * k // 12
        cv.fill(line([(cx - hw + 1, yy), (cx + hw - 1, yy + 1)]) & roof, THATCH['s'])
    for k in range(18):   # straw strands
        tx = r(x0 - 4, x1 + 4)
        ty = r(apex + 4, wy0 + 6)
        if roof[ty, tx] and roof[min(H - 1, ty + 2), tx]:
            cv.fill(rect(tx, ty, tx, ty + 2), THATCH['r'] if k % 2 else THATCH['s'])
    cv.fill(roof & ~shift(roof, 0, -1) & rect(0, wy0, W, H), '#8a5a2a')   # fringe line
    for xx in range(x0 - 5, x1 + 6, 2):
        cv.dots([(xx, wy0 + 8 + (xx % 3 == 0))], THATCH['s'])
    o = cv.obj()   # topknot
    o.part(rect(cx - 1, apex - 5, cx + 1, apex + 1), UMBER, d=0)
    o.draw()


hut(186, 214, 116, 140, 86, deco=1)      # back hut (right)
hut(90, 116, 128, 150, 102, deco=2)      # little hut (left)
# granary on stilts between the back huts
o = cv.obj()
o.part(rect(218, 128, 219, 146) | rect(228, 128, 229, 146), UMBER, d=0)
o.part(ell(214, 110, 234, 132), MUD, d=2)
o.part(poly([(212, 116), (224, 98), (236, 116)]), THATCH, d=2)
o.draw()
cv.fill(rect(222, 120, 226, 124), '#4a2c1a')
# the Coffee Ceremony Hut (front centre): bigger, open front with smoke from the roof peak
hut(122, 170, 124, 156, 84, deco=0)
cv.fill(rect(138, 140, 154, 156) & rrect(138, 140, 154, 156, 3), '#4a2c1a')   # wide doorway, glowing coals inside
cv.fill(rect(142, 150, 150, 153), '#e0501f')
cv.dots([(144, 149), (147, 148), (149, 150)], '#f5cf6a')
for k in range(6):   # roasting smoke drifting right from the top
    sx, sy = 146 + k * 5, 78 - k * 6
    pm = ell(sx - 3 - k // 2, sy - 3, sx + 3 + k // 2, sy + 2)
    cv.fill(pm, '#f6ecdc' if k < 4 else '#f2dcc0')
    cv.fill(pm & ~shift(pm, -1, -1), '#d9c0a0')
# boma: a low thorn-stick fence round the village
for fx in list(range(84, 122, 4)) + list(range(172, 238, 4)):
    fy = 150 if fx < 122 else 146 + (fx - 172) // 20
    cv.fill(rect(fx, fy - 6, fx, fy), UMBER['s'])
    cv.dots([(fx - 1, fy - 5), (fx + 1, fy - 3)], UMBER['r'])
cv.fill(line([(84, 147), (121, 147)]) | line([(172, 143), (237, 146)]), UMBER['b'])

# ---------------------------------------------------------------- coffee ceremony in front of the hut: grass mat, pot, cups, roasting gnome
mat = ell(156, 160, 226, 182)
cv.fill(mat, '#6a9a3a')
cv.fill(mat & ~shift(mat, 0, -2), '#4f7a2a')
for _ in range(70):
    mx, my = r(156, 226), r(160, 182)
    if mat[my, mx]:
        cv.fill(line([(mx, my), (mx + r(-2, 2), my - 1)]), ('#8ab84a', '#4f7a2a', '#a4c86a')[r(0, 2)])
for px, py in ((190, 178), (172, 162), (214, 164), (198, 162)):   # petals scattered on the grass
    cv.dots([(px, py), (px + 1, py)], '#f6b8cf')
# fire ring and the roasting pan over it
o = cv.obj()
o.part(ell(158, 172, 172, 179), GRANITE, d=1)
o.draw()
cv.fill(ell(161, 170, 169, 176), '#e0501f')
cv.dots([(164, 169), (165, 168), (166, 170), (163, 171)], '#f5cf6a')
# roasting gnome, arm out to the left holding the long-handled pan
gnome(186, 180, ramp('#e8a317', '#b07a10', '#f5cf6a'), PURP, lean=-6, arm=(-5, 0))
o = cv.obj()
o.part(line([(176, 166), (168, 166)], 2), UMBER, d=0)
o.part(ell(158, 163, 169, 168), ramp('#4a3c36', '#2a1a10', '#8a7a70'), d=1)
o.draw()
cv.fill(rect(175, 165, 177, 168), SKIN['b'])   # hand
cv.dots([(160, 164), (162, 164), (164, 165), (161, 165), (166, 164)], '#3d2a1c')   # beans
for k in range(4):   # bean smoke curling up from the pan
    cv.fill(ell(160 + k * 2 - 2, 154 - k * 5, 160 + k * 2 + 3, 157 - k * 5), '#f2e4c0')
# clay jebena pot on the mat
jx, jy = 204, 166
POT = ramp('#3d2a1c', '#2a1a10', '#7a4a1f')
o = cv.obj()
o.part(ell(jx - 6, jy - 2, jx + 6, jy + 10), POT, d=2)
o.part(rect(jx - 1, jy - 10, jx + 1, jy - 1), POT, d=0)
o.part(line([(jx + 5, jy + 2), (jx + 10, jy - 3)], 2), POT, d=0)
o.part(line([(jx - 4, jy - 6), (jx - 7, jy - 2), (jx - 5, jy + 2)]), POT, d=0)
o.draw()
cv.dots([(jx - 3, jy + 1), (jx - 3, jy + 2), (jx - 2, jy)], '#9a6b3f')
cv.fill(rect(jx - 1, jy - 12, jx + 1, jy - 11), '#d6322b')   # straw stopper
# low tray with three little cups
o = cv.obj()
o.part(rect(212, 176, 226, 178), UMBER, d=1)
o.draw()
for cx in (213, 218, 223):
    o = cv.obj()
    o.part(rect(cx, 172, cx + 2, 175), ramp('#f1ece0', '#c9c5bc', '#ffffff'), d=1)
    o.draw()
    cv.dots([(cx + 1, 172)], '#5c3420')
cv.fill(line([(228, 168), (226, 162), (229, 156), (227, 150)]), '#f2e4c0')   # incense wisp

# ---------------------------------------------------------------- termite mounds (front left)
for mx, mtop, mw in ((14, 132, 12), (34, 152, 9), (52, 166, 7)):
    base = 192 if mx < 30 else 188 + (mx - 30) // 8
    m = poly([(mx - mw, base), (mx - mw + 3, mtop + 22), (mx - 3, mtop + 6), (mx - 1, mtop), (mx + 2, mtop + 2), (mx + 3, mtop + 12), (mx + mw - 2, mtop + 26), (mx + mw, base)])
    m |= poly([(mx + 2, mtop + 14), (mx + mw + 3, mtop + 10), (mx + mw, mtop + 24)])   # side chimney
    shadow(mx - mw - 2, base - 2, mx + mw + 8, base + 3, DGRASS['s'])
    o = cv.obj()
    o.part(m, CLAY, d=3)
    o.draw()
    for k in range(10):
        yy = r(mtop + 6, base - 4)
        xx = mx + r(-mw // 2, mw // 2)
        if m[yy, xx]:
            cv.fill(rect(xx, yy, xx, yy + 2), CLAY['s'])
    cv.dots([(mx - 1, mtop + 8), (mx, mtop + 9)], DARK)   # vent
# a gnome with an ear to the big mound
gnome(32, 196, GREENT, ramp('#f08a24', '#b85a14', '#f5b04a'), lean=6, s=0.9)
# a guineafowl pecking
gfx, gfy = 64, 194
o = cv.obj()
o.part(ell(gfx, gfy - 6, gfx + 9, gfy), ramp('#4a4a5a', '#2a2a3a', '#6a6a7a'), d=1)
o.part(rect(gfx + 8, gfy - 9, gfx + 10, gfy - 5), ramp('#3f8fb0', '#25637d'), d=0)
o.draw()
cv.dots([(gfx + 2, gfy - 4), (gfx + 4, gfy - 3), (gfx + 6, gfy - 4), (gfx + 3, gfy - 2), (gfx + 5, gfy - 5)], '#ffffff')
cv.dots([(gfx + 9, gfy - 10)], '#d6322b')

# ---------------------------------------------------------------- waterhole with flamingos (front, left of the path)
pond = ell(66, 166, 124, 196)
cv.fill(dil4(dil4(pond)), '#9a603a')
cv.fill(dil4(pond), '#c9875a')
cv.fill(pond, WATER['b'])
cv.fill(pond & ~shift(pond, 0, 3), WATER['s'])
for _ in range(30):
    rx, ry = r(70, 120), r(170, 194)
    if pond[ry, rx] and pond[ry, min(W - 1, rx + 5)]:
        cv.fill(line([(rx, ry), (rx + r(2, 5), ry)]), '#8cc4dc' if r(0, 2) else '#f5b46a')   # sunrise glints
cv.fill(rect(84, 176, 98, 176) & pond, '#f5cf6a')
for fx, fy, f in ((80, 186, 1), (104, 180, -1), (94, 190, 1)):   # flamingos, one leg each
    o = cv.obj()
    o.part(rect(fx, fy - 10, fx, fy), PINK, d=0)
    o.part(ell(fx - 5, fy - 16, fx + 5, fy - 10), PINK, d=1)
    o.part(line([(fx + 4 * f, fy - 14), (fx + 6 * f, fy - 22), (fx + 4 * f, fy - 26)], 2), PINK, d=0)
    o.part(rect(min(fx + 3 * f, fx + 6 * f), fy - 28, max(fx + 3 * f, fx + 6 * f), fy - 25), PINK, d=0)
    o.draw()
    cv.dots([(fx + 6 * f, fy - 25), (fx + 7 * f, fy - 24)], DARK)
    cv.fill(line([(fx, fy - 6), (fx - 3 * f, fy - 4)]), PINK['b'])   # tucked leg
    cv.fill(rect(fx - 2, fy + 1, fx + 2, fy + 1), WATER['r'])
for rx, ry in ((68, 172), (122, 176), (70, 190), (118, 192), (64, 182)):   # reeds
    h = r(7, 11)
    cv.fill(rect(rx, ry - h, rx, ry), '#4f6a2a')
    cv.fill(line([(rx + 1, ry), (rx + 3, ry - h + 2)]), '#6a8a3a')

# ---------------------------------------------------------------- the near migration crossing the front right: zebras and wildebeest
def zebra(x, y, f):
    by = y - 15
    body = ell(x - 12, by - 6, x + 12, by + 5)
    legs = blank()
    for lx, sp in ((-9, -1), (-6, 1), (6, -1), (9, 1)):
        legs |= line([(x + lx * f, by + 2), (x + (lx + sp) * f, y)])
    neck = poly([(x + 7 * f, by - 3), (x + 12 * f, by), (x + 17 * f, by - 11), (x + 12 * f, by - 14)])
    head = poly([(x + 12 * f, by - 15), (x + 17 * f, by - 15), (x + 23 * f, by - 6), (x + 20 * f, by - 4)])
    o = cv.obj()
    o.part(legs, ZEB, d=0)
    o.part(body | neck, ZEB, d=2)
    o.part(head, ZEB, d=1)
    o.draw()
    for k in range(-10, 9, 4):   # curved body stripes
        cv.fill(line([(x + k, by - 6), (x + k + 1, by - 1), (x + k - 1, by + 4)]) & body, '#2a1a10')
    cv.fill(line([(x - 12 * f, by - 2), (x - 5 * f, by - 4)]) & body, '#2a1a10')
    for k in range(3):
        cv.fill(line([(x + (9 + k * 2) * f, by - 3 - k * 4), (x + (14 + k * 2) * f, by - 1 - k * 4)]) & neck, '#2a1a10')
    cv.fill(legs & (rect(0, by + 7, W, by + 7) | rect(0, by + 11, W, by + 11)), '#2a1a10')
    cv.fill(legs & rect(0, y - 1, W, y), DARK)   # hooves
    cv.fill(line([(x + 12 * f, by - 16), (x + 7 * f, by - 4)]), DARK)   # mane
    cv.fill(line([(x + 21 * f, by - 7), (x + 22 * f, by - 5)]), DARK)   # muzzle
    cv.dots([(x + 16 * f, by - 12)], DARK)
    cv.dots([(x + 13 * f, by - 17), (x + 15 * f, by - 17)], ZEB['s'])   # ears
    cv.fill(line([(x - 12 * f, by - 2), (x - 14 * f, by + 6)]), DARK)


def wildebeest(x, y, f):
    by = y - 14
    body = poly([(x - 12 * f, by - 2), (x - 6 * f, by - 6), (x + 6 * f, by - 9), (x + 10 * f, by - 6), (x + 10 * f, by + 4), (x - 12 * f, by + 4)])
    legs = blank()
    for lx, sp in ((-10, 0), (-7, 1), (5, -1), (8, 0)):
        legs |= line([(x + lx * f, by + 3), (x + (lx + sp) * f, y)])
    head = poly([(x + 8 * f, by - 8), (x + 13 * f, by - 8), (x + 18 * f, by + 2), (x + 14 * f, by + 4)])
    o = cv.obj()
    o.part(legs, WILD, d=0)
    o.part(body, WILD, d=2)
    o.part(head, ramp('#4a3c36', '#3d2a1c', '#6a5a52'), d=1)
    o.draw()
    cv.fill(line([(x + 9 * f, by - 9), (x + 7 * f, by - 12), (x + 5 * f, by - 11)]) | line([(x + 12 * f, by - 9), (x + 14 * f, by - 12), (x + 16 * f, by - 11)]), '#f1ece0')   # horns
    cv.fill(line([(x + 13 * f, by + 3), (x + 12 * f, by + 7)], 2), '#2a1a10')   # beard
    cv.fill(line([(x + 8 * f, by - 9), (x - 4 * f, by - 6)]), '#2a1a10')   # mane along the hump
    for k in range(-8, 6, 3):
        cv.fill(rect(x + k, by - 2, x + k, by + 2) & body, WILD['s'])   # faint body stripes
    cv.fill(line([(x - 12 * f, by - 1), (x - 14 * f, by + 6)]), DARK)
    cv.dots([(x + 13 * f, by - 5)], '#f1ece0')


for dx, dy in ((232, 198), (262, 184), (292, 196), (300, 170), (244, 172)):   # dust clouds behind them
    cv.fill(ell(dx - 10, dy - 6, dx + 10, dy), '#f0c890')
    cv.fill(ell(dx - 6, dy - 9, dx + 4, dy - 3), '#f6dcb0')
shadow(240, 174, 266, 178)
wildebeest(254, 176, -1)
shadow(276, 182, 300, 186)
zebra(290, 184, -1)
shadow(232, 196, 262, 199)
zebra(246, 199, -1)
shadow(286, 197, 300, 199)
wildebeest(296, 200, -1)
cv.dots([(244, 175), (245, 174), (246, 175)], '#5c3420')   # oxpecker on the zebra
cv.fill(rect(243, 174, 244, 175), '#d6322b')

# ---------------------------------------------------------------- litter: grass seed heads, stones, aloe and flowers across the meadow
keep = (rect(150, 140, 232, 199) | rect(14, 150, 46, 199) | rect(176, 160, 300, 199) | rect(40, 84, 70, 106) | rect(56, 40, 110, 121)
        | rect(140, 44, 196, 112) | pond | dil4(dil4(pond)) | path | rect(228, 30, 300, 160))
for _ in range(110):
    lx, ly = r(0, W - 3), r(112, H - 4)
    if keep[ly, lx] or kop[ly, lx]:
        continue
    k = r(0, 3)
    if k == 0:   # seed head on a stalk
        cv.fill(rect(lx, ly, lx, ly + 3), '#a8701c')
        cv.dots([(lx, ly - 1), (lx - 1, ly), (lx + 1, ly)], '#f5cf6a')
    elif k == 1:   # pebble
        cv.dots([(lx, ly), (lx + 1, ly), (lx + 1, ly + 1)], '#b9a088')
        cv.dots([(lx, ly + 1)], '#8a7464')
    else:   # red-hot-poker / pentas flower dots
        cv.dots([(lx, ly), (lx, ly + 1)], ('#d6322b', '#f08a24')[k - 2])
        cv.dots([(lx, ly + 2)], '#55652a')
for ax, ay in ((6, 172), (70, 150), (124, 176), (214, 150), (300 - 8, 162)):   # small aloe rosettes
    o = cv.obj()
    for t in (-6, -3, 0, 3, 6):
        o.part(line([(ax, ay), (ax + t, ay - 7 + abs(t) // 2)], 2), GREENT, d=0)
    o.draw()
    cv.fill(rect(ax, ay - 14, ax, ay - 8), '#55652a')
    cv.dots([(ax, ay - 15), (ax, ay - 14)], '#f08a24')

if __name__ == '__main__':
    out = sys.argv[1] if len(sys.argv) > 1 else None
    n = save_pic(cv, 'thornacre', out)
    print('thornacre:', n, 'colours')
