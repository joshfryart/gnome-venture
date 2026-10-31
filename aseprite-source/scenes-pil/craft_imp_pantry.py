"""Crafting area scene: PANTRY (variant imp). Usage: python3 -B aseprite-source/scenes-pil/craft_imp_pantry.py [outdir]
Writes aseprite-source/craftmap/scenes/imp/pantry.png (1800 x 1200), pantry-thumb.png (450 x 300), pantry.json (hotspots) and pantry_hs.png.
Brief: claude/craftmap-scene-brief.md. Clean and clear, five big tap targets on a calm dusty-plum wall:
hero = tall shelf of jam jars with gingham lids (left); centre = garlic string and muslin cheese hanging from the beam over a
blue-banded pickle crock; right = amber, ruby and green cordial bottles on a wall shelf over a sauerkraut barrel.
"""
import json
import os
import sys

from jigsaw_common import *  # noqa: F401,F403
from PIL import Image, ImageDraw

NAME = 'pantry'
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




# ---------------------------------------------------------------- palette (plum / amber / glass)
WALL, WALL_S = '#b494aa', '#a08298'
FLOOR, FLOOR_S, FLOOR_L = '#8a7a86', '#6e606c', '#a89aa4'
SHADOW = '#5a4a58'
WOOD = ramp('#9a6b3f', '#7a4a1f', '#c9a96e', '#8a5a30')
DWOOD = ramp('#7a4a1f', '#5c3420', '#9a6b3f')
GLASS = ramp('#d8ecf0', '#a9c8d4', '#ffffff')
PLUM = ramp('#7a2f6e', '#55204e', '#a8509a')
BERRY = ramp('#c0324a', '#8a2034', '#e86a7a')
APRI = ramp('#e8a317', '#b07a10', '#f5cf6a')
CHECK_A, CHECK_B = '#e46a9b', '#fff4f0'
TWINE = ramp('#e8a317', '#b07a10', '#f5cf6a')
CROCK = ramp('#e6dccb', '#b8ab96', '#fffaf0', '#cfc3ae')
CROCKBAND = '#5a7aa8'
PICKLE = ramp('#7a9432', '#566c22', '#a8c060')
GARLIC = ramp('#f1ece0', '#c9b8a6', '#ffffff')
MUSLIN = ramp('#efe2c4', '#c9b48e', '#fff8e6')
KRAUT = ramp('#e4e0a0', '#b4b060', '#fafad0')   # pale green-yellow cabbage, not straw
AMBER = ramp('#e8901f', '#b0620f', '#f8c060')
RUBY = ramp('#b02a4a', '#7a1a34', '#e0607a')
LEAF = ramp('#5a9a5a', '#3a7a44', '#8ac07a')
CORK = ramp('#c9a96e', '#9a7a4a', '#e8d4a0')
UMB = '#2a1a10'

cv = new_canvas(WALL)


def rell(cx, cy, rx, ry, a):
    """Rotated ellipse mask (angle a in radians, screen coords)."""
    yy, xx = np.mgrid[0:H, 0:W]
    dx, dy = xx - cx, yy - cy
    u, v = dx * np.cos(a) + dy * np.sin(a), -dx * np.sin(a) + dy * np.cos(a)
    return (u / rx) ** 2 + (v / ry) ** 2 <= 1


def shadow(x0, y0, x1, y1):
    cv.fill(ell(x0, y0, x1, y1), SHADOW)


def draw(*parts):
    o = cv.obj()
    for p in parts:
        o.part(*p[:2], **(p[2] if len(p) > 2 else {}))
    return o.draw()


# ---------------------------------------------------------------- room: beam with hooks, plum plaster, stone-flag floor
cv.fill(rect(0, 0, W - 1, 7), DWOOD['b'])
cv.fill(rect(0, 6, W - 1, 7), DWOOD['s'])
cv.fill(rect(0, 0, W - 1, 0), DWOOD['r'])
cv.fill(rect(0, 8, W - 1, 8), WALL_S)
for bx in (70, 210):
    cv.fill(rect(bx, 1, bx, 5), DWOOD['s'])
