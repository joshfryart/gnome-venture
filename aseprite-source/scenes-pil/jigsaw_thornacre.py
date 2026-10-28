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
r3 = rnd(5353)   # pass-1 details (so the v0 layout does not shift)


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
    a1 = a0 + math.pi / 30 * (0.5 + (k * 7 % 5) / 3.0)   # uneven ray widths
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
for ci, (cx, cy, w) in enumerate(CLOUDS):
    st = (0, 1, 2, 1, 2, 0, 1, 2, 0, 2, 1)[ci]
    if st == 0:   # flat-bellied puff
        m = ell(cx - w // 2, cy - 3, cx + w // 2, cy + 3) | ell(cx - w // 4, cy - 6, cx + w // 6, cy + 2) | ell(cx + w // 8, cy - 5, cx + w // 2 - 4, cy + 2)
    elif st == 1:   # long layered streak with a torn tail
        m = (ell(cx - w // 2, cy - 2, cx + w // 2, cy + 2) | ell(cx - w // 3 + 4, cy - 4, cx + w // 6 + 4, cy + 1) | ell(cx - w // 2 - 10, cy + 1, cx - 2, cy + 4)
             | ell(cx + w // 2 + 2, cy - 1, cx + w // 2 + 8, cy + 1))
    else:   # tall cumulus, flat bottom
        m = (ell(cx - w // 2, cy - 3, cx + w // 2, cy + 3) | ell(cx - w // 3, cy - 9, cx, cy + 1) | ell(cx - w // 8, cy - 12, cx + w // 4, cy) | ell(cx + w // 6, cy - 7, cx + w // 2 - 2, cy + 1))
        m &= rect(0, 0, W, cy + 2)
    cv.fill(m, '#fbe6c8')
    cv.fill(m & ~shift(m, 0, -2), '#f0a080')   # warm underside
    cv.fill(m & ~shift(m, 0, -1), '#d9705a')
    cv.fill(m & ~shift(m, 2, 1) & ~shift(m, 0, 1), '#fff6e4')   # lit top-left rim
for bx, by in ((60, 20), (66, 17), (72, 21), (54, 24), (78, 25), (150, 6), (156, 9), (236, 30), (242, 33), (104, 50), (196, 14)):   # birds (a flock of storks heading out)
    cv.dots([(bx, by), (bx + 1, by - 1), (bx + 2, by), (bx + 3, by - 1), (bx + 4, by)], '#5c3420')
# a vulture circling high on the right
cv.fill(line([(270, 6), (276, 9), (280, 8), (284, 9), (290, 6)], 2), '#4a3c36')
# the fading morning moon (top centre)
moon = ell(158, 6, 168, 16) & ~ell(161, 4, 171, 14)
cv.fill(moon, '#fff6e4')
cv.fill(moon & ~shift(moon, -1, -1), '#e0b0b8')


def balloon(bx, by, s, ramp_a, ramp_b):
    """Safari hot-air balloon: envelope centre (bx, by), half-width s, gores in two colours, basket below."""
    env = ell(bx - s, by - s - 2, bx + s, by + s) | poly([(bx - s + 1, by + 2), (bx + s - 1, by + 2), (bx + 2, by + s + 4), (bx - 2, by + s + 4)])
    o = cv.obj()
    o.part(env, ramp_a, d=2)
    o.part(rect(bx - 2, by + s + 7, bx + 2, by + s + 9), UMBER, d=0)
    o.draw()
    for gx in range(bx - s + 2, bx + s - 1, 4):   # vertical gores
        g = rect(gx, by - s - 2, gx + 1, by + s + 4) & env & shift(env, 1, 1) & shift(env, -1, -1)
        cv.fill(g, ramp_b['b'])
    cv.fill(env & rect(0, by + 1, W, by + 2) & shift(env, 1, 0) & shift(env, -1, 0), '#f5cf6a')   # band
    cv.dots([(bx - 2, by + s + 5), (bx - 2, by + s + 6), (bx + 2, by + s + 5), (bx + 2, by + s + 6)], DARK)   # ropes
    cv.dots([(bx - s + 3, by - s + 1), (bx - s + 3, by - s + 2), (bx - s + 4, by - s)], '#fff6e4')   # gloss


balloon(112, 34, 8, RED, ramp('#f08a24', '#b85a14'))
balloon(66, 42, 4, PURP, ramp('#f5cf6a', '#b07a10'))


def crane(cx, cy, up):
    """Grey crowned crane in flight: neck forward (left), legs trailing, wings up or down."""
    cv.fill(ell(cx - 3, cy - 1, cx + 3, cy + 1), '#8a7a70')
    cv.fill(line([(cx - 3, cy), (cx - 8, cy - 1)]), '#4a3c36')
    cv.fill(line([(cx + 3, cy), (cx + 10, cy + 1)]), '#2a1a10')
    wy = cy - 6 if up else cy + 5
    wing = poly([(cx - 2, cy), (cx + 2, cy), (cx + 4, wy), (cx - 1, wy + (1 if up else -1))])
    cv.fill(wing, '#f1ece0')
    cv.fill(wing & ~shift(wing, 0, 2 if up else -2), '#4a3c36')
    cv.dots([(cx - 9, cy - 1), (cx - 9, cy - 2), (cx - 8, cy - 3), (cx - 10, cy - 3)], '#f5cf6a')   # golden crown
    cv.dots([(cx - 9, cy)], '#d6322b')


crane(34, 33, True)
crane(44, 41, False)
crane(24, 44, False)

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
leftface = peak & ~snow & poly([(196, 36), (199, 50), (197, 64), (201, 80), (199, 98), (100, 98), (100, 36)])
cv.fill(leftface, '#c49aa4')   # the sunlit left face
cv.fill(line([(186, 52), (194, 80)]) & leftface, '#9a7a8a')   # (re-cut the old gullies, softer on the lit face)
cv.fill(line([(200, 60), (204, 88)]) & peak, '#7a5c70')
# sunlit ridges and buttresses down the left face (light from the upper left), each with a shaded right edge
for ridge, dxs in (([(176, 50), (170, 58), (164, 66), (158, 72), (150, 82), (142, 92), (136, 98)], (2, 3, 5, 6, 7, 8, 9)),
                   ([(186, 54), (184, 62), (178, 70), (174, 78), (168, 88), (164, 98)], (2, 3, 4, 6, 5, 7)),
                   ([(166, 62), (160, 68), (156, 76), (150, 86)], (1, 3, 4, 5)),
                   ([(178, 76), (174, 84), (170, 98)], (2, 4, 5))):
    right = [(x + max(1, d // 2), y) for (x, y), d in zip(ridge, dxs)]
    face = poly(ridge + right[::-1]) & peak & ~snow
    cv.fill(line(ridge) & peak & ~snow, '#fbe0d8')   # sun-caught ridge crest
    cv.fill(face, '#9a7a8a')   # shaded side of the ridge
    cv.fill(line(right) & peak & ~snow, '#7a5c70')
for _ in range(60):   # scree and rock specks on the slope
    sx, sy = r3(124, 200), r3(50, 94)
    if peak[sy, sx] and not snow[sy, sx]:
        cv.dots([(sx, sy), (sx + 1, sy)], ('#7a5c70', '#c49aa4', '#c98a6a')[r3(0, 2)])
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

# ---------------------------------------------------------------- the mid herd: bigger wildebeest and zebras trotting through the gaps behind the village
def mini(x, y, kind, f):
    """Tiny far animal, feet at y, facing f."""
    def R(d0, y0, d1, y1, col):
        cv.fill(rect(min(x + d0 * f, x + d1 * f), y0, max(x + d0 * f, x + d1 * f), y1), col)
    if kind == 'w':
        R(-3, y - 6, 2, y - 4, '#4a3c36')
        R(1, y - 7, 3, y - 5, '#4a3c36')
        R(4, y - 6, 5, y - 3, '#3d2a1c')
        cv.dots([(x + 4 * f, y - 7), (x + 6 * f, y - 7)], '#c9c5bc')
        for d in (-3, -1, 1, 2):
            R(d, y - 3, d, y - (1 if d % 2 else 0), '#3d2a1c')
        cv.dots([(x - 4 * f, y - 5), (x - 4 * f, y - 4)], DARK)
    else:
        R(-3, y - 6, 2, y - 4, '#f1ece0')
        R(3, y - 8, 4, y - 5, '#f1ece0')
        cv.dots([(x - 2 * f, y - 6), (x - 2 * f, y - 5), (x, y - 6), (x, y - 5), (x + 2 * f, y - 5), (x + 5 * f, y - 7), (x + 3 * f, y - 9)], DARK)
        for d in (-3, -1, 1, 2):
            R(d, y - 3, d, y - (1 if d % 2 else 0), '#4a3c36')


for hx_, hy_, kind, f in ((72, 113, 'w', 1), (80, 116, 'z', 1), (92, 112, 'w', 1), (100, 115, 'w', 1), (108, 112, 'z', 1), (114, 116, 'w', 1),
                          (128, 112, 'w', 1), (136, 115, 'z', 1), (144, 112, 'w', 1), (174, 113, 'w', 1), (182, 116, 'w', 1), (226, 112, 'z', 1),
                          (234, 115, 'w', 1), (292, 112, 'w', -1), (298, 116, 'z', -1), (6, 112, 'w', 1)):
    cv.fill(ell(min(hx_ - 9 * f, hx_ - f), hy_ - 10, max(hx_ - 9 * f, hx_ - f), hy_ - 6), '#f2c88a')   # kicked-up dust behind
    mini(hx_, hy_, kind, f)

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

    def X(d):
        return x + d * f
    body = ell(x - 14, by - 6, x + 14, by + 7) | ell(min(X(0), X(15)), by - 10, max(X(0), X(15)), by + 5)   # sloping back, high withers
    near, far = blank(), blank()
    for lx, is_near, hind in ((-10, True, True), (-6, False, True), (10, True, False), (6, False, False)):
        top = (X(lx), by + 3)
        knee = (X(lx - 2 if hind else lx + (0 if is_near else -1)), by + 15)   # hind legs bend back at the hock
        foot = (X(lx + (0 if hind else 1) + (1 if is_near else -1)), y)
        m = line([top, knee], 3) | line([knee, foot], 2) | rect(knee[0] - 1, knee[1] - 1, knee[0] + 1, knee[1])
        m |= rect(min(foot[0], foot[0] + f), y - 1, max(foot[0], foot[0] + f), y)   # hoof
        if is_near:
            near |= m
        else:
            far |= m
    neck = poly([(x + 8 * f, by - 6), (x + 14 * f, by - 2), (x + 22 * f, by - h + 34), (x + 17 * f, by - h + 32)])
    head = ell(min(x + 16 * f, x + 30 * f), by - h + 26, max(x + 16 * f, x + 30 * f), by - h + 33)
    o = cv.obj()
    o.part(far, ramp('#c98a2a', '#a8701c'), d=0, rim=False)
    o.draw()
    o = cv.obj()
    o.part(near, GIR, d=0, rim=False)
    o.part(body | neck, GIR, d=2)
    o.part(head, GIR, d=1)
    o.part(line([(x - 14 * f, by - 2), (x - 18 * f, by + 10)]), GIR, d=0, rim=False)
    o.draw()
    blob = body | neck
    inner = blob & shift(blob, 1, 1) & shift(blob, -1, -1) & shift(blob, 1, -1) & shift(blob, -1, 1)
    for gy in range(by - h + 30, by + 9, 4):   # reticulated patches: a jittered grid of rounded tiles with thin pale lines between
        for gx in range(x - 34, x + 34, 4):
            px, py = gx + (2 if (gy // 4) % 2 else 0) + r2(0, 1), gy + r2(0, 1)
            pm = rect(px, py, px + 2, py + 2) & ~rect(px + 2, py + 2, px + 2, py + 2) & ~rect(px, py, px, py)
            cv.fill(pm & inner, '#9a5a24')
    legs = near | far
    for lm in (near, far):   # a few small patches high on the legs, dark hooves
        cv.fill(lm & rect(0, by + 5, W, by + 6) & shift(lm, 1, 0), '#9a5a24')
    cv.fill(legs & rect(0, y - 1, W, y), DARK)
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
# the watcher: a carved soapstone bird on a chevron-cut pillar, looking out over the plain
hx, hy = 14, 60
SOAP = ramp('#8a9a7a', '#66755a', '#b4c09a')
o = cv.obj()
o.part(rect(hx - 4, hy + 34, hx + 22, hy + 40), GRANITE, d=1)   # plinth
o.part(rrect(hx + 2, hy + 14, hx + 14, hy + 34, 1), GRANITE, d=2)   # pillar
o.part(rect(hx, hy + 11, hx + 16, hy + 14), GRANITE, d=1)   # cap
o.draw()
for yy in range(hy + 17, hy + 32, 5):   # carved chevrons
    for xx in range(hx + 4, hx + 13):
        cv.dots([(xx, yy + abs(xx - (hx + 8)) // 2)], GRANITE['s'])
cv.fill(rect(hx + 3, hy + 16, hx + 3, hy + 32), GRANITE['r'])
o = cv.obj()
o.part(rect(hx + 6, hy + 6, hx + 7, hy + 10) | rect(hx + 10, hy + 6, hx + 11, hy + 10), SOAP, d=0, rim=False)   # legs
o.part(ell(hx + 3, hy - 6, hx + 14, hy + 8) | poly([(hx + 5, hy + 2), (hx + 1, hy + 10), (hx + 6, hy + 10)]), SOAP, d=2)   # body + tail
o.part(ell(hx + 8, hy - 13, hx + 15, hy - 5) | poly([(hx + 15, hy - 11), (hx + 19, hy - 8), (hx + 15, hy - 7)]), SOAP, d=1)   # head + beak
o.draw()
for k in range(3):   # folded wing feathers
    cv.fill(line([(hx + 5, hy - 2 + k * 3), (hx + 10, hy + 3 + k * 2)]) & ell(hx + 3, hy - 6, hx + 14, hy + 8), SOAP['s'])
cv.dots([(hx + 12, hy - 10)], DARK)
cv.dots([(hx + 4, hy + 30), (hx + 6, hy + 31), (hx + 3, hy + 22)], '#a4b05a')   # moss
# a red-headed agama lizard basking on the middle boulder
cv.fill(rect(32, 118, 40, 119), '#4f93b8')
cv.fill(rect(41, 117, 43, 119), '#f08a24')
cv.fill(line([(31, 119), (27, 120), (24, 122)]), '#4f93b8')
cv.dots([(33, 120), (38, 120), (34, 117), (39, 117), (43, 118)], DARK)


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
    if xx < 266:   # sunlit ridge beside each fold on the left half
        cv.fill(line([(xx - 2, 74 + (xx % 5)), (xx + (xx % 3) - 3, 148)]) & bt & ~shift(bt, 3, 0), BARK['r'])
lit = blank()   # lit left flank, a ragged band 2-5 px wide just inside the outline
for yy in range(66, 156):
    xs_ = np.nonzero(bt[yy])[0]
    if len(xs_):
        x0_ = int(xs_[0]) + 1
        lit |= rect(x0_, yy, x0_ + 1 + (yy * 7 // 3) % 4, yy)
cv.fill(lit, BARK['r'])
for _ in range(26):   # wrinkle arcs across the trunk
    wx, wy = r3(242, 280), r3(70, 120)
    wr = line([(wx, wy), (wx + 3, wy + 1), (wx + 6, wy)]) & bt & ~shift(bt, 3, 0)
    cv.fill(wr, BARK['s'])
    cv.fill(shift(wr, 0, -1) & bt & ~shift(bt, 3, 0) & rect(0, 0, 266, H), BARK['r'])
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
o = cv.obj()   # arched doorway: a smile-shaped gap in the bark, lit from inside
door = ell(252, 126, 272, 162) & rect(0, 0, W, 154)
o.part(door, ramp('#4a2c1a', '#2a1a10', '#74462a'), d=2)
o.draw()
cv.fill(ell(255, 132, 269, 160) & rect(0, 0, W, 152), '#e8a317')
cv.fill(ell(257, 134, 267, 158) & rect(0, 0, W, 146), '#f5cf6a')
cv.fill(rect(256, 146, 268, 147), '#b07a10')   # a table inside
cv.fill(rect(258, 148, 258, 152) | rect(266, 148, 266, 152), '#7a4a1f')
cv.dots([(259, 145), (260, 145), (264, 145)], '#f1ece0')   # cups
cv.fill(line([(252, 154), (272, 154)]), BARK['s'])   # sill
o = cv.obj()   # bench outside
o.part(rect(270, 148, 284, 149), UMBER, d=0)
o.part(rect(271, 150, 272, 154) | rect(282, 150, 283, 154), UMBER, d=0)
o.draw()
for k in range(40):   # bark knots and speckle
    tx, ty = r(240, 288), r(70, 150)
    if bt[ty, tx] and not door[ty, tx]:
        cv.dots([(tx, ty), (tx + 1, ty)], BARK['r'] if k % 3 == 0 else BARK['s'])
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
    wall = rrect(x0, wy0, x1, wy1, 3)
    for k in range((x1 - x0) * (wy1 - wy0) // 30):   # daub texture: little lit and shaded smears
        tx, ty = r(x0 + 2, x1 - 3), r(wy0 + 2, wy1 - 2)
        if wall[ty, tx] and wall[ty, tx + 1]:
            cv.dots([(tx, ty), (tx + 1, ty)], MUD['r'] if k % 2 else MUD['s'])
    yy = wy0 + 10
    band = rect(x0 + 2, yy - 1, x1 - 2, yy + 3) & wall
    cv.fill(band, (CLAY['b'], '#f2e4c0', CLAY['s'])[deco % 3])
    for xx in range(x0 + 2, x1 - 2, 4):   # zigzag on the band
        cv.dots([(xx, yy + (xx // 4) % 2 * 2), (xx + 1, yy + 1), (xx + 2, yy + 2 - (xx // 4) % 2 * 2)], ('#f2e4c0', CLAY['s'], '#f2e4c0')[deco % 3])
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
mat = ell(154, 158, 234, 190)
cv.fill(mat, '#6a9a3a')
cv.fill(mat & ~shift(mat, 0, -2), '#4f7a2a')
for _ in range(50):   # strands over the wider mat
    mx, my = r3(154, 234), r3(158, 190)
    if mat[my, mx]:
        cv.fill(line([(mx, my), (mx + r3(-2, 2), my - 1)]), ('#8ab84a', '#4f7a2a', '#a4c86a')[r3(0, 2)])
mat = ell(156, 160, 226, 182)   # (v0 mask: keeps the v0 random sequence)
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
# clay jebena pot on a woven straw ring: round belly, tall neck, spout, loop handle
jx, jy = 207, 168
POT = ramp('#b8502a', '#8a3a1f', '#d9764a')
o = cv.obj()
o.part(ell(jx - 8, jy + 8, jx + 8, jy + 13), THATCH, d=1)   # straw ring
o.draw()
cv.dots([(xx, jy + 10 + (xx % 2)) for xx in range(jx - 6, jx + 7, 2)], THATCH['s'])
o = cv.obj()
o.part(line([(jx - 1, jy - 8), (jx - 6, jy - 7), (jx - 8, jy - 2), (jx - 6, jy + 2)]), POT, d=0, rim=False)   # handle
o.part(line([(jx + 5, jy + 3), (jx + 9, jy - 1), (jx + 11, jy - 5)], 2), POT, d=0, rim=False)   # spout
o.part(rect(jx - 1, jy - 10, jx + 1, jy - 1), POT, d=1)   # neck
o.part(rect(jx - 2, jy - 11, jx + 2, jy - 10), POT, d=0)   # lip
o.part(ell(jx - 7, jy - 3, jx + 7, jy + 10), POT, d=3)   # belly
o.draw()
cv.dots([(xx, jy + 4) for xx in range(jx - 5, jx + 6, 2)] + [(xx, jy + 5) for xx in range(jx - 4, jx + 6, 2)], '#f2e4c0')   # painted zigzag band
cv.dots([(jx - 4, jy - 1), (jx - 3, jy - 1), (jx - 4, jy)], '#f2cf8a')   # gloss
cv.fill(rect(jx - 1, jy - 13, jx + 1, jy - 12), '#f2cf8a')   # straw stopper
cv.dots([(jx + 12, jy - 7), (jx + 13, jy - 9), (jx + 12, jy - 11)], '#f2e4c0')   # steam from the spout
# low carved table (rekebot) with four little handleless cups
o = cv.obj()
o.part(rect(214, 180, 232, 182), UMBER, d=1)
o.part(rect(215, 183, 216, 187) | rect(230, 183, 231, 187), UMBER, d=0)
o.draw()
for ci, cx in enumerate((215, 219, 223, 227)):
    o = cv.obj()
    o.part(rect(cx, 176, cx + 2, 179), ramp('#f1ece0', '#c9c5bc', '#ffffff'), d=1)
    o.draw()
    cv.dots([(cx + 1, 176)], '#5c3420')
    cv.dots([(cx, 178), (cx + 2, 178)], ('#4f93b8', '#d6322b')[ci % 2])
# a little basket of popcorn, served with the coffee
o = cv.obj()
o.part(ell(190, 183, 202, 190) & rect(0, 185, W, H), THATCH, d=1)
o.part(ell(192, 182, 200, 187) & rect(0, 0, W, 185), ramp('#f1ece0', '#c9c5bc', '#ffffff'), d=0)
o.draw()
cv.dots([(193, 187), (196, 188), (199, 187), (194, 189), (198, 189)], THATCH['s'])
cv.dots([(193, 183), (196, 182), (199, 184), (195, 184)], '#f5cf6a')
# incense burner with a curling wisp
o = cv.obj()
o.part(rect(226, 170, 230, 172) | rect(227, 173, 229, 174), CLAY, d=0)
o.draw()
cv.fill(line([(228, 169), (226, 163), (229, 157), (227, 151)]), '#f2e4c0')

# ---------------------------------------------------------------- termite mounds (front left)
for mx, mtop, mw in ((14, 132, 12), (34, 152, 9), (52, 166, 7)):
    base = 192 if mx < 30 else 188 + (mx - 30) // 8
    ht = base - mtop
    # lumpy rounded mound: a broad skirt, a swelling body, a rounded main turret and a smaller side turret
    m = ell(mx - mw - 2, base - ht // 4, mx + mw + 2, base + 4) & rect(0, 0, W, base)
    m |= ell(mx - mw * 3 // 4, mtop + ht // 3, mx + mw * 3 // 4, base - 2)
    m |= ell(mx - mw // 2 - 1, mtop, mx + mw // 3 + 1, mtop + ht // 2 + 2)
    m |= ell(mx + mw // 4, mtop + ht // 4, mx + mw - 1, mtop + ht // 2 + 4)
    m |= ell(mx - mw + 1, mtop + ht // 2, mx - 2, mtop + ht // 2 + ht // 4)
    shadow(mx - mw - 2, base - 2, mx + mw + 8, base + 3, DGRASS['s'])
    o = cv.obj()
    o.part(m, CLAY, d=3)
    o.draw()
    for k in range(10):   # (v0 sequence kept)
        r(0, 1)
        r(0, 1)
    inner = m & shift(m, 2, 0) & shift(m, -2, 0) & shift(m, 0, 2)
    for yy in range(mtop + 5, base - 1, 4):   # baked mud courses: short curved ridges, lit above, shaded below
        for xx in range(mx - mw, mx + mw, 5):
            x0_ = xx + (yy // 4) % 3
            rg = line([(x0_, yy + 1), (x0_ + 1, yy), (x0_ + 3, yy), (x0_ + 4, yy + 1)]) & inner
            cv.fill(rg, CLAY['s'])
            cv.fill(shift(rg, 0, -1) & inner & rect(0, 0, mx, H), CLAY['r'])
    cv.fill(ell(mx - 2, mtop + 6, mx + 1, mtop + 9), DARK)   # vents
    cv.fill(ell(mx + mw // 2, mtop + ht // 4 + 4, mx + mw // 2 + 2, mtop + ht // 4 + 6) & m, DARK)
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
def _mirror(x, f):
    def X(d):
        return x + d * f

    def E(d0, y0, d1, y1):
        return ell(min(X(d0), X(d1)), y0, max(X(d0), X(d1)), y1)
    return X, E


def _legs(x, by, y, f, specs, w_up, w_lo):
    """specs: (dx, hind, near). Hind legs bend back at the hock, front legs have a knee bump. Returns (near, far) masks."""
    X = lambda d: x + d * f   # noqa: E731
    near, far = blank(), blank()
    ky = by + (y - by) * 9 // 20
    for dx, hind, is_near in specs:
        top = (X(dx), by + 2)
        knee = (X(dx - 2 if hind else dx), ky)
        foot = (X(dx + (0 if hind else 1) + (0 if is_near else -1)), y)
        m = line([top, knee], w_up) | line([knee, foot], w_lo)
        if not hind:
            m |= rect(knee[0] - 1, knee[1], knee[0] + 1, knee[1] + 1)
        if is_near:
            near |= m
        else:
            far |= m
    return near, far


def zebra(x, y, f, graze=False):
    by = y - 16
    X, E = _mirror(x, f)
    body = E(-14, by - 6, -3, by + 4) | E(-9, by - 5, 8, by + 5) | E(3, by - 7, 12, by + 4)   # rump, barrel, chest
    if graze:   # head down to the grass
        neck = poly([(X(6), by - 5), (X(11), by - 2), (X(18), by + 9), (X(14), by + 11)])
        head = poly([(X(14), by + 6), (X(18), by + 5), (X(21), by + 15), (X(17), by + 16)])
    else:
        neck = poly([(X(6), by - 5), (X(12), by + 1), (X(17), by - 10), (X(12), by - 14)])
        head = poly([(X(12), by - 15), (X(17), by - 16), (X(23), by - 6), (X(19), by - 3)])
    near, far = _legs(x, by, y, f, ((-11, True, True), (-8, True, False), (8, False, True), (5, False, False)), 3, 2)
    o = cv.obj()
    o.part(far, ramp('#c9c5bc', '#8a7a70'), d=0, rim=False)
    o.draw()
    o = cv.obj()
    o.part(near, ZEB, d=0, rim=False)
    o.part(body | neck, ZEB, d=2)
    o.part(head, ZEB, d=1)
    o.draw()
    inb = body & shift(body, 0, 1) & shift(body, 0, -1)
    for k in range(-12, 12, 3):   # body stripes: curved verticals, bending back over the rump
        bend = -2 if k < -5 else 1
        cv.fill(line([(X(k), by - 8), (X(k + bend), by - 2), (X(k), by + 3), (X(k - 1), by + 6)]) & inb, DARK)
    for k in range(3):   # rump chevrons
        cv.fill(line([(X(-15), by - 3 + k * 3), (X(-10), by - 5 + k * 3)]) & inb, DARK)
    for k in range(-2, 18, 3):   # neck stripes, across the neck
        cv.fill(line([(X(4), by + k - 10), (X(20), by + k - 18 + (12 if graze else 0))]) & neck & shift(neck, 0, 1), DARK)
    legs = near | far
    for yy in range(by + 7, y - 2, 3):
        cv.fill(legs & rect(0, yy, W, yy), DARK)
    cv.fill(legs & rect(0, y - 1, W, y), DARK)
    hd = head & shift(head, 0, 1)
    if graze:
        cv.fill(hd & rect(0, by + 12, W, H), DARK)   # muzzle
        cv.dots([(X(17), by + 9)], DARK)
        mane = line([(X(6), by - 6), (X(13), by + 2), (X(16), by + 7)])
    else:
        cv.fill(hd & (rect(min(X(20), X(24)), 0, max(X(20), X(24)), H)), DARK)
        cv.dots([(X(16), by - 12)], DARK)
        mane = line([(X(6), by - 6), (X(10), by - 11), (X(12), by - 16)])
    cv.fill(mane, DARK)
    cv.fill(shift(mane, -f, -1) & ~body & ~neck & ~head, DARK)   # stand-up mane
    ear = (X(13), by - 17) if not graze else (X(15), by + 4)
    cv.dots([ear, (ear[0], ear[1] - 1), (ear[0] + f, ear[1] - 1)], ZEB['s'])
    cv.fill(line([(X(-14), by - 3), (X(-16), by + 6)]), DARK)   # tail
    cv.dots([(X(-16), by + 7), (X(-17), by + 7), (X(-16), by + 8)], DARK)


def wildebeest(x, y, f):
    by = y - 15
    X, E = _mirror(x, f)
    hump = E(-2, by - 10, 10, by + 3)
    body = hump | E(-12, by - 5, 4, by + 4) | E(-14, by - 4, -6, by + 2)
    neck = poly([(X(6), by - 9), (X(11), by - 8), (X(14), by + 0), (X(8), by + 2)])
    head = poly([(X(10), by - 8), (X(15), by - 8), (X(19), by + 4), (X(14), by + 5)])
    near, far = _legs(x, by, y, f, ((-11, True, True), (-8, True, False), (6, False, True), (3, False, False)), 2, 1)
    o = cv.obj()
    o.part(far, ramp('#4a3c36', '#3d2a1c'), d=0, rim=False)
    o.draw()
    o = cv.obj()
    o.part(near, WILD, d=0, rim=False)
    o.part(body | neck, WILD, d=2)
    o.part(head, ramp('#4a3c36', '#3d2a1c', '#6a5a52'), d=1)
    o.part(line([(X(11), by - 8), (X(8), by - 10), (X(9), by - 13)]) | line([(X(14), by - 8), (X(17), by - 10), (X(16), by - 13)]), ramp('#c9c5bc', '#8a7a70', '#f1ece0'), d=0)   # horns
    o.draw()
    for k in range(-2, 9, 2):   # brindle bands over the shoulders
        cv.fill(line([(X(k), by - 9), (X(k - 1), by + 2)]) & hump & shift(hump, 0, 1), WILD['s'])
    cv.fill(head & shift(head, 0, 1) & rect(0, by - 6, W, by + 1), '#3d2a1c')   # dark face
    cv.fill(line([(X(12), by + 2), (X(11), by + 8)], 2), DARK)   # beard
    mane = line([(X(10), by - 10), (X(4), by - 11), (X(-1), by - 9)])
    cv.fill(mane, DARK)
    cv.dots([(X(k), by - 12) for k in (1, 4, 7)], DARK)
    cv.fill((near | far) & rect(0, y - 1, W, y), DARK)
    cv.dots([(X(13), by - 5)], '#f1ece0')   # eye glint
    cv.fill(line([(X(-14), by - 3), (X(-17), by + 4), (X(-16), by + 9)]), DARK)   # long black tail
    cv.dots([(X(-17), by + 9), (X(-15), by + 10)], DARK)


for dx, dy in ((232, 198), (262, 184), (292, 196), (300, 170), (244, 172)):   # dust clouds behind them
    cv.fill(ell(dx - 10, dy - 6, dx + 10, dy), '#f0c890')
    cv.fill(ell(dx - 6, dy - 9, dx + 4, dy - 3), '#f6dcb0')
shadow(240, 174, 266, 178)
wildebeest(254, 176, -1)
shadow(276, 182, 300, 186)
zebra(290, 184, -1)
shadow(232, 196, 262, 199)
zebra(246, 199, -1, graze=True)
shadow(286, 197, 300, 199)
wildebeest(296, 200, -1)
cv.fill(rect(285, 160, 288, 161), '#5c3420')   # oxpecker riding the zebra
cv.dots([(284, 160), (288, 159)], '#d6322b')

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

# fold rare near-duplicate colours into their neighbours (keeps the picture under ~100 colours)
cv.remap({'#a9d6ea': '#8cc4dc', '#6a6a7a': '#8a7a70', '#2a2a3a': '#2a1a10', '#4a4a5a': '#4a3c36', '#3f8fb0': '#4f93b8', '#25637d': '#2f6f92',
          '#5c4a3c': '#5c3420', '#6a5444': '#6a4e3c', '#a4c86a': '#a4b05a', '#2f6a3a': '#4f7a2a', '#8ab84a': '#a4b05a', '#fff4c0': '#fff4c8',
          '#f2d46a': '#f5cf6a', '#6a4a3a': '#6a4e3c', '#6a5a3a': '#6a4e3c', '#f5b04a': '#f5b46a', '#c9a96e': '#d9a35a', '#f2c86a': '#f5cf6a',
          '#a8241f': '#8a3a1f', '#c9d08a': '#a4b05a', '#f8c860': '#f8c870', '#e0907a': '#d9a07a', '#f0a0a0': '#f08aa0', '#fff0d8': '#fff4c8',
          '#d9c0a0': '#dccab0', '#f2dcc0': '#f6dcb0', '#e2a87a': '#e0a07a'})


def palette_report():
    px = cv.px.reshape(-1, 3)
    u, c = np.unique(px, axis=0, return_counts=True)
    for col, n in sorted(zip(map(tuple, u), c), key=lambda t: t[1]):
        print('#%02x%02x%02x' % col, n)


if __name__ == '__main__':
    if '--pal' in sys.argv:
        palette_report()
        sys.exit()
    out = sys.argv[1] if len(sys.argv) > 1 else None
    n = save_pic(cv, 'thornacre', out)
    print('thornacre:', n, 'colours')
