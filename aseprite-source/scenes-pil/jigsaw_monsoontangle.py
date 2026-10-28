"""Jigsaw picture: THE MONSOON TANGLE (draft v0): game/assets/img/jigsaw/monsoontangle.jpg (+ -thumb). Usage: python3 -B aseprite-source/scenes-pil/jigsaw_monsoontangle.py [outdir]
A warm afternoon downpour over a floating-market canal: a grey-teal rain sky with a moon-kite, a hornbill and rising paper lanterns, a far smoking volcano
(the spice gardens on its foot), the root-wrapped temple under its fig on the right hilltop, rice terraces stepping down the hill and reflecting the sky with
a gnome planting seedlings and a water buffalo wading, a thatched stilt house on the left with lanterns and a coconut palm, a Lantern Bridge over the paddy
inlet, and the canal in front: a fruit boat whose gnome holds a giant leaf as an umbrella, a flower boat, a noodle boat, lotus, a frog, dragonflies,
mangrove roots in the right corner, and silver rain streaks over everything.
"""
import sys

from jigsaw_common import *  # noqa: F401,F403

# palette: jade green, canal teal, hot pink, mango orange (+ rain silver, umber wood)
SKY0, SKY1, SKY2 = '#8fb5b2', '#a3c6c0', '#b8d6ce'
CLOUD, CLOUDL, CLOUDD = '#c9ddd8', '#e2eeea', '#7a9e9e'
RAIN, RAIN2 = '#e6f2f0', '#c2dcda'
JADE = ramp('#4fae6a', '#2f8a4f', '#8fd07a', '#6abf5a')
DJADE = ramp('#2f8a4f', '#1f6a45', '#4fae6a')
PALM = ramp('#3f9a5a', '#1f6a45', '#7ac46a')
TEAL = ramp('#3a9aa0', '#2a7a84', '#8acfc8')
PADDY = ramp('#a6cfc6', '#86b8b0', '#cfe6e0')
PINK = ramp('#e8408a', '#b82a6a', '#f890b8')
ORG = ramp('#f08a24', '#c0601a', '#f8b850')
YEL = ramp('#f0c43a', '#c99a1a', '#f8e078')
RED = ramp('#d6322b', '#a8241f', '#f0603a')
THATCH = ramp('#c9a052', '#9a7434', '#e8c878')
BAMBOO = ramp('#b8b85a', '#86862e', '#dede8a')
WOOD = ramp('#9a5a2a', '#6a3a1a', '#c07a40')
DWOOD = ramp('#6a3a1a', '#4a2c1a', '#9a5a2a')
STONE = ramp('#8fa08e', '#6a7e70', '#b4c4b0')
MUD = ramp('#8a6a3a', '#6a4a2a', '#b08a50')
BUFF = ramp('#5e5e6a', '#3e3e4a', '#82828e')
SKIN = ramp('#f2c8a0', '#d9a07a', '#fff0d8')
BEARD = ramp('#f1ece0', '#c9c5bc', '#ffffff')
BLUE = ramp('#3f8fb0', '#25637d', '#a9d6ea')
PURP = ramp('#6a3a7a', '#4a2a5a', '#9a6aaa')
WHITE = ramp('#f4f0e8', '#d0ccc4', '#ffffff')
UMB = '#2a1a10'
cv = new_canvas(SKY0)
r = rnd(1907)
r2 = rnd(53)
r3 = rnd(2207)   # pass-1 details: a separate generator so the v0 layout does not shift
keep = blank()   # faces and small props the rain must not speckle


