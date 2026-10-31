"""Crafting area scene: KITCHEN (variant imp). Usage: python3 -B aseprite-source/scenes-pil/craft_imp_kitchen.py [outdir]
Writes aseprite-source/craftmap/scenes/imp/kitchen.png (1800 x 1200), kitchen-thumb.png (450 x 300), kitchen.json (hotspots) and kitchen_hs.png.
Brief: claude/craftmap-scene-brief.md. Clean and clear, five big tap targets on a calm cream wall:
hero = black iron stove with the red stew pot (centre, framed by a tiled alcove); left = brick bread oven built into the wall
over a barrel of produce; right = a rack of hanging copper pans over the worktable with a loaf, board and mixing bowl.
"""
import json
import os
import sys

from jigsaw_common import *  # noqa: F401,F403
from PIL import Image, ImageDraw

NAME = 'kitchen'
OUTDIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'craftmap', 'scenes', 'imp')


def save_scene(cv, name, hotspots, outdir=None):
    """<name>.png (6x nearest), <name>-thumb.png (450 x 300), <name>.json, and <name>_hs.png with the hotspot rects."""
    outdir = outdir or OUTDIR
    os.makedirs(outdir, exist_ok=True)
    im = Image.fromarray(cv.px, 'RGB').resize((W * SCALE, H * SCALE), Image.NEAREST)
    im.save(os.path.join(outdir, name + '.png'), optimize=True)
    im.resize((450, 300), Image.NEAREST).save(os.path.join(outdir, name + '-thumb.png'), optimize=True)
    with open(os.path.join(outdir, name + '.json'), 'w') as f:
        json.dump({'scene': name, 'w': W, 'h': H, 'hotspots': hotspots}, f, indent=1)
    hs = im.copy()
    d = ImageDraw.Draw(hs)
    for i, h in enumerate(hotspots):
        for a, b in ((h, hotspots[j]) for j in range(i + 1, len(hotspots))):
            assert a['x'] + a['w'] <= b['x'] or b['x'] + b['w'] <= a['x'] or a['y'] + a['h'] <= b['y'] or b['y'] + b['h'] <= a['y'], (a['id'], b['id'])
        assert h['w'] >= 37 and h['h'] >= 37, h['id']
        x0, y0 = h['x'] * SCALE, h['y'] * SCALE
        x1, y1 = (h['x'] + h['w']) * SCALE - 1, (h['y'] + h['h']) * SCALE - 1
        d.rectangle([x0, y0, x1, y1], outline=(0, 255, 255), width=4)
        d.text((x0 + 10, y0 + 8), h['id'], fill=(0, 255, 255))
    hs.save(os.path.join(outdir, name + '_hs.png'))
    return cv.colours()


# ---------------------------------------------------------------- palette (warm red / orange / cream)
WALL, WALL_S, WALL_L = '#ecd6aa', '#dcc08e', '#f4e4c0'
TILE, TILE_S = '#f2e4c0', '#d9b98a'
FLOOR, FLOOR_S, FLOOR_L = '#9a6438', '#7a4a28', '#b07a45'
SHADOW = '#6a3e22'
IRON = ramp('#4e5262', '#34343f', '#767c90', '#5b6070')
RED = ramp('#dd3a2a', '#ae2a2a', '#f2793a', '#c03228')
STEW = ramp('#e0701f', '#b8452f', '#f5a04a')
WOOD = ramp('#b07a45', '#8a4f2a', '#d9a660', '#9a6438')
DWOOD = ramp('#7a4a1f', '#5c3420', '#9a6b3f')
BOARD = ramp('#d9a660', '#b07a45', '#ecc58a')
BRICK = ramp('#c0603a', '#9a4428', '#e08a5a', '#a84e30')
STONE = ramp('#d8cbb0', '#b0a084', '#f1ece0')
COPPER = ramp('#d0743a', '#a04e24', '#f5b07a', '#b85e2c')
CREAM = ramp('#f2e4c0', '#c9a96e', '#fff4d8')
BREAD = ramp('#e8a317', '#b07a10', '#f5cf6a', '#c98a1a')
BOWL = ramp('#3f8fb0', '#25637d', '#a9d6ea')
APPLE = ramp('#d6322b', '#a8241f', '#f08a24')
CARROT = ramp('#f08a24', '#c25a1a', '#f5cf6a')
CABBAGE = ramp('#7ab55c', '#4f9a45', '#a4b86a')
STEAM = ramp('#f1ece0', '#c9b89a', '#ffffff')
FIRE0, FIRE1, FIRE2, FIRE3 = '#e0501f', '#f08a24', '#f5cf6a', '#fff1c8'
UMB = '#2a1a10'

