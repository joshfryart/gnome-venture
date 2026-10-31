"""Crafting area scene (variant med): ALCHEMY station. Usage: python3 -B aseprite-source/scenes-pil/craft_med_alchemy.py
Writes aseprite-source/craftmap/scenes/med/alchemy.png (1800 x 1200), alchemy-thumb.png (450 x 300), alchemy.json (hotspots), _hs-alchemy.png check.
A violet stone workshop with teal glow and gold glints (brief: claude/craftmap-scene-brief.md): wall shelf of round potion flasks, mortar and pestle
on a bench, the bubbling teal cauldron over a fire, a copper still with its tube and receiving flask, a book stand. Light from the upper left.
"""
import json
import os

from jigsaw_common import *  # noqa: F401,F403
from PIL import Image, ImageDraw

NAME = 'alchemy'
OUTDIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'craftmap', 'scenes', 'med')

WALL, WMORT, WLIT, WDARK = '#5a4680', '#46346a', '#6a5690', '#503e76'
FLOOR, FLOOR2, FSEAM, FSHADOW = '#3a6266', '#33585c', '#24404a', '#2a4850'
WOOD = ramp('#9a6b3f', '#6a4428', '#c9945a', '#7a5030', '#4a2c1a')
GLASS = ramp('#d4ecea', '#9cc4c4', '#ffffff')
TEAL = ramp('#2fb5a0', '#1f7f78', '#7ae0c8', '#26968a')
VIOL = ramp('#8a5cc0', '#5e3c90', '#c3b2ea')
GOLD = ramp('#e8a317', '#b07a10', '#f5cf6a')
ROSE = ramp('#e46a9b', '#b8447a', '#f6b8cf')
AMB = ramp('#f08a24', '#c86414', '#f5b04a')
IRON = ramp('#4a4050', '#2e2834', '#6a6070')
COPPER = ramp('#d9803a', '#a8562a', '#f5b070', '#b8602e')
STONE = ramp('#a8a2b0', '#76707e', '#cac4d0')
PAGE = ramp('#f2e4c0', '#d9bf8e', '#fff3c8')
CORK = ramp('#c9a96e', '#9a6b3f', '#e0c890')
FIRE1, FIRE2, FIRE3 = '#f08a24', '#f5cf6a', '#fff4c8'

FY = 160
cv = new_canvas(WALL)
r = rnd(53)


def draw(*parts, **kw):
    o = cv.obj(**kw)
    for p in parts:
        o.part(*p[:2], **(p[2] if len(p) > 2 else {}))
    return o.draw()


def shadow(x0, y0, x1, y1):
    cv.fill(ell(x0, y0, x1, y1), FSHADOW)


def sparkle(x, y, big=False, col=GOLD['r']):
    """Four-point gold twinkle (as on the potions tile)."""
    k = 3 if big else 2
    cv.fill(rect(x - k, y, x + k, y) | rect(x, y - k, x, y + k), col)
    if big:
        cv.dots([(x, y)], '#fff4c8')


