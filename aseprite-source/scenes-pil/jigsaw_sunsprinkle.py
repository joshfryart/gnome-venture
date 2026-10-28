"""Jigsaw picture: THE SUNSPRINKLE ISLES (draft v0): game/assets/img/jigsaw/sunsprinkle.jpg (+ -thumb). Usage: python3 -B aseprite-source/scenes-pil/jigsaw_sunsprinkle.py [outdir]
A bright midday Caribbean cove: sun and trade-wind kite over a turquoise sea, a far jungle island with the Singing Waterfall, the Hurricane Crab's shell-island
on the horizon, sailboats and a whale spout; a stilted Driftwood Tavern with a palm-thatch roof and a striped bandstand awning (steel-drum gnome), a pier with
a kite-flying gnome and a moored sloop; a tall palm and a hammock gnome on the left, a leaning palm on the shore; a sea turtle nesting mid-beach with a gnome
shading the hatchlings down to the sea; the mast and hull of the Sunken Gnome Galleon in the clear shallows; hermit crabs, shells, starfish and coconuts.
"""
import sys
import math

from jigsaw_common import *  # noqa: F401,F403

SKY0, SKY1, SKY2 = '#7fd0e6', '#9adcec', '#bfe9f0'
SEA_DEEP, SEA_MID, SEA_SHAL, SEA_LIGHT = '#1f8fa8', '#2bb3bf', '#5fd3cc', '#a6ece0'
SAND = ramp('#f2d9a0', '#d9b77a', '#fff0c8')
WETSAND = '#d9b77a'
PALM = ramp('#4fae4a', '#2f7a3a', '#8fd06a')
PALMD = ramp('#3a8a40', '#22603a', '#5fae4a')
TRUNK = ramp('#a8865a', '#7a5a38', '#d1b07a')
DRIFT = ramp('#c2ae8e', '#8f7a5e', '#e6d6b8')
THATCH = ramp('#d9b45a', '#a8822a', '#f2d68a')
CORAL = ramp('#f2827a', '#c8504f', '#ffb3a6')
CORALP = ramp('#f6a0b8', '#d0607f', '#ffd0dc')
TURQ = ramp('#2bb3bf', '#1a7f8f', '#8fe6e0')
COCO = ramp('#8a5a2a', '#5c3420', '#b07a3a')
SHELL = ramp('#6f8a3a', '#4a6028', '#9ab05a')   # turtle shell
TSKIN = ramp('#9aa86a', '#6a7a48', '#c4d08a')
STEEL = ramp('#c9d2d8', '#8a96a0', '#ffffff')
BEARD = ramp('#f1ece0', '#c9c5bc', '#ffffff')
SKIN = ramp('#f2c8a0', '#d9a07a', '#fff0d8')
RED = ramp('#d6322b', '#a8241f', '#f08a24')
YEL = ramp('#f0b92b', '#c98a14', '#f8dc6a')
WOOD = ramp('#b07a3a', '#7a4a1f', '#d9a35a')
ROCK = ramp('#9a9488', '#6f6a60', '#c9c3b5')
JUNGLE0, JUNGLE1 = '#4f9a7a', '#3f8068'
cv = new_canvas(SKY0)
r = rnd(1717)
r2 = rnd(303)


def shadow(x0, y0, x1, y1):
    cv.fill(ell(x0, y0, x1, y1) & sand, WETSAND)


def gnome(gx, gy, hat, tunic, s=1.0, arm=None):
    """Standing gnome, feet at (gx, gy), ~30 px tall at s=1. arm=(dx, dy) puts a hand there."""
    def q(v):
        return int(round(v * s))
    o = cv.obj()
    o.part(rect(gx - q(6), gy - q(3), gx - q(2), gy) | rect(gx + q(1), gy - q(3), gx + q(5), gy), ramp('#5c3420', '#3d2a1c', '#7a4a1f'), d=1)
    o.part(rrect(gx - q(6), gy - q(13), gx + q(6), gy - q(3), 2), tunic, d=2, contour=True)
    o.part(rect(gx - q(6), gy - q(6), gx + q(6), gy - q(5)), ramp('#7a4a1f', '#5c3420'), d=0)
    o.part(poly([(gx - q(6), gy - q(16)), (gx + q(6), gy - q(16)), (gx + 1, gy - q(5))]), BEARD, d=1, contour=True)
    o.part(rect(gx - q(4), gy - q(20), gx + q(4), gy - q(15)), SKIN, d=1)
    o.part(poly([(gx - q(7), gy - q(18)), (gx + q(7), gy - q(18)), (gx - q(3), gy - q(33))]), hat, d=2, contour=True)
    if arm:
        o.part(line([(gx + q(5), gy - q(11)), (gx + arm[0], gy + arm[1])], 3), tunic, d=1)
    o.draw()
    cv.fill(rect(gx - q(7), gy - q(19), gx + q(7), gy - q(18)), hat['s'])
    cv.dots([(gx - 2, gy - q(17)), (gx + 2, gy - q(17))], '#2a1a10')
    cv.dots([(gx, gy - q(16)), (gx + 1, gy - q(16))], '#e0907a')
    cv.dots([(gx - 3, gy - q(15)), (gx + 3, gy - q(15))], '#f0a0a0')
    if arm:
        cv.fill(rect(gx + arm[0] - 1, gy + arm[1] - 1, gx + arm[0] + 1, gy + arm[1] + 1), SKIN['b'])


def bez(p0, p1, p2, t):
    a = (1 - t) ** 2
    b = 2 * (1 - t) * t
    c = t * t
    return (a * p0[0] + b * p1[0] + c * p2[0], a * p0[1] + b * p1[1] + c * p2[1])


def frond(cx, cy, ang, ln, droop):
    """One palm frond: a drooping rib with leaflets hanging off both sides."""
    a = math.radians(ang)
    dx, dy = math.cos(a), math.sin(a)
    pts = []
    n = 10
    for i in range(n + 1):
        t = i / n
        pts.append((cx + dx * ln * t, cy + dy * ln * t + droop * t * t))
    m = line([(int(x), int(y)) for x, y in pts], 3)
    for i in range(1, n + 1):
        x0, y0 = pts[i - 1]
        x1, y1 = pts[i]
        tx, ty = x1 - x0, y1 - y0
        L = math.hypot(tx, ty) or 1
        tx, ty = tx / L, ty / L
        nx, ny = -ty, tx
        k = 6 - 3 * i // n
        for sgn in (1, -1):
            ex = x1 + sgn * nx * k + tx * 2
            ey = y1 + sgn * ny * k + ty * 2 + 3
            m |= line([(int(x1), int(y1)), (int(ex), int(ey))], 2)
    return m