FY = 152
cv.fill(rect(0, FY, W - 1, H - 1), FLOOR)
for k, y in enumerate((FY + 14, FY + 31)):   # three rows of big flags
    cv.fill(rect(0, y, W - 1, y), FLOOR_S)
for k, (y0, y1) in enumerate(((FY, FY + 13), (FY + 15, FY + 30), (FY + 32, H - 1))):
    for jx in range(20 + k * 23, W, 64):
        cv.fill(rect(jx, y0, jx, y1), FLOOR_S)
        cv.fill(rect(jx + 1, y0 + 1, jx + 1, y0 + 3), FLOOR_L)
cv.fill(rect(0, FY, W - 1, FY), FLOOR_L)
cv.fill(rect(0, FY - 4, W - 1, FY - 1), DWOOD['b'])
cv.fill(rect(0, FY - 4, W - 1, FY - 4), DWOOD['r'])

# ---------------------------------------------------------------- HERO: shelf of jam jars with gingham lids (left)
SX0, SX1, ST, SB = 8, 124, 12, 180
shadow(SX0 - 2, SB - 4, SX1 + 8, SB + 4)
draw((rect(SX0, ST, SX0 + 6, SB) | rect(SX1 - 6, ST, SX1, SB), WOOD, {'d': 2}),
     (rect(SX0 + 7, ST + 2, SX1 - 7, SB - 2), ramp('#6e4a5e', '#5a3a4c', '#7e5a6e'), {'d': 0, 'rim': False}))   # dark back board
draw((rect(SX0 - 3, ST - 3, SX1 + 3, ST + 2), WOOD, {'d': 2}))   # crown
for k in range(3):   # back-board planks
    x = SX0 + 7 + (k + 1) * 26
    cv.fill(rect(x, ST + 3, x, SB - 3), '#5a3a4c')
BOARDS = (66, 122)
for by in BOARDS:
    draw((rect(SX0 - 2, by, SX1 + 2, by + 4), WOOD, {'d': 2}))
