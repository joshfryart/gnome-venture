"""Jigsaw picture: THE GREATCANOPY (WCA): game/assets/img/jigsaw/greatcanopy.jpg (+ -thumb). Usage: python3 -B aseprite-source/scenes-pil/jigsaw_greatcanopy.py [outdir]
A rainforest clearing in a rainy-season shower: a grey-indigo rain sky with a rainbow, rope canopy bridges looping from a giant baobab inn (left) to a kapok
platform (right) with weaverbird nests, the red mud library with its pole-studded walls behind, a thatched pavilion where four gnomes drum the rain in
(the Drum Circle Market) with kente bunting and stalls, the Gorilla Glade among ferns, a red laterite path with puddles, yam mounds, calabash gourds
catching roof-water, Grandmother Tortoise, a loose goat, grey parrots, giant leaves with raindrops in the front corners.
"""
import sys

from jigsaw_common import *  # noqa: F401,F403

SKY0, SKY1, SKY2 = '#7f97a6', '#94abb4', '#adc2c4'
CLOUD = ramp('#c9d4d6', '#8a9aa6', '#e6ecea')
FAR0, FAR1 = '#2f6a5a', '#245446'
EM = ramp('#1f8a5a', '#14603e', '#3fb070')
EMD = ramp('#166a46', '#0f4a32', '#2a8a5a')
LEAF = ramp('#2a9a52', '#1a6a3a', '#6cc878', '#14603e')
GRASS = ramp('#3a9a50', '#2a7a40', '#6ab85a')
LAT = ramp('#b8532e', '#8a3a22', '#d9764a')
PATHC = ramp('#c8643a', '#9a4428', '#e08a58')
MUD = ramp('#c8784a', '#9a5434', '#e8a070')
BAOB = ramp('#a08a74', '#74604e', '#c4b09a')
KAPOK = ramp('#8a7f72', '#625a50', '#aaa092')
THATCH = ramp('#d9a84a', '#a8782a', '#f2d07a')
GOLD = ramp('#e8b02a', '#b07a10', '#f5d46a')
RED = ramp('#c8302a', '#8a2020', '#e8604a')
INDIGO = ramp('#3a4a8a', '#25306a', '#6a7ac0')
WOOD = ramp('#9a6b3f', '#6a4424', '#c08a50')
GOURD = ramp('#d9a35a', '#a8743a', '#f2cf8a')
SKIN = ramp('#f2c8a0', '#d9a07a', '#fff0d8')
SKIN2 = ramp('#a8683e', '#7a4a2a', '#c8885a')
SKIN3 = ramp('#7a4a2a', '#5a3420', '#a8683e')
BEARD = ramp('#f1ece0', '#c9c5bc', '#ffffff')
GOR = ramp('#3a3638', '#24201f', '#5a5456')
WATER = ramp('#7a9aa8', '#5a7a8a', '#c5d6d4')
RAIN = '#cfe0e6'
UMB = '#2a1a10'
KENTE = ('#e8b02a', '#1f8a5a', '#c8302a', '#e8b02a', '#2a1a10')
cv = new_canvas(SKY0)
r = rnd(1907)
r2 = rnd(53)


def shadow(x0, y0, x1, y1, col=None):
    cv.fill(ell(x0, y0, x1, y1), col or GRASS['s'])