def palm(base, top, ctrl, w0, w1, fronds_back, fronds_front, nuts=3):
    m = blank()
    pts = [bez(base, ctrl, top, i / 40) for i in range(41)]
    for i, (x, y) in enumerate(pts):
        w = w0 + (w1 - w0) * i / 40
        m |= ell(int(x - w), int(y - 2), int(x + w), int(y + 2))
    o = cv.obj()
    o.part(m, TRUNK, d=2)
    o.draw()
    for i in range(2, 40, 3):   # trunk rings, chevron-ish
        x, y = pts[i]
        w = w0 + (w1 - w0) * i / 40
        cv.fill(line([(int(x - w), int(y)), (int(x), int(y) + 1), (int(x + w), int(y))]) & m, TRUNK['s'])
        cv.dots([(int(x - w + 1), int(y) - 1)], TRUNK['r'])
    tx, ty = int(top[0]), int(top[1])
    mb = blank()
    for ang, ln, dr in fronds_back:
        mb |= frond(tx, ty, ang, ln, dr)
    o = cv.obj()
    o.part(mb, PALMD, d=1)
    o.draw()
    mf = blank()
    for ang, ln, dr in fronds_front:
        mf |= frond(tx, ty, ang, ln, dr)
    o = cv.obj()
    o.part(mf, PALM, d=1)
    o.draw()
    o = cv.obj()
    for k in range(nuts):
        nx, ny = tx - 5 + k * 4 + (k % 2), ty + 1 + (k % 2) * 3
        o.part(ell(nx - 3, ny - 3, nx + 3, ny + 3), COCO, d=1, contour=True)
    o.draw()
    for k in range(nuts):
        nx, ny = tx - 5 + k * 4 + (k % 2), ty + 1 + (k % 2) * 3
        cv.dots([(nx - 1, ny - 1)], '#d9a35a')


# ================================================================ sky: bands, sun, clouds, gulls
cv.fill(rect(0, 22, W - 1, 62), SKY1)
cv.fill(rect(0, 46, W - 1, 62), SKY2)
sx0, sy0 = 50, 16   # the midday sun, upper left (the light source)
for k in range(12):
    a = k * math.pi / 6
    cv.fill(line([(int(sx0 + math.cos(a) * 13), int(sy0 + math.sin(a) * 13)), (int(sx0 + math.cos(a) * 17), int(sy0 + math.sin(a) * 17))], 2), '#fff4b0')