draw((rect(SX0 + 7, 127, SX1 - 7, SB - 2), WOOD, {'d': 2}))   # cupboard below
for dx0, dx1 in ((SX0 + 10, (SX0 + SX1) // 2 - 2), ((SX0 + SX1) // 2 + 2, SX1 - 10)):
    o = cv.obj()
    o.part(rect(dx0, 131, dx1, SB - 6), WOOD, d=1, contour=True)
    o.draw()
    cv.fill(rect(dx0 + 3, 134, dx1 - 3, 134), WOOD['r'])
    cv.fill(rect(dx0 + 3, 134, dx0 + 3, SB - 9), WOOD['r'])
cv.fill(rect((SX0 + SX1) // 2 - 5, 150, (SX0 + SX1) // 2 - 4, 154) | rect((SX0 + SX1) // 2 + 4, 150, (SX0 + SX1) // 2 + 5, 154), APRI['b'])   # knobs


def jar(x, base, w, h, fill):
    """A glass jar standing on y=base: jam inside, gingham cloth over the lid tied with twine."""
    body = rrect(x, base - h, x + w, base - 1, 3)
    o = cv.obj()
    o.part(body, GLASS, d=2)
    o.draw()
    jam = rrect(x + 2, base - h + 7, x + w - 2, base - 3, 2)
    cv.fill(jam, fill['b'])
    cv.fill(jam & ~shift(jam, -2, -2), fill['s'])
    cv.fill(jam & rect(0, base - h + 7, W, base - h + 7), fill['r'])
    cv.fill(rect(x + 2, base - h + 9, x + 3, base - 6), GLASS['r'])   # glass glint
    cv.fill(rect(x + 2, base - h + 9, x + 3, base - h + 11), '#ffffff')
    cloth = rrect(x - 3, base - h - 5, x + w + 3, base - h + 4, 2) | poly([(x - 4, base - h + 2), (x + w + 4, base - h + 2), (x + w + 2, base - h + 8), (x - 2, base - h + 8)])
    o = cv.obj()
    o.part(cloth, ramp(CHECK_B, '#e8c8d0'), d=1)
    o.draw()
    ys, xs = np.nonzero(cloth & ~dil4(~cloth))
    for yy, xx in zip(ys, xs):   # 2 x 2 gingham check
        if ((xx // 2) + (yy // 2)) % 2 == 0:
            cv.px[yy, xx] = P.hx(CHECK_A)
    for xx in range(x - 3, x + w + 4, 3):   # pinked frill edge
        cv.dots([(xx, base - h + 9)], CHECK_A)
    cv.fill(rect(x - 2, base - h + 3, x + w + 2, base - h + 4), TWINE['b'])   # twine
    cv.dots([((x * 2 + w) // 2 - 1, base - h + 5), ((x * 2 + w) // 2 + 1, base - h + 5), ((x * 2 + w) // 2, base - h + 6)], TWINE['s'])


JW = 26
for row, (base, fills, hs) in enumerate(((66, (PLUM, BERRY, PLUM), (28, 24, 30)), (122, (APRI, PLUM, PLUM), (24, 30, 26)))):
    for k in range(3):
        jar(SX0 + 11 + k * 36, base, JW, hs[k], fills[k])

# ---------------------------------------------------------------- CENTRE TOP: garlic string and cloth-wrapped cheese hanging from the beam
for hx0 in (148, 178):
    draw((rect(hx0 - 1, 6, hx0 + 1, 10), ramp('#767c90', '#4e5262', '#b8c0d0'), {'d': 1}))   # iron hooks
cv.fill(rect(148, 10, 148, 16), TWINE['s'])
gar = blank()
bulbs = []
for k in range(7):   # braided garlic: bulbs alternate left/right down the string
    gx = 148 + (-5 if k % 2 else 4)
    gy = 18 + k * 9
    bulbs.append((gx, gy))
    gar |= ell(gx - 6, gy - 5, gx + 6, gy + 5)
o = cv.obj()
for gx, gy in bulbs:
    o.part(ell(gx - 6, gy - 5, gx + 6, gy + 5) | poly([(gx - 1, gy - 8), (gx + 1, gy - 8), (gx + 3, gy - 3), (gx - 3, gy - 3)]), GARLIC, d=2, contour=True)
o.draw()
for gx, gy in bulbs:
    cv.fill(rect(gx, gy - 3, gx, gy + 3), GARLIC['s'])
    cv.dots([(gx - 3, gy - 1), (gx + 3, gy - 1)], '#d9b8c8')

# cheese in muslin
cv.fill(rect(178, 10, 178, 26), TWINE['s'])
chz = ell(158, 40, 198, 68)   # a squat cheese wheel in muslin, cloth gathered into a ruff at the top
ruff = poly([(170, 30), (186, 30), (190, 40), (166, 40)]) | ell(168, 24, 188, 33)
draw((ruff, MUSLIN, {'d': 2}), (chz, MUSLIN, {'d': 3, 'contour': True}))
cv.fill(rect(172, 34, 184, 36), TWINE['b'])   # tie
for fx in (172, 177, 182):   # ruff pleats
    cv.fill(rect(fx, 25, fx, 31), MUSLIN['s'])
peel = poly([(176, 56), (194, 54), (190, 66), (178, 66)]) & chz   # the cloth folded back shows the waxed rind
cv.fill(peel, '#e8a317')
cv.fill(peel & ~shift(peel, -1, -1), '#b07a10')
cv.fill(line([(176, 56), (194, 54)]), MUSLIN['r'])
for k, (a, b) in enumerate((((162, 48), (176, 40)), ((160, 56), (182, 41)), ((180, 41), (196, 52)), ((170, 66), (186, 43)))):   # twine net
    cv.fill(line([a, b]) & chz & ~peel, TWINE['s'])

# ---------------------------------------------------------------- CENTRE BOTTOM: pickle crock
CX0, CX1, CY0, CY1 = 138, 196, 116, 184
shadow(CX0 - 2, CY1 - 4, CX1 + 8, CY1 + 4)
crock = blank()
for y in range(CY0 + 8, CY1 + 1):   # stoneware belly, narrower at the neck and foot
    t = (y - CY0 - 8) / (CY1 - CY0 - 8)
    hw = (CX1 - CX0) / 2 - 4 + int(round(5 * (1 - (2 * t - 1.1) ** 2)))
    crock[y, int((CX0 + CX1) / 2 - hw):int((CX0 + CX1) / 2 + hw) + 1] = True
crock &= ~(rect(0, CY1, W, CY1) & ~rect(CX0 + 4, 0, CX1 - 4, H))
# pickles first, so the rim overlaps them: fat capsules with bumps, leaning out of the crock
import math
def stadium(x0, y0, x1, y1, rad):
    """Blunt capsule between two points: a gherkin, not a leaf."""
    yy, xx = np.mgrid[0:H, 0:W]
    dx, dy = x1 - x0, y1 - y0
    t = np.clip(((xx - x0) * dx + (yy - y0) * dy) / float(dx * dx + dy * dy), 0, 1)
    return (xx - x0 - t * dx) ** 2 + (yy - y0 - t * dy) ** 2 <= rad * rad


lipm = ell(CX0, CY0, CX1, CY0 + 14)
brine = ell(CX0 + 5, CY0 + 3, CX1 - 5, CY0 + 11)
draw((lipm, CROCK, {'d': 1}))   # back of the rim
cv.fill(brine, '#3a4a2a')   # dark brine in the mouth
cv.fill(brine & rect(0, CY0 + 9, W, H), '#4a5e30')
for x0, y0, x1, y1 in ((148, CY0 + 4, 166, CY0 - 4), (188, CY0 + 4, 170, CY0 - 6), (156, CY0 - 6, 178, CY0 - 13)):   # a heap of gherkins at shallow angles
    draw((stadium(x0, y0, x1, y1, 5), PICKLE, {'d': 2}))
    for k in (1, 2, 3, 4):   # warts along the gherkin
        tx, ty = x1 + (x0 - x1) * k // 5, y1 + (y0 - y1) * k // 5
        cv.dots([(tx - 2 + (k % 2) * 3, ty)], PICKLE['r'])
        cv.dots([(tx + 1 - (k % 2) * 3, ty + 1)], PICKLE['s'])
draw((crock, CROCK, {'d': 3}), (lipm & ~brine & rect(0, CY0 + 8, W, H), CROCK, {'d': 1, 'contour': True}))
cv.fill(crock & rect(0, CY0 + 26, W, CY0 + 29), CROCKBAND)
cv.fill(crock & rect(0, CY0 + 50, W, CY0 + 51), CROCKBAND)
for wx in range(CX0 + 8, CX1 - 4, 10):   # painted wave on the band
    cv.dots([(wx, CY0 + 38), (wx + 1, CY0 + 37), (wx + 2, CY0 + 37), (wx + 3, CY0 + 38), (wx + 4, CY0 + 39), (wx + 5, CY0 + 39)], CROCKBAND)

# ---------------------------------------------------------------- RIGHT TOP: cordial bottles on a wall shelf
draw((rect(212, 84, 296, 88), WOOD, {'d': 2}), (poly([(220, 89), (226, 89), (220, 100)]) | poly([(282, 89), (288, 89), (288, 100)]), WOOD, {'d': 1}))


def bottle(x, top, w, rp, neck=5):
    base = 83
    nx = x + w // 2 - neck // 2
    o = cv.obj()
    o.part(rect(nx, top, nx + neck - 1, top + 12) | rrect(x, top + 14, x + w, base, 4) | poly([(nx - 1, top + 10), (nx + neck, top + 10), (x + w, top + 18), (x, top + 18)]), GLASS, d=2)
    o.part(rect(nx - 1, top - 5, nx + neck, top), CORK, d=1, contour=True)
    o.draw()
    liq = rrect(x + 2, top + 22, x + w - 2, base - 2, 3)
    cv.fill(liq, rp['b'])
    cv.fill(liq & ~shift(liq, -2, -2), rp['s'])
    cv.fill(liq & rect(0, top + 22, W, top + 22), rp['r'])
    cv.fill(rect(x + 3, top + 24, x + 4, base - 6), '#ffffff')
    cv.fill(rect(x + 2, top + 40, x + w - 2, top + 48) & liq, '#f1ece0')   # blank paper label (no text)
    cv.fill(rect(x + 2, top + 48, x + w - 2, top + 48) & liq, '#c9b8a6')


bottle(218, 34, 18, AMBER)
bottle(244, 22, 20, RUBY, 6)
bottle(272, 38, 18, LEAF)

# ---------------------------------------------------------------- RIGHT BOTTOM: sauerkraut barrel with a wooden tamper
BX0, BX1, BY0, BY1 = 222, 290, 122, 186
shadow(BX0 - 2, BY1 - 4, BX1 + 8, BY1 + 4)
barrel = blank()
for y in range(BY0, BY1 + 1):
    t = (y - BY0) / (BY1 - BY0)
    hw = (BX1 - BX0) / 2 - 3 + int(round(4 * (1 - (2 * t - 1) ** 2)))
    cx = (BX0 + BX1) / 2
    barrel[y, int(cx - hw):int(cx + hw) + 1] = True
mound = ell(BX0 + 2, BY0 - 12, BX1 - 2, BY0 + 8) & ~rect(0, BY0 + 3, W, H)
draw((mound, KRAUT, {'d': 2}))
for k in range(40):   # curly shreds: short arcs in two tones
    sx, sy = BX0 + 6 + (k * 37) % (BX1 - BX0 - 12), BY0 - 9 + (k * 7) % 12
    if mound[sy, sx] and mound[sy, min(W - 1, sx + 4)]:
        cv.dots([(sx, sy + 1), (sx + 1, sy), (sx + 2, sy), (sx + 3, sy + 1)], KRAUT['s'] if k % 3 else KRAUT['r'])
draw((barrel, WOOD, {'d': 3}))
for k, sx in enumerate(range(BX0 + 9, BX1 - 4, 10)):
    cv.fill(barrel & line([(sx + (k - 2), BY0 + 2), (sx + (k - 2) * 2, (BY0 + BY1) // 2), (sx + (k - 2), BY1 - 2)]), DWOOD['b'])
for hy in (BY0 + 7, BY1 - 9):
    draw((barrel & rect(0, hy, W, hy + 3), ramp('#5b6070', '#34343f', '#8b8f96'), {'d': 1, 'rim': False}))
    cv.fill(barrel & rect(0, hy, W, hy), '#8b8f96')
cv.fill(rect(BX0 + 4, BY0, BX1 - 4, BY0 + 2), DWOOD['b'])
cab = ell(BX1 - 26, BY0 - 20, BX1 - 4, BY0 + 1)   # a whole cabbage waiting on the kraut
draw((cab, LEAF, {'d': 2}))
cv.fill(line([(BX1 - 15, BY0 - 17), (BX1 - 15, BY0 - 2)]) | line([(BX1 - 22, BY0 - 12), (BX1 - 15, BY0 - 6)]) | line([(BX1 - 8, BY0 - 12), (BX1 - 15, BY0 - 6)]), LEAF['s'])

HOTSPOTS = [
    {'id': 'jam', 'label': 'Jam shelf', 'x': 4, 'y': 8, 'w': 126, 'h': 180},
    {'id': 'hanging', 'label': 'Garlic and cheese', 'x': 136, 'y': 8, 'w': 64, 'h': 84},
    {'id': 'pickles', 'label': 'Pickle crock', 'x': 134, 'y': 92, 'w': 70, 'h': 98},
    {'id': 'cordials', 'label': 'Cordial bottles', 'x': 210, 'y': 12, 'w': 88, 'h': 90},
    {'id': 'kraut', 'label': 'Sauerkraut barrel', 'x': 214, 'y': 104, 'w': 84, 'h': 88},
]

if __name__ == '__main__':
    out = sys.argv[1] if len(sys.argv) > 1 else None
    n = save_scene(cv, NAME, HOTSPOTS, out)
    print(NAME + ':', n, 'colours')
