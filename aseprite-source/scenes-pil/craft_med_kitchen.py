"""Crafting area scene (variant med): KITCHEN. Usage: python3 -B aseprite-source/scenes-pil/craft_med_kitchen.py
Writes aseprite-source/craftmap/scenes/med/kitchen.png (1800 x 1200), kitchen-thumb.png (450 x 300), kitchen.json (hotspots), _hs.png check.
A cosy gnome kitchen, clean and clear (brief: claude/craftmap-scene-brief.md): domed clay bread oven, iron stove with the red soup pot,
worktable with board and bread, hanging copper pans, a barrel of produce. Calm cream wall, terracotta floor, light from the upper left.
"""
import json
import os

from jigsaw_common import *  # noqa: F401,F403
from PIL import Image, ImageDraw

NAME = 'kitchen'
OUTDIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'craftmap', 'scenes', 'med')

WALL, WALL2, WALL3 = '#f2dcb4', '#ead0a2', '#e2c290'
TILE, TILE2, GROUT = '#e8a86e', '#e09c62', '#c98450'
FLOOR, FLOOR2, FGROUT, FSHADOW = '#b8583a', '#ac4e33', '#8a3a28', '#93422c'
BEAM = ramp('#8a5a2a', '#5c3420', '#b07a3a')
CLAY = ramp('#d9804a', '#b05a30', '#f0a868', '#c26a3c')
STONE = ramp('#b9a68e', '#8a7a66', '#d8c8b0')
IRON = ramp('#5a4650', '#3a2a34', '#7a6670')
RED = ramp('#d6322b', '#a8241f', '#f08a24', '#b8302a')
GOLD = ramp('#e8a317', '#b07a10', '#f5cf6a')
WOOD = ramp('#b07a3a', '#7a4a1f', '#d9a35a', '#8a5a2a')
BOARD = ramp('#d9a35a', '#b07a3a', '#f2c87a')
BREAD = ramp('#d0883a', '#9a5a24', '#f2c06a')
COPPER = ramp('#d9803a', '#a8562a', '#f5b070', '#b8602e')
GREEN = ramp('#7ab55c', '#4f9a45', '#a4c86a')
ORANGE = ramp('#f08a24', '#c86414', '#f5b04a')
FIRE1, FIRE2, FIRE3, SOOT = '#f08a24', '#f5cf6a', '#fff4c8', '#3d2014'
STEAM, STEAM2 = '#fffaf0', '#e8d6b8'

FY = 164   # floor line (back edge of the floor)
cv = new_canvas(WALL)
r = rnd(31)


def draw(*parts, **kw):
    o = cv.obj(**kw)
    for p in parts:
        o.part(*p[:2], **(p[2] if len(p) > 2 else {}))
    return o.draw()


def shadow(x0, y0, x1, y1):
    cv.fill(ell(x0, y0, x1, y1), FSHADOW)


# ---------------------------------------------------------------- room: plaster wall, tiled dado, terracotta floor, beam
for _ in range(14):   # a few soft plaster patches so the wall is calm but not dead flat
    x, y = r(4, 290), r(12, 100)
    cv.fill(rrect(x, y, x + r(6, 12), y + r(2, 4), 1), WALL2)
cv.fill(rect(0, 0, W - 1, 7), BEAM['b'])
cv.fill(rect(0, 6, W - 1, 7), BEAM['s'])
cv.fill(rect(0, 0, W - 1, 0), BEAM['r'])
for x in range(10, W, 40):
    cv.fill(rect(x, 2, x + 1, 4), BEAM['s'])
