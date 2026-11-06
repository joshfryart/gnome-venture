"""Crafting area scene (variant med): PANTRY. Usage: python3 -B aseprite-source/scenes-pil/craft_med_pantry.py
Writes aseprite-source/craftmap/scenes/med/pantry.png (1800 x 1200), pantry-thumb.png (450 x 300), pantry.json (hotspots), _hs-pantry.png check.
A cool plum larder lit by amber preserves (brief: claude/craftmap-scene-brief.md): cupboard of jam jars with gingham lids, a cloth-wrapped cheese
hanging from the beam, a wall shelf of cordial bottles, a pickle crock and a sauerkraut tub with its weight stone. Light from the upper left.
"""
import json
import os

from jigsaw_common import *  # noqa: F401,F403
from PIL import Image, ImageDraw

NAME = 'pantry'
OUTDIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'craftmap', 'scenes', 'med')

WALL, WSEAM, WLIT, WDARK = '#8a5a7a', '#6e4462', '#9a6a8a', '#7a4c6c'
FLOOR, FLOOR2, FSEAM, FSHADOW = '#6a4030', '#5e3828', '#4a2c1a', '#4f3022'
BEAM = ramp('#7a4a1f', '#5c3420', '#9a6b3f')
WOOD = ramp('#b07a3a', '#7a4a1f', '#d9a35a', '#8a5a2a', '#5c3420')
BACK, BACK2 = '#c9945a', '#b8844c'
GLASS = ramp('#e6dcea', '#b8a6c4', '#ffffff')
BGLASS = ramp('#d6c6de', '#a894b6', '#f4eef6')   # bottle glass, a touch deeper than the jars so it reads against the plum wall
PLUM = ramp('#7a2e7a', '#561c5a', '#a85aa8')
JRED = ramp('#c8282e', '#8a1a24', '#e8604a')
AMBER = ramp('#e8a317', '#b07a10', '#f5cf6a')
CREAM = ramp('#f2e4c0', '#d9bf8e', '#fff3c8')
LABEL = '#f2e4c0'
GINGP = ('#f2e4c0', '#a86ab0', '#6a2e72')   # light, mid, dark gingham checks
GINGR = ('#f2e4c0', '#e0605a', '#a8241f')
ROSE = ramp('#e46a9b', '#b8447a', '#f6b8cf')
HERB = ramp('#7ab55c', '#4f9a45', '#a4c86a')
CURR = ramp('#5a2a6a', '#3a1648', '#8a4a9a')
STONE = ramp('#a8a2a8', '#7a7480', '#cac4c8')
TAN = ramp('#d9b47a', '#a8824a', '#f0d49a', '#b88e56')
GLAZE = ramp('#8a4a2a', '#5c2e1a', '#b06a3a')
CABB = ramp('#a4c86a', '#7ab55c', '#d0e49a')
KRAUT = '#ece2a0'
GOLD = '#f5cf6a'

FY = 160
cv = new_canvas(WALL)
r = rnd(47)


def draw(*parts, **kw):
    o = cv.obj(**kw)
    for p in parts:
        o.part(*p[:2], **(p[2] if len(p) > 2 else {}))
    return o.draw()


def shadow(x0, y0, x1, y1):
    cv.fill(ell(x0, y0, x1, y1), FSHADOW)


