"""Crafting area scene: GARDEN SUPPLIES (variant imp). Usage: python3 -B aseprite-source/scenes-pil/craft_imp_garden.py [outdir]
Writes aseprite-source/craftmap/scenes/imp/garden.png (1800 x 1200), garden-thumb.png (450 x 300), garden.json (hotspots) and garden_hs.png.
Brief: claude/craftmap-scene-brief.md (Round 2). Clean and clear, five big tap targets on a calm sage board wall in a garden shed:
hero = leaf-green slatted compost bin heaped with dark compost, a sprout and a garden fork (centre, framed by the shed window);
left = zinc watering can and a pot of trowels on a shelf over two burlap sacks of loam; right = a terracotta seed tray of
seedlings on a shelf over a wooden wheelbarrow of bark mulch.
"""
import json
import os
import sys

from jigsaw_common import *  # noqa: F401,F403
from PIL import Image, ImageDraw

NAME = 'garden'
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
        d.rectangle([x0, y0, x1, y1], outline=(255, 0, 255), width=4)
        d.text((x0 + 10, y0 + 8), h['id'], fill=(255, 0, 255))
    hs.save(os.path.join(outdir, name + '_hs.png'))
    return cv.colours()


# ---------------------------------------------------------------- palette (leaf green / earth brown / cream)
WALL, WALL_S, WALL_L = '#d9dcb0', '#c4c897', '#e6e8c4'
SKY, HILL, HILL_S = '#d8ece6', '#b4d08e', '#9cbf7a'
FLOOR, FLOOR_S, FLOOR_L = '#8a5a36', '#76492b', '#96643e'
SHADOW = '#5e3a20'
LEAF = ramp('#4fa443', '#357a34', '#86cc5a', '#41903c')    # the hero owns the saturated green
LEAFD = ramp('#3a7f38', '#285e2a', '#5aa646')
COMPOST = ramp('#5c3a22', '#3e2616', '#7a5232')
WOOD = ramp('#b07a45', '#8a4f2a', '#d9a660', '#9a6438')
DWOOD = ramp('#7a4a1f', '#5c3420', '#9a6b3f')
ZINC = ramp('#8aa2ae', '#5f7886', '#c6d8de', '#6f8a98')
TERRA = ramp('#c8683a', '#9a4a2a', '#e8925a', '#a85530')
BURLAP = ramp('#b49a72', '#94784f', '#c8b088', '#a28660')   # mid-value: sits back so the bin stays the hero
BARROW = ramp('#5f8aa0', '#436a80', '#8cb4c4', '#4e7890')
MULCH = ramp('#a8662e', '#7a4422', '#cf8a44')
SPROUT = ramp('#7cc44e', '#4f9a3a', '#b4e07a')
IRON = ramp('#4e5262', '#34343f', '#767c90', '#5b6070')
GOLD = ramp('#e8a317', '#b07a10', '#f5cf6a')
CARROT = ramp('#f08a24', '#c25a1a', '#f5cf6a')
APPLE = ramp('#d6322b', '#a8241f', '#f08a24')
UMB = '#2a1a10'

cv = new_canvas(WALL)


def shadow(x0, y0, x1, y1):
    cv.fill(ell(x0, y0, x1, y1), SHADOW)


def draw(*parts):
    o = cv.obj()
    for p in parts:
        o.part(*p[:2], **(p[2] if len(p) > 2 else {}))
    return o.draw()


def sparkle(x, y, s=2, col=GOLD['r']):
    cv.fill(rect(x - s, y, x + s, y) | rect(x, y - s, x, y + s), col)
    cv.dots([(x, y)], '#ffffff')


# ---------------------------------------------------------------- room: roof beam, wide vertical shed boards, packed-earth floor
FY = 150
for bx in range(14, W, 30):   # wide boards, one joint line each: texture without noise
    cv.fill(rect(bx, 8, bx, FY - 1), WALL_S)
    cv.fill(rect(bx + 1, 8, bx + 1, FY - 1), WALL_L)