def flask(cx, base, rad, liq, neck=7, tall=False):
    """Round (or tall) glass flask standing on `base`, cork on top, liquid in the lower part."""
    if tall:
        body = rrect(cx - rad, base - rad * 3, cx + rad, base, 3)
    else:
        body = ell(cx - rad, base - rad * 2, cx + rad, base)
    top = base - (rad * 3 if tall else rad * 2)
    nk = rect(cx - 2, top - neck, cx + 2, top + 2)
    cork = rrect(cx - 3, top - neck - 4, cx + 3, top - neck, 1)
    draw((nk | body, GLASS, dict(d=2)), (cork, CORK, dict(d=1, contour=True)))
    lm = body & ~dil4(~body) & rect(0, top + (rad if not tall else rad + 2), W, H)
    lm &= ~shift(~body, 0, -1)
    cv.fill(lm, liq['b'])
    cv.fill(lm & ~shift(lm, -2, -2), liq['s'])
    cv.fill(lm & ~shift(lm, 0, 1), liq['r'])
    cv.fill(rect(cx - rad + 2, top + 3, cx - rad + 3, top + 6 + rad // 2) & body, '#ffffff')   # glass glint


# ---------------------------------------------------------------- room: violet block wall, teal flagstone floor
for row, y in enumerate(range(12, FY, 16)):
    cv.fill(rect(0, y, W - 1, y + 1), WMORT)
    off = (row % 2) * 20
    for x in range(off - 40, W, 40):
        cv.fill(rect(x, y, x + 1, y + 16), WMORT)
        cv.fill(rect(x + 2, y + 2, x + 38, y + 2), WLIT)   # lit top edge of each block
        if r(0, 3) == 0:
            cv.fill(rect(x + 4 + r(0, 20), y + 6 + r(0, 6), x + 10 + r(0, 20), y + 7 + r(0, 6)), WDARK)
cv.fill(rect(0, 0, W - 1, 11), '#3e2c5c')   # dark vault band at the top
cv.fill(rect(0, 10, W - 1, 11), WMORT)
cv.fill(rect(0, FY, W - 1, H - 1), FLOOR)
for k, y in enumerate(range(FY, H, 13)):
    cv.fill(rect(0, y, W - 1, y), FSEAM)
    for x in range((k % 2) * 22 - 44, W, 44):
        cv.fill(rect(x, y, x, y + 12), FSEAM)
        cv.fill(rect(x + 1, y + 1, x + 43, y + 1), '#467478')
        if (x // 44 + k) % 3 == 0:
            cv.fill(rect(x + 1, y + 2, x + 43, y + 12), FLOOR2)
cv.fill(rect(0, FY, W - 1, FY + 1), FSEAM)

# ---------------------------------------------------------------- 1 wall shelf of potion flasks (top left)
for sy in (54, 94):
    board = rect(6, sy, 100, sy + 4)
    br = poly([(14, sy + 5), (22, sy + 5), (14, sy + 13)]) | poly([(84, sy + 5), (92, sy + 5), (92, sy + 13)])
    draw((br, WOOD, dict(d=1)), (board, WOOD, dict(d=2, contour=True)))
    cv.fill(rect(6, sy, 100, sy), WOOD['r'])
flask(24, 53, 11, TEAL)
flask(52, 53, 8, VIOL, neck=9, tall=True)
flask(80, 53, 10, ROSE)
flask(22, 93, 8, GOLD, tall=True)
flask(50, 93, 12, TEAL)
flask(80, 93, 9, VIOL)
sparkle(38, 22, True)
sparkle(66, 66, True)

# ---------------------------------------------------------------- 2 bench with mortar and pestle (bottom left)
bx0, bx1 = 6, 98
BT = 150
shadow(bx0 - 2, 182, bx1 + 6, 190)
legs = rect(bx0 + 6, BT + 8, bx0 + 12, 186) | rect(bx1 - 12, BT + 8, bx1 - 6, 186)
top = rrect(bx0, BT, bx1, BT + 8, 1)
draw((legs | rect(bx0 + 12, 172, bx1 - 12, 175), WOOD, dict(d=2)), (top, WOOD, dict(d=2, contour=True)))
cv.fill(rect(bx0 + 1, BT, bx1 - 1, BT), WOOD['r'])
cv.fill(rect(bx0 + 1, BT + 4, bx1 - 1, BT + 4), WOOD['bo'])
MX = 50
pestle = line([(MX + 6, BT - 26), (MX + 26, BT - 36)], 7) | ell(MX + 22, BT - 42, MX + 33, BT - 32)
bowl = (ell(MX - 26, BT - 52, MX + 26, BT - 4) & rect(0, BT - 28, W, H)) | rrect(MX - 12, BT - 8, MX + 12, BT - 1, 1)
lip = rrect(MX - 28, BT - 31, MX + 28, BT - 25, 2)
draw((pestle, ramp('#c9945a', '#9a6b3f', '#e0b47a'), dict(d=2)))
draw((bowl, STONE, dict(d=3)), (lip, STONE, dict(d=2, contour=True)))
cv.fill(rect(MX - 24, BT - 30, MX + 24, BT - 28), '#4a4458')   # dark hollow of the bowl
cv.fill(rect(MX - 22, BT - 29, MX - 6, BT - 28), TEAL['s'])   # ground herb inside
cv.fill(rect(MX + 6, BT - 31, MX + 9, BT - 28), '#9a6b3f')   # pestle going in
cv.fill(rect(MX - 28, BT - 31, MX + 28, BT - 31) & lip, STONE['r'])
for x in range(MX - 22, MX + 22, 3):   # stitched band round the mortar
    cv.fill(rect(x, BT - 19, x + 1, BT - 19) & bowl, GOLD['r'])
cv.fill(rect(MX - 20, BT - 22, MX - 18, BT - 14), STONE['g'] if STONE['g'] else '#e0dce6')
for (x, y) in ((82, BT - 3), (86, BT - 5), (90, BT - 3)):   # a few loose seeds
    cv.fill(rect(x, y, x + 2, y + 2), GOLD['b'])
    cv.dots([(x, y)], GOLD['r'])

# ---------------------------------------------------------------- 3 bubbling cauldron over a fire (centre)
cx0, cx1 = 106, 186
CT, CB = 116, 166
shadow(cx0 - 4, 182, cx1 + 6, 192)
legs = poly([(cx0 + 10, CB - 8), (cx0 + 18, CB - 8), (cx0 + 10, 188), (cx0 + 4, 188)]) | poly([(cx1 - 18, CB - 8), (cx1 - 10, CB - 8), (cx1 - 4, 188), (cx1 - 10, 188)])
logs = rrect(cx0 + 14, 180, cx1 - 14, 186, 2)
draw((logs, WOOD, dict(d=1)))
fl = poly([(cx0 + 16, 182), (cx0 + 20, 166), (cx0 + 27, 174), (134, 162), (140, 172), (146, 160), (152, 172), (158, 162), (cx1 - 27, 174), (cx1 - 20, 166), (cx1 - 16, 182)])
cv.fill(fl, FIRE1)
cv.fill(poly([(cx0 + 24, 182), (134, 170), (140, 176), (146, 168), (152, 176), (158, 170), (cx1 - 24, 182)]), FIRE2)
cv.fill(poly([(140, 182), (146, 174), (152, 182)]), FIRE3)
pot = ell(cx0, CT - 30, cx1, CB) & rect(0, CT, W, H)
rim = rrect(cx0 - 2, CT - 4, cx1 + 2, CT + 4, 3)
draw((legs, IRON, dict(d=1)), (pot, IRON, dict(d=3)), (rim, IRON, dict(d=2, contour=True)))
cv.fill(rect(cx0, CT - 4, cx1, CT - 4), IRON['r'])
brew = rrect(cx0 + 3, CT - 2, cx1 - 3, CT + 1, 1)
cv.fill(brew, TEAL['b'])
cv.fill(rect(cx0 + 5, CT - 2, cx0 + 40, CT - 2), TEAL['r'])
for x in range(cx0 + 4, cx1 - 3, 3):   # gold stitched band on the pot belly
    cv.fill(rect(x, CT + 8, x + 1, CT + 8) & pot & ~dil4(~pot), GOLD['b'])
cv.fill(rect(cx0 + 12, CT + 16, cx0 + 14, CT + 18) | rect(cx0 + 10, CT + 19, cx0 + 11, CT + 26), '#7a6a8a')   # iron gloss comma
drip = rrect(cx0 + 52, CT, cx0 + 57, CT + 9, 2) | ell(cx0 + 51, CT + 6, cx0 + 58, CT + 12)
cv.fill(drip, TEAL['b'])   # brew spilling over the rim
cv.fill(drip & ~shift(drip, -1, -1), TEAL['s'])
cv.dots([(cx0 + 53, CT + 7)], TEAL['r'])
for (bx, by, s) in ((128, 102, 5), (148, 92, 6), (166, 104, 4), (140, 78, 4), (160, 70, 3), (150, 56, 3)):   # bubbles rising
    m = ell(bx - s, by - s, bx + s, by + s)
    ring = m & ~ell(bx - s + 1, by - s + 1, bx + s - 1, by + s - 1)
    cv.fill(m, TEAL['b'] if s > 3 else TEAL['r'])
    cv.fill(m & ~shift(m, -1, -1), TEAL['s'])
    cv.fill(ring & rect(0, 0, bx, by), TEAL['r'])
    cv.dots([(bx - s // 2, by - s // 2)], '#ffffff')
for (bx, by) in ((122, 108), (134, 110), (160, 109), (174, 108)):   # surface bubbles
    cv.fill(ell(bx - 3, by - 3, bx + 3, by + 2), TEAL['r'])
sparkle(118, 82, True)
sparkle(176, 86)

# ---------------------------------------------------------------- 4 copper still with tube and receiving flask (right centre)
sx0, sx1 = 194, 234
shadow(sx0 - 4, FY + 20, 258, FY + 28)
stand = rect(sx0 + 4, 168, sx0 + 7, 186) | rect(sx1 - 7, 168, sx1 - 4, 186) | rect(sx0 + 2, 166, sx1 - 2, 169)
boiler = ell(sx0, 128, sx1, 170)
head = ell(sx0 + 10, 108, sx1 - 10, 132)
cap = rect(213, 102, 215, 110)
tube = line([(220, 114), (236, 104), (244, 104), (248, 112), (248, 146)], 3)
recv = ell(236, 150, 260, 176) | rect(244, 142, 252, 152)
draw((stand, IRON, dict(d=1)))
cv.fill(rect(sx0 + 8, 172, sx1 - 8, 182), FIRE1)   # burner glow under the boiler
cv.fill(rect(sx0 + 12, 176, sx1 - 12, 182), FIRE2)
cv.fill(rect(sx0 + 6, 182, sx1 - 6, 186), IRON['b'])
draw((tube, COPPER, dict(d=1)))
draw((boiler, COPPER, dict(d=3)), (head, COPPER, dict(d=2, contour=True)), (cap, COPPER, dict(d=1)))
cv.fill(rect(sx0 + 6, 138, sx0 + 8, 140) | rect(sx0 + 5, 141, sx0 + 6, 146), '#ffc27a')   # copper gloss
for x in range(sx0 + 2, sx1 - 1, 3):
    cv.fill(rect(x, 156, x + 1, 156) & boiler & ~dil4(~boiler), GOLD['r'])
for y in (140, 148):   # rivets
    cv.dots([(sx1 - 6, y)], COPPER['s'])
draw((recv, GLASS, dict(d=2)), (rect(234, 176, 262, 180), WOOD, dict(d=1)))
lm = ell(238, 160, 258, 174) & ell(237, 151, 259, 175)
cv.fill(lm, VIOL['b'])
cv.fill(lm & ~shift(lm, -2, -2), VIOL['s'])
cv.fill(rect(239, 158, 240, 164), '#ffffff')
cv.dots([(248, 148), (248, 150)], VIOL['r'])   # a drip falling in
sparkle(204, 96)

# ---------------------------------------------------------------- 5 book stand with an open spell book (right)
lx = 280
shadow(262, 184, 298, 192)
post = rect(lx - 3, 130, lx + 3, 186)
feet = rrect(264, 184, 296, 189, 1)
desk = poly([(261, 122), (297, 110), (299, 126), (265, 136)])
draw((post | feet, WOOD, dict(d=2)), (desk, WOOD, dict(d=2, contour=True)))
cover = poly([(260, 106), (299, 92), (299, 117), (263, 130)])
pages = poly([(262, 104), (280, 97), (282, 122), (265, 127)]) | poly([(280, 97), (297, 90), (297, 114), (282, 122)])
draw((cover, VIOL, dict(d=1)))
draw((pages, PAGE, dict(d=2)), outline=False)
cv.fill(line([(280, 97), (282, 122)]), PAGE['s'])
for k in range(5):   # squiggle script lines (not text)
    cv.fill(line([(266, 107 + k * 3), (277, 103 + k * 3)]), '#8a6a9a')
    cv.fill(line([(285, 101 + k * 3), (294, 97 + k * 3)]), '#8a6a9a')
draw((ell(284, 109, 292, 117), GOLD, dict(d=1)), outline=False)   # gold sigil on the right page
cv.dots([(287, 112)], '#fff4c8')
cv.fill(rect(276, 122, 277, 140), GOLD['b'])   # ribbon
cv.fill(rect(276, 140, 277, 141), GOLD['s'])
sparkle(266, 86, True)

HOTSPOTS = [
    ('potions', 'Potion shelf', 2, 12, 102, 96),
    ('mortar', 'Mortar and pestle', 2, 108, 102, 86),
    ('cauldron', 'Cauldron', 104, 50, 86, 146),
    ('still', 'Still', 190, 92, 70, 104),
    ('book', 'Book stand', 260, 80, 40, 116),
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
