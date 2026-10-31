"""Crafting area scene: TOOL SHED (variant imp). Usage: python3 -B aseprite-source/scenes-pil/craft_imp_tools.py [outdir]
Writes aseprite-source/craftmap/scenes/imp/tools.png (1800 x 1200), tools-thumb.png (450 x 300), tools.json (hotspots) and tools_hs.png.
Brief: claude/craftmap-scene-brief.md (Round 2). Clean and clear, five big tap targets on a calm steel-blue clapboard wall:
hero = dark iron anvil on a stump with a glowing bar and a sledge hammer leaning on it (centre, lit by a two-step amber glow);
left = a rack of saw, spade and rake over a workbench with a blue vice; right = a wooden tool tote on a shelf over a sandstone grindstone.
"""
import json
import os
import sys

from jigsaw_common import *  # noqa: F401,F403
from PIL import Image, ImageDraw

NAME = 'tools'
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


# ---------------------------------------------------------------- palette (steel blue / wood / amber)
WALL, WALL_S = '#5a6f82', '#4e6276'
GLOW1, GLOW2 = '#6f7a82', '#8c877c'
FLOOR, FLOOR_S, FLOOR_L = '#8a5a34', '#6e4528', '#a06c3e'
SHADOW = '#5c3a22'
IRON = ramp('#3e4a5c', '#2a3240', '#6c7c94', '#4a5668')
HAMMER = ramp('#5e6e86', '#3e4a5c', '#8e9eb6')
STEEL = ramp('#b4c4d2', '#7d93a6', '#e4ecf2', '#94a8ba')
BLUE = ramp('#4676a4', '#2f5a84', '#7aa8d4', '#3a6894')
WOOD = ramp('#b07a45', '#8a4f2a', '#d9a660', '#9a6438')
DWOOD = ramp('#7a4a1f', '#5c3420', '#9a6b3f')
BARK = ramp('#8a5a30', '#6a4024', '#a87a48', '#7a4a28')
RING = ramp('#d9b07a', '#b08050', '#ecd0a0')
SAND = ramp('#d4ac6a', '#a8844a', '#eed29a', '#b8945a')
AMBER = ramp('#e8a317', '#b07a10', '#f5cf6a')
RED = ramp('#c8402e', '#963024', '#e8704a')
HOT0, HOT1, HOT2, HOT3 = '#e0501f', '#f08a24', '#f5cf6a', '#fff1c8'
UMB = '#2a1a10'

cv = new_canvas(WALL)


def shadow(x0, y0, x1, y1):
    cv.fill(ell(x0, y0, x1, y1), SHADOW)


def draw(*parts):
    o = cv.obj()
    for p in parts:
        o.part(*p[:2], **(p[2] if len(p) > 2 else {}))
    return o.draw()


def sparkle(x, y, s=2, col=AMBER['r']):
    cv.fill(rect(x - s, y, x + s, y) | rect(x, y - s, x, y + s), col)
    cv.dots([(x, y)], '#ffffff')


# ---------------------------------------------------------------- room: wide clapboard wall, ceiling beam, plank floor
FY = 150
for k, y in enumerate(range(20, FY, 13)):   # wide boards, few joints: texture without noise
    cv.fill(rect(0, y, W - 1, y), WALL_S)
    for jx in range(30 + (k % 3) * 37, W, 110):
        cv.fill(rect(jx, y - 12, jx, y - 1), WALL_S)
cv.fill(rect(0, 0, W - 1, 7), DWOOD['b'])
cv.fill(rect(0, 6, W - 1, 7), DWOOD['s'])
cv.fill(rect(0, 0, W - 1, 0), DWOOD['r'])
cv.fill(rect(0, FY, W - 1, H - 1), FLOOR)
for k, y in enumerate(range(FY + 10, H, 12)):
    cv.fill(rect(0, y, W - 1, y), FLOOR_S)
    for jx in range(26 + (k % 2) * 41, W, 82):
        cv.fill(rect(jx, y - 11, jx, y - 1), FLOOR_S)
cv.fill(rect(0, FY, W - 1, FY), FLOOR_L)
cv.fill(rect(0, FY - 5, W - 1, FY - 1), DWOOD['b'])   # skirting board
cv.fill(rect(0, FY - 5, W - 1, FY - 5), DWOOD['r'])

# ---------------------------------------------------------------- warm glow from the hot iron (two hard steps behind the hero)
g2 = ell(86, 30, 214, 170) & ~rect(0, FY - 5, W, H)
g1 = ell(104, 50, 196, 156) & ~rect(0, FY - 5, W, H)
cv.fill(g2, GLOW1)
cv.fill(g1, GLOW2)
for k, y in enumerate(range(20, FY, 13)):   # board lines stay visible inside the glow, one step lighter
    cv.fill(g2 & rect(0, y, W, y), WALL)
    cv.fill(g1 & rect(0, y, W, y), GLOW1)
    for jx in range(30 + (k % 3) * 37, W, 110):
        cv.fill(g2 & rect(jx, y - 12, jx, y - 1), WALL)
        cv.fill(g1 & rect(jx, y - 12, jx, y - 1), GLOW1)

