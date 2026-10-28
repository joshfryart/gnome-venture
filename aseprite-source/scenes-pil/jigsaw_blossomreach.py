"""Jigsaw picture: BLOSSOMREACH (EA). Usage: python3 -B aseprite-source/scenes-pil/jigsaw_blossomreach.py [outdir]
A spring hillside in Blossomreach: misty violet mountains with the Long Wall and its watchtowers on the ridge, a gnarled cherry tree over the
Cherry Blossom Teahouse (paper lanterns, a gnome whisking tea on the veranda), a carp-streamer pole, the Thousand Gates climbing stone steps
diagonally up through rice and tea terraces to a five-tier pagoda, paddy ducks and a tea picker on the terraces, a blossom-picnic, a koi pond with
a red moon bridge (a gnome on top flying a dragon-fly kite, the golden koi below), a stone lantern, and the Panda Bamboo Grove in the front right.
"""
import sys
import math

from jigsaw_common import *  # noqa: F401,F403

# ---------------------------------------------------------------- palette: blush pink, vermilion, bamboo green, misty violet (+ stone and umber)
SKY0, SKY1, SKY2 = '#b7d7e8', '#cfe3ec', '#f1dde3'
MT0, MT1, MT2 = '#c3bedb', '#a9a6cc', '#8f8fbd'
MIST = '#e9e3ef'
PINK = ramp('#f2a7bf', '#d9789a', '#fbd3df')
PINK2 = ramp('#f7c4d4', '#e08aa8', '#ffe8ef')
ROSE = ramp('#e47a9e', '#b8506f', '#f6b8cf')
BLOOMS = [PINK, PINK2, ROSE, PINK, PINK2]
VERM = ramp('#d8432e', '#a52a1e', '#f07a50')
SLATE = ramp('#5a6280', '#3e445e', '#8a92b0')
BAMBOO = ramp('#7ab84f', '#4a8a3a', '#b4d878')
GRASS = ramp('#8cc45a', '#5ea040', '#b4d878')
DGRASS = ramp('#5ea040', '#3f7a34', '#8cc45a')
TEA = ramp('#4f9a45', '#2f6a3a', '#7ab55c')
BARK = ramp('#6a4a3a', '#4a3028', '#8a6a52')
WOOD = ramp('#b07a3a', '#7a4a1f', '#d9a35a')
STONE = ramp('#b9b2a2', '#8a8474', '#d8d2c2')
PAPER = ramp('#f6eedc', '#d9ccb0', '#fffaf0')
WATER = ramp('#5fa8a0', '#3f8480', '#9fd0c8')
PADDY = ramp('#a9d4dc', '#7fb4c4', '#d6eef2')
EARTH = ramp('#9a6b3f', '#6a4a2a', '#c9a96e')
GOLD = ramp('#f0b92b', '#c98a14', '#f8dc6a')
TEAL = ramp('#3f8fb0', '#25637d', '#a9d6ea')
SKIN = ramp('#f2c8a0', '#d9a07a', '#fff0d8')
BEARD = ramp('#f1ece0', '#c9c5bc', '#ffffff')
WHITE = ramp('#f6f4ee', '#cfcac0', '#ffffff')
INK = '#2a1a10'
DARK = '#3a2a2a'

cv = new_canvas(SKY0)
r = rnd(4417)
r2 = rnd(91)   # second stream for later details
r3 = rnd(2026)   # third stream (pass 1 details), so earlier layout does not shift
r4 = rnd(777)   # fourth stream (pass 2 details)
yy_, xx_ = np.mgrid[0:H, 0:W]


def shadow(x0, y0, x1, y1, col='#3f7a34'):
    cv.fill(ell(x0, y0, x1, y1), col)