def gingham(m, cols, x0, y0):
    """Paint a 2 px gingham check inside mask m."""
    ys, xs = np.nonzero(m)
    for y, x in zip(ys, xs):
        a, b = ((x - x0) // 2) % 2, ((y - y0) // 2) % 2
        cv.px[y, x] = P.hx(cols[a + b])


# ---------------------------------------------------------------- room: plum board wall, beam, plank floor
for x in range(0, W, 14):
    cv.fill(rect(x, 0, x, FY), WSEAM)
    cv.fill(rect(x + 1, 0, x + 1, FY), WLIT)
for _ in range(16):   # knots and grain ticks so the boards are calm but alive
    x, y = r(0, 20) * 14 + r(4, 9), r(16, 150)
    cv.fill(rect(x, y, x, y + r(3, 7)), WDARK)
cv.fill(rect(0, 0, W - 1, 9), BEAM['b'])
cv.fill(rect(0, 0, W - 1, 0), BEAM['r'])
cv.fill(rect(0, 8, W - 1, 9), BEAM['s'])
cv.fill(rect(0, 10, W - 1, 11), WSEAM)   # beam shadow
cv.fill(rect(0, FY, W - 1, H - 1), FLOOR)
for y in range(FY + 9, H, 10):
    cv.fill(rect(0, y, W - 1, y), FSEAM)
    off = ((y - FY) // 10 % 3) * 23
    for x in range(off, W, 70):
        cv.fill(rect(x, y + 1, x, y + 9), FSEAM)
        cv.fill(rect(x + 1, y + 1, x + 30, y + 1), FLOOR2)
cv.fill(rect(0, FY - 4, W - 1, FY), WOOD['s'])   # skirting board
cv.fill(rect(0, FY - 4, W - 1, FY - 4), WOOD['b'])

# ---------------------------------------------------------------- 1 jam cupboard (left)
cx0, cx1 = 8, 118
shadow(cx0 - 2, FY - 3, cx1 + 8, FY + 6)
carcass = rect(cx0, 20, cx1, FY)
crown = rect(cx0 - 4, 16, cx1 + 4, 22)
draw((carcass, WOOD, dict(d=3)), (crown, WOOD, dict(d=2, contour=True)))
cv.fill(rect(cx0 - 4, 16, cx1 + 4, 16), WOOD['r'])
cv.fill(rect(cx0 + 6, 23, cx1 - 6, 107), BACK)   # back panel of the open shelves
for x in range(cx0 + 20, cx1 - 6, 16):
    cv.fill(rect(x, 23, x, 107), BACK2)
cv.fill(rect(cx0 + 6, 23, cx1 - 6, 25), WOOD['s'])   # shadow under the crown
for sy in (63, 107):   # shelf boards
    cv.fill(rect(cx0 + 6, sy, cx1 - 6, sy + 3), WOOD['b'])
    cv.fill(rect(cx0 + 6, sy, cx1 - 6, sy), WOOD['r'])
    cv.fill(rect(cx0 + 6, sy + 3, cx1 - 6, sy + 3), WOOD['d'])
for dx0 in (cx0 + 6, (cx0 + cx1) // 2 + 1):   # two lower doors
    dx1 = dx0 + (cx1 - cx0) // 2 - 7
    cv.fill(rect(dx0, 113, dx1, FY - 5), WOOD['bo'])
    cv.fill(rect(dx0 + 4, 117, dx1 - 4, FY - 9), WOOD['b'])
    cv.fill(rect(dx0, 113, dx1, 113) | rect(dx0, 113, dx0, FY - 5), WOOD['r'])
    cv.fill(rect(dx0 + 4, FY - 9, dx1 - 4, FY - 9) | rect(dx1 - 4, 117, dx1 - 4, FY - 9), WOOD['s'])
kx = (cx0 + cx1) // 2
cv.fill(rect(kx - 4, 132, kx - 2, 135) | rect(kx + 3, 132, kx + 5, 135), GOLD)
cv.fill(rect(kx - 2, 135, kx - 2, 135) | rect(kx + 5, 135, kx + 5, 135), AMBER['s'])
JW, JH = 26, 25
fills = ((PLUM, GINGP), (AMBER, GINGR), (JRED, GINGP), (JRED, GINGP), (PLUM, GINGR), (AMBER, GINGP))
for row, base in enumerate((62, 106)):
    for c in range(3):
        jx = cx0 + 10 + c * 33
        jy = base - JH
        fill, ging = fills[row * 3 + c]
        jar = rrect(jx, jy, jx + JW - 1, base, 3)
        draw((jar, GLASS, dict(d=2)))
        jam = rrect(jx + 2, jy + 5, jx + JW - 3, base - 2, 2)
        cv.fill(jam, fill['b'])
        cv.fill(jam & ~shift(jam, -2, -2), fill['s'])
        cv.fill(rect(jx + 5, jy + 11, jx + JW - 6, jy + 18), LABEL)   # blank label
        cv.fill(rect(jx + 5, jy + 18, jx + JW - 6, jy + 18), CREAM['s'])
        cv.fill(rect(jx + 2, jy + 6, jx + 3, jy + 14), '#ffffff')   # glass glint
        cloth = rect(jx - 3, jy - 4, jx + JW + 2, jy + 4)
        for k in range(0, JW + 6, 5):   # scalloped skirt
            cloth |= rect(jx - 3 + k, jy + 5, jx - 1 + k, jy + 6) & rect(0, 0, jx + JW + 2, H)
        o = cv.obj()
        o.part(cloth, ramp(ging[1], ging[2], ging[0]), d=0)
        o.draw()
        gingham(cloth, ging, jx, jy)
        cv.fill(rect(jx - 2, jy + 2, jx + JW + 1, jy + 3), '#e8a317')   # gold string tie
        cv.fill(rect(jx + JW - 7, jy + 1, jx + JW - 5, jy + 5), '#e8a317')   # bow
        cv.dots([(jx + JW - 8, jy + 5), (jx + JW - 4, jy + 5)], '#b07a10')

# ---------------------------------------------------------------- 2 cheese wheel with a wedge cut out, hanging in a cloth sling knotted on a rope
CHEESE = ramp('#f8e08a', '#e8b84a', '#fff3c8')
RIND = ramp('#e8a317', '#c98a14', '#f5cf6a')
CX, CY, CR = 155, 57, 20   # wheel centre and radius
draw((line([(155, 10), (155, 25)], 2), BEAM, dict(d=0)))   # rope from the beam
for y in range(12, 25, 3):   # rope twist
    cv.fill(rect(155, y, 155, y), BEAM['r'])
straps = line([(153, 28), (135, 52), (134, 68)], 4) | line([(157, 28), (175, 52), (176, 68)], 4)   # sling straps behind the wheel
draw((straps, CREAM, dict(d=1)))
wheel = ell(CX - CR, CY - CR, CX + CR, CY + CR)
wedge = poly([(CX, CY), (CX + 30, CY - 30), (CX + 32, CY - 2), (CX + 30, CY + 1)])   # upper-right slice taken out
wheel &= ~wedge
draw((wheel, CHEESE, dict(d=2)))
rind = wheel & ~(ell(CX - CR + 3, CY - CR + 3, CX + CR - 3, CY + CR - 3))
cv.fill(rind, RIND['b'])
cv.fill(rind & ~shift(rind, 1, 1) & ~shift(wheel, 1, 1), RIND['r'])   # lit rind upper left
cv.fill(rind & ~shift(wheel, -1, -1), RIND['s'])
cut = wheel & ~shift(wedge, -1, 0) & dil4(dil4(wedge)) & ~rind   # fresh cut faces along the slice
cv.fill(cut, CHEESE['r'])
cv.fill(wheel & dil4(wedge) & rect(0, CY - 1, W, CY + 1) & ~rind, CHEESE['s'])   # thickness under the flat cut
for (x, y, w_, h_) in ((143, 47, 3, 3), (161, 62, 2, 2), (149, 60, 2, 2)):   # hard-pixel holes
    cv.fill(rect(x, y, x + w_ - 1, y + h_ - 1), CHEESE['s'])
    cv.fill(rect(x, y, x + w_ - 1, y) | rect(x, y, x, y + h_ - 1), RIND['s'])
sling = (ell(CX - CR - 2, CY - CR - 6, CX + CR + 2, CY + CR + 3) & rect(0, CY + 12, W, H)) | rect(CX - CR - 1, CY + 9, CX - CR + 2, CY + 12) | rect(CX + CR - 2, CY + 9, CX + CR + 1, CY + 12)
knot = ell(150, 22, 160, 31)
ears = poly([(151, 25), (146, 19), (148, 27)]) | poly([(159, 25), (164, 19), (162, 27)])
draw((sling, CREAM, dict(d=2)), (ears, CREAM, dict(d=1, contour=True)), (knot, CREAM, dict(d=2, contour=True)))
for x in range(CX - CR + 1, CX + CR, 3):   # stitched hem along the top of the sling
    cv.fill(rect(x, CY + 14, x + 1, CY + 14) & sling, GOLD)
for (a_, b_) in (((144, 74), (150, 78)), ((160, 73), (165, 77))):   # fold creases
    cv.fill(line([a_, b_]) & sling, CREAM['s'])
cv.fill(rect(151, 26, 159, 26) & knot, CREAM['s'])   # knot crease

# ---------------------------------------------------------------- 3 wall shelf of cordial bottles (right)
shelf = rect(196, 86, 294, 90)
brackets = poly([(204, 91), (212, 91), (204, 101)]) | poly([(278, 91), (286, 91), (286, 101)])
draw((brackets, WOOD, dict(d=1)), (shelf, WOOD, dict(d=2, contour=True)))
cv.fill(rect(196, 86, 294, 86), WOOD['r'])
for k, (liq, tall) in enumerate(((ROSE, 50), (AMBER, 56), (HERB, 46), (CURR, 54))):
    bx = 201 + k * 23
    top = 86 - tall
    body = rrect(bx, top + 16, bx + 17, 85, 4)
    neck = rect(bx + 6, top + 4, bx + 11, top + 17) | ell(bx + 2, top + 10, bx + 15, top + 24)
    cork = rrect(bx + 5, top - 1, bx + 12, top + 5, 1)
    draw((neck | body, BGLASS, dict(d=2)), (cork, TAN, dict(d=1, contour=True)))
    liqm = rrect(bx + 2, top + 22, bx + 15, 83, 3)
    cv.fill(liqm, liq['b'])
    cv.fill(liqm & ~shift(liqm, -2, -2), liq['s'])
    cv.fill(rect(bx + 2, top + 22, bx + 15, top + 22) & liqm, liq['r'])
    cv.fill(rect(bx + 3, top + 18, bx + 4, top + 30), '#ffffff')   # glint
    cv.fill(rect(bx + 4, 66, bx + 13, 74), LABEL)
    for x in range(bx + 5, bx + 13, 3):
        cv.fill(rect(x, 70, x + 1, 70), CREAM['s'])
    cv.fill(rect(bx + 5, top + 5, bx + 12, top + 5), '#e8a317')   # wax seal band

# ---------------------------------------------------------------- 4 pickle crock (centre front)
kx0, kx1 = 128, 184
KT, KB = 118, 184
shadow(kx0 - 2, KB - 5, kx1 + 6, KB + 4)
PICK = ramp('#6a9a3a', '#3f6a2a', '#9ac05a')
for (x0, y0, x1, y1) in ((143, KT + 2, 136, KT - 20), (154, KT + 2, 154, KT - 26), (165, KT + 2, 172, KT - 18)):   # pickles poking out of the brine
    pm = (line([(x0, y0), (x1, y1)], 8) | ell(x1 - 4, y1 - 4, x1 + 4, y1 + 4)) & rect(0, 0, W, KT + 1)
    draw((pm, PICK, dict(d=2)))
    for t in (0.25, 0.5, 0.75):   # bumps
        bx, by = int(x0 + (x1 - x0) * t), int(y0 + (y1 - y0) * t)
        cv.dots([(bx - 2, by), (bx + 1, by - 3)], PICK['r'])
crock = (rrect(kx0 + 2, KT, kx1 - 2, KB, 6) | ell(kx0, KT + 10, kx1, KB - 4)) & rect(0, KT, W, KB)
lip = rrect(kx0 + 2, KT - 3, kx1 - 2, KT + 4, 2)
draw((crock, TAN, dict(d=3)), (lip, GLAZE, dict(d=1, contour=True)))
cv.fill(rect(kx0 + 5, KT - 1, kx1 - 5, KT + 1), '#4a6a2a')   # brine
cv.fill(crock & rect(0, KT + 4, W, KT + 14), GLAZE['b'])   # brown glazed shoulder
cv.fill(crock & rect(0, KT + 13, W, KT + 14), GLAZE['s'])
cv.fill(crock & rect(0, KT + 4, kx0 + 6, KT + 14), GLAZE['r'])
for x in range(kx0 + 6, kx1 - 4, 3):   # stitched glaze seam (Stitched Toy)
    cv.fill(rect(x, KT + 17, x + 1, KT + 17) & crock, GOLD)
cv.fill(crock & rect(0, KT + 40, W, KT + 43), '#5f7fa8')   # blue painted band
cv.fill(crock & rect(0, KT + 40, W, KT + 40), '#8aa8c8')
cv.fill(rect(kx0 + 6, KT + 22, kx0 + 8, KT + 36), '#f6e2b0')
for (ex, ey) in ((kx0 - 3, KT + 8), (kx1 - 2, KT + 8)):   # lug handles
    draw((rrect(ex, ey, ex + 5, ey + 7, 1), GLAZE, dict(d=1)))

# ---------------------------------------------------------------- 5 sauerkraut tub with lid, weight stone and a cabbage
tx0, tx1 = 202, 292
TT, TB = 136, 192
shadow(tx0 - 2, TB - 5, tx1 + 6, TB + 5)
tub = (rrect(tx0 + 3, TT, tx1 - 3, TB, 4) | ell(tx0, TT + 4, tx1, TB - 4)) & rect(0, TT, W, TB)
rimm = ell(tx0 + 3, TT - 9, tx1 - 3, TT + 9)
lid = ell(tx0 + 10, TT - 6, tx1 - 10, TT + 6)
draw((tub | rimm, WOOD, dict(d=3)))
cv.fill(rimm & ~shift(rimm, 0, 2) & rect(0, 0, W, TT), WOOD['r'])
cv.fill(ell(tx0 + 7, TT - 7, tx1 - 7, TT + 7), WOOD['d'])   # inside of the tub
cv.fill(ell(tx0 + 8, TT - 4, tx1 - 8, TT + 7), KRAUT)   # kraut round the lid
draw((lid, ramp('#d9a35a', '#b07a3a', '#f2c87a'), dict(d=2)), outline=False)
cv.fill(lid & ~shift(lid, 1, 1) & ~shift(lid, -1, -1), '#7a4a1f')
for x in range(tx0 + 10, tx1 - 4, 10):
    cv.fill(rect(x, TT + 10, x, TB - 2) & tub, WOOD['s'])
for y in (TT + 12, TB - 15):
    hm = rect(0, y, W, y + 3) & tub
    cv.fill(hm, '#5a4650')
    cv.fill(hm & rect(0, y, W, y), '#7a6670')
for x in range(tx0 + 22, tx1 - 16, 12):   # lid boards
    cv.fill(rect(x, TT - 5, x, TT + 5) & lid, '#b07a3a')
draw((ell(216, 114, 246, 134), STONE, dict(d=2)))   # weight stone
cv.fill(rect(222, 118, 226, 119), STONE['r'])
cab = ell(248, 102, 282, 134)
draw((cab, CABB, dict(d=3)))
for (a, b) in (((265, 108), (265, 132)), ((258, 112), (262, 130)), ((273, 112), (269, 130))):
    cv.fill(line([a, b]), CABB['s'])
cv.fill(poly([(250, 116), (256, 108), (258, 122)]), CABB['r'])

HOTSPOTS = [
    ('jams', 'Jam cupboard', 2, 12, 124, 156),
    ('cheese', 'Hanging cheese', 126, 14, 58, 72),
    ('cordials', 'Cordial bottles', 192, 20, 106, 82),
    ('crock', 'Pickle crock', 126, 90, 66, 102),
    ('kraut', 'Sauerkraut tub', 196, 102, 104, 96),
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
