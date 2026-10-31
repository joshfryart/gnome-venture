"""Crafting area scene: ALCHEMY STATION (variant imp). Usage: python3 -B aseprite-source/scenes-pil/craft_imp_alchemy.py [outdir]
Writes aseprite-source/craftmap/scenes/imp/alchemy.png (1800 x 1200), alchemy-thumb.png (450 x 300), alchemy.json (hotspots) and alchemy_hs.png.
Brief: claude/craftmap-scene-brief.md. Clean and clear, five big tap targets on a calm teal stone wall:
hero = iron cauldron of glowing teal brew over a fire (centre, lit by a two-step glow on the wall); left = a shelf of violet,
teal and gold flasks over a mortar and pestle on a stool; right = an open spellbook on a wall rest over a copper still.
"""
import json
import os
import sys

from jigsaw_common import *  # noqa: F401,F403
from PIL import Image, ImageDraw

NAME = 'alchemy'
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




# ---------------------------------------------------------------- palette (teal / violet / gold)
WALL, WALL_S = '#3e6872', '#335a64'
GLOW1, GLOW2 = '#4a7880', '#57868c'
FLOOR, FLOOR_S, FLOOR_L = '#4e4270', '#3e345c', '#625488'
SHADOW = '#33294c'
WOOD = ramp('#9a6b3f', '#7a4a1f', '#c9a96e', '#8a5a30')
DWOOD = ramp('#7a4a1f', '#5c3420', '#9a6b3f')
IRON = ramp('#5a5e70', '#3a3a48', '#8a90a6', '#4a4e5e')
BREW = ramp('#3ad0b0', '#1f9a88', '#a8f0d8')
GLASS = ramp('#d8ecf0', '#a9c8d4', '#ffffff')
VIOLET = ramp('#7a5cc0', '#4e3a8a', '#b09ae6')
TEAL = ramp('#2fb0a0', '#1f7a72', '#80e0c8')
GOLD = ramp('#e8a317', '#b07a10', '#f5cf6a')
COPPER = ramp('#d0843a', '#a05a24', '#f5b87a', '#b86a2c')
STONE = ramp('#aaa2b8', '#7e7690', '#d4cee0')
PAGE = ramp('#f1ece0', '#c9bfa8', '#ffffff')
CORK = ramp('#c9a96e', '#9a7a4a', '#e8d4a0')
LEAF = ramp('#5a9a5a', '#3a7a44', '#8ac07a')
VAPOUR = ramp('#c3b2ea', '#9a86cc', '#e8e0fa')
FIRE0, FIRE1, FIRE2 = '#e0501f', '#f08a24', '#f5cf6a'
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


# ---------------------------------------------------------------- room: big calm stone blocks, round night window, violet flag floor
FY = 150
for k, y in enumerate(range(14, FY, 17)):   # wide courses, few joints: texture without noise
    cv.fill(rect(0, y, W - 1, y), WALL_S)
    for jx in range(12 + (k % 2) * 28, W, 56):
        cv.fill(rect(jx, y + 1, jx, min(FY - 1, y + 16)), WALL_S)
cv.fill(rect(0, 0, W - 1, 7), DWOOD['b'])
cv.fill(rect(0, 6, W - 1, 7), DWOOD['s'])
cv.fill(rect(0, 0, W - 1, 0), DWOOD['r'])
cv.fill(rect(0, FY, W - 1, H - 1), FLOOR)
for k, y in enumerate((FY + 14, FY + 31)):
    cv.fill(rect(0, y, W - 1, y), FLOOR_S)
for k, (y0, y1) in enumerate(((FY, FY + 13), (FY + 15, FY + 30), (FY + 32, H - 1))):
    for jx in range(30 + k * 21, W, 60):
        cv.fill(rect(jx, y0, jx, y1), FLOOR_S)
        cv.fill(rect(jx + 1, y0 + 1, jx + 1, y0 + 3), FLOOR_L)
cv.fill(rect(0, FY, W - 1, FY), FLOOR_L)

