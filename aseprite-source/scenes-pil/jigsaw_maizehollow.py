"""Jigsaw picture: MAIZEHOLLOW (v2.0.87): game/assets/img/jigsaw/maizehollow.jpg (+ -thumb). Usage: python3 -B aseprite-source/scenes-pil/jigsaw_maizehollow.py [outdir]
Late-afternoon golden light over a highland valley: a turquoise-to-gold sky with a low sun, a butterfly kite and a flying macaw, the smoking cone of
Smokecap Caldera over terraced hills, the Stepped Seed Temple on the left (a gnome sweeps its steps, one bean on every step), the Plaza of the Bells
with a whitewashed bell tower and paper-flag strings, three market stalls of the Market of a Thousand Chilies (chili strings, clay pots, corn), the
Pinata fig tree with a donkey pinata, a quetzal and a toucan, milpa rows of corn, beans and squash in front (a gnome flies the kite from them), a
winding path, and the Cenote of Echoes at the front right with hanging vines, a diving gnome and a swimmer; prickly pear and barrel cacti round it.
"""
import sys

from jigsaw_common import *  # noqa: F401,F403

SKY = ('#8fcfcf', '#b4dcc6', '#eedca6', '#f4c682')
TERRA = ramp('#c8643a', '#9a4426', '#e8905a')
TURQ = ramp('#3fb0a8', '#24807e', '#8adcd0')
JADE = ramp('#3f9a6a', '#2a7050', '#7ac48a')
MAIZE = ramp('#e8b83a', '#b8862a', '#f8dc7a')
SAND = ramp('#dcb482', '#a8825a', '#f2d8a8')     # temple stone
LIME = ramp('#e8dcb8', '#b8a888', '#fff4dc')     # limestone, whitewash
WOOD = ramp('#b07a3a', '#7a4a1f', '#d9a35a')
CORN = ramp('#5a9a3a', '#3a6a2a', '#8cc45a')
CHILI = ramp('#d6322b', '#a8241f', '#f08a6a')
SKIN = ramp('#f2c8a0', '#d9a07a', '#fff0d8')
BEARD = ramp('#f1ece0', '#c9c5bc', '#ffffff')
PINK = ramp('#e46a9b', '#b04a74', '#f6b8cf')
WATER = ramp('#2fb8b8', '#1f8a94', '#8ae0d8')
SOIL = ramp('#b8683e', '#8a4a2a', '#d8905a')
SQUASH = ramp('#f08a24', '#b85a14', '#f5b04a')
DARK = '#2a1a10'
EARTH, EARTH_S, EARTH_R = '#d8a464', '#b8804a', '#ecc488'
cv = new_canvas(SKY[0])
r = rnd(1521)
r2 = rnd(88)
r3 = rnd(4417)   # pass-1 details (keeps r and r2 layouts unchanged)


def shadow(x0, y0, x1, y1):
    cv.fill(ell(x0, y0, x1, y1), EARTH_S)


