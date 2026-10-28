"""Jigsaw picture: MAPLEWOLD (v2.0.87): game/assets/img/jigsaw/maplewold.jpg (+ -thumb). Usage: python3 -B aseprite-source/scenes-pil/jigsaw_maplewold.py [outdir]
An autumn valley: pale sky and clouds, far blue hills with a windmill, a ridge of flame-coloured maples, birch grove on the left, a round-door gnome cottage
with a smoking chimney, woodpile and a gnome raking leaves, a pumpkin patch on tilled soil with a scarecrow, a path to the front edge, a beaver pond with a
stick lodge, a swimming beaver and a log dam, big maple on the right, leaves everywhere.
"""
import sys

from jigsaw_common import *  # noqa: F401,F403

SKY0, SKY1, SKY2 = '#a9d3e8', '#c3e2ee', '#ddeff2'
HILL0, HILL1 = '#8fb3c9', '#7aa0b8'
GRASS = ramp('#7ab55c', '#4f9a45', '#a4b86a', '#a4b86a')
DGRASS = ramp('#4f9a45', '#2f6a3a', '#7ab55c')
BARK = ramp('#7a4a1f', '#5c3420', '#9a6b3f')
BIRCH = ramp('#efe6d2', '#c9bfa8', '#ffffff', '#d9cfb8')
RED = ramp('#d6322b', '#a8241f', '#f08a24')
ORG = ramp('#e8841f', '#b85a14', '#f5b04a')
YEL = ramp('#f0b92b', '#c98a14', '#f8dc6a')
GOLD = ramp('#d9a22a', '#a8741a', '#f2d46a')
STONE = ramp('#b9b2a2', '#8a8474', '#d8d2c2')
ROOF = ramp('#b8412d', '#8a2c20', '#dc6a4a')
PLAST = ramp('#f2e4c0', '#c9a96e', '#fff4d8')
WOOD = ramp('#b07a3a', '#7a4a1f', '#d9a35a')
PUMP = ramp('#e8841f', '#b85a14', '#f5b04a')
WATER = ramp('#4f93b8', '#2f6f92', '#8cc4dc')
BLUE = ramp('#3f8fb0', '#25637d', '#a9d6ea')
BEARD = ramp('#f1ece0', '#c9c5bc', '#ffffff')
SKIN = ramp('#f2c8a0', '#d9a07a', '#fff0d8')
SOIL = ramp('#7a4a1f', '#5c3420', '#9a6b3f')
FOLIAGE = [RED, ORG, YEL, ORG, RED, GOLD]
cv = new_canvas(SKY0)
r = rnd(2024)
r2 = rnd(77)   # second stream for pass-2 details, so the approved layout drawn with r stays put


def shadow(x0, y0, x1, y1):
    """Flat ground shadow under a standing thing (hard pixels, one darker green step)."""
    cv.fill(ell(x0, y0, x1, y1), '#2f6a3a' if y0 >= 128 else '#4f9a45')


