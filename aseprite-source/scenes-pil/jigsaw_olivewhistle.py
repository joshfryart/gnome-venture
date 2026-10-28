"""Jigsaw picture: OLIVEWHISTLE SHORE (v2.0.87): game/assets/img/jigsaw/olivewhistle.jpg (+ -thumb). Usage: python3 -B aseprite-source/scenes-pil/jigsaw_olivewhistle.py [outdir]
Golden hour on a Mediterranean hillside: a low sun over the sea at the upper left (sun glitter, Cinderpeak smoking on the horizon, the sleeping-cat isle,
a sailboat, a goat ferry, a leaping dolphin), a breakwater with the little whitewashed harbour light, painted fishing boats in the harbour, a quay with an
old fisher mending nets on a crate, a sardine grill and a pirate-gull; stone steps climbing to the Olive Press Piazza with a donkey carrying lemons; the great
stone press wheel turned by a gnome, oil jars, a vine pergola with a checked-cloth table and two gnomes eating; terraced olive groves with nets, goats with
bells and a gnome combing a tree; at the top a terracotta-roof village with a bell tower and cypresses. Hillside on the right, sea on the left (light from the upper left).
"""
import sys

from jigsaw_common import *  # noqa: F401,F403

# ---------------------------------------------------------------- palette: sun-baked ochre, olive green, sea blue, terracotta (+ golden sky)
OCHRE = ramp('#d9a855', '#b07f3a', '#f0cc80')
DRY = ramp('#c9a85a', '#a6843f', '#e2c47a')
TERRA = ramp('#c8643a', '#9a4426', '#e88a5a')
ROOF = ramp('#c25a32', '#8f3a22', '#e8845a')
OLIVE = ramp('#8a9a52', '#5f6f34', '#b8c48a')
SILVER = ramp('#9fae6a', '#6f7f40', '#cdd6a0')
CYP = ramp('#4a6a32', '#2f4a24', '#6f8a44')
SEA0, SEA1, SEA2, SEA3 = '#6fb6d0', '#3f93bf', '#2f78aa', '#25637d'
FOAM = '#d8eef0'
GLIT = '#fff2b0'
STONE = ramp('#d8c6a0', '#a8946e', '#f0e4c4')
GREY = ramp('#b9b2a2', '#8a8474', '#d8d2c2')
WALL = ramp('#f0e0b8', '#c9ad7a', '#fff4d8')     # whitewash / limewash
WALL2 = ramp('#e8b878', '#c08a4a', '#f6d49a')    # ochre plaster
WOOD = ramp('#b07a3a', '#7a4a1f', '#d9a35a')
BARK = ramp('#7a5a3a', '#4f3a24', '#9a7a52')
SHUT = ramp('#3f8fb0', '#25637d', '#7fc0d8')     # blue shutters
LEMON = ramp('#f2d23a', '#c9a414', '#fff08a')
BEARD = ramp('#f1ece0', '#c9c5bc', '#ffffff')
SKIN = ramp('#f2c8a0', '#d9a07a', '#fff0d8')
RED = ramp('#d6322b', '#a8241f', '#f08a5a')
BLUE = ramp('#3f8fb0', '#25637d', '#a9d6ea')
GREEN = ramp('#4f9a45', '#2f6a3a', '#7ab55c')
PURP = ramp('#7a4e8a', '#4e3a6a', '#a87ab8')
DONK = ramp('#9a8a7a', '#6a5a4c', '#c3b4a2')
GOAT = ramp('#f1ece0', '#c9bfa8', '#ffffff')
DARK = '#2a1a10'

WALL3 = ramp('#f0c4aa', '#c98a72', '#ffe2d0')    # rose plaster
WALL4 = ramp('#e2ebe2', '#a8b8ae', '#ffffff')    # cool limewash
NET = ramp('#3f8a7a', '#2a5a50', '#6ab0a0')
COATS = {'brown': ramp('#9a6a3a', '#6a4424', '#c08a5a'), 'black': ramp('#4a3e3a', '#2a2220', '#6e625a'),
         'white': ramp('#ece6d8', '#bfb39a', '#ffffff'), 'tan': ramp('#c9a060', '#94703a', '#e2c084')}

cv = new_canvas('#93c3d8')
r = rnd(1907)
r2 = rnd(311)
r3 = rnd(733)   # pass-1 details (headland, pergola leaves, net): keeps the r / r2 layout stable
YY, XX = np.mgrid[0:H, 0:W]


def shadow(x0, y0, x1, y1, col='#a6843f'):
    cv.fill(ell(x0, y0, x1, y1), col)