# ---------------------------------------------------------------- glow cast on the wall by the brew (two hard steps behind the hero)
g2 = ell(84, 40, 216, 176) & ~rect(0, FY, W, H)
g1 = ell(100, 56, 200, 166) & ~rect(0, FY, W, H)
cv.fill(g2, GLOW1)
cv.fill(g1, GLOW2)
for k, y in enumerate(range(14, FY, 17)):   # keep the courses visible inside the glow, one step lighter
    cv.fill(g2 & rect(0, y, W, y), WALL)
    for jx in range(12 + (k % 2) * 28, W, 56):
        cv.fill(g2 & rect(jx, y + 1, jx, min(FY - 1, y + 16)), WALL)

# ---------------------------------------------------------------- HERO: bubbling cauldron over a fire
CX0, CX1 = 108, 192
shadow(CX0 - 4, 176, CX1 + 8, 186)
fire = poly([(124, 178), (128, 162), (134, 170), (142, 152), (150, 168), (158, 156), (166, 170), (172, 162), (176, 178)])
draw((fire, ramp(FIRE1, FIRE0, FIRE2), {'d': 2}))
cv.fill(poly([(136, 178), (142, 162), (150, 174), (158, 164), (164, 178)]), FIRE2)
for lx0, lx1 in ((118, 150), (150, 182)):   # crossed logs under the fire
    draw((line([(lx0, 182), (lx1, 176)], 5), WOOD, {'d': 1}))