def clump(cx, cy, rx, ry, n, s0=5, s1=9):
    """Scalloped foliage mass: a union of small ellipses (reads as leaves, not a balloon)."""
    m = blank()
    for _ in range(n):
        ex, ey, s = cx + r(-rx, rx), cy + r(-ry, ry), r(s0, s1)
        m |= ell(ex - s, ey - s * 3 // 4, ex + s, ey + s * 3 // 4)
    return m


def foliage(m, rp, d=3, specks=10):
    o = cv.obj()
    o.part(m, rp, d=d)
    o.draw()
    ys, xs = np.nonzero(m)
    inner = m & shift(m, 2, 0) & shift(m, -2, 0) & shift(m, 0, 2) & shift(m, 0, -2)
    others = [f for f in FOLIAGE if f['b'] != rp['b']]
    for _ in range(specks):   # leaf flecks: LIGHT tones only (rim or a neighbouring leaf colour), never a dark that reads as a hole
        i = r(0, len(xs) - 1)
        k = r(0, 1)
        x, y = int(xs[i]), int(ys[i])
        if not inner[y, x]:
            continue
        col = rp['r'] if k else others[r2(0, len(others) - 1)]['b']
        cv.dots([(x, y), (x + 1, y), (x + 1, y - 1)], col)


# ---------------------------------------------------------------- sky, clouds, birds
cv.fill(rect(0, 18, W - 1, 80), SKY1)
cv.fill(rect(0, 46, W - 1, 80), SKY2)
for cx, cy, w in ((40, 14, 44), (150, 26, 56), (240, 12, 40), (96, 44, 36), (214, 40, 46), (118, 8, 30), (186, 54, 30), (12, 40, 26), (66, 30, 24)):
    m = ell(cx - w // 2, cy - 7, cx + w // 2, cy + 6) | ell(cx - w // 4, cy - 12, cx + w // 5, cy + 4) | ell(cx, cy - 9, cx + w // 2 - 6, cy + 5)
    m &= ~rect(0, cy + 3, W, H)
    cv.fill(m, '#ffffff')
    cv.fill(m & ~shift(m, -2, -2) & rect(0, cy - 2, W, cy + 3), '#d4e6ee')
    cv.fill(m & rect(0, cy + 3, W, cy + 3), '#c3d2e6')   # cool underside line
for bx, by in ((172, 10), (178, 13), (184, 16), (166, 13), (160, 16), (70, 50), (84, 56)):   # a V of geese + two strays
    cv.dots([(bx, by), (bx + 1, by - 1), (bx + 2, by), (bx + 3, by - 1), (bx + 4, by)], '#3a4a5a')
blx, bly = 200, 26   # a patchwork hot-air balloon drifting over the valley
env = ell(blx - 7, bly - 9, blx + 7, bly + 7) | poly([(blx - 5, bly + 4), (blx + 5, bly + 4), (blx + 2, bly + 10), (blx - 2, bly + 10)])
o = cv.obj()
o.part(env, RED, d=2)
o.part(rect(blx - 3, bly + 15, blx + 3, bly + 19), WOOD, d=1)
o.draw()
cv.fill(env & ~shift(env, 1, 1) & ~shift(env, -1, -1) & (rect(blx - 3, 0, blx - 2, H) | rect(blx + 2, 0, blx + 3, H)), YEL['b'])
cv.fill(env & rect(blx - 7, bly - 1, blx + 7, bly) & ~(dil4(~env)), '#3f8fb0')   # teal band
cv.dots([(blx - 4, bly - 6), (blx - 5, bly - 4)], '#f5b04a')   # glint
for t in (-1, 1):
    cv.fill(line([(blx + t * 2, bly + 10), (blx + t * 3, bly + 15)]), '#4a2c1a')
cv.fill(rect(blx - 2, bly + 16, blx + 2, bly + 16), '#7a4a1f')

# ---------------------------------------------------------------- far hills with tree dots and a windmill
m = poly([(0, 82), (30, 62), (70, 74), (120, 54), (180, 72), (230, 56), (300, 76), (300, 90), (0, 90)])
cv.fill(m, HILL0)
cv.fill(m & ~shift(m, 3, 3), '#a9c4d6')
x = 2
while x < W - 2:   # far copses: irregular little clumps in loose groups, with open gaps (no regular stripes)
    x = min(W - 2, x + r2(2, 7))
    if r2(0, 4) == 0:
        x += r2(6, 14)
        continue
    col = m[:, x]
    if col.any():
        ty = int(np.argmax(col)) + r2(4, 12)
        shp = ((0, 0), (1, 0), (0, 1), (1, 1), (-1, 1)) if r2(0, 2) else ((0, 0), (0, 1), (1, 1))
        cv.dots([(x + dx, ty + dy) for dx, dy in shp], '#6f93ab')
for fx0, fy0, fw in ((14, 80, 22), (150, 76, 26), (236, 72, 18)):   # a few pale stubble fields
    cv.fill(m & poly([(fx0, fy0), (fx0 + fw, fy0 - 3), (fx0 + fw + 4, fy0 + 4), (fx0 + 3, fy0 + 7)]), '#9cbccf')
wx, wy = 120, 54   # windmill on the far peak
cv.fill(poly([(wx - 3, wy + 4), (wx + 3, wy + 4), (wx + 2, wy - 6), (wx - 2, wy - 6)]), '#d8d2c2')
cv.fill(rect(wx + 1, wy - 5, wx + 2, wy + 4), '#b9b2a2')
cv.fill(poly([(wx - 3, wy - 6), (wx + 3, wy - 6), (wx, wy - 9)]), '#b8412d')
for dx, dy in ((1, 1), (-1, 1), (1, -1), (-1, -1)):
    cv.fill(line([(wx, wy - 6), (wx + dx * 6, wy - 6 + dy * 6)]), '#6a6a7a')
m = poly([(0, 90), (50, 74), (110, 86), (170, 70), (240, 84), (300, 72), (300, 100), (0, 100)])
cv.fill(m, HILL1)
x = 1
while x < W - 2:
    x = min(W - 2, x + r2(2, 6))
    col = m[:, x]
    ty = int(np.argmax(col)) + r2(2, 9)
    cv.dots([(x, ty), (x, ty - 1)] + ([(x + 1, ty)] if r2(0, 1) else []), '#6a8fa8')

# ---------------------------------------------------------------- far maple ridge
x = -6
while x < W + 6:
    w = r(14, 24)
    rp = FOLIAGE[r(0, 5)]
    top = 78 + r(0, 12)
    o = cv.obj(outline=False)
    o.part(ell(x, top, x + w, top + w * 3 // 4 + 6), rp, d=2)
    o.draw()
    for k in range(4):
        cv.dots([(x + r(2, w - 2), top + r(2, 12))], rp['r'] if k % 2 else rp['s'])
    x += w - r(2, 5)
cv.fill(rect(0, 100, W - 1, 112), '#5c8a3a')

# ---------------------------------------------------------------- meadow bands, tufts
cv.fill(rect(0, 104, W - 1, H - 1), GRASS['b'])
cv.fill(rect(0, 128, W - 1, H - 1), DGRASS['b'])
for y in range(104, H):
    for _ in range(4):
        gx = r(0, W - 1)
        if y < 128:
            cv.dots([(gx, y), (gx, y - 1)], GRASS['r'] if r(0, 2) else GRASS['s'])
        else:
            cv.dots([(gx, y), (gx, y - 1), (gx + 1, y)], GRASS['b'] if r(0, 2) else DGRASS['s'])

# ---------------------------------------------------------------- tilled pumpkin plot (front left) and the path (door to front edge)
path = poly([(121, 128), (134, 128), (142, 140), (152, 150), (164, 164), (172, 182), (178, 199), (146, 199), (144, 184), (136, 168), (124, 152), (118, 140)])
soil = poly([(0, 142), (112, 140), (130, 199), (0, 199)]) & ~dil4(dil4(path))
cv.fill(soil, SOIL['b'])
for fy in range(144, 200, 5):   # furrows: dark trench under a lit ridge
    cv.fill(soil & rect(0, fy, W, fy), SOIL['s'])
    cv.fill(soil & rect(0, fy - 2, W, fy - 2), SOIL['r'])
cv.fill(soil & ~shift(soil, 0, 2), '#3d2a1c')   # top lip of the plot
cv.fill(path, '#d9bf86')
cv.fill(path & ~shift(path, -2, 0), '#b8a06a')
cv.fill(path & ~shift(path, 2, 0), '#f2e4c0')
for sx, sy in ((126, 136), (132, 150), (142, 164), (150, 178), (158, 192)):   # stepping stones
    o = cv.obj()
    o.part(ell(sx, sy, sx + 9, sy + 5), STONE, d=2)
    o.draw()
for _ in range(50):
    px, py = r(118, 178), r(128, 199)
    if path[py, px]:
        cv.dots([(px, py)], r(0, 1) and '#c9a96e' or '#f2e4c0')

# ---------------------------------------------------------------- birch grove (left)
BIRCHES = ((50, 58, 118, 4, GOLD), (22, 52, 122, 4, ORG), (64, 48, 124, 4, YEL), (6, 44, 128, 5, YEL), (36, 40, 132, 5, GOLD))
for bx, top, bot, w, crown in BIRCHES:
    shadow(bx - 4, bot - 1, bx + w + 8, bot + 3)
    o = cv.obj()
    o.part(rect(bx, top, bx + w, bot), BIRCH, d=2)
    o.part(line([(bx + w, top + 14), (bx + w + 7, top + 6)], 2), BIRCH, d=1)   # side branch
    o.draw()
    for yy in range(top + 3, bot - 2, 5):
        ln = r(1, w - 1)
        cv.fill(rect(bx + 1, yy, bx + ln, yy), '#3a2a1c')
        if r(0, 1):
            cv.fill(rect(bx + w - 1, yy + 2, bx + w - 1, yy + 3), '#3a2a1c')
    cv.dots([(bx - 1, bot), (bx + w + 1, bot), (bx + 2, bot + 1)], DGRASS['s'])   # tufts at the foot
    foliage(clump(bx + 2, top - 4, 9, 6, 7, 5, 8), crown, specks=16)

# ---------------------------------------------------------------- the cottage (centre-left)
bx0, by0 = 98, 82
shadow(bx0 - 4, by0 + 42, bx0 + 64, by0 + 50)
o = cv.obj()
o.part(rrect(bx0, by0 + 12, bx0 + 56, by0 + 46, 3), PLAST, d=3)
o.part(rect(bx0 + 40, by0 - 6, bx0 + 49, by0 + 18), STONE, d=2)   # chimney
o.draw()
for yy in range(by0 + 20, by0 + 46, 4):   # timber lines and plaster cracks give the wall texture
    cv.fill(rect(bx0 + 2, yy, bx0 + 4, yy), '#c9a96e')
    cv.fill(rect(bx0 + 50, yy + 2, bx0 + 52, yy + 2), '#c9a96e')
cv.fill(rect(bx0 + 1, by0 + 44, bx0 + 55, by0 + 46), STONE['b'])   # stone plinth
for xx in range(bx0 + 2, bx0 + 55, 4):
    cv.dots([(xx, by0 + 45)], STONE['s'])
for xx in range(bx0 + 40, bx0 + 50, 3):   # chimney bricks
    cv.fill(rect(xx, by0 - 4, xx + 1, by0 - 4), '#8a8474')
    cv.fill(rect(xx + 1, by0 + 2, xx + 2, by0 + 2), '#8a8474')
o = cv.obj()
o.part(poly([(bx0 - 6, by0 + 18), (bx0 + 28, by0 - 12), (bx0 + 62, by0 + 18)]), ROOF, d=3)
o.draw()
for k in range(5):   # roof tile rows with staggered tile joints
    yy = by0 - 6 + k * 5
    hw = (yy - (by0 - 12)) * 34 // 30
    xa, xb = bx0 + 28 - hw, bx0 + 28 + hw
    cv.fill(line([(xa + 2, yy), (xb - 2, yy)]), '#8a2c20')
    for tx in range(xa + 4 + (k % 2) * 3, xb - 3, 6):
        cv.dots([(tx, yy - 1), (tx, yy - 2)], '#8a2c20')
cv.fill(rect(bx0 + 24, by0 - 4, bx0 + 32, by0 + 2), '#4a2c1a')   # attic
cv.fill(rect(bx0 + 26, by0 - 2, bx0 + 30, by0), '#f5cf6a')
cv.dots([(bx0 + 28, by0 - 2), (bx0 + 28, by0 - 1), (bx0 + 28, by0)], '#4a2c1a')
for k in range(9):   # moss and fallen leaves on the roof
    t = r(-20, 20)
    yy = by0 + 4 + r(0, 12)
    if abs(t) < (yy - (by0 - 12)) * 34 // 30 - 3:
        cv.fill(rect(bx0 + 28 + t, yy, bx0 + 29 + t, yy), FOLIAGE[k % 6]['b'])
o = cv.obj()
o.part(ell(bx0 + 21, by0 + 25, bx0 + 37, by0 + 46), STONE, d=2)   # stone door frame
o.part(ell(bx0 + 23, by0 + 27, bx0 + 35, by0 + 46), WOOD, d=3, contour=True)   # round door
o.draw()
for xx in (bx0 + 26, bx0 + 29, bx0 + 32):
    cv.fill(rect(xx, by0 + 29, xx, by0 + 45), '#7a4a1f')
cv.dots([(bx0 + 33, by0 + 38)], '#f5cf6a')
for wx in (bx0 + 6, bx0 + 42):   # windows
    o = cv.obj()
    o.part(rect(wx, by0 + 24, wx + 9, by0 + 34), ramp('#f5cf6a', '#e8a317', '#fff4c0'), d=2)
    o.draw()
    cv.fill(rect(wx + 4, by0 + 24, wx + 5, by0 + 34), '#4a2c1a')
    cv.fill(rect(wx, by0 + 28, wx + 9, by0 + 29), '#4a2c1a')
    cv.fill(rect(wx - 1, by0 + 35, wx + 10, by0 + 37), '#b07a3a')   # flower box
    cv.fill(rect(wx - 1, by0 + 37, wx + 10, by0 + 37), '#7a4a1f')
    for k in range(4):
        cv.dots([(wx + k * 3, by0 + 34), (wx + 1 + k * 3, by0 + 34)], ('#d6322b', '#f08ac0', '#f0b92b', '#d6322b')[k])
for k in range(7):   # smoke (hard puffs, drifting right)
    sx, sy = bx0 + 45 + k * 4, by0 - 10 - k * 6
    pm = ell(sx - 3 - k // 2, sy - 3, sx + 3 + k // 2, sy + 3)
    cv.fill(pm, '#f2f2f0' if k < 5 else '#e0e8ee')
    cv.fill(pm & ~shift(pm, -1, -1), '#c9ccd0')
# woodpile against the right wall
o = cv.obj()
logs = []
for row, n in ((0, 4), (1, 3), (2, 2)):
    for c in range(n):
        lx, ly = bx0 + 58 + c * 5 + row * 2, by0 + 40 - row * 5
        logs.append((lx, ly))
        o.part(ell(lx, ly, lx + 5, ly + 5), WOOD, d=1, contour=True)
o.draw()
for lx, ly in logs:
    cv.dots([(lx + 2, ly + 2), (lx + 3, ly + 3)], '#7a4a1f')
# fence (outlined, with a gap for the door path)
fence = blank()
for fx in list(range(bx0 - 8, bx0 + 20, 6)) + list(range(bx0 + 40, bx0 + 60, 6)):
    fence |= rect(fx, by0 + 40, fx + 2, by0 + 52)
fence |= rect(bx0 - 8, by0 + 43, bx0 + 21, by0 + 44) | rect(bx0 - 8, by0 + 48, bx0 + 21, by0 + 49)
fence |= rect(bx0 + 40, by0 + 43, bx0 + 60, by0 + 44) | rect(bx0 + 40, by0 + 48, bx0 + 60, by0 + 49)
o = cv.obj()
o.part(fence, WOOD, d=1)
o.draw()
for fx in list(range(bx0 - 8, bx0 + 20, 6)) + list(range(bx0 + 40, bx0 + 60, 6)):
    cv.dots([(fx + 1, by0 + 40)], WOOD['r'])

# ---------------------------------------------------------------- scarecrow at the back of the patch
sx = 78   # clear of the fence and the cottage corner, standing in the plot
o = cv.obj()
o.part(rect(sx - 1, 124, sx + 1, 156), WOOD, d=1)
o.part(rect(sx - 12, 134, sx + 12, 135), WOOD, d=1)
o.part(rrect(sx - 6, 132, sx + 6, 146, 1), ramp('#4f9a45', '#2f6a3a', '#7ab55c'), d=2, contour=True)   # patched shirt
o.part(ell(sx - 4, 122, sx + 4, 131), ramp('#e8c87a', '#c9a96e', '#f5e0a0'), d=2, contour=True)   # sack head
o.part(rect(sx - 8, 120, sx + 8, 121) | rrect(sx - 4, 115, sx + 4, 121, 1), ramp('#c9a96e', '#9a6b3f', '#f2e4c0'), d=1, contour=True)   # straw hat
o.draw()
cv.dots([(sx - 2, 126), (sx + 2, 126)], '#2a1a10')
cv.fill(rect(sx - 2, 129, sx + 2, 129), '#2a1a10')
cv.fill(rect(sx + 1, 138, sx + 4, 141), '#d6322b')   # patch
for dx in (-13, -12, 12, 13):
    cv.dots([(sx + dx, 136), (sx + dx, 137)], '#f5cf6a')   # straw hands
cv.dots([(sx + 9, 133), (sx + 10, 132), (sx + 11, 133)], '#2a1a10')   # crow on the arm
cv.fill(rect(sx + 9, 131, sx + 10, 132), '#2a1a10')

# ---------------------------------------------------------------- pumpkins on the plot, with leaves
for lx, ly in ((16, 146), (44, 172), (70, 150), (88, 186), (6, 186), (56, 192), (34, 154)):
    o = cv.obj()
    o.part(ell(lx - 5, ly - 3, lx + 5, ly + 4) | ell(lx - 2, ly - 5, lx + 3, ly), DGRASS, d=1, contour=False)
    o.draw()
    cv.fill(line([(lx - 3, ly), (lx + 3, ly - 1)]), DGRASS['s'])
for px, py, s in ((22, 152, 9), (40, 164, 11), (10, 172, 8), (58, 152, 7), (66, 172, 10), (28, 186, 9), (82, 162, 8), (100, 182, 10), (110, 162, 7), (48, 196, 7), (8, 196, 6), (76, 196, 8)):
    shadow(px - s + 2, py + s * 2 // 3 - 1, px + s + 2, py + s * 2 // 3 + 2)
    o = cv.obj()
    o.part(ell(px - s, py - s * 2 // 3, px + s, py + s * 2 // 3), PUMP, d=2)
    o.draw()
    cv.fill(rect(px - 1, py - s * 2 // 3 - 3, px + 1, py - s * 2 // 3), '#4f6a2a')
    cv.dots([(px + 2, py - s * 2 // 3 - 3)], '#4f6a2a')
    for t in (-1, 1):
        cv.fill(line([(px + t * s // 3, py - s // 2 + 1), (px + t * (s // 3 + 1), py + s // 2)]), '#b85a14')
    cv.dots([(px - s // 2, py - s // 3), (px - s // 2 + 1, py - s // 3)], '#f5d08a')   # glint
cv.fill(line([(4, 160), (22, 158), (34, 170), (52, 166), (72, 180), (92, 174)]), '#4f9a45')   # vines
cv.fill(line([(14, 180), (30, 178), (40, 190), (64, 186)]), '#4f9a45')

# ---------------------------------------------------------------- beaver pond (front right): lodge, beaver, duck, dam
pond = (ell(182, 148, 304, 198) | rect(250, 168, 299, 190)) & ~ell(248, 134, 314, 164)   # bank bites round the maple roots
cv.fill(pond, WATER['b'])
cv.fill(pond & ~shift(pond, 0, 3), WATER['s'])
cv.fill(dil4(pond) & ~pond, '#c9a96e')   # muddy bank line
for _ in range(80):
    rx, ry = r(184, 298), r(152, 196)
    if pond[ry, rx] and pond[ry, min(W - 1, rx + 6)]:
        cv.fill(line([(rx, ry), (rx + r(3, 6), ry)]), '#8cc4dc' if r(0, 2) else '#3f7fa4')
for lx, ly in ((196, 174), (284, 166), (212, 188)):   # lily pads
    cv.fill(ell(lx, ly, lx + 8, ly + 3), '#4f9a45')
    cv.dots([(lx + 7, ly + 1)], WATER['b'])
    cv.dots([(lx + 3, ly - 1), (lx + 4, ly - 1)], '#f08ac0')
lodge = ell(226, 160, 266, 200) & ~rect(0, 187, W, H)   # a domed stick lodge sitting on the water
o = cv.obj()
o.part(lodge, BARK, d=3)
o.draw()
for k in range(40):   # criss-cross sticks
    sx, sy = r(228, 264), r(162, 185)
    if lodge[sy, sx]:
        dx = r(-7, 7)
        cv.fill(line([(sx, sy), (sx + dx, sy + r(-2, 2))]) & lodge, ('#9a6b3f', '#5c3420', '#b07a3a', '#3d2a1c')[k % 4])
for sx, sy, dx, dy in ((229, 168, -6, -4), (244, 161, -2, -6), (258, 164, 5, -5), (264, 176, 6, -2), (235, 163, -5, -6)):   # stick ends poking out
    cv.fill(line([(sx, sy), (sx + dx, sy + dy)], 2), '#5c3420')
    cv.dots([(sx + dx, sy + dy)], '#d9a35a')
cv.fill(ell(240, 177, 252, 194) & lodge, '#2a1a10')   # doorway at the waterline
cv.fill(rect(228, 188, 264, 188) & pond, WATER['s'])   # reflection line under the dome
cv.fill(rect(232, 187, 238, 187) | rect(254, 187, 260, 187), '#8cc4dc')
# beaver swimming with a wake
bvx, bvy = 202, 164
for k in range(1, 4):
    cv.fill(line([(bvx + 8 + k * 4, bvy - 1 - k), (bvx + 10 + k * 4, bvy + 3)]), '#8cc4dc')
    cv.fill(line([(bvx + 8 + k * 4, bvy + 5 + k), (bvx + 10 + k * 4, bvy + 3)]), '#8cc4dc')
o = cv.obj()
o.part(ell(bvx, bvy - 1, bvx + 12, bvy + 6), ramp('#8a5a2a', '#5c3420', '#b07a3a'), d=2)
o.part(rect(bvx + 1, bvy - 3, bvx + 2, bvy - 1), ramp('#8a5a2a', '#5c3420'), d=0)
o.draw()
cv.dots([(bvx + 3, bvy + 1)], '#2a1a10')
cv.dots([(bvx - 1, bvy + 2), (bvx, bvy + 4), (bvx, bvy + 5)], '#2a1a10')
cv.dots([(bvx + 1, bvy + 5)], '#ffffff')
cv.fill(rect(bvx, bvy + 5, bvx + 12, bvy + 6), WATER['s'])
# duck
dkx, dky = 278, 176
o = cv.obj()
o.part(ell(dkx, dky, dkx + 11, dky + 6), ramp('#9a7a5a', '#6a5038', '#c9a98a'), d=2)
o.part(ell(dkx - 1, dky - 5, dkx + 4, dky + 1), ramp('#2f8a5a', '#1f6a40', '#5fb87a'), d=1)
o.draw()
cv.dots([(dkx - 2, dky - 2), (dkx - 3, dky - 2)], '#f0b92b')
cv.dots([(dkx + 1, dky - 3)], '#2a1a10')
cv.fill(rect(dkx, dky + 3, dkx + 11, dky + 3), '#ffffff')
cv.fill(rect(dkx - 1, dky + 6, dkx + 13, dky + 6), '#8cc4dc')
# log dam along the front edge, water trickling over it
for row in range(3):
    y0 = 189 + row * 4
    x = 204 - row * 4 + (row % 2) * 3
    while x < W + 2:
        ln = r(10, 16)
        o = cv.obj()
        o.part(rrect(x, y0, x + ln, y0 + 4, 2), BARK, d=1)
        o.draw()
        cv.fill(ell(x, y0, x + 3, y0 + 4), '#c9a96e')
        cv.dots([(x + 1, y0 + 2)], '#7a4a1f')
        x += ln + 2
for tx in (222, 247, 271, 290):
    cv.fill(rect(tx, 189, tx, 199), '#8cc4dc')
    cv.fill(rect(tx + 1, 191, tx + 1, 199), WATER['b'])
# reeds and cattails round the bank
for rx, ry in ((186, 160), (190, 164), (184, 172), (276, 156), (283, 158), (296, 152), (188, 182), (200, 186)):
    h = r(9, 14)
    cv.fill(rect(rx, ry - h, rx, ry), '#4f6a2a')
    cv.fill(line([(rx + 1, ry), (rx + 3, ry - h + 3)]), '#6a8a3a')
    cv.fill(rect(rx - 1, ry - h - 3, rx + 1, ry - h + 1), '#7a4a1f')
    cv.dots([(rx, ry - h - 4)], '#4f6a2a')

# ---------------------------------------------------------------- the big maple (right): branches first, then scalloped crown
shadow(250, 146, 300, 154)
o = cv.obj()
o.part(poly([(258, 152), (266, 140), (270, 74), (286, 74), (290, 140), (300, 150), (300, 154), (256, 154)]), BARK, d=3)
o.part(line([(274, 90), (240, 54)], 5) | line([(280, 84), (262, 40)], 4) | line([(284, 90), (300, 60)], 5) | line([(272, 100), (226, 80)], 3), BARK, d=2)
o.draw()
for yy in range(84, 148, 6):   # bark furrows
    cv.fill(line([(272 + (yy % 3), yy), (275 + (yy % 4), yy + 4)]), BARK['s'])
    cv.fill(line([(282 + (yy % 2), yy + 2), (284 + (yy % 3), yy + 5)]), BARK['s'])
cv.fill(ell(276, 112, 283, 122), '#2a1a10')   # knot hole with a squirrel peeking
cv.fill(ell(277, 115, 282, 121), '#c25a1f')
cv.dots([(278, 117), (281, 117)], '#2a1a10')
cv.dots([(277, 114), (282, 114)], '#c25a1f')
for cx, cy, rx, ry, rp in ((262, 14, 16, 10, YEL), (238, 30, 18, 12, RED), (290, 24, 14, 12, ORG), (226, 62, 16, 10, ORG), (258, 50, 18, 12, RED), (296, 52, 10, 14, GOLD), (282, 78, 14, 8, YEL), (244, 80, 12, 6, GOLD)):
    foliage(clump(cx, cy, rx, ry, 9, 6, 10), rp, specks=26)
for _ in range(22):   # falling leaves (little two-tone diamonds)
    lx, ly = r(170, 296), r(60, 145)
    rp = FOLIAGE[r(0, 5)]
    cv.dots([(lx, ly), (lx + 1, ly), (lx, ly + 1)], rp['b'])
    cv.dots([(lx + 1, ly + 1)], rp['s'])

# ---------------------------------------------------------------- mid meadow: gnome raking a leaf pile, apple basket
pile = (clump(222, 136, 7, 3, 10, 4, 7) | ell(212, 128, 232, 146)) & ~rect(0, 142, W, H)
o = cv.obj()
o.part(pile, ORG, d=2)
o.draw()
ys, xs = np.nonzero(pile)
for k in range(40):
    i = r(0, len(xs) - 1)
    cv.dots([(int(xs[i]), int(ys[i]))], FOLIAGE[k % 6]['b' if k % 3 else 'r'])
gx, gy = 204, 146   # the gnome (feet at gx, gy), drawn big enough to read in the thumbnail
shadow(gx - 9, gy - 1, gx + 10, gy + 2)
o = cv.obj()   # rake: handle from his hands down to the head at the foot of the leaf pile
o.part(line([(gx + 1, gy - 26), (gx + 19, gy - 1)], 2), WOOD, d=1)
o.part(rect(gx + 14, gy - 2, gx + 26, gy), WOOD, d=1)
o.draw()
for tx in range(gx + 15, gx + 27, 2):
    cv.dots([(tx, gy + 1)], '#4a2c1a')
o = cv.obj()
o.part(rect(gx - 7, gy - 3, gx - 2, gy) | rect(gx + 1, gy - 3, gx + 6, gy), ramp('#5c3420', '#3d2a1c', '#7a4a1f'), d=1)   # boots
o.part(rrect(gx - 7, gy - 16, gx + 7, gy - 3, 2), BLUE, d=2, contour=True)   # tunic
o.part(rect(gx - 7, gy - 7, gx + 7, gy - 6), ramp('#7a4a1f', '#5c3420'), d=0)   # belt
o.part(poly([(gx - 7, gy - 20), (gx + 7, gy - 20), (gx + 1, gy - 6)]), BEARD, d=1, contour=True)
o.part(rect(gx - 5, gy - 25, gx + 5, gy - 19), SKIN, d=1)
o.part(poly([(gx - 8, gy - 23), (gx + 8, gy - 23), (gx - 5, gy - 42)]), RED, d=2, contour=True)   # tall hat, tip leaning back
o.part(rect(gx + 5, gy - 15, gx + 9, gy - 12), BLUE, d=1)   # sleeve reaching for the rake
o.draw()
cv.fill(rect(gx - 8, gy - 24, gx + 8, gy - 23), RED['s'])   # hat brim
cv.dots([(gx - 2, gy - 22), (gx + 2, gy - 22)], '#2a1a10')
cv.dots([(gx, gy - 21), (gx + 1, gy - 21), (gx, gy - 20), (gx + 1, gy - 20)], '#e0907a')   # nose
cv.dots([(gx - 4, gy - 20), (gx + 4, gy - 20)], '#f0a0a0')   # rosy cheeks
cv.fill(rect(gx + 8, gy - 16, gx + 10, gy - 13), SKIN['b'])   # hand on the rake
cv.fill(rect(gx - 1, gy - 7, gx + 1, gy - 6), '#f5cf6a')   # belt buckle
cv.dots([(gx - 6, gy - 14), (gx - 6, gy - 13)], BLUE['r'])
# hay bales stacked by the woodpile (fills the meadow between cottage and maple)
for hx0, hy0, hx1, hy1 in ((177, 112, 194, 122), (180, 104, 192, 111)):
    o = cv.obj()
    o.part(rrect(hx0, hy0, hx1, hy1, 1), ramp('#e8c45a', '#b8902a', '#f8e08a'), d=2)
    o.draw()
    for xx in (hx0 + 4, hx1 - 4):
        cv.fill(rect(xx, hy0 + 1, xx, hy1 - 1), '#9a6b3f')   # twine
    for k in range(4):
        cv.dots([(hx0 + 2 + r2(0, hx1 - hx0 - 4), hy0 + 2 + r2(0, hy1 - hy0 - 4))], '#c99a34')
cv.dots([(176, 123), (195, 122), (179, 103), (193, 110)], '#f5d08a')   # loose straw
# a woolly sheep grazing under the maple
shx, shy = 246, 110
shadow(shx - 2, shy + 11, shx + 17, shy + 14)
o = cv.obj()
o.part(rect(shx + 2, shy + 7, shx + 3, shy + 12) | rect(shx + 12, shy + 7, shx + 13, shy + 12), ramp('#3d2a1c', '#2a1a10'), d=0)
o.part(clump(shx + 9, shy + 4, 4, 2, 7, 3, 4) | ell(shx + 3, shy, shx + 16, shy + 9), ramp('#f1ece0', '#c9c5bc', '#ffffff'), d=2)
o.part(ell(shx - 3, shy + 3, shx + 4, shy + 10), ramp('#4a3a30', '#2a1a10', '#6a5848'), d=1)
o.draw()
cv.dots([(shx - 1, shy + 5)], '#f1ece0')
cv.dots([(shx + 3, shy + 3), (shx + 4, shy + 3)], '#4a3a30')   # ear
for k in range(5):
    cv.dots([(shx + 6 + r2(0, 8), shy + 2 + r2(0, 4))], '#c9c5bc')
wbx, wby = 220, 112   # wheelbarrow of pumpkins in the upper meadow
shadow(wbx - 2, wby + 9, wbx + 22, wby + 12)
o = cv.obj()
o.part(poly([(wbx, wby), (wbx + 18, wby), (wbx + 15, wby + 7), (wbx + 3, wby + 7)]), ramp('#3f8fb0', '#25637d', '#a9d6ea'), d=2)
o.part(ell(wbx + 4, wby + 5, wbx + 10, wby + 11), BARK, d=1, contour=True)
o.part(line([(wbx + 17, wby + 3), (wbx + 24, wby + 8)], 2) | rect(wbx + 14, wby + 7, wbx + 15, wby + 10), WOOD, d=1)
o.draw()
cv.dots([(wbx + 7, wby + 8)], '#d9a35a')
for qx, s in ((wbx + 3, 4), (wbx + 9, 5), (wbx + 14, 3)):
    o = cv.obj()
    o.part(ell(qx, wby - s, qx + s * 2 - 1, wby + 1), PUMP, d=1)
    o.draw()
    cv.dots([(qx + s - 1, wby - s - 1)], '#4f6a2a')
bkx, bky = 238, 132   # apple basket
shadow(bkx - 1, bky + 8, bkx + 14, bky + 11)
o = cv.obj()
o.part(rrect(bkx, bky + 2, bkx + 12, bky + 9, 2), WOOD, d=2)
o.draw()
for xx in range(bkx + 1, bkx + 12, 2):
    cv.fill(rect(xx, bky + 3, xx, bky + 8), '#7a4a1f')
for ax, ay in ((bkx + 2, bky), (bkx + 5, bky - 1), (bkx + 8, bky), (bkx + 4, bky + 1), (bkx + 10, bky + 1)):
    cv.fill(rect(ax, ay, ax + 2, ay + 2), '#d6322b')
    cv.dots([(ax, ay)], '#f08a24')
cv.fill(rect(bkx + 15, bky + 8, bkx + 17, bky + 10), '#d6322b')   # one rolled away

# characters and props the litter must not speckle (keeps faces readable)
keep = rect(gx - 10, gy - 43, gx + 12, gy + 1) | rect(shx - 5, shy - 2, shx + 18, shy + 14) | rect(175, 102, 197, 124) | rect(68, 113, 88, 148)
# ---------------------------------------------------------------- leaf litter (small two-tone leaves), stones, toadstools
for _ in range(170):
    lx, ly = r(0, W - 3), r(106, H - 3)
    if pond[ly, lx] or path[ly, lx] or soil[ly, lx] or keep[ly, lx] or ly > 186 and lx > 196:
        continue
    rp = FOLIAGE[r(0, 5)]
    cv.dots([(lx, ly), (lx + 1, ly), (lx + 1, ly + 1)], rp['b'])
    cv.dots([(lx, ly + 1)], rp['s'])
for sx, sy in ((114, 136), (180, 140), (184, 190), (172, 150), (160, 124)):   # stones
    o = cv.obj()
    o.part(ell(sx, sy, sx + 8, sy + 5), STONE, d=2)
    o.draw()
    cv.dots([(sx + 2, sy + 1)], STONE['r'])
for sx, sy in ((186, 124), (178, 130), (190, 182), (182, 194), (4, 136), (56, 136), (44, 140)):   # toadstools
    o = cv.obj()
    o.part(ell(sx - 4, sy - 5, sx + 4, sy), RED, d=2)
    o.part(rect(sx - 1, sy - 1, sx + 1, sy + 4), PLAST, d=1)
    o.draw()
    cv.dots([(sx - 2, sy - 3), (sx + 1, sy - 4)], '#ffffff')
fx = 0
while fx < W - 3:   # tiny wildflowers along the far meadow, loosely spaced
    fx += r2(4, 11)
    fy = r(108, 126)
    c = ('#f0b92b', '#f08ac0', '#ffffff')[r2(0, 2)]
    if fx >= W - 1 or keep[fy, fx] or keep[fy + 1, fx]:
        continue
    cv.dots([(fx, fy), (fx - 1, fy + 1), (fx + 1, fy + 1)], c)
    cv.dots([(fx, fy + 1)], '#c98a14')

if __name__ == '__main__':
    out = sys.argv[1] if len(sys.argv) > 1 else None
    n = save_pic(cv, 'maplewold', out)
    print('maplewold:', n, 'colours')
