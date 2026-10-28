"""Jigsaw picture: MAPLEWOLD (v2.0.87): game/assets/img/jigsaw/maplewold.jpg (+ -thumb). Usage: python3 -B aseprite-source/scenes-pil/jigsaw_maplewold.py [outdir]
An autumn valley: pale sky and clouds, far blue hills, a ridge of flame-coloured maples, birch grove on the left, a round-door gnome cottage with a smoking
chimney and a pumpkin patch, a winding path, a beaver pond with a lodge and dam in front, big maple on the right, leaves everywhere.
"""
import math
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
FOLIAGE = [RED, ORG, YEL, ORG, RED, GOLD]
cv = new_canvas(SKY0)
r = rnd(2024)

# ---------------------------------------------------------------- sky, clouds, far hills
cv.fill(rect(0, 18, W - 1, 80), SKY1)
cv.fill(rect(0, 46, W - 1, 80), SKY2)
for cx, cy, w in ((40, 14, 44), (150, 26, 56), (240, 12, 40), (96, 44, 36), (214, 40, 46)):   # flat-bottomed clouds
    m = ell(cx - w // 2, cy - 7, cx + w // 2, cy + 6) | ell(cx - w // 4, cy - 12, cx + w // 5, cy + 4) | ell(cx, cy - 9, cx + w // 2 - 6, cy + 5)
    m &= ~rect(0, cy + 3, W, H)
    cv.fill(m, '#ffffff')
    cv.fill(m & ~shift(m, -2, -2) & rect(0, cy - 2, W, cy + 3), '#d4e6ee')
for i in range(30):   # birds
    if i % 6 == 0:
        bx, by = r(20, 280), r(6, 40)
        cv.dots([(bx, by), (bx + 1, by - 1), (bx + 2, by), (bx + 3, by - 1), (bx + 4, by)], '#3a4a5a')
m = poly([(0, 82), (30, 62), (70, 74), (120, 54), (180, 72), (230, 56), (300, 76), (300, 90), (0, 90)])
cv.fill(m, HILL0)
cv.fill(m & ~shift(m, 3, 3), '#a9c4d6')
m = poly([(0, 90), (50, 74), (110, 86), (170, 70), (240, 84), (300, 72), (300, 100), (0, 100)])
cv.fill(m, HILL1)

# ---------------------------------------------------------------- far maple ridge (flame-coloured blobs along y 80-100)
x = -6
while x < W + 6:
    w = r(14, 24)
    rp = FOLIAGE[r(0, 5)]
    top = 78 + r(0, 12)
    o = cv.obj(outline=False)
    o.part(ell(x, top, x + w, top + w * 3 // 4 + 6), rp, d=2)
    o.draw()
    for k in range(3):
        cv.dots([(x + r(2, w - 2), top + r(2, 12))], rp['r'])
    x += w - r(2, 5)
cv.fill(rect(0, 100, W - 1, 112), '#5c8a3a')

# ---------------------------------------------------------------- meadow bands and the path
cv.fill(rect(0, 104, W - 1, H - 1), GRASS['b'])
cv.fill(rect(0, 128, W - 1, H - 1), DGRASS['b'])
for y in range(104, H):   # grass tufts everywhere
    for _ in range(3):
        gx = r(0, W - 1)
        cv.dots([(gx, y), (gx, y - 1)], GRASS['r'] if y < 128 else GRASS['b'])
path = poly([(150, 104), (172, 104), (190, 118), (176, 132), (206, 150), (214, 172), (160, 172), (150, 150), (136, 134), (140, 118)])
cv.fill(path, '#d9bf86')
cv.fill(path & ~shift(path, -2, 0), '#b8a06a')
for _ in range(40):
    px, py = r(138, 210), r(106, 170)
    if path[py, px]:
        cv.dots([(px, py)], r(0, 1) and '#c9a96e' or '#f2e4c0')

# ---------------------------------------------------------------- birch grove (left)
for bx, top, bot, w in ((6, 44, 128, 5), (22, 52, 122, 4), (36, 40, 130, 5), (50, 58, 118, 4), (64, 48, 124, 4)):
    o = cv.obj()
    o.part(rect(bx, top, bx + w, bot), BIRCH, d=2)
    o.draw()
    for yy in range(top + 4, bot - 2, 6):
        cv.fill(rect(bx + 1, yy, bx + w - 2, yy), '#3a2a1c')
        if (yy // 6) % 2:
            cv.fill(rect(bx + w - 1, yy + 2, bx + w - 1, yy + 3), '#3a2a1c')
    for k in range(3):   # yellow crowns
        rp = (YEL, GOLD, YEL)[k % 3]
        o = cv.obj()
        cx, cy = bx + 2 + (k - 1) * 9, top - 4 + (k % 2) * 6
        o.part(ell(cx - 9, cy - 7, cx + 9, cy + 9), rp, d=3)
        o.draw()
        cv.dots([(cx - 3, cy - 2), (cx + 4, cy + 3), (cx, cy + 5)], rp['r'])

# ---------------------------------------------------------------- the cottage (centre-left)
bx0, by0 = 98, 82
o = cv.obj()
o.part(rrect(bx0, by0 + 12, bx0 + 56, by0 + 46, 3), PLAST, d=3)
o.part(rect(bx0 + 40, by0 - 6, bx0 + 49, by0 + 18), STONE, d=2)   # chimney
o.draw()
for xx in range(bx0 + 40, bx0 + 50, 3):   # chimney bricks
    cv.fill(rect(xx, by0 - 4, xx + 1, by0 - 4), '#8a8474')
    cv.fill(rect(xx + 1, by0 + 2, xx + 2, by0 + 2), '#8a8474')
o = cv.obj()
o.part(poly([(bx0 - 6, by0 + 18), (bx0 + 28, by0 - 12), (bx0 + 62, by0 + 18)]), ROOF, d=3)
o.draw()
for k in range(5):   # roof tile rows
    yy = by0 - 6 + k * 5
    xa, xb = bx0 + 28 - (yy - (by0 - 12)) * 34 // 30, bx0 + 28 + (yy - (by0 - 12)) * 34 // 30
    cv.fill(line([(xa + 2, yy), (xb - 2, yy)]), '#8a2c20')
cv.fill(rect(bx0 + 24, by0 - 4, bx0 + 32, by0 + 2), '#4a2c1a')   # attic
cv.fill(rect(bx0 + 26, by0 - 2, bx0 + 30, by0), '#f5cf6a')
o = cv.obj()
o.part(ell(bx0 + 22, by0 + 26, bx0 + 36, by0 + 46), WOOD, d=3)   # round door
o.draw()
cv.fill(ell(bx0 + 26, by0 + 30, bx0 + 32, by0 + 38), '#7a4a1f')
cv.dots([(bx0 + 31, by0 + 38)], '#f5cf6a')
for wx in (bx0 + 6, bx0 + 42):   # windows
    o = cv.obj()
    o.part(rect(wx, by0 + 24, wx + 9, by0 + 34), ramp('#f5cf6a', '#e8a317', '#fff4c0'), d=2)
    o.draw()
    cv.fill(rect(wx + 4, by0 + 24, wx + 5, by0 + 34), '#4a2c1a')
    cv.fill(rect(wx, by0 + 28, wx + 9, by0 + 29), '#4a2c1a')
    cv.fill(rect(wx - 1, by0 + 35, wx + 10, by0 + 36), '#b07a3a')   # sill
    for k in range(3):
        cv.dots([(wx + 1 + k * 3, by0 + 37)], '#d6322b')   # flowers in the box
for k in range(7):   # smoke (hard puffs, drifting right)
    sx, sy = bx0 + 45 + k * 4, by0 - 10 - k * 6
    cv.fill(ell(sx - 3 - k // 2, sy - 3, sx + 3 + k // 2, sy + 3), '#f2f2f0' if k < 5 else '#e0e8ee')
# fence
for fx in range(bx0 - 22, bx0 + 90, 6):
    if bx0 + 22 <= fx <= bx0 + 38:
        continue
    cv.fill(rect(fx, by0 + 40, fx + 2, by0 + 52), WOOD['b'])
    cv.fill(rect(fx + 2, by0 + 41, fx + 2, by0 + 52), WOOD['s'])
cv.fill(rect(bx0 - 22, by0 + 43, bx0 + 90, by0 + 44), WOOD['b'])
cv.fill(rect(bx0 - 22, by0 + 49, bx0 + 90, by0 + 49), WOOD['s'])

# ---------------------------------------------------------------- pumpkin patch (front left of the path)
for px, py, s in ((22, 150, 9), (38, 160, 11), (12, 166, 8), (52, 148, 7), (62, 168, 10), (30, 178, 9), (80, 160, 8), (96, 176, 10), (110, 156, 7)):
    o = cv.obj()
    o.part(ell(px - s, py - s * 2 // 3, px + s, py + s * 2 // 3), PUMP, d=2)
    o.draw()
    cv.fill(rect(px - 1, py - s * 2 // 3 - 3, px + 1, py - s * 2 // 3), '#4f6a2a')
    cv.fill(line([(px - s // 3, py - s // 2 + 1), (px - s // 3 - 1, py + s // 2)]), '#b85a14')
    cv.fill(line([(px + s // 3, py - s // 2 + 1), (px + s // 3 + 1, py + s // 2)]), '#b85a14')
    cv.fill(line([(px + 2, py - s * 2 // 3 - 2), (px + 6, py - s * 2 // 3 - 5), (px + 8, py - s * 2 // 3 - 2)]), '#4f9a45')   # curly vine
cv.fill(line([(8, 156), (24, 163), (46, 156), (70, 164), (100, 168)]), '#4f9a45')

# ---------------------------------------------------------------- beaver pond (front right) with dam and lodge
pond = ell(150, 150, 296, 198) | rect(190, 172, 300, 199)
cv.fill(pond, WATER['b'])
cv.fill(pond & ~shift(pond, 0, 3), WATER['s'])
for _ in range(60):   # ripples
    rx, ry = r(160, 290), r(158, 196)
    if pond[ry, rx]:
        cv.fill(line([(rx, ry), (rx + r(3, 7), ry)]), '#8cc4dc')
for lx, ly in ((190, 170), (230, 164), (262, 176), (216, 186)):   # lily pads
    cv.fill(ell(lx, ly, lx + 8, ly + 3), '#4f9a45')
    cv.dots([(lx + 7, ly + 1)], WATER['b'])
    cv.dots([(lx + 3, ly - 1)], '#f08ac0')
o = cv.obj()   # lodge: a dome of sticks
o.part(ell(222, 144, 276, 188), BARK, d=3)
o.draw()
for k in range(22):
    sx, sy = r(226, 270), r(150, 184)
    cv.fill(line([(sx, sy), (sx + r(-6, 6), sy + r(1, 3))]), ('#9a6b3f', '#5c3420', '#b07a3a')[k % 3])
cv.fill(ell(244, 172, 254, 188), '#2a1a10')   # doorway
# dam of logs across the pond edge
for k in range(7):
    o = cv.obj()
    o.part(rrect(160 + k * 7, 188 - (k % 2) * 5, 176 + k * 7, 194 - (k % 2) * 5, 2), BARK, d=2)
    o.draw()
    cv.dots([(168 + k * 7, 191 - (k % 2) * 5)], '#d9a35a')
# reeds
for rx in (156, 162, 290, 284, 168):
    for h in (12, 9, 14):
        cv.fill(rect(rx, 148 - h + 10, rx, 164), '#4f6a2a')
    cv.fill(rect(rx - 1, 146, rx + 1, 150), '#7a4a1f')

# ---------------------------------------------------------------- the big maple (right)
o = cv.obj()
o.part(poly([(262, 148), (270, 74), (286, 74), (294, 148)]), BARK, d=3)
o.draw()
for yy in range(84, 144, 7):
    cv.fill(line([(272 + (yy % 3), yy), (276 + (yy % 4), yy + 4)]), BARK['s'])
for cx, cy, w, h, rp in ((238, 34, 40, 28, RED), (278, 20, 44, 30, ORG), (262, 56, 44, 30, RED), (300, 44, 36, 30, GOLD), (222, 62, 34, 24, ORG), (284, 76, 36, 24, YEL), (248, 10, 32, 22, YEL)):
    o = cv.obj()
    o.part(ell(cx - w // 2, cy - h // 2, cx + w // 2, cy + h // 2), rp, d=3)
    o.draw()
    for _ in range(6):
        cv.dots([(cx + r(-w // 3, w // 3), cy + r(-h // 3, h // 3))], rp['r'])
for _ in range(14):   # falling leaves
    lx, ly = r(180, 296), r(50, 150)
    cv.fill(rect(lx, ly, lx + 1, ly + 1), FOLIAGE[r(0, 5)]['b'])

# ---------------------------------------------------------------- leaf litter, stones, mushrooms over every open patch
for _ in range(220):
    lx, ly = r(0, W - 3), r(106, H - 3)
    if pond[ly, lx] or (150 <= lx <= 215 and 104 <= ly <= 172 and path[min(ly, H - 1), min(lx, W - 1)] and r(0, 2)):
        continue
    rp = FOLIAGE[r(0, 5)]
    cv.fill(rect(lx, ly, lx + 1, ly + 1), rp['b'])
    cv.dots([(lx, ly)], rp['r'])
for sx, sy in ((120, 140), (126, 144), (196, 134), (140, 176), (70, 134)):   # stones
    o = cv.obj()
    o.part(ell(sx, sy, sx + 8, sy + 5), STONE, d=2)
    o.draw()
for sx, sy in ((128, 150), (134, 154), (80, 146), (4, 140)):   # toadstools
    o = cv.obj()
    o.part(ell(sx - 4, sy - 5, sx + 4, sy), RED, d=2)
    o.part(rect(sx - 1, sy - 1, sx + 1, sy + 4), PLAST, d=1)
    o.draw()
    cv.dots([(sx - 2, sy - 3), (sx + 1, sy - 4)], '#ffffff')
for fx in range(2, W, 9):   # tiny wildflowers along the far meadow
    fy = r(110, 124)
    cv.dots([(fx, fy)], ('#f0b92b', '#f08ac0', '#ffffff')[fx % 3])

if __name__ == '__main__':
    out = sys.argv[1] if len(sys.argv) > 1 else None
    n = save_pic(cv, 'maplewold', out)
    print('maplewold:', n, 'colours')