draw((line([(CX0 + 10, 150), (CX0 + 4, 180)], 4) | line([(CX1 - 10, 150), (CX1 - 4, 180)], 4), IRON, {'d': 1}))   # legs
body = ell(CX0, 92, CX1, 170) & ~rect(0, 0, W, 99)
rim = ell(CX0 - 4, 86, CX1 + 4, 106)   # thick rolled rim seen slightly from above
brew = ell(CX0 + 4, 90, CX1 - 4, 102)
draw((body, IRON, {'d': 4}), (rim, IRON, {'d': 2, 'contour': True}))
cv.fill(rim & ~shift(rim, 0, 1) & rect(0, 0, CX0 + 40, H), IRON['r'])
cv.fill(brew, BREW['s'])
cv.fill(brew & shift(brew, 0, 2), BREW['b'])
cv.fill(brew & rect(0, 0, W, 93) & shift(brew, 0, 2), BREW['r'])
for bx, by, s in ((126, 88, 5), (138, 82, 6), (170, 88, 4), (180, 93, 3)):   # bubbles rising off the surface
    draw((ell(bx - s, by - s, bx + s, by + s), BREW, {'d': 1}))
    cv.dots([(bx - s // 2, by - s // 2)], '#ffffff')
cv.fill(ell(CX0 + 8, 108, CX0 + 14, 140) & body, IRON['g'] or IRON['r'])   # big highlight on the belly
cv.fill(rect(CX0 + 6, 120, CX1 - 6, 121) & body, IRON['s'])   # cast band
for rx in range(CX0 + 16, CX1 - 10, 12):
    cv.dots([(rx, 120)], GOLD['b'])   # gold rivets
# vapour: violet puffs rising, shrinking
vap = blank()
for vx, vy, s in ((146, 70, 9), (156, 62, 8), (148, 52, 7), (156, 42, 6), (150, 34, 4)):   # one merged plume, not loose pebbles
    vap |= ell(vx - s, vy - s * 3 // 4, vx + s, vy + s * 3 // 4)
draw((vap & ~rect(0, 76, W, H), VAPOUR, {'d': 2}))
for sx, sy in ((122, 70), (178, 72), (132, 50), (170, 40)):
    sparkle(sx, sy)

# ---------------------------------------------------------------- LEFT TOP: shelf of coloured potion flasks
draw((rect(6, 64, 98, 68), WOOD, {'d': 2}), (poly([(12, 69), (18, 69), (12, 80)]) | poly([(86, 69), (92, 69), (92, 80)]), WOOD, {'d': 1}))


def flask(cx, base, kind, rp):
    if kind == 'round':
        bodym = ell(cx - 13, base - 26, cx + 13, base) & ~rect(0, base, W, H)
        neck = rect(cx - 3, base - 38, cx + 3, base - 22)
        liq = ell(cx - 11, base - 24, cx + 11, base - 1) & rect(0, base - 15, W, H)
        top = base - 38
    elif kind == 'tall':
        bodym = rrect(cx - 8, base - 34, cx + 8, base - 1, 3)
        neck = rect(cx - 3, base - 46, cx + 3, base - 32)
        liq = rrect(cx - 6, base - 24, cx + 6, base - 3, 2)
        top = base - 46
    else:   # cone
        bodym = poly([(cx - 3, base - 30), (cx + 3, base - 30), (cx + 12, base - 1), (cx - 12, base - 1)])
        neck = rect(cx - 3, base - 36, cx + 3, base - 28)
        liq = poly([(cx - 7, base - 15), (cx + 7, base - 15), (cx + 10, base - 3), (cx - 10, base - 3)])
        top = base - 36
    o = cv.obj()
    o.part(neck | bodym, GLASS, d=2)
    o.part(rect(cx - 4, top - 5, cx + 4, top), CORK, d=1, contour=True)
    o.draw()
    cv.fill(liq, rp['b'])
    cv.fill(liq & ~shift(liq, -2, -2), rp['s'])
    ys = np.nonzero(liq.any(axis=1))[0]
    cv.fill(liq & rect(0, ys.min(), W, ys.min()), rp['r'])
    cv.fill(rect(cx - 6 if kind != 'tall' else cx - 5, ys.min() - 6, cx - 5 if kind != 'tall' else cx - 4, ys.min() + 4) & bodym, '#ffffff')


flask(26, 63, 'round', VIOLET)
flask(52, 63, 'tall', TEAL)
flask(77, 63, 'cone', GOLD)
sparkle(40, 24)

# ---------------------------------------------------------------- LEFT BOTTOM: mortar and pestle on a stool
shadow(10, 178, 90, 186)
draw((rect(20, 140, 25, 182) | rect(75, 140, 80, 182), WOOD, {'d': 2}), (rect(25, 166, 75, 169), WOOD, {'d': 1}),
     (rect(12, 132, 88, 140), WOOD, {'d': 2, 'contour': True}))
cv.fill(rect(13, 133, 87, 133), WOOD['r'])
mort = (ell(26, 104, 74, 132) & rect(0, 112, W, H)) | rect(38, 126, 62, 132)
draw((mort, STONE, {'d': 3}), (ell(26, 106, 74, 118), STONE, {'d': 1, 'contour': True}))
cv.fill(ell(30, 108, 70, 116), STONE['s'])
cv.fill(ell(32, 110, 68, 116) & rect(0, 112, W, H), '#5aa070')   # ground green herbs inside
front = mort & ~ell(26, 106, 74, 118)   # the bowl's front wall hides the pestle's foot
draw(((line([(56, 116), (72, 92)], 6) | ell(66, 86, 77, 97)) & ~front, WOOD, {'d': 2}))   # pestle leaning out of the bowl

# ---------------------------------------------------------------- RIGHT TOP: open spellbook on a wall book-rest
draw((poly([(214, 64), (292, 64), (288, 70), (218, 70)]), WOOD, {'d': 1}), (rect(222, 70, 226, 78) | rect(280, 70, 284, 78), WOOD, {'d': 1}))
rest = poly([(218, 62), (288, 62), (282, 40), (224, 40)])
draw((rest, DWOOD, {'d': 2}))
book = poly([(220, 58), (253, 60), (253, 22), (226, 18)]) | poly([(253, 60), (286, 58), (280, 18), (253, 22)])
draw((book | poly([(218, 60), (288, 60), (286, 63), (220, 63)]), VIOLET, {'d': 2}))   # cover
pages = poly([(223, 56), (252, 58), (252, 22), (228, 19)]) | poly([(254, 58), (283, 56), (278, 19), (254, 22)])
cv.fill(pages, PAGE['b'])
cv.fill(pages & ~shift(pages, 0, 1) | pages & rect(250, 0, 252, H), PAGE['s'])
for k in range(5):   # lines of (unreadable) script
    y = 28 + k * 5
    cv.fill(rect(231, y, 247, y) & pages, '#8a7aa8')
    if k != 2:
        cv.fill(rect(258, y, 275, y) & pages, '#8a7aa8')
draw((ell(260, 34, 272, 46), GOLD, {'d': 1}))   # a gold sigil on the right page
cv.fill(ell(263, 37, 269, 43), PAGE['b'])
draw((rect(251, 58, 254, 74), ramp('#c0324a', '#8a2034', '#e86a7a'), {'d': 1}))   # ribbon bookmark
for cx_, cy_ in ((221, 60), (284, 60)):
    cv.fill(rect(cx_ - 1, cy_ - 1, cx_ + 2, cy_ + 2), GOLD['b'])   # gold corners

# ---------------------------------------------------------------- RIGHT BOTTOM: copper still (alembic) with a glass receiver
shadow(206, 178, 296, 186)
draw((rrect(212, 150, 248, 182, 2), ramp('#8a7aa0', '#6a5a80', '#aa9ac0'), {'d': 2}))   # little stone furnace
cv.fill(rrect(222, 160, 238, 178, 2), UMB)
cv.fill(poly([(224, 178), (228, 168), (230, 174), (233, 164), (236, 178)]), FIRE1)
pot = ell(208, 112, 252, 156)
draw((pot, COPPER, {'d': 3}), (poly([(222, 116), (238, 116), (234, 96), (226, 96)]), COPPER, {'d': 2}),   # pot and helm
     (ell(222, 88, 238, 100), COPPER, {'d': 2}))
for ry in (126, 140):
    cv.fill(rect(210, ry, 250, ry) & pot, COPPER['s'])
    for rx in range(214, 250, 6):
        cv.dots([(rx, ry - 1)], COPPER['r'] if pot[ry - 1, rx] else WALL)
tube = line([(236, 92), (256, 92), (270, 106), (274, 134)], 3)
draw((tube, COPPER, {'d': 1}))
rx0 = 264
draw((rect(rx0 - 4, 164, rx0 + 28, 168) | rect(rx0 - 2, 168, rx0 + 1, 182) | rect(rx0 + 23, 168, rx0 + 26, 182), WOOD, {'d': 1}))   # stool
recv = ell(rx0 - 1, 136, rx0 + 25, 164) & ~rect(0, 0, W, 139) | rect(rx0 + 9, 128, rx0 + 15, 140)
draw((recv, GLASS, {'d': 2}))
rl = ell(rx0 + 2, 144, rx0 + 22, 162) & rect(0, 150, W, H)
cv.fill(rl, VIOLET['b'])
cv.fill(rl & ~shift(rl, -2, -2), VIOLET['s'])
cv.fill(rl & rect(0, 150, W, 150), VIOLET['r'])
cv.fill(rect(rx0 + 3, 145, rx0 + 4, 152), '#ffffff')
cv.dots([(rx0 + 12, 142), (rx0 + 12, 146)], VIOLET['r'])   # drip falling from the tube

HOTSPOTS = [
    {'id': 'flasks', 'label': 'Potion shelf', 'x': 4, 'y': 8, 'w': 96, 'h': 76},
    {'id': 'mortar', 'label': 'Mortar and pestle', 'x': 8, 'y': 84, 'w': 84, 'h': 104},
    {'id': 'cauldron', 'label': 'Cauldron', 'x': 102, 'y': 32, 'w': 100, 'h': 158},
    {'id': 'book', 'label': 'Spellbook', 'x': 210, 'y': 12, 'w': 86, 'h': 68},
    {'id': 'still', 'label': 'Copper still', 'x': 206, 'y': 84, 'w': 92, 'h': 104},
]

if __name__ == '__main__':
    out = sys.argv[1] if len(sys.argv) > 1 else None
    n = save_scene(cv, NAME, HOTSPOTS, out)
    print(NAME + ':', n, 'colours')