# ---------------------------------------------------------------- HERO: iron anvil on a stump, glowing bar, sledge leaning on it
shadow(108, 172, 214, 186)
# stump: cut top seen a little from above, bark grooves, flared roots
stump = rrect(116, 128, 184, 176, 2) | poly([(110, 178), (122, 166), (126, 178)]) | poly([(190, 178), (178, 166), (174, 178)])
draw((stump, BARK, {'d': 3}), (rect(116, 126, 184, 130), RING, {'d': 1, 'contour': True}))
for pts in (((126, 134), (125, 150), (127, 172)), ((142, 140), (143, 158)), ((158, 134), (157, 146), (159, 170)), ((172, 142), (173, 162))):
    cv.fill(stump & line(list(pts)), BARK['s'])   # wavy bark grooves of uneven length (not planks)
cv.fill(ell(147, 160, 152, 165), BARK['s'])   # a knot
cv.dots([(148, 161)], BARK['r'])
# anvil: horn on the left, flat face, waist, wide feet
face = rect(114, 92, 188, 102)
horn = poly([(115, 92), (104, 93), (94, 96), (104, 99), (115, 102)])
waist = poly([(128, 103), (176, 103), (166, 116), (138, 116)])
feet = poly([(134, 116), (170, 116), (182, 126), (122, 126)])
draw((feet, IRON, {'d': 3}), (waist, IRON, {'d': 3}), (horn | face, IRON, {'d': 2, 'contour': True}))
cv.fill(rect(115, 92, 187, 92) | rect(104, 93, 114, 93), IRON['r'])   # lit top edge
cv.fill(rect(178, 95, 181, 98), UMB)   # hardy hole
# glowing bar on the face, its tip bent down over the horn
bar = rect(118, 86, 164, 91) | poly([(118, 86), (110, 88), (106, 92), (112, 92), (118, 91)])
draw((bar, ramp(HOT1, HOT0, HOT2), {'d': 1}))
cv.fill(rect(122, 87, 158, 88), HOT2)
cv.fill(rect(132, 87, 150, 87), HOT3)
cv.fill(rect(156, 89, 163, 90), HOT0)
# sledge hammer standing head-up, leaning against the anvil
draw((line([(200, 178), (193, 110)], 4), WOOD, {'d': 1}),
     (poly([(181, 102), (205, 99), (207, 112), (183, 115)]), HAMMER, {'d': 2, 'contour': True}))
cv.fill(line([(183, 103), (203, 100)]), HAMMER['r'])
cv.fill(rect(181, 103, 182, 114), HAMMER['s'])
# sparks flying from the hot bar
import math   # noqa: E402
for ang, d0, L in ((-158, 8, 9), (-128, 18, 11), (-104, 6, 16), (-84, 24, 10), (-62, 10, 15), (-36, 20, 9), (-14, 6, 8)):   # spark streaks off the strike, uneven
    ux, uy = math.cos(math.radians(ang)), math.sin(math.radians(ang))
    x0, y0 = 142 + ux * d0, 86 + uy * d0
    x1, y1 = x0 + ux * L, y0 + uy * L
    cv.fill(line([(x0, y0), (x1, y1)], 2), HOT1)
    cv.fill(line([(x0 + ux * L * .45, y0 + uy * L * .45), (x1, y1)], 2), HOT2)
    cv.fill(rect(int(round(x1)) - 1, int(round(y1)) - 1, int(round(x1)), int(round(y1))), HOT3)
for sx, sy in ((116, 58), (170, 56), (132, 38), (156, 36)):
    sparkle(sx, sy)

# ---------------------------------------------------------------- LEFT TOP: wall rack with saw, spade and rake
draw((rect(6, 14, 92, 18), DWOOD, {'d': 1}), (rect(10, 10, 14, 20) | rect(84, 10, 88, 20), DWOOD, {'d': 1}))
# hand saw hung by its handle, blade down
draw((poly([(15, 36), (33, 36), (29, 74), (21, 74)]), STEEL, {'d': 2}),
     (rrect(14, 20, 33, 38, 3), WOOD, {'d': 2, 'contour': True}))
cv.fill(rrect(20, 25, 27, 31, 1), WALL)   # hand hole
for ty in range(40, 73, 4):   # teeth on the right edge
    tx = 33 - (ty - 36) * 4 // 38
    cv.dots([(tx, ty), (tx + 1, ty + 1)], STEEL['s'])
cv.fill(rect(18, 40, 18, 46), '#ffffff')
# spade: D-grip, shaft, steel blade
draw((rect(53, 28, 57, 56), WOOD, {'d': 1}),
     (rrect(48, 19, 62, 31, 2) & ~rect(52, 22, 58, 27), WOOD, {'d': 1}),
     (poly([(45, 54), (65, 54), (65, 68), (55, 76), (45, 68)]), STEEL, {'d': 2, 'contour': True}))
