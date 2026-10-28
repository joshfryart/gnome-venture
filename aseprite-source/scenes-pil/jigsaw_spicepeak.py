"""Jigsaw picture: SPICEPEAK (v2.0.87): game/assets/img/jigsaw/spicepeak.jpg (+ -thumb). Usage: python3 -B aseprite-source/scenes-pil/jigsaw_spicepeak.py [outdir]
A monsoon-clearing mountain valley: rain clouds drifting off to the right, a rainbow over snow peaks, kites over the ridge, the Cloud Monastery on its crag
(apricots drying on the flat roof), strings of prayer flags to a white stupa on a green knoll, a snow leopard on the right-hand ledge, terraced tea, saffron
and chilli fields stepping down the left slope with a gnome picker, a teal river with a waterfall and a rope bridge where a gnome leads a laden yak, a flower
boat poled down the river, river ghat steps with spice mortars, and the spice souk in front right: a striped awning, chilli garlands, burlap sacks of saffron,
turmeric, chilli, cardamom and cumin, and the gnome spice-seller. A tiger moth flutters over the terraces.
"""
import math
import sys

from jigsaw_common import *  # noqa: F401,F403

# ---------------------------------------------------------------- palette (saffron / magenta / teal / snow-white lead)
SKY0, SKY1, SKY2 = '#86c9c9', '#a8dbd3', '#c8ecdf'
SNOW = ramp('#f7f5ee', '#c9d2e4', '#ffffff')
ROCK0, ROCK1 = '#9a9cc0', '#7a7ca6'
FOOT = ramp('#5f9c86', '#467e6c', '#82b89a')
GRASS = ramp('#6eae5a', '#4f9a45', '#a4b86a')
TEA = ramp('#3f9a4a', '#2f6a3a', '#7ab55c')
WALL = ramp('#b49a76', '#7a6248', '#d8c4a0')
SAFF = ramp('#f0a020', '#c06a10', '#f8d060')
MAG = ramp('#c8327a', '#8e1f58', '#ec74ac')
TEAL = ramp('#2a9a9a', '#1d7378', '#7fd0c8')
WATER = ramp('#2a9a9a', '#1d7378', '#7fd0c8')
WOOD = ramp('#b07a3a', '#7a4a1f', '#d9a35a')
DARKW = ramp('#7a4a1f', '#4a2c1a', '#9a6b3f')
STONE = ramp('#c9c5bc', '#8b8f96', '#ece8de')
WHITE = ramp('#f4f0e4', '#c9c5bc', '#ffffff')
GOLD = ramp('#e8a317', '#b07a10', '#f5cf6a')
MAROON = ramp('#8e2a3a', '#5e1c28', '#b8485a')
BURLAP = ramp('#cfae7a', '#9a7a4a', '#ecd6a4')
RED = ramp('#d6322b', '#a8241f', '#f08a24')
SKIN = ramp('#f2c8a0', '#d9a07a', '#fff0d8')
BEARD = ramp('#f1ece0', '#c9c5bc', '#ffffff')
YAK = ramp('#4a3a30', '#2a1a10', '#6a5848')
LEO = ramp('#e6e0d0', '#b8b0a0', '#ffffff')
FLAGS = ('#3f7fc8', '#f4f0e4', '#d6322b', '#3f9a4a', '#f0c030')
cv = new_canvas(SKY0)
r = rnd(4242)
r2 = rnd(91)
yy_g, xx_g = np.mgrid[0:H, 0:W]


def shadow(x0, y0, x1, y1, col='#3d6a3a'):
    cv.fill(ell(x0, y0, x1, y1), col)


def sag(p0, p1, s, step=1):
    """Points along a hanging string from p0 to p1, sagging s pixels at the middle."""
    (x0, y0), (x1, y1) = p0, p1
    n = max(2, int(abs(x1 - x0) / step))
    return [(x0 + (x1 - x0) * t / n, y0 + (y1 - y0) * t / n + s * 4 * (t / n) * (1 - t / n)) for t in range(n + 1)]


def flag_string(p0, p1, s, gap=4, seed=0):
    pts = sag(p0, p1, s)
    cv.fill(line([(int(x), int(y)) for x, y in pts]), '#4a2c1a')
    k = seed
    for i in range(2, len(pts) - 2, gap):
        x, y = int(pts[i][0]), int(pts[i][1])
        c = FLAGS[k % 5]
        k += 1
        cv.fill(rect(x, y + 1, x + 2, y + 4), c)
        cv.dots([(x + 2, y + 4)], '#2a1a10' if c == FLAGS[1] else c)
        if c == FLAGS[1]:
            cv.dots([(x, y + 4), (x + 1, y + 4)], '#c9c5bc')