def clump(cx, cy, rx, ry, n, s0=5, s1=9):
    m = blank()
    for _ in range(n):
        ex, ey, s = cx + r(-rx, rx), cy + r(-ry, ry), r(s0, s1)
        m |= ell(ex - s, ey - s * 3 // 4, ex + s, ey + s * 3 // 4)
    return m


def gnome(gx, gy, tunic, hat, arm='side', braids=False, small=False):
    """A gnome standing with feet at (gx, gy). arm: 'side', 'up' (reaching up-right) or 'out' (sweeping forward-left)."""
    if small:
        shadow(gx - 5, gy - 1, gx + 6, gy + 1)
        o = cv.obj()
        o.part(rect(gx - 4, gy - 2, gx - 1, gy) | rect(gx + 1, gy - 2, gx + 4, gy), ramp('#5c3420', '#3d2a1c'), d=0)
        o.part(rrect(gx - 4, gy - 10, gx + 4, gy - 2, 1), tunic, d=1, contour=True)
        if braids:
            o.part(rect(gx - 4, gy - 14, gx - 3, gy - 7) | rect(gx + 3, gy - 14, gx + 4, gy - 7), ramp('#3a2a28', DARK), d=0)
        else:
            o.part(poly([(gx - 4, gy - 12), (gx + 4, gy - 12), (gx, gy - 5)]), BEARD, d=1, contour=True)
        o.part(rect(gx - 3, gy - 15, gx + 3, gy - 11), SKIN, d=1)
        o.part(poly([(gx - 5, gy - 14), (gx + 5, gy - 14), (gx - 3, gy - 26)]), hat, d=2, contour=True)
        o.draw()
        cv.dots([(gx - 1, gy - 13), (gx + 1, gy - 13)], DARK)
        cv.dots([(gx, gy - 12)], '#e0907a')
        return
    shadow(gx - 9, gy - 1, gx + 10, gy + 2)
    o = cv.obj()
    o.part(rect(gx - 7, gy - 3, gx - 2, gy) | rect(gx + 1, gy - 3, gx + 6, gy), ramp('#5c3420', '#3d2a1c', '#7a4a1f'), d=1)
    o.part(rrect(gx - 7, gy - 16, gx + 7, gy - 3, 2), tunic, d=2, contour=True)
    o.part(rect(gx - 7, gy - 7, gx + 7, gy - 6), ramp('#7a4a1f', '#5c3420'), d=0)
    if braids:
        o.part(rect(gx - 7, gy - 24, gx - 5, gy - 10) | rect(gx + 5, gy - 24, gx + 7, gy - 10), ramp('#3a2a28', DARK), d=0)
    else:
        o.part(poly([(gx - 7, gy - 20), (gx + 7, gy - 20), (gx + 1, gy - 6)]), BEARD, d=1, contour=True)
    o.part(rect(gx - 5, gy - 25, gx + 5, gy - 19), SKIN, d=1)
    o.part(poly([(gx - 8, gy - 23), (gx + 8, gy - 23), (gx - 5, gy - 42)]), hat, d=2, contour=True)
    if arm == 'up':
        o.part(line([(gx + 5, gy - 14), (gx + 10, gy - 22), (gx + 11, gy - 28)], 3), tunic, d=1)
    elif arm == 'out':
        o.part(rect(gx - 11, gy - 15, gx - 5, gy - 12), tunic, d=1)
    else:
        o.part(rect(gx + 5, gy - 15, gx + 9, gy - 12), tunic, d=1)
    o.draw()
    cv.fill(rect(gx - 8, gy - 24, gx + 8, gy - 23), hat['s'])
    cv.dots([(gx - 2, gy - 22), (gx + 2, gy - 22)], DARK)
    cv.dots([(gx, gy - 21), (gx + 1, gy - 21), (gx, gy - 20), (gx + 1, gy - 20)], '#e0907a')
    cv.dots([(gx - 4, gy - 20), (gx + 4, gy - 20)], '#f0a0a0')
    cv.fill(rect(gx - 1, gy - 7, gx + 1, gy - 6), MAIZE['r'])
    if braids:
        cv.dots([(gx - 6, gy - 10), (gx + 6, gy - 10)], PINK['b'])
        cv.fill(rect(gx - 3, gy - 18, gx + 3, gy - 18), '#e0907a')
    if arm == 'up':
        cv.fill(rect(gx + 10, gy - 31, gx + 12, gy - 29), SKIN['b'])
    elif arm == 'out':
        cv.fill(rect(gx - 13, gy - 15, gx - 11, gy - 12), SKIN['b'])
    else:
        cv.fill(rect(gx + 8, gy - 15, gx + 10, gy - 12), SKIN['b'])


# ---------------------------------------------------------------- sky: hard bands, low sun upper left, clouds
cv.fill(rect(0, 16, W - 1, 99), SKY[1])
cv.fill(rect(0, 34, W - 1, 99), SKY[2])
cv.fill(rect(0, 52, W - 1, 99), SKY[3])
sun = ell(14, 10, 42, 38)
cv.fill(ell(10, 6, 46, 42) & ~sun, '#fbe8a8')   # halo ring
cv.fill(sun, '#fff4c8')
cv.fill(sun & ~shift(sun, -2, -2), '#fbe08a')
for k in range(12):   # short hard rays
    a = k * np.pi / 6
    x0, y0 = 28 + np.cos(a) * 22, 24 + np.sin(a) * 22
    cv.fill(line([(x0, y0), (28 + np.cos(a) * 27, 24 + np.sin(a) * 27)], 2), '#fbe8a8')
for cx, cy, w in ((76, 10, 40), (150, 30, 50), (196, 8, 34), (40, 50, 36), (120, 52, 30), (226, 26, 30), (12, 64, 22), (180, 48, 26)):
    m = ell(cx - w // 2, cy - 6, cx + w // 2, cy + 5) | ell(cx - w // 4, cy - 11, cx + w // 5, cy + 3) | ell(cx, cy - 8, cx + w // 2 - 5, cy + 4)
    m &= ~rect(0, cy + 3, W, H)
    cv.fill(m, '#fff3dc')
    cv.fill(m & ~shift(m, -2, -2) & rect(0, cy - 2, W, cy + 3), '#f5d6b0')
    cv.fill(m & rect(0, cy + 3, W, cy + 3), '#e8a888')   # warm underside
for bx, by in ((60, 34), (66, 30), (72, 34), (250, 6), (256, 9), (110, 70)):
    cv.dots([(bx, by), (bx + 1, by - 1), (bx + 2, by), (bx + 3, by - 1), (bx + 4, by)], '#5a3a4a')
# scarlet macaw flying left, long tail streaming behind
mx, my = 122, 42
o = cv.obj()
o.part(poly([(mx + 10, my + 3), (mx + 26, my + 10), (mx + 25, my + 12), (mx + 9, my + 6)]), CHILI, d=1)   # tail
o.part(ell(mx, my, mx + 13, my + 6), CHILI, d=1)
o.part(ell(mx - 4, my - 1, mx + 3, my + 5), CHILI, d=1)   # head
o.part(poly([(mx + 3, my + 2), (mx + 6, my - 10), (mx + 14, my - 13), (mx + 11, my + 2)]), CHILI, d=1)   # raised wing
o.draw()
cv.fill(poly([(mx + 6, my - 9), (mx + 14, my - 13), (mx + 13, my - 8), (mx + 8, my - 6)]), TURQ['s'])   # blue wingtips
cv.fill(line([(mx + 5, my - 3), (mx + 11, my - 4)]), MAIZE['b'])   # gold band
cv.fill(rect(mx + 20, my + 9, mx + 25, my + 10), TURQ['b'])
cv.dots([(mx - 2, my + 1), (mx - 1, my + 1)], '#ffffff')
cv.dots([(mx - 2, my + 1)], DARK)
cv.dots([(mx - 5, my + 2), (mx - 6, my + 3), (mx - 5, my + 4)], '#fff4dc')   # pale beak
# a small papel-striped hot-air balloon and a pair of swallows in the high calm sky
bx0, by0 = 156, 4
bal = ell(bx0, by0, bx0 + 13, by0 + 15) | poly([(bx0 + 2, by0 + 11), (bx0 + 11, by0 + 11), (bx0 + 9, by0 + 17), (bx0 + 4, by0 + 17)])
o = cv.obj()
o.part(bal, SQUASH, d=1)
o.draw()
for k, c in enumerate((PINK['b'], TURQ['b'], MAIZE['b'])):   # gores
    cv.fill(bal & rect(bx0 + 2 + k * 4, 0, bx0 + 3 + k * 4, H) & ~rect(0, by0 + 15, W, H), c)
cv.fill(bal & rect(0, by0 + 9, W, by0 + 9), '#fff4dc')
cv.fill(line([(bx0 + 4, by0 + 18), (bx0 + 5, by0 + 21)]) | line([(bx0 + 9, by0 + 18), (bx0 + 8, by0 + 21)]), '#4a2c1a')
o = cv.obj()
o.part(rect(bx0 + 4, by0 + 21, bx0 + 9, by0 + 24), WOOD, d=1)
o.draw()
for sx, sy in ((132, 10), (141, 16)):   # swallows: forked tails
    cv.dots([(sx - 3, sy - 2), (sx - 2, sy - 1), (sx - 1, sy), (sx, sy), (sx + 1, sy), (sx + 2, sy - 1), (sx + 3, sy - 2),
             (sx, sy + 1), (sx - 1, sy + 2), (sx + 1, sy + 2)], '#3a2a48')
    cv.dots([(sx, sy)], CHILI['b'])
# butterfly kite (string drawn later, from the gnome in the corn)
kx, ky = 96, 26
o = cv.obj()
o.part(ell(kx - 15, ky - 12, kx - 1, ky + 2) | ell(kx + 1, ky - 12, kx + 15, ky + 2), TURQ, d=2)
o.part(ell(kx - 11, ky, kx - 1, ky + 11) | ell(kx + 1, ky, kx + 11, ky + 11), TERRA, d=2)
o.part(rect(kx - 1, ky - 13, kx + 1, ky + 12), ramp('#4a2c1a', DARK), d=0)
o.draw()
for dx, dy in ((-9, -6), (9, -6), (-6, 6), (6, 6)):
    cv.fill(ell(kx + dx - 2, ky + dy - 2, kx + dx + 2, ky + dy + 2), MAIZE['b'])
cv.dots([(kx - 12, ky - 9), (kx + 4, ky - 9)], TURQ['r'])
cv.fill(line([(kx - 1, ky - 14), (kx - 5, ky - 19)]) | line([(kx + 1, ky - 14), (kx + 5, ky - 19)]), DARK)   # antennae
t = 0
for k in range(6):   # zigzag tail with bows
    ty = ky + 13 + k * 4
    cv.fill(line([(kx + (2 if k % 2 else -2), ty), (kx + (-2 if k % 2 else 2), ty + 4)]), '#4a2c1a')
    cv.fill(rect(kx - 2, ty + 2, kx + 1, ty + 3), (PINK['b'], MAIZE['b'], TURQ['b'])[k % 3])

# ---------------------------------------------------------------- far range and Smokecap Caldera
m = poly([(0, 70), (40, 56), (80, 66), (130, 52), (160, 62), (300, 58), (300, 96), (0, 96)])
cv.fill(m, '#c49ab0')
cv.fill(m & ~shift(m, 3, 3), '#d8b4c0')
VX = 12   # the cone sits right of the bell tower so its crater shows
vol = poly([(120 + VX, 92), (150 + VX, 64), (164 + VX, 50), (172 + VX, 40), (176 + VX, 37), (179 + VX, 40), (183 + VX, 35), (187 + VX, 39),
            (191 + VX, 34), (195 + VX, 38), (200 + VX, 43), (214 + VX, 58), (240 + VX, 80), (256 + VX, 92)])
cv.fill(vol, '#9a7a96')
cv.fill(vol & poly([(120 + VX, 92), (176 + VX, 36), (186 + VX, 36), (172 + VX, 92)]), '#b892a8')   # lit left flank
for gx0, gl in ((150, 0), (166, 6), (184, 2), (200, 8), (218, 4)):   # gullies of uneven length
    cv.fill(line([(gx0 + VX + 10, 50 + gl), (gx0 + VX + 6, 70 + gl), (gx0 + VX + 3, 90)]) & vol, '#86688a')
crater = poly([(178 + VX, 40), (183 + VX, 36), (187 + VX, 40), (191 + VX, 35), (195 + VX, 39), (190 + VX, 44), (182 + VX, 44)]) & vol
cv.fill(crater, '#6a4a5a')   # dark notched crater mouth
cv.fill(crater & ~shift(crater, 0, -1), '#f08a24')   # molten glow at its floor
cv.fill(crater & ~shift(crater, 0, -2) & shift(crater, 0, -1), '#f5b04a')
cv.dots([(185 + VX, 45), (186 + VX, 46), (185 + VX, 48)], '#f08a24')   # a few glowing drips
for k, (sx, sy, rr) in enumerate(((187 + VX, 31, 4), (183 + VX, 25, 5), (189 + VX, 20, 6), (181 + VX, 14, 7), (191 + VX, 9, 6), (178 + VX, 5, 7), (195 + VX, 3, 5))):   # puffy plume from the crater
    pm = ell(sx - rr, sy - rr + 1, sx + rr, sy + rr - 1)
    cv.fill(pm, '#efe2d4' if k % 3 else '#e2d2c8')
    cv.fill(pm & ~shift(pm, -1, -1), '#c4b0b0')
    cv.fill(pm & ~shift(pm, 1, 1), '#fff3dc')
x = 0
while x < W:   # dusty dots on the far range (shrubs)
    x += r2(3, 8)
    col = m[:, min(x, W - 1)]
    if col.any():
        y = int(np.argmax(col)) + r2(4, 14)
        cv.dots([(x, y), (x + 1, y)], '#a8869e')
# terraced near hills: stripes of crops and dark terrace walls
hills = poly([(0, 84), (40, 74), (90, 82), (140, 72), (200, 80), (250, 70), (300, 78), (300, 100), (0, 100)])
cv.fill(hills, '#7fb07a')
_top = np.argmax(hills, axis=0)   # terrace walls follow the hill's own contour (not ruler-straight stripes)
_dy = np.arange(H)[:, None] - _top[None, :] - 3
_tw = (_dy >= 0) & (_dy % 5 == 0) | (_dy >= 0) & (_dy % 5 == 3) & (np.arange(W)[None, :] // 23 % 3 == 0)
cv.fill(hills & _tw, '#5f9468')
cv.fill(hills & (_dy >= 0) & (_dy % 5 == 2) & (rect(0, 0, 90, H) | rect(160, 0, 240, H)), '#a8c47a')
for hx0, hy0 in ((24, 80), (110, 80), (214, 78), (268, 76), (60, 84)):   # tiny far houses
    cv.fill(rect(hx0, hy0, hx0 + 5, hy0 + 3), '#fff4dc')
    cv.fill(rect(hx0 - 1, hy0 - 2, hx0 + 6, hy0 - 1), TERRA['b'])
    cv.dots([(hx0 + 2, hy0 + 2), (hx0 + 2, hy0 + 3)], '#4a2c1a')

# ---------------------------------------------------------------- ground and plaza
cv.fill(rect(0, 98, W - 1, H - 1), EARTH)
plaza = poly([(108, 112), (252, 110), (262, 150), (200, 152), (186, 148), (148, 148), (112, 140)])
cv.fill(plaza, '#ecd0a0')
for yy in range(114, 152, 5):   # paving courses with staggered joints
    cv.fill(plaza & rect(0, yy, W, yy), '#d4b07a')
    for xx in range(110 + (yy // 5 % 2) * 4, 262, 8):
        cv.dots([(xx, yy + 1), (xx, yy + 2), (xx, yy + 3)], '#d4b07a')
for yy in range(114, 152, 5):   # odd flagstones: warm terracotta tiles, pale worn ones, inset turquoise diamonds, cracks
    for xx in range(110 + (yy // 5 % 2) * 4, 262, 8):
        k = r3(0, 9)
        cell = rect(xx + 1, yy + 1, xx + 7, yy + 4) & plaza
        if k < 2:
            cv.fill(cell, '#e0a878')
        elif k < 4:
            cv.fill(cell, '#f6e2b8')
        elif k == 4:
            cv.fill(cell & poly([(xx + 4, yy + 1), (xx + 7, yy + 2.5), (xx + 4, yy + 4), (xx + 1, yy + 2.5)]), TURQ['b'])
        elif k == 5:
            cv.fill(line([(xx + 2, yy + 1), (xx + 4, yy + 3), (xx + 6, yy + 4)]) & plaza, '#d4b07a')
for y in range(100, H, 2):
    for _ in range(3):
        gx = r(0, W - 2)
        cv.dots([(gx, y), (gx + 1, y)], EARTH_R if r(0, 1) else EARTH_S)

# ---------------------------------------------------------------- bell tower of the Plaza of the Bells (behind the stalls)
tx0, tx1 = 156, 176
o = cv.obj()
o.part(rect(tx0, 60, tx1, 116), LIME, d=2)
o.part(rect(tx0 - 2, 56, tx1 + 2, 60), LIME, d=1)
o.part(ell(tx0 + 2, 44, tx1 - 2, 62) & rect(0, 0, W, 58), TURQ, d=2)
o.draw()
cv.fill(rect(tx0 + 9, 38, tx0 + 11, 45), '#4a2c1a')   # finial cross-post
cv.fill(rect(tx0 + 8, 40, tx0 + 12, 40), '#4a2c1a')
arch = rect(tx0 + 5, 68, tx1 - 5, 84) | ell(tx0 + 5, 64, tx1 - 5, 72)
cv.fill(arch, '#5a3a3a')
bell = ell(tx0 + 7, 70, tx1 - 7, 82) & ~rect(0, 80, W, H) | rect(tx0 + 6, 79, tx1 - 6, 80)
cv.fill(bell, MAIZE['b'])
cv.fill(bell & ~shift(bell, -1, -1), MAIZE['s'])
cv.dots([(tx0 + 8, 73), (tx0 + 8, 74)], MAIZE['r'])
cv.fill(rect(tx0 + 2, 88, tx1 - 2, 89), TURQ['b'])   # painted band
for xx in range(tx0 + 2, tx1 - 2, 4):
    cv.dots([(xx + 1, 90), (xx + 2, 91)], TERRA['b'])
cv.fill(rect(tx0 + 7, 94, tx1 - 7, 104), '#7a4a2a')   # small window
cv.fill(rect(tx0 + 9, 96, tx1 - 9, 102), '#f5cf6a')

# ---------------------------------------------------------------- the Stepped Seed Temple (left)
o = cv.obj()
tiers = []
for k in range(5):
    x0, x1, y1 = 4 + k * 10, 118 - k * 10, 126 - k * 14
    tiers.append((x0, x1, y1 - 13, y1))
    o.part(rect(x0, y1 - 13, x1, y1), SAND, d=2)
stair = poly([(50, 126), (72, 126), (68, 56), (54, 56)])
o.part(stair, ramp('#c8a070', '#a8825a', '#e8c898'), d=1, contour=True)
o.part(rect(48, 38, 74, 56), SAND, d=2)   # shrine
o.part(rect(46, 32, 76, 37), TERRA, d=1)   # roof slab
o.part(rect(52, 24, 70, 31), SAND, d=1)   # roof comb
o.draw()
for (x0, x1, y0, y1) in tiers:   # stone courses, staggered joints, lit ledge
    for yy in range(y0 + 4, y1, 4):
        cv.fill(rect(x0 + 1, yy, x1 - 1, yy) & ~stair, SAND['s'])
        for xx in range(x0 + 3 + (yy // 4 % 2) * 4, x1 - 1, 8):
            cv.dots([(xx, yy + 1), (xx, yy + 2)] if not stair[yy + 1, xx] else [], SAND['s'])
    cv.fill(rect(x0, y0, x1, y0) & ~stair, SAND['r'])
for (x0, x1, y0, y1) in tiers:   # weathered stones: some blocks paler or darker so the courses are not uniform
    for yy in range(y0 + 4, y1 - 2, 4):
        for xx in range(x0 + 3 + (yy // 4 % 2) * 4, x1 - 8, 8):
            k = r3(0, 6)
            if k < 2:
                cv.fill(rect(xx + 1, yy + 1, xx + 7, yy + 3) & ~stair, ('#c49a6a', SAND['r'])[k])
            elif k == 2 and xx > 60:
                cv.dots([(xx + 2, yy + 2), (xx + 3, yy + 3), (xx + 4, yy + 3)], SAND['s'])   # crack
for yy in range(58, 126, 3):   # stair treads
    cv.fill(stair & rect(0, yy, W, yy), '#a8825a')
    cv.fill(stair & rect(0, yy + 1, W, yy + 1), '#e8c898')
for k, yy in enumerate(range(61, 124, 9)):   # one bean on every step (for the mice)
    cv.dots([(56 + (k * 5) % 11, yy), (57 + (k * 5) % 11, yy)], '#5a3a3a')
for (x0, x1, y0, y1), panels in zip(tiers, (4, 3, 2, 2, 1)):   # carved turquoise glyph panels on the tier faces
    for side in (0, 1):
        for p in range(panels):
            px = x0 + 4 + p * 10 if side == 0 else x1 - 11 - p * 10
            if stair[y0 + 4, px] or stair[y0 + 4, px + 7] or px + 7 >= 46 and px <= 76:
                continue
            pc = TERRA if side == 1 and (p + y0) % 2 else TURQ   # right face mixes in terracotta maize glyphs
            cv.fill(rect(px, y0 + 3, px + 6, y0 + 9), pc['s'])
            cv.fill(rect(px + 1, y0 + 4, px + 5, y0 + 8), pc['b'])
            if pc is TURQ:
                cv.fill(rect(px + 2, y0 + 5, px + 3, y0 + 6) | rect(px + 3, y0 + 6, px + 4, y0 + 7), TURQ['s'])   # spiral
            else:
                cv.fill(rect(px + 3, y0 + 4, px + 3, y0 + 7), MAIZE['b'])   # maize ear glyph
                cv.dots([(px + 2, y0 + 6), (px + 4, y0 + 6), (px + 2, y0 + 7), (px + 4, y0 + 7)], CORN['r'])
cv.fill(rect(55, 42, 67, 56), '#3a2a28')   # shrine doorway
cv.fill(rect(57, 44, 65, 56) & ~rect(58, 45, 64, 56), TURQ['b'])
cv.fill(ell(59, 49, 63, 53), MAIZE['b'])   # golden ear in the shrine
for xx in range(53, 70, 4):   # roof comb openings
    cv.fill(rect(xx, 26, xx + 1, 29), SAND['s'])
for (x0, x1, y0, y1) in tiers[1:]:   # amaranth and corn on the terrace ledges
    for xx in list(range(x0 - 8, x0 - 1, 3)) + list(range(x1 + 2, x1 + 9, 3)):
        if xx < 2:
            continue
        if (xx // 3) % 2:
            cv.fill(rect(xx, y1 - 2, xx + 1, y1 + 1), '#c8304a')   # red amaranth plume
            cv.dots([(xx, y1 - 3)], '#e8607a')
        else:
            cv.fill(rect(xx, y1 - 4, xx, y1 + 1), CORN['b'])
            cv.dots([(xx + 1, y1 - 3), (xx - 1, y1 - 1)], CORN['r'])
for vx, vy, ln in ((6, 113, 10), (108, 102, 8), (24, 87, 8), (100, 74, 9)):   # creepers down the stone
    cv.fill(line([(vx, vy), (vx + 1, vy + ln)]), CORN['s'])
    for k in range(0, ln, 3):
        cv.dots([(vx + 2 - (k % 2) * 3, vy + k)], CORN['r'])
for (x0, x1, y0, y1), mx0 in zip(tiers[:4], (84, 80, 70, 66)):   # moss creeping over the right-hand ledges only
    for k in range(3):
        mx_ = mx0 + r3(0, max(1, x1 - mx0 - 6))
        mw = r3(4, 9)
        mm = rect(mx_, y0, mx_ + mw, y0 + 1) | rect(mx_ + 1, y0 + 2, mx_ + 1, y0 + 2 + r3(1, 4)) | rect(mx_ + mw - 2, y0 + 2, mx_ + mw - 2, y0 + 1 + r3(1, 3))
        cv.fill(mm & ~stair, CORN['s'])
        cv.fill(mm & rect(0, y0, W, y0) & ~stair, CORN['r'])
# a sapling growing out of the top-left terrace
o = cv.obj()
o.part(rect(40, 61, 41, 70), WOOD, d=0)
o.part(ell(33, 55, 42, 63) | ell(37, 52, 46, 61), CORN, d=1)
o.draw()
cv.dots([(36, 57), (40, 54), (43, 57)], CHILI['b'])   # red berries
# iguana basking on a ledge
ix, iy = 88, 98
o = cv.obj()
o.part(ell(ix, iy - 3, ix + 10, iy + 1) | rect(ix + 8, iy - 4, ix + 13, iy - 1), JADE, d=1)
o.draw()
cv.fill(line([(ix, iy - 1), (ix - 8, iy + 1)]), JADE['s'])
cv.dots([(ix + 11, iy - 3)], DARK)
cv.dots([(ix + 2, iy - 4), (ix + 4, iy - 4), (ix + 6, iy - 4)], MAIZE['b'])
# gnome sweeping the temple steps (on the second ledge)
gnome(32, 100, JADE, TERRA, small=True)
cv.fill(line([(27, 92), (22, 100)]), WOOD['s'])   # broom
cv.fill(poly([(19, 99), (24, 99), (23, 101), (18, 101)]), MAIZE['b'])
cv.dots([(17, 97), (15, 98), (18, 96)], SAND['r'])   # dust

# ---------------------------------------------------------------- papel picado strings (no text: plain cut-paper flags)
def flags(p0, p1, sag, start):
    (x0, y0), (x1, y1) = p0, p1
    pts = []
    for i in range(0, 41):
        t = i / 40
        pts.append((x0 + (x1 - x0) * t, y0 + (y1 - y0) * t + sag * 4 * t * (1 - t)))
    cv.fill(line(pts), '#4a2c1a')
    cols = (PINK['b'], TURQ['b'], MAIZE['b'], JADE['r'], '#fff4dc', SQUASH['b'])
    for i in range(2, 39, 3):
        fx, fy = int(pts[i][0]), int(pts[i][1]) + 1
        c = cols[(i // 3 + start) % 6]
        cv.fill(rect(fx - 2, fy, fx + 2, fy + 4), c)
        cv.dots([(fx - 2, fy + 4), (fx + 2, fy + 4)], SKY[3] if fy < 98 else EARTH)   # notched hem
        cv.dots([(fx, fy + 2)], SKY[3] if fy < 98 else EARTH)


flags((76, 40), (156, 64), 14, 0)
flags((176, 62), (240, 70), 10, 3)

# ---------------------------------------------------------------- market stalls (Market of a Thousand Chilies)
def stall(x0, x1, ay, cy, c1, c2):
    o = cv.obj()
    o.part(rect(x0 + 1, ay + 6, x1 - 1, cy), ramp('#7a4a2a', '#5a3420'), d=0)   # shady back cloth
    o.part(rect(x0, ay + 6, x0 + 2, cy + 12) | rect(x1 - 2, ay + 6, x1, cy + 12), WOOD, d=1)
    o.draw()
    aw = rect(x0 - 3, ay, x1 + 3, ay + 6)
    for xx in range(x0 - 3, x1 + 3, 6):
        aw |= ell(xx, ay + 4, xx + 5, ay + 9)
    o = cv.obj()
    o.part(aw, c1, d=2)
    o.draw()
    for xx in range(x0 - 3, x1 + 4, 12):   # stripes
        cv.fill(aw & rect(xx + 6, 0, xx + 11, H), c2['b'])
    cv.fill(aw & ~shift(aw, 0, -1), DARK)
    cv.fill(aw & rect(0, ay, W, ay), '#fff4dc')
    o = cv.obj()
    o.part(rect(x0 - 1, cy, x1 + 1, cy + 11), WOOD, d=2)
    o.draw()
    for xx in range(x0 + 1, x1, 6):   # painted zigzag on the counter front
        cv.fill(line([(xx, cy + 7), (xx + 3, cy + 4), (xx + 6, cy + 7)]), c1['b'])
    cv.fill(rect(x0, cy + 1, x1, cy + 1), WOOD['r'])


# stall 1: chilies. keeper behind the counter first
gnome(136, 120, TURQ, CHILI, small=True)
stall(120, 154, 92, 116, TERRA, ramp('#fff4dc', '#e8dcb8'))
for bx in (122, 132, 143):   # baskets of chilies
    o = cv.obj()
    o.part(rrect(bx, 112, bx + 9, 117, 1), WOOD, d=1)
    o.draw()
    for k in range(6):
        c = (CHILI['b'], CORN['b'], SQUASH['b'])[(bx // 10 + k // 3) % 3]
        cv.dots([(bx + 1 + k * 3 // 2, 111 - (k % 2)), (bx + 2 + k * 3 // 2, 111 - (k % 2))], c)
for rx in (124, 137, 150):   # ristras: hot-pepper strings hanging from the awning
    cv.fill(rect(rx, 101, rx, 104), '#4a2c1a')
    for k in range(5):
        cv.fill(rect(rx - 1 + (k % 2), 105 + k * 2, rx + (k % 2), 106 + k * 2), CHILI['b'] if k % 3 else CHILI['s'])
        cv.dots([(rx - 1 + (k % 2), 105 + k * 2)], CHILI['r'])
# stall 2: cocoa house and clay pots
gnome(194, 120, MAIZE, JADE, braids=True, small=True)
stall(180, 208, 94, 116, TURQ, ramp('#fff4dc', '#e8dcb8'))
for px, s in ((183, 3), (190, 4), (198, 3), (204, 2)):   # mugs and pots on the counter
    o = cv.obj()
    o.part(ell(px - s, 116 - s * 2, px + s, 116), TERRA, d=1)
    o.draw()
    cv.fill(rect(px - s + 1, 116 - s, px + s - 1, 116 - s), TURQ['b'])
for k in range(4):   # cocoa steam
    cv.dots([(190 + (k % 2), 106 - k * 2)], '#fff4dc')
# stall 3: corn, squash, beans
gnome(226, 122, PINK, TURQ, small=True)
stall(212, 242, 96, 118, JADE, ramp('#e8b83a', '#b8862a'))
for k, ex in enumerate(range(214, 240, 4)):   # corn ears, husks open
    cv.fill(rect(ex, 113 + k % 2, ex + 2, 117), MAIZE['b'])
    cv.dots([(ex, 113 + k % 2)], MAIZE['r'])
    cv.dots([(ex + 3, 116), (ex + 3, 117)], CORN['b'])
cv.fill(ell(228, 110, 236, 117), SQUASH['b'])
cv.fill(ell(229, 111, 232, 113), SQUASH['r'])

# ---------------------------------------------------------------- the Pinata fig tree (right)
shadow(236, 142, 300, 152)
o = cv.obj()
trunk = poly([(244, 148), (256, 136), (260, 70), (282, 70), (286, 136), (300, 146), (300, 150), (242, 150)])
o.part(trunk, ramp('#9a7a5a', '#6a5038', '#c4a47a'), d=3)
o.part(line([(266, 84), (212, 60)], 4) | line([(272, 78), (256, 30)], 4) | line([(280, 82), (300, 50)], 5) | line([(262, 100), (240, 88)], 3), ramp('#9a7a5a', '#6a5038', '#c4a47a'), d=2)
o.draw()
for yy in range(80, 140, 7):   # fig bark: hanging aerial roots
    cv.fill(line([(262 + yy % 5, yy), (263 + yy % 5, yy + 6)]), '#6a5038')
    cv.fill(line([(276 + yy % 4, yy + 3), (277 + yy % 4, yy + 8)]), '#6a5038')
for cx, cy, rx, ry in ((282, 12, 18, 10), (246, 18, 16, 10), (234, 46, 12, 8), (266, 44, 18, 12), (294, 40, 8, 12), (238, 66, 10, 5), (290, 72, 10, 6)):
    o = cv.obj()
    m = clump(cx, cy, rx, ry, 9, 6, 10)
    o.part(m, JADE if (cx // 10) % 2 else ramp('#4fa870', '#2a7050', '#8ad09a'), d=3)
    o.draw()
    ys, xs = np.nonzero(m & shift(m, 2, 2) & shift(m, -2, -2))
    for k in range(24):
        i = r(0, len(xs) - 1)
        x, y = int(xs[i]), int(ys[i])
        if k % 4 == 0:
            cv.fill(rect(x, y, x + 1, y + 1), '#9a3a5a')   # figs
        else:
            cv.dots([(x, y), (x + 1, y), (x + 1, y - 1)], JADE['r'])
# donkey pinata on a rope from the long branch
cv.fill(rect(222, 64, 222, 74), '#4a2c1a')
px0, py0 = 214, 76
body = rect(px0, py0, px0 + 16, py0 + 8)
o = cv.obj()
o.part(body, PINK, d=1)
o.part(rect(px0 - 6, py0 - 6, px0 + 1, py0 + 3), PINK, d=1)   # head
o.part(rect(px0 - 5, py0 - 10, px0 - 4, py0 - 6) | rect(px0 - 2, py0 - 10, px0 - 1, py0 - 6), PINK, d=0)   # ears
o.part(rect(px0 + 1, py0 + 9, px0 + 3, py0 + 13) | rect(px0 + 12, py0 + 9, px0 + 14, py0 + 13), TURQ, d=0)   # legs
o.draw()
for k, c in enumerate((MAIZE['b'], TURQ['b'], SQUASH['b'], '#fff4dc')):   # fringe stripes
    cv.fill(rect(px0 + 1, py0 + 1 + k * 2, px0 + 15, py0 + 1 + k * 2), c)
cv.dots([(px0 - 4, py0 - 3)], DARK)
cv.fill(rect(px0 + 17, py0 + 1, px0 + 19, py0 + 5), MAIZE['b'])   # tail tassel
for _ in range(26):   # fig bark: fissures, lit ridges and moss so the trunk is not a plain block
    bx_, by_ = r3(256, 296), r3(82, 146)
    k = r3(0, 3)
    if k < 2:
        ln = r3(3, 8)
        cv.fill(line([(bx_, by_), (bx_ + r3(-1, 1), by_ + ln)]) & trunk, '#6a5038')
        cv.fill(line([(bx_ + 1, by_), (bx_ + 1, by_ + ln - 1)]) & trunk, '#c4a47a')
    elif k == 2:
        cv.fill(rect(bx_, by_, bx_ + r3(2, 4), by_ + 1) & trunk, CORN['s'])
    else:
        cv.dots([(bx_, by_), (bx_ + 1, by_ + 1)], '#6a5038')
cv.fill(ell(263, 82, 275, 98), '#6a5038')   # knot hole with a little owl peeping out
cv.fill(ell(264, 83, 274, 97), '#2a1a10')
o = cv.obj()
o.part(ell(265, 87, 273, 97), ramp('#c49a6a', '#9a7048', '#e8c898'), d=1)
o.draw()
cv.fill(rect(266, 89, 268, 91) | rect(270, 89, 272, 91), '#fff4dc')
cv.dots([(267, 90), (271, 90)], DARK)
cv.dots([(269, 92)], SQUASH['b'])
cv.dots([(266, 87), (272, 87)], '#9a7048')   # ear tufts
cv.fill(rect(262, 98, 276, 99), '#c4a47a')   # lit sill of the hole
cv.fill(rect(250, 92, 250, 100), '#4a2c1a')   # tin lantern hanging from the low branch
o = cv.obj()
o.part(rect(247, 101, 253, 108), MAIZE, d=1)
o.part(rect(246, 100, 254, 101) | rect(248, 109, 252, 110), ramp('#7a6a6a', '#4a3a3a'), d=0)
o.draw()
cv.fill(rect(249, 103, 251, 106), '#fff4c8')
o = cv.obj()   # leaves at the tip of the long branch
o.part(ell(205, 54, 216, 62) | ell(210, 50, 220, 58), JADE, d=1)
o.draw()
cv.dots([(209, 56), (214, 53)], '#9a3a5a')
# quetzal on the long branch, tail hanging; toucan on the right branch
qx, qy = 240, 64
o = cv.obj()
o.part(ell(qx, qy - 6, qx + 6, qy + 2), ramp('#3fc06a', '#2a8a4a', '#8ae09a'), d=1)
o.part(rect(qx + 2, qy + 1, qx + 4, qy + 14), ramp('#3fc06a', '#2a8a4a'), d=0)
o.draw()
cv.fill(rect(qx + 1, qy - 1, qx + 4, qy + 1), CHILI['b'])   # red breast
cv.dots([(qx + 1, qy - 4)], DARK)
cv.dots([(qx - 1, qy - 3)], MAIZE['b'])
tx, ty = 288, 50
o = cv.obj()
o.part(ell(tx, ty - 7, tx + 6, ty + 3), ramp('#3a2a28', DARK, '#5a4a48'), d=1)
o.part(ell(tx - 8, ty - 6, tx + 1, ty - 2), SQUASH, d=1)
o.draw()
cv.fill(rect(tx + 1, ty - 4, tx + 3, ty - 1), '#fff4dc')
cv.dots([(tx + 2, ty - 5)], DARK)
cv.dots([(tx - 8, ty - 5)], CHILI['b'])

# ---------------------------------------------------------------- the milpa: corn, beans and squash (front left)
soil = poly([(0, 130), (110, 136), (142, 199), (0, 199)])
cv.fill(soil, SOIL['b'])
for fy in range(136, 200, 6):
    cv.fill(soil & rect(0, fy, W, fy), SOIL['s'])
    cv.fill(soil & rect(0, fy - 2, W, fy - 2), SOIL['r'])
cv.fill(soil & ~shift(soil, 0, 2), '#6a3a22')


def corn(x, base, h, ear=True):
    o = cv.obj()
    st = rect(x, base - h, x + 1, base)
    lv = blank()
    for k in range(3):
        y = base - h * (k + 1) // 4
        s = 1 if (k + x // 7) % 2 else -1
        lv |= line([(x + (1 if s > 0 else 0), y), (x + s * 6, y - 4), (x + s * 11, y - 1)], 2)
    o.part(st | lv, CORN, d=1)
    if ear:
        o.part(ell(x + 2, base - h // 2 - 6, x + 5, base - h // 2 + 2), MAIZE, d=1)
    o.draw()
    for k in range(-2, 3):   # tassel
        cv.fill(line([(x, base - h), (x + k * 2, base - h - 4 - abs(k) * -1)]), MAIZE['r'] if k % 2 else MAIZE['s'])
    for yy in range(base - h + 6, base - 2, 4):   # a bean vine twining up the stalk
        cv.dots([(x - 1, yy), (x + 2, yy + 2)], '#2a5a2a')
    cv.dots([(x - 2, base - h // 3), (x - 2, base - h // 3 + 1)], '#7a3a6a')   # bean pod
    cv.dots([(x + 3, base - h * 2 // 3)], PINK['r'])   # bean flower


for x in range(4, 112, 11):
    corn(x, 146 + x // 20, 30)
for x in range(8, 124, 12):
    corn(x, 172 + x // 25, 38)
for x, sq in ((10, 1), (36, 0), (60, 1), (82, 0)):   # squash vines and fruit in the gaps
    lf = ell(x - 6, 178, x + 2, 184) | ell(x + 4, 180, x + 12, 186)
    o = cv.obj()
    o.part(lf, CORN, d=1)
    o.draw()
    if sq:
        o = cv.obj()
        o.part(ell(x - 2, 182, x + 9, 190), SQUASH, d=2)
        o.draw()
        cv.fill(rect(x + 3, 180, x + 4, 182), CORN['s'])
        cv.dots([(x, 184), (x + 1, 184)], SQUASH['r'])
    else:
        o = cv.obj()
        o.part(ell(x, 183, x + 6, 189), MAIZE, d=1)
        o.draw()
for x, y in ((24, 152), (70, 154), (98, 158)):   # flat squash flowers in the back row
    cv.fill(rect(x, y, x + 2, y + 2), SQUASH['r'])
    cv.dots([(x + 1, y + 1)], SQUASH['s'])
# kite-flying gnome between the rows
kgx, kgy = 104, 194
gnome(kgx, kgy, TURQ, TERRA, arm='up')
for x in (4, 18, 32, 46, 60, 74, 128):   # front row (gap left for the gnome)
    corn(x, 199, 44 if x % 3 else 40, ear=x % 4 != 0)
ks = [(kgx + 11 + (96 - kgx - 11) * t + 9 * np.sin(np.pi * t), kgy - 31 + (39 - kgy + 31) * t) for t in np.linspace(0, 1, 30)]
ksm = line(ks)   # kite string: a gentle bowed curve, cream over dark corn and leaves, umber over the light stone and sky
lum = cv.px[..., 0].astype(int) * 3 + cv.px[..., 1].astype(int) * 6 + cv.px[..., 2].astype(int)
cv.fill(ksm & (lum < 1500), '#fff4dc')
cv.fill(ksm & (lum >= 1500), '#4a2c1a')

# fountain where the musicians tune up, with a gnome on guitar and two doves
fx0, fy0 = 156, 124
o = cv.obj()
o.part(ell(fx0, fy0 + 6, fx0 + 28, fy0 + 20), LIME, d=2)
o.part(rect(fx0 + 12, fy0 - 6, fx0 + 16, fy0 + 10), LIME, d=1)
o.part(ell(fx0 + 8, fy0 - 9, fx0 + 20, fy0 - 4), LIME, d=1)
o.draw()
cv.fill(ell(fx0 + 3, fy0 + 8, fx0 + 25, fy0 + 14), WATER['b'])
cv.fill(ell(fx0 + 3, fy0 + 8, fx0 + 25, fy0 + 14) & ~shift(ell(fx0 + 3, fy0 + 8, fx0 + 25, fy0 + 14), 0, 2), WATER['s'])
cv.fill(rect(fx0 + 12, fy0 - 6, fx0 + 16, fy0 + 10) & rect(0, fy0 + 8, W, fy0 + 12), LIME['b'])
for dx in (-1, 1):   # water arcs
    cv.fill(line([(fx0 + 14, fy0 - 10), (fx0 + 14 + dx * 6, fy0 - 9), (fx0 + 14 + dx * 9, fy0 + 7)]), WATER['r'])
cv.fill(rect(fx0 + 2, fy0 + 15, fx0 + 26, fy0 + 15), TURQ['b'])   # painted tiles on the basin
for xx in range(fx0 + 3, fx0 + 26, 4):
    cv.dots([(xx, fy0 + 17)], TERRA['b'])
for dvx, dvy in ((fx0 + 4, fy0 + 5), (fx0 + 22, fy0 + 4)):
    cv.fill(ell(dvx, dvy, dvx + 4, dvy + 3), '#fff4dc')
    cv.dots([(dvx, dvy), (dvx - 1, dvy + 1)], LIME['s'])
gnome(198, 148, PINK, MAIZE, arm='out', small=True)
o = cv.obj()   # little guitar
o.part(ell(189, 138, 195, 144), WOOD, d=1)
o.part(line([(194, 139), (200, 134)], 2), WOOD, d=0)
o.draw()
cv.dots([(191, 140)], DARK)
for k, (nx, ny) in enumerate(((205, 141), (212, 135), (219, 140))):   # music notes drifting up-right from the guitar
    c = (DARK, CHILI['s'], '#3a2a48')[k]
    cv.fill(rect(nx, ny, nx + 2, ny + 1), c)
    cv.fill(rect(nx + 2, ny - 6, nx + 2, ny), c)
    if k == 1:   # a beamed pair
        cv.fill(rect(nx + 4, ny + 1, nx + 6, ny + 2) | rect(nx + 6, ny - 5, nx + 6, ny + 1) | rect(nx + 2, ny - 6, nx + 6, ny - 5), c)
    else:
        cv.dots([(nx + 3, ny - 5), (nx + 4, ny - 4), (nx + 4, ny - 3)], c)

# ---------------------------------------------------------------- the path down from the plaza, pots by the path
path = poly([(150, 146), (184, 146), (190, 160), (196, 178), (200, 199), (146, 199), (150, 180), (146, 162)])
cv.fill(path, '#e8c890')
cv.fill(path & ~shift(path, -2, 0), '#c8a070')
cv.fill(path & ~shift(path, 2, 0), '#f6e0b0')
for sx, sy in ((156, 150), (170, 158), (158, 168), (176, 176), (160, 186), (180, 192)):
    o = cv.obj()
    o.part(ell(sx, sy, sx + 10, sy + 5), LIME, d=2)
    o.draw()
for _ in range(40):   # corn kernels and beans spilt on the path
    px, py = r(146, 198), r(146, 199)
    if path[py, px]:
        cv.dots([(px, py)], MAIZE['b'] if r(0, 2) else '#5a3a3a')
for _ in range(70):   # gravel, wheel ruts and footprints so the path is not a plain sand strip
    px, py = r3(146, 200), r3(147, 199)
    if not path[py, px] or cv.px[py, px].tolist() != [232, 200, 144]:
        continue
    k = r3(0, 4)
    if k < 2:
        cv.dots([(px, py), (px + 1, py)], '#c8a070')
    elif k == 2:
        cv.dots([(px, py)], '#f6e0b0')
    elif k == 3:
        cv.dots([(px, py), (px, py + 1), (px + 2, py + 2), (px + 2, py + 3)], '#d4b07a')   # little footprints
    else:
        cv.dots([(px, py), (px + 1, py), (px, py + 1)], LIME['s'])
# a speckled hen and her chicks crossing the path
hx0, hy0 = 184, 170
shadow(hx0 - 1, hy0 + 6, hx0 + 12, hy0 + 8)
o = cv.obj()
o.part(poly([(hx0 + 8, hy0 + 2), (hx0 + 13, hy0 - 4), (hx0 + 12, hy0 + 3)]), ramp('#7a4a2a', '#5a3420'), d=0)   # tail
o.part(ell(hx0, hy0, hx0 + 12, hy0 + 7), ramp('#c8783a', '#9a5428', '#e8a060'), d=1)
o.part(ell(hx0 - 2, hy0 - 4, hx0 + 4, hy0 + 2), ramp('#c8783a', '#9a5428', '#e8a060'), d=1)   # head
o.draw()
cv.dots([(hx0 - 1, hy0 - 5), (hx0, hy0 - 6), (hx0 + 1, hy0 - 5), (hx0 - 2, hy0 + 2)], CHILI['b'])   # comb, wattle
cv.dots([(hx0 - 3, hy0 - 1), (hx0 - 4, hy0 - 1)], MAIZE['s'])   # beak
cv.dots([(hx0, hy0 - 2)], DARK)
cv.dots([(hx0 + 4, hy0 + 3), (hx0 + 7, hy0 + 2), (hx0 + 9, hy0 + 4), (hx0 + 6, hy0 + 5)], '#fff4dc')   # speckles
cv.dots([(hx0 + 4, hy0 + 8), (hx0 + 4, hy0 + 9), (hx0 + 8, hy0 + 8), (hx0 + 8, hy0 + 9)], MAIZE['s'])   # legs
for cx_, cy_ in ((174, 183), (168, 178), (190, 186)):
    o = cv.obj()
    o.part(ell(cx_, cy_, cx_ + 4, cy_ + 3) | rect(cx_ - 1, cy_ - 2, cx_ + 1, cy_), MAIZE, d=0)
    o.draw()
    cv.dots([(cx_ - 1, cy_ - 1)], DARK)
    cv.dots([(cx_ - 2, cy_ - 1)], SQUASH['b'])
for px, py, s in ((136, 140, 6), (146, 136, 4), (128, 146, 3)):   # big clay bean pots by the plaza edge
    shadow(px - s - 1, py + s - 1, px + s + 3, py + s + 2)
    o = cv.obj()
    o.part(ell(px - s, py - s, px + s, py + s), TERRA, d=2)
    o.part(rect(px - s // 2, py - s - 2, px + s // 2, py - s + 1), TERRA, d=1)
    o.draw()
    cv.fill(rect(px - s + 1, py - 1, px + s - 1, py - 1), TURQ['b'])
    cv.dots([(px - s // 2, py - s // 2)], TERRA['r'])

# ---------------------------------------------------------------- Cenote of Echoes (front right)
# burn the main generator exactly as the v0 cenote did, so the litter after it keeps its layout
_rim0, _hole0 = ell(196, 150, 312, 222), ell(208, 160, 298, 222)
_water0 = ell(214, 178, 292, 222) & _hole0
for _ in range(30):
    cx, cy = r(198, 300), r(152, 199)
    if _rim0[cy, cx] and not _hole0[cy, cx]:
        r(-3, 3), r(0, 2)
for _ in range(40):
    wx, wy = r(216, 290), r(182, 198)
    if _water0[wy, wx] and _water0[wy, min(W - 1, wx + 5)]:
        r(2, 5), r(0, 2)
for vx in (216, 228, 244, 262, 276, 286):
    r(12, 26), r(-2, 2)
# limestone rim with a lumpy outer edge, an open shaft with a ragged lip, strata on the far wall, a pool at the bottom
rim = ell(194, 146, 308, 214)
for bx_, by_, br in ((200, 160, 8), (214, 150, 7), (246, 145, 6), (276, 148, 8), (300, 162, 7), (198, 186, 6)):
    rim |= ell(bx_ - br, by_ - br * 2 // 3, bx_ + br, by_ + br * 2 // 3)
hole = ell(208, 156, 296, 196)
for k in range(9):   # ragged lip: rocks jutting in, bites taken out
    ex = 212 + k * 10 + r3(-3, 3)
    col = np.nonzero(hole[:, min(W - 1, ex)])[0]
    ey = int(col.min()) if len(col) else 160
    sz = r3(2, 4)
    if k % 2:
        hole &= ~ell(ex - sz - 1, ey - 1, ex + sz + 1, ey + sz)
    else:
        hole |= ell(ex - sz, ey - sz, ex + sz, ey + 1)
for ex, ey in ((207, 176), (297, 172), (210, 186), (294, 184)):   # side bites
    hole |= ell(ex - 3, ey - 3, ex + 3, ey + 3)
water = hole & rect(0, 179, W, H)
o = cv.obj()
o.part(rim, LIME, d=3)
o.draw()
hole_d = dil4(dil4(hole))
for _ in range(34):   # limestone cracks, pits and moss on the rim top
    cx, cy = min(W - 2, r3(196, 306)), r3(146, 199)
    if rim[cy, cx] and not hole_d[cy, cx]:
        k = r3(0, 3)
        if k == 0:
            cv.fill(line([(cx, cy), (cx + r3(-3, 3), cy + 2)]), LIME['s'])
        elif k == 1:
            cv.fill(rect(cx, cy, cx + r3(1, 3), cy) & rim, CORN['r'])
            cv.dots([(cx + 1, cy - 1)], CORN['b'])
        else:
            cv.dots([(cx, cy), (cx + 1, cy)], LIME['s'])
cv.fill(hole, '#5a3e34')
yy = 158
for k in range(7):   # far wall strata, uneven thickness, each with a lit upper edge
    th = r3(2, 4)
    band = hole & rect(0, yy, W, yy + th - 1) & ~water
    cv.fill(band, ('#6a4a3a', '#4a3430', '#7a5a44')[k % 3])
    cv.fill(band & rect(0, yy, W, yy) & (hole & ~shift(hole, 3, 0)), LIME['s'])
    yy += th
cv.fill(hole & ~shift(hole, 0, 4), '#2a1a18')   # deep shadow under the overhanging far lip
cv.fill(hole & ~shift(hole, 0, 1) & dil4(rim & ~hole), DARK)
cv.fill(dil4(hole) & ~hole & shift(hole, 0, -1) & rim, LIME['r'])   # sunlit edge just above the far lip
cv.fill(water, WATER['b'])
cv.fill(water & ~shift(water, 0, 4), WATER['s'])   # shade where the wall meets the pool
cv.fill(water & rect(0, 179, W, 179), '#1f6a74')
for _ in range(40):
    wx, wy = r3(214, 292), r3(184, 196)
    if water[wy, wx] and water[wy, min(W - 1, wx + 5)]:
        cv.fill(line([(wx, wy), (wx + r3(2, 5), wy)]), WATER['r'] if r3(0, 2) else WATER['s'])
cv.fill(water & poly([(222, 179), (236, 179), (246, 199), (228, 199)]) & ~rect(0, 0, W, 182), WATER['r'])   # slanting light shaft
cv.fill(dil4(hole) & ~hole & ~shift(hole, 0, -1) & shift(hole, 0, 2), '#6a4a3a')   # near lip: thin wet ledge
for x0 in range(210, 296, 7):   # stalactite teeth under the far lip
    col = np.nonzero(hole[:, x0])[0]
    if len(col):
        t0 = int(col.min())
        cv.fill(poly([(x0 - 1, t0), (x0 + 2, t0), (x0, t0 + r3(3, 5))]), LIME['s'])
for vx in (216, 232, 249, 264, 278, 290):   # hanging vines and roots from the far lip
    col = np.nonzero(hole[:, vx])[0]
    if not len(col):
        continue
    v0 = int(col.min())
    ln = min(r3(10, 22), 178 - v0)
    cv.fill(line([(vx, v0), (vx + r3(-2, 2), v0 + ln)]), CORN['s'])
    for k in range(2, ln, 3):
        cv.dots([(vx + (1 if k % 2 else -1), v0 + k)], CORN['b'] if k % 4 else CORN['r'])
    if vx % 3 == 0:
        cv.dots([(vx, v0 + ln + 1)], PINK['b'])
# rope ladder down the left wall into the pool
for side in (220, 226):
    cv.fill(line([(side - 3, 162), (side, 186)]), '#d9a35a')
for k in range(6):
    yk = 165 + k * 4
    xk = 217 + (yk - 162) * 3 // 24
    cv.fill(rect(xk + 1, yk, xk + 6, yk), WOOD['b'])
cv.fill(rect(214, 158, 219, 161), WOOD['s'])   # stake on the rim
# swimming gnome (head and hat) with ripple rings
sgx, sgy = 258, 190
cv.fill(ell(sgx - 10, sgy - 1, sgx + 10, sgy + 4) & ~ell(sgx - 8, sgy, sgx + 8, sgy + 3) & water, WATER['r'])
o = cv.obj()
o.part(rect(sgx - 4, sgy - 5, sgx + 4, sgy + 1), SKIN, d=1)
o.part(poly([(sgx - 5, sgy - 6), (sgx + 5, sgy - 6), (sgx + 2, sgy - 18)]), MAIZE, d=2, contour=True)
o.part(poly([(sgx - 4, sgy - 2), (sgx + 4, sgy - 2), (sgx, sgy + 2)]), BEARD, d=1, contour=True)
o.draw()
cv.dots([(sgx - 2, sgy - 4), (sgx + 2, sgy - 4)], DARK)
cv.fill(rect(sgx - 5, sgy + 1, sgx + 5, sgy + 1), WATER['s'])
cv.fill(line([(sgx + 6, sgy - 4), (sgx + 10, sgy - 8)], 2), SKIN['b'])   # waving hand
# a gnome on the far lip, about to jump in
gnome(240, 153, CHILI, TURQ, arm='up')
cv.dots([(254, 132), (256, 130), (258, 132), (260, 128), (262, 126), (264, 128)], DARK)   # echo marks
# pot and flowers on the rim, a hummingbird
o = cv.obj()
o.part(ell(284, 148, 296, 158), TERRA, d=2)
o.part(rect(287, 146, 293, 149), TERRA, d=1)
o.draw()
cv.fill(rect(285, 153, 295, 153), TURQ['b'])
for fx, fy in ((299, 158), (297, 166), (292, 144), (300, 150), (200, 168), (203, 190)):
    cv.fill(rect(fx, fy, fx + 2, fy + 1), PINK['b'])
    cv.dots([(fx + 1, fy)], PINK['r'])
hbx, hby = 272, 142
cv.fill(ell(hbx, hby, hbx + 5, hby + 3), JADE['b'])
cv.dots([(hbx - 1, hby + 1), (hbx - 2, hby + 1), (hbx - 3, hby + 2)], DARK)
cv.fill(line([(hbx + 2, hby), (hbx + 5, hby - 4)]), JADE['r'])
cv.fill(line([(hbx + 3, hby), (hbx + 7, hby - 3)]), JADE['r'])
cv.dots([(hbx + 1, hby + 1)], CHILI['b'])

# ---------------------------------------------------------------- cacti
CACT = ramp('#5fa86a', '#3a7a4a', '#9ad08a')


def pear(x, y, pads):
    o = cv.obj()
    for dx, dy, w, h in pads:
        o.part(ell(x + dx, y + dy, x + dx + w, y + dy + h), CACT, d=2)
    o.draw()
    for dx, dy, w, h in pads:
        for k in range(3):
            cv.dots([(x + dx + 2 + k * w // 3, y + dy + 2 + (k % 2) * h // 2)], '#f2e4c0')
        cv.dots([(x + dx + w // 2, y + dy - 1), (x + dx + w // 2 + 1, y + dy - 1)], CHILI['b'])   # tuna fruit


pear(256, 122, ((6, 8, 10, 14), (0, 0, 9, 11), (12, 0, 9, 12), (4, -8, 8, 10)))
o = cv.obj()   # tall columnar cactus at the far right
o.part(rect(288, 100, 294, 146) | rect(280, 112, 284, 128) | rect(282, 126, 288, 129) | rect(296, 106, 299, 122), CACT, d=2)
o.draw()
for yy in range(102, 146, 3):
    cv.dots([(290, yy), (292, yy + 1)], CACT['s'])
cv.dots([(291, 99), (281, 111), (297, 105)], PINK['b'])
for bx, by in ((4, 132), (138, 192), (300 - 12, 186)):   # barrel cacti with flowers
    o = cv.obj()
    o.part(ell(bx, by, bx + 9, by + 9), CACT, d=2)
    o.draw()
    cv.fill(rect(bx + 2, by + 3, bx + 2, by + 7) | rect(bx + 5, by + 2, bx + 5, by + 8), CACT['s'])
    cv.fill(rect(bx + 3, by - 2, bx + 6, by), PINK['b'])
    cv.dots([(bx + 4, by - 2)], MAIZE['b'])
o = cv.obj()   # agave in the front corner of the path
ag = blank()
for dx, dy in ((-10, -4), (-6, -10), (0, -12), (6, -10), (10, -4)):
    ag |= line([(178, 199), (178 + dx, 199 + dy)], 3)
o.part(ag, ramp('#7aa8a0', '#4f7a74', '#a8d0c4'), d=1)
o.draw()

# ---------------------------------------------------------------- litter: dry grass tufts, marigolds, pebbles
keep = rect(140, 100, 260, 152) | rect(0, 22, 124, 128) | soil | path | _rim0 | rect(196, 120, 240, 162) | rect(240, 60, 300, 152)
for _ in range(220):
    lx, ly = r(0, W - 3), r(100, H - 3)
    if keep[ly, lx]:
        continue
    k = r(0, 5)
    if rim[ly, lx]:
        continue
    if k < 3:
        cv.dots([(lx, ly), (lx, ly - 1), (lx + 1, ly - 2), (lx - 1, ly - 1)], '#b8a050' if k else '#8a9a4a')
    elif k == 3:
        cv.fill(rect(lx, ly, lx + 1, ly + 1), SQUASH['b'])
        cv.dots([(lx, ly)], MAIZE['r'])
    else:
        cv.dots([(lx, ly), (lx + 1, ly)], LIME['s'])
for fx in range(2, 300, 9):   # marigolds along the plaza back edge, loosely spaced
    fy = r2(98, 110)
    if keep[fy, fx]:
        continue
    cv.dots([(fx, fy), (fx - 1, fy + 1), (fx + 1, fy + 1)], SQUASH['b'])
    cv.dots([(fx, fy + 1)], MAIZE['s'])

cv.remap({'#c49a6a': '#c8a070', '#9a7048': '#a8825a', '#f0a0a0': '#f6b8cf', '#2a8a4a': '#2a7050', '#8ae09a': '#8ad09a', '#e8607a': '#e46a9b', '#5a4a48': '#3a2a28', '#f2e4c0': '#fff4dc',
          '#8a9a4a': '#5a9a3a', '#ecc488': '#f2d8a8', '#c9c5bc': '#b8a888', '#fff0d8': '#fff4dc', '#f5cf6a': '#f8dc7a', '#f08a6a': '#e8905a',
          '#a8d0c4': '#8adcd0', '#4f7a74': '#24807e', '#a8869e': '#9a7a96', '#d9a07a': '#d9a35a', '#3d2a1c': '#3a2a28', '#6a3a22': '#5c3420',
          '#e2d2c8': '#efe2d4', '#2a1a18': DARK, '#8ae0d8': '#8adcd0', '#9ad08a': '#8ad09a', '#5a3e34': '#5a3a3a', '#d8905a': '#e8905a'})

if __name__ == '__main__':
    out = sys.argv[1] if len(sys.argv) > 1 else None
    n = save_pic(cv, 'maizehollow', out)
    print('maizehollow:', n, 'colours')