cv.fill(ell(sx0 - 10, sy0 - 10, sx0 + 10, sy0 + 10), '#fff4b0')
cv.fill(ell(sx0 - 8, sy0 - 8, sx0 + 8, sy0 + 8), '#ffe46a')
cv.fill(ell(sx0 - 6, sy0 - 6, sx0 + 2, sy0 + 2), '#fff4b0')
for cx, cy, w in ((104, 12, 40), (168, 30, 44), (236, 8, 34), (290, 26, 30), (140, 50, 30), (78, 40, 26), (206, 44, 24)):
    m = ell(cx - w // 2, cy - 6, cx + w // 2, cy + 5) | ell(cx - w // 4, cy - 11, cx + w // 5, cy + 3) | ell(cx, cy - 8, cx + w // 2 - 5, cy + 4)
    m &= ~rect(0, cy + 3, W, H)
    cv.fill(m, '#ffffff')
    cv.fill(m & ~shift(m, -2, -2) & rect(0, cy - 2, W, cy + 3), '#d8eef2')
    cv.fill(m & rect(0, cy + 3, W, cy + 3), '#bfdfe8')
for bx, by in ((92, 30), (100, 26), (184, 14), (192, 18), (262, 40), (60, 50), (150, 8)):   # gulls
    cv.dots([(bx, by), (bx + 1, by - 1), (bx + 2, by - 1), (bx + 3, by), (bx + 4, by - 1), (bx + 5, by - 1), (bx + 6, by)], '#4a5a6a')
    cv.dots([(bx + 3, by + 1)], '#ffffff')

# ================================================================ far island with the Singing Waterfall (right), crab-shell isle (centre)
isl = poly([(176, 63), (196, 46), (214, 40), (232, 22), (250, 14), (266, 22), (280, 30), (300, 34), (300, 63)])
cv.fill(isl, JUNGLE0)
cv.fill(isl & ~shift(isl, 3, 3), '#6fb890')
x = 178
while x < W - 1:   # jungle canopy bumps
    x += r2(2, 5)
    col = isl[:, min(x, W - 1)]
    if col.any():
        ty = int(np.argmax(col)) + r2(3, 14)
        cv.dots([(x, ty), (x + 1, ty), (x, ty + 1), (x - 1, ty + 1)], JUNGLE1)
for px, py in ((206, 44), (222, 32), (284, 32), (296, 36)):   # tiny far palms on the ridge
    cv.fill(rect(px, py, px, py + 5), '#3f6a50')
    cv.dots([(px - 2, py), (px - 1, py - 1), (px + 1, py - 1), (px + 2, py), (px, py - 1)], '#2f6a50')
cliff = poly([(228, 28), (246, 26), (248, 63), (226, 63)])
cv.fill(cliff & isl, '#8a9a8a')
cv.fill(cliff & isl & ~shift(cliff, -2, 0), '#a8b5a5')
for k, wx in enumerate(range(233, 243)):   # the waterfall: hard white and aqua streaks
    cv.fill(rect(wx, 27 + (k % 3), wx, 60), '#ffffff' if k % 3 else '#a6ece0')
cv.fill(rect(232, 26, 243, 27), '#ffffff')
for k in range(5):   # spray puffs at the foot
    pm = ell(228 + k * 4, 56 - (k % 2) * 2, 236 + k * 4, 63)
    cv.fill(pm, '#ffffff')
    cv.fill(pm & ~shift(pm, -1, -1), '#d8eef2')
for nx, ny in ((252, 34), (258, 44), (222, 40)):   # the song: tiny notes drifting off the falls
    cv.fill(rect(nx + 2, ny - 4, nx + 2, ny), '#4e3a8a')
    cv.fill(rect(nx, ny, nx + 2, ny + 1), '#4e3a8a')
    cv.dots([(nx + 3, ny - 4), (nx + 4, ny - 3)], '#4e3a8a')
crab = ell(128, 52, 160, 70) & ~rect(0, 63, W, H)   # the Hurricane Crab's shell-island, claws up
cv.fill(crab, '#c86a5a')
cv.fill(crab & ~shift(crab, 2, 2), '#e08a72')
for cxx in (126, 160):
    cv.fill(ell(cxx - 3, 49, cxx + 3, 56) & ~ell(cxx - 1, 47, cxx + 2, 52), '#c86a5a')
    cv.fill(rect(cxx - 1, 55, cxx + 1, 62), '#c86a5a')
cv.dots([(138, 55), (149, 55), (138, 54), (149, 54)], '#2a1a10')   # stalk eyes
cv.fill(rect(138, 56, 138, 58) | rect(149, 56, 149, 58), '#a8504a')
cv.fill(rect(134, 58, 154, 58), '#4f9a7a')   # a fringe of palms on its back
cv.dots([(136, 57), (142, 57), (147, 57), (152, 57)], '#3f8068')

# ================================================================ the sea: deep at the horizon, shallows by the shore
sand = poly([(0, 100), (40, 103), (100, 109), (150, 115), (186, 126), (210, 142), (232, 165), (250, 199), (0, 199)])
sea = rect(0, 63, W - 1, H - 1) & ~sand
cv.fill(sea, SEA_MID)
cv.fill(sea & rect(0, 63, W - 1, 74), SEA_DEEP)
cv.fill(rect(0, 63, W - 1, 63), '#1a7f8f')
near = sand.copy()
for _ in range(16):
    near = dil4(near)
cv.fill(sea & near, SEA_SHAL)
near2 = sand.copy()
for _ in range(6):
    near2 = dil4(near2)
cv.fill(sea & near2, SEA_LIGHT)
for _ in range(170):   # ripples
    rx, ry = r(0, W - 8), r(64, H - 2)
    if sea[ry, rx] and sea[ry, rx + 6]:
        ln = 2 + (ry - 60) // 25 + r(0, 3)
        c = '#8fe6e0' if not near[ry, rx] else ('#ffffff' if near2[ry, rx] else '#a6ece0')
        if ry < 75:
            c = '#2bb3bf'
        cv.fill(line([(rx, ry), (rx + ln, ry)]), c)
foam = dil4(dil4(sand)) & ~sand
cv.fill(foam & sea, '#ffffff')
f2 = dil4(dil4(dil4(dil4(dil4(sand))))) & ~dil4(dil4(dil4(sand)))
for x in range(0, W, 9):
    cv.fill(f2 & rect(x, 0, x + 4, H), '#ffffff')

# ---------------------------------------------------------------- far sailboats and a whale spout
for bx, by, sc, scol in ((100, 72, 1, '#ffffff'), (276, 70, 1, '#f2827a'), (30, 82, 1, '#f0b92b')):
    cv.fill(poly([(bx, by - 2), (bx + 10, by - 2), (bx + 8, by + 1), (bx + 2, by + 1)]), '#7a4a1f')
    cv.fill(rect(bx + 5, by - 14, bx + 5, by - 2), '#4a2c1a')
    cv.fill(poly([(bx + 6, by - 14), (bx + 12, by - 3), (bx + 6, by - 3)]), scol)
    cv.fill(poly([(bx + 4, by - 11), (bx + 4, by - 3), (bx, by - 3)]), '#ffffff' if scol != '#ffffff' else '#bfe9f0')
    cv.fill(rect(bx - 1, by + 2, bx + 11, by + 2), '#8fe6e0')
wsx, wsy = 168, 68
cv.fill(ell(wsx - 7, wsy - 1, wsx + 7, wsy + 3) & ~rect(0, wsy + 2, W, H), '#3a5a70')
cv.dots([(wsx - 2, wsy - 1), (wsx + 2, wsy - 1)], '#5a7a90')
for k, (dx, dy) in enumerate(((0, -3), (0, -5), (-2, -7), (2, -7), (-4, -8), (4, -8), (0, -6))):
    cv.dots([(wsx + dx, wsy + dy)], '#ffffff')

# ================================================================ sand: wet band, speckle, ripples
wet = sand & dil4(dil4(dil4(dil4(foam))))
cv.fill(sand & ~wet, SAND['b'])
cv.fill(wet, WETSAND)
cv.fill(foam & sand, '#ffffff')
for _ in range(700):
    px, py = r(0, W - 1), r(100, H - 1)
    if sand[py, px] and not wet[py, px]:
        cv.dots([(px, py)], SAND['r'] if r(0, 2) else SAND['s'])
for _ in range(28):   # wind ripples in the dry sand
    px, py = r(0, 220), r(112, 196)
    if sand[py, px] and not wet[py, px]:
        cv.fill(line([(px, py), (px + 4, py - 1), (px + 8, py)]) & sand & ~wet, '#e6c88a')

# ================================================================ the far shore palm-scrub behind the tavern (left horizon)
for k, (fx, fy) in enumerate(((2, 98), (14, 96), (26, 98))):
    cv.fill(ell(fx - 6, fy - 5, fx + 6, fy + 4), PALMD['b'] if k % 2 else PALM['s'])
    cv.dots([(fx - 2, fy - 4), (fx + 1, fy - 5)], PALM['r'])

# ================================================================ Driftwood Tavern on stilts with palm-thatch roof and bandstand awning
for sxp in (40, 58, 76, 94, 110, 132, 150):   # stilts
    o = cv.obj()
    o.part(rect(sxp, 104, sxp + 3, 116 if sxp < 140 else 118), DRIFT, d=1)
    o.draw()
    cv.dots([(sxp + 1, 110)], DRIFT['s'])
shadow(34, 114, 156, 121)
o = cv.obj()
o.part(rect(32, 101, 154, 105), DRIFT, d=1)   # floor and deck
o.part(rect(38, 70, 112, 101), DRIFT, d=2)    # walls
o.draw()
for yy in range(72, 101, 4):   # silvered plank seams with knots, ragged ends
    cv.fill(rect(39, yy, 111, yy), '#8f7a5e')
    for k in range(3):
        kx = r(42, 108)
        cv.fill(rect(kx, yy - 2, kx, yy - 1), '#a8957a')
    cv.dots([(r(42, 108), yy + 2)], '#6f5a40')
for xx in range(36, 154, 5):   # deck plank ends
    cv.dots([(xx, 103)], '#8f7a5e')
cv.fill(rect(32, 105, 154, 105), '#6f5a40')
# door (round-topped, open, warm inside) and windows with turquoise shutters and shell charms
door = rect(68, 84, 82, 101) | ell(68, 78, 82, 92)
o = cv.obj()
o.part(dil4(dil4(door)), WOOD, d=1)
o.draw()
cv.fill(door, '#4a2c1a')
cv.fill(door & rect(70, 88, 80, 101), '#7a4a1f')
cv.fill(rect(73, 92, 77, 95), '#f5cf6a')   # lamp glow inside
cv.dots([(75, 91)], '#4a2c1a')
for wx in (44, 92):
    o = cv.obj()
    o.part(rect(wx, 78, wx + 12, 90), ramp('#f5cf6a', '#e8a317', '#fff4c0'), d=2)
    o.part(rect(wx - 5, 77, wx - 1, 91) | rect(wx + 13, 77, wx + 17, 91), TURQ, d=1, contour=True)
    o.draw()
    for yy in range(79, 91, 3):
        cv.fill(rect(wx - 4, yy, wx - 2, yy) | rect(wx + 14, yy, wx + 16, yy), '#1a7f8f')
    cv.fill(rect(wx + 6, 78, wx + 6, 90), '#4a2c1a')
    cv.fill(rect(wx - 1, 91, wx + 13, 93), '#b07a3a')
    for k, sc in enumerate(('#f6a0b8', '#ffffff', '#f2827a', '#f0b92b')):   # shell charms on the sill
        cv.dots([(wx + 1 + k * 3, 90), (wx + 2 + k * 3, 90), (wx + 1 + k * 3, 89)], sc)
# thatched roof
roof = poly([(26, 74), (76, 42), (126, 74)])
o = cv.obj()
o.part(roof, THATCH, d=3)
o.draw()
for k in range(26):   # straw strokes
    tx0 = r(36, 116)
    ty0 = r(50, 70)
    if roof[ty0, tx0] and roof[min(H - 1, ty0 + 4), tx0]:
        cv.fill(line([(tx0, ty0), (tx0 + (1 if tx0 > 76 else -1), ty0 + 4)]) & roof, THATCH['s'] if k % 2 else THATCH['r'])
for xx in range(28, 125, 3):   # ragged fringe
    cv.fill(rect(xx, 74, xx + 1, 76 + (xx // 3) % 2), THATCH['s'])
for k in range(4):   # roof bands of fresh fronds
    yy = 52 + k * 6
    hw = (yy - 42) * 50 // 32
    cv.fill(line([(76 - hw + 2, yy), (76 + hw - 2, yy)]), '#c99a40')
cv.fill(rect(68, 58, 84, 66), '#4a2c1a')   # loft hatch with a hanging conch
cv.fill(rect(70, 60, 82, 66), '#2bb3bf')
o = cv.obj()
o.part(poly([(74, 37), (80, 39), (78, 44), (73, 43)]), CORALP, d=1)
o.draw()
cv.fill(rect(75, 33, 75, 38), '#4a2c1a')   # flagpole with a pennant
cv.fill(poly([(76, 33), (83, 35), (76, 37)]), CORAL['b'])
# striped bandstand awning over the deck
aw = poly([(112, 64), (156, 70), (156, 76), (112, 70)])
for k in range(9):
    stripe = aw & rect(112 + k * 5, 0, 116 + k * 5, H)
    cv.fill(stripe, CORAL['b'] if k % 2 == 0 else '#fff4e8')
for k in range(9):   # scalloped edge
    sx = 113 + k * 5
    cv.fill(ell(sx - 1, 73, sx + 3, 79) & ~rect(0, 0, W, 74 + (k * 6) // 8), CORAL['b'] if k % 2 == 0 else '#fff4e8')
cv.fill(line([(112, 63), (156, 69)]), '#74462a')
cv.fill(aw & ~shift(aw, 0, -1) & rect(0, 72, W, H), '#c8504f')
for pxp in (153,):
    o = cv.obj()
    o.part(rect(pxp, 70, pxp + 2, 101), WOOD, d=1)
    o.draw()
# the drummer and his steel pans
gnome(133, 101, RED, TURQ, 0.85)
for dx in (118, 140):
    o = cv.obj()
    o.part(ell(dx, 88, dx + 12, 93), STEEL, d=1)
    o.part(rect(dx + 1, 91, dx + 11, 96), STEEL, d=2)
    o.draw()
    cv.fill(ell(dx + 2, 89, dx + 10, 92), '#8a96a0')
    cv.dots([(dx + 4, 90), (dx + 7, 91)], '#c9d2d8')
    cv.fill(line([(dx + 2, 97), (dx, 101)]) | line([(dx + 10, 97), (dx + 12, 101)]), '#4a2c1a')
cv.fill(line([(126, 84), (122, 89)]) | line([(140, 84), (144, 89)]), '#7a4a1f')   # sticks
cv.dots([(122, 89), (144, 89)], '#f2827a')
for k, (bx, by) in enumerate(((110, 84), (114, 82))):
    cv.dots([(bx, by), (bx + 1, by - 1), (bx + 1, by), (bx + 1, by + 1), (bx + 2, by - 2)], '#4e3a8a')
# bunting from the awning post to the leaning palm
bpts = [(156, 72), (166, 78), (176, 80), (186, 78)]
cv.fill(line(bpts), '#4a2c1a')
for k in range(5):
    bx = 158 + k * 6
    by = 74 + (3 if 2 <= k else 2) + (k * 3) // 4
    cv.fill(poly([(bx, by), (bx + 4, by), (bx + 2, by + 4)]), (CORAL['b'], YEL['b'], TURQ['b'], '#ffffff', CORALP['b'])[k])
# hanging lanterns along the eaves
for lx in (42, 108):
    cv.fill(rect(lx, 76, lx, 79), '#4a2c1a')
    o = cv.obj()
    o.part(rrect(lx - 2, 79, lx + 2, 84, 1), YEL, d=1)
    o.draw()

# ================================================================ pier with a kite-flying gnome, sloop moored at its end
pier = rect(154, 101, 208, 105)
for pxp in (164, 180, 196, 206):
    o = cv.obj()
    o.part(rect(pxp, 104, pxp + 2, 116), DRIFT, d=1)
    o.draw()
    cv.fill(rect(pxp - 2, 116, pxp + 4, 116), '#ffffff')
o = cv.obj()
o.part(pier, DRIFT, d=1)
o.draw()
for xx in range(157, 208, 4):
    cv.fill(rect(xx, 102, xx, 104), '#8f7a5e')
# sloop
hull = poly([(206, 106), (246, 106), (240, 115), (212, 115)])
o = cv.obj()
o.part(hull, TURQ, d=2)
o.part(rect(225, 66, 226, 106), WOOD, d=1)
o.draw()
cv.fill(rect(207, 107, 245, 108), '#ffffff')
cv.fill(rect(211, 116, 241, 116), '#1f8fa8')
sail = poly([(228, 68), (250, 102), (228, 102)])
jib = poly([(223, 72), (223, 102), (208, 102)])
o = cv.obj()
o.part(sail, ramp('#fff4e8', '#e6d6b8', '#ffffff'), d=2)
o.part(jib, ramp('#fff4e8', '#e6d6b8', '#ffffff'), d=1)
o.draw()
for k in range(3):
    cv.fill(sail & rect(0, 76 + k * 9, W, 79 + k * 9), CORAL['b'])
cv.fill(poly([(227, 60), (234, 62), (227, 64)]), YEL['b'])
cv.fill(line([(206, 104), (212, 108)]), '#4a2c1a')   # mooring line
# kite gnome at the pier end
kgx, kgy = 170, 101
gnome(kgx, kgy, YEL, CORAL, 0.9, arm=(8, -24))
kx, ky = 128, 24   # the trade-wind kite
cv.fill(line([(kgx + 8, kgy - 24), (160, 52), (kx + 6, ky + 14)]), '#4a5a6a')
kite = poly([(kx + 6, ky), (kx + 13, ky + 8), (kx + 6, ky + 15), (kx - 1, ky + 8)])
o = cv.obj()
o.part(kite, CORAL, d=1)
o.draw()
cv.fill(kite & rect(kx + 6, 0, W, ky + 8), TURQ['b'])
cv.fill(kite & rect(0, ky + 8, kx + 5, H), YEL['b'])
cv.fill(line([(kx + 6, ky + 1), (kx + 6, ky + 14)]) | line([(kx, ky + 8), (kx + 12, ky + 8)]), '#4a2c1a')
tail = [(kx + 6, ky + 15), (kx + 2, ky + 21), (kx + 5, ky + 27), (kx + 1, ky + 33)]
cv.fill(line(tail), '#4a2c1a')
for k, (tx, ty) in enumerate(tail[1:]):
    cv.dots([(tx - 1, ty), (tx + 1, ty), (tx, ty)], (CORALP['b'], YEL['b'], TURQ['b'])[k])

# ================================================================ leaning palm on the shore
palm((180, 130), (204, 38), (196, 96), 4, 3,
     [(200, 26, 8), (240, 22, 6), (-30, 24, 8), (160, 28, 12)],
     [(10, 30, 14), (-60, 18, 4), (135, 26, 16), (60, 22, 10), (-120, 18, 6), (30, 26, 18)], nuts=3)
shadow(166, 128, 196, 133)

# ================================================================ the Sunken Gnome Galleon in the clear shallows (bottom right)
gal = poly([(234, 176), (300, 168), (300, 199), (248, 199)]) & sea
cv.fill(gal, '#2f9fa8')
for xx in range(246, 300, 7):   # hull ribs under the water
    cv.fill(line([(xx, 199), (xx + 3, 174)]) & gal, '#1f7f8f')
cv.fill(line([(236, 177), (300, 169)], 2) & gal, '#4a7a70')
for px, py in ((258, 184), (276, 182), (292, 180)):   # portholes
    cv.fill(ell(px - 2, py - 2, px + 2, py + 2) & gal, '#1a5f6f')
    cv.dots([(px - 1, py - 1)], '#5fd3cc')
o = cv.obj()   # broken mast poking out of the water, with yard, crow's nest and a torn sail
o.part(line([(266, 186), (284, 122)], 3), WOOD, d=1)
o.part(line([(266, 140), (294, 148)], 2), WOOD, d=1)
o.part(rrect(278, 126, 290, 131, 1), WOOD, d=1)
o.draw()
torn = poly([(268, 142), (292, 149), (288, 164), (282, 158), (276, 166), (270, 160)])
o = cv.obj()
o.part(torn, ramp('#efe0c0', '#c9b48a', '#fff4d8'), d=2)
o.draw()
cv.fill(rect(276, 150, 282, 154) & torn, CORAL['s'])   # patch
cv.fill(rect(262, 186, 272, 187) & sea, '#ffffff')   # foam at the waterline
cv.fill(rect(260, 189, 274, 189) & sea, '#a6ece0')
cv.dots([(283, 120), (284, 119), (285, 120), (286, 119), (287, 120)], '#ffffff')   # gull on the masthead
cv.dots([(285, 121)], '#f0b92b')
o = cv.obj()   # a seed chest half sunk on the bow
o.part(rrect(240, 186, 252, 195, 1), WOOD, d=2)
o.draw()
cv.fill(rect(240, 189, 252, 189), '#f0b92b')
cv.dots([(246, 191)], '#f0b92b')
for cx, cy in ((296, 186), (232, 196), (286, 196)):   # coral heads
    m = blank()
    for k in range(4):
        m |= ell(cx - 4 + k * 2 - r2(0, 2), cy - 3 - (k % 2) * 3, cx + k * 2 - 1, cy + 2)
    o = cv.obj()
    o.part(m & sea, CORALP, d=1)
    o.draw()
for fx, fy, fc in ((256, 158, '#f0b92b'), (296, 172, '#f2827a'), (244, 152, '#f0b92b'), (290, 140, '#ffffff'), (222, 134, '#f2827a')):   # reef fish
    cv.fill(rect(fx, fy, fx + 3, fy + 1), fc)
    cv.dots([(fx + 4, fy - 1), (fx + 4, fy + 2)], fc)
    cv.dots([(fx, fy)], '#2a1a10')
for _ in range(12):   # sea-grass in the shallows
    gx, gy = r(210, 298), r(130, 170)
    if sea[gy, gx] and not gal[gy, gx]:
        cv.fill(line([(gx, gy), (gx + 1, gy - 4)]), '#3fa08a')

# ================================================================ tall palm (left edge) and the hammock
palm((10, 176), (30, 30), (2, 100), 5, 3,
     [(190, 28, 10), (-20, 30, 10), (250, 18, 4), (100, 22, 14)],
     [(-160, 30, 16), (-40, 30, 14), (20, 34, 18), (160, 26, 18), (60, 24, 14), (-90, 16, 4)], nuts=4)
post = rect(58, 116, 61, 150)
o = cv.obj()
o.part(post, DRIFT, d=1)
o.part(poly([(56, 112), (63, 112), (61, 117), (58, 117)]), CORALP, d=1)   # conch on top
o.draw()
shadow(52, 148, 68, 152)
shadow(18, 156, 56, 162)
ham = blank()
for k in range(5):
    ham |= line([(16, 128 + k // 2), (24, 136 + k), (36, 140 + k), (48, 136 + k), (58, 122 + k // 2)], 1)
o = cv.obj()
o.part(dil4(line([(18, 129), (26, 137), (36, 141), (47, 137), (57, 123)], 3)), CORAL, d=1)
o.draw()
hm = dil4(line([(18, 129), (26, 137), (36, 141), (47, 137), (57, 123)], 3))
for k in range(0, 44, 6):
    cv.fill(hm & rect(16 + k, 0, 18 + k, H), '#fff4e8')
for k in range(2, 44, 6):
    cv.fill(hm & rect(16 + k, 0, 17 + k, H), YEL['b'])
cv.fill(line([(12, 124), (18, 129)]) | line([(57, 123), (60, 118)]), '#4a2c1a')
# hammock gnome lying back, hat flopped, coconut drink on his belly
o = cv.obj()
o.part(ell(28, 128, 44, 138), TURQ, d=2, contour=True)   # belly
o.part(rect(44, 128, 52, 132), ramp('#5c3420', '#3d2a1c', '#7a4a1f'), d=1)   # boots up
o.part(ell(20, 124, 30, 133), SKIN, d=1)   # face
o.part(poly([(22, 130), (32, 126), (30, 134)]), BEARD, d=1, contour=True)
o.part(poly([(18, 126), (26, 120), (10, 112)]), RED, d=2, contour=True)   # flopped hat
o.draw()
cv.dots([(24, 127), (25, 127)], '#2a1a10')   # closed eyes
cv.dots([(22, 129), (27, 128)], '#f0a0a0')
o = cv.obj()
o.part(ell(34, 122, 40, 128), COCO, d=1)
o.draw()
cv.fill(line([(38, 123), (42, 117)]), CORAL['b'])
cv.fill(rect(35, 123, 36, 123), '#ffffff')
for k, (zx, zy) in enumerate(((28, 112), (32, 108))):   # snoozing bubbles
    cv.fill(ell(zx, zy, zx + 2 + k, zy + 2 + k), '#ffffff')

# ================================================================ turtle nesting beach (centre)
nest = ell(84, 150, 108, 166)
cv.fill(nest, '#c9a46a')
cv.fill(nest & ~shift(nest, 2, 2), '#a8844a')
for ex, ey in ((88, 155), (93, 154), (98, 156), (91, 159), (96, 160), (101, 158), (86, 160)):   # eggs
    cv.fill(ell(ex, ey, ex + 3, ey + 3), '#fff8ec')
    cv.dots([(ex + 2, ey + 2)], '#d9cfb8')
cv.fill(dil4(nest) & ~nest, '#e6c88a')
# mother turtle heading back to the sea
tx0, ty0 = 112, 150
for k in range(14):   # flipper tracks behind her
    cv.dots([(tx0 - 4 - k * 2, ty0 + 4 + (k % 2) * 10), (tx0 - 3 - k * 2, ty0 + 4 + (k % 2) * 10)], '#c9a46a')
shadow(tx0 - 2, ty0 + 14, tx0 + 34, ty0 + 20)
o = cv.obj()
o.part(ell(tx0 + 30, ty0 + 4, tx0 + 40, ty0 + 12), TSKIN, d=1)   # head
o.part(poly([(tx0 + 22, ty0 + 12), (tx0 + 34, ty0 + 14), (tx0 + 26, ty0 + 20)]) | poly([(tx0 + 6, ty0 + 12), (tx0 - 2, ty0 + 20), (tx0 + 12, ty0 + 15)]), TSKIN, d=1)
o.part(poly([(tx0 + 22, ty0 + 2), (tx0 + 32, ty0 - 4), (tx0 + 26, ty0 + 4)]) | poly([(tx0 + 2, ty0 + 4), (tx0 - 4, ty0), (tx0 + 6, ty0 + 2)]), TSKIN, d=1)
o.part(ell(tx0, ty0 - 2, tx0 + 32, ty0 + 16), SHELL, d=3, contour=True)
o.draw()
for hx_, hy_ in ((tx0 + 10, ty0 + 2), (tx0 + 20, ty0 + 2), (tx0 + 6, ty0 + 9), (tx0 + 16, ty0 + 9), (tx0 + 25, ty0 + 9)):   # scutes
    cv.fill(poly([(hx_, hy_ - 2), (hx_ + 4, hy_ - 2), (hx_ + 6, hy_ + 1), (hx_ + 4, hy_ + 4), (hx_, hy_ + 4), (hx_ - 2, hy_ + 1)]) & ~poly([(hx_ + 1, hy_ - 1), (hx_ + 3, hy_ - 1), (hx_ + 4, hy_ + 1), (hx_ + 3, hy_ + 3), (hx_ + 1, hy_ + 3), (hx_ - 1, hy_ + 1)]), SHELL['s'])
cv.dots([(tx0 + 37, ty0 + 7)], '#2a1a10')
cv.dots([(tx0 + 8, ty0 + 1), (tx0 + 9, ty0 + 1), (tx0 + 14, ty0)], SHELL['r'])
# hatchlings scurrying to the surf, little tracks behind them
HATCH = ((150, 150), (162, 158), (178, 146), (174, 166), (192, 156), (196, 172), (210, 160), (186, 180), (214, 178))
for hx_, hy_ in HATCH:
    for k in range(1, 4):
        cv.dots([(hx_ - k * 3, hy_ + 1 + k), (hx_ - k * 3, hy_ + 3 + k)], '#c9a46a')
    o = cv.obj()
    o.part(ell(hx_, hy_, hx_ + 5, hy_ + 4), ramp('#4a4a3a', '#2a2a20', '#6a6a50'), d=1)
    o.part(ell(hx_ + 5, hy_ + 1, hx_ + 7, hy_ + 3), ramp('#4a4a3a', '#2a2a20'), d=0)
    o.draw()
    cv.dots([(hx_ + 1, hy_ - 1), (hx_ + 4, hy_ + 5), (hx_ + 1, hy_ + 5), (hx_ + 4, hy_ - 1)], '#4a4a3a')
# gnome warden shading them with a palm frond
wgx, wgy = 166, 186
shadow(wgx - 9, wgy - 1, wgx + 9, wgy + 2)
fm = frond(wgx + 8, wgy - 26, -20, 18, 8)
gnome(wgx, wgy, CORAL, ramp('#4f6ab0', '#36508a', '#7f9ad0'), 1.0, arm=(8, -14))
o = cv.obj()
o.part(fm | line([(wgx + 8, wgy - 14), (wgx + 9, wgy - 26)], 2), PALM, d=1)
o.draw()
# a basket of coconuts beside the hammock post, footprints from the tavern steps to the nest
o = cv.obj()
o.part(rrect(66, 140, 80, 150, 2), WOOD, d=2)
o.draw()
for xx in range(67, 80, 2):
    cv.fill(rect(xx, 141, xx, 149), '#7a4a1f')
for cx_, cy_ in ((68, 136), (73, 135), (78, 137)):
    o = cv.obj()
    o.part(ell(cx_ - 3, cy_ - 3, cx_ + 3, cy_ + 3), COCO, d=1)
    o.draw()
    cv.dots([(cx_ - 1, cy_ - 1)], '#d9a35a')
for k in range(9):   # footprints
    fx_, fy_ = 120 + k * 5 + (k % 2) * 2, 120 + k * 3 + (k % 2) * 2
    cv.fill(rect(fx_, fy_, fx_ + 1, fy_ + 2), '#d9b77a')

# ================================================================ foreground: hermit-crab parade, shells, starfish, coconuts, sea-grapes
for k, (cx_, cy_) in enumerate(((22, 190), (36, 188), (50, 191), (64, 189), (78, 192))):
    o = cv.obj()
    o.part(ell(cx_, cy_ - 7, cx_ + 9, cy_ + 1), (CORALP, YEL, ramp('#fff4e8', '#d9cfb8', '#ffffff'), CORAL, TURQ)[k], d=2)
    o.part(rect(cx_ + 8, cy_ - 2, cx_ + 12, cy_ + 1), CORAL, d=1)
    o.draw()
    cv.fill(line([(cx_ + 2, cy_ - 5), (cx_ + 6, cy_ - 2), (cx_ + 4, cy_)]) , '#2a1a10' if k % 2 else '#74462a')
    cv.dots([(cx_ + 11, cy_ - 4), (cx_ + 12, cy_ - 4), (cx_ + 13, cy_ - 1)], '#2a1a10')
    cv.dots([(cx_ + 9, cy_ + 2), (cx_ + 11, cy_ + 2)], CORAL['s'])
for sx, sy, sc in ((114, 186, CORAL), (206, 192, YEL), (8, 150, CORALP)):   # starfish
    m = blank()
    for k in range(5):
        a = -math.pi / 2 + k * 2 * math.pi / 5
        m |= line([(sx, sy), (int(sx + math.cos(a) * 6), int(sy + math.sin(a) * 6))], 2)
    o = cv.obj()
    o.part(m, sc, d=1)
    o.draw()
    cv.dots([(sx, sy), (sx - 2, sy - 2)], sc['r'])
for k in range(26):   # shells
    sx, sy = r2(4, 230), r2(118, 197)
    if not sand[sy, sx] or sea[sy, sx]:
        continue
    c = ('#ffffff', '#f6a0b8', '#f2827a', '#fff4e8', '#f0b92b')[k % 5]
    if k % 2:
        cv.dots([(sx, sy), (sx + 1, sy), (sx + 2, sy), (sx + 1, sy - 1)], c)
        cv.dots([(sx + 1, sy + 1)], '#c8504f')
    else:
        cv.dots([(sx, sy), (sx + 1, sy - 1), (sx + 1, sy), (sx + 2, sy + 1)], c)
for cx_, cy_ in ((130, 196), (146, 192), (228, 186), (40, 172)):   # fallen coconuts
    o = cv.obj()
    o.part(ell(cx_ - 4, cy_ - 4, cx_ + 4, cy_ + 3), COCO, d=2)
    o.draw()
    cv.dots([(cx_ - 1, cy_ - 1), (cx_ + 1, cy_ - 1), (cx_, cy_ + 1)], '#3d2a1c')
for gx0, gy0 in ((96, 196), (156, 134), (0, 196), (214, 128), (232, 150)):   # sea-grape and beach grass tufts
    m = blank()
    for k in range(5):
        m |= ell(gx0 + k * 3 - 2, gy0 - 5 - (k % 2) * 3, gx0 + k * 3 + 3, gy0)
    o = cv.obj()
    o.part(m & sand, PALM, d=1)
    o.draw()
    cv.dots([(gx0 + 2, gy0 - 4), (gx0 + 8, gy0 - 6)], '#c8504f')
for rx_, ry_ in ((104, 124), (6, 132), (196, 132)):   # sea-washed rocks
    o = cv.obj()
    o.part(ell(rx_, ry_, rx_ + 9, ry_ + 6), ROCK, d=2)
    o.draw()
o = cv.obj()   # a little sandcastle with a shell door (front centre)
o.part(rect(190, 186, 204, 196) | rect(188, 180, 193, 196) | rect(201, 180, 206, 196), SAND, d=2)
o.draw()
cv.dots([(188, 179), (190, 179), (192, 179), (201, 179), (203, 179), (205, 179)], SAND['b'])
cv.fill(ell(195, 190, 199, 196), '#c9a46a')
cv.fill(rect(197, 178, 197, 186), '#4a2c1a')
cv.fill(poly([(198, 178), (203, 180), (198, 182)]), TURQ['b'])

# ================================================================ second-stream details: beached dinghy, wicker fish pot, drift log, crabs
o = cv.obj()   # an upturned dinghy hauled up on the left sand
dhull = poly([(22, 160), (70, 158), (64, 172), (30, 173)])
o.part(dhull, TURQ, d=2)
o.part(rect(24, 157, 70, 159), ramp('#fff4e8', '#d9cfb8', '#ffffff'), d=1)
o.draw()
for xx in range(30, 66, 8):
    cv.fill(line([(xx, 161), (xx + 1, 171)]) & dhull, TURQ['s'])
cv.fill(line([(30, 175), (36, 168)], 2) | line([(36, 168), (60, 150)], 2), WOOD['b'])   # oar leaning on it
cv.fill(ell(58, 146, 64, 152), WOOD['s'])
o = cv.obj()   # wicker fish pot by the pier steps
o.part(ell(144, 124, 162, 138), ramp('#c9a46a', '#8a6a3a', '#e6c88a'), d=2)
o.draw()
for xx in range(146, 162, 3):
    cv.fill(line([(xx, 125), (xx + 1, 137)]) & ell(144, 124, 162, 138), '#8a6a3a')
cv.fill(ell(150, 124, 156, 128), '#4a2c1a')
cv.fill(line([(162, 130), (176, 122), (182, 110)]), '#74462a')   # its rope up to the pier
o = cv.obj()   # drift log
o.part(rrect(84, 130, 116, 136, 2), DRIFT, d=2)
o.part(line([(104, 130), (110, 124)], 2), DRIFT, d=1)
o.draw()
cv.fill(ell(84, 130, 88, 136), '#e6d6b8')
cv.dots([(86, 133)], '#8f7a5e')
for cx_, cy_ in ((128, 140), (220, 196), (138, 172)):   # little red crabs sidling about
    o = cv.obj()
    o.part(ell(cx_, cy_, cx_ + 6, cy_ + 4), CORAL, d=1)
    o.draw()
    cv.dots([(cx_ - 1, cy_ - 1), (cx_ + 7, cy_ - 1), (cx_ - 1, cy_ + 5), (cx_ + 7, cy_ + 5), (cx_ + 2, cy_ - 1), (cx_ + 4, cy_ - 1)], '#c8504f')
    cv.dots([(cx_ + 2, cy_ + 1), (cx_ + 4, cy_ + 1)], '#2a1a10')
# kite duel: a second kite flown from the sloop's deck, and a pelican gliding past
gnome(238, 104, CORALP, YEL, 0.75, arm=(6, -16))
k2x, k2y = 178, 4
cv.fill(line([(244, 88), (214, 50), (k2x + 5, k2y + 12)]), '#4a5a6a')
kite2 = poly([(k2x + 5, k2y), (k2x + 11, k2y + 6), (k2x + 5, k2y + 13), (k2x - 1, k2y + 6)])
o = cv.obj()
o.part(kite2, TURQ, d=1)
o.draw()
cv.fill(kite2 & rect(0, k2y + 6, k2x + 4, H), '#ffffff')
cv.fill(kite2 & rect(k2x + 6, k2y + 7, W, H), CORAL['b'])
cv.fill(line([(k2x + 5, k2y + 1), (k2x + 5, k2y + 12)]), '#4a2c1a')
t2 = [(k2x + 5, k2y + 13), (k2x + 9, k2y + 18), (k2x + 6, k2y + 23)]
cv.fill(line(t2), '#4a2c1a')
for k, (tx, ty) in enumerate(t2[1:]):
    cv.dots([(tx - 1, ty), (tx + 1, ty), (tx, ty)], (YEL['b'], CORALP['b'])[k])
pex, pey = 146, 14
pel = ell(pex, pey, pex + 12, pey + 4) | poly([(pex + 2, pey + 1), (pex + 6, pey - 6), (pex + 9, pey + 1)]) | poly([(pex + 3, pey + 3), (pex + 8, pey + 3), (pex + 4, pey + 9)])
o = cv.obj()
o.part(pel, ramp('#fff4e8', '#c9d2d8', '#ffffff'), d=1)
o.draw()
cv.fill(rect(pex + 12, pey + 1, pex + 17, pey + 2), '#f0b92b')
cv.dots([(pex + 11, pey + 1)], '#2a1a10')
cv.fill(rect(pex - 3, pey + 1, pex - 1, pey + 2), '#8a96a0')
# dolphins arching in the open water, a buoy, a gnome fishing from a rowboat
for dx_, dy_ in ((256, 86), (278, 92)):
    dm = ell(dx_, dy_, dx_ + 16, dy_ + 10) & ~ell(dx_ + 3, dy_ + 4, dx_ + 13, dy_ + 14) & ~rect(0, dy_ + 8, W, H)
    dm |= poly([(dx_ + 7, dy_ - 1), (dx_ + 10, dy_ - 4), (dx_ + 10, dy_ + 1)])
    o = cv.obj()
    o.part(dm, ramp('#6a8aa0', '#4a6a80', '#a9c6d6'), d=1)
    o.draw()
    cv.dots([(dx_ + 13, dy_ + 4)], '#2a1a10')
    cv.fill(rect(dx_ - 1, dy_ + 9, dx_ + 3, dy_ + 9) | rect(dx_ + 13, dy_ + 9, dx_ + 18, dy_ + 9), '#ffffff')
o = cv.obj()
o.part(poly([(288, 104), (296, 104), (294, 112), (290, 112)]), CORAL, d=1)
o.part(rect(291, 98, 293, 104), YEL, d=1)
o.draw()
cv.fill(rect(286, 113, 298, 113), '#ffffff')
rbx, rby = 258, 120
o = cv.obj()
o.part(poly([(rbx, rby), (rbx + 22, rby), (rbx + 18, rby + 6), (rbx + 4, rby + 6)]), WOOD, d=2)
o.draw()
cv.fill(rect(rbx + 1, rby + 1, rbx + 21, rby + 1), YEL['b'])
cv.fill(rect(rbx - 2, rby + 7, rbx + 24, rby + 7), '#ffffff')
gnome(rbx + 10, rby + 1, TURQ, CORAL, 0.6, arm=(6, -8))
cv.fill(line([(rbx + 16, rby - 7), (rbx + 30, rby - 16)]), '#7a4a1f')
cv.fill(line([(rbx + 30, rby - 16), (rbx + 34, rby + 4)]), '#ffffff')
cv.remap({'#5a7a90': '#4a5a6a', '#3a5a70': '#4a5a6a', '#a8504a': '#c8504f', '#a8957a': '#8f7a5e', '#2f6a50': '#3f8068', '#3f6a50': '#3f8068',
          '#c9c5bc': '#d9cfb8', '#c9c3b5': '#d9cfb8', '#fff0d8': '#fff4e8', '#fff4d8': '#fff4e8', '#fff4c0': '#fff4b0', '#f8dc6a': '#ffe46a',
          '#6a6a50': '#6a7a48', '#2a2a20': '#2a1a10', '#4a7a70': '#1f7f8f', '#a8844a': '#c9a46a', '#a8b5a5': '#c9d2d8'})

if __name__ == '__main__':
    out = sys.argv[1] if len(sys.argv) > 1 else None
    n = save_pic(cv, 'sunsprinkle', out)
    print('sunsprinkle:', n, 'colours')