def gnome(gx, gy, k, hat, tunic, face=1):
    """A gnome with feet at (gx, gy); k = 1 small, 2 large. face = 1 hat tip leans left (faces right)."""
    o = cv.obj()
    o.part(rect(gx - 3 * k, gy - k - 1, gx - 1, gy) | rect(gx + 1, gy - k - 1, gx + 3 * k, gy), DARKW, d=1)
    o.part(rrect(gx - 3 * k - 1, gy - 7 * k, gx + 3 * k + 1, gy - k - 1, k), tunic, d=2, contour=True)
    o.part(poly([(gx - 3 * k - 1, gy - 9 * k - 1), (gx + 3 * k + 1, gy - 9 * k - 1), (gx, gy - 3 * k)]), BEARD, d=1, contour=True)
    o.part(rect(gx - 2 * k - 1, gy - 12 * k + 1, gx + 2 * k + 1, gy - 9 * k), SKIN, d=1)
    o.part(poly([(gx - 4 * k, gy - 11 * k), (gx + 4 * k, gy - 11 * k), (gx - 3 * k * face, gy - 21 * k)]), hat, d=2, contour=True)
    o.draw()
    cv.fill(rect(gx - 4 * k, gy - 11 * k, gx + 4 * k, gy - 11 * k + k - 1), hat['s'])
    ey = gy - 11 * k + k + (1 if k > 1 else 0)
    cv.dots([(gx - k, ey), (gx + k, ey)], '#2a1a10')
    if k > 1:
        cv.dots([(gx, ey + 1), (gx + 1, ey + 1), (gx, ey + 2), (gx + 1, ey + 2)], '#e0907a')
        cv.dots([(gx - 3, ey + 2), (gx + 3, ey + 2)], '#f0a0a0')
        cv.fill(rect(gx - 3 * k - 1, gy - 3 * k, gx + 3 * k + 1, gy - 3 * k + 1), DARKW['b'])
        cv.fill(rect(gx - 1, gy - 3 * k, gx + 1, gy - 3 * k + 1), GOLD['r'])
    return o


# ---------------------------------------------------------------- sky: bands, clearing rain clouds on the right, clouds, rainbow, kites, birds
cv.fill(rect(0, 16, W - 1, 99), SKY1)
cv.fill(rect(0, 40, W - 1, 99), SKY2)
rb_cx, rb_cy = 100, 132
d2 = (xx_g - rb_cx) ** 2 + (yy_g - rb_cy) ** 2
for i, c in enumerate(('#e0483a', '#f09030', '#f5d040', '#5fb05a', '#3f8fc0', '#8a5aa8')):
    ro = 110 - i * 2
    cv.fill((d2 <= ro * ro) & (d2 > (ro - 2) ** 2), c)