cv = new_canvas(WALL)
r = rnd(1207)


def shadow(x0, y0, x1, y1):
    cv.fill(ell(x0, y0, x1, y1), SHADOW)


def draw(*parts):
    o = cv.obj()
    for p in parts:
        o.part(*p[:2], **(p[2] if len(p) > 2 else {}))
    return o.draw()


# ---------------------------------------------------------------- room: ceiling beam, plaster wall, skirting, plank floor
for _ in range(14):   # a few faint plaster patches, kept away from the objects' outlines
    x, y = r(4, 290), r(14, 136)
    cv.fill(rect(x, y, x + r(3, 7), y), WALL_S)
cv.fill(rect(0, 0, W - 1, 7), DWOOD['b'])
cv.fill(rect(0, 6, W - 1, 7), DWOOD['s'])
cv.fill(rect(0, 0, W - 1, 0), DWOOD['r'])
for bx in (40, 150, 260):   # beam joints
    cv.fill(rect(bx, 1, bx, 5), DWOOD['s'])
cv.fill(rect(0, 8, W - 1, 8), WALL_S)   # beam shadow on the wall
FY = 150
cv.fill(rect(0, FY, W - 1, H - 1), FLOOR)
for k, y in enumerate(range(FY + 9, H, 11)):   # boards widen towards the viewer
    cv.fill(rect(0, y, W - 1, y), FLOOR_S)
    for jx in range(18 + (k % 2) * 37, W, 74):
        cv.fill(rect(jx, y - 10, jx, y - 1), FLOOR_S)
cv.fill(rect(0, FY, W - 1, FY), FLOOR_L)
cv.fill(rect(0, FY - 5, W - 1, FY - 1), DWOOD['b'])   # skirting board
cv.fill(rect(0, FY - 5, W - 1, FY - 5), DWOOD['r'])