cv.fill(rect(0, 0, W - 1, 7), DWOOD['b'])
cv.fill(rect(0, 6, W - 1, 7), DWOOD['s'])
cv.fill(rect(0, 0, W - 1, 0), DWOOD['r'])
for bx in (60, 240):
    cv.fill(rect(bx, 1, bx, 5), DWOOD['s'])
cv.fill(rect(0, 8, W - 1, 8), WALL_S)
cv.fill(rect(0, FY, W - 1, H - 1), FLOOR)
for k, y in enumerate(range(FY + 10, H, 12)):   # subtle planks, widening towards the viewer
    cv.fill(rect(0, y, W - 1, y), FLOOR_S)
    for jx in range(26 + (k % 2) * 43, W, 86):
        cv.fill(rect(jx, y - 11, jx, y - 1), FLOOR_S)
        cv.fill(rect(jx + 1, y - 11, jx + 1, y - 1), FLOOR_L)
cv.fill(rect(0, FY - 5, W - 1, FY - 1), DWOOD['b'])   # sill board
cv.fill(rect(0, FY - 5, W - 1, FY - 5), DWOOD['r'])
cv.fill(rect(0, FY, W - 1, FY), FLOOR_S)

# ---------------------------------------------------------------- shed window behind the hero (frames it like the kitchen alcove)
WX0, WX1, WY0, WY1 = 108, 192, 16, 76
pane = rect(WX0 + 5, WY0 + 5, WX1 - 5, WY1 - 2)
cv.fill(pane, SKY)
hill = (ell(WX0 - 30, WY1 - 26, WX0 + 70, WY1 + 30) | ell(WX0 + 40, WY1 - 18, WX1 + 40, WY1 + 30)) & pane
cv.fill(hill, HILL)
cv.fill(hill & ~shift(hill, 0, 1), HILL_S)
cv.fill(ell(WX0 + 14, WY0 + 12, WX0 + 30, WY0 + 20) | ell(WX0 + 22, WY0 + 9, WX0 + 36, WY0 + 19), '#f4faf6')   # one soft cloud
frame = rect(WX0, WY0, WX1, WY1) & ~pane
mull = rect((WX0 + WX1) // 2 - 1, WY0, (WX0 + WX1) // 2 + 1, WY1) | rect(WX0, (WY0 + WY1) // 2 - 1, WX1, (WY0 + WY1) // 2 + 1)
draw((frame | mull, WOOD, {'d': 2}), (rect(WX0 - 4, WY1, WX1 + 4, WY1 + 4), WOOD, {'d': 1, 'contour': True}))
cv.fill(pane & ~mull & ~shift(pane & ~mull, 1, 1), '#b7cfc8')   # inner reveal shadow, top-left of each pane

# ---------------------------------------------------------------- HERO: leaf-green slatted compost bin with a heap, sprout and fork
BX0, BX1, BY0, BY1 = 108, 192, 104, 174
FX, DX, DY = 180, 12, 8   # front face BX0..FX, side face recedes up-right by DX, DY (three-quarter view)
shadow(BX0 - 4, BY1 - 4, BX1 + 10, BY1 + 6)
# garden fork: handle with a D-grip, rising out of the heap towards the window
fork = line([(170, 96), (184, 44)], 4)
dgrip = poly([(180, 46), (188, 46), (194, 30), (192, 28), (176, 28), (174, 30)]) & ~poly([(180, 41), (188, 41), (190, 33), (178, 33)])
draw((fork, WOOD, {'d': 1}), (dgrip, WOOD, {'d': 1}))
top = poly([(BX0, BY0), (FX, BY0), (FX + DX, BY0 - DY), (BX0 + DX, BY0 - DY)])
back_rim = rect(BX0 + DX, BY0 - DY - 3, FX + DX, BY0 - DY)
left_rim = poly([(BX0, BY0), (BX0 + 4, BY0), (BX0 + DX + 4, BY0 - DY - 3), (BX0 + DX, BY0 - DY - 3)])
right_rim = poly([(FX - 3, BY0 + 3), (FX + DX, BY0 - DY - 3), (FX + DX, BY0 - DY + 1), (FX, BY0 + 4)])
side = poly([(FX, BY0), (FX + DX, BY0 - DY), (FX + DX, BY1 - DY), (FX, BY1)])
heap = ((ell(BX0 + 4, 88, BX0 + 44, 112) | ell(BX0 + 24, 78, FX - 14, 110) | ell(FX - 40, 86, FX + 2, 108)) & ~rect(0, BY0 - 1, W, H)) | (top & ~back_rim & ~left_rim)
slats, sslats = blank(), blank()
for y in range(BY0 + 4, BY1 - 4, 14):
    slats |= rect(BX0 + 6, y, FX - 6, y + 10)
    sslats |= poly([(FX + 1, y), (FX + DX, y - DY), (FX + DX, y - DY + 10), (FX + 1, y + 10)])
posts = rect(BX0, BY0, BX0 + 7, BY1) | rect(FX - 7, BY0, FX, BY1)
draw((back_rim, LEAF, {'d': 1}),
     (side, COMPOST, {'flat': True}),
     (sslats, LEAFD, {'d': 1, 'rim': False}),
     (poly([(FX + DX - 4, BY0 - DY - 3), (FX + DX, BY0 - DY - 3), (FX + DX, BY1 - DY), (FX + DX - 4, BY1 - DY + 2)]), LEAFD, {'d': 1, 'rim': False}),
     (heap, COMPOST, {'d': 3}),
     (rect(BX0, BY0, FX, BY1 - 2), COMPOST, {'flat': True}),
     (slats, LEAF, {'d': 2, 'contour': True}),
     (posts, LEAFD, {'d': 2, 'contour': True}),
     (left_rim | right_rim, LEAF, {'d': 1}),
     (rect(BX0, BY0 - 1, FX, BY0 + 3), LEAF, {'d': 1, 'contour': True}))
cv.fill((left_rim | right_rim) & ~shift(left_rim | right_rim, 0, 1), '#b4e07a')   # lit top of the side rims
cv.fill(rect(BX0 + 1, BY0 - 1, FX - 1, BY0 - 1), '#b4e07a')   # sunlit top edge of the front rim: reads as a surface
cv.fill(back_rim & rect(0, BY0 - DY - 3, W, BY0 - DY - 3), LEAF['r'])
cv.fill(slats & ~shift(slats, 0, 1), LEAF['r'])   # top lit edge on every slat
cv.fill(rect(FX, BY0, FX, BY1), LEAFD['s'])   # front corner turns into shadow
for sx in range(BX0 + 14, FX - 10, 6):   # stitched seam on the middle slat
    cv.fill(rect(sx, BY0 + 37, sx + 2, BY0 + 37), '#c8ec98')
for py in (BY0 + 8, BY1 - 8):   # nail heads on the posts
    cv.dots([(BX0 + 4, py), (FX - 4, py)], LEAFD['r'])
# on the heap: apple core, a cabbage leaf, lumps of rich compost
cv.dots([(124, 98), (125, 98), (134, 94), (135, 94), (140, 90), (141, 90), (138, 99), (166, 100), (167, 100), (128, 101), (146, 100), (176, 92), (177, 92), (184, 95)], COMPOST['r'])
draw((ell(155, 88, 165, 99), APPLE, {'d': 1}), (rect(159, 84, 160, 88), DWOOD, {'d': 0}))
draw((ell(118, 92, 132, 101), SPROUT, {'d': 1}))
cv.fill(line([(120, 97), (129, 96)]), SPROUT['s'])   # cabbage leaf vein
# the sprout: proud and bright, the one thing that grows here
draw((rect(150, 64, 152, 86), SPROUT, {'d': 0}),
     (ell(134, 58, 151, 69), SPROUT, {'d': 1}), (ell(152, 52, 169, 63), SPROUT, {'d': 1}))
cv.fill(line([(138, 63), (149, 63)]) | line([(155, 57), (165, 57)]), SPROUT['s'])
for sx, sy in ((124, 76), (132, 44), (200, 70), (112, 86), (162, 40)):
    sparkle(sx, sy)

# ---------------------------------------------------------------- LEFT TOP: a pot of trowels and a zinc watering can on a shelf
draw((rect(4, 76, 98, 80), WOOD, {'d': 2}), (poly([(10, 81), (16, 81), (10, 92)]) | poly([(86, 81), (92, 81), (92, 92)]), WOOD, {'d': 1}))
# trowel and hand fork standing in a terracotta pot (left)
draw((rect(14, 36, 17, 58), WOOD, {'d': 1}), (poly([(11, 36), (20, 36), (19, 26), (15.5, 18), (12, 26)]), ZINC, {'d': 1}))
draw((rect(25, 42, 28, 60), WOOD, {'d': 1}),
     (rect(21, 34, 22, 42) | rect(24, 32, 25, 42) | rect(28, 32, 29, 42) | rect(31, 34, 32, 42) | rect(21, 41, 32, 43), ZINC, {'d': 0}))
draw((poly([(8, 60), (34, 60), (31, 75), (11, 75)]), TERRA, {'d': 2}), (rect(6, 56, 36, 61), TERRA, {'d': 1, 'contour': True}))
# watering can (right): tapered body, back handle, long spout up to the rose
can = poly([(44, 75), (42, 46), (74, 46), (72, 75)])
spout = poly([(70, 66), (92, 36), (95, 39), (72, 72)])
rose = poly([(88, 32), (96, 28), (99, 40), (93, 42)])
handle = (ell(44, 30, 72, 60) & ~ell(49, 35, 67, 60)) & rect(0, 0, W, 45)
draw((handle, ZINC, {'d': 1}), (spout, ZINC, {'d': 1}), (rose, ZINC, {'d': 1}),
     (can, ZINC, {'d': 3}), (rect(40, 43, 76, 47), ZINC, {'d': 1, 'contour': True}))
cv.fill(rect(47, 51, 48, 70), ZINC['r'])
for ry in (55, 66):
    cv.fill(can & rect(0, ry, W, ry), ZINC['s'])
cv.dots([(95, 32), (96, 35), (97, 38)], ZINC['s'])   # holes in the rose

# ---------------------------------------------------------------- LEFT BOTTOM: two burlap sacks of loam
shadow(8, 180, 96, 190)
sack1 = (poly([(18, 186), (14, 150), (20, 124), (52, 124), (58, 150), (56, 186)]) | ell(12, 150, 60, 190)) & ~rect(0, 187, W, H)
lip = poly([(17, 118), (26, 114), (36, 117), (46, 113), (55, 118), (54, 128), (18, 128)])   # rolled-down top, wavy
draw((sack1, BURLAP, {'d': 3}), (lip, BURLAP, {'d': 1, 'contour': True}))
soil = ell(22, 114, 50, 122)
cv.fill(soil, COMPOST['b'])
cv.fill(soil & ~shift(soil, 0, 2), COMPOST['s'])
cv.dots([(30, 118), (31, 118), (40, 116), (44, 119), (45, 119)], COMPOST['r'])
cv.fill(lip & rect(0, 127, W, 127), BURLAP['s'])
for k, wy in enumerate(range(136, 184, 8)):   # sparse burlap weave stitches
    for wx in range(20 + (k % 2) * 4, 54, 8):
        if sack1[wy, wx] and sack1[wy, wx + 3]:
            cv.fill(rect(wx, wy, wx + 1, wy), BURLAP['s'])
patch = ell(27, 148, 43, 166)   # small leaf patch stitched on the front, muted so it does not compete
draw((patch, ramp('#6f8a4a', '#566e38', '#8aa25e'), {'d': 1}))
cv.fill(line([(35, 151), (35, 163)]), '#8aa25e')
# second sack, tied with twine, slumped against the first
sack2 = (poly([(54, 188), (52, 164), (64, 143), (80, 143), (92, 164), (94, 188)]) | ell(48, 156, 98, 200)) & ~rect(0, 189, W, H)
ears = ell(60, 126, 72, 138) | ell(68, 124, 80, 136) | ell(74, 128, 86, 140) | rect(66, 134, 78, 142)
draw((ears, BURLAP, {'d': 1}), (sack2, BURLAP, {'d': 3}), (rect(64, 140, 80, 143), DWOOD, {'d': 1, 'contour': True}))
for k, wy in enumerate(range(152, 186, 8)):
    for wx in range(58 + (k % 2) * 4, 92, 8):
        if sack2[wy, wx] and sack2[wy, wx + 3]:
            cv.fill(rect(wx, wy, wx + 1, wy), BURLAP['s'])

# ---------------------------------------------------------------- RIGHT TOP: terracotta seed tray of seedlings on a shelf
draw((rect(204, 76, 296, 80), WOOD, {'d': 2}), (poly([(210, 81), (216, 81), (210, 92)]) | poly([(284, 81), (290, 81), (290, 92)]), WOOD, {'d': 1}))
tray = rrect(210, 58, 290, 75, 1)
draw((tray, TERRA, {'d': 2}), (rect(208, 56, 292, 60), TERRA, {'d': 1, 'contour': True}))
cv.fill(rect(212, 57, 288, 57), COMPOST['b'])
for tx, h in ((224, 12), (244, 22), (263, 16), (281, 26)):   # four seedlings, uneven like real ones
    draw((rect(tx, 56 - h, tx + 1, 56), SPROUT, {'d': 0}),
         (ell(tx - 10, 51 - h, tx, 59 - h), SPROUT, {'d': 1}),
         (ell(tx + 1, 49 - h, tx + 11, 57 - h), SPROUT, {'d': 1}))
for dx in range(214, 290, 19):
    cv.fill(rect(dx, 66, dx + 10, 66), TERRA['s'])   # cell divisions on the tray front

# ---------------------------------------------------------------- RIGHT BOTTOM: slate-blue wheelbarrow of bark mulch
shadow(204, 180, 296, 190)
mulch = (ell(212, 118, 240, 146) | ell(230, 112, 258, 146) | ell(250, 114, 274, 146) | ell(264, 120, 286, 146)) & ~rect(0, 134, W, H)
tub = poly([(208, 132), (284, 132), (274, 162), (222, 162)])
draw((poly([(274, 140), (298, 130), (298, 135), (276, 146)]), WOOD, {'d': 1}),   # handle
     (rect(264, 160, 268, 186), WOOD, {'d': 1}),   # leg
     (mulch, MULCH, {'d': 3}),
     (tub, BARROW, {'d': 3, 'contour': True}),
     (rect(206, 130, 286, 134), IRON, {'d': 1, 'contour': True}))
cv.fill(tub & rect(0, 146, W, 146), BARROW['s'])
cv.fill(rect(230, 138, 231, 156) & tub, BARROW['r'])
r = rnd(4211)
for _ in range(60):   # bark chips: short hard dashes
    x, y = r(214, 284), r(113, 131)
    if mulch[y, x] and mulch[y, x + 4] and mulch[y - 1, x]:
        cv.fill(rect(x, y, x + r(1, 3), y), MULCH['s'] if r(0, 2) else MULCH['r'])
wheel = ell(210, 156, 236, 182)
draw((wheel, IRON, {'d': 2}), (ell(218, 164, 228, 174), WOOD, {'d': 1, 'contour': True}))
cv.fill(rect(222, 168, 224, 170), IRON['b'])

HOTSPOTS = [
    {'id': 'can', 'label': 'Watering can and trowels', 'x': 4, 'y': 14, 'w': 96, 'h': 82},
    {'id': 'sacks', 'label': 'Sacks of loam', 'x': 6, 'y': 104, 'w': 92, 'h': 88},
    {'id': 'compost', 'label': 'Compost bin', 'x': 102, 'y': 28, 'w': 96, 'h': 152},
    {'id': 'seeds', 'label': 'Seed trays', 'x': 202, 'y': 14, 'w': 96, 'h': 82},
    {'id': 'barrow', 'label': 'Mulch barrow', 'x': 202, 'y': 100, 'w': 96, 'h': 92},
]

if __name__ == '__main__':
    out = sys.argv[1] if len(sys.argv) > 1 else None
    n = save_scene(cv, NAME, HOTSPOTS, out)
    print(NAME + ':', n, 'colours')