cv.fill(rect(48, 57, 49, 66), '#ffffff')
# rake: head up on the peg, long tines down, handle
tines = blank()
for tx in range(65, 91, 5):
    tines |= rect(tx, 25, tx + 1, 36)
draw((rect(76, 26, 79, 76), WOOD, {'d': 1}),
     (tines, STEEL, {'d': 0}),
     (rect(63, 20, 91, 24), STEEL, {'d': 1, 'contour': True}))

# ---------------------------------------------------------------- LEFT BOTTOM: workbench with a blue vice
shadow(6, 174, 96, 184)
draw((rect(12, 112, 18, 178) | rect(76, 112, 82, 178), WOOD, {'d': 2}),
     (rect(18, 156, 76, 160), WOOD, {'d': 1}),
     (rect(4, 104, 88, 112), WOOD, {'d': 2, 'contour': True}))
cv.fill(rect(5, 105, 87, 105), WOOD['r'])
# vice at the right end: base, two jaws, screw out to the right with a T-handle
draw((rect(48, 98, 76, 104), BLUE, {'d': 1}),
     (rect(48, 88, 57, 98) | rect(67, 88, 76, 98), BLUE, {'d': 2}),
     (rect(46, 86, 59, 89) | rect(65, 86, 78, 89), STEEL, {'d': 1, 'contour': True}),
     (rect(76, 92, 86, 94), STEEL, {'d': 1}),
     (rect(86, 84, 88, 102), STEEL, {'d': 1}))
draw((rect(58, 82, 66, 97), RING, {'d': 1}))   # a block clamped in the jaws
cv.fill(rect(59, 83, 65, 83), RING['r'])

# ---------------------------------------------------------------- RIGHT TOP: wooden tool tote on a shelf
draw((rect(212, 68, 294, 72), WOOD, {'d': 2}), (poly([(218, 73), (224, 73), (218, 84)]) | poly([(282, 73), (288, 73), (288, 84)]), WOOD, {'d': 1}))
# tools standing in the tote (behind its front board)
wr = ell(226, 16, 242, 32) & ~rect(231, 14, 237, 22)   # open-end wrench head
draw((line([(238, 54), (234, 28)], 5) | wr, STEEL, {'d': 1}))
draw((rect(260, 28, 265, 48), RED, {'d': 1}), (rect(262, 18, 263, 28), STEEL, {'d': 0}))   # screwdriver
tote = rect(222, 46, 288, 67)
ends = poly([(220, 67), (220, 32), (225, 26), (230, 32), (230, 67)]) | poly([(280, 67), (280, 32), (285, 26), (290, 32), (290, 67)])
draw((rect(228, 30, 282, 33), DWOOD, {'d': 1}), (tote, WOOD, {'d': 2}), (ends, WOOD, {'d': 2, 'contour': True}))
cv.fill(rect(223, 56, 287, 56) & tote, WOOD['s'])
for nx in (235, 275):
    cv.dots([(nx, 50), (nx, 62)], DWOOD['s'])

# ---------------------------------------------------------------- RIGHT BOTTOM: sandstone grindstone on a splayed stand, crank handle
shadow(212, 176, 296, 186)
draw((line([(238, 134), (222, 180)], 5) | line([(260, 134), (276, 180)], 5), WOOD, {'d': 1}),
     (rect(226, 164, 272, 167), WOOD, {'d': 1}))
wheel = ell(219, 90, 279, 150)
draw((wheel, SAND, {'d': 3}))
cv.fill(ell(222, 93, 276, 147) & ~ell(224, 95, 274, 145), SAND['s'])   # bevel just inside the grinding edge
for gx, gy in ((232, 108), (262, 132), (236, 136), (266, 112), (228, 124), (254, 100)):   # sandstone grit
    cv.dots([(gx, gy), (gx + 1, gy)], SAND['s'])
draw((rrect(240, 111, 258, 129, 3), WOOD, {'d': 2}))   # bearing block on the axle
cv.fill(ell(245, 116, 253, 124), IRON['b'])
cv.fill(ell(247, 118, 251, 122), IRON['s'])
draw((line([(250, 120), (272, 104)], 3), IRON, {'d': 1}), (ell(267, 97, 278, 108), WOOD, {'d': 2}))   # crank arm and knob

HOTSPOTS = [
    {'id': 'rack', 'label': 'Tool rack', 'x': 2, 'y': 6, 'w': 90, 'h': 74},
    {'id': 'bench', 'label': 'Workbench', 'x': 2, 'y': 80, 'w': 90, 'h': 108},
    {'id': 'anvil', 'label': 'Anvil', 'x': 92, 'y': 30, 'w': 118, 'h': 158},
    {'id': 'toolbox', 'label': 'Toolbox', 'x': 210, 'y': 12, 'w': 88, 'h': 76},
    {'id': 'grindstone', 'label': 'Grindstone', 'x': 210, 'y': 88, 'w': 88, 'h': 100},
]

if __name__ == '__main__':
    out = sys.argv[1] if len(sys.argv) > 1 else None
    n = save_scene(cv, NAME, HOTSPOTS, out)
    print(NAME + ':', n, 'colours')