def clump(cx, cy, rx, ry, n, s0=5, s1=9):
    m = blank()
    for _ in range(n):
        ex, ey, s = cx + r(-rx, rx), cy + r(-ry, ry), r(s0, s1)
        m |= ell(ex - s, ey - s * 3 // 4, ex + s, ey + s * 3 // 4)
    return m


def foliage(m, rp, d=3, specks=10, outline=True):
    o = cv.obj(outline=outline)
    o.part(m, rp, d=d)
    o.draw()
    ys, xs = np.nonzero(m)
    if not len(xs):
        return
    for _ in range(specks):   # leaf flecks: little lit leaf shapes
        i = r(0, len(xs) - 1)
        x, y = int(xs[i]), int(ys[i])
        if m[min(H - 1, y + 2), x] and m[y, min(W - 1, x + 2)]:
            cv.dots([(x, y), (x + 1, y), (x + 1, y - 1)], rp['r'])


def kente(m, x0, y0, w=3):
    """Fill a mask with a kente weave: gold base, coloured vertical strips, black ticks."""
    cv.fill(m, KENTE[0])
    for k, x in enumerate(range(x0, x0 + 80, w)):
        col = KENTE[k % 4]
        cv.fill(m & rect(x, 0, x + w - 2, H), col)
    for y in range(y0, y0 + 80, 4):
        cv.fill(m & rect(0, y, W, y) & ~shift(m, 0, 2), KENTE[4])


def sagpts(x0, y0, x1, y1, s, n=24):
    return [(x0 + (x1 - x0) * i / n, y0 + (y1 - y0) * i / n + s * 4 * (i / n) * (1 - i / n)) for i in range(n + 1)]


def gnome(gx, gy, hat, tunic, skin, lean=-5, tall=40, arm=None):
    """Standing gnome, feet at (gx, gy)."""
    shadow(gx - 9, gy - 1, gx + 10, gy + 2, LAT['s'] if gy > 150 else None)
    o = cv.obj()
    o.part(rect(gx - 6, gy - 3, gx - 2, gy) | rect(gx + 1, gy - 3, gx + 5, gy), ramp('#5c3420', '#3d2a1c', '#7a4a1f'), d=1)
    o.part(rrect(gx - 6, gy - 15, gx + 6, gy - 3, 2), tunic, d=2, contour=True)
    o.part(rect(gx - 6, gy - 7, gx + 6, gy - 6), ramp('#5c3420', '#3d2a1c'), d=0)
    o.part(poly([(gx - 6, gy - 19), (gx + 6, gy - 19), (gx + 1, gy - 6)]), BEARD, d=1, contour=True)
    o.part(rect(gx - 4, gy - 23, gx + 4, gy - 18), skin, d=1)
    o.part(poly([(gx - 7, gy - 22), (gx + 7, gy - 22), (gx + lean, gy - tall)]), hat, d=2, contour=True)
    if arm:
        o.part(arm, tunic, d=1)
    o.draw()
    cv.fill(rect(gx - 7, gy - 23, gx + 7, gy - 22), hat['s'])
    cv.dots([(gx - 2, gy - 21), (gx + 2, gy - 21)], UMB)
    cv.dots([(gx, gy - 20), (gx + 1, gy - 20)], skin['s'])
    cv.dots([(gx - 3, gy - 19), (gx + 3, gy - 19)], '#e88a7a')


def drummer(gx, gy, hat, tunic, skin, lean, hit):
    """Seated gnome behind a djembe; gy = foot of the drum."""
    shadow(gx - 9, gy - 2, gx + 9, gy + 1, LAT['s'])
    o = cv.obj()
    o.part(rrect(gx - 7, gy - 19, gx + 7, gy - 6, 2), tunic, d=2, contour=True)
    o.part(poly([(gx - 6, gy - 23), (gx + 6, gy - 23), (gx + 1, gy - 11)]), BEARD, d=1, contour=True)
    o.part(rect(gx - 4, gy - 27, gx + 4, gy - 22), skin, d=1)
    o.part(poly([(gx - 7, gy - 26), (gx + 7, gy - 26), (gx + lean, gy - 40)]), hat, d=2, contour=True)
    o.draw()
    cv.fill(rect(gx - 7, gy - 27, gx + 7, gy - 26), hat['s'])
    cv.dots([(gx - 2, gy - 25), (gx + 2, gy - 25)], UMB)
    cv.dots([(gx - 3, gy - 23), (gx + 3, gy - 23)], '#e88a7a')
    o = cv.obj()   # djembe: goblet with a pale skin head
    o.part(poly([(gx - 6, gy - 14), (gx + 6, gy - 14), (gx + 3, gy - 7), (gx + 2, gy - 4), (gx + 4, gy), (gx - 4, gy), (gx - 2, gy - 4), (gx - 3, gy - 7)]), WOOD, d=2)
    o.part(rect(gx - 6, gy - 15, gx + 6, gy - 14), ramp('#f2e4c0', '#c9a96e'), d=0)
    o.draw()
    for k in range(-5, 6, 2):   # rope lacing
        cv.dots([(gx + k * 2 // 3, gy - 12), (gx + k * 2 // 3 + 1, gy - 11)], '#f2e4c0')
    cv.fill(rect(gx - 4, gy - 9, gx + 4, gy - 9), RED['b'])
    hy = gy - 20 if hit else gy - 16   # one hand up, one striking
    cv.fill(rect(gx - 6, gy - 17, gx - 3, gy - 15), skin['b'])
    cv.fill(rect(gx + 3, hy, gx + 6, hy + 2), skin['b'])
    cv.dots([(gx - 6, gy - 15), (gx + 6, hy + 2)], skin['s'])
    if hit:
        cv.dots([(gx + 8, gy - 22), (gx + 9, gy - 23), (gx + 8, gy - 18), (gx + 10, gy - 18)], '#f5d46a')   # beat marks


# ================================================================ sky: rain clouds, rainbow, rain sheets
cv.fill(rect(0, 22, W - 1, 90), SKY1)
cv.fill(rect(0, 44, W - 1, 90), SKY2)
for i, col in enumerate(('#c8302a', '#e8843a', '#e8b02a', '#5ab05a', '#3a6ab0', '#6a4a9a')):   # a rainbow breaking through
    band = ell(96 + i * 2, 18 + i * 2, 250 - i * 2, 150 - i * 2) & ~ell(98 + i * 2, 20 + i * 2, 248 - i * 2, 148 - i * 2)
    cv.fill(band & rect(0, 0, W, 72) & ~rect(0, 0, 150, 30), col)
for cx, cy, w in ((30, 8, 60), (130, 12, 70), (220, 6, 56), (88, 30, 40), (180, 34, 46), (276, 30, 34), (10, 38, 30), (148, 50, 30)):
    m = ell(cx - w // 2, cy - 7, cx + w // 2, cy + 7) | ell(cx - w // 4, cy - 13, cx + w // 5, cy + 4) | ell(cx, cy - 10, cx + w // 2 - 6, cy + 5)
    cv.fill(m, CLOUD['b'])
    cv.fill(m & ~shift(m, -2, -3), CLOUD['s'])
    cv.fill(m & ~shift(m, 2, 2), CLOUD['r'])
    for k in range(w // 5):   # a rain sheet hanging under the cloud
        x0 = cx - w // 3 + k * 4 + r(0, 2)
        y0 = cy + 7 + r(0, 3)
        cv.fill(line([(x0, y0), (x0 - 3, y0 + r(6, 12))]), '#a2b6bc')

# ================================================================ far forest wall with palms
x = -8
while x < W + 8:
    w = r(16, 26)
    top = 54 + r(0, 12)
    o = cv.obj(outline=False)
    o.part(ell(x, top, x + w, top + w), ramp(FAR0, FAR1, '#3f7a66'), d=2)
    o.draw()
    x += w - r(3, 7)
for px, py, h in ((108, 70, 34), (196, 64, 30), (232, 74, 26), (96, 76, 22)):   # oil palms poking above the wall
    cv.fill(line([(px, py), (px + 2, py - h // 2), (px + 1, py - h)], 2), '#5a5040')
    for k in range(0, h, 3):
        cv.dots([(px + 1, py - k)], '#3d3428')
    tx, ty = px + 1, py - h
    for dx, dy in ((-12, 4), (-9, -4), (-3, -8), (4, -8), (10, -3), (12, 5), (-6, 7), (7, 7)):
        cv.fill(line([(tx, ty), (tx + dx, ty + dy)], 2), FAR1)
        cv.fill(line([(tx, ty - 1), (tx + dx, ty + dy - 1)]), '#3f7a66')
    cv.fill(ell(tx - 2, ty, tx + 2, ty + 3), '#c8502a')   # palm fruit bunch
cv.fill(rect(0, 84, W - 1, 100), FAR1)
for x in range(0, W, 3):
    cv.dots([(x, 84 + r2(0, 4)), (x + 1, 86 + r2(0, 6))], FAR0)

# ================================================================ the mud library (behind the market)
lx0 = 176
o = cv.obj()
o.part(poly([(lx0, 104), (lx0 + 4, 64), (lx0 + 34, 64), (lx0 + 38, 104)]), MUD, d=3)
o.part(poly([(lx0 + 10, 66), (lx0 + 12, 40), (lx0 + 24, 40), (lx0 + 26, 66)]), MUD, d=2)   # tower
for k in range(3):
    o.part(poly([(lx0 + 11 + k * 5, 42), (lx0 + 13 + k * 5, 34), (lx0 + 15 + k * 5, 42)]), MUD, d=1)   # pinnacles
for k in range(5):
    o.part(poly([(lx0 + 2 + k * 8, 66), (lx0 + 5 + k * 8, 58), (lx0 + 8 + k * 8, 66)]), MUD, d=1)
o.draw()
for k in range(3):
    cv.dots([(lx0 + 13 + k * 5, 33), (lx0 + 13 + k * 5, 32)], '#f1ece0')   # egg tips
for yy in range(46, 100, 9):   # toron poles sticking out of the walls
    for xx in (lx0 + 13, lx0 + 22) if yy < 64 else (lx0 + 6, lx0 + 16, lx0 + 26, lx0 + 34):
        cv.fill(rect(xx, yy, xx + 3, yy + 1), WOOD['s'])
        cv.dots([(xx + 3, yy)], WOOD['r'])
cv.fill(rrect(lx0 + 16, 48, lx0 + 20, 56, 1), '#4a2c1a')
cv.fill(rrect(lx0 + 8, 72, lx0 + 12, 80, 1), '#4a2c1a')
cv.fill(rrect(lx0 + 26, 72, lx0 + 30, 80, 1), '#4a2c1a')
cv.dots([(lx0 + 9, 73), (lx0 + 27, 73)], '#f5cf6a')
for k in range(10):   # rain-washed streaks down the plaster
    xx = lx0 + 3 + r(0, 32)
    cv.fill(rect(xx, 68 + r(0, 10), xx, 82 + r(0, 14)), MUD['s'])

# ================================================================ ground: glade grass, laterite clearing, path
gnd = rect(0, 98, W - 1, H - 1)
cv.fill(gnd, GRASS['b'])
cv.fill(rect(0, 98, W - 1, 99), GRASS['s'])
clear = ell(70, 112, 260, 160)
path = poly([(150, 150), (196, 150), (206, 168), (224, 186), (236, 199), (170, 199), (172, 184), (160, 168)])
cv.fill(clear | path, LAT['b'])
cv.fill((clear | path) & ~shift(clear | path, 0, 2), LAT['s'])
for _ in range(220):   # grass tufts (light) and earth pebbles
    x, y = r(0, W - 2), r(100, H - 2)
    if (clear | path)[y, x]:
        cv.dots([(x, y), (x + 1, y)], LAT['r'] if r(0, 2) else LAT['s'])
    else:
        cv.dots([(x, y), (x, y - 1), (x + 1, y)], GRASS['r'] if r(0, 1) else GRASS['s'])
puddles = [(184, 158, 16, 4), (196, 176, 20, 5), (182, 190, 18, 5), (120, 140, 14, 3), (214, 192, 14, 4)]
for px, py, pw, ph in puddles:
    m = ell(px - pw // 2, py - ph // 2, px + pw // 2, py + ph // 2)
    cv.fill(m, WATER['b'])
    cv.fill(m & ~shift(m, 0, 1), WATER['s'])
    cv.fill(ell(px - pw // 4, py - 1, px + pw // 4, py + 1) & ~ell(px - pw // 4 + 2, py, px + pw // 4 - 2, py), WATER['r'])   # ripple ring
    cv.dots([(px - pw // 3, py), (px + pw // 3 - 1, py - 1)], '#e6ecea')

# ================================================================ kapok tree (right) with platform, buttress roots, weaver nests
o = cv.obj()
o.part(poly([(266, 0), (290, 0), (292, 120), (300, 140), (300, 156), (234, 156), (252, 144), (264, 122)]), KAPOK, d=3)
o.part(poly([(270, 120), (248, 154), (240, 156), (262, 132)]) | poly([(286, 118), (300, 136), (300, 148)]), KAPOK, d=2)   # buttress fins
o.draw()
for yy in range(4, 150, 7):
    cv.fill(line([(270 + yy % 5, yy), (272 + yy % 4, yy + 4)]), KAPOK['s'])
    cv.dots([(282 + yy % 3, yy + 2)], KAPOK['r'])
for sx, sy in ((276, 60), (280, 92), (272, 110)):   # kapok thorns
    cv.dots([(sx, sy), (sx + 1, sy - 1)], KAPOK['s'])
cv.fill(line([(268, 18), (226, 10)], 3), KAPOK['b'])   # branch for the nests
cv.fill(line([(268, 20), (226, 12)]), KAPOK['s'])
for k, nx in enumerate((230, 238, 247, 256)):
    ny = 13 + (nx - 226) // 5
    cv.fill(rect(nx, ny, nx, ny + 3), '#a8782a')
    o = cv.obj()
    o.part(ell(nx - 3, ny + 3, nx + 3, ny + 10), THATCH, d=1)
    o.draw()
    cv.dots([(nx, ny + 9), (nx, ny + 10)], UMB)
    if k % 2:
        cv.dots([(nx + 3, ny + 7), (nx + 4, ny + 7), (nx + 4, ny + 6)], '#f0d020')   # a yellow weaverbird
        cv.dots([(nx + 5, ny + 6)], UMB)
for cx, cy, rx, ry, rp in ((262, 4, 16, 8, EM), (292, 10, 10, 10, EMD), (244, 0, 14, 6, EMD), (296, 34, 6, 10, EM)):
    foliage(clump(cx, cy, rx, ry, 8, 6, 10), rp, specks=20)
plat = rect(246, 42, 299, 45)   # platform round the trunk
o = cv.obj()
o.part(plat, WOOD, d=1)
o.part(line([(256, 46), (268, 58)], 2) | line([(296, 46), (290, 58)], 2), WOOD, d=1)
o.draw()
for xx in range(248, 300, 4):
    cv.fill(rect(xx, 34, xx, 42), WOOD['s'])
cv.fill(rect(246, 34, 299, 35), WOOD['b'])
cv.fill(rect(246, 36, 299, 36), WOOD['s'])
for k in range(4):   # ladder rungs down the trunk
    pass
for yy in range(48, 140, 6):
    cv.fill(rect(258, yy, 264, yy), '#d9a35a')
cv.fill(rect(258, 46, 258, 140) | rect(264, 46, 264, 140), WOOD['s'])

# ================================================================ the baobab inn (left)
o = cv.obj()
trunk = ell(-6, 44, 96, 160) | poly([(14, 30), (74, 30), (88, 80), (2, 80)])
trunk &= ~rect(0, 156, W, H)
o.part(trunk, BAOB, d=3)
o.draw()
for k in range(26):   # bark folds
    xx = r(4, 88)
    y0 = r(34, 120)
    seg = line([(xx, y0), (xx + r(-2, 2), y0 + r(12, 26))]) & trunk & ~shift(~trunk, 2, 0) & ~shift(~trunk, -2, 0)
    cv.fill(seg, BAOB['s'])
    cv.fill(shift(seg, -1, 0) & trunk, BAOB['r'] if k % 2 else BAOB['b'])
for bx0, by0, bx1, by1, wdt in ((24, 32, 4, 8, 6), (38, 30, 32, 2, 6), (54, 30, 64, 4, 6), (68, 32, 98, 22, 5), (16, 36, 0, 26, 5)):   # stubby root-like crown
    o = cv.obj()
    o.part(line([(bx0, by0), (bx1, by1)], wdt), BAOB, d=2)
    o.part(line([(bx1, by1), (bx1 + (bx1 - bx0) // 4, by1 - 6)], 3), BAOB, d=1)
    o.draw()
for cx, cy in ((4, 6), (32, 0), (66, 2), (8, 22), (88, 14)):
    foliage(clump(cx, cy, 6, 3, 5, 3, 5), EM, specks=6)
cv.fill(rect(20, 32, 70, 33), BAOB['s'])
# thatched porch roof, round door, round windows with warm light
o = cv.obj()
o.part(rrect(30, 126, 58, 156, 6), ramp('#5c3420', '#3d2a1c'), d=1)
o.part(ell(32, 128, 56, 160) & ~rect(0, 157, W, H), WOOD, d=3, contour=True)
o.draw()
for xx in (37, 42, 47, 52):
    cv.fill(rect(xx, 132, xx, 155), WOOD['s'])
cv.dots([(52, 144), (52, 145)], '#f5cf6a')
o = cv.obj()
o.part(poly([(20, 128), (70, 128), (62, 114), (28, 114)]), THATCH, d=2)
o.draw()
for xx in range(22, 70, 3):
    cv.fill(rect(xx, 126, xx, 129), THATCH['s'])
    cv.dots([(xx + 1, 117 + (xx % 4))], THATCH['r'])
for wx, wy, s in ((14, 92, 12), (64, 82, 12), (36, 58, 11), (70, 112, 8)):
    o = cv.obj()
    o.part(ell(wx, wy, wx + s, wy + s), ramp('#f5cf6a', '#e8a317', '#fff4c0'), d=2)
    o.draw()
    cv.fill(rect(wx + s // 2, wy, wx + s // 2, wy + s) | rect(wx, wy + s // 2, wx + s, wy + s // 2), '#4a2c1a')
    cv.fill(rect(wx - 1, wy + s + 1, wx + s + 1, wy + s + 2), WOOD['b'])
for k, (wx, wy) in enumerate(((14, 92), (64, 82))):   # flower pots: red roselle
    cv.dots([(wx + 2, wy + 12), (wx + 5, wy + 12), (wx + 8, wy + 12), (wx + 3, wy + 11)], RED['b'] if k else GOLD['b'])
# balcony with a woven indigo mat airing over the rail
o = cv.obj()
o.part(rect(2, 74, 34, 76), WOOD, d=1)
o.part(rect(6, 77, 26, 88), INDIGO, d=2)
o.draw()
for xx in range(4, 34, 4):
    cv.fill(rect(xx, 68, xx, 74), WOOD['s'])
cv.fill(rect(2, 67, 34, 68), WOOD['b'])
for yy in (80, 84):
    for xx in range(8, 26, 4):
        cv.dots([(xx, yy), (xx + 1, yy)], '#f1ece0')   # adire circles
# hanging drum sign on a bracket (no text)
cv.fill(rect(86, 96, 100, 97), WOOD['s'])
o = cv.obj()
o.part(poly([(93, 100), (101, 100), (99, 108), (100, 112), (94, 112), (95, 108)]), RED, d=1)
o.draw()
cv.fill(rect(94, 99, 100, 99), '#f2e4c0')
cv.fill(rect(96, 98, 96, 99) | rect(98, 98, 98, 99), UMB)
# split-bamboo gutter pouring into calabash gourds at the foot of the trunk
cv.fill(line([(70, 127), (84, 134)], 2), '#a4b86a')
cv.fill(line([(70, 126), (84, 133)]), '#d0d86a')
for yy in range(136, 150, 2):
    cv.dots([(85, yy), (86, yy + 1)], RAIN)
for gx0, gy0, s in ((80, 150, 9), (90, 156, 7), (72, 156, 6)):
    o = cv.obj()
    o.part(ell(gx0 - s, gy0 - s, gx0 + s, gy0 + s // 2) & ~rect(0, gy0 - s, W, gy0 - s + 2), GOURD, d=2)
    o.draw()
    cv.fill(ell(gx0 - s + 2, gy0 - s + 1, gx0 + s - 2, gy0 - s + 4), WATER['b'])
    cv.fill(rect(gx0 - s + 2, gy0 - 2, gx0 + s - 2, gy0 - 2), GOURD['s'])

# trunk texture: pale bark scars, a climbing vine, a bushbaby peeking from a knot hole, a lantern
for _ in range(9):
    sx, sy = r2(8, 80), r2(40, 118)
    m = ell(sx, sy, sx + r2(5, 9), sy + r2(3, 5)) & trunk
    cv.fill(m, BAOB['r'])
    cv.fill(m & ~shift(m, 1, 1), BAOB['s'])
vine = [(4, 150), (10, 132), (6, 116), (12, 100), (8, 84), (14, 66), (10, 50), (18, 36)]
cv.fill(line(vine, 2) & trunk, EMD['s'])
for i, (vx, vy) in enumerate(vine[1:]):
    cv.dots([(vx + 1, vy), (vx + 2, vy - 1), (vx + 2, vy), (vx + 3, vy - 1)], EM['b'] if i % 2 else LEAF['b'])
    cv.dots([(vx - 2, vy + 4), (vx - 3, vy + 3), (vx - 2, vy + 3)], EM['r'])
cv.fill(ell(52, 40, 62, 50), UMB)
cv.fill(ell(54, 43, 60, 50), '#9a7a5a')
cv.dots([(55, 45), (58, 45)], '#f5d46a')
cv.dots([(54, 42), (60, 42)], '#9a7a5a')
cv.fill(rect(86, 112, 87, 118), UMB)   # lantern under the porch edge
o = cv.obj()
o.part(rrect(83, 118, 90, 126, 1), ramp('#f5cf6a', '#e8a317', '#fff4c0'), d=1)
o.draw()
cv.fill(rect(83, 121, 90, 121), UMB)

# ================================================================ canopy bridge from the baobab crown to the kapok platform
deck = sagpts(98, 26, 248, 42, 16)
rail = sagpts(98, 16, 248, 32, 14)
cv.fill(line(rail, 1), '#5c3420')
for i in range(0, len(deck), 2):   # vertical ties
    cv.fill(line([rail[i], deck[i]]), '#7a4a1f')
plank = blank()
for i in range(len(deck) - 1):
    (ax, ay), (bx, by) = deck[i], deck[i + 1]
    for t in (0, 0.5):
        px, py = int(ax + (bx - ax) * t), int(ay + (by - ay) * t)
        plank |= rect(px, py, px + 2, py + 2)
o = cv.obj()
o.part(plank, WOOD, d=1)
o.draw()
# gnome crossing the bridge with a parcel, monkey hanging underneath
bgx, bgy = int(deck[9][0]), int(deck[9][1])
gnome(bgx, bgy - 1, GOLD, INDIGO, SKIN2, lean=-6, tall=36)
o = cv.obj()
o.part(rect(bgx + 6, bgy - 16, bgx + 13, bgy - 10), GOURD, d=1)
o.draw()
cv.fill(rect(bgx + 9, bgy - 16, bgx + 9, bgy - 10) | rect(bgx + 6, bgy - 13, bgx + 13, bgy - 13), RED['b'])
mkx, mky = int(deck[17][0]), int(deck[17][1]) + 3
o = cv.obj()
o.part(line([(mkx, mky - 2), (mkx + 2, mky + 4)], 2), ramp('#3a3030', '#24201f'), d=0)   # tail curled round the deck
o.part(ell(mkx - 3, mky + 3, mkx + 5, mky + 12), ramp('#3a3030', '#24201f', '#6a6060'), d=2)   # colobus body
o.part(ell(mkx - 2, mky + 11, mkx + 4, mky + 17), ramp('#f1ece0', '#c9c5bc', '#ffffff'), d=1)   # white face ruff
o.draw()
cv.dots([(mkx, mky + 14), (mkx + 2, mky + 14)], UMB)
cv.fill(rect(mkx - 2, mky + 16, mkx + 4, mky + 18), '#6a6060')
cv.dots([(mkx - 4, mky + 8), (mkx - 5, mky + 9), (mkx + 6, mky + 8), (mkx + 7, mky + 9)], '#24201f')

# ================================================================ kente bunting across the clearing
for (x0, y0, x1, y1, s) in ((88, 88, 136, 76, 8), (140, 76, 252, 64, 12)):
    pts = sagpts(x0, y0, x1, y1, s, 16)
    cv.fill(line(pts), '#5c3420')
    for i in range(1, len(pts) - 1):
        fx, fy = int(pts[i][0]), int(pts[i][1])
        flag = poly([(fx - 2, fy + 1), (fx + 2, fy + 1), (fx, fy + 6)])
        cv.fill(flag, KENTE[i % 4])
        cv.fill(flag & rect(0, fy + 3, W, fy + 3), KENTE[(i + 1) % 4] if i % 4 != 3 else '#e8b02a')

# ================================================================ Gorilla Glade (right middle): ferns, silverback, mother and baby
for fx, fy in ((206, 112), (228, 104), (250, 110), (214, 128), (262, 124), (240, 132), (198, 126)):   # fern fronds behind
    for dx, dy in ((-10, -6), (-6, -10), (0, -12), (6, -10), (10, -6)):
        cv.fill(line([(fx, fy), (fx + dx, fy + dy)], 2), EM['s'])
        cv.fill(line([(fx, fy - 1), (fx + dx, fy + dy - 1)]), EM['b'])
        for t in (3, 6):
            cv.dots([(fx + dx * t // 10 - 1, fy + dy * t // 10 - 2), (fx + dx * t // 10 + 1, fy + dy * t // 10 - 2)], EM['r'])
sgx, sgy = 238, 104   # silverback sitting, munching a fruit
shadow(sgx - 4, sgy + 34, sgx + 34, sgy + 38)
o = cv.obj()
o.part(ell(sgx, sgy + 8, sgx + 30, sgy + 36), GOR, d=3)   # body
o.part(ell(sgx + 4, sgy, sgx + 20, sgy + 14), GOR, d=2)   # head with crest
o.part(poly([(sgx + 8, sgy + 2), (sgx + 13, sgy - 3), (sgx + 17, sgy + 2)]), GOR, d=1)
o.part(rrect(sgx - 2, sgy + 18, sgx + 8, sgy + 36, 2), GOR, d=2)   # arm
o.part(ell(sgx + 7, sgy + 5, sgx + 17, sgy + 13), ramp('#6a6062', '#4a4446', '#8a8082'), d=1)   # face
o.draw()
saddle = ell(sgx + 14, sgy + 10, sgx + 30, sgy + 24) & ell(sgx + 1, sgy + 9, sgx + 29, sgy + 35) & ~ell(sgx + 8, sgy + 15, sgx + 26, sgy + 34)
cv.fill(saddle, '#9a9a9e')   # silver saddle across the back
cv.fill(saddle & ~shift(saddle, 1, 1), '#c4c8cc')
cv.dots([(sgx + 10, sgy + 7), (sgx + 14, sgy + 7)], '#f1ece0')
cv.dots([(sgx + 10, sgy + 8), (sgx + 14, sgy + 8)], UMB)
cv.fill(rect(sgx + 11, sgy + 11, sgx + 13, sgy + 11), '#24201f')
o = cv.obj()
o.part(ell(sgx + 2, sgy + 14, sgx + 9, sgy + 20), ramp('#e8843a', '#b85a14', '#f5b04a'), d=1)   # a forest fruit
o.draw()
cv.dots([(sgx + 5, sgy + 13)], EM['b'])
# youngster tumbling out of the ferns to pat a warden gnome's hat
ygx, ygy = 222, 134
o = cv.obj()
o.part(ell(ygx, ygy, ygx + 12, ygy + 12), GOR, d=2)
o.part(ell(ygx + 2, ygy - 7, ygx + 11, ygy + 2), GOR, d=1)
o.part(line([(ygx + 1, ygy + 3), (ygx - 6, ygy - 4)], 3), GOR, d=1)   # reaching arm
o.draw()
cv.fill(ell(ygx + 4, ygy - 4, ygx + 10, ygy + 1), '#6a6062')
cv.dots([(ygx + 5, ygy - 3), (ygx + 8, ygy - 3)], UMB)
cv.dots([(ygx + 6, ygy - 1), (ygx + 7, ygy - 1)], '#24201f')
gnome(212, 166, EM, GOLD, SKIN, lean=4, tall=38)   # the warden, standing very still

# ================================================================ market stalls (right of the pavilion, before the glade)
for sx0, cloth in ((150, 'k'), (176, 'i')):
    o = cv.obj()
    o.part(rect(sx0 + 1, 104, sx0 + 2, 132) | rect(sx0 + 22, 104, sx0 + 23, 132), WOOD, d=1)   # posts
    o.part(rect(sx0, 122, sx0 + 24, 132), WOOD, d=2)   # counter
    o.draw()
    aw = poly([(sx0 - 3, 102), (sx0 + 27, 102), (sx0 + 25, 96), (sx0 - 1, 96)])
    o = cv.obj()
    o.part(aw, GOLD, d=1)
    o.draw()
    if cloth == 'k':
        kente(aw & ~shift(~aw, 0, 1), sx0 - 3, 96)
    else:
        cv.fill(aw & ~shift(~aw, 0, 1), INDIGO['b'])
        for xx in range(sx0, sx0 + 26, 4):
            cv.dots([(xx, 98), (xx + 1, 99)], '#f1ece0')
    for xx in range(sx0 - 2, sx0 + 26, 4):   # scalloped valance
        cv.fill(ell(xx, 101, xx + 3, 104), RED['b'] if cloth == 'k' else INDIGO['s'])
    for xx in range(sx0 + 1, sx0 + 24, 2):
        cv.dots([(xx, 127)], WOOD['s'])
# goods: yams, gourds, egusi melons, folded cloth
for k, (ix, iy, kind) in enumerate(((152, 118, 'yam'), (160, 118, 'yam'), (168, 117, 'gourd'), (178, 117, 'cloth'), (186, 118, 'melon'), (193, 117, 'gourd'))):
    if kind == 'yam':
        o = cv.obj()
        o.part(ell(ix, iy, ix + 8, iy + 4), ramp('#8a5a3a', '#5c3420', '#b07a5a'), d=1)
        o.draw()
    elif kind == 'gourd':
        o = cv.obj()
        o.part(ell(ix, iy - 2, ix + 6, iy + 4) | ell(ix + 2, iy - 5, ix + 4, iy - 1), GOURD, d=1)
        o.draw()
    elif kind == 'melon':
        o = cv.obj()
        o.part(ell(ix, iy - 1, ix + 6, iy + 4), ramp('#6ab85a', '#2a7a40', '#a4d87a'), d=1)
        o.draw()
        cv.dots([(ix + 2, iy), (ix + 4, iy + 2)], '#f1ece0')
    else:
        o = cv.obj()
        o.part(rect(ix, iy, ix + 7, iy + 1), INDIGO, d=0)
        o.part(rect(ix, iy + 2, ix + 7, iy + 4), GOLD, d=1)
        o.draw()
# a cooking pot of groundnut stew steaming in the rain
o = cv.obj()
o.part(ell(208, 126, 222, 136), ramp('#3a3638', '#24201f', '#5a5456'), d=2)
o.draw()
cv.fill(ell(210, 126, 220, 129), '#c8843a')
for k, (sx, sy) in enumerate(((212, 120), (216, 114), (213, 108))):
    pm = ell(sx - 2, sy - 2, sx + 2, sy + 2)
    cv.fill(pm, '#e6ecea')
    cv.fill(pm & ~shift(pm, -1, -1), '#b8c4c6')
for k in range(3):
    cv.fill(rect(209 + k * 5, 137, 210 + k * 5, 139), '#f08a24' if k != 1 else '#e8604a')   # embers
    cv.dots([(210 + k * 5, 136)], '#f5d46a')

# ================================================================ the drum circle pavilion (focal)
pcx = 118
for px in (pcx - 30, pcx + 28):
    o = cv.obj()
    o.part(rect(px, 96, px + 2, 140), WOOD, d=1)
    o.draw()
    kente(rect(px - 1, 104, px + 3, 116), px - 1, 104)   # kente wrap on the posts
roof = poly([(pcx - 40, 100), (pcx + 38, 100), (pcx + 4, 70), (pcx - 2, 70)])
o = cv.obj()
o.part(roof, THATCH, d=3)
o.part(rect(pcx - 1, 64, pcx + 3, 70), WOOD, d=1)   # finial
o.draw()
cv.fill(ell(pcx - 2, 60, pcx + 4, 66), GOLD['b'])
cv.dots([(pcx, 61)], GOLD['r'])
for k in range(5):   # thatch courses with straw ticks
    yy = 76 + k * 5
    hw = (yy - 70) * 39 // 30 + 3
    cv.fill(line([(pcx + 1 - hw + 2, yy), (pcx + 1 + hw - 2, yy)]), THATCH['s'])
    for tx in range(pcx + 1 - hw + 3 + (k % 2) * 2, pcx + 1 + hw - 2, 4):
        cv.dots([(tx, yy + 2), (tx, yy + 3)], THATCH['s'] if k % 2 else THATCH['r'])
for xx in range(pcx - 40, pcx + 39, 3):   # ragged eave fringe dripping rain
    cv.fill(rect(xx, 100, xx + 1, 101 + (xx % 3)), THATCH['s'])
    if xx % 9 == 0:
        cv.dots([(xx, 106), (xx, 109), (xx, 113)], RAIN)
cv.fill(rect(pcx - 34, 100, pcx + 32, 100) & ~roof, THATCH['b'])
# the four drummers and the big lead drum
drummer(pcx - 16, 132, RED, ramp('#1f8a5a', '#14603e', '#3fb070'), SKIN, -4, True)
drummer(pcx + 14, 130, INDIGO, GOLD, SKIN3, 4, False)
o = cv.obj()   # lead drum on a stand
o.part(poly([(pcx - 7, 126), (pcx + 9, 126), (pcx + 6, 146), (pcx - 4, 146)]), RED, d=2)
o.part(rect(pcx - 7, 124, pcx + 9, 126), ramp('#f2e4c0', '#c9a96e'), d=0)
o.draw()
for k in range(5):
    cv.fill(line([(pcx - 6 + k * 3, 128), (pcx - 3 + k * 3, 144)]), GOLD['b'])
cv.fill(rect(pcx - 5, 136, pcx + 7, 136), UMB)
drummer(pcx - 28, 152, GOLD, RED, SKIN2, -5, False)
drummer(pcx + 26, 152, EM, INDIGO, SKIN, 5, True)
# talking drum hanging from the left post
o = cv.obj()
o.part(poly([(pcx - 34, 118), (pcx - 26, 118), (pcx - 28, 122), (pcx - 26, 126), (pcx - 34, 126), (pcx - 32, 122)]), WOOD, d=1)
o.draw()
for xx in range(pcx - 33, pcx - 26, 2):
    cv.fill(rect(xx, 119, xx, 125), '#f2e4c0')

# ================================================================ foreground left: yam mounds with climbing sticks, a gnome dashing with a gourd
for k, (mx, my) in enumerate(((10, 172), (34, 176), (58, 180), (20, 192), (46, 196), (80, 194), (104, 186))):
    m = ell(mx - 9, my - 7, mx + 9, my + 5) & ~rect(0, my + 4, W, H)
    o = cv.obj()
    o.part(m, LAT, d=2)
    o.draw()
    cv.fill(line([(mx, my - 6), (mx + 2 - k % 3, my - 24)], 1), WOOD['s'])
    for t in range(4):   # yam vine twining up the stick
        vy = my - 8 - t * 4
        cv.dots([(mx - 1, vy), (mx + 1, vy - 2)], EM['b'])
        cv.dots([(mx + 2, vy - 1), (mx + 3, vy - 2), (mx + 2, vy - 2)], EM['r'] if t % 2 else LEAF['b'])
gnome(132, 178, GOLD, RED, SKIN3, lean=-10, tall=38, arm=None)   # gnome dashing with a brimming calabash
o = cv.obj()
o.part(ell(136, 160, 148, 172) & ~rect(0, 0, W, 162), GOURD, d=2)
o.draw()
cv.fill(rect(138, 162, 146, 163), WATER['b'])
cv.fill(rect(136, 163, 139, 166), SKIN3['b'])   # hand on the rim
for k in range(4):
    cv.dots([(150 + k * 2, 160 - k * 2)], RAIN)   # water slopping over the brim

# ================================================================ foreground right: Grandmother Tortoise with listeners on stools, the loose goat
ttx, tty = 246, 166
shadow(ttx - 4, tty + 14, ttx + 38, tty + 19, GRASS['s'])
o = cv.obj()
o.part(ell(ttx + 26, tty + 4, ttx + 40, tty + 14), ramp('#9a8a5a', '#6a5e3a', '#c4b47a'), d=1)   # head
o.part(rect(ttx + 2, tty + 12, ttx + 7, tty + 18) | rect(ttx + 24, tty + 12, ttx + 29, tty + 18), ramp('#9a8a5a', '#6a5e3a'), d=1)
o.part(ell(ttx, tty - 6, ttx + 32, tty + 16) & ~rect(0, tty + 14, W, H), ramp('#7a6a3a', '#4e4428', '#a8985a'), d=3)   # domed shell
o.draw()
for hx_, hy_ in ((ttx + 8, tty), (ttx + 16, tty - 3), (ttx + 24, tty), (ttx + 12, tty + 7), (ttx + 20, tty + 7)):
    cv.fill(rrect(hx_ - 3, hy_ - 2, hx_ + 3, hy_ + 2, 1) & ~rect(0, tty + 13, W, H), '#c4a85a')
    cv.dots([(hx_ - 2, hy_ - 1)], '#e0c87a')
cv.dots([(ttx + 35, tty + 7)], UMB)
cv.dots([(ttx + 34, tty + 6), (ttx + 36, tty + 6)], '#f1ece0')   # spectacles glint
cv.fill(rect(ttx + 33, tty + 6, ttx + 37, tty + 6), '#d9a22a')
cv.fill(rect(ttx + 37, tty + 11, ttx + 39, tty + 11), UMB)
for stx in (230,):
    o = cv.obj()
    o.part(rect(stx - 4, 186, stx + 4, 188), WOOD, d=1)
    o.part(rect(stx - 3, 189, stx - 2, 194) | rect(stx + 2, 189, stx + 3, 194), WOOD, d=0)
    o.draw()
gnome(230, 186, INDIGO, GOLD, SKIN2, lean=-5, tall=34)   # a listener on a stool
# the goat that is always loose (on the path, nibbling the bunting end)
gtx, gty = 164, 168
shadow(gtx - 2, gty + 12, gtx + 20, gty + 15, LAT['s'])
o = cv.obj()
o.part(rect(gtx + 2, gty + 6, gtx + 3, gty + 13) | rect(gtx + 15, gty + 6, gtx + 16, gty + 13), ramp('#3d2a1c', '#2a1a10'), d=0)
o.part(ell(gtx, gty, gtx + 18, gty + 9), ramp('#f1ece0', '#c9c5bc', '#ffffff'), d=2)
o.part(ell(gtx + 15, gty - 6, gtx + 23, gty + 2), ramp('#f1ece0', '#c9c5bc', '#ffffff'), d=1)
o.draw()
cv.fill(ell(gtx + 4, gty + 1, gtx + 10, gty + 5), '#7a4a1f')   # brown patch
cv.dots([(gtx + 19, gty - 3)], UMB)
cv.dots([(gtx + 15, gty - 8), (gtx + 16, gty - 9), (gtx + 18, gty - 8), (gtx + 19, gty - 9)], '#6a5e3a')   # horns
cv.dots([(gtx + 21, gty + 3), (gtx + 21, gty + 4)], '#c9c5bc')   # beard

# ================================================================ giant leaves with raindrops in the front corners
def bigleaf(tip, base, wdt, rp, k=0):
    (tx, ty), (bx, by) = tip, base
    mx, my = (tx + bx) / 2, (ty + by) / 2
    nx, ny = -(by - ty), (bx - tx)
    ln = (nx * nx + ny * ny) ** .5
    nx, ny = nx / ln * wdt, ny / ln * wdt
    m = poly([(tx, ty), (mx + nx, my + ny), (bx, by), (mx - nx, my - ny)])
    m |= ell(int(mx - wdt * .8), int(my - wdt * .8), int(mx + wdt * .8), int(my + wdt * .8)) & poly([(tx, ty), (mx + nx * 1.2, my + ny * 1.2), (bx, by), (mx - nx * 1.2, my - ny * 1.2)])
    o = cv.obj()
    o.part(m, rp, d=3)
    o.draw()
    cv.fill(line([(tx, ty), (bx, by)]) & m, rp['s'])   # midrib
    for t in (0.25, 0.45, 0.65):   # veins
        vx, vy = tx + (bx - tx) * t, ty + (by - ty) * t
        cv.fill(line([(vx, vy), (vx + nx * .7 + (bx - tx) * .12, vy + ny * .7 + (by - ty) * .12)]) & m, rp['s'])
        cv.fill(line([(vx, vy), (vx - nx * .7 + (bx - tx) * .12, vy - ny * .7 + (by - ty) * .12)]) & m, rp['s'])
    ys, xs = np.nonzero(m & shift(m, 3, 3) & shift(m, -3, -3))
    for j in range(5 + k if len(xs) else 0):   # raindrops: dark crescent, pale body, white glint
        i = r2(0, len(xs) - 1)
        x, y = int(xs[i]), int(ys[i])
        cv.fill(ell(x - 1, y - 1, x + 2, y + 2), '#a9d6c8')
        cv.dots([(x + 1, y + 2), (x + 2, y + 1)], rp['d'] or rp['s'])
        cv.dots([(x, y)], '#ffffff')
    return m


bigleaf((-6, 150), (34, 204), 16, LEAF, 2)
bigleaf((34, 158), (4, 204), 11, EM)
bigleaf((114, 186), (72, 206), 7, LEAF)
bigleaf((310, 166), (280, 206), 13, LEAF, 2)
bigleaf((270, 186), (292, 208), 7, EM)
# tree frog on the left leaf
fgx, fgy = 18, 172
o = cv.obj()
o.part(ell(fgx, fgy, fgx + 8, fgy + 5), ramp('#7ad04a', '#3a9a2a', '#b8f07a'), d=1)
o.draw()
cv.dots([(fgx + 1, fgy), (fgx + 6, fgy)], '#e8604a')
cv.dots([(fgx + 1, fgy + 1), (fgx + 6, fgy + 1)], UMB)
cv.dots([(fgx - 1, fgy + 5), (fgx + 9, fgy + 5)], '#e8843a')

# ================================================================ grey parrots and a turaco in the air
for px, py, fl in ((60, 46, 1), (150, 24, -1), (226, 50, 1)):
    o = cv.obj()
    o.part(ell(px, py, px + 9, py + 5), ramp('#9aa0a6', '#6a7076', '#c4c8cc'), d=1)
    o.part(poly([(px + 3, py + 1), (px + 7, py + 1), (px + 4, py - 6 * fl)]), ramp('#8a9096', '#5a6066'), d=1)   # wing
    o.draw()
    cv.fill(rect(px - 3, py + 2, px, py + 4), RED['b'])   # red tail
    cv.dots([(px + 10, py + 2), (px + 11, py + 3)], UMB)
    cv.dots([(px + 8, py + 1)], '#f1ece0')
tux, tuy = 132, 44   # turaco: green with crimson wing flash
o = cv.obj()
o.part(ell(tux, tuy, tux + 12, tuy + 5), EM, d=1)
o.part(poly([(tux + 4, tuy + 1), (tux + 9, tuy + 1), (tux + 6, tuy - 7)]), RED, d=1)
o.part(poly([(tux + 9, tuy - 1), (tux + 12, tuy - 4), (tux + 12, tuy)]), EM, d=0)   # crest
o.draw()
cv.dots([(tux + 13, tuy + 2)], '#e8604a')

# ================================================================ rain over everything (kept off faces) and splash crowns on the ground
keep = blank()
for kx, ky in ((pcx - 16, 132), (pcx + 14, 130), (pcx - 28, 152), (pcx + 26, 152), (212, 166), (132, 178), (230, 186), (bgx, bgy)):
    keep |= rect(kx - 8, ky - 30, kx + 8, ky - 14)
keep |= rect(sgx + 4, sgy, sgx + 20, sgy + 14) | rect(ttx + 26, tty + 2, ttx + 40, tty + 14)
under = roof.copy()
under[100:140, pcx - 40:pcx + 39] = True   # dry under the pavilion
for _ in range(360):
    x, y = r2(2, W - 1), r2(0, H - 6)
    if keep[y, x] or under[y, x]:
        continue
    ln = 3 + r2(0, 3)
    pts = [(x - j // 3, y + j) for j in range(ln)]
    cv.dots(pts, RAIN if y < 98 else '#a9c4cc')
for _ in range(60):
    x, y = r2(4, W - 5), r2(104, H - 3)
    if keep[y, x] or under[y, x]:
        continue
    cv.dots([(x - 1, y - 1), (x + 1, y - 1), (x, y)], '#e6ecea')

# ================================================================ colour cap: fold the rarest colours into their nearest kept neighbour
_u, _n = np.unique(cv.px.reshape(-1, 3), axis=0, return_counts=True)
_order = np.argsort(_n)
_drop = [i for i in _order[:max(0, len(_u) - 96)] if _n[i] < 60]
_keep = np.array([i for i in range(len(_u)) if i not in set(_drop)])
for i in _drop:
    d = ((_u[_keep].astype(int) - _u[i].astype(int)) ** 2).sum(1)
    j = _keep[int(np.argmin(d))]
    cv.remap({'#%02x%02x%02x' % tuple(_u[i]): '#%02x%02x%02x' % tuple(_u[j])})

if __name__ == '__main__':
    out = sys.argv[1] if len(sys.argv) > 1 else None
    n = save_pic(cv, 'greatcanopy', out)
    print('greatcanopy:', n, 'colours')