def clump(cx, cy, rx, ry, n, s0=5, s1=9, r=r):
    m = blank()
    for _ in range(n):
        ex, ey, s = cx + r(-rx, rx), cy + r(-ry, ry), r(s0, s1)
        m |= ell(ex - s, ey - s * 3 // 4, ex + s, ey + s * 3 // 4)
    return m


def blossom(m, rp, d=3, specks=20, outline=True, r=r):
    o = cv.obj(outline=outline)
    o.part(m, rp, d=d)
    o.draw()
    ys, xs = np.nonzero(m)
    if not len(xs):
        return
    inner = m & shift(m, 2, 0) & shift(m, -2, 0) & shift(m, 0, 2) & shift(m, 0, -2)
    for k in range(specks):   # five-dot blossoms in white / deeper pink
        i = r(0, len(xs) - 1)
        x, y = int(xs[i]), int(ys[i])
        if not inner[y, x]:
            continue
        col = ('#ffffff', rp['r'], ROSE['b'], '#ffe8ef')[k % 4]
        cv.dots([(x, y), (x + 1, y), (x - 1, y), (x, y - 1), (x, y + 1)], col)
        cv.dots([(x, y)], GOLD['b'] if k % 3 == 0 else ROSE['s'])


def gnome(gx, gy, hat=VERM, tunic=TEAL, s=1.0, lean=-1):
    """Standing gnome, feet at (gx, gy). Returns the right-hand position."""
    def S(v):
        return int(round(v * s))
    o = cv.obj()
    o.part(rect(gx - S(5), gy - S(2), gx - S(1), gy) | rect(gx + S(1), gy - S(2), gx + S(5), gy), ramp('#5c3420', '#3d2a1c', '#7a4a1f'), d=1)
    o.part(rrect(gx - S(5), gy - S(11), gx + S(5), gy - S(2), 1), tunic, d=2, contour=True)
    o.part(poly([(gx - S(5), gy - S(14)), (gx + S(5), gy - S(14)), (gx, gy - S(5))]), BEARD, d=1, contour=True)
    o.part(rect(gx - S(4), gy - S(18), gx + S(4), gy - S(14)), SKIN, d=1)
    o.part(poly([(gx - S(6), gy - S(17)), (gx + S(6), gy - S(17)), (gx + lean * S(4), gy - S(31))]), hat, d=2, contour=True)
    o.part(rect(gx + S(5), gy - S(10), gx + S(7), gy - S(7)), tunic, d=1)
    o.draw()
    cv.fill(rect(gx - S(6), gy - S(18), gx + S(6), gy - S(17)), hat['s'])
    cv.dots([(gx - S(2), gy - S(16)), (gx + S(2), gy - S(16))], INK)
    cv.dots([(gx, gy - S(15)), (gx + 1, gy - S(15))], '#e0907a')
    cv.dots([(gx - S(3), gy - S(14)), (gx + S(3), gy - S(14))], '#f0a0a0')
    cv.fill(rect(gx + S(7), gy - S(10), gx + S(8), gy - S(8)), SKIN['b'])
    return gx + S(8), gy - S(9)


# ---------------------------------------------------------------- sky: bands, clouds, cranes, kites
cv.fill(rect(0, 22, W - 1, 60), SKY1)
cv.fill(rect(0, 44, W - 1, 100), SKY2)
for cx, cy, w in ((150, 12, 40), (214, 30, 34), (120, 40, 30), (290, 8, 26), (176, 50, 26), (240, 6, 22)):
    m = ell(cx - w // 2, cy - 5, cx + w // 2, cy + 5) | ell(cx - w // 4, cy - 9, cx + w // 6, cy + 3) | ell(cx + 1, cy - 7, cx + w // 2 - 5, cy + 4)
    m &= ~rect(0, cy + 3, W, H)
    cv.fill(m, '#fdf6f8')
    cv.fill(m & ~shift(m, -2, -2) & rect(0, cy - 1, W, cy + 3), '#ecd8e2')
    cv.fill(m & rect(0, cy + 3, W, cy + 3), '#d8c8de')
for bx, by, s in ((132, 24, 1), (142, 28, 1), (152, 32, 1), (226, 14, 0), (232, 18, 0)):   # cranes: white wings with ink tips
    if s:
        cv.dots([(bx - 3, by - 1), (bx - 2, by - 1), (bx - 1, by), (bx, by), (bx + 1, by), (bx + 2, by - 1), (bx + 3, by - 2)], '#ffffff')
        cv.dots([(bx - 4, by - 2), (bx + 4, by - 3)], INK)
        cv.dots([(bx + 1, by + 1), (bx + 2, by + 1)], '#d8432e')
    else:
        cv.dots([(bx, by), (bx + 1, by - 1), (bx + 2, by), (bx + 3, by - 1), (bx + 4, by)], '#5a6280')
# swallow kite (high, centre-right)
kx, ky = 196, 18
o = cv.obj()
o.part(poly([(kx, ky - 6), (kx + 9, ky + 1), (kx + 3, ky + 1), (kx + 6, ky + 9), (kx, ky + 4), (kx - 6, ky + 9), (kx - 3, ky + 1), (kx - 9, ky + 1)]), TEAL, d=1)
o.draw()
cv.fill(poly([(kx, ky - 4), (kx + 2, ky + 2), (kx - 2, ky + 2)]), '#ffffff')
cv.dots([(kx - 1, ky - 3), (kx + 1, ky - 3)], INK)
for k in range(5):
    cv.dots([(kx + 1 + k, ky + 10 + k * 2), (kx + 2 + k, ky + 11 + k * 2)], VERM['b'] if k % 2 else GOLD['b'])
# the dragon-fly kite (flown from the moon bridge), drawn now, string later
dkx, dky = 168, 34
o = cv.obj()
for t in (-1, 1):
    o.part(ell(dkx + t * 2 - 7 if t < 0 else dkx + 2, dky - 4, dkx + t * 2 + (0 if t < 0 else 9), dky), ramp('#c8ecd8', '#8cc4a8', '#ffffff'), d=1)
    o.part(ell(dkx + (-8 if t < 0 else 2), dky + 1, dkx + (-1 if t < 0 else 8), dky + 4), ramp('#c8ecd8', '#8cc4a8', '#ffffff'), d=1)
o.part(rect(dkx - 1, dky - 6, dkx + 1, dky + 12), ramp('#3faa78', '#1f7a50', '#8ad8a8'), d=1)
o.draw()
cv.dots([(dkx - 1, dky - 5), (dkx + 1, dky - 5)], INK)
for yy in range(dky + 2, dky + 12, 3):
    cv.dots([(dkx, yy)], GOLD['b'])

# ---------------------------------------------------------------- far misty mountains, the Long Wall on the ridge
m0 = poly([(0, 60), (24, 40), (44, 52), (78, 30), (104, 50), (132, 38), (160, 56), (196, 34), (232, 54), (262, 44), (300, 56), (300, 120), (0, 120)])
cv.fill(m0, MT0)
cv.fill(m0 & ~shift(m0, 2, 2), '#d8d3e8')   # snow-pale lit rims
for px, py in ((78, 30), (196, 34), (132, 38)):   # snow caps
    cap = m0 & poly([(px - 9, py + 9), (px, py - 1), (px + 9, py + 9), (px + 4, py + 7), (px + 1, py + 10), (px - 3, py + 7)])
    cv.fill(cap, '#f4f0f8')
m1 = poly([(0, 78), (30, 62), (62, 72), (96, 56), (126, 70), (150, 62), (184, 74), (214, 60), (250, 72), (300, 66), (300, 120), (0, 120)])
cv.fill(m1, MT1)
cv.fill(m1 & ~shift(m1, 2, 2), '#bdbad8')
cv.fill(rect(0, 80, W - 1, 82) & m0, MIST)
cv.fill(rect(0, 84, W - 1, 84) & m0, MIST)
# the Long Wall snakes along the m1 ridge with watchtowers
ridge = []
for x in range(0, W):
    col = m1[:, x]
    ridge.append(int(np.argmax(col)))
wall = blank()
for x in range(0, W):
    y = ridge[x] + 2
    wall[y - 1:y + 2, x] = True
    if x % 4 < 2:
        wall[y - 2, x] = True   # crenels
cv.fill(wall, '#7d7aa6')
cv.fill(wall & ~shift(wall, 0, 1), '#d8d3e8')
for tx in (30, 96, 150, 214):
    ty = ridge[tx]
    o = cv.obj(outline=False)
    o.part(rect(tx - 3, ty - 6, tx + 3, ty + 3), ramp('#8a86b2', '#6d6a98', '#c3bedb'), d=1)
    o.draw()
    cv.fill(rect(tx - 4, ty - 7, tx + 4, ty - 7), '#6d6a98')
    cv.dots([(tx - 4, ty - 8), (tx - 2, ty - 8), (tx, ty - 8), (tx + 2, ty - 8), (tx + 4, ty - 8)], '#6d6a98')
    cv.dots([(tx, ty - 3), (tx, ty - 2)], '#4a4878')
m2 = poly([(0, 92), (40, 80), (86, 90), (130, 78), (170, 90), (210, 82), (300, 90), (300, 120), (0, 120)])
cv.fill(m2, MT2)
cv.fill(m2 & ~shift(m2, 2, 2), '#a9a6cc')
cv.fill(rect(0, 94, W - 1, 95) & m2, '#b4b2d4')   # low mist band
x = 1
while x < W - 2:   # far blossom dots and pines on the near range
    x += r2(3, 8)
    if x >= W - 1:
        break
    ty = int(np.argmax(m2[:, x])) + r2(3, 12)
    cv.dots([(x, ty), (x + 1, ty), (x, ty + 1)], ('#c8a8c8', '#7d7aa6', '#e4c4d8')[r2(0, 2)])

# ---------------------------------------------------------------- near blossom ridge behind the teahouse (left half)
x = -6
while x < 170:
    w = r(12, 20)
    rp = [PINK2, PINK, ROSE, BAMBOO, PINK2][r(0, 4)]
    top = 94 + r(0, 8)
    o = cv.obj(outline=False)
    o.part(ell(x, top, x + w, top + w * 3 // 4 + 4), rp, d=2)
    o.draw()
    for k in range(3):
        cv.dots([(x + r(2, w - 2), top + r(2, 9))], '#ffffff' if rp is not BAMBOO else BAMBOO['r'])
    x += w - r(2, 5)

# ---------------------------------------------------------------- ground (left meadow)
cv.fill(rect(0, 106, W - 1, H - 1), GRASS['b'])
dg = yy_ >= (140 + 3 * np.sin(xx_ / 11.0) + 2 * np.sin(xx_ / 4.3 + 1.0)).astype(int)
cv.fill(dg, DGRASS['b'])
for y in range(106, H):
    for _ in range(4):
        gx = r(0, W - 1)
        cv.dots([(gx, y), (gx, y - 1)], GRASS['r'] if y < 140 and r(0, 2) else DGRASS['s'])

# ---------------------------------------------------------------- right hill with terraces (rice paddies and tea rows)
HE = []   # the hill's left shoulder: a rounded, wobbly slope instead of one straight ramp
for i in range(17):
    t = i / 16.0
    HE.append((int(round(112 + 96 * t + 2 * math.sin(t * 11))), int(round(150 - 66 * t - 9 * math.sin(math.pi * t) + 2.5 * math.sin(t * 17 + 1)))))
hill = poly(HE + [(222, 76), (246, 66), (272, 61), (300, 62), (300, 200), (112, 200)])
cv.fill(hill, GRASS['b'])
edges = [np.array([62 + 9 * k + 2.0 * math.sin(x / 19.0 + k * 1.7) + (x - 230) * 0.04 for x in range(W)]) for k in range(11)]
terr = []
for k in range(10):
    band = (yy_ >= edges[k][None, :]) & (yy_ < edges[k + 1][None, :]) & hill & (yy_ < 150)
    terr.append(band)
    kind = 'paddy' if k in (1, 3, 4, 7) else 'tea'
    if kind == 'paddy':
        cv.fill(band, PADDY['b'])
        cv.fill(band & ~shift(band, 0, 2), PADDY['r'])
        ys, xs = np.nonzero(band)
        for i in range(0, len(xs), 7):   # rows of sprouts
            x, y = int(xs[i]), int(ys[i])
            if x % 4 == (k % 4) and y % 3 == 0:
                cv.dots([(x, y), (x, y - 1)], BAMBOO['b'])
        for i in range(0, len(xs), 97):
            cv.dots([(int(xs[i]), int(ys[i]))], '#ffffff')
    else:
        cv.fill(band, TEA['b'])
        tops = band & ~shift(band, 0, 1)
        ys, xs = np.nonzero(tops)
        for i in range(len(xs)):   # rounded tea bushes along each row
            x, y = int(xs[i]), int(ys[i])
            if x % 7 == k % 7:
                cv.fill(ell(x - 3, y, x + 3, y + 4) & band, TEA['r'])
                cv.dots([(x - 1, y + 1)], '#b4d878')
            elif x % 7 == (k + 4) % 7:
                cv.fill(rect(x, y + 2, x, y + 5) & band, TEA['s'])
    lip = band & ~shift(band, 0, -2)   # retaining wall at the front of each terrace
    cv.fill(lip, EARTH['b'])
    cv.fill(band & ~shift(band, 0, -1), EARTH['s'])
    ys, xs = np.nonzero(lip)
    for i in range(0, len(xs), 5):
        if xs[i] % 6 == 0:
            cv.dots([(int(xs[i]), int(ys[i]))], EARTH['r'])
cv.fill(hill & ~shift(hill, 2, 2) & (yy_ < 150) & (xx_ > 206), GRASS['r'])
cv.fill(hill & ~shift(hill, 1, 0) & (yy_ < 152), DGRASS['s'])   # a darker lip where the slope turns away
for i in range(1, 16):   # tea shrubs, blossom bushes and a stone or two along the shoulder
    t = i / 16.0
    ex, ey = HE[i]
    ex, ey = ex + r3(-1, 3), ey + r3(0, 3)
    kind = (0, 1, 0, 2, 1, 0, 1, 2)[i % 8]
    if kind == 2:
        o = cv.obj()
        o.part(ell(ex - 3, ey - 1, ex + 3, ey + 3), STONE, d=1)
        o.draw()
        cv.dots([(ex - 1, ey), (ex, ey)], STONE['r'])
        continue
    m = clump(ex, ey, 3, 1, 3, 3, 4, r=r3)
    if kind == 0:
        o = cv.obj()
        o.part(m, TEA, d=2)
        o.draw()
        ys_, xs_ = np.nonzero(m)
        for k in range(0, len(xs_), 9):
            cv.dots([(int(xs_[k]), int(ys_[k]))], TEA['r'] if k % 2 else '#b4d878')
    else:
        blossom(m, (PINK2, ROSE)[i % 2], d=2, specks=4, r=r3)

# ---------------------------------------------------------------- the pagoda on the hilltop (five tiers, vermilion walls, slate roofs)
pcx, pby = 262, 64
shadow(pcx - 30, pby + 3, pcx + 32, pby + 9, TEA['s'])
o = cv.obj()   # a raised stone terrace the pagoda stands on, the steps arrive at its front
o.part(rect(pcx - 26, pby - 2, pcx + 26, pby + 5), STONE, d=2)
o.draw()
cv.fill(rect(pcx - 25, pby - 1, pcx + 25, pby - 1), STONE['r'])
for yy in (pby + 1, pby + 3):
    cv.fill(rect(pcx - 25, yy, pcx + 25, yy), STONE['s'])
for xx in range(pcx - 23, pcx + 25, 5):
    cv.dots([(xx + (2 if xx % 2 else 0), pby + 2), (xx, pby + 4)], STONE['s'])
for xx in range(pcx - 25, pcx + 26, 4):   # little vermilion railing round the terrace edge
    cv.fill(rect(xx, pby - 4, xx, pby - 2), VERM['s'])
cv.fill(rect(pcx - 25, pby - 4, pcx + 25, pby - 4), VERM['b'])
o = cv.obj()
o.part(rect(pcx - 18, pby - 3, pcx + 18, pby + 1), STONE, d=1)
o.draw()
for bx_ in (pcx - 29, pcx + 27):   # shrubs tucked at the terrace corners
    o = cv.obj()
    o.part(clump(bx_, pby + 2, 2, 1, 3, 3, 4, r=r3), TEA, d=2)
    o.draw()
    cv.dots([(bx_ - 1, pby + 1), (bx_ + 1, pby)], '#b4d878')
y = pby - 3
walls = (13, 11, 9, 8, 6)
for i, hw in enumerate(walls):
    wh = 7
    o = cv.obj()
    o.part(rect(pcx - hw, y - wh, pcx + hw, y), VERM, d=2)
    o.draw()
    cv.fill(rect(pcx - hw + 1, y - wh + 1, pcx + hw - 1, y - wh + 1), '#f6eedc')   # white rail band
    for xx in range(pcx - hw + 2, pcx + hw - 1, 3):
        cv.dots([(xx, y - wh + 2)], '#f6eedc')
    cv.fill(rect(pcx - 2, y - 4, pcx + 2, y), DARK if i == 0 else '#f5cf6a')   # door / lit window
    y -= wh
    R = hw + 7
    nhw = walls[i + 1] if i + 1 < len(walls) else 3
    roof = poly([(pcx - R - 3, y - 3), (pcx - R + 1, y + 1), (pcx + R - 1, y + 1), (pcx + R + 3, y - 3), (pcx + R - 4, y - 3), (pcx + nhw + 1, y - 6), (pcx - nhw - 1, y - 6), (pcx - R + 4, y - 3)])
    o = cv.obj()
    o.part(roof, SLATE, d=2)
    o.draw()
    cv.fill(roof & ~shift(roof, 0, -1), VERM['s'])   # eave underside
    for xx in range(pcx - R + 3, pcx + R - 2, 3):
        cv.dots([(xx, y - 2)], SLATE['s'])
    cv.dots([(pcx - R - 3, y - 4), (pcx + R + 3, y - 4)], GOLD['b'])   # bells on the tips
    cv.dots([(pcx - R - 3, y - 2), (pcx + R + 3, y - 2)], GOLD['s'])
    y -= 5
o = cv.obj()   # finial with rings
o.part(rect(pcx - 1, y - 10, pcx + 1, y + 1), GOLD, d=1)
o.part(ell(pcx - 2, y - 13, pcx + 2, y - 9), GOLD, d=1)
o.draw()
for k in range(3):
    cv.fill(rect(pcx - 2, y - 2 - k * 3, pcx + 2, y - 2 - k * 3), GOLD['s'])
# little blossom trees either side of the pagoda
for cx, cy, rp in ((238, 58, PINK2), (288, 56, PINK), (296, 46, ROSE)):
    cv.fill(rect(cx, cy + 3, cx + 1, cy + 9), BARK['b'])
    blossom(clump(cx, cy, 4, 2, 5, 3, 5), rp, d=2, specks=6)

# ---------------------------------------------------------------- the stone steps of the Thousand Gates, climbing to the pagoda
PTS = ((199, 170, 40), (180, 180, 32), (160, 194, 26), (140, 208, 20), (120, 222, 15), (100, 236, 11), (82, 246, 8), (64, 254, 6))


def path_at(y):
    for (y0, x0, w0), (y1, x1, w1) in zip(PTS, PTS[1:]):
        if y1 <= y <= y0:
            t = (y0 - y) / (y0 - y1)
            return x0 + (x1 - x0) * t, w0 + (w1 - w0) * t
    return None


steps = blank()
for y in range(pby + 6, H):
    pw = path_at(y)
    if pw:
        cx, w = pw
        steps[y, max(0, int(cx - w / 2)):min(W, int(cx + w / 2) + 1)] = True
cv.fill(dil4(dil4(steps)) & ~steps, DGRASS['s'])
cv.fill(steps, STONE['b'])
y, k = H - 1, 0
while y > pby + 6:   # treads and risers, closer together as they climb
    cx, w = path_at(y)
    sp = max(2, int(w / 6))
    cv.fill(steps & rect(0, y, W, y), STONE['s'])
    cv.fill(steps & rect(0, y - 1, W, y - 1), STONE['r'])
    for j in range(2):   # joints between slabs
        jx = int(cx - w / 2 + (w / 3) * (j + 1) + (k % 2) * 3)
        cv.fill(rect(jx, y - sp + 1, jx, y - 2) & steps, STONE['s'])
    y -= sp
    k += 1
cv.fill(steps & ~shift(steps, 1, 0), '#8a8474')
cv.fill(steps & ~shift(steps, -1, 0), '#ece6d8')


def torii(cx, by, w, h):
    pw = max(1, w // 9)
    th = max(1, h // 12)
    xl, xr = cx - w // 2, cx + w // 2
    o = cv.obj(outline=w >= 14)
    posts = rect(xl, by - h, xl + pw, by) | rect(xr - pw, by - h, xr, by)
    o.part(posts, VERM, d=1 if w < 20 else 2)
    o.part(rect(xl - max(1, w // 10), by - h + th * 3, xr + max(1, w // 10), by - h + th * 4), VERM, d=1)   # nuki
    o.part(rect(xl - w // 8, by - h + th, xr + w // 8, by - h + th * 2), VERM, d=1)   # shimaki
    kas = poly([(xl - w // 5, by - h - th - 1), (xl - w // 8, by - h), (xr + w // 8, by - h), (xr + w // 5, by - h - th - 1), (xr, by - h - th), (xl, by - h - th)])
    o.part(kas, ramp(DARK, '#1f1414', '#5a4a4a'), d=1)
    o.part(rect(cx - max(1, pw // 2), by - h + th * 2, cx + max(1, pw // 2), by - h + th * 3), VERM, d=0)   # gakuzuka
    o.draw()
    cv.fill(rect(xl, by - 1, xl + pw, by) | rect(xr - pw, by - 1, xr, by), DARK)   # black feet
    if w >= 14:
        cv.fill(rect(xl, by - h + 1, xl, by - 2), VERM['r'])


for gy in (89, 101, 115, 133, 156):   # the top gate sits clear below the pagoda terrace   # fewer, spaced gates so the climbing stair shows between them
    cx, w = path_at(gy)
    gw = int(w + 4 + w * 0.15)
    torii(int(cx), gy, gw, int(gw * 1.15))

# ---------------------------------------------------------------- terrace life: tea picker, paddy ducks, a scarecrow kite pole
tpx, tpy = 176, 110
hx_, hy_ = gnome(tpx, tpy, hat=VERM, tunic=ramp('#8a5aa8', '#5e3a7a', '#b88ad0'), s=0.6, lean=1)
o = cv.obj()
o.part(rrect(tpx - 9, tpy - 8, tpx - 4, tpy - 3, 1), WOOD, d=1)   # tea basket on her back
o.draw()
cv.dots([(tpx - 8, tpy - 9), (tpx - 6, tpy - 10), (tpx - 5, tpy - 9)], TEA['r'])
for dx, dy in ((276, 100), (284, 103), (292, 99)):   # paddy ducks
    o = cv.obj()
    o.part(ell(dx, dy, dx + 6, dy + 3), WHITE, d=1)
    o.part(ell(dx - 1, dy - 3, dx + 2, dy + 1), WHITE, d=1)
    o.draw()
    cv.dots([(dx - 2, dy - 2)], GOLD['b'])
    cv.dots([(dx, dy - 2)], INK)
    cv.fill(rect(dx, dy + 4, dx + 7, dy + 4), PADDY['r'])
for sx, sy in ((214, 84), (196, 100), (230, 76)):   # stone lanterns up the steps' side
    o = cv.obj(outline=False)
    o.part(rect(sx, sy - 5, sx + 2, sy), STONE, d=1)
    o.part(rect(sx - 1, sy - 7, sx + 3, sy - 6), STONE, d=0)
    o.draw()
    cv.dots([(sx + 1, sy - 4)], '#f5cf6a')

# kite string from the bridge gnome's hand (79, 150), drawn before the teahouse so it passes behind it
cv.fill(line([(79, 147), (110, 118), (140, 80), (dkx, dky + 12)]), '#f6eedc')

# ---------------------------------------------------------------- the Cherry Blossom Teahouse (centre-left)
tx0, tx1, tby = 64, 140, 132
shadow(tx0 - 2, tby - 2, tx1 + 4, tby + 4)
o = cv.obj()
o.part(rect(tx0, tby - 6, tx1, tby), STONE, d=2)   # stone plinth
o.part(rect(tx0 + 6, tby - 34, tx1 - 6, tby - 7), PAPER, d=2)   # walls
o.draw()
for xx in range(tx0 + 2, tx1 - 1, 5):
    cv.dots([(xx, tby - 3), (xx + 1, tby - 3)], STONE['s'])
for xx in range(tx0 + 6, tx1 - 5, 13):   # dark posts
    cv.fill(rect(xx, tby - 34, xx + 1, tby - 7), BARK['s'])
for xx in range(tx0 + 9, tx1 - 6, 13):   # shoji grids
    for gx in (xx + 3, xx + 6):
        cv.fill(rect(gx, tby - 32, gx, tby - 9), '#c9b48a')
    for gy in range(tby - 30, tby - 8, 5):
        cv.fill(rect(xx, gy, xx + 9, gy), '#c9b48a')
cv.fill(rect(tx0 + 46, tby - 30, tx0 + 56, tby - 8), '#f5cf6a')   # an open screen, warm light inside
cv.fill(rect(tx0 + 46, tby - 30, tx0 + 56, tby - 26), VERM['b'])   # noren curtain
for xx in (tx0 + 49, tx0 + 53):
    cv.fill(rect(xx, tby - 30, xx, tby - 24), VERM['s'])
cv.dots([(tx0 + 50, tby - 28), (tx0 + 51, tby - 28)], '#ffffff')
rw = ell(tx0 + 14, tby - 30, tx0 + 26, tby - 18)   # round moon window
cv.fill(rw, '#f5cf6a')
cv.fill(rw & ~shift(rw, -1, -1), '#e8a317')
cv.fill(rect(tx0 + 20, tby - 30, tx0 + 20, tby - 18) & rw, BARK['s'])
cv.fill(rect(tx0 + 14, tby - 24, tx0 + 26, tby - 24) & rw, BARK['s'])
cv.fill(dil4(rw) & ~rw, BARK['b'])
o = cv.obj()   # veranda deck
o.part(rect(tx0 + 2, tby - 9, tx1 - 2, tby - 6), WOOD, d=1)
o.draw()
for xx in range(tx0 + 4, tx1 - 2, 6):
    cv.dots([(xx, tby - 8)], WOOD['s'])
roof = poly([(tx0 - 8, tby - 40), (tx0 - 2, tby - 34), (tx1 + 2, tby - 34), (tx1 + 8, tby - 40), (tx1 + 2, tby - 41), (tx1 - 12, tby - 54), (tx0 + 12, tby - 54), (tx0 - 2, tby - 41)])
o = cv.obj()
o.part(roof, SLATE, d=3)
o.part(rect(tx0 + 10, tby - 58, tx1 - 10, tby - 54), SLATE, d=1)   # ridge
o.draw()
for xx in range(tx0 + 2, tx1 - 1, 4):   # tile ribs
    cv.fill(line([(xx, tby - 36), (xx + (xx - (tx0 + tx1) // 2) // 8, tby - 52)]) & roof, SLATE['s'])
cv.fill(roof & ~shift(roof, 0, -1), '#2e3248')
cv.fill(rect(tx0 + 10, tby - 58, tx1 - 10, tby - 58), SLATE['r'])
for ex in (tx0 + 8, tx1 - 10):   # ridge-end ornaments
    cv.fill(rect(ex, tby - 61, ex + 2, tby - 58), VERM['b'])
    cv.dots([(ex, tby - 62), (ex + 2, tby - 62)], VERM['b'])
# hanging paper lanterns along the eaves
for lx in (tx0 - 2, tx0 + 18, tx0 + 38, tx1 - 22, tx1 - 2):
    cv.fill(rect(lx, tby - 34, lx, tby - 32), INK)
    o = cv.obj()
    o.part(ell(lx - 3, tby - 32, lx + 3, tby - 24), VERM, d=1)
    o.draw()
    cv.fill(rect(lx - 2, tby - 32, lx + 2, tby - 32) | rect(lx - 2, tby - 24, lx + 2, tby - 24), DARK)
    cv.fill(rect(lx - 3, tby - 29, lx + 3, tby - 29), VERM['s'])
    cv.dots([(lx - 1, tby - 30), (lx - 1, tby - 27)], '#f5cf6a')
    cv.dots([(lx, tby - 23)], GOLD['b'])
# a ginger cat curled on the roof ridge, and a pair of sparrows further along
ctx, cty = 92, tby - 58
o = cv.obj()
o.part(ell(ctx, cty - 5, ctx + 10, cty + 1), ramp('#e89a4a', '#b86a2a', '#f8c47a'), d=1)
o.part(ell(ctx + 7, cty - 8, ctx + 13, cty - 2), ramp('#e89a4a', '#b86a2a', '#f8c47a'), d=1)
o.part(poly([(ctx + 7, cty - 7), (ctx + 8, cty - 10), (ctx + 9, cty - 7)]) | poly([(ctx + 11, cty - 7), (ctx + 12, cty - 10), (ctx + 13, cty - 7)]), ramp('#e89a4a', '#b86a2a', '#f8c47a'), d=0)
o.part(line([(ctx, cty - 1), (ctx - 4, cty + 3)], 2), ramp('#e89a4a', '#b86a2a', '#f8c47a'), d=0)
o.draw()
cv.dots([(ctx + 3, cty - 4), (ctx + 5, cty - 4), (ctx + 4, cty - 2)], '#b86a2a')   # stripes
cv.fill(rect(ctx + 9, cty - 5, ctx + 10, cty - 5) | rect(ctx + 11, cty - 5, ctx + 12, cty - 5), INK)   # sleepy eyes
SPAR = ramp('#b08a62', '#7a5638', '#d8b88a')
def sparrow(sx, sy, f):   # buff belly, chestnut cap, white cheek, black bib, cocked tail
    def X(v):
        return sx + f * v
    o = cv.obj()
    o.part(poly([(X(-1), sy - 3), (X(-5), sy - 7), (X(-3), sy - 7), (X(1), sy - 5)]), ramp('#7a5638', '#4a3020', '#9a7450'), d=0)   # tail
    o.part(ell(min(X(0), X(7)), sy - 6, max(X(0), X(7)), sy - 1), SPAR, d=1)   # body
    o.part(ell(min(X(4), X(9)), sy - 10, max(X(4), X(9)), sy - 5), SPAR, d=1)   # head
    o.draw()
    cv.dots([(X(1), sy - 3), (X(2), sy - 2), (X(3), sy - 2), (X(4), sy - 2)], '#f2e4c0')   # belly
    cv.dots([(X(1), sy - 5), (X(3), sy - 5), (X(2), sy - 4)], '#4a3020')   # wing bars
    cv.dots([(X(2), sy - 4)], '#ffffff')
    cv.dots([(X(5), sy - 10), (X(6), sy - 10), (X(7), sy - 10), (X(5), sy - 9)], '#8a3a1e')   # chestnut cap
    cv.dots([(X(6), sy - 7), (X(7), sy - 7)], '#ffffff')   # cheek
    cv.dots([(X(7), sy - 8)], INK)   # eye
    cv.dots([(X(8), sy - 6), (X(7), sy - 5)], INK)   # bib
    cv.dots([(X(10), sy - 7)], GOLD['s'])   # beak
    cv.dots([(X(3), sy), (X(5), sy)], '#7a4a1f')   # feet


sparrow(113, tby - 58, 1)   # one on the roof ridge; the other perches on the carp pole (drawn after it)
for k, (px_, py_) in enumerate(((78, tby - 46), (100, tby - 40), (126, tby - 47), (110, tby - 50))):   # petals settled on the tiles
    cv.dots([(px_, py_), (px_ + 1, py_)], (PINK['b'], '#ffffff', PINK2['b'], ROSE['b'])[k])
# gnome on the veranda whisking tea at a low table
gtx, gty = tx0 + 34, tby - 7
hx2, hy2 = gnome(gtx, gty, hat=ramp('#e46a9b', '#b8506f', '#f6b8cf'), tunic=BAMBOO, s=0.8)
o = cv.obj()
o.part(rect(gtx + 7, gty - 6, gtx + 20, gty - 4), WOOD, d=1)
o.part(rect(gtx + 8, gty - 3, gtx + 9, gty) | rect(gtx + 18, gty - 3, gtx + 19, gty), WOOD, d=0)
o.part(ell(gtx + 9, gty - 10, gtx + 15, gty - 6) & ~rect(0, 0, W, gty - 9), ramp('#3f7a5a', '#25563e', '#7ab89a'), d=1)   # tea bowl
o.draw()
cv.fill(rect(gtx + 10, gty - 9, gtx + 14, gty - 9), '#a4d870')   # green froth
cv.fill(line([(hx2, hy2), (gtx + 12, gty - 11)]), WOOD['r'])   # whisk
cv.dots([(gtx + 12, gty - 12), (gtx + 11, gty - 12), (gtx + 13, gty - 12)], '#f2e4c0')
cv.dots([(gtx + 17, gty - 7), (gtx + 18, gty - 7)], '#ffffff')   # sweet
cv.dots([(gtx + 17, gty - 8)], PINK['b'])

# ---------------------------------------------------------------- carp-streamer pole by the teahouse
cpx = 150
o = cv.obj()
o.part(rect(cpx, 62, cpx + 1, 132), WOOD, d=1)
o.part(ell(cpx - 1, 59, cpx + 2, 62), GOLD, d=0)
o.draw()
for k, (rp, ln) in enumerate(((VERM, 20), (TEAL, 17), (ROSE, 14))):
    fy = 66 + k * 9
    body = poly([(cpx + 2, fy), (cpx + ln, fy + 1 + (k % 2)), (cpx + ln + 4, fy - 1), (cpx + ln + 4, fy + 7), (cpx + ln, fy + 4), (cpx + 2, fy + 6)])
    o = cv.obj()
    o.part(body, rp, d=1)
    o.draw()
    for sx in range(cpx + 6, cpx + ln - 1, 4):
        cv.fill(ell(sx, fy + 1, sx + 3, fy + 4) & body, rp['r'])
    cv.fill(ell(cpx + 3, fy + 1, cpx + 6, fy + 4), '#ffffff')
    cv.dots([(cpx + 4, fy + 2)], INK)
sparrow(cpx + 5, 59, -1)

# ---------------------------------------------------------------- the gnarled cherry tree (top-left)
shadow(4, 128, 64, 136)
trunk = poly([(14, 134), (22, 120), (26, 96), (22, 76), (30, 56), (40, 42), (50, 44), (40, 60), (36, 80), (40, 100), (38, 120), (50, 134)])
br = line([(34, 62), (70, 40), (104, 34)], 5) | line([(30, 70), (8, 50)], 4) | line([(42, 48), (60, 16)], 4) | line([(70, 40), (124, 54)], 3) | line([(26, 90), (2, 82)], 3)
o = cv.obj()
o.part(trunk, BARK, d=3)
o.part(br, BARK, d=2)
o.draw()
for yy in range(60, 130, 5):
    cv.fill(line([(28 + (yy % 4), yy), (31 + (yy % 3), yy + 3)]), BARK['s'])
    cv.dots([(34 + (yy % 3), yy + 2)], BARK['r'])
for cx, cy, rx, ry, rp in ((18, 12, 18, 8, PINK), (62, 8, 18, 8, PINK2), (104, 22, 14, 8, PINK), (8, 44, 10, 8, ROSE), (40, 30, 14, 8, PINK2), (80, 34, 14, 8, ROSE), (124, 50, 8, 5, PINK2), (0, 76, 6, 6, PINK), (100, 46, 8, 4, PINK)):
    blossom(clump(cx, cy, rx, ry, 9, 6, 10), rp, specks=36)
# red panda dozing on the big branch
rpx, rpy = 76, 38
o = cv.obj()
o.part(ell(rpx, rpy - 5, rpx + 10, rpy + 1), ramp('#c8562a', '#8a3a1e', '#e8844a'), d=1)
o.part(ell(rpx + 8, rpy - 8, rpx + 15, rpy - 2), ramp('#c8562a', '#8a3a1e', '#e8844a'), d=1)
o.part(rect(rpx - 6, rpy - 3, rpx, rpy - 1), ramp('#c8562a', '#8a3a1e', '#e8844a'), d=0)
o.draw()
cv.dots([(rpx - 5, rpy - 2), (rpx - 2, rpy - 2)], '#f2e4c0')   # tail rings
cv.dots([(rpx + 10, rpy - 5), (rpx + 13, rpy - 5), (rpx + 11, rpy - 3), (rpx + 12, rpy - 3)], '#ffffff')
cv.dots([(rpx + 11, rpy - 5), (rpx + 12, rpy - 4)], INK)
cv.dots([(rpx + 9, rpy - 9), (rpx + 14, rpy - 9)], '#8a3a1e')
# string of lanterns from the tree to the teahouse roof
pts = [(48, 70 + int(10 * math.sin(math.pi * t / 20))) for t in range(0)]
sag = [(x, int(64 + 0.006 * (x - 58) * (x - 58) * -1 + 0.6 * (x - 46))) for x in range(46, 80)]
for x, y in sag:
    cv.dots([(x, y)], INK)
for k, (x, y) in enumerate(sag[4::8]):
    o = cv.obj(outline=False)
    o.part(ell(x - 2, y + 1, x + 2, y + 6), (VERM, PINK2, GOLD, VERM)[k % 4], d=1)
    o.draw()
    cv.dots([(x, y + 7)], DARK)

# ---------------------------------------------------------------- blossom picnic on a blanket (between teahouse and steps)
bl = poly([(104, 138), (156, 135), (168, 149), (110, 152)])
cv.fill(bl, PINK2['b'])
for yy in range(135, 153, 4):
    cv.fill(bl & rect(0, yy, W, yy + 1), '#f6eedc')
for xx in range(104, 170, 6):
    cv.fill(bl & rect(xx, 0, xx + 2, H), PINK['b'])
cv.fill(bl & ~shift(bl, -1, -1), PINK['s'])
o = cv.obj()   # bento box stack
o.part(rect(122, 138, 132, 142), VERM, d=1)
o.part(rect(122, 143, 132, 146), ramp(DARK, '#1f1414', '#5a4a4a'), d=1)
o.draw()
cv.dots([(124, 140), (127, 140), (130, 140)], '#ffffff')
o = cv.obj()   # teapot
o.part(ell(140, 139, 147, 145), TEAL, d=1)
o.part(rect(147, 140, 149, 141), TEAL, d=0)
o.draw()
cv.dots([(143, 138)], DARK)
for cx_, cy_ in ((137, 146), (151, 144)):   # two tea cups
    cv.fill(rect(cx_, cy_, cx_ + 2, cy_ + 1), '#f6eedc')
    cv.dots([(cx_ + 1, cy_)], '#a4d870')
cv.fill(ell(116, 145, 121, 149), WOOD['b'])   # a little dish of mochi
cv.dots([(117, 146), (119, 146)], '#ffffff')
cv.dots([(118, 147)], PINK['b'])
cv.dots([(120, 147)], '#a4d870')
for px, py, hat, tun in ((110, 149, GOLD, VERM), (164, 151, TEAL, ramp('#f6eedc', '#d9ccb0', '#fffaf0'))):
    gnome(px, py, hat=hat, tunic=tun, s=0.75, lean=-1 if px < 130 else 1)
cv.dots([(117, 142), (118, 142), (117, 143)], '#ffffff')   # rice ball held up
cv.dots([(117, 144)], DARK)

# ---------------------------------------------------------------- koi pond with the red moon bridge (front left)
pond = ell(-30, 150, 160, 236) & ~rect(0, 0, W, 152)
cv.fill(dil4(dil4(pond)) & ~pond, STONE['b'])
ys, xs = np.nonzero(dil4(dil4(pond)) & ~pond)
for i in range(0, len(xs), 11):   # bank stones
    cv.dots([(int(xs[i]), int(ys[i])), (int(xs[i]) + 1, int(ys[i]))], STONE['s'])
cv.fill(pond, WATER['b'])
cv.fill(pond & ~shift(pond, 0, 3), WATER['s'])
for _ in range(60):
    wx, wy = r(0, 150), r(160, 199)
    if pond[wy, wx] and pond[wy, min(W - 1, wx + 6)]:
        cv.fill(line([(wx, wy), (wx + r(3, 6), wy)]), WATER['r'] if r(0, 2) else WATER['s'])
# bridge: an arc deck with posts and a rail; its reflection closes the circle
bx0, bx1, bcy, bh = 22, 112, 182, 25
bmid, bhw = (bx0 + bx1) / 2, (bx1 - bx0) / 2


def arc_y(x):
    t = (x - bmid) / bhw
    return int(round(bcy - bh * (1 - t * t)))


deck, rail, posts, refl = blank(), blank(), blank(), blank()
for x in range(bx0, bx1 + 1):
    y = arc_y(x)
    deck[y:y + 5, x] = True
    rail[y - 9:y - 7, x] = True
    if (x - bx0) % 9 == 0:
        posts[y - 10:y, x:x + 2] = True
    ry = bcy + 5 + (bcy - y) * 2 // 5   # a squashed mirror arc so it fits above the bottom edge
    if 0 <= ry < H:
        refl[ry:min(H, ry + 3), x] = True
    if (x - bx0) % 9 == 0:   # post reflections hang below the deck's reflection
        refl[min(H - 1, ry + 3):min(H, ry + 7), x:x + 2] = True
    if x % 3 and ry + 5 < H:   # the hand-rail's broken reflection
        refl[ry + 5, x] = True
cv.fill(refl & pond, '#c8483a')
cv.fill(refl & pond & ~shift(refl, 0, 1), '#e8806a')
cv.fill(refl & pond & ~shift(refl, 0, -1), '#9a3a2e')
for x in range(bx0 + 5, bx1, 11):   # a few ripples break the reflection into stitched dashes
    yy = bcy + 5 + (bcy - arc_y(x)) * 2 // 5 + 1
    cv.fill(rect(x, yy, x + 1, yy) & pond, WATER['r'])
o = cv.obj()
o.part(deck, VERM, d=2)
o.part(rail | posts, VERM, d=1)
o.draw()
cv.fill(deck & ~shift(deck, 0, -1), VERM['s'])
for x in range(bx0 + 4, bx1, 9):
    cv.dots([(x, arc_y(x) + 2)], '#f6eedc')
for x in range(bx0, bx1 + 1, 9):
    cv.dots([(x, arc_y(x) - 11), (x + 1, arc_y(x) - 11)], GOLD['b'])   # brass post caps
# koi (orange / white / one golden), lotus pads and a lotus flower
for kx, ky, body, spot, flip in ((6, 190, '#f08a24', '#ffffff', 1), (118, 174, '#ffffff', '#e0501f', -1), (8, 168, '#f08a24', '#ffffff', -1), (128, 189, '#e0501f', '#ffffff', 1), (60, 178, '#f0b92b', '#f8dc6a', 1)):
    o = cv.obj(outline=False)
    o.part(ell(kx, ky, kx + 9, ky + 4), ramp(body, '#c86a1a' if body != '#ffffff' else '#d8d2c2', '#ffffff'), d=1)
    tx = kx - 3 if flip > 0 else kx + 10
    o.part(poly([(kx + (1 if flip > 0 else 8), ky + 2), (tx, ky), (tx, ky + 4)]), ramp(body, body), d=0)
    o.draw()
    cv.dots([(kx + 4, ky + 1), (kx + 5, ky + 2), (kx + 4, ky + 2)], spot)
    cv.dots([(kx + (8 if flip > 0 else 1), ky + 1)], INK)
cv.dots([(62, 176), (70, 177), (56, 182)], '#f8dc6a')   # the golden koi's ripples
for lx, ly in ((40, 172), (22, 193), (96, 191), (140, 182), (82, 168)):
    pad = ell(lx, ly, lx + 10, ly + 4) & ~poly([(lx + 5, ly + 2), (lx + 11, ly), (lx + 11, ly + 3)])
    cv.fill(pad, BAMBOO['b'])
    cv.fill(pad & ~shift(pad, -1, -1), BAMBOO['s'])
    cv.dots([(lx + 3, ly + 1)], BAMBOO['r'])
for fx, fy in ((43, 168), (142, 178)):
    o = cv.obj()
    o.part(poly([(fx, fy + 4), (fx + 2, fy - 2), (fx + 4, fy + 2), (fx + 6, fy - 2), (fx + 8, fy + 4)]), ROSE, d=1)
    o.draw()
    cv.dots([(fx + 4, fy + 3)], GOLD['b'])
# gnome on the bridge top flying the dragon-fly kite
gbx = int(bmid) + 4
hx3, hy3 = gnome(gbx, arc_y(gbx) - 1, hat=VERM, tunic=TEAL, s=0.95, lean=-1)
# jade dragon-fly over the water
jx, jy = 118, 163
cv.fill(rect(jx, jy, jx + 7, jy), '#1f9a6a')
cv.dots([(jx + 8, jy), (jx + 8, jy - 1)], '#1f7a50')
cv.dots([(jx + 2, jy - 2), (jx + 3, jy - 2), (jx + 4, jy - 1), (jx + 2, jy + 2), (jx + 3, jy + 2), (jx + 4, jy + 1)], '#c8ecd8')

# stone lantern (toro) on the bank
slx, sly = 168, 176
shadow(slx - 6, sly - 1, slx + 8, sly + 2)
o = cv.obj()
o.part(rect(slx - 4, sly - 3, slx + 6, sly), STONE, d=1)
o.part(rect(slx - 1, sly - 12, slx + 3, sly - 3), STONE, d=1)
o.part(rect(slx - 3, sly - 18, slx + 5, sly - 12), STONE, d=1)
o.part(poly([(slx - 6, sly - 18), (slx + 1, sly - 23), (slx + 8, sly - 18)]), STONE, d=1)
o.draw()
cv.fill(rect(slx, sly - 16, slx + 2, sly - 14), '#f5cf6a')
cv.dots([(slx + 1, sly - 24)], STONE['s'])

# ---------------------------------------------------------------- Panda Bamboo Grove (front right)
for bx, top in ((238, 104), (300, 96), (250, 92), (292, 110), (262, 100), (282, 88), (272, 118), (244, 130)):
    o = cv.obj()
    o.part(rect(bx, top, bx + 2, H - 1), BAMBOO, d=1)
    o.draw()
    for ny in range(top + 6 + (bx % 5), H, 10):
        cv.fill(rect(bx - 1, ny, bx + 3, ny), BAMBOO['s'])
        cv.dots([(bx, ny - 1)], BAMBOO['r'])
        if r2(0, 1):
            d = 1 if r2(0, 1) else -1
            lf = poly([(bx + 1, ny), (bx + 1 + d * 9, ny - 3), (bx + 1 + d * 6, ny + 1)])
            o = cv.obj(outline=False)
            o.part(lf, TEA, d=1)
            o.draw()
for _ in range(14):   # leaf sprays at the stalk tops
    lx, ly = r(236, 299), r(86, 128)
    d = 1 if r(0, 1) else -1
    cv.fill(poly([(lx, ly), (lx + d * 8, ly - 2), (lx + d * 5, ly + 2)]), (TEA['b'], BAMBOO['b'], TEA['r'])[r(0, 2)])
# panda sitting in front, chewing a stalk
pnx, pny = 268, 194
shadow(pnx - 16, pny - 2, pnx + 18, pny + 3)
o = cv.obj()
o.part(ell(pnx - 14, pny - 26, pnx + 14, pny), WHITE, d=3)   # body
o.part(ell(pnx - 15, pny - 8, pnx - 5, pny + 1) | ell(pnx + 5, pny - 8, pnx + 15, pny + 1), ramp('#3a3440', '#1f1a24', '#5a5468'), d=1)   # feet
o.part(ell(pnx - 15, pny - 24, pnx - 3, pny - 13) | ell(pnx + 3, pny - 24, pnx + 15, pny - 13), ramp('#3a3440', '#1f1a24', '#5a5468'), d=1)   # arms
o.part(ell(pnx - 11, pny - 44, pnx + 11, pny - 22), WHITE, d=2)   # head
o.part(ell(pnx - 12, pny - 47, pnx - 5, pny - 40) | ell(pnx + 5, pny - 47, pnx + 12, pny - 40), ramp('#3a3440', '#1f1a24', '#5a5468'), d=1)   # ears
o.draw()
cv.fill(ell(pnx - 8, pny - 37, pnx - 2, pny - 31) | ell(pnx + 2, pny - 37, pnx + 8, pny - 31), '#3a3440')   # eye patches
cv.dots([(pnx - 5, pny - 35), (pnx + 5, pny - 35)], '#ffffff')
cv.dots([(pnx - 4, pny - 34), (pnx + 4, pny - 34)], INK)
cv.fill(rect(pnx - 1, pny - 30, pnx + 1, pny - 29), INK)
cv.dots([(pnx - 6, pny - 28), (pnx + 6, pny - 28)], PINK['r'])
cv.dots([(pnx - 6, pny - 6), (pnx - 4, pny - 6), (pnx + 6, pny - 6), (pnx + 8, pny - 6)], '#5a5468')   # toe pads
o = cv.obj()   # the bamboo stalk it chews
o.part(line([(pnx + 4, pny - 12), (pnx - 6, pny - 34)], 3), BAMBOO, d=1)
o.part(poly([(pnx - 6, pny - 34), (pnx - 14, pny - 40), (pnx - 9, pny - 34)]), TEA, d=1)
o.draw()
cv.fill(ell(pnx - 4, pny - 20, pnx + 6, pny - 14), '#3a3440')   # paws round the stalk
cv.dots([(pnx - 1, pny - 19), (pnx + 2, pny - 18)], '#5a5468')
# gnome climbing the steps with a lantern on a pole
gcx, gcy = 196, 158
hx4, hy4 = gnome(gcx, gcy, hat=GOLD, tunic=VERM, s=0.85, lean=1)
cv.fill(line([(hx4, hy4), (hx4 + 6, hy4 - 10)]), WOOD['s'])
o = cv.obj(outline=False)
o.part(ell(hx4 + 4, hy4 - 10, hx4 + 9, hy4 - 3), GOLD, d=1)
o.draw()
cv.fill(rect(hx4 + 5, hy4 - 10, hx4 + 8, hy4 - 10), DARK)
# bamboo shoots in a basket at the foot of the steps (for the panda)
bkx, bky = 214, 186
shadow(bkx - 2, bky + 8, bkx + 16, bky + 11)
o = cv.obj()
o.part(rrect(bkx, bky + 1, bkx + 13, bky + 9, 2), WOOD, d=2)
o.draw()
for xx in range(bkx + 2, bkx + 13, 3):
    cv.fill(rect(xx, bky + 2, xx, bky + 8), WOOD['s'])
for sx in (bkx + 3, bkx + 7, bkx + 10):
    cv.fill(poly([(sx - 2, bky + 1), (sx + 2, bky + 1), (sx, bky - 6)]), '#d9c06a')
    cv.dots([(sx, bky - 4)], BAMBOO['b'])

# ---------------------------------------------------------------- petals: on the ground and falling through the whole frame
keep = (rect(gtx - 8, gty - 30, gtx + 22, gty + 1) | rect(gbx - 8, arc_y(gbx) - 32, gbx + 10, arc_y(gbx)) | rect(pnx - 16, pny - 48, pnx + 16, pny)
        | rect(100, 118, 172, 154) | rect(ctx - 5, cty - 11, ctx + 14, cty + 3) | rect(gcx - 8, gcy - 30, gcx + 18, gcy + 1) | rect(rpx - 7, rpy - 10, rpx + 16, rpy + 2) | rect(tpx - 10, tpy - 20, tpx + 8, tpy + 1))
ground = ~pond & ~steps & ~hill
for _ in range(200):
    lx, ly = r(0, W - 3), r(108, H - 3)
    if not ground[ly, lx] or keep[ly, lx]:
        continue
    cv.dots([(lx, ly), (lx + 1, ly)], (PINK['b'], PINK2['r'], '#ffffff')[r(0, 2)])
for _ in range(110):
    lx, ly = r(0, W - 3), r(0, H - 3)
    if keep[ly, lx]:
        continue
    c = (PINK['b'], PINK2['b'], '#ffffff', ROSE['b'])[r(0, 3)]
    cv.dots([(lx, ly), (lx + 1, ly + 1)], c)
    cv.dots([(lx + 1, ly)], PINK['s'] if c != '#ffffff' else PINK['r'])
for _ in range(30):   # petals floating on the pond
    lx, ly = r(0, 150), r(158, 198)
    if pond[ly, lx] and not deck[ly, lx]:
        cv.dots([(lx, ly), (lx + 1, ly)], PINK2['b'])
for sx, sy in ((8, 140), (52, 144), (94, 148)):   # azalea bushes by the pond: leafy green domes studded with flowers
    m = clump(sx, sy, 5, 2, 5, 4, 6, r=r3) & ~pond
    o = cv.obj()
    o.part(m, DGRASS, d=2)
    o.draw()
    ys_, xs_ = np.nonzero(m & shift(m, 0, 2) & shift(m, 2, 0) & shift(m, -2, 0) & shift(m, 0, -1))
    for k in range(0, len(xs_), max(1, len(xs_) // 9)):
        x, y = int(xs_[k]), int(ys_[k])
        c = (ROSE['b'], '#f6b8cf', VERM['r'])[k % 3]
        cv.dots([(x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)], c)
        cv.dots([(x, y)], '#ffffff' if k % 2 else GOLD['b'])
    for k in range(3, len(xs_), 13):
        cv.dots([(int(xs_[k]), int(ys_[k]))], DGRASS['r'])
for sx, sy in ((172, 192), (180, 166), (226, 150), (226, 176)):   # stepping stones / pebbles
    o = cv.obj()
    o.part(ell(sx, sy, sx + 7, sy + 4), STONE, d=1)
    o.draw()

# clover and tiny wildflower tufts on the open lawns (bottom centre and right of the steps)
lawn = ~pond & ~steps & ~dil4(dil4(pond)) & ~keep & (yy_ > 152) & ~rect(236, 80, W, H) & ~rect(slx - 8, sly - 26, slx + 10, sly + 3)
for _ in range(70):
    lx, ly = r3(146, 240), r3(154, 196)
    if not lawn[ly, lx]:
        continue
    k = r3(0, 3)
    if k == 0:
        cv.dots([(lx, ly), (lx + 2, ly), (lx + 1, ly - 1), (lx + 1, ly + 1)], DGRASS['r'])
    elif k == 1:
        cv.dots([(lx, ly), (lx - 1, ly), (lx + 1, ly), (lx, ly - 1)], '#ffffff')
        cv.dots([(lx, ly)], GOLD['b'])
    elif k == 2:
        cv.dots([(lx, ly), (lx, ly - 1), (lx + 1, ly - 2), (lx - 1, ly - 2)], DGRASS['s'])
    else:
        cv.dots([(lx, ly), (lx + 1, ly)], GOLD['b'])
        cv.dots([(lx, ly + 1)], DGRASS['s'])

# ---------------------------------------------------------------- pass 2 details (own generator r4)
# an egret wading in a paddy left of the steps
ex_ = 207
ey_ = int(edges[4][ex_]) - 1
o = cv.obj()
o.part(ell(ex_ - 3, ey_ - 7, ex_ + 3, ey_ - 3), WHITE, d=1)
o.part(line([(ex_ + 2, ey_ - 6), (ex_ + 4, ey_ - 11)], 2), WHITE, d=0)
o.part(ell(ex_ + 3, ey_ - 13, ex_ + 6, ey_ - 10), WHITE, d=0)
o.draw()
cv.fill(line([(ex_ + 6, ey_ - 12), (ex_ + 9, ey_ - 11)]), GOLD['b'])
cv.dots([(ex_ + 4, ey_ - 12)], INK)
cv.fill(rect(ex_ - 1, ey_ - 2, ex_ - 1, ey_) | rect(ex_ + 1, ey_ - 2, ex_ + 1, ey_), '#3a3440')
cv.fill(rect(ex_ - 3, ey_ + 1, ex_ + 3, ey_ + 1) & ~steps, PADDY['r'])
# a white rabbit and toadstools on the left lawn, behind the cherry trunk
rbx, rby = 4, 128
o = cv.obj()
o.part(ell(rbx, rby - 6, rbx + 8, rby), WHITE, d=1)
o.part(ell(rbx + 6, rby - 9, rbx + 11, rby - 4), WHITE, d=1)
o.part(rect(rbx + 7, rby - 14, rbx + 8, rby - 9) | rect(rbx + 10, rby - 13, rbx + 11, rby - 9), WHITE, d=0)
o.draw()
cv.dots([(rbx + 7, rby - 12), (rbx + 10, rby - 11)], '#f0a0b8')
cv.dots([(rbx + 9, rby - 7)], INK)
cv.dots([(rbx + 11, rby - 6)], ROSE['b'])
cv.dots([(rbx - 1, rby - 4), (rbx, rby - 5)], '#ffffff')
for mx, my in ((56, 128), (60, 130)):
    o = cv.obj()
    o.part(rect(mx, my - 3, mx + 1, my), PAPER, d=0)
    o.part(ell(mx - 2, my - 6, mx + 3, my - 3), VERM, d=1)
    o.draw()
    cv.dots([(mx - 1, my - 5), (mx + 2, my - 5)], '#ffffff')
# the lawn right of the steps: an iris bed, a stone water basin with a bamboo spout, a snail, clover
o = cv.obj()   # tsukubai: low round basin on a stone
tbx, tby_ = 213, 150
shadow(tbx - 7, tby_ - 1, tbx + 9, tby_ + 2)
o.part(ell(tbx - 6, tby_ - 6, tbx + 6, tby_), STONE, d=2)
o.draw()
cv.fill(ell(tbx - 4, tby_ - 6, tbx + 4, tby_ - 4), WATER['b'])
cv.dots([(tbx - 2, tby_ - 5)], WATER['r'])
o = cv.obj()
o.part(rect(tbx + 7, tby_ - 12, tbx + 8, tby_ - 1), BAMBOO, d=0)
o.part(rect(tbx + 2, tby_ - 12, tbx + 8, tby_ - 11), BAMBOO, d=0)
o.draw()
cv.dots([(tbx + 2, tby_ - 9), (tbx + 2, tby_ - 7)], WATER['r'])
cv.dots([(tbx + 3, tby_ - 6)], '#ffffff')
for k, (ix, iy) in enumerate(((199, 197), (204, 195), (209, 198), (202, 190), (207, 191))):   # irises
    cv.fill(line([(ix, iy), (ix - 2, iy - 7)]) | line([(ix + 1, iy), (ix + 3, iy - 6)]), DGRASS['s'])
    cv.fill(rect(ix, iy - 7, ix, iy), BAMBOO['s'])
    c = (ramp('#8a6ac8', '#5a3e98', '#c0a8e8'), ramp('#6a7ad0', '#3e4a98', '#a8b8f0'))[k % 2]
    o = cv.obj()
    o.part(poly([(ix - 2, iy - 9), (ix, iy - 13), (ix + 2, iy - 9), (ix, iy - 7)]), c, d=1)
    o.draw()
    cv.dots([(ix, iy - 9)], GOLD['b'])
snx, sny = 206, 170   # snail
o = cv.obj()
o.part(rect(snx - 3, sny - 1, snx + 4, sny), ramp('#c8b890', '#9a8a68', '#e8dcb8'), d=0)
o.part(ell(snx - 2, sny - 6, snx + 3, sny - 1), ramp('#d9944a', '#9a5a2a', '#f0c07a'), d=1)
o.draw()
cv.dots([(snx, sny - 4), (snx + 1, sny - 3), (snx, sny - 3)], '#9a5a2a')
cv.dots([(snx + 5, sny - 3), (snx + 5, sny - 2)], '#9a8a68')
for _ in range(60):
    lx, ly = r4(198, 240), r4(140, 198)
    if not lawn[ly, lx] or steps[ly, lx]:
        continue
    k = r4(0, 3)
    if k == 0:
        cv.dots([(lx, ly), (lx + 2, ly), (lx + 1, ly - 1), (lx + 1, ly + 1)], DGRASS['r'])
    elif k == 1:
        cv.dots([(lx, ly), (lx - 1, ly), (lx + 1, ly), (lx, ly - 1)], (PINK2['b'], '#ffffff')[r4(0, 1)])
        cv.dots([(lx, ly)], GOLD['b'])
    else:
        cv.dots([(lx, ly), (lx, ly - 1), (lx + 1, ly - 2), (lx - 1, ly - 2)], DGRASS['s'])

# fold the rarest colours into their nearest neighbours to stay under the colour cap
cols, cnt = np.unique(cv.px.reshape(-1, 3), axis=0, return_counts=True)
cols, cnt = cols.astype(int), list(cnt)
alive = list(range(len(cols)))
while len(alive) > 96:
    i = min(alive, key=lambda j: cnt[j])
    alive.remove(i)
    j = min(alive, key=lambda k: int(((cols[k] - cols[i]) ** 2).sum()))
    cnt[j] += cnt[i]
    cv.remap({'#%02x%02x%02x' % tuple(cols[i]): '#%02x%02x%02x' % tuple(cols[j])})
    cols[i] = cols[j]

if __name__ == '__main__':
    out = sys.argv[1] if len(sys.argv) > 1 else None
    n = save_pic(cv, 'blossomreach', out)
    print('blossomreach:', n, 'colours')