cv.fill(rect(0, 8, W - 1, 8), WALL3)   # beam shadow on the wall
cv.fill(rect(0, 120, W - 1, FY - 1), TILE)
for y in range(120, FY, 8):
    cv.fill(rect(0, y, W - 1, y), GROUT)
    for x in range(((y - 120) // 8 % 2) * 8, W, 16):
        cv.fill(rect(x, y, x, y + 7), GROUT)
        cv.fill(rect(x + 1, y + 1, x + 15, y + 1), '#f0bc88')   # lit top edge of each tile
cv.fill(rect(0, 116, W - 1, 119), WOOD['b'])   # dado rail
cv.fill(rect(0, 116, W - 1, 116), WOOD['r'])
cv.fill(rect(0, 119, W - 1, 119), WOOD['s'])
cv.fill(rect(0, FY, W - 1, H - 1), FLOOR)
for y in range(FY, H, 12):
    off = ((y - FY) // 12 % 2) * 12
    for x in range(-24 + off, W, 24):
        cv.fill(rect(x + 1, y + 1, x + 11, y + 11), FLOOR2)
    cv.fill(rect(0, y, W - 1, y), FGROUT)
cv.fill(rect(0, FY, W - 1, FY + 1), FGROUT)

rug = ell(70, 170, 190, 197)
for k, col in enumerate(('#c8643c', '#d9804a', '#c8643c', '#e09c62')):
    cv.fill(ell(70 + k * 11, 170 + k * 3, 190 - k * 11, 197 - k * 3), col)
cv.fill(rug & ~shift(rug, -1, -1), '#93422c')   # rug sits flat: one dark lower edge, no outline

# ---------------------------------------------------------------- 1 domed clay bread oven (left)
ox0, ox1 = 8, 76
shadow(ox0 - 2, FY - 3, ox1 + 8, FY + 6)
dome = ell(ox0 + 1, 64, ox1 - 1, 184) & rect(0, 0, W, 124)
base = rrect(ox0, 122, ox1, FY, 1)
flue = rect(36, 30, 48, 70)
draw((flue, CLAY, dict(d=2)), (dome, CLAY, dict(d=3)), (base, STONE, dict(d=2, contour=True)))
cv.fill(rect(35, 30, 49, 33), CLAY['s'])   # flue cap
cv.fill(rect(35, 30, 49, 30), CLAY['r'])
for y in (42, 52):
    cv.fill(rect(38, y, 46, y), CLAY['s'])
for (x, y) in ((22, 80), (30, 72), (54, 74), (64, 86), (14, 98), (66, 104), (16, 112)):   # clay dabs
    cv.fill(rect(x, y, x + 3, y), CLAY['bo'])
for y in (131, 141, 151):   # stone courses of the base
    cv.fill(rect(ox0 + 1, y, ox1 - 1, y), STONE['s'])
    for x in range(ox0 + 6 + (y // 10 % 2) * 6, ox1 - 2, 12):
        cv.fill(rect(x, y + 1, x, y + 9), STONE['s'])
mouth = ell(24, 90, 60, 152) & rect(0, 0, W, 122)
arch = dil4(dil4(mouth)) & ~mouth & rect(0, 0, W, 122)
cv.fill(arch, '#a84a2c')
for (x, y) in ((23, 112), (25, 101), (31, 92), (42, 88), (53, 92), (59, 101), (61, 112)):
    cv.fill(rect(x - 1, y - 1, x, y), '#f0a868')   # arch brick highlights
cv.fill(mouth, SOOT)
fl = poly([(28, 121), (32, 106), (36, 113), (41, 98), (46, 111), (50, 103), (55, 121)])
cv.fill(fl, FIRE1)
cv.fill(poly([(33, 121), (37, 110), (41, 104), (45, 114), (50, 121)]), FIRE2)
cv.fill(poly([(38, 121), (41, 113), (44, 121)]), FIRE3)
draw((rrect(26, 117, 58, 121, 1), WOOD, dict(d=1)), outline=False)   # log ends glowing on the hearth
cv.fill(rect(28, 118, 56, 118), '#5c3420')
cv.fill(rect(20, 122, 64, 125), STONE['r'])   # hearth sill
cv.fill(rect(20, 125, 64, 125), STONE['s'])

# ---------------------------------------------------------------- 2 iron stove with the red soup pot (centre left)
sx0, sx1 = 92, 148
shadow(sx0 - 2, FY - 2, sx1 + 8, FY + 5)
pipe = rect(136, 8, 143, 104)
body = rrect(sx0, 112, sx1, FY - 6, 2)
legs = rect(sx0 + 3, FY - 6, sx0 + 7, FY) | rect(sx1 - 7, FY - 6, sx1 - 3, FY)
top = rect(sx0 - 3, 106, sx1 + 3, 112)
draw((pipe, IRON, dict(d=2)), (legs, IRON, dict(d=1)), (body, IRON, dict(d=3)), (top, IRON, dict(d=2, contour=True)))
cv.fill(rect(sx0 - 3, 106, sx1 + 3, 106), IRON['r'])
for y in (40, 70):
    cv.fill(rect(135, y, 144, y + 2), IRON['s'])   # pipe collars
    cv.fill(rect(135, y, 144, y), IRON['r'])
door = rrect(sx0 + 8, 120, sx0 + 32, FY - 12, 1)
cv.fill(door, '#2a1a20')
cv.fill(door & ~shift(door, 1, 1), IRON['r'])
grill = rect(sx0 + 11, 124, sx0 + 29, 136)
cv.fill(grill, FIRE1)
cv.fill(rect(sx0 + 13, 130, sx0 + 27, 136), FIRE2)
for x in range(sx0 + 13, sx0 + 29, 4):
    cv.fill(rect(x, 124, x + 1, 136), '#2a1a20')
cv.fill(rect(sx0 + 36, 124, sx0 + 50, 136), '#4a3640')   # oven door (right)
cv.fill(rect(sx0 + 36, 124, sx0 + 50, 124), IRON['r'])
cv.fill(rect(sx0 + 40, 129, sx0 + 46, 130), GOLD['b'])   # brass handle
cv.fill(rect(sx0 + 40, 129, sx0 + 46, 129), GOLD['r'])
cv.fill(rect(sx0 + 22, 141, sx0 + 26, 142), GOLD['b'])   # door latch
# the pot
px0, px1 = 96, 134
pot = rrect(px0, 80, px1, 106, 4)
ears = rect(px0 - 5, 86, px0, 91) | rect(px1, 86, px1 + 5, 91)
rim = rrect(px0 - 2, 76, px1 + 2, 82, 1)
spoon = line([(108, 80), (98, 54)], 3) | ell(95, 50, 102, 57)
draw((ears, IRON, dict(d=1)), (pot, RED, dict(d=3)), (rim, RED, dict(d=2, contour=True)))
cv.fill(rect(px0, 79, px1, 80), '#7a1a18')   # soup well
cv.fill(rect(px0 + 2, 78, px1 - 2, 79), ORANGE['b'])
cv.fill(rect(px0 + 2, 78, px1 - 12, 78), ORANGE['r'])
for x in range(px0 + 2, px1 - 1, 3):   # gold stitched band (Stitched Toy seam)
    cv.fill(rect(x, 88, x + 1, 88), GOLD['r'])
cv.fill(rect(px0 + 5, 84, px0 + 7, 85), '#ff9158')   # enamel gloss comma
cv.dots([(px0 + 5, 86), (px0 + 4, 87)], '#ff9158')
cv.dots([(px0 + 6, 84)], '#ffc27a')
draw((spoon, WOOD, dict(d=1)))
cv.fill(rect(108, 80, 112, 80), ORANGE['b'])
m = blank()
for (cx, cy, s) in ((114, 68, 6), (119, 60, 6), (123, 51, 6), (119, 42, 5), (124, 34, 4)):   # one curling steam plume, drifting up and right
    m |= ell(cx - s, cy - s + 1, cx + s, cy + s - 1)
cv.fill(m, STEAM)
cv.fill(m & ~shift(m, -1, -1), STEAM2)

# ---------------------------------------------------------------- 3 worktable with board and bread (centre right)
tx0, tx1 = 158, 240
shadow(tx0 - 2, FY - 2, tx1 + 8, FY + 6)
legs = rect(tx0 + 4, 120, tx0 + 10, FY) | rect(tx1 - 10, 120, tx1 - 4, FY)
stretch = rect(tx0 + 10, 148, tx1 - 10, 151)
topm = rrect(tx0, 112, tx1, 120, 1)
draw((legs | stretch, WOOD, dict(d=2)), (topm, WOOD, dict(d=2, contour=True)))
cv.fill(rect(tx0 + 1, 116, tx1 - 1, 116), WOOD['bo'])   # plank seam on the table edge
cv.fill(rect(tx0 + 1, 112, tx1 - 1, 112), WOOD['r'])
draw((rrect(162, 105, 204, 111, 1), BOARD, dict(d=2)), (rect(156, 107, 162, 109), BOARD, dict(d=1)))   # cutting board + handle
cv.dots([(158, 108)], WOOD['s'])
loaf = ell(166, 80, 200, 128) & rect(0, 0, W, 105)
draw((loaf, BREAD, dict(d=3)))
for k in range(3):   # slashes on the loaf
    cv.fill(line([(173 + k * 7, 92 - (k == 1) * 2), (178 + k * 7, 88 - (k == 1) * 2)], 2), BREAD['s'])
    cv.fill(line([(173 + k * 7, 91 - (k == 1) * 2), (178 + k * 7, 87 - (k == 1) * 2)]), BREAD['r'])
CREAM = ramp('#f2e4c0', '#d9bf8e', '#fff3c8')
dough = ell(212, 82, 236, 100)
bowl = (ell(206, 78, 242, 122) & rect(0, 94, W, H)) | rrect(205, 92, 243, 96, 1)
draw((dough, CREAM, dict(d=2)))
cv.fill(rect(219, 85, 222, 86), '#fff3c8')
draw((line([(230, 92), (241, 78)], 3) | ell(238, 72, 245, 80), WOOD, dict(d=1)))   # spoon in the dough
draw((bowl, CREAM, dict(d=3)), (rect(208, 100, 240, 103) & bowl, RED, dict(d=0)))
cv.fill(rect(206, 92, 242, 92), '#fff3c8')
cv.dots([(210, 106), (210, 107), (211, 108)], '#fff3c8')

# ---------------------------------------------------------------- 4 hanging pan rack (above the table)
chain = rect(168, 8, 169, 18) | rect(242, 8, 243, 18)
rail = rect(162, 18, 250, 21)
hooks = blank()
for hxp in (179, 205, 227, 245):
    hooks |= rect(hxp, 22, hxp + 1, 25)
draw((chain | hooks, IRON, dict(d=0)), (rail, IRON, dict(d=1)))
cv.fill(rect(162, 18, 250, 18), IRON['r'])
# frying pan
draw((rect(178, 25, 181, 40), IRON, dict(d=1)), (ell(164, 36, 196, 68), COPPER, dict(d=3)))
inner = ell(170, 42, 190, 62)
cv.fill(inner, COPPER['s'])
cv.fill(inner & ~shift(inner, 2, 2), COPPER['bo'])
cv.fill(rect(170, 44, 172, 45) | rect(169, 46, 170, 48), COPPER['r'])
cv.dots([(171, 44)], '#ffc27a')
# ladle
draw((rect(204, 25, 206, 54), IRON, dict(d=1)), (ell(198, 50, 212, 66) & rect(0, 56, W, H), IRON, dict(d=2)))
# saucepan
sp = rrect(216, 38, 240, 60, 5) | rect(216, 38, 240, 50)
draw((rect(226, 25, 229, 35), COPPER, dict(d=1)), (sp, COPPER, dict(d=3)), (rect(214, 35, 242, 38), COPPER, dict(d=1, contour=True)))
cv.fill(rect(219, 42, 221, 43) | rect(219, 44, 219, 47), COPPER['r'])
# wooden spoon pair
draw((line([(246, 25), (246, 48)], 2) | ell(242, 46, 250, 58), WOOD, dict(d=1)))

# ---------------------------------------------------------------- 5 barrel of produce (right)
bx0, bx1 = 252, 296
BT, BB = 132, 190
shadow(bx0 - 2, BB - 4, bx1 + 4, BB + 4)
barrel = (rrect(bx0 + 3, BT, bx1 - 3, BB, 3) | ell(bx0, BT + 4, bx1, BB - 4)) & rect(0, BT, W, BB)
produce = blank()
apples = ((262, 100), (272, 96), (282, 100), (266, 106), (278, 106))
draw((barrel, WOOD, dict(d=3)))
for x in range(bx0 + 7, bx1 - 4, 7):
    cv.fill(rect(x, BT + 1, x, BB - 2) & barrel, WOOD['s'])
for y in (BT + 9, BB - 14):   # iron hoops
    hm = rect(0, y, W, y + 3) & barrel
    cv.fill(hm, IRON['b'])
    cv.fill(hm & rect(0, y, W, y), IRON['r'])
cv.fill(rect(bx0 + 4, BT, bx1 - 4, BT + 2), '#5c3420')
# cabbage, carrots, apples heaped on top
for (ax, ay) in ((256, 112), (264, 106)):
    car = poly([(ax, ay), (ax + 7, ay - 2), (ax + 12, ay + 22), (ax + 9, ay + 23)])
    cv.fill(rect(ax + 1, ay - 9, ax + 2, ay - 1) | rect(ax + 4, ay - 10, ax + 5, ay - 2) | rect(ax - 2, ay - 6, ax - 1, ay - 1), GREEN['s'])
    draw((car, ORANGE, dict(d=1)))
    for k in range(2):
        cv.fill(rect(ax + 4 + k * 2, ay + 6 + k * 6, ax + 6 + k * 2, ay + 6 + k * 6), ORANGE['s'])
draw((ell(272, 104, 296, 132), GREEN, dict(d=3)))
cv.fill(line([(285, 108), (285, 128)]), GREEN['s'])
cv.fill(line([(279, 112), (284, 124)]), GREEN['s'])
cv.fill(line([(291, 112), (287, 124)]), GREEN['s'])
for (ax, ay) in ((256, 120), (266, 118)):
    draw((ell(ax, ay, ax + 11, ay + 11), RED, dict(d=2)))
    cv.dots([(ax + 2, ay + 3), (ax + 3, ay + 2)], '#ff9158')
    cv.dots([(ax + 5, ay - 2), (ax + 5, ay - 1), (ax + 6, ay - 3)], '#5c3420')

HOTSPOTS = [
    ('oven', 'Bread oven', 4, 26, 80, 142),
    ('stove', 'Stove', 86, 26, 66, 140),
    ('table', 'Worktable', 154, 70, 94, 98),
    ('rack', 'Pan rack', 158, 10, 94, 60),
    ('barrel', 'Produce barrel', 250, 94, 50, 104),
]


def save(cv, name, hotspots):
    os.makedirs(OUTDIR, exist_ok=True)
    im = Image.fromarray(cv.px, 'RGB').resize((W * SCALE, H * SCALE), Image.NEAREST)
    im.save(os.path.join(OUTDIR, name + '.png'), optimize=True)
    im.resize((450, 300), Image.NEAREST).save(os.path.join(OUTDIR, name + '-thumb.png'), optimize=True)
    hs = [dict(id=i, label=lb, x=x, y=y, w=w, h=h) for (i, lb, x, y, w, h) in hotspots]
    with open(os.path.join(OUTDIR, name + '.json'), 'w') as f:
        json.dump(dict(scene=name, w=W, h=H, hotspots=hs), f, indent=1)
    chk = im.copy()
    d = ImageDraw.Draw(chk)
    for a in hs:   # check: rects in range, min size, no overlap
        assert a['w'] >= 37 and a['h'] >= 37 and a['x'] >= 0 and a['y'] >= 0 and a['x'] + a['w'] <= W and a['y'] + a['h'] <= H, a
        for b in hs:
            if a is not b:
                assert a['x'] + a['w'] <= b['x'] or b['x'] + b['w'] <= a['x'] or a['y'] + a['h'] <= b['y'] or b['y'] + b['h'] <= a['y'], (a, b)
        d.rectangle([a['x'] * SCALE, a['y'] * SCALE, (a['x'] + a['w']) * SCALE - 1, (a['y'] + a['h']) * SCALE - 1], outline=(255, 0, 255), width=6)
    chk.save(os.path.join(OUTDIR, '_hs-' + name + '.png'))
    return cv.colours()


if __name__ == '__main__':
    print(NAME + ':', save(cv, NAME, HOTSPOTS), 'colours')