def clump(cx, cy, rx, ry, n, s0=4, s1=7, rr=None):
    rr = rr or r
    m = blank()
    for _ in range(n):
        ex, ey, s = cx + rr(-rx, rx), cy + rr(-ry, ry), rr(s0, s1)
        m |= ell(ex - s, ey - s * 2 // 3, ex + s, ey + s * 2 // 3)
    return m


def specks(m, cols, n, rr=None):
    rr = rr or r
    ys, xs = np.nonzero(m & shift(m, 1, 0) & shift(m, -1, 0) & shift(m, 0, 1) & shift(m, 0, -1))
    if len(xs) == 0:
        return
    for k in range(n):
        i = rr(0, len(xs) - 1)
        cv.dots([(int(xs[i]), int(ys[i])), (int(xs[i]) + 1, int(ys[i]))], cols[k % len(cols)])


def gnome(gx, gy, hat, tunic, s=1.0, face=1, arm=0, legs=True):
    """A gnome standing with feet at (gx, gy). s scales, face=1 hat tip leans left (looking right), arm=+1/-1 reaches out that side."""
    def X(v):
        return gx + int(round(v * s)) * face

    def Y(v):
        return gy + int(round(v * s))

    def R(x0, y0, x1, y1):
        a, b = sorted((X(x0), X(x1)))
        return rect(a, Y(y0), b, Y(y1))
    o = cv.obj()
    if legs:
        o.part(R(-7, -3, -2, 0) | R(1, -3, 6, 0), ramp('#5c3420', '#3d2a1c', '#7a4a1f'), d=1)
    o.part(R(-7, -16, 7, -3), tunic, d=2, contour=True)
    o.part(R(-7, -7, 7, -6), ramp('#7a4a1f', '#5c3420'), d=0)
    o.part(poly([(X(-7), Y(-20)), (X(7), Y(-20)), (X(1), Y(-6))]), BEARD, d=1, contour=True)
    o.part(R(-5, -25, 5, -19), SKIN, d=1)
    o.part(poly([(X(-8), Y(-23)), (X(8), Y(-23)), (X(-5), Y(-40))]), hat, d=2, contour=True)
    if arm:
        o.part(R(5 * arm, -15, 9 * arm, -12), tunic, d=1)
    o.draw()
    cv.fill(R(-8, -24, 8, -23), hat['s'])
    cv.dots([(X(-2), Y(-22)), (X(2), Y(-22))], DARK)
    cv.dots([(X(0), Y(-21)), (X(1), Y(-21))], '#e0907a')
    if s >= 0.8:
        cv.dots([(X(-4), Y(-20)), (X(4), Y(-20))], '#f0a0a0')
    if arm:
        cv.fill(R(8 * arm, -16, 10 * arm, -13), SKIN['b'])
    cv.fill(R(-1, -7, 1, -6), '#f5cf6a')


def olive_tree(tx, ty, w, rr=None, fruit=True):
    """Gnarled silver-green olive: twisted trunk standing at (tx, ty), crown about w wide."""
    rr = rr or r
    shadow(tx - w // 2, ty - 1, tx + w // 2 + 2, ty + 2, '#9a4426')
    th = w * 2 // 3
    o = cv.obj()
    o.part(poly([(tx - 3, ty), (tx + 3, ty), (tx + 2, ty - th // 2), (tx + 4, ty - th), (tx, ty - th), (tx - 1, ty - th // 2), (tx - 4, ty - th + 2), (tx - 2, ty - th // 2 + 1)]), BARK, d=1)
    o.draw()
    cv.fill(rect(tx, ty - th // 2 + 1, tx, ty - 2), BARK['s'])
    cv.dots([(tx - 1, ty - 3), (tx + 1, ty - th // 2 - 2)], '#3a2a1c')   # knots
    cm = clump(tx, ty - th - 3, w // 2 - 3, 3, 7, 3, max(4, w // 4), rr)
    o = cv.obj()
    o.part(cm, SILVER if rr(0, 2) else OLIVE, d=2)
    o.draw()
    specks(cm, ['#cdd6a0', '#e2e8c0', OLIVE['b']], w, rr)
    if fruit:
        specks(cm, ['#3a2a3a', '#5a3a4a'], max(2, w // 6), rr)


def cypress(cx, by, h, w=5):
    o = cv.obj()
    o.part(ell(cx - w, by - h, cx + w, by) | poly([(cx - 2, by - h - 4), (cx + 2, by - h - 4), (cx + w - 1, by - h // 2), (cx - w + 1, by - h // 2)]), CYP, d=2)
    o.draw()
    for yy in range(by - h + 3, by - 2, 4):
        cv.dots([(cx - 2 + (yy % 3), yy), (cx - 1 + (yy % 3), yy + 1)], CYP['r'])


def house(x0, by, w, h, wall, roofh=5, door=True, flip=False):
    """Cubic Mediterranean house, walls from by-h to by, low terracotta roof on top, blue shutters."""
    o = cv.obj()
    o.part(rect(x0, by - h, x0 + w, by), wall, d=2)
    o.part(poly([(x0 - 2, by - h), (x0 + w + 2, by - h), (x0 + w - 2, by - h - roofh), (x0 + 2, by - h - roofh)]), ROOF, d=2)
    o.draw()
    for yy in range(by - h - roofh + 2, by - h, 2):   # roof tile ridges
        for xx in range(x0 + 1 + (yy % 4) // 2, x0 + w, 3):
            cv.dots([(xx, yy)], ROOF['s'])
    nwin = max(1, (w - 4) // 8)
    for k in range(nwin):
        wx = x0 + 3 + k * ((w - 6) // nwin) + (2 if flip else 0)
        wy = by - h + 3
        if wy + 4 < by - 6 or not door:
            cv.fill(rect(wx, wy, wx + 2, wy + 3), '#4a2c1a')
            cv.fill(rect(wx - 1, wy, wx - 1, wy + 3) | rect(wx + 3, wy, wx + 3, wy + 3), SHUT['b'])
            cv.dots([(wx + 1, wy)], '#f5cf6a')
    if door and h >= 12:
        dx = x0 + (w * 2 // 3 if not flip else w // 4)
        cv.fill(rrect(dx, by - 7, dx + 3, by, 1), '#7a4a1f')
        cv.fill(rect(dx + 1, by - 6, dx + 1, by), '#5c3420')


# ================================================================ SKY (golden hour, sun low at the upper left)
for y0, col in ((12, '#a9cdd6'), (22, '#c6d8c8'), (32, '#ecd8a8'), (44, '#f4c98c'), (56, '#f6b97a')):
    m = blank()
    pts = [(0, y0)]
    for x in range(0, W + 20, 20):
        pts.append((x, y0 + r(-2, 2)))
    pts += [(W, H), (0, H)]
    cv.fill(poly(pts), col)
sx, sy = 54, 54
cv.fill(ell(sx - 17, sy - 17, sx + 17, sy + 17), '#f8d690')   # halo ring (hard)
cv.fill(ell(sx - 13, sy - 13, sx + 13, sy + 13), '#fbe4a6')
cv.fill(ell(sx - 10, sy - 10, sx + 10, sy + 10), GLIT)
cv.fill(ell(sx - 10, sy - 10, sx + 10, sy + 10) & ~shift(ell(sx - 10, sy - 10, sx + 10, sy + 10), -2, -2), '#f8dc6a')
cv.fill(ell(sx - 7, sy - 7, sx - 2, sy - 3), '#ffffff')
# streaky golden clouds lit from below-left
for cx, cy, w in ((22, 10, 40), (112, 14, 54), (170, 6, 40), (84, 34, 46), (150, 30, 40), (10, 32, 24), (196, 22, 30), (128, 48, 34), (226, 6, 22)):
    m = ell(cx - w // 2, cy - 3, cx + w // 2, cy + 3) | ell(cx - w // 4, cy - 6, cx + w // 6, cy + 2) | ell(cx + 2, cy - 5, cx + w // 3, cy + 2)
    cv.fill(m, '#fff4dc')
    cv.fill(m & ~shift(m, 0, -2), '#f6c8a0')          # warm underside
    cv.fill(m & ~shift(m, 3, 0) & ~shift(m, 0, -2), '#e8a888')   # pink lower-right tip
    cv.fill(m & ~shift(m, 0, 1) & shift(m, 2, 0), '#ffffff')    # top rim
for bx, by in ((92, 22), (98, 25), (104, 22), (140, 12), (146, 15), (30, 40), (36, 43), (188, 40), (70, 8), (76, 11)):   # gulls
    cv.dots([(bx - 2, by - 1), (bx - 1, by), (bx, by + 1), (bx + 1, by), (bx + 2, by - 1)], '#5a4a4a')
    cv.dots([(bx, by)], '#ffffff')

# ================================================================ FAR: horizon islands and Cinderpeak
HZ = 72
cat = ell(0, 64, 30, 80) | poly([(20, 66), (22, 60), (25, 65)]) | poly([(26, 67), (29, 61), (31, 68)]) | ell(24, 64, 34, 76)   # sleeping-cat isle
cat &= rect(0, 0, W, HZ)
cv.fill(cat, '#c99a7a')
cv.fill(cat & ~shift(cat, 2, 2), '#e2b896')
cv.fill(line([(4, 70), (10, 67), (16, 70)]), '#a87a62')   # curled tail
volc = poly([(84, HZ), (104, 54), (112, 52), (118, 55), (142, HZ)])
cv.fill(volc, '#b88a7a')
cv.fill(volc & ~shift(volc, 3, 2), '#d6a890')
cv.fill(poly([(104, 54), (112, 52), (118, 55), (115, 58), (107, 58)]), '#8a6a62')
cv.dots([(110, 56), (111, 56), (113, 57)], '#f08a24')
for k in range(6):   # thin smoke curl drifting left
    px, py = 110 - k * 4 - (k * k) // 3, 48 - k * 5
    pm = ell(px - 2 - k // 2, py - 2, px + 2 + k // 2, py + 2)
    cv.fill(pm, '#e6dccf' if k < 4 else '#f0e8dc')
    cv.fill(pm & ~shift(pm, -1, -1), '#c9b8aa')
cv.fill(rect(0, HZ - 1, W, HZ - 1) & ~cat & ~volc, '#f8dc8a')
# the Labyrinth Isle: a low island with a hedge maze and a white fountain
lab = ell(60, 64, 84, 78) & rect(0, 0, W, HZ - 1)
cv.fill(lab, '#7a8a52')
cv.fill(lab & ~shift(lab, 2, 2), '#9aa86a')
for yy in (67, 70):
    cv.fill(rect(64, yy, 80, yy) & lab, '#e8dcc0')
cv.fill(rect(72, 66, 72, 70) & lab, '#e8dcc0')
cv.dots([(72, 65), (71, 66), (73, 66)], '#ffffff')
# a kite flown from the village, tail streaming
kx, ky = 162, 38
km = poly([(kx, ky - 7), (kx + 5, ky), (kx, ky + 7), (kx - 5, ky)])
o = cv.obj()
o.part(km, ramp('#d6322b', '#a8241f', '#f08a5a'), d=1)
o.draw()
cv.fill(km & rect(kx - 5, ky - 7, kx, ky), '#f2d23a')
cv.fill(rect(kx, ky - 6, kx, ky + 6) & km, '#4a2c1a')
cv.fill(line([(kx, ky + 7), (kx - 3, ky + 12), (kx + 1, ky + 17), (kx - 2, ky + 22)]), '#4a2c1a')
for tx, ty, c in ((kx - 3, ky + 12, '#3f8fb0'), (kx + 1, ky + 17, '#f2d23a'), (kx - 2, ky + 22, '#d6322b')):
    cv.fill(rect(tx - 1, ty, tx + 1, ty + 1), c)
cv.fill(line([(kx + 1, ky + 6), (200, 56)]), '#8a7a6a')
# a big gull gliding close, and a far flight of three
gbx, gby = 40, 34
cv.fill(poly([(gbx - 9, gby - 3), (gbx - 2, gby + 1), (gbx, gby + 3), (gbx + 2, gby + 1), (gbx + 9, gby - 3), (gbx + 2, gby - 1), (gbx, gby), (gbx - 2, gby - 1)]), '#ffffff')
cv.dots([(gbx - 9, gby - 3), (gbx - 8, gby - 3), (gbx + 9, gby - 3), (gbx + 8, gby - 3)], '#3a3a4a')
cv.fill(rect(gbx - 1, gby + 1, gbx + 1, gby + 3), '#c9c5bc')
cv.dots([(gbx, gby + 4)], '#f0b92b')
for bx, by in ((10, 26), (16, 29), (6, 30), (118, 36), (122, 38)):
    cv.dots([(bx - 1, by - 1), (bx, by), (bx + 1, by - 1)], '#5a4a4a')

# ================================================================ LAND MASKS
hill = poly([(300, 2), (272, 8), (246, 16), (222, 26), (202, 38), (186, 50), (172, 62), (160, 76), (156, 82), (153, 88), (149, 92), (147, 98), (142, 102), (140, 108), (135, 112), (133, 118), (128, 122), (126, 128), (120, 132), (300, 132)])
piazza = poly([(124, 126), (300, 126), (300, 200), (134, 200), (128, 176)])
steps = poly([(106, 130), (126, 130), (110, 178), (84, 172)])
pwall = poly([(124, 128), (134, 128), (136, 200), (106, 200), (110, 176)]) & ~piazza
quay = poly([(0, 168), (86, 166), (108, 178), (110, 200), (0, 200)])
mole = poly([(0, 126), (24, 122), (44, 124), (50, 132), (44, 138), (18, 140), (0, 142)])
land = hill | piazza | steps | pwall | quay | mole

# ================================================================ SEA
sea = rect(0, HZ, W - 1, H - 1) & ~land
cv.fill(sea, SEA2)
cv.fill(sea & rect(0, HZ, W, 84), SEA0)
cv.fill(sea & rect(0, 85, W, 104), SEA1)
cv.fill(sea & rect(0, 140, W, H), SEA3)
for _ in range(220):   # wavelets
    wx, wy = r(0, W - 8), r(HZ + 2, 196)
    if sea[wy, wx] and sea[wy, min(W - 1, wx + 5)]:
        ln = 2 + (wy - HZ) // 18
        col = (FOAM if wy < 90 else '#8cc4dc') if r(0, 2) else (SEA1 if wy > 104 else '#a9d6ea')
        cv.fill(rect(wx, wy, wx + ln, wy) & sea, col)
for k in range(46):   # sun glitter column
    gy = r(HZ + 1, 124)
    spread = 6 + (gy - HZ) // 3
    gx = sx + r(-spread, spread)
    ln = r(2, 5)
    if sea[gy, max(0, gx)]:
        cv.fill(rect(gx, gy, gx + ln, gy) & sea, GLIT if k % 3 else '#f8dc6a')

# far sailboat with an ochre sail
fbx, fby = 150, 80
cv.fill(poly([(fbx - 7, fby), (fbx + 7, fby), (fbx + 5, fby + 3), (fbx - 5, fby + 3)]), '#7a4a1f')
cv.fill(poly([(fbx, fby - 13), (fbx, fby - 1), (fbx + 8, fby - 1)]), '#f0cc80')
cv.fill(poly([(fbx - 1, fby - 10), (fbx - 1, fby - 1), (fbx - 6, fby - 1)]), '#e88a5a')
cv.fill(rect(fbx, fby - 14, fbx, fby), DARK)
cv.fill(rect(fbx - 6, fby + 4, fbx + 6, fby + 4), FOAM)
# goat ferry chugging between the isles
ffx, ffy = 96, 98
o = cv.obj()
o.part(poly([(ffx, ffy), (ffx + 30, ffy), (ffx + 27, ffy + 6), (ffx + 3, ffy + 6)]), ramp('#f0e0b8', '#c9ad7a', '#ffffff'), d=1)
o.part(rect(ffx + 18, ffy - 7, ffx + 25, ffy - 1), TERRA, d=1)
o.draw()
cv.fill(rect(ffx + 1, ffy + 3, ffx + 28, ffy + 3), SHUT['b'])
cv.fill(rect(ffx + 20, ffy - 5, ffx + 21, ffy - 4), '#4a2c1a')
for gxx in (ffx + 4, ffx + 10):   # two goats on deck
    cv.fill(rect(gxx, ffy - 4, gxx + 4, ffy - 2), '#f1ece0')
    cv.dots([(gxx + 5, ffy - 5), (gxx + 5, ffy - 4), (gxx + 6, ffy - 6)], '#f1ece0')
    cv.dots([(gxx + 1, ffy - 1), (gxx + 3, ffy - 1)], '#4a3a30')
    cv.dots([(gxx + 5, ffy - 3)], '#f5cf6a')
for k in range(3):
    cv.fill(ell(ffx + 20 + k * 3, ffy - 12 - k * 4, ffx + 24 + k * 4, ffy - 9 - k * 4), '#f0e8dc')
cv.fill(rect(ffx - 6, ffy + 6, ffx + 2, ffy + 6) | rect(ffx - 3, ffy + 4, ffx, ffy + 4), FOAM)
# leaping dolphin
dlx, dly = 10, 98
o = cv.obj()
o.part(poly([(dlx, dly + 8), (dlx + 4, dly), (dlx + 12, dly - 3), (dlx + 18, dly + 1), (dlx + 14, dly), (dlx + 6, dly + 3), (dlx + 3, dly + 9)]), ramp('#7a8fa8', '#4f6a84', '#b0c4d6'), d=1)
o.part(poly([(dlx + 9, dly - 2), (dlx + 10, dly - 6), (dlx + 12, dly - 2)]), ramp('#7a8fa8', '#4f6a84'), d=0)
o.draw()
cv.dots([(dlx + 15, dly)], DARK)
cv.fill(rect(dlx - 2, dly + 10, dlx + 8, dly + 10), FOAM)
cv.dots([(dlx + 20, dly + 9), (dlx + 22, dly + 8), (dlx + 18, dly + 6)], FOAM)
# sponge-diver's rowboat in the glitter, a gnome's hat bobbing beside it
rbx, rby = 64, 110
o = cv.obj()
o.part(poly([(rbx, rby), (rbx + 18, rby), (rbx + 15, rby + 5), (rbx + 3, rby + 5)]), ramp('#e88a5a', '#9a4426', '#f6b48a'), d=1)
o.draw()
cv.fill(rect(rbx + 1, rby + 1, rbx + 17, rby + 1), '#f0e0b8')
cv.fill(line([(rbx + 4, rby - 2), (rbx + 12, rby + 7)]), '#d9a35a')   # oar
cv.fill(rect(rbx + 7, rby - 3, rbx + 10, rby - 1), '#f2d23a')   # sponge basket
cv.dots([(rbx + 8, rby - 4), (rbx + 9, rby - 4)], '#c9a414')
dhx, dhy = rbx + 24, rby + 3
o = cv.obj()
o.part(poly([(dhx - 4, dhy), (dhx + 4, dhy), (dhx - 2, dhy - 8)]), RED, d=1)
o.part(rect(dhx - 3, dhy + 1, dhx + 3, dhy + 2), SKIN, d=0)
o.draw()
cv.dots([(dhx - 1, dhy + 1), (dhx + 1, dhy + 1)], DARK)
cv.fill(ell(dhx - 7, dhy + 2, dhx + 7, dhy + 5) & ~ell(dhx - 4, dhy + 2, dhx + 4, dhy + 4), FOAM)
# a couple of bobbing buoys
for bx, by, c in ((132, 112, RED), (36, 116, LEMON)):
    o = cv.obj()
    o.part(ell(bx, by, bx + 5, by + 5), c, d=1)
    o.draw()
    cv.fill(rect(bx - 1, by + 5, bx + 6, by + 5), FOAM)

# ================================================================ BREAKWATER and the harbour light
cv.fill(mole, GREY['s'])
for k in range(26):
    bx, by = r(0, 46), r(122, 140)
    if mole[by, bx]:
        o = cv.obj()
        o.part(ell(bx - 4, by - 3, bx + 4, by + 3) & dil4(mole), GREY, d=2)
        o.draw()
cv.fill(dil4(mole) & ~mole & sea & ~shift(mole, 0, -3), FOAM)
lhx, lhy = 30, 126
o = cv.obj()
o.part(poly([(lhx - 6, lhy), (lhx + 6, lhy), (lhx + 4, lhy - 26), (lhx - 4, lhy - 26)]), WALL, d=2)
o.part(rect(lhx - 6, lhy - 34, lhx + 6, lhy - 27), ramp('#3f8fb0', '#25637d', '#a9d6ea'), d=1)
o.part(poly([(lhx - 7, lhy - 34), (lhx + 7, lhy - 34), (lhx, lhy - 40)]), TERRA, d=1)
o.part(rect(lhx - 7, lhy - 27, lhx + 7, lhy - 26), WOOD, d=0)
o.draw()
cv.fill(rect(lhx - 3, lhy - 32, lhx + 3, lhy - 29), '#fff08a')
cv.fill(rect(lhx - 5, lhy - 18, lhx + 5, lhy - 15), TERRA['b'])   # painted band
cv.fill(rect(lhx - 1, lhy - 8, lhx + 1, lhy), '#4a2c1a')   # door
cv.fill(rect(lhx - 1, lhy - 23, lhx, lhy - 21), '#4a2c1a')
cv.dots([(lhx, lhy - 41)], DARK)
for k in range(3):   # beams
    cv.fill(line([(lhx - 8, lhy - 31 - k), (lhx - 18, lhy - 34 - k * 3)]), '#fff2b0')
gx_, gy_ = 18, 120   # a gull perched on the breakwater
cv.fill(ell(gx_, gy_ - 4, gx_ + 7, gy_), '#ffffff')
cv.fill(rect(gx_ + 1, gy_ - 3, gx_ + 6, gy_ - 2), '#c9c5bc')
cv.dots([(gx_ + 7, gy_ - 5), (gx_ + 8, gy_ - 5)], '#ffffff')
cv.dots([(gx_ + 9, gy_ - 5)], '#f0b92b')
cv.dots([(gx_ + 7, gy_ - 6)], DARK)

# ================================================================ HILLSIDE: dry ground, cliff edge, terraces
cv.fill(hill, DRY['b'])
cliff = hill & ~shift(hill, -7, 0) & rect(0, 60, W, 132)
cv.fill(cliff, '#c49660')
cv.fill(cliff & ~shift(cliff, 2, 0), '#e2b47a')
for k in range(40):   # cliff crevices
    cy = r(64, 128)
    xs = np.nonzero(cliff[cy])[0]
    if len(xs):
        cx = int(xs[0]) + r(1, 5)
        cv.fill(rect(cx, cy, cx + r(1, 3), cy) & cliff, '#8a5a3a')
for cy in (78, 96, 112, 124):   # caper bushes sprouting from the cliff
    xs = np.nonzero(cliff[cy])[0]
    if len(xs):
        cx = int(xs[0]) + 1
        bm = ell(cx - 3, cy - 2, cx + 3, cy + 2)
        cv.fill(bm, GREEN['b'])
        cv.fill(bm & ~shift(bm, -1, -1), GREEN['s'])
        cv.dots([(cx - 1, cy - 1), (cx + 1, cy)], '#f6b8cf')
cv.fill(dil4(hill) & sea & rect(0, 0, W, 134), FOAM)   # surf along the cliff foot
for k in range(14):
    yy = r(90, 132)
    xs = np.nonzero(hill[yy])[0]
    if len(xs):
        cv.fill(rect(int(xs[0]) - r(3, 6), yy, int(xs[0]) - 1, yy), FOAM)

# ground texture over the dry hillside
for _ in range(500):
    px, py = r(120, W - 2), r(4, 130)
    if hill[py, px] and not cliff[py, px]:
        cv.dots([(px, py), (px, py - 1)], DRY['s'] if r(0, 2) else DRY['r'])

# maquis scrub on the open slope below the village: rosemary, yellow broom, rockrose
for k in range(26):
    px, py = r2(150, 236), r2(30, 72)
    if hill[py, px] and hill[py, px - 6] and not cliff[py, px]:
        bm = clump(px, py, 2, 1, 3, 2, 3, r2)
        cv.fill(bm, OLIVE['b'] if k % 3 else CYP['b'])
        cv.fill(bm & ~shift(bm, -1, -1), OLIVE['s'])
        cv.dots([(px - 1, py - 1), (px + 1, py)], ('#f2d23a', '#f6b8cf', '#c3b2ea')[k % 3])
# ================================================================ VILLAGE (top right): back row, bell tower, middle row, front row
for cx, by, h in ((262, 26, 18), (296, 22, 14), (208, 62, 20), (180, 70, 16), (290, 70, 14)):
    cypress(cx, by, h, 3)
# back row
for x0, by, w, h, wl in ((246, 32, 16, 12, WALL), (264, 30, 18, 14, WALL2), (284, 26, 16, 12, WALL)):
    house(x0, by, w, h, wl, door=False)
# bell tower
btx, bty = 226, 58
o = cv.obj()
o.part(rect(btx, bty - 46, btx + 12, bty), WALL2, d=2)
o.part(rect(btx - 1, bty - 47, btx + 13, bty - 45) | rect(btx - 1, bty - 31, btx + 13, bty - 30), STONE, d=1)
o.part(poly([(btx - 1, bty - 47), (btx + 13, bty - 47), (btx + 6, bty - 56)]), ROOF, d=2)
o.draw()
cv.fill(rrect(btx + 3, bty - 43, btx + 9, bty - 33, 2) & ~rect(0, bty - 43, W, bty - 42) | rect(btx + 4, bty - 42, btx + 8, bty - 33), '#4a2c1a')
o = cv.obj()
o.part(poly([(btx + 4, bty - 34), (btx + 8, bty - 34), (btx + 7, bty - 40), (btx + 5, bty - 40)]), ramp('#d9a22a', '#a8741a', '#f2d46a'), d=1)
o.draw()
cv.dots([(btx + 6, bty - 33)], '#a8741a')
cv.dots([(btx + 6, bty - 57), (btx + 6, bty - 58), (btx + 5, bty - 58), (btx + 7, bty - 58)], DARK)   # little cross-vane
cv.fill(ell(btx + 3, bty - 27, btx + 9, bty - 21), '#f0e4c4')   # clock
cv.dots([(btx + 6, bty - 26), (btx + 6, bty - 25), (btx + 7, bty - 24)], DARK)
for yy in range(bty - 18, bty, 5):
    cv.fill(rect(btx + 2, yy, btx + 4, yy), WALL2['s'])
    cv.fill(rect(btx + 8, yy + 2, btx + 10, yy + 2), WALL2['s'])
cv.fill(rect(btx + 5, bty - 14, btx + 7, bty - 10), '#4a2c1a')
for k in range(3):   # the evening bell ringing
    cv.dots([(btx - 3 - k * 2, bty - 39 + k), (btx + 15 + k * 2, bty - 39 + k)], '#fff4dc')
# middle row
for x0, by, w, h, wl in ((198, 50, 18, 14, WALL), (242, 50, 20, 16, WALL2), (264, 48, 16, 14, WALL), (282, 48, 18, 16, WALL2)):
    house(x0, by, w, h, wl, flip=wl is WALL)
# front row
for x0, by, w, h, wl in ((184, 72, 20, 16, WALL2), (206, 70, 16, 18, WALL), (226, 72, 22, 14, WALL2), (252, 70, 18, 18, WALL), (272, 72, 16, 14, WALL2)):
    house(x0, by, w, h, wl)
# washing line between two front houses, pots of geraniums on the sills
cv.fill(line([(222, 56), (252, 58)]), '#4a2c1a')
for k, c in enumerate(('#d6322b', '#ffffff', '#3f8fb0', '#f2d23a', '#ffffff')):
    lx = 225 + k * 6
    cv.fill(rect(lx, 57 + k // 2, lx + 3, 61 + k // 2), c)
for px_, py_ in ((188, 59), (210, 55), (256, 55), (276, 61), (246, 39), (284, 37)):
    cv.fill(rect(px_, py_, px_ + 3, py_ + 2), TERRA['b'])
    cv.dots([(px_, py_ - 1), (px_ + 2, py_ - 1), (px_ + 1, py_ - 2), (px_ + 3, py_ - 1)], '#d6322b')
    cv.dots([(px_ + 1, py_ - 1)], GREEN['b'])
# a cat on a roof, swallows round the tower
cv.fill(rect(268, 55, 272, 57), '#e8841f')
cv.dots([(273, 54), (273, 53), (274, 54), (275, 53), (267, 54), (266, 53)], '#e8841f')
cv.dots([(274, 55)], DARK)
for bx, by in ((214, 14), (240, 6), (204, 24)):
    cv.dots([(bx - 2, by), (bx - 1, by + 1), (bx, by), (bx + 1, by + 1), (bx + 2, by), (bx, by + 1), (bx, by + 2)], '#3a3a4a')

# ================================================================ TERRACES of olive trees
for wy in (84, 100, 116):
    wm = hill & rect(0, wy, W, wy + 3) & ~cliff
    soil = hill & rect(0, wy - 5, W, wy - 1) & ~cliff
    cv.fill(soil, TERRA['b'])
    for _ in range(60):
        px = r(130, W - 2)
        if soil[wy - 3, px]:
            cv.dots([(px, wy - r(2, 4))], TERRA['s'] if r(0, 1) else TERRA['r'])
    cv.fill(wm, STONE['b'])
    cv.fill(wm & rect(0, wy + 3, W, wy + 3), STONE['s'])
    cv.fill(wm & rect(0, wy, W, wy), STONE['r'])
    x = 120 + (wy % 7)
    while x < W:
        cv.fill(rect(x, wy + 1, x, wy + 2) & wm, STONE['s'])
        x += r(4, 7)
cv.fill(hill & rect(0, 73, W, 76) & ~cliff, STONE['b'])   # village base wall
cv.fill(hill & rect(0, 76, W, 76) & ~cliff, STONE['s'])
for tx, ty, w in ((176, 82, 18), (200, 83, 20), (226, 82, 16), (252, 83, 22), (282, 82, 18),
                  (160, 98, 16), (184, 99, 22), (232, 98, 18), (262, 98, 20), (290, 99, 14),
                  (148, 114, 16), (172, 115, 20), (198, 114, 18), (246, 114, 22), (274, 115, 18)):
    olive_tree(tx, ty, w)
# nets under the tree on the middle terrace, a gnome combing it with a little rake
nm = poly([(204, 98), (230, 98), (236, 101), (200, 101)])
cv.fill(nm, '#f0e4c4')
for xx in range(201, 236, 3):
    cv.fill(rect(xx, 98, xx, 101) & nm, '#c9ad7a')
cv.dots([(206, 99), (212, 100), (218, 99), (224, 100), (228, 99), (215, 99)], '#3a2a3a')
for k in range(5):
    cv.dots([(214 + k * 3, 90 + k % 2 * 3)], '#3a2a3a')   # olives falling
gnome(222, 100, ramp('#3f8fb0', '#25637d', '#a9d6ea'), RED, s=0.62, face=-1, arm=1)
cv.fill(line([(214, 87), (226, 81)], 1), '#7a4a1f')   # rake pole reaching into the crown
cv.fill(rect(212, 85, 214, 89), '#4a2c1a')
# a basket of olives on the top terrace
o = cv.obj()
o.part(rrect(238, 78, 246, 83, 1), WOOD, d=1)
o.draw()
cv.dots([(239, 77), (241, 77), (243, 77), (240, 76), (244, 77)], '#3a2a3a')
# bell-goats on the terraces
for gx0, gy0, fc in ((150, 96, 1), (268, 112, -1), (212, 113, 1)):
    o = cv.obj()
    o.part(rect(gx0 + 1, gy0 - 2, gx0 + 2, gy0) | rect(gx0 + 8, gy0 - 2, gx0 + 9, gy0), ramp('#4a3a30', '#2a1a10'), d=0)
    o.part(rrect(gx0, gy0 - 7, gx0 + 10, gy0 - 2, 1), GOAT, d=1)
    hx_ = gx0 + 10 if fc > 0 else gx0 - 4
    o.part(rect(hx_, gy0 - 10, hx_ + 4, gy0 - 6), GOAT, d=1)
    o.draw()
    cv.dots([(hx_ + (1 if fc > 0 else 3), gy0 - 11), (hx_ + (0 if fc > 0 else 4), gy0 - 12)], '#6a5a4c')   # horns
    cv.dots([(hx_ + (3 if fc > 0 else 1), gy0 - 9)], DARK)
    cv.dots([(hx_ + 2, gy0 - 5), (hx_ + 2, gy0 - 4)], '#f0b92b')   # bell
    cv.dots([(gx0 + (0 if fc > 0 else 10), gy0 - 7), (gx0 + (-1 if fc > 0 else 11), gy0 - 6)], '#c9bfa8')

# ================================================================ PIAZZA paving
cv.fill(piazza, '#e2c48e')
for yy in range(130, 200, 6):
    cv.fill(piazza & rect(0, yy, W, yy), '#c9a46a')
    off = (yy // 6) % 2 * 5
    for xx in range(124 + off, W, 10):
        cv.fill(piazza & rect(xx, yy + 1, xx, yy + 5), '#c9a46a')
for _ in range(70):
    px, py = r(128, W - 4), r(130, 196)
    if piazza[py, px]:
        k = r(0, 2)
        if k == 0:
            cv.fill(rect(px, py, px + 3, py + 1) & piazza, '#d6b47a')
        else:
            cv.dots([(px, py)], '#f0dcb0' if k == 1 else '#b8945a')
# back retaining wall of the piazza (terrace foot)
bw = piazza & rect(0, 126, W, 131)
cv.fill(bw, STONE['b'])
cv.fill(bw & rect(0, 131, W, 131), STONE['s'])
cv.fill(bw & rect(0, 126, W, 126), STONE['r'])
for xx in range(128, W, 7):
    cv.fill(rect(xx, 127, xx, 130) & bw, STONE['s'])
# retaining wall face beside the steps
cv.fill(pwall, '#c49660')
for yy in range(132, 200, 5):
    cv.fill(pwall & rect(0, yy, W, yy), '#a87a4a')
    for xx in range(100 + (yy // 5) % 2 * 3, 140, 6):
        cv.fill(pwall & rect(xx, yy + 1, xx, yy + 4), '#a87a4a')
cv.fill(pwall & ~shift(pwall, 2, 0), '#e2b47a')

# ================================================================ STEPS down to the harbour
cv.fill(steps, STONE['b'])
for yy in range(131, 178, 4):
    cv.fill(steps & rect(0, yy, W, yy), STONE['s'])
    cv.fill(steps & rect(0, yy + 1, W, yy + 1), STONE['r'])
cv.fill(steps & ~shift(steps, 2, 0), '#a8946e')
cv.fill(steps & ~shift(steps, -2, 0), '#a8946e')
for k in range(8):   # potted geraniums along the step edge
    yy = 134 + k * 6
    xs = np.nonzero(steps[yy])[0]
    if len(xs) and k % 2 == 0:
        px_ = int(xs[-1]) - 4
        cv.fill(rect(px_, yy - 2, px_ + 3, yy), TERRA['b'])
        cv.dots([(px_, yy - 3), (px_ + 2, yy - 4), (px_ + 3, yy - 3), (px_ + 1, yy - 3)], '#d6322b' if k % 4 else '#f6b8cf')
        cv.dots([(px_ + 1, yy - 4)], GREEN['b'])

# ================================================================ QUAY, BOATS
cv.fill(quay, '#d8c6a0')
for yy in range(170, 200, 5):
    cv.fill(quay & rect(0, yy, W, yy), '#b8a27a')
    for xx in range((yy // 5) % 2 * 6, 110, 12):
        cv.fill(quay & rect(xx, yy + 1, xx, yy + 4), '#b8a27a')
lip = quay & ~shift(quay, 0, 3)
cv.fill(lip, '#f0e4c4')
cv.fill(lip & ~shift(quay, 0, 1), '#a8946e')
cv.fill(dil4(quay) & sea & ~quay, SEA3)
# harbour boats (moored, bows left), mooring lines to bollards
for bx, by, w, hull, stripe in ((4, 152, 30, BLUE, '#f2d23a'), (44, 156, 28, TERRA, '#f0e4c4'), (76, 146, 22, ramp('#f2d23a', '#c9a414', '#fff08a'), '#3f8fb0')):
    o = cv.obj()
    o.part(poly([(bx, by), (bx + w, by), (bx + w - 3, by + 7), (bx + 4, by + 7), (bx - 2, by - 3)]), hull, d=2)
    o.part(rect(bx + w // 2, by - 16, bx + w // 2 + 1, by - 1), WOOD, d=0)
    o.draw()
    cv.fill(rect(bx + 1, by + 2, bx + w - 2, by + 3), stripe)
    cv.fill(ell(bx + 1, by, bx + 4, by + 2), '#ffffff')   # painted eye on the bow
    cv.dots([(bx + 2, by + 1)], DARK)
    cv.fill(rect(bx + w // 2 - 4, by - 4, bx + w // 2 + 6, by - 2), '#f0e4c4')   # furled sail
    cv.fill(rect(bx + w // 2 - 4, by - 2, bx + w // 2 + 6, by - 2), '#c9ad7a')
    cv.fill(rect(bx - 3, by + 8, bx + w + 2, by + 8), '#8cc4dc')
    cv.fill(rect(bx + 2, by + 9, bx + w - 2, by + 9), SEA1)
for (ax, ay), (bx, by) in (((30, 158), (40, 168)), ((66, 162), (70, 167)), ((96, 152), (98, 168))):
    cv.fill(line([(ax, ay), (bx, by)]), '#c9ad7a')
for bx in (38, 68, 96):   # bollards
    o = cv.obj()
    o.part(rrect(bx, 166, bx + 5, 172, 1), ramp('#5b6470', '#3a4048', '#8b8f96'), d=1)
    o.draw()

# old fisher on an upturned crate, mending a net
o = cv.obj()
o.part(rect(8, 182, 26, 196), WOOD, d=2)
o.draw()
for xx in (12, 17, 22):
    cv.fill(rect(xx, 183, xx, 195), '#7a4a1f')
gnome(17, 184, ramp('#3f8fb0', '#25637d', '#a9d6ea'), ramp('#e8b878', '#c08a4a', '#f6d49a'), s=0.82, face=1, arm=1, legs=False)
cv.fill(rect(10, 184, 24, 186), ramp('#3f5a7a', '#2a3a52')['b'])   # trousers on the crate
net = poly([(24, 172), (60, 176), (66, 196), (24, 198)]) & quay
cv.fill(net, '#9aa0a8')
for xx in range(24, 68, 3):
    cv.fill(line([(xx, 172), (xx + 4, 198)]) & net, '#c9c5bc')
for yy in range(174, 199, 3):
    cv.fill(rect(0, yy, W, yy) & net, '#6a7078')
for fx_, fy_ in ((30, 180), (44, 186), (54, 192), (36, 192)):   # floats
    cv.fill(ell(fx_, fy_, fx_ + 3, fy_ + 2), '#e8841f')
cv.fill(line([(25, 172), (21, 174)]), '#c9c5bc')
# rope coil, lobster pot, sardine bucket
o = cv.obj()
o.part(ell(68, 180, 80, 188), ramp('#d9b878', '#a8844a', '#f0dca0'), d=1)
o.draw()
cv.fill(ell(71, 182, 77, 186) & ~ell(73, 183, 75, 185), '#a8844a')
o = cv.obj()
o.part(rrect(66, 188, 82, 198, 3), ramp('#c9a96e', '#9a6b3f', '#f0dca0'), d=2)
o.draw()
for xx in range(68, 82, 3):
    cv.fill(rect(xx, 189, xx, 197), '#7a4a1f')
cv.fill(rect(67, 192, 81, 192), '#7a4a1f')
o = cv.obj()
o.part(rect(4, 168, 11, 176), ramp('#8b8f96', '#5b6470', '#c9c5bc'), d=1)
o.draw()
for k in range(4):
    cv.dots([(5 + k * 2, 168), (6 + k * 2, 167)], '#e0e8ee')
# sardine grill made from a cart wheel, smoke rising
o = cv.obj()
o.part(rect(86, 184, 104, 186), ramp('#5b6470', '#3a4048', '#8b8f96'), d=1)
o.part(rect(88, 187, 89, 197) | rect(101, 187, 102, 197), ramp('#5b6470', '#3a4048'), d=0)
o.draw()
cv.fill(rect(87, 186, 103, 186), '#e8841f')
for k in range(4):
    cv.fill(rect(89 + k * 4, 182, 91 + k * 4, 183), '#c9c5bc')
    cv.dots([(89 + k * 4, 182)], DARK)
for k in range(4):
    pm = ell(92 + k * 2 - 2 - k // 2, 176 - k * 6, 96 + k * 2 + k // 2, 180 - k * 6)
    cv.fill(pm, '#f0e8dc')
    cv.fill(pm & ~shift(pm, -1, -1), '#c9b8aa')
# the pirate-gull making off with a sardine
pgx, pgy = 106, 194
cv.fill(ell(pgx, pgy - 5, pgx + 8, pgy), '#ffffff')
cv.fill(rect(pgx + 1, pgy - 4, pgx + 6, pgy - 3), '#c9c5bc')
cv.fill(ell(pgx + 6, pgy - 9, pgx + 10, pgy - 5), '#ffffff')
cv.dots([(pgx + 11, pgy - 7), (pgx + 12, pgy - 7)], '#f0b92b')
cv.dots([(pgx + 8, pgy - 8)], DARK)
cv.fill(rect(pgx + 7, pgy - 9, pgx + 9, pgy - 9), DARK)   # pirate bandana
cv.fill(rect(pgx + 12, pgy - 8, pgx + 15, pgy - 7), '#c9c5bc')   # the sardine
cv.dots([(pgx + 2, pgy + 1), (pgx + 5, pgy + 1)], '#f0b92b')

# ================================================================ DONKEY with lemon panniers on the steps, a gnome leading it
dkx, dky = 90, 168
shadow(dkx - 2, dky - 1, dkx + 20, dky + 2, '#a8946e')
o = cv.obj()
o.part(rect(dkx + 2, dky - 7, dkx + 3, dky) | rect(dkx + 14, dky - 7, dkx + 15, dky), DONK, d=0)
o.part(rrect(dkx, dky - 15, dkx + 18, dky - 6, 2), DONK, d=2)
o.part(poly([(dkx + 16, dky - 14), (dkx + 22, dky - 22), (dkx + 27, dky - 19), (dkx + 22, dky - 12)]), DONK, d=1)   # head up the steps
o.part(rect(dkx + 20, dky - 27, dkx + 21, dky - 21) | rect(dkx + 23, dky - 26, dkx + 24, dky - 21), DONK, d=0)   # ears
o.part(rrect(dkx + 2, dky - 16, dkx + 9, dky - 7, 1) | rrect(dkx + 10, dky - 16, dkx + 16, dky - 7, 1), WOOD, d=1, contour=True)   # panniers
o.draw()
cv.fill(rect(dkx + 2, dky - 1, dkx + 3, dky) | rect(dkx + 14, dky - 1, dkx + 15, dky), '#3d2a1c')
cv.dots([(dkx + 25, dky - 18), (dkx + 26, dky - 18)], '#e8dccc')
cv.dots([(dkx + 23, dky - 19)], DARK)
cv.fill(rect(dkx - 2, dky - 13, dkx - 1, dky - 9), '#6a5a4c')   # tail
for lx, ly in ((dkx + 3, dky - 19), (dkx + 6, dky - 18), (dkx + 11, dky - 19), (dkx + 14, dky - 18), (dkx + 8, dky - 20)):
    cv.fill(rect(lx, ly, lx + 2, ly + 2), LEMON['b'])
    cv.dots([(lx, ly)], LEMON['r'])
cv.dots([(dkx + 5, dky - 21), (dkx + 12, dky - 21)], GREEN['b'])
gnome(dkx - 6, dky + 14, RED, ramp('#4f9a45', '#2f6a3a', '#7ab55c'), s=0.72, face=1, arm=1)   # a gnome shoving the donkey up the steps

# ================================================================ OLIVE PRESS (piazza centre)
px0 = 176
shadow(144, 164, 212, 174, '#c9a46a')
o = cv.obj()
o.part(ell(146, 146, 208, 170), GREY, d=3)
o.draw()
mash = ell(152, 150, 202, 165)
cv.fill(mash, '#5a5a2a')
cv.fill(mash & ~shift(mash, 0, 2), '#3f3f1f')
specks(mash, ['#8a9a52', '#3a2a3a', '#b8a03a'], 30)
cv.fill(ell(146, 146, 208, 170) & ~ell(148, 147, 206, 169) & rect(0, 140, W, 158), GREY['r'])
o = cv.obj()   # central post and the beam out to the right
o.part(rect(px0 - 2, 128, px0 + 2, 160), WOOD, d=1)
o.part(line([(px0, 136), (231, 151)], 3), WOOD, d=1)
o.draw()
o = cv.obj()   # the great millstone wheel standing on edge
o.part(ell(156, 128, 182, 162), GREY, d=3)
o.draw()
cv.fill(ell(166, 140, 172, 148), '#4a2c1a')
cv.fill(ell(167, 141, 170, 144), WOOD['b'])
for k in range(6):   # chisel marks on the wheel face
    cv.dots([(160 + r(0, 18), 132 + r(0, 26))], GREY['s'])
cv.fill(ell(156, 128, 182, 162) & ~ell(157, 129, 183, 163), '#4a4a3a')
cv.fill(ell(156, 154, 182, 164) & ell(156, 128, 182, 162) & mash, '#3f3f1f')   # wheel sitting in the mash
# oil spout and jars
cv.fill(rect(196, 166, 202, 167), '#8a8474')
cv.fill(rect(201, 168, 201, 174), '#f2c93a')
for jx, jy, jh, col in ((196, 190, 16, TERRA), (210, 194, 18, ramp('#d9a855', '#b07f3a', '#f0cc80')), (182, 196, 14, TERRA), (146, 192, 14, ramp('#d9a855', '#b07f3a', '#f0cc80'))):
    o = cv.obj()
    o.part(ell(jx - 5, jy - jh, jx + 5, jy - jh // 3) | poly([(jx - 4, jy - jh // 2), (jx + 4, jy - jh // 2), (jx + 1, jy), (jx - 1, jy)]), col, d=2)
    o.part(rect(jx - 2, jy - jh - 3, jx + 2, jy - jh + 1), col, d=1)
    o.draw()
    cv.fill(rect(jx - 3, jy - jh - 3, jx + 3, jy - jh - 3), col['s'])
    cv.fill(rect(jx - 4, jy - jh // 2 - 3, jx + 4, jy - jh // 2 - 3), col['s'])
cv.fill(rect(200, 174, 203, 175), '#f2c93a')   # oil pooling in the first jar's mouth
# gnome pushing the beam
gnome(240, 166, ramp('#e8b878', '#c08a4a', '#f6d49a'), BLUE, s=1.0, face=-1, arm=1)
# sacks of olives by the press
for sx_, sy_ in ((128, 162), (136, 166)):
    o = cv.obj()
    o.part(rrect(sx_, sy_ - 10, sx_ + 9, sy_, 2) | poly([(sx_ + 2, sy_ - 10), (sx_ + 7, sy_ - 10), (sx_ + 5, sy_ - 13)]), ramp('#d8c6a0', '#a8946e', '#f0e4c4'), d=2)
    o.draw()
    cv.dots([(sx_ + 3, sy_ - 11), (sx_ + 5, sy_ - 11), (sx_ + 4, sy_ - 12)], '#3a2a3a')
    cv.fill(rect(sx_ + 2, sy_ - 9, sx_ + 7, sy_ - 9), '#7a4a1f')

# ================================================================ LEMON TREES in big terracotta pots
for lx, ly, w in ((140, 150, 16), (222, 196, 18)):
    o = cv.obj()
    o.part(poly([(lx - 7, ly - 10), (lx + 7, ly - 10), (lx + 5, ly), (lx - 5, ly)]), TERRA, d=2)
    o.part(rect(lx - 8, ly - 12, lx + 8, ly - 10), TERRA, d=1)
    o.part(rect(lx - 1, ly - 22, lx + 1, ly - 12), BARK, d=0)
    o.draw()
    cm = clump(lx, ly - 26, w // 2 - 3, 4, 8, 4, 6)
    o = cv.obj()
    o.part(cm, ramp('#3f7a3a', '#2a5a2a', '#6aa04a'), d=2)
    o.draw()
    ys, xs = np.nonzero(cm & shift(cm, 1, 1) & shift(cm, -1, -1))
    for k in range(9):
        i = r(0, len(xs) - 1)
        cv.fill(rect(int(xs[i]), int(ys[i]), int(xs[i]) + 2, int(ys[i]) + 1), LEMON['b'])
        cv.dots([(int(xs[i]), int(ys[i]))], LEMON['r'])

# ================================================================ VINE PERGOLA and the table
o = cv.obj()
o.part(rect(250, 128, 252, 186) | rect(296, 128, 298, 186), WOOD, d=1)
o.part(rect(244, 124, 299, 126), WOOD, d=1)
o.draw()
for k in range(4):
    lx = 246 + k * 14
    cv.fill(rect(lx, 122, lx + 2, 128), WOOD['s'])
vine = clump(272, 124, 26, 3, 16, 4, 6) | clump(297, 138, 2, 10, 5, 3, 4)
o = cv.obj()
o.part(vine, GREEN, d=2)
o.draw()
specks(vine, ['#7ab55c', '#a4b86a'], 30)
for gx0, gy0 in ((258, 130), (270, 128), (284, 131), (294, 146), (264, 128)):   # grape bunches
    for dx, dy in ((0, 0), (2, 0), (4, 0), (1, 2), (3, 2), (2, 4)):
        cv.fill(rect(gx0 + dx, gy0 + dy, gx0 + dx + 1, gy0 + dy + 1), PURP['b'])
        cv.dots([(gx0 + dx, gy0 + dy)], PURP['r'])
    cv.dots([(gx0 + 2, gy0 - 1)], GREEN['s'])
# the two diners (drawn first so the table hides their legs)
gnome(266, 168, RED, ramp('#e8b878', '#c08a4a', '#f6d49a'), s=0.86, face=1, legs=False)
gnome(288, 168, ramp('#3f8fb0', '#25637d', '#a9d6ea'), ramp('#f0e0b8', '#c9ad7a', '#fff4d8'), s=0.86, face=-1, arm=1, legs=False)
o = cv.obj()
o.part(rect(254, 164, 299, 170), ramp('#f0f0e8', '#c9c5bc', '#ffffff'), d=1)
o.part(rect(258, 171, 260, 184) | rect(292, 171, 294, 184), WOOD, d=0)
o.draw()
for xx in range(254, 300, 4):   # blue check on the cloth
    cv.fill(rect(xx, 164, xx + 1, 170), '#7fc0d8')
for yy in (165, 168):
    cv.fill(rect(254, yy, 299, yy), '#7fc0d8')
cv.fill(rect(254, 170, 299, 170), '#3f8fb0')
cv.fill(rrect(262, 160, 272, 164, 1), '#d9a35a')   # bread
cv.fill(rect(264, 160, 270, 160), '#f0cc80')
cv.dots([(264, 162), (267, 161), (270, 162)], '#b07a3a')
cv.fill(rect(276, 156, 277, 163), '#8a9a3a')   # oil bottle
cv.fill(rect(276, 155, 277, 155), '#5c3420')
cv.fill(ell(280, 160, 288, 164), '#f0e4c4')   # olive bowl
cv.dots([(282, 160), (284, 160), (286, 161), (283, 161)], '#3a2a3a')
cv.dots([(290, 161), (291, 161), (290, 162), (292, 162)], LEMON['b'])
# a stool beside the table and a sleeping tabby underneath
o = cv.obj()
o.part(rect(244, 176, 252, 178) | rect(245, 179, 246, 186) | rect(250, 179, 251, 186), WOOD, d=1)
o.draw()
cm = ell(270, 180, 284, 186)
cv.fill(cm, '#e8841f')
cv.fill(cm & ~shift(cm, -1, -1), '#b85a14')
cv.dots([(272, 181), (275, 182), (278, 181)], '#b85a14')
cv.dots([(270, 180), (271, 179), (269, 179)], '#e8841f')
cv.fill(line([(284, 184), (288, 182)]), '#e8841f')

# ================================================================ FOREGROUND litter: lemon crate, olive basket, geraniums, gecko, cicada
o = cv.obj()
o.part(rect(240, 188, 258, 198), WOOD, d=2)
o.draw()
cv.fill(rect(240, 193, 258, 193), '#7a4a1f')
for k in range(6):
    lx = 241 + k * 3
    cv.fill(rect(lx, 186, lx + 2, 188), LEMON['b'])
    cv.dots([(lx, 186)], LEMON['r'])
for px_, py_, c in ((268, 194, '#d6322b'), (286, 196, '#f6b8cf'), (160, 196, '#d6322b'), (124, 196, '#ffffff')):
    o = cv.obj()
    o.part(poly([(px_ - 5, py_ - 6), (px_ + 5, py_ - 6), (px_ + 4, py_), (px_ - 4, py_)]), TERRA, d=1)
    o.draw()
    bm = clump(px_, py_ - 9, 3, 1, 5, 2, 4, r2)
    cv.fill(bm, GREEN['b'])
    cv.fill(bm & ~shift(bm, -1, -1), GREEN['s'])
    specks(bm, [c], 6, r2)
gk = (118, 186)   # gecko basking on the retaining wall
cv.fill(rect(gk[0], gk[1], gk[0] + 7, gk[1] + 1), '#6a9a3a')
cv.dots([(gk[0] + 8, gk[1]), (gk[0] + 9, gk[1] + 1), (gk[0] - 1, gk[1] + 1), (gk[0] - 2, gk[1] + 2), (gk[0] - 3, gk[1] + 2),
         (gk[0] + 1, gk[1] - 1), (gk[0] + 5, gk[1] - 1), (gk[0] + 1, gk[1] + 2), (gk[0] + 5, gk[1] + 2)], '#6a9a3a')
cv.dots([(gk[0] + 8, gk[1] - 1)], DARK)
for cx_, cy_ in ((204, 108), (170, 92)):   # cicadas on trunks
    cv.dots([(cx_, cy_), (cx_, cy_ + 1), (cx_ + 1, cy_ + 1)], '#3a4a2a')
for _ in range(40):   # olive leaves and petals blown across the piazza
    px, py = r2(130, W - 3), r2(132, 198)
    if piazza[py, px]:
        cv.dots([(px, py), (px + 1, py)], ('#8a9a52', '#b8c48a', '#f6b8cf')[r2(0, 2)])


def fold_colours(cap=96):
    """Fold the rarest colours into their nearest kept colour, to stay under the cap (vectorised, no per-pixel loop)."""
    flat = cv.px.reshape(-1, 3)
    cols, inv, cnt = np.unique(flat, axis=0, return_inverse=True, return_counts=True)
    if len(cols) <= cap:
        return
    keep = np.argsort(-cnt)[:cap]
    d = ((cols[:, None, :].astype(int) - cols[keep][None, :, :].astype(int)) ** 2).sum(2)
    cv.px[:] = cols[keep][d.argmin(1)][inv.reshape(-1)].reshape(cv.px.shape)


fold_colours()

if __name__ == '__main__':
    out = sys.argv[1] if len(sys.argv) > 1 else None
    n = save_pic(cv, 'olivewhistle', out)
    print('olivewhistle:', n, 'colours')