# ---------------------------------------------------------------- tiled alcove behind the stove (frames the hero)
al = rect(100, 30, 196, FY - 6) | ell(100, 14, 196, 50)
cv.fill(al, TILE)
cv.fill(dil4(al) & ~al & ~rect(0, FY - 5, W, H), WALL_S)
for ty in range(36, FY - 6, 8):
    cv.fill(al & rect(0, ty, W, ty), TILE_S)
    for tx in range(100 + (ty // 8 % 2) * 4, 197, 8):
        cv.fill(al & rect(tx, ty - 7, tx, ty - 1), TILE_S)

# ---------------------------------------------------------------- HERO: iron stove with the red stew pot
SX0, SX1 = 106, 190
shadow(SX0 - 2, 168, SX1 + 6, 176)
pipe = rect(168, 9, 178, 104)
draw((pipe, IRON, {'d': 2}))
for py in (30, 62):
    draw((rect(166, py, 180, py + 3), IRON, {'d': 1}))
draw((rect(SX0 + 4, 164, SX0 + 10, 172), IRON, {'d': 1}), (rect(SX1 - 10, 164, SX1 - 4, 172), IRON, {'d': 1}),
     (rrect(SX0 + 2, 110, SX1 - 2, 166, 2), IRON, {'d': 3}),
     (rect(SX0 - 2, 104, SX1 + 2, 110), IRON, {'d': 2, 'contour': True}))
cv.fill(rect(SX0 - 1, 105, SX1 + 1, 105), IRON['r'])
# firebox door with a glowing window
draw((rrect(116, 120, 150, 156, 2), IRON, {'d': 2, 'contour': True}))
win = rrect(121, 126, 145, 146, 2)
cv.fill(win, FIRE0)
fl = poly([(122, 146), (125, 134), (128, 140), (132, 128), (137, 139), (140, 132), (144, 146)])
cv.fill(fl & win, FIRE1)
cv.fill(poly([(127, 146), (132, 134), (137, 146)]) & win, FIRE2)
cv.fill(rect(131, 142, 133, 146), FIRE3)
for gx in (127, 133, 139):   # grate bars
    cv.fill(rect(gx, 126, gx, 146), UMB)
cv.fill(rect(130, 150, 136, 151), '#e8a317')   # brass latch
# oven door with brass handle
draw((rrect(156, 120, 182, 156, 2), IRON, {'d': 2, 'contour': True}))
cv.fill(rect(160, 124, 178, 124), IRON['g'])
draw((rect(160, 134, 178, 137), ramp('#e8a317', '#b07a10', '#f5cf6a'), {'d': 1}))
cv.fill(rect(SX0 + 4, 159, SX1 - 4, 159), IRON['s'])   # ash-pan line
# the pot
PX0, PX1 = 118, 162
draw((ell(PX0 - 2, 66, PX1 + 2, 82), IRON, {'d': 2}),   # rim back
     (rrect(PX0 - 6, 82, PX0 + 1, 90, 2) | rrect(PX1 - 1, 82, PX1 + 6, 90, 2), IRON, {'d': 1}),   # lug handles
     (rrect(PX0, 74, PX1, 104, 6), RED, {'d': 3}),
     (rrect(PX0 - 3, 74, PX1 + 3, 79, 2), IRON, {'d': 1, 'contour': True}))
cv.fill(ell(PX0 + 2, 68, PX1 - 2, 78) & ~rect(0, 75, W, H), STEW['b'])
cv.fill(ell(PX0 + 2, 68, PX1 - 2, 78) & rect(0, 68, W, 70), STEW['s'])
cv.dots([(126, 71), (127, 71), (140, 72), (150, 71), (151, 71)], STEW['r'])
cv.fill(rect(PX0 + 4, 82, PX0 + 6, 96), RED['g'] or '#ff9158')
cv.fill(rect(PX0 + 4, 82, PX0 + 5, 84), '#ffc27a')
for sx in range(PX0 + 12, PX1 - 4, 6):   # stitched seam
    cv.fill(rect(sx, 90, sx + 2, 90), '#ffc27a')
# wooden spoon standing in the stew
draw((line([(150, 72), (164, 50)], 3), WOOD, {'d': 1}), (ell(160, 40, 172, 52), WOOD, {'d': 2}))
# steam curls
for pts in (((128, 64), (124, 56), (128, 48), (124, 40)), ((142, 62), (146, 54), (142, 46), (146, 38), (142, 32))):
    cv.fill(line(list(pts), 3), STEAM['b'])
    cv.fill(line([(x + 1, y) for x, y in pts], 1) & line(list(pts), 3), STEAM['s'])

# ---------------------------------------------------------------- LEFT TOP: brick bread oven built into the wall
oven = ell(8, 14, 88, 82) | rect(8, 48, 88, 94)
draw((oven, BRICK, {'d': 3}))
for k, by in enumerate(range(22, 94, 6)):   # brick courses
    cv.fill(oven & rect(0, by, W, by), BRICK['s'])
    for bx in range(10 + (k % 2) * 6, 88, 12):
        cv.fill(oven & rect(bx, by - 5, bx, by - 1), BRICK['s'])
mouth = ell(26, 42, 70, 80) | rect(26, 62, 70, 88)
draw((dil4(dil4(mouth)) & oven, STONE, {'d': 2}))
cv.fill(mouth, '#3d2a1c')
cv.fill(mouth & rect(0, 74, W, 88), '#5c2a18')
cv.fill(mouth & rect(0, 84, W, 88), FIRE0)
for ex in range(29, 69, 5):
    cv.dots([(ex, 84), (ex + 1, 85), (ex + 2, 83)], FIRE1)
for lx in (32, 50):   # two loaves baking
    draw((ell(lx, 74, lx + 15, 84), BREAD, {'d': 2}))
    cv.fill(line([(lx + 4, 77), (lx + 7, 80)]) | line([(lx + 8, 76), (lx + 11, 79)]), BREAD['s'])
draw((rect(4, 94, 92, 100), STONE, {'d': 2}))   # stone sill

# ---------------------------------------------------------------- LEFT BOTTOM: barrel of produce
BX0, BX1 = 18, 76
shadow(BX0 - 2, 178, BX1 + 6, 186)
barrel = rrect(BX0, 122, BX1, 182, 5) | ell(BX0 - 2, 132, BX1 + 2, 172)
draw((barrel, WOOD, {'d': 3}))
for sx in range(BX0 + 9, BX1 - 4, 10):
    cv.fill(barrel & rect(sx, 124, sx, 180), WOOD['s'])
for hy in (130, 170):
    draw((barrel & rect(0, hy, W, hy + 3), IRON, {'d': 1, 'rim': False}))
    cv.fill(barrel & rect(0, hy, W, hy), IRON['r'])
cv.fill(rect(BX0 + 2, 122, BX1 - 2, 124), WOOD['s'])
# heap: cabbage, apples, carrots
draw((ell(22, 104, 46, 126), CABBAGE, {'d': 2}))
cv.fill(line([(34, 108), (34, 124)]) | line([(28, 112), (34, 118)]) | line([(40, 112), (34, 118)]), CABBAGE['s'])
for ax, ay in ((46, 112), (58, 108), (54, 118), (66, 116)):
    draw((ell(ax, ay, ax + 10, ay + 9), APPLE, {'d': 2}))
    cv.fill(rect(ax + 5, ay - 2, ax + 5, ay), DWOOD['b'])
    cv.dots([(ax + 2, ay + 2), (ax + 3, ay + 2)], '#ffc27a')
for cx0, cy0, cx1, cy1 in ((62, 104, 74, 124), (68, 102, 78, 122)):
    draw((line([(cx0, cy0), (cx1, cy1)], 4), CARROT, {'d': 1}))
    cv.fill(line([(cx0 - 2, cy0 - 5), (cx0, cy0)], 1) | line([(cx0 + 2, cy0 - 5), (cx0, cy0)], 1), '#4f9a45')

# ---------------------------------------------------------------- RIGHT TOP: hanging rack of copper pans
draw((rect(206, 16, 294, 20), DWOOD, {'d': 1}), (rect(210, 12, 214, 22) | rect(286, 12, 290, 22), DWOOD, {'d': 1}))
for hx0 in (226, 252, 276):
    cv.fill(rect(hx0, 21, hx0, 25), IRON['b'])
# frying pan (handle up)
draw((rect(224, 24, 228, 38), COPPER, {'d': 1}), (ell(212, 36, 240, 60), COPPER, {'d': 3}))
cv.fill(ell(217, 41, 235, 55), COPPER['s'])
cv.fill(ell(217, 41, 235, 55) & ~shift(ell(217, 41, 235, 55), 2, 2), COPPER['bo'])
cv.dots([(218, 44), (219, 43), (220, 42)], COPPER['r'])
# ladle
draw((rect(251, 24, 253, 46), IRON, {'d': 1}), (ell(245, 44, 259, 56), IRON, {'d': 2}))
# small saucepan
draw((rect(274, 24, 278, 34), COPPER, {'d': 1}), (rrect(266, 34, 288, 54, 3), COPPER, {'d': 3}))
cv.fill(rect(269, 38, 270, 48), COPPER['r'])

# ---------------------------------------------------------------- RIGHT BOTTOM: worktable with board, loaf and mixing bowl
TX0, TX1 = 206, 294
shadow(TX0 + 2, 168, TX1 + 4, 176)
draw((rect(TX0 + 6, 116, TX0 + 12, 172) | rect(TX1 - 12, 116, TX1 - 6, 172), WOOD, {'d': 2}),
     (rect(TX0 + 12, 150, TX1 - 12, 154), WOOD, {'d': 1}),
     (rect(TX0, 108, TX1, 116), WOOD, {'d': 2, 'contour': True}))
cv.fill(rect(TX0 + 1, 109, TX1 - 1, 109), WOOD['r'])
draw((rrect(214, 100, 258, 108, 1), BOARD, {'d': 1}), (rect(258, 103, 266, 105), BOARD, {'d': 1}))   # board with handle
draw((ell(218, 82, 252, 104), BREAD, {'d': 3}))   # big round loaf
for k in range(3):
    cv.fill(line([(225 + k * 8, 88), (230 + k * 8, 96)]), BREAD['s'])
    cv.fill(line([(226 + k * 8, 88), (231 + k * 8, 96)]), BREAD['r'])
draw((ell(266, 86, 292, 96) | (ell(266, 86, 292, 112) & rect(0, 91, W, H)), BOWL, {'d': 3}))   # mixing bowl
cv.fill(ell(269, 87, 289, 94), CREAM['b'])
cv.fill(ell(269, 87, 289, 94) & ~shift(ell(269, 87, 289, 94), 0, 2), CREAM['s'])
cv.fill(rect(267, 100, 291, 101) & ell(266, 86, 292, 112), BOWL['r'])
draw((line([(280, 92), (290, 76)], 2), WOOD, {'d': 1}))   # spoon in the batter

HOTSPOTS = [
    {'id': 'oven', 'label': 'Bread oven', 'x': 4, 'y': 10, 'w': 90, 'h': 90},
    {'id': 'produce', 'label': 'Produce barrel', 'x': 12, 'y': 100, 'w': 72, 'h': 88},
    {'id': 'stove', 'label': 'Stove', 'x': 100, 'y': 30, 'w': 98, 'h': 148},
    {'id': 'rack', 'label': 'Pan rack', 'x': 204, 'y': 10, 'w': 92, 'h': 52},
    {'id': 'table', 'label': 'Worktable', 'x': 202, 'y': 72, 'w': 96, 'h': 106},
]

if __name__ == '__main__':
    out = sys.argv[1] if len(sys.argv) > 1 else None
    n = save_scene(cv, NAME, HOTSPOTS, out)
    print(NAME + ':', n, 'colours')