for cx, cy, w in ((34, 12, 40), (118, 34, 34), (72, 52, 26), (8, 38, 20), (150, 8, 30)):   # fair-weather clouds on the clear side
    m = ell(cx - w // 2, cy - 6, cx + w // 2, cy + 5) | ell(cx - w // 4, cy - 11, cx + w // 5, cy + 3) | ell(cx, cy - 8, cx + w // 2 - 5, cy + 4)
    m &= ~rect(0, cy + 3, W, H)
    cv.fill(m, '#ffffff')
    cv.fill(m & ~shift(m, -2, -2) & rect(0, cy - 2, W, cy + 3), '#d4ece8')
    cv.fill(m & rect(0, cy + 3, W, cy + 3), '#b8d8d8')
rain = blank()
for cx, cy, w in ((262, 6, 70), (214, 2, 50), (296, 20, 40), (240, 18, 40)):   # the last monsoon clouds drifting away
    m = ell(cx - w // 2, cy - 8, cx + w // 2, cy + 7) | ell(cx - w // 4, cy - 14, cx + w // 4, cy + 4) | ell(cx + 2, cy - 10, cx + w // 2 - 4, cy + 6)
    rain |= m
cv.fill(rain, '#9aa4b8')
cv.fill(rain & ~shift(rain, -3, -3), '#7a84a0')
cv.fill(rain & ~shift(rain, 2, 2), '#c3cad8')
for k in range(26):   # rain streaks under them
    sx, sy = r(196, 298), r(22, 34)
    if not rain[sy, sx]:
        cv.fill(line([(sx, sy), (sx - 2, sy + r(5, 9))]), '#9fb4c4')
for kx, ky, rp, tail in ((132, 14, MAG, 22), (100, 26, SAFF, 18), (180, 40, TEAL, 16)):   # kite duel over the ridge
    km = poly([(kx, ky - 6), (kx + 5, ky), (kx, ky + 7), (kx - 5, ky)])
    o = cv.obj()
    o.part(km, rp, d=2)
    o.draw()
    cv.fill(line([(kx, ky - 6), (kx, ky + 7)]) & km, rp['s'])
    cv.fill(line([(kx - 5, ky), (kx + 5, ky)]) & km, rp['r'])
    cv.fill(line([(kx, ky + 7), (kx - 4, ky + 12), (kx + 1, ky + 16), (kx - 3, ky + tail)]), '#4a2c1a')
    for t in range(3):
        cv.dots([(kx - 4 + t, ky + 10 + t * 3), (kx - 3 + t, ky + 10 + t * 3)], FLAGS[(t + kx) % 5])
for bx, by in ((60, 26), (66, 29), (72, 26), (190, 52), (196, 55), (54, 30)):
    cv.dots([(bx, by), (bx + 1, by - 1), (bx + 2, by), (bx + 3, by - 1), (bx + 4, by)], '#3a4a5a')

# ---------------------------------------------------------------- far snow peaks
PEAKS = [(0, 62), (22, 46), (42, 58), (78, 30), (104, 50), (132, 40), (160, 56), (204, 16), (236, 42), (262, 30), (300, 50)]
VALL = [(11, 56), (32, 62), (60, 54), (92, 58), (118, 56), (146, 62), (182, 58), (222, 46), (248, 48), (282, 52)]
pts = []
for i in range(len(PEAKS)):
    pts.append(PEAKS[i])
    if i < len(VALL):
        pts.append(VALL[i])
mtn = poly(pts + [(300, 112), (0, 112)])
cv.fill(mtn, ROCK0)
top = np.where(mtn.any(axis=0), np.argmax(mtn, axis=0), H)
depth = np.zeros(W, int)
for x in range(W):
    depth[x] = max(0, 26 - (top[x] - 16) // 2) + r(0, 4)
snow = mtn & (yy_g < top[None, :] + depth[None, :]) & (yy_g < 64)
shade = blank()
for (px, py), (vx, vy) in zip(PEAKS, VALL + [(300, 60)]):   # the right-hand face of every peak is in shade
    shade |= poly([(px, py), (vx, vy), (vx - 2, vy + 40), (px + 3, py + 50)]) & mtn
cv.fill(shade, ROCK1)
cv.fill(snow & ~shade, SNOW['b'])
cv.fill(snow & shade, SNOW['s'])
for (px, py) in PEAKS[1:-1]:   # crisp ridge-line glints
    cv.fill(line([(px, py + 1), (px - 6, py + 9)]) & snow, SNOW['r'])
for x in range(3, W - 3, 7):   # rock ribs poking through the snow line
    y = top[x] + depth[x] + r(-1, 2)
    if y < 70:
        cv.fill(line([(x, y), (x + 2, y + 5)]), '#6a6c94')
cv.fill(mtn & rect(0, 76, W, 112) & ~snow, '#8f93b8')

# ---------------------------------------------------------------- foothills: teal-green with tree dots; the stupa knoll and the leopard crag
foot = poly([(0, 88), (24, 80), (52, 86), (86, 74), (122, 84), (160, 78), (196, 70), (214, 66), (244, 66), (262, 76), (282, 70), (300, 68), (300, 130), (0, 130)])
cv.fill(foot, FOOT['b'])
cv.fill(foot & ~shift(foot, 0, 2), FOOT['r'])
x = 2
while x < W - 3:
    x += r2(3, 7)
    col = foot[:, min(W - 1, x)]
    if not col.any():
        continue
    ty = int(np.argmax(col)) + r2(4, 14)
    shp = ((0, 0), (1, 0), (0, 1), (1, 1), (-1, 1), (0, -1)) if r2(0, 2) else ((0, 0), (0, 1), (1, 1))
    cv.dots([(x + dx, ty + dy) for dx, dy in shp], FOOT['s'])
    cv.dots([(x, ty - (1 if len(shp) > 3 else 0))], '#82b89a')
crag = poly([(262, 112), (268, 72), (276, 60), (286, 56), (296, 62), (300, 58), (300, 112)])
o = cv.obj()
o.part(crag, ramp('#8b8f96', '#5b6470', '#c9c5bc', '#6a7280'), d=3)
o.draw()
for (a, b) in (((272, 74), (282, 80)), ((284, 66), (298, 70)), ((268, 90), (280, 94)), ((282, 86), (296, 92))):
    cv.fill(line([a, b]), '#5b6470')
    cv.fill(line([(a[0], a[1] - 1), (b[0], b[1] - 1)]), '#c9c5bc')
cv.fill(crag & rect(0, 54, W, 60), SNOW['b'])
# snow leopard on the ledge, tail curled up
lx, ly = 278, 52
o = cv.obj()
o.part(ell(lx, ly, lx + 15, ly + 7), LEO, d=2)
o.part(ell(lx - 5, ly - 3, lx + 3, ly + 4), LEO, d=1)
o.part(rect(lx + 1, ly + 5, lx + 2, ly + 9) | rect(lx + 11, ly + 5, lx + 12, ly + 9), LEO, d=0)
o.part(line([(lx + 15, ly + 4), (lx + 20, ly + 2), (lx + 21, ly - 4), (lx + 18, ly - 7)], 2), LEO, d=1)
o.draw()
cv.dots([(lx - 4, ly - 4), (lx + 1, ly - 4)], LEO['s'])
cv.dots([(lx - 3, ly), (lx - 1, ly)], '#3a4a5a')
cv.dots([(lx - 5, ly + 2)], '#c87a7a')
for sx, sy in ((lx + 4, ly + 2), (lx + 7, ly + 1), (lx + 10, ly + 3), (lx + 6, ly + 5), (lx + 12, ly + 1), (lx + 19, ly - 1), (lx + 20, ly - 5)):
    cv.dots([(sx, sy), (sx + 1, sy)], '#5a5048')

# ---------------------------------------------------------------- the lower valley floor
cv.fill(rect(0, 104, W - 1, H - 1) & ~crag & ~(rect(0, 0, W, 103)), GRASS['b'])
cv.fill(rect(0, 100, W - 1, 104) & ~crag, FOOT['s'])

# river centreline and half-width by row
RY = [96, 104, 112, 122, 132, 142, 152, 162, 172, 182, 192, 200]
RX = [206, 200, 190, 180, 174, 170, 162, 152, 146, 142, 138, 136]
RW = [2, 4, 6, 8, 10, 11, 13, 15, 17, 19, 21, 22]


def river_at(y):
    y = max(RY[0], min(RY[-1], y))
    for i in range(len(RY) - 1):
        if RY[i] <= y <= RY[i + 1]:
            t = (y - RY[i]) / (RY[i + 1] - RY[i])
            return RX[i] + (RX[i + 1] - RX[i]) * t, RW[i] + (RW[i + 1] - RW[i]) * t
    return RX[-1], RW[-1]


rc = np.zeros(H)
rw = np.zeros(H)
for y in range(H):
    rc[y], rw[y] = river_at(y)
river = (np.abs(xx_g - rc[:, None]) <= rw[:, None]) & (yy_g >= 98)

# ---------------------------------------------------------------- terraces on the left slope: tea, saffron crocus, chilli, turmeric
TOPS = [80, 89, 99, 110, 123, 138, 156, 178, 210]
CROP = ['tea', 'crocus', 'tea', 'chilli', 'tea', 'turmeric', 'tea', 'tea']


def tline(k, x):
    return TOPS[k] + int(0.12 * x + 3 * math.sin(x / 21 + k * 1.3))


tl = np.array([[tline(k, x) for x in range(W)] for k in range(len(TOPS))])
limit = (rc - rw - 5).astype(int)
limit[:100] = int(rc[100] - rw[100] - 5)
inner = xx_g <= limit[:, None]
bands = []
for k in range(len(TOPS) - 1):
    band = (yy_g >= tl[k][None, :]) & (yy_g < tl[k + 1][None, :]) & inner
    bands.append(band)
    wall = band & (yy_g >= tl[k + 1][None, :] - 3 - k // 3)
    field = band & ~wall
    cv.fill(field, TEA['b'] if CROP[k] == 'tea' else ('#8a7a4a' if CROP[k] != 'turmeric' else '#7a9a3a'))
    cv.fill(field & ~shift(field, 0, 1), TEA['r'] if CROP[k] == 'tea' else '#a4b86a')
    cv.fill(wall, WALL['b'])
    cv.fill(wall & ~shift(wall, 0, 1), WALL['r'])
    cv.fill(wall & ~shift(wall, 0, -1), WALL['s'])
    ys, xs = np.nonzero(wall)
    if len(xs):
        for xj in range(int(xs.min()) + (k * 3) % 7, int(xs.max()), 6 + k // 2):   # stone joints
            col = wall[:, xj]
            if col.any():
                y0 = int(np.argmax(col))
                cv.fill(rect(xj, y0 + 1, xj, y0 + 1 + k // 3), WALL['s'])
cv.fill(dil4(river) & ~river & (yy_g > 100), '#8a7a5a')

for k in range(len(TOPS) - 1):   # crops in rows along each terrace
    crop = CROP[k]
    sz = 2 + k // 2
    x = 2 + (k * 5) % 7
    while x < W:
        lim = limit[min(H - 1, tline(k, x) + 4)]
        if x > lim - sz:
            break
        y0, y1 = tline(k, x), tline(k + 1, x) - 3 - k // 3
        if y1 - y0 < 3:
            x += 4
            continue
        if y0 >= H:
            break
        rows = 1 if k < 5 else 2
        for rr in range(rows):
            cy = y0 + (y1 - y0) * (rr + 1) // (rows + 1) + 1
            if cy >= H:
                continue
            cx = x + rr * (sz + 1)
            if crop == 'tea':
                m = ell(cx - sz - 1, cy - sz, cx + sz + 1, cy + sz // 2 + 1)
                o = cv.obj(outline=k >= 4)
                o.part(m, TEA, d=1 if k < 4 else 2)
                o.draw()
                if k >= 4:
                    cv.dots([(cx - 1, cy - sz + 1), (cx + 1, cy - sz + 2), (cx - sz + 1, cy)], '#a4d070')
            elif crop == 'crocus':
                cv.dots([(cx, cy), (cx, cy + 1)], '#4f9a45')
                cv.dots([(cx - 1, cy - 1), (cx + 1, cy - 1), (cx, cy - 2)], '#9a7ac8')
                cv.dots([(cx, cy - 1)], '#e0483a')
            elif crop == 'chilli':
                cv.fill(ell(cx - 2, cy - 2, cx + 2, cy + 1), '#4f9a45')
                cv.dots([(cx - 1, cy), (cx + 2, cy - 1), (cx, cy + 1)], RED['b'])
            else:
                cv.fill(line([(cx, cy + 1), (cx - 2, cy - 3)]) | line([(cx, cy + 1), (cx + 2, cy - 3)]) | line([(cx, cy + 1), (cx, cy - 4)]), '#a4b86a')
                cv.dots([(cx, cy + 1), (cx + 1, cy + 1)], SAFF['b'])
        x += sz * 2 + 3 + (rows - 1) * 2
# a stone stair up the terraces
for k in range(len(TOPS) - 2):
    sx = 92 - k * 6
    y0 = tline(k + 1, sx) - 4 - k // 3
    if y0 < H:
        o = cv.obj()
        o.part(rect(sx, y0, sx + 6 + k // 2, y0 + 3 + k // 3), WALL, d=1)
        o.draw()

# ---------------------------------------------------------------- the Cloud Monastery on its crag (left), apricots drying on the roof
mx0, my0 = 10, 56
o = cv.obj()
o.part(poly([(mx0 - 4, my0 + 30), (mx0 + 2, my0 + 18), (mx0 + 50, my0 + 18), (mx0 + 58, my0 + 30)]), ramp('#8b8f96', '#5b6470', '#c9c5bc'), d=2)
o.part(poly([(mx0 + 2, my0 + 24), (mx0 + 48, my0 + 24), (mx0 + 45, my0 + 2), (mx0 + 5, my0 + 2)]), WHITE, d=3)
o.part(rect(mx0 + 4, my0 - 2, mx0 + 46, my0 + 3), MAROON, d=1)
o.part(poly([(mx0 + 16, my0 - 2), (mx0 + 34, my0 - 2), (mx0 + 31, my0 - 12), (mx0 + 19, my0 - 12)]), WHITE, d=2)
o.part(rect(mx0 + 18, my0 - 15, mx0 + 32, my0 - 12), MAROON, d=1)
o.draw()
cv.fill(rect(mx0 + 3, my0 - 3, mx0 + 47, my0 - 3), '#4a2c1a')
cv.fill(rect(mx0 + 17, my0 - 16, mx0 + 33, my0 - 16), '#4a2c1a')
o = cv.obj()
o.part(poly([(mx0 + 23, my0 - 17), (mx0 + 27, my0 - 17), (mx0 + 25, my0 - 24)]), GOLD, d=1)
o.draw()
for wx in (mx0 + 9, mx0 + 21, mx0 + 33):   # trapezoid windows with saffron frames
    cv.fill(poly([(wx, my0 + 8), (wx + 6, my0 + 8), (wx + 7, my0 + 15), (wx - 1, my0 + 15)]), '#2a1a10')
    cv.fill(rect(wx, my0 + 7, wx + 6, my0 + 7), SAFF['b'])
    cv.fill(rect(wx + 2, my0 + 10, wx + 4, my0 + 13), MAG['s'])
cv.fill(rect(mx0 + 22, my0 - 10, mx0 + 28, my0 - 5), '#2a1a10')
cv.fill(rect(mx0 + 22, my0 - 11, mx0 + 28, my0 - 11), SAFF['b'])
cv.fill(rect(mx0 + 20, my0 + 17, mx0 + 30, my0 + 24), '#2a1a10')   # door
cv.fill(rect(mx0 + 21, my0 + 18, mx0 + 29, my0 + 24), MAROON['b'])
cv.fill(rect(mx0 + 25, my0 + 18, mx0 + 25, my0 + 24), '#5e1c28')
cv.dots([(mx0 + 24, my0 + 21), (mx0 + 26, my0 + 21)], GOLD['b'])
for k in range(10):   # apricots on mats on the flat roof ends
    ax = mx0 + 5 + k * 1 + (0 if k < 5 else 31)
    cv.dots([(ax + (k % 2), my0 - 4)], ('#f0a020', '#e0702a')[k % 2])
cv.fill(rect(mx0 + 5, my0 - 4, mx0 + 13, my0 - 4) | rect(mx0 + 36, my0 - 4, mx0 + 44, my0 - 4), '#e0702a')
cv.dots([(mx0 + 6 + 2 * k, my0 - 5) for k in range(4)] + [(mx0 + 37 + 2 * k, my0 - 5) for k in range(4)], SAFF['r'])
# flag pole next to it, and strings: pole -> stupa, monastery -> left edge
o = cv.obj()
o.part(rect(66, 40, 67, 84), WOOD, d=0)
o.draw()
cv.dots([(66, 39), (67, 39)], GOLD['b'])
o = cv.obj()   # a vertical banner flag on the pole
o.part(rect(68, 42, 71, 60), MAG, d=1)
o.draw()
for yb in range(44, 60, 4):
    cv.fill(rect(68, yb, 71, yb), SAFF['b'])

# ---------------------------------------------------------------- the stupa on its knoll (right of centre)
sx0, sy0 = 228, 88
shadow(206, sy0 + 2, 252, sy0 + 8, FOOT['s'])
o = cv.obj()
o.part(rect(sx0 - 16, sy0 - 6, sx0 + 16, sy0 + 2), WHITE, d=2)
o.part(rect(sx0 - 12, sy0 - 11, sx0 + 12, sy0 - 6), WHITE, d=2)
o.part(ell(sx0 - 12, sy0 - 30, sx0 + 12, sy0 - 4) & rect(0, 0, W, sy0 - 11), WHITE, d=3)
o.part(rect(sx0 - 4, sy0 - 37, sx0 + 4, sy0 - 29), GOLD, d=1, contour=True)
o.part(poly([(sx0 - 4, sy0 - 37), (sx0 + 4, sy0 - 37), (sx0, sy0 - 54)]), GOLD, d=2, contour=True)
o.draw()
for k in range(4):   # spire rings
    yk = sy0 - 40 - k * 4
    hw = 3 - k * 3 // 4
    cv.fill(rect(sx0 - hw, yk, sx0 + hw, yk), GOLD['s'])
cv.fill(ell(sx0 - 4, sy0 - 59, sx0 + 4, sy0 - 54) & rect(0, 0, W, sy0 - 56), GOLD['b'])   # parasol
cv.dots([(sx0 - 3, sy0 - 57)], GOLD['r'])
cv.dots([(sx0 - 3, sy0 - 34), (sx0 - 2, sy0 - 34), (sx0 + 2, sy0 - 34), (sx0 + 3, sy0 - 34)], '#25637d')   # the painted eyes
cv.dots([(sx0 - 2, sy0 - 33), (sx0 + 2, sy0 - 33)], '#2a1a10')
cv.dots([(sx0, sy0 - 32), (sx0, sy0 - 31)], '#25637d')
cv.fill(rect(sx0 - 12, sy0 - 12, sx0 + 12, sy0 - 12), SAFF['b'])   # saffron band
for xk in range(sx0 - 14, sx0 + 15, 5):
    cv.fill(rect(xk, sy0 - 3, xk + 2, sy0), '#2a1a10')   # niches
    cv.dots([(xk + 1, sy0 - 2)], SAFF['r'])
cv.fill(ell(sx0 - 9, sy0 - 26, sx0 - 4, sy0 - 20), WHITE['r'])
# prayer-flag strings: monastery pole -> stupa spire (long sag across the valley), stupa -> crag, monastery -> left edge, stupa -> knoll foot
flag_string((67, 41), (sx0, sy0 - 52), 30, seed=0)
flag_string((sx0, sy0 - 50), (300, 64), 10, seed=2)
flag_string((0, 30), (mx0 + 25, my0 - 22), 6, seed=4)
flag_string((sx0, sy0 - 48), (198, 98), 4, gap=3, seed=1)

# ---------------------------------------------------------------- the river: waterfall from the knoll, ripples, banks
cv.fill(river, WATER['b'])
cv.fill(river & ~shift(river, -3, 0), WATER['s'])
cv.fill(river & ~shift(river, 2, 0), '#5fbab4')
for k in range(110):
    y = r(100, 199)
    x = int(rc[y]) + r(-int(rw[y]), int(rw[y]))
    ln = 2 + y // 50
    if river[y, max(0, x - 1)] and river[y, min(W - 1, x + ln + 1)]:
        cv.fill(rect(x, y, x + ln, y), WATER['r'] if r(0, 2) else WATER['s'])
fall = rect(202, 90, 209, 100)
cv.fill(fall, '#e8f6f2')
cv.fill(rect(203, 90, 203, 100) | rect(207, 92, 207, 100), '#7fd0c8')
cv.fill(ell(198, 98, 213, 104), '#e8f6f2')
cv.dots([(197, 99), (214, 100), (200, 96), (212, 95)], '#ffffff')
for sx, sy in ((186, 112), (196, 108), (160, 150), (176, 140), (132, 186), (157, 172)):   # river stones
    o = cv.obj()
    o.part(ell(sx, sy, sx + 6, sy + 4), STONE, d=1)
    o.draw()
    cv.fill(rect(sx - 1, sy + 4, sx + 7, sy + 4), WATER['r'])

# ---------------------------------------------------------------- right bank: grass to the knoll, spice mats drying, ghat steps
rbank = (xx_g > (rc + rw + 1)[:, None]) & (yy_g >= 100) & ~crag
cv.fill(rbank & (yy_g >= 104), GRASS['b'])
for _ in range(240):
    gx, gy = r(0, W - 1), r(104, H - 1)
    cv.dots([(gx, gy), (gx, gy - 1)], GRASS['r'] if r(0, 2) else GRASS['s'])
for mx, my, col, dot in ((214, 110, '#c8a878', RED['b']), (238, 106, '#c8a878', SAFF['b']), (250, 116, '#c8a878', '#e0c040')):
    o = cv.obj()
    o.part(poly([(mx, my), (mx + 18, my - 2), (mx + 22, my + 6), (mx + 3, my + 8)]), ramp(col, '#9a7a4a', '#ecd6a4'), d=1)
    o.draw()
    for k in range(14):
        cv.dots([(mx + 3 + r(0, 15), my + 1 + r(0, 5))], dot)
gh = poly([(156, 200), (176, 136), (194, 136), (204, 200)])   # ghat: stone steps from the souk down to the water
gh &= ~river
cv.fill(gh, WALL['b'])
for yk in range(138, 200, 5):
    cv.fill(gh & rect(0, yk, W, yk), WALL['s'])
    cv.fill(gh & rect(0, yk + 1, W, yk + 1), WALL['r'])
cv.fill(gh & ~shift(gh, 2, 0), '#d8c4a0')

# ---------------------------------------------------------------- the rope bridge across the river, a gnome leading a laden yak over it
bl, br = (148, 118), (204, 122)
deck = sag(bl, br, 7)
dk = blank()
for x, y in deck:
    dk |= rect(int(x), int(y), int(x), int(y) + 2)
cv.fill(dk, WOOD['b'])
for i, (x, y) in enumerate(deck):
    if i % 3 == 0:
        cv.fill(rect(int(x), int(y), int(x), int(y) + 2), WOOD['s'])
    cv.dots([(int(x), int(y) + 3)], '#4a2c1a')
hand = sag((bl[0], bl[1] - 10), (br[0], br[1] - 10), 5)
cv.fill(line([(int(x), int(y)) for x, y in hand]), '#7a4a1f')
for i in range(0, len(hand), 5):
    cv.fill(line([(int(hand[i][0]), int(hand[i][1])), (int(deck[i][0]), int(deck[i][1]))]), '#9a6b3f')
for px, py in (bl, br):
    o = cv.obj()
    o.part(rect(px - 2, py - 14, px + 1, py + 6), DARKW, d=1)
    o.draw()
    cv.dots([(px - 2, py - 15), (px + 1, py - 15)], SAFF['b'])
flag_string((bl[0] - 1, bl[1] - 14), (br[0] - 1, br[1] - 14), 6, gap=5, seed=3)
# yak (feet on the deck around x 176)
yx = 172
yy = int(sag(bl, br, 7)[yx - bl[0]][1])
o = cv.obj()
fringe = blank()
for k in range(9):
    fringe |= poly([(yx - 8 + k * 2, yy - 7), (yx - 6 + k * 2, yy - 7), (yx - 7 + k * 2, yy - 3)])
o.part(rect(yx - 6, yy - 4, yx - 5, yy) | rect(yx + 6, yy - 4, yx + 7, yy), YAK, d=0)
o.part(ell(yx - 9, yy - 17, yx + 10, yy - 5) | fringe, YAK, d=2)
o.part(ell(yx + 7, yy - 13, yx + 14, yy - 6), YAK, d=1)
o.part(ell(yx - 5, yy - 20, yx + 5, yy - 12), MAG, d=2, contour=True)   # saddle bags
o.draw()
cv.fill(rect(yx - 5, yy - 16, yx + 5, yy - 15), SAFF['b'])
cv.fill(rect(yx - 1, yy - 20, yx + 1, yy - 12), SAFF['s'])
cv.fill(ell(yx + 10, yy - 12, yx + 14, yy - 8), '#f1ece0')   # white blaze
cv.dots([(yx + 12, yy - 11)], '#2a1a10')
cv.fill(line([(yx + 9, yy - 13), (yx + 8, yy - 17), (yx + 10, yy - 18)]) | line([(yx + 13, yy - 13), (yx + 15, yy - 16), (yx + 14, yy - 18)]), '#f1ece0')
cv.dots([(yx - 10, yy - 12), (yx - 11, yy - 10), (yx - 11, yy - 9)], YAK['b'])   # tail
cv.dots([(yx + 11, yy - 5)], GOLD['r'])   # bell
gxb = 192
gyb = int(sag(bl, br, 7)[gxb - bl[0]][1])
gnome(gxb, gyb, 1, SAFF, TEAL, face=1)
cv.fill(line([(gxb - 3, gyb - 6), (yx + 13, yy - 8)]), '#4a2c1a')   # lead rope

# ---------------------------------------------------------------- the spice souk (front right)
aw = poly([(206, 128), (300, 120), (300, 138), (210, 146)])
stall_in = poly([(212, 140), (296, 134), (296, 170), (212, 172)])
cv.fill(stall_in, '#5e3a2e')
for xs_ in range(216, 294, 13):   # shelves of jars and copper pots in the shade
    for yk, col in ((150, '#d07a3a'), (160, GOLD['b'])):
        cv.fill(rect(xs_, yk, xs_ + 3, yk + 4), col if (xs_ // 13) % 2 else TEAL['b'])
        cv.dots([(xs_, yk)], SAFF['r'])
    cv.fill(rect(xs_ - 2, 155, xs_ + 10, 155) | rect(xs_ - 2, 165, xs_ + 10, 165), DARKW['b'])
o = cv.obj()
o.part(aw, MAG, d=2)
o.part(rect(208, 140, 211, 186) | rect(294, 132, 297, 184), WOOD, d=1)
o.draw()
for xs_ in range(212, 300, 12):   # saffron stripes on the magenta awning
    cv.fill(aw & rect(xs_, 0, xs_ + 5, H) & ~(dil4(~aw)), SAFF['b'])
for k in range(8):   # scalloped valance
    bx = 210 + k * 12
    by = 146 - (bx - 210) * 8 // 90
    sc = ell(bx, by - 3, bx + 11, by + 3) & rect(0, by, W, H)
    o = cv.obj()
    o.part(sc, MAG if k % 2 else SAFF, d=1)
    o.draw()
for gx_ in (220, 238, 262, 284):   # chilli and marigold garlands hanging from the awning
    gy0 = 146 - (gx_ - 210) * 8 // 90 + 3
    for t in range(6):
        c = RED['b'] if gx_ % 3 else SAFF['b']
        cv.dots([(gx_, gy0 + t * 2), (gx_ + 1, gy0 + t * 2 + 1)], c)
    cv.dots([(gx_, gy0 + 12)], '#4f9a45')
o = cv.obj()   # counter
o.part(rect(212, 168, 296, 176), WOOD, d=2)
o.draw()
for xs_ in range(216, 296, 8):
    cv.fill(rect(xs_, 170, xs_, 175), WOOD['s'])
# brass scale on the counter
o = cv.obj()
o.part(rect(269, 155, 270, 167), GOLD, d=0)
o.part(line([(260, 157), (280, 155)], 1), GOLD, d=0)
o.part(ell(256, 162, 264, 166) | ell(276, 160, 284, 164), GOLD, d=1)
o.draw()
cv.dots([(259, 161), (260, 161), (279, 159)], SAFF['b'])
# sacks: back row then front row
SPICES = [('saffron', '#d8481e', '#a8301a', '#f08a4a'), ('turmeric', '#f0b020', '#c08010', '#f8d870'), ('chilli', '#c8202a', '#8e1a20', '#e0483a'),
          ('cardamom', '#7aa04a', '#4f7a2a', '#a4c46a'), ('cumin', '#a07040', '#6a4a28', '#c89a60'), ('rose', '#c8327a', '#8e1f58', '#ec74ac')]
for i, (sx, sy, w, sp) in enumerate(((218, 176, 16, 1), (238, 174, 18, 0), (260, 176, 16, 3), (280, 174, 18, 2),
                                    (206, 190, 18, 2), (228, 188, 20, 4), (252, 190, 20, 5), (276, 188, 22, 1))):
    name, b, s, rr = SPICES[sp]
    shadow(sx - 1, sy + 13, sx + w + 2, sy + 16, '#7a5a38')
    o = cv.obj()
    o.part(rrect(sx, sy + 2, sx + w, sy + 15, 3), BURLAP, d=2)
    o.part(ell(sx - 1, sy - 1, sx + w + 1, sy + 5), ramp('#e6cc98', '#b8945c', '#f5e6c0'), d=1, contour=True)
    o.part(ell(sx + 2, sy - 5, sx + w - 2, sy + 3) & rect(0, 0, W, sy + 1), ramp(b, s, rr), d=2, contour=True)
    o.draw()
    hm = ell(sx + 2, sy - 5, sx + w - 2, sy + 3) & rect(0, 0, W, sy + 1)
    ys, xs = np.nonzero(hm)
    for k in range(8):   # spice grain texture
        j = r(0, len(xs) - 1)
        cv.dots([(int(xs[j]), int(ys[j]))], rr if k % 2 else s)
    for yk in range(sy + 6, sy + 14, 3):   # burlap weave
        cv.fill(rect(sx + 2 + (yk % 2), yk, sx + w - 2, yk) & rrect(sx, sy + 2, sx + w, sy + 15, 3), BURLAP['r'] if yk % 2 else BURLAP['s'])
    if sp == 2:
        for k in range(4):
            cv.dots([(sx + 4 + k * 3, sy - 2), (sx + 5 + k * 3, sy - 3)], '#4f9a45')
    if i == 5:   # a brass scoop stuck in the cumin
        cv.fill(line([(sx + 12, sy - 3), (sx + 18, sy - 9)], 2), GOLD['b'])
        cv.dots([(sx + 18, sy - 9)], GOLD['r'])
# the spice seller: big gnome by the sacks, holding up a scoop of saffron
gnome(197, 184, 2, MAG, SAFF, face=1)
cv.fill(rect(204, 166, 206, 169), SKIN['b'])
cv.fill(line([(205, 166), (210, 160)], 2), WOOD['b'])
cv.fill(ell(207, 154, 215, 161), GOLD['b'])
cv.fill(ell(208, 154, 214, 158), '#d8481e')
cv.dots([(209, 155), (211, 154)], '#f08a4a')
# stone mortars of the spice grinders on the ghat
for mx, my in ((168, 150), (180, 176)):
    o = cv.obj()
    o.part(rrect(mx, my, mx + 10, my + 8, 2), STONE, d=2)
    o.part(line([(mx + 6, my + 1), (mx + 11, my - 6)], 2), DARKW, d=1)
    o.draw()
    cv.fill(rect(mx + 2, my + 1, mx + 8, my + 1), '#e0702a')

# ---------------------------------------------------------------- the flower boat poled down the river
fbx, fby = 122, 182
hull = poly([(fbx - 2, fby), (fbx + 34, fby - 2), (fbx + 38, fby - 6), (fbx + 30, fby + 6), (fbx + 4, fby + 7)])
o = cv.obj()
o.part(hull, DARKW, d=2)
o.draw()
cv.fill(rect(fbx + 2, fby + 1, fbx + 32, fby + 1) & hull, SAFF['b'])
cv.fill(rect(fbx - 2, fby + 8, fbx + 34, fby + 8), WATER['r'])
o = cv.obj()   # canopy
o.part(rect(fbx + 4, fby - 14, fbx + 6, fby) | rect(fbx + 20, fby - 14, fbx + 22, fby), WOOD, d=0)
o.part(poly([(fbx + 1, fby - 14), (fbx + 25, fby - 14), (fbx + 21, fby - 19), (fbx + 5, fby - 19)]), TEAL, d=2)
o.draw()
cv.fill(rect(fbx + 2, fby - 14, fbx + 24, fby - 14), SAFF['b'])
for k in range(18):   # heaped garlands and blooms
    fx, fy = fbx + 2 + r(0, 26), fby - 2 - r(0, 4)
    c = (SAFF['b'], MAG['b'], '#f6b8cf', SAFF['r'], RED['b'])[k % 5]
    cv.fill(rect(fx, fy, fx + 1, fy + 1), c)
gnome(fbx + 32, fby - 2, 1, RED, MAG, face=1)
cv.fill(line([(fbx + 36, fby - 12), (fbx + 44, fby + 10)], 1), WOOD['s'])

# ---------------------------------------------------------------- foreground left: a tea picker gnome with a basket, marigolds, tiger moth
pgx, pgy = 66, 192
o = cv.obj()   # back basket
o.part(poly([(pgx - 12, pgy - 30), (pgx - 2, pgy - 30), (pgx - 4, pgy - 14), (pgx - 10, pgy - 14)]), WOOD, d=2)
o.draw()
for yk in range(pgy - 28, pgy - 14, 3):
    cv.fill(rect(pgx - 11, yk, pgx - 3, yk), WOOD['s'])
cv.dots([(pgx - 10, pgy - 32), (pgx - 8, pgy - 33), (pgx - 5, pgy - 32), (pgx - 7, pgy - 31)], '#7ab55c')
gnome(pgx, pgy, 2, TEAL, MAG, face=-1)
cv.fill(rect(pgx + 7, pgy - 14, pgx + 9, pgy - 12), SKIN['b'])
for fx, fy in ((6, 196), (22, 184), (40, 198), (96, 194), (110, 198), (84, 186), (12, 170), (104, 174)):   # marigold clumps
    cv.fill(ell(fx - 3, fy - 1, fx + 3, fy + 3), '#4f9a45')
    for dx, dy in ((-2, -1), (1, -2), (2, 1)):
        cv.fill(rect(fx + dx, fy + dy, fx + dx + 1, fy + dy + 1), SAFF['b'])
        cv.dots([(fx + dx, fy + dy)], SAFF['r'])
tmx, tmy = 120, 140   # the Tiger Moth
o = cv.obj()
o.part(poly([(tmx, tmy), (tmx - 10, tmy - 7), (tmx - 12, tmy + 1)]) | poly([(tmx, tmy), (tmx + 10, tmy - 7), (tmx + 12, tmy + 1)]), SAFF, d=1)
o.part(poly([(tmx, tmy + 1), (tmx - 8, tmy + 7), (tmx - 3, tmy + 8)]) | poly([(tmx, tmy + 1), (tmx + 8, tmy + 7), (tmx + 3, tmy + 8)]), MAG, d=1)
o.part(rect(tmx - 1, tmy - 3, tmx, tmy + 6), YAK, d=0)
o.draw()
for dx, dy in ((-7, -3), (-9, -1), (7, -3), (9, -1), (-4, -2), (4, -2)):
    cv.dots([(tmx + dx, tmy + dy)], '#2a1a10')
cv.dots([(tmx - 2, tmy - 5), (tmx - 3, tmy - 6), (tmx + 1, tmy - 5), (tmx + 2, tmy - 6)], '#2a1a10')
for bx, by in ((92, 120), (40, 132), (150, 96)):   # butterflies after the rain
    cv.dots([(bx, by), (bx + 2, by), (bx + 1, by + 1)], MAG['r'])
    cv.dots([(bx + 1, by)], '#2a1a10')

# rain puddles and drops on the leaves (the monsoon just passed)
for px, py in ((26, 160), (72, 134), (120, 122)):
    if not river[py, px]:
        cv.fill(ell(px, py, px + 7, py + 2), '#a8dbd3')
        cv.dots([(px + 2, py + 1)], '#ffffff')

if __name__ == '__main__':
    out = sys.argv[1] if len(sys.argv) > 1 else None
    n = save_pic(cv, 'spicepeak', out)
    print('spicepeak:', n, 'colours')