def clump(cx, cy, rx, ry, n, s0=5, s1=9):
    m = blank()
    for _ in range(n):
        ex, ey, s = cx + r(-rx, rx), cy + r(-ry, ry), r(s0, s1)
        m |= ell(ex - s, ey - s * 3 // 4, ex + s, ey + s * 3 // 4)
    return m


def foliage(m, rp, d=3, specks=10, alt=None):
    o = cv.obj()
    o.part(m, rp, d=d)
    o.draw()
    ys, xs = np.nonzero(m)
    inner = m & shift(m, 2, 0) & shift(m, -2, 0) & shift(m, 0, 2) & shift(m, 0, -2)
    for k in range(specks):
        i = r(0, len(xs) - 1)
        x, y = int(xs[i]), int(ys[i])
        if inner[y, x]:
            cv.dots([(x, y), (x + 1, y), (x + 1, y - 1)], rp['r'] if k % 3 else (alt or rp['s']))


def gnome(gx, gy, s, hat, tunic, kind='tall', lean=-1):
    """A gnome standing with feet at (gx, gy); s scales the 42 px Maplewold gnome. Returns the hand position (right side)."""
    def k(v):
        return int(round(v * s))
    o = cv.obj()
    o.part(rect(gx - k(7), gy - k(3), gx - k(2), gy) | rect(gx + k(1), gy - k(3), gx + k(6), gy), DWOOD, d=1)
    o.part(rrect(gx - k(7), gy - k(16), gx + k(7), gy - k(3), 2), tunic, d=2, contour=True)
    o.part(rect(gx - k(7), gy - k(7), gx + k(7), gy - k(6)), DWOOD, d=0)
    o.part(poly([(gx - k(7), gy - k(20)), (gx + k(7), gy - k(20)), (gx + k(1), gy - k(6))]), BEARD, d=1, contour=True)
    o.part(rect(gx - k(5), gy - k(25), gx + k(5), gy - k(19)), SKIN, d=1)
    if kind == 'tall':
        o.part(poly([(gx - k(8), gy - k(23)), (gx + k(8), gy - k(23)), (gx + lean * k(5), gy - k(42))]), hat, d=2, contour=True)
    else:   # wide conical rice-straw hat
        o.part(poly([(gx - k(13), gy - k(22)), (gx + k(13), gy - k(22)), (gx, gy - k(33))]), hat, d=2, contour=True)
    o.part(rect(gx + k(5), gy - k(15), gx + k(9), gy - k(12)), tunic, d=1)
    o.draw()
    if kind == 'tall':
        cv.fill(rect(gx - k(8), gy - k(24), gx + k(8), gy - k(23)), hat['s'])
    else:
        cv.fill(line([(gx - k(13), gy - k(22)), (gx + k(13), gy - k(22))]), hat['s'])
        cv.fill(line([(gx - k(6), gy - k(26)), (gx + k(6), gy - k(26))]), hat['s'])
    cv.dots([(gx - k(2), gy - k(22)), (gx + k(2), gy - k(22))], UMB)
    cv.dots([(gx, gy - k(21)), (gx + 1, gy - k(21))], '#e0907a')
    cv.dots([(gx - k(4), gy - k(20)), (gx + k(4), gy - k(20))], '#f0a0a0')
    cv.fill(rect(gx + k(8), gy - k(15), gx + k(10), gy - k(13)), SKIN['b'])
    cv.dots([(gx - 1, gy - k(7)), (gx, gy - k(7))], YEL['b'])
    keep[max(0, gy - k(44)):gy + 1, max(0, gx - k(14)):gx + k(14)] = True
    return gx + k(9), gy - k(14)


def lantern(x, y, rp, string=True):
    """A small paper lantern hanging at (x, y) top; 5 x 7."""
    if string:
        cv.dots([(x + 2, y - 1)], UMB)
    o = cv.obj()
    o.part(rrect(x, y, x + 4, y + 6, 1), rp, d=1)
    o.draw()
    cv.fill(rect(x, y + 3, x + 4, y + 3), rp['s'])
    cv.dots([(x + 1, y + 1)], rp['r'])
    cv.dots([(x + 2, y + 7)], YEL['b'])
    keep[y - 1:y + 8, x - 1:x + 6] = True


def boat(x0, x1, y0, h, rp=WOOD):
    """A long sampan hull, upturned prow and stern; returns its mask."""
    hull = poly([(x0, y0 - 4), (x0 + 6, y0), (x1 - 6, y0), (x1, y0 - 5), (x1 - 4, y0 + h), (x0 + 5, y0 + h)])
    o = cv.obj()
    o.part(hull, rp, d=2)
    o.draw()
    cv.fill(line([(x0 + 4, y0 + 1), (x1 - 4, y0 + 1)]), rp['s'])
    cv.fill(line([(x0 + 6, y0 + h - 2), (x1 - 6, y0 + h - 2)]), rp['s'])
    for xx in range(x0 + 10, x1 - 6, 9):
        cv.dots([(xx, y0 + 3), (xx, y0 + 4)], rp['r'])
    cv.dots([(x0 + 1, y0 - 3), (x1 - 1, y0 - 4)], ORG['b'])   # painted eye-spots at the ends
    return hull


def bez(p0, p1, p2, n=10):
    """Points along a quadratic curve (for roots that arch)."""
    out = []
    for i in range(n + 1):
        t = i / n
        out.append((int(round((1 - t) ** 2 * p0[0] + 2 * (1 - t) * t * p1[0] + t * t * p2[0])), int(round((1 - t) ** 2 * p0[1] + 2 * (1 - t) * t * p1[1] + t * t * p2[1]))))
    return out


def ring(cx, cy, rx, ry, col):
    m = ell(cx - rx, cy - ry, cx + rx, cy + ry)
    cv.fill(m & ~shift(m, 0, 1) | m & ~shift(m, 1, 0) | m & ~shift(m, -1, 0), col)


# ---------------------------------------------------------------- sky: bands, heavy rain clouds, rain curtain
cv.fill(rect(0, 34, W - 1, 99), SKY1)
cv.fill(rect(0, 58, W - 1, 99), SKY2)
for cx, cy, w in ((60, 4, 70), (150, 0, 60), (250, 6, 66), (196, 22, 40), (100, 30, 36), (30, 46, 34), (296, 32, 40), (140, 52, 30), (214, 56, 26)):
    m = ell(cx - w // 2, cy - 7, cx + w // 2, cy + 7) | ell(cx - w // 4, cy - 12, cx + w // 5, cy + 4) | ell(cx, cy - 10, cx + w // 2 - 5, cy + 5)
    m &= ~rect(0, cy + 5, W, H)
    cv.fill(m, CLOUD)
    cv.fill(m & ~shift(m, 2, 2), CLOUDL)
    cv.fill(m & rect(0, cy + 3, W, cy + 5), CLOUDD)
    for k in range(5):   # rain curtain hanging under the cloud
        xx = cx - w // 3 + k * w // 6 + r(-2, 2)
        cv.fill(line([(xx, cy + 7), (xx - 3, cy + 7 + r(8, 16))]), CLOUDD if k % 2 else SKY0)
# moon-kite (crescent) with tail, string down to the stilt-house deck
kx, ky = 118, 16
km = ell(kx - 9, ky - 9, kx + 9, ky + 9) & ~ell(kx - 4, ky - 11, kx + 12, ky + 6)
o = cv.obj()
o.part(km, ORG, d=2)
o.draw()
cv.fill(km & rect(0, ky + 2, W, ky + 3), PINK['b'])
for k in range(4):
    cv.dots([(kx - 2 + k * 3, ky + 10 + k * 3), (kx - 1 + k * 3, ky + 11 + k * 3)], (PINK['b'], YEL['b'])[k % 2])
cv.fill(line([(kx - 1, ky + 8), (76, 84)]), '#5a4a3a')
# hornbill flying left over the palm (black body, white tail band, big orange casque)
hbx, hby = 147, 13   # clear of the top edge and of the kite, over the empty sky band left of the plume
o = cv.obj()
o.part(ell(hbx, hby, hbx + 14, hby + 6), ramp('#3a3a3a', '#202020', '#5a5a5a'), d=1)
o.part(poly([(hbx + 3, hby + 1), (hbx + 12, hby + 1), (hbx + 16, hby - 9), (hbx + 6, hby - 6)]), ramp('#3a3a3a', '#202020', '#5a5a5a'), d=1)   # raised wing
o.part(rect(hbx + 14, hby + 2, hbx + 21, hby + 4), WHITE, d=0)
o.part(poly([(hbx - 8, hby + 3), (hbx + 1, hby), (hbx + 1, hby + 5)]), YEL, d=1)
o.part(rect(hbx - 3, hby - 2, hbx + 1, hby), ORG, d=0)
o.draw()
cv.dots([(hbx + 2, hby + 2)], '#ffffff')
cv.fill(rect(hbx + 18, hby + 2, hbx + 21, hby + 2), '#202020')

# ---------------------------------------------------------------- the volcano with its plume and the spice gardens on its foot
vol = poly([(98, 96), (150, 40), (160, 30), (176, 30), (186, 40), (244, 96)])
cv.fill(vol, '#7c9c9c')
cv.fill(vol & ~shift(vol, -4, 0) & rect(0, 0, 167, H), '#94b4b0')
for k in range(7):   # lava-rock gullies
    gx0 = 152 + k * 5
    cv.fill(line([(gx0, 36 + k % 3 * 3), (gx0 + (k - 3) * 6, 70 + k * 2)]) & vol, '#6a8a8c')
for k in range(8):   # plume puffs, drifting up and right
    px, py = 168 + k * 6, 26 - k * 3
    pm = ell(px - 4 - k // 2, py - 3, px + 4 + k // 2, py + 3)
    cv.fill(pm, '#d8e2de' if k < 6 else CLOUD)
    cv.fill(pm & ~shift(pm, -1, -1), '#a8b8b4')
for k in range(40):   # spice garden rows on the lower slope
    sx, sy = r(116, 228), r(72, 92)
    if vol[sy, sx] and vol[sy, min(W - 1, sx + 4)]:
        cv.fill(rect(sx, sy, sx + 3, sy), ('#5a8a5a', '#a86a3a', '#6a9a62')[k % 3])
# pass 1: break the plain grey cone: a zigzag pilgrim path, a tiny red-roofed shrine, low mist wisps, lava-rock speckle
path = [(176, 80), (186, 72), (170, 64), (182, 56), (168, 48), (172, 40)]
pm_ = line(path) & vol
cv.fill(pm_, '#a8b8b4')
cv.fill(shift(pm_, 1, 1) & vol & ~pm_, '#6a8a8c')
o = cv.obj()
o.part(rect(181, 51, 187, 55), STONE, d=1)
o.part(poly([(179, 51), (184, 46), (189, 51)]), RED, d=1)
o.draw()
cv.dots([(184, 53), (184, 54)], UMB)
for cx0, cy0, w in ((136, 64, 24), (200, 60, 22), (150, 76, 18), (214, 74, 16)):
    mm = ell(cx0 - w // 2, cy0 - 2, cx0 + w // 2, cy0 + 2) | ell(cx0 - w // 4, cy0 - 4, cx0 + w // 5, cy0 + 1)
    cv.fill(mm & vol, CLOUD)
    cv.fill(mm & vol & ~shift(mm, 0, 1), CLOUDL)
for k in range(45):
    sx, sy = r3(126, 216), r3(38, 70)
    if vol[sy, sx] and not pm_[sy, sx]:
        cv.dots([(sx, sy), (sx + 1, sy)], '#6a8a8c' if k % 3 else '#94b4b0')

# a few paper lanterns rising from last night's festival
for lx, ly, rp in ((206, 40, ORG), (196, 52, PINK), (218, 28, YEL), (138, 50, ORG), (226, 46, PINK)):
    lantern(lx, ly, rp, string=False)
    cv.dots([(lx + 1, ly + 8), (lx + 3, ly + 8)], ORG['r'])

# ---------------------------------------------------------------- far jungle band behind the hill
jung = poly([(0, 100), (0, 86), (300, 78), (300, 100)])
x = 90
while x < W + 6:
    w = r(10, 18)
    jung |= ell(x, 70 + r(0, 10), x + w, 96)
    x += w - r(2, 5)
cv.fill(jung & rect(90, 0, W, H), '#4f8a76')
cv.fill(jung & ~shift(jung, 2, 2) & rect(90, 0, W, H), '#6aa48a')
for k in range(6):   # far palm silhouettes
    px = 100 + k * 33 + r(-6, 6)
    py = 70 + r(-3, 4)
    cv.fill(line([(px, py), (px + 1, py + 16)]), '#3f7464')
    for dx, dy in ((-6, 2), (6, 2), (-4, -3), (5, -3), (0, -4)):
        cv.fill(line([(px, py), (px + dx, py + dy)]), '#3f7464')

# ---------------------------------------------------------------- the root-wrapped temple and its fig (right hilltop)
tx = 250
o = cv.obj()
for k, (hw, y0, y1) in enumerate(((22, 72, 86), (16, 62, 72), (11, 52, 62), (6, 42, 52))):
    o.part(rect(tx - hw, y0, tx + hw, y1), STONE, d=2)
o.part(poly([(tx - 3, 42), (tx + 3, 42), (tx, 32)]), STONE, d=1)
o.draw()
for hw, y0 in ((22, 72), (16, 62), (11, 52), (6, 42)):   # stone courses with staggered joints
    cv.fill(rect(tx - hw + 1, y0 + 5, tx + hw - 2, y0 + 5), STONE['s'])
    for jx in range(tx - hw + 3, tx + hw - 2, 5):
        cv.dots([(jx, y0 + 2), (jx + 2, y0 + 7)], STONE['s'])
cv.fill(ell(tx - 5, 74, tx + 5, 90) & rect(0, 0, W, 86), UMB)   # dark doorway
cv.fill(rect(tx - 14, 64, tx - 12, 69) | rect(tx + 12, 64, tx + 14, 69), '#4a5a50')   # niches
cv.dots([(tx - 1, 78), (tx + 1, 78)], YEL['b'])   # candle glow inside
FIGW = ramp('#8a7a62', '#5e5040', '#b0a084')
c1 = clump(tx + 2, 26, 24, 7, 13, 7, 11)
o = cv.obj()   # pass 1: thick limbs fan out of the shrine top, so the crown is held up, not floating
o.part(line([(tx + 1, 42), (tx - 2, 30), (tx - 16, 22)], 3) | line([(tx + 2, 40), (tx + 6, 30), (tx + 18, 24)], 3)
       | line([(tx + 3, 40), (tx + 14, 36), (tx + 25, 37)], 3) | line([(tx - 1, 38), (tx - 12, 34), (tx - 20, 33)], 2), FIGW, d=1)
o.draw()
foliage(c1, DJADE, specks=30, alt=JADE['b'])
c2 = clump(tx + 26, 36, 8, 5, 5, 6, 8)
foliage(c2, JADE, specks=12)
crown = c1 | c2
cv.fill(crown & ~shift(crown, 0, -2), DJADE['s'])   # dark underside of the canopy
cinner = crown & shift(crown, 4, 0) & shift(crown, -4, 0) & shift(crown, 0, 3) & shift(crown, 0, -3)
cys, cxs = np.nonzero(cinner)
for k in range(16):   # leaf-cluster scallops break the cloud shape inside the crown
    i = r3(0, len(cxs) - 1)
    x0, y0 = int(cxs[i]), int(cys[i])
    sc = ell(x0 - 4, y0 - 2, x0 + 4, y0 + 2)
    cv.fill(sc & ~shift(sc, 0, -1) & crown, DJADE['s'] if k % 2 else JADE['s'])
    cv.dots([(x0 - 1, y0 - 2), (x0, y0 - 2)], JADE['r'])
for ax in (tx - 21, tx - 15, tx - 9, tx + 11, tx + 17, tx + 23, tx + 31, tx + 35):   # aerial roots hanging from the canopy
    col = crown[:, ax]
    if not col.any():
        continue
    ay = int(np.nonzero(col)[0].max()) + 1
    ln = r3(6, 18)
    cv.fill(rect(ax, ay, ax, ay + ln), FIGW['s'])
    cv.fill(rect(ax - 1, ay, ax - 1, ay + ln // 2), FIGW['r'])
    cv.dots([(ax, ay + ln + 1)], FIGW['b'])
roots = poly([(tx - 4, 44), (tx - 1, 36), (tx - 2, 28), (tx + 4, 28), (tx + 3, 36), (tx + 7, 44)])   # the fig's own flared trunk sits in the top shrine
for pts in (((tx + 3, 40), (tx + 7, 50), (tx + 12, 52), (tx + 13, 61), (tx + 18, 63), (tx + 18, 72), (tx + 22, 75), (tx + 21, 86)),   # roots creep down the steps,
            ((tx - 1, 40), (tx - 6, 51), (tx - 12, 53), (tx - 11, 62), (tx - 17, 64), (tx - 16, 73), (tx - 21, 76), (tx - 22, 86)),   # hugging each ledge
            ((tx + 1, 42), (tx - 2, 54), (tx + 3, 62), (tx - 7, 70), (tx - 8, 78)),
            ((tx + 2, 42), (tx + 5, 56), (tx + 9, 64), (tx + 8, 73), (tx + 13, 80)),
            ((tx + 12, 53), (tx + 6, 58)), ((tx - 12, 54), (tx - 15, 58)), ((tx + 18, 66), (tx + 13, 69)), ((tx - 17, 66), (tx - 12, 70))):
    roots |= line(list(pts), 2 if len(pts) > 2 else 1)
roots &= ~(ell(tx - 5, 74, tx + 5, 90) & rect(0, 0, W, 86))
roots &= ~(crown & shift(crown, 0, -3))   # trunk shows only below the canopy
o = cv.obj()
o.part(roots, ramp('#8a7a62', '#5e5040', '#b0a084'), d=1)
o.draw()

# ---------------------------------------------------------------- rice terraces stepping down the hill, reflecting the sky
yy, xx = np.mgrid[0:H, 0:W]
hill = poly([(92, 132), (104, 104), (130, 92), (170, 88), (214, 86), (240, 86), (300, 84), (300, 132)])
BASES = (90, 98, 106, 114, 122, 130)
curves = []
for i, b in enumerate(BASES):
    curves.append(b + np.round(2.5 * np.sin(xx / (19.0 + i * 3) + i * 1.3) + (xx - 200) / 60.0).astype(int))
for i in range(len(BASES) - 1):
    top, bot = curves[i], curves[i + 1]
    band = hill & (yy >= top) & (yy < bot)
    cv.fill(band, PADDY['b'])
    cv.fill(band & (yy >= bot - 3), JADE['b'])   # grassy riser at the front of the step
    cv.fill(band & (yy == bot - 1), DJADE['b'])
    cv.fill(band & (yy == bot - 3), JADE['r'])
    cv.fill(band & (yy == top), MUD['r'])   # mud lip
    cv.fill(band & (yy == top + 1) & ((xx + i * 3) % 7 < 3), PADDY['s'])   # lip reflection
    for row in (3, 5):   # seedling rows
        cv.fill(band & (yy == top + row) & (yy < bot - 3) & ((xx + i * 2 + row) % 4 == 0), JADE['bo'])
        cv.fill(band & (yy == top + row - 1) & (yy < bot - 3) & ((xx + i * 2 + row) % 4 == 0) & ((xx // 4 + i) % 3 == 0), JADE['r'])
    for k in range(5):   # bright cloud reflections
        cxr = r(100, 296)
        cv.fill(band & (yy == top + 2) & (xx >= cxr) & (xx < cxr + r(4, 9)), PADDY['r'])
top0 = hill & (yy < curves[0])
cv.fill(top0, JADE['s'])   # jungle crown of the hill
for k in range(30):
    bx, by = r(100, 300), r(84, 96)
    if top0[by, bx]:
        cv.fill(ell(bx - 3, by - 2, bx + 3, by + 2) & top0, JADE['b'] if k % 2 else DJADE['s'])
cv.fill(hill & ~shift(hill, 2, 0) & (yy < 118), JADE['s'])
# the far end of every terrace drops in a little waterfall to the next
for i, wx in enumerate((292, 286, 280, 274)):
    y0 = int(curves[i + 1][0, wx]) - 3
    cv.fill(rect(wx, y0, wx + 1, y0 + 4), PADDY['r'])

# gnome planting seedlings in a wide straw hat, ankle deep
gp = gnome(156, 108, 0.62, THATCH, PINK, kind='wide')
cv.fill(rect(150, 107, 162, 108), PADDY['s'])
cv.fill(rect(gp[0], gp[1], gp[0] + 1, gp[1] + 5), JADE['bo'])   # a seedling bunch in hand
cv.dots([(gp[0] - 1, gp[1]), (gp[0] + 2, gp[1] - 1)], JADE['r'])
o = cv.obj()   # seedling basket on the lip
o.part(rrect(166, 101, 174, 106, 1), THATCH, d=1)
o.draw()
cv.dots([(168, 100), (170, 99), (172, 100), (169, 99)], JADE['bo'])
# water buffalo wading, egret on its back
bfx, bfy = 256, 102
cv.fill(rect(bfx - 2, bfy + 7, bfx + 26, bfy + 8), PADDY['s'])
o = cv.obj()
o.part(rect(bfx + 3, bfy + 4, bfx + 6, bfy + 8) | rect(bfx + 18, bfy + 4, bfx + 21, bfy + 8), BUFF, d=0)
o.part(ell(bfx, bfy - 6, bfx + 24, bfy + 6), BUFF, d=2)
o.part(line([(bfx - 4, bfy - 4), (bfx - 11, bfy - 6), (bfx - 13, bfy - 10)]) | line([(bfx - 1, bfy - 4), (bfx + 5, bfy - 7), (bfx + 6, bfy - 10)]), ramp('#d8ccb0', '#a89a80', '#f0e8d8'), d=0)
o.part(ell(bfx - 9, bfy - 5, bfx + 2, bfy + 6), BUFF, d=1, contour=True)
o.draw()
cv.dots([(bfx - 6, bfy - 1), (bfx - 1, bfy - 1)], UMB)
cv.dots([(bfx - 6, bfy - 2), (bfx - 1, bfy - 2)], '#f4f0e8')
cv.fill(rect(bfx - 6, bfy + 3, bfx - 2, bfy + 5), '#82828e')
cv.dots([(bfx - 5, bfy + 4), (bfx - 3, bfy + 4)], UMB)
cv.fill(rect(bfx + 24, bfy - 3, bfx + 25, bfy + 3), BUFF['s'])   # tail
o = cv.obj()   # egret
o.part(ell(bfx + 10, bfy - 12, bfx + 16, bfy - 7) | rect(bfx + 10, bfy - 16, bfx + 11, bfy - 11), WHITE, d=1)
o.draw()
cv.dots([(bfx + 8, bfy - 15), (bfx + 9, bfy - 15)], YEL['b'])
keep[bfy - 18:bfy + 9, bfx - 13:bfx + 27] = True

# ---------------------------------------------------------------- the canal (front), far bank with banana plants
canal = poly([(0, 150), (60, 148), (110, 142), (150, 138), (186, 136), (186, 126), (236, 126), (236, 136), (300, 138), (300, 199), (0, 199)])
bank = hill.copy() | rect(80, 126, 300, 140)
bank &= ~canal
cv.fill(bank & (yy >= 126), JADE['b'])
cv.fill(bank & ~shift(bank, 0, -2) & (yy > 126), MUD['b'])   # muddy edge above the water
cv.fill(canal, TEAL['b'])
cv.fill(canal & ~shift(canal, 0, 3), TEAL['s'])   # shade under the bank
for k in range(140):   # ripple dashes
    rx, ry = r(0, 296), r(140, 198)
    if canal[ry, rx] and canal[ry, min(W - 1, rx + 6)]:
        cv.fill(line([(rx, ry), (rx + r(2, 6), ry)]), TEAL['r'] if r(0, 2) else TEAL['s'])
for bx in (96, 112, 128, 248, 266):   # banana plants along the far bank
    by = 136
    cv.fill(rect(bx, by - 12, bx + 2, by), BAMBOO['s'])
    for dx, dy, ln in ((-1, -1, 9), (1, -1, 9), (-1, 0, 7), (1, -2, 6)):
        lf = line([(bx + 1, by - 12), (bx + 1 + dx * ln, by - 12 + dy * 4 - 3)], 3)
        o = cv.obj()
        o.part(lf, PALM, d=1)
        o.draw()
    cv.dots([(bx + 3, by - 9), (bx + 3, by - 8), (bx + 4, by - 8)], YEL['b'])

# ---------------------------------------------------------------- Lantern Bridge over the paddy inlet
brx0, brx1, bry = 180, 244, 128
mid = (brx0 + brx1) // 2
deck = blank()
for x in range(brx0, brx1 + 1):
    t = (x - mid) / (brx1 - brx0) * 2
    ytop = int(round(bry - 12 * (1 - t * t)))
    deck[ytop:ytop + 4, x] = True
o = cv.obj()
o.part(deck, WOOD, d=1)
for px in (brx0 + 2, brx0 + 14, mid - 2, brx1 - 16, brx1 - 4):   # piers
    t = (px - mid) / (brx1 - brx0) * 2
    ytop = int(round(bry - 12 * (1 - t * t)))
    o.part(rect(px, ytop + 3, px + 2, 140), BAMBOO, d=1)
o.draw()
rail = blank()
for x in range(brx0, brx1 + 1):
    t = (x - mid) / (brx1 - brx0) * 2
    ytop = int(round(bry - 12 * (1 - t * t)))
    rail[ytop - 7, x] = True
    if (x - brx0) % 8 == 0:
        rail[ytop - 7:ytop, x] = True
cv.fill(rail, BAMBOO['s'])
cv.fill(shift(rail, 0, -1) & ~rail, BAMBOO['r'])
for k, x in enumerate(range(brx0 + 4, brx1 - 2, 8)):
    t = (x - mid) / (brx1 - brx0) * 2
    ytop = int(round(bry - 12 * (1 - t * t)))
    lantern(x, ytop - 6, (RED, ORG, PINK, YEL)[k % 4])
cv.fill(canal & rect(brx0, 141, brx1, 142), TEAL['s'])   # bridge reflection
for x in range(brx0 + 4, brx1 - 2, 8):
    cv.dots([(x + 2, 144), (x + 2, 146)], ORG['r'])   # lantern reflections

# ---------------------------------------------------------------- coconut palm behind the stilt house (top-left)
o = cv.obj()
o.part(line([(4, 110), (12, 60), (30, 18)], 4), ramp('#8a7050', '#5e4a34', '#b09a74'), d=1)
o.draw()

fr = blank()
for dx, dy in ((-24, 8), (-18, -8), (-4, -14), (14, -12), (26, -2), (24, 14), (-10, 16), (8, 18)):
    fr |= line([(30, 16), (30 + dx // 2, 16 + dy // 2 - 3), (30 + dx, 16 + dy)], 3)
o = cv.obj()
o.part(fr, PALM, d=1)
o.draw()
for dx, dy in ((-24, 8), (-18, -8), (-4, -14), (14, -12), (26, -2), (24, 14), (-10, 16), (8, 18)):   # frond fingers
    ex, ey = 30 + dx, 16 + dy
    cv.dots([(ex, ey + 2), (ex - 1, ey + 3), (ex + 1, ey + 3)], PALM['s'])
for cx0, cy0 in ((27, 18), (32, 19), (29, 22)):   # coconuts
    o = cv.obj()
    o.part(ell(cx0, cy0, cx0 + 4, cy0 + 4), ramp('#6a8a3a', '#4a6a2a', '#9ab85a'), d=1)
    o.draw()

# ---------------------------------------------------------------- the stilt house (left): thatch, woven walls, deck, lanterns
for sx in (8, 22, 38, 56, 72, 88):   # stilts into the water
    o = cv.obj()
    o.part(rect(sx, 102, sx + 3, 156), BAMBOO, d=1)
    o.draw()
    for yy0 in (112, 124, 136, 148):
        cv.fill(rect(sx, yy0, sx + 3, yy0), BAMBOO['s'])
cv.fill(line([(10, 108), (40, 140)], 1) | line([(40, 108), (74, 140)], 1) | line([(58, 108), (90, 138)], 1), BAMBOO['s'])   # cross braces
cv.fill(canal & rect(0, 154, 96, 160), TEAL['s'])   # house shadow on the water
for sx in (8, 22, 38, 56, 72, 88):
    cv.fill(rect(sx + 1, 157, sx + 2, 164), BAMBOO['s'])   # stilt reflections
o = cv.obj()
o.part(rect(0, 98, 98, 103), WOOD, d=1)   # deck
o.part(rect(10, 70, 82, 98), BAMBOO, d=2)   # woven walls
o.draw()
for yy0 in range(72, 98, 3):   # weave
    for xx0 in range(11 + (yy0 // 3) % 2 * 2, 82, 4):
        cv.fill(rect(xx0, yy0, xx0 + 1, yy0), BAMBOO['s'])
for xx0 in range(2, 98, 6):
    cv.dots([(xx0, 100)], WOOD['s'])
o = cv.obj()
o.part(rect(52, 78, 66, 98), DWOOD, d=1, contour=True)   # open door
o.part(rect(18, 78, 34, 90), DWOOD, d=1, contour=True)   # window
o.draw()
cv.fill(rect(54, 80, 64, 98), '#3a2414')
cv.fill(rect(20, 80, 32, 88), YEL['b'])
cv.fill(rect(26, 80, 26, 88) | rect(20, 84, 32, 84), DWOOD['b'])
cv.fill(rect(16, 90, 36, 91), WOOD['b'])   # shutter prop
gnome_cat = None
roof = poly([(-6, 74), (6, 46), (20, 36), (48, 28), (76, 36), (92, 46), (104, 74), (92, 70), (48, 66), (4, 70)])
o = cv.obj()
o.part(roof, THATCH, d=3)
o.draw()
for k in range(9):   # thatch layers: wavy dark lines with straw ends
    y0 = 38 + k * 4
    cv.fill(line([(0, y0 + 3), (24, y0), (48, y0 - 1), (72, y0), (100, y0 + 3)]) & roof & ~shift(roof, 0, -2), THATCH['s'])
for k in range(30):
    sx, sy = r(4, 98), r(34, 70)
    if roof[sy, sx] and roof[min(H - 1, sy + 2), sx]:
        cv.dots([(sx, sy), (sx, sy + 1)], THATCH['r'] if k % 2 else THATCH['s'])
cv.fill(line([(4, 46), (-2, 38)], 2) | line([(92, 46), (100, 38)], 2), DWOOD['b'])   # upturned gable horns
cv.fill(line([(20, 36), (48, 24), (76, 36)], 2), DWOOD['b'])   # ridge beam
for dx in range(4, 100, 4):   # drips off the eaves
    ey = 72 if 10 < dx < 92 else 74
    cv.dots([(dx, ey + 2 + (dx % 3)), (dx, ey + 5 + (dx % 3))], RAIN)
for k, lx in enumerate((8, 38, 70, 92)):
    lantern(lx, 72 + (k % 2) * 2, (PINK, ORG, PINK, RED)[k])
# deck life: potted orchids, a rain barrel, the kite-flying gnome, a gecko
for px, rp in ((4, PINK), (40, WHITE), (88, PINK)):
    o = cv.obj()
    o.part(rect(px, 91, px + 6, 97), ramp('#b8603a', '#8a4024', '#d8805a'), d=1)
    o.draw()
    cv.fill(rect(px + 3, 86, px + 3, 91), JADE['s'])
    cv.dots([(px + 1, 86), (px + 2, 85), (px + 4, 86), (px + 5, 87), (px + 2, 88)], rp['b'])
    cv.dots([(px + 3, 86)], YEL['b'])
o = cv.obj()
o.part(rrect(42, 84, 50, 97, 1), WOOD, d=2)   # rain barrel catching the gutter
o.draw()
cv.fill(rect(42, 88, 50, 88) | rect(42, 94, 50, 94), DWOOD['s'])
cv.fill(rect(43, 84, 49, 85), TEAL['r'])
hd = gnome(76, 97, 0.5, ORG, BLUE, lean=1)
cv.fill(line([hd, (76, 84)]), '#5a4a3a')
cv.dots([(28, 94), (29, 95), (30, 94), (29, 93), (29, 96), (31, 96)], '#8ab84a')   # gecko on the wall
cv.dots([(27, 93), (31, 93), (27, 96)], '#5a8a2a')
# ladder down to the water
lad = rect(92, 103, 93, 150) | rect(99, 103, 100, 150)
for yy0 in range(106, 150, 5):
    lad |= rect(92, yy0, 100, yy0)
o = cv.obj()
o.part(lad, BAMBOO, d=1)
o.draw()

# ---------------------------------------------------------------- noodle boat by the bridge, steam in the rain
nb = boat(150, 184, 142, 6)
o = cv.obj()
o.part(rect(156, 132, 168, 141), DWOOD, d=1)   # stove box
o.part(ell(157, 128, 167, 134), STONE, d=1)   # pot
o.draw()
cv.fill(rect(158, 135, 160, 139), ORG['b'])   # fire glow
for k in range(3):
    cv.fill(ell(159 + k * 3, 120 - k * 5, 164 + k * 3, 124 - k * 5), CLOUDL)
for bx0 in (170, 175):   # bowls
    cv.fill(rect(bx0, 139, bx0 + 3, 141), WHITE['b'])
    cv.dots([(bx0 + 1, 138)], YEL['b'])
gnome(178, 141, 0.45, RED, JADE)
keep[118:150, 150:186] = True

# ---------------------------------------------------------------- mangrove roots and mudbank (bottom-right)
mud = poly([(238, 199), (250, 184), (270, 176), (300, 170), (300, 199)])
cv.fill(mud, MUD['b'])
cv.fill(mud & ~shift(mud, 0, -2), MUD['r'])
for k in range(20):
    mx, my = r(246, 298), r(178, 198)
    if mud[my, mx]:
        cv.dots([(mx, my), (mx + 1, my)], MUD['s'])
mroots = blank()
for x0, y0, x1, y1 in ((283, 146, 240, 192), (284, 150, 256, 198), (286, 152, 270, 190), (292, 150, 298, 186), (283, 138, 250, 170), (290, 144, 300, 168), (285, 158, 280, 199), (284, 134, 262, 176)):
    mroots |= line(bez((x0, y0), (x1 + (x0 - x1) // 3, y0 - 6), (x1, y1), 12), 2)
o = cv.obj()
o.part(poly([(284, 112), (291, 112), (295, 160), (281, 160)]), ramp('#7a6a58', '#54463a', '#a09080'), d=2)
o.part(mroots, ramp('#7a6a58', '#54463a', '#a09080'), d=1)
o.draw()
foliage(clump(282, 116, 18, 8, 10, 6, 9), DJADE, specks=24, alt=JADE['b'])
for k in range(5):   # propagule pods hanging
    px = 270 + k * 6
    cv.fill(rect(px, 124 + k % 2 * 3, px, 130 + k % 2 * 3), JADE['s'])
o = cv.obj()   # crab on the mud
o.part(ell(262, 184, 270, 189), RED, d=1)
o.draw()
cv.dots([(261, 183), (271, 183), (260, 182), (272, 182), (264, 183), (268, 183)], RED['s'])
cv.dots([(264, 184), (268, 184)], UMB)
cv.dots([(261, 189), (263, 190), (269, 190), (271, 189)], RED['s'])

# ---------------------------------------------------------------- the fruit boat: gnome under a giant leaf umbrella (focal)
fbx0, fbx1, fby = 70, 150, 170
cv.fill(canal & rect(fbx0 + 4, fby + 10, fbx1 - 4, fby + 12), TEAL['s'])   # hull reflection
cv.fill(canal & rect(fbx0 + 8, fby + 13, fbx1 - 10, fby + 13), WOOD['s'])
for k in range(3):   # wake
    cv.fill(line([(fbx0 - 4 - k * 5, fby + 3 + k), (fbx0 - 8 - k * 5, fby + 7 + k * 2)]), TEAL['r'])
fx, fy = 132, 172
lh = gnome(fx, fy, 0.82, PINK, ORG, lean=-1)
o = cv.obj()   # leaf stalk and the huge taro leaf held overhead, dripping
o.part(line([lh, (fx + 4, 124)], 2), JADE, d=0)
leaf = poly([(fx - 26, 132), (fx - 18, 120), (fx - 4, 113), (fx + 12, 112), (fx + 26, 118), (fx + 32, 130), (fx + 20, 128), (fx + 4, 126), (fx - 10, 129)])
o.part(leaf, JADE, d=2)
o.draw()
cv.fill(line([(fx + 4, 124), (fx - 20, 128)]) & leaf, JADE['s'])
cv.fill(line([(fx + 4, 124), (fx + 26, 124)]) & leaf, JADE['s'])
for ax, ay in ((fx - 12, 116), (fx - 2, 114), (fx + 10, 114), (fx + 20, 118)):
    cv.fill(line([(fx + 4, 124), (ax, ay)]) & leaf, JADE['s'])
for dx in (-26, -12, 4, 20, 32):   # drops off the leaf rim
    ex = fx + dx
    cv.dots([(ex, 134), (ex, 137), (ex - 1, 141)], RAIN)
keep[110:136, fx - 28:fx + 34] = True
hull = boat(fbx0, fbx1, fby, 9)
for px, py, s, rp in ((78, 162, 4, ramp('#a8c84a', '#7a9a2a', '#d0e87a')), (86, 160, 5, ramp('#a8c84a', '#7a9a2a', '#d0e87a')), (95, 163, 4, PURP), (102, 160, 4, PURP),
                      (110, 162, 4, RED), (116, 164, 3, RED), (92, 156, 4, YEL), (84, 155, 3, ORG), (106, 155, 4, ramp('#8a9a3a', '#5a6a2a', '#b0c060'))):
    o = cv.obj()
    o.part(ell(px - s, py - s, px + s, py + s), rp, d=1)
    o.draw()
for px, py in ((110, 159), (116, 161), (113, 157)):   # rambutan hairs
    cv.dots([(px - 1, py - 2), (px + 2, py - 1), (px, py + 3)], RED['r'])
cv.dots([(102, 156), (95, 159)], JADE['s'])   # mangosteen caps
for k in range(5):   # durian spikes
    cv.dots([(103 + k % 3 * 2, 152 + k // 3 * 2)], '#5a6a2a')
o = cv.obj()   # starfruit
o.part(poly([(120, 160), (126, 157), (128, 164), (122, 166)]), YEL, d=1)
o.draw()
cv.fill(rect(70, 160, 76, 168), THATCH['s'])   # rope coil at the prow
cv.dots([(71, 162), (73, 162), (75, 164), (72, 166)], THATCH['r'])
keep[148:182, 68:152] = True

# ---------------------------------------------------------------- the flower boat (lower centre-right)
cv.fill(canal & rect(184, 194, 236, 196), TEAL['s'])
gnome(228, 186, 0.6, BLUE, PINK, kind='wide')
o = cv.obj()   # paddle
o.part(line([(232, 175), (240, 196)], 2), WOOD, d=0)
o.part(ell(237, 193, 243, 199), WOOD, d=1)
o.draw()
fh = boat(176, 238, 186, 8, ramp('#3f8fb0', '#25637d', '#a9d6ea'))
for k in range(16):   # orchids and lotus heaped in the hull
    px, py = 182 + k * 3 + r(-1, 1), 182 - (k % 3) * 2 - r(0, 2)
    rp = (PINK, WHITE, PURP, PINK, ORG)[k % 5]
    o = cv.obj(outline=False)
    o.part(ell(px - 2, py - 2, px + 2, py + 2), rp, d=1)
    o.draw()
    cv.dots([(px, py)], YEL['b'])
for px in (186, 200, 214):
    cv.fill(rect(px, 172, px, 180), JADE['s'])
    o = cv.obj()
    o.part(poly([(px - 3, 172), (px, 166), (px + 3, 172), (px, 174)]), PINK, d=1)
    o.draw()
keep[164:200, 176:244] = True

# ---------------------------------------------------------------- lotus and lily pads, frog, rain rings, dragonflies
pads = ((6, 172, 9), (24, 184, 11), (2, 192, 7), (44, 190, 9), (52, 172, 7), (160, 186, 8), (150, 196, 7), (66, 196, 6), (34, 162, 6), (254, 150, 7), (240, 160, 6))
for px, py, s in pads:
    pm = ell(px - s, py - s // 2, px + s, py + s // 2) & ~poly([(px, py), (px + s + 1, py - 2), (px + s + 1, py + 1)])
    o = cv.obj()
    o.part(pm, JADE, d=1)
    o.draw()
    cv.fill(line([(px, py), (px - s + 2, py)]) & pm, JADE['s'])
for px, py in ((12, 166), (30, 176), (48, 182), (162, 178), (6, 186)):   # lotus flowers on stems
    cv.fill(rect(px, py, px, py + 6), JADE['s'])
    o = cv.obj()
    o.part(poly([(px - 5, py - 4), (px - 1, py), (px - 3, py)]) | poly([(px + 5, py - 4), (px + 1, py), (px + 3, py)]), PINK, d=0)
    o.part(ell(px - 3, py - 5, px + 3, py) | poly([(px - 2, py - 4), (px, py - 9), (px + 2, py - 4)]), PINK, d=1, rim=True)
    o.draw()
    cv.fill(line([(px, py - 7), (px, py - 2)]), PINK['s'])
    cv.dots([(px - 2, py - 3), (px + 2, py - 3)], PINK['s'])
    cv.dots([(px - 1, py - 1), (px + 1, py - 1)], YEL['b'])
    keep[py - 9:py + 7, px - 5:px + 6] = True
for px, py in ((58, 164), (170, 194)):   # seed pods
    cv.fill(rect(px, py, px, py + 6), JADE['s'])
    cv.fill(rect(px - 2, py - 2, px + 2, py), '#8ab84a')
    cv.dots([(px - 1, py - 1), (px + 1, py - 1)], '#4a6a2a')
o = cv.obj()   # frog on the big pad
o.part(ell(20, 176, 30, 183), ramp('#7ac44a', '#4a9a2a', '#a8e07a'), d=1)
o.part(ell(19, 174, 23, 178) | ell(26, 174, 30, 178), ramp('#7ac44a', '#4a9a2a', '#a8e07a'), d=0)
o.draw()
cv.dots([(21, 175), (28, 175)], UMB)
cv.fill(rect(22, 180, 27, 180), '#f0e08a')
keep[172:186, 17:33] = True
for k in range(60):   # rain rings on the water
    cx0, cy0 = r(2, 296), r(146, 197)
    if canal[cy0, cx0] and not keep[cy0, cx0] and not hull[cy0, cx0] and canal[min(H - 1, cy0 + 2), max(0, cx0 - 4)] and canal[cy0, min(W - 1, cx0 + 4)]:
        ring(cx0, cy0, r(2, 4), 1, TEAL['r'] if k % 3 else RAIN2)
for dx0, dy0, rp in ((176, 158, BLUE), (60, 136, RED), (246, 166, ORG), (140, 96, BLUE), (106, 116, RED)):   # dragonflies
    cv.fill(rect(dx0, dy0, dx0 + 6, dy0), rp['s'])
    cv.dots([(dx0, dy0), (dx0 + 1, dy0)], rp['b'])
    cv.dots([(dx0 + 1, dy0 - 1), (dx0 + 2, dy0 - 2), (dx0 + 3, dy0 - 1), (dx0 + 1, dy0 + 1), (dx0 + 2, dy0 + 2), (dx0 + 3, dy0 + 1)], RAIN)
    keep[dy0 - 3:dy0 + 4, dx0 - 1:dx0 + 8] = True

# ---------------------------------------------------------------- rain: slanting silver streaks over the whole frame
for k in range(300):
    x0, y0 = r(0, W + 20), r(-4, H - 2)
    ln = 3 if y0 < 100 else 4
    m = line([(x0, y0), (x0 - 1, y0 + ln)]) & ~keep
    cv.fill(m, RAIN if k % 3 else RAIN2)

# fold rare one-off tones into their neighbours (scene colour cap ~100)
cv.remap({'#5a8a2a': '#2f8a4f', '#d8ccb0': '#f4f0e8', '#fff0d8': '#ffffff', '#6a9a62': '#6aa48a', '#c9c5bc': '#d0ccc4', '#f0e08a': '#f8e078', '#5a8a5a': '#4f8a76',
          '#b0c060': '#a8c84a', '#d0e87a': '#dede8a', '#4a9a2a': '#2f8a4f', '#a8e07a': '#8fd07a', '#7a9a2a': '#86862e', '#f0e8d8': '#f4f0e8', '#5a6a2a': '#4a6a2a',
          '#b4c4b0': '#b8d6ce', '#5a5a5a': '#5e5e6a', '#9ab85a': '#a8c84a', '#6a8a3a': '#86862e', '#a86a3a': '#9a5a2a', '#4a5a50': '#5e5040', '#5e4a34': '#5e5040',
          '#b09a74': '#b0a084'})

if __name__ == '__main__':
    out = sys.argv[1] if len(sys.argv) > 1 else None
    n = save_pic(cv, 'monsoontangle', out)
    print('monsoontangle:', n, 'colours')
