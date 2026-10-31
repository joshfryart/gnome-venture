"""Crafting area scene: YARD & DECOR (variant imp). Usage: python3 -B aseprite-source/scenes-pil/craft_imp_decor.py [outdir]
Writes aseprite-source/craftmap/scenes/imp/decor.png (1800 x 1200), decor-thumb.png (450 x 300), decor.json (hotspots) and decor_hs.png.
Brief: claude/craftmap-scene-brief.md (Round 2). Clean and clear, five big tap targets on a calm sky / blossom hedge / lawn:
hero = pale stone birdbath with bright blue water and a robin on the rim (centre, on a round flagstone); left = an iron lantern
post (back) over a fat terracotta planter of pink flowers (front); right = a white picket fence (back) over stepping stones (front).
"""
import json
import os
import sys

from jigsaw_common import *  # noqa: F401,F403
from PIL import Image, ImageDraw

NAME = 'decor'
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
        assert h['x'] >= 0 and h['y'] >= 0 and h['x'] + h['w'] <= W and h['y'] + h['h'] <= H, h['id']
        x0, y0 = h['x'] * SCALE, h['y'] * SCALE
        x1, y1 = (h['x'] + h['w']) * SCALE - 1, (h['y'] + h['h']) * SCALE - 1
        d.rectangle([x0, y0, x1, y1], outline=(0, 255, 255), width=4)
        d.text((x0 + 10, y0 + 8), h['id'], fill=(0, 255, 255))
    hs.save(os.path.join(outdir, name + '_hs.png'))
    return cv.colours()


# ---------------------------------------------------------------- palette (petal pink / lawn green / sky)
SKY, CLOUD, CLOUD_S = '#9fd3ea', '#eef8fc', '#cbe8f4'
HEDGE = ramp('#d98aa8', '#bc6c8e', '#eeaac2')            # far blossom hedge: mid pink so pale stone and white pickets pop
LAWN, LAWN_L, LAWN_S = '#7ab55c', '#86bf66', '#5f9e4a'
SHADOW = '#4f9a45'
STONE = ramp('#e2dccf', '#b4ab9a', '#f7f4ec', '#c6bead')   # the birdbath: pale warm stone
FLAG = ramp('#c9c3b4', '#9e9686', '#e2dccf')               # flagstone pad and stepping stones, a step darker than the hero
WATER = ramp('#2f8fc8', '#1f6a9e', '#8fd0f0')
IRON = ramp('#4e5262', '#34343f', '#767c90', '#5b6070')
GLOW = ramp('#f5cf6a', '#e8a317', '#fff1c8')
PICKET = ramp('#f4efe4', '#c9c2b2', '#ffffff')
POT = ramp('#c8744a', '#9a5234', '#e89a6c', '#ac5e3c')
LEAF = ramp('#4f9a45', '#2f6a2f', '#7ab55c')
PETAL = ramp('#e46a9b', '#b8487a', '#f6b8cf')
ROBIN = ramp('#9a6b3f', '#7a4a1f', '#c9a96e')
BREAST = ramp('#e0501f', '#b8452f', '#f08a24')
GOLD = ramp('#e8a317', '#b07a10', '#f5cf6a')
UMB = '#2a1a10'

cv = new_canvas(SKY)


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


# ---------------------------------------------------------------- yard: calm sky, two flat clouds, a blossom hedge, mown lawn
for (x0, y0, x1, y1) in ((62, 16, 100, 32), (210, 20, 262, 38)):
    c = ell(x0, y0 + 4, x1, y1) | ell(x0 + (x1 - x0) // 4, y0, x0 + 3 * (x1 - x0) // 4, y1 - 4)
    cv.fill(c, CLOUD)
    cv.fill(c & ~shift(c, 0, -2), CLOUD_S)

HY = 112   # lawn horizon
hedge = rect(0, 100, W - 1, HY)
for k, bx in enumerate(range(-6, W + 12, 22)):
    hedge |= ell(bx - 13, 88 + (k % 2) * 3, bx + 13, 112)
cv.fill(hedge, HEDGE['b'])
cv.fill(hedge & ~shift(hedge, 0, 2), HEDGE['r'])
cv.fill(hedge & rect(0, HY - 4, W, HY), HEDGE['s'])

cv.fill(rect(0, HY, W - 1, H - 1), LAWN)
for y0, y1 in ((HY + 10, HY + 22), (HY + 38, HY + 56)):   # wide mown stripes, widening towards the viewer
    cv.fill(rect(0, y0, W - 1, y1), LAWN_L)
cv.fill(rect(0, HY, W - 1, HY), LAWN_S)

# ---------------------------------------------------------------- HERO: stone birdbath on a round flagstone, robin on the rim
shadow(108, 172, 214, 184)
pad_top = ell(98, 158, 204, 178)
draw((ell(98, 161, 204, 181), FLAG, {'d': 1, 'rim': False}), (pad_top, FLAG, {'d': 1, 'contour': True}))
cv.fill(pad_top & ~shift(pad_top, 0, -1), FLAG['s'])
# plinth, baluster pedestal, collar
draw((rrect(122, 150, 178, 166, 2), STONE, {'d': 2}),
     (rrect(128, 142, 172, 151, 2), STONE, {'d': 2, 'contour': True}),
     (rect(140, 96, 160, 143) | ell(132, 106, 168, 134), STONE, {'d': 3}),
     (rrect(134, 94, 166, 101, 1), STONE, {'d': 1, 'contour': True}))
cv.fill(rect(138, 119, 162, 119) & ell(132, 106, 168, 134), STONE['s'])   # carved band on the vase
# bowl: shallow dish, thick rim seen from above
bowl = ell(96, 58, 204, 104) & rect(0, 72, W, 99)
rim = ell(92, 60, 208, 86)
draw((bowl | rrect(126, 96, 174, 100, 1), STONE, {'d': 3}), (rim, STONE, {'d': 2, 'contour': True}))
cv.fill(rim & ~shift(rim, 0, 1) & rect(0, 0, 150, H), STONE['r'])
water = ell(100, 64, 200, 82)
cv.fill(water, WATER['s'])
cv.fill(water & shift(water, 0, 2), WATER['b'])
cv.fill(water & rect(0, 0, 128, H) & shift(water, 2, 3), WATER['r'])          # sky glinting off the near-left water
cv.fill(rect(150, 72, 166, 72) | rect(170, 76, 182, 76), WATER['r'])            # ripples
cv.fill(rect(112, 70, 117, 71), '#ffffff')
for px_, py_ in ((176, 69), (186, 73)):                                         # two blossom petals afloat
    cv.fill(ell(px_, py_, px_ + 5, py_ + 3), PETAL['r'])
    cv.dots([(px_ + 4, py_ + 2)], PETAL['b'])
cv.fill(ell(104, 86, 112, 96) & bowl, STONE['g'] if STONE.get('g') else STONE['r'])   # light on the bowl's left belly
# robin on the rim, facing the water
rb = ell(104, 46, 128, 64)
head = ell(118, 38, 134, 54)
tail = poly([(108, 52), (94, 46), (96, 52), (106, 60)])
draw((tail, ROBIN, {'d': 1}), (rb, ROBIN, {'d': 2}), (head, ROBIN, {'d': 2}),
     (poly([(133, 45), (139, 47), (133, 49)]), GOLD, {'d': 1}))
cv.fill(ell(118, 46, 132, 62) & (rb | head), BREAST['b'])
cv.fill(ell(118, 46, 132, 62) & (rb | head) & ~shift(ell(118, 46, 132, 62) & (rb | head), -2, -2), BREAST['s'])
cv.fill(line([(108, 52), (118, 56)]), ROBIN['s'])                                # wing line
cv.fill(rect(127, 43, 128, 44), UMB)
cv.dots([(127, 43)], '#ffffff')
cv.fill(rect(114, 64, 114, 66) | rect(120, 64, 120, 66), UMB)                   # legs to the rim
for sx, sy in ((86, 52), (214, 50), (176, 38), (222, 92)):
    sparkle(sx, sy)

# ---------------------------------------------------------------- LEFT BACK: iron lantern post
LX = 40
shadow(LX - 10, 120, LX + 22, 128)
draw((rrect(LX - 11, 114, LX + 11, 124, 2), IRON, {'d': 2}),           # foot
     (rect(LX - 4, 52, LX + 4, 116), IRON, {'d': 2}),                  # post
     (rect(LX - 7, 84, LX + 7, 88) | rect(LX - 7, 108, LX + 7, 112), IRON, {'d': 1, 'contour': True}))
# lantern head: roof, four-pane glass, base
glass = poly([(LX - 14, 22), (LX + 14, 22), (LX + 11, 46), (LX - 11, 46)])
draw((rect(LX - 2, 4, LX + 2, 10), IRON, {'d': 1}),
     (poly([(LX, 6), (LX + 20, 22), (LX - 20, 22)]), IRON, {'d': 2}),
     (glass, GLOW, {'d': 2}),
     (rrect(LX - 13, 46, LX + 13, 52, 1), IRON, {'d': 1, 'contour': True}))
cv.fill(rect(LX - 20, 22, LX + 20, 24), IRON['s'])
cv.fill(line([(LX, 6), (LX - 18, 21)]), IRON['r'])
for mx in (LX - 5, LX + 5):
    cv.fill(rect(mx, 25, mx, 45), IRON['b'])
cv.fill(ell(LX - 3, 30, LX + 3, 42), GLOW['r'])                       # candle flame
cv.fill(rect(LX - 2, 40, LX + 2, 45), '#f1ece0')

# ---------------------------------------------------------------- LEFT FRONT: terracotta planter of pink flowers
PX0, PX1 = 16, 84
shadow(PX0 + 4, 184, PX1 + 10, 194)
potm = poly([(PX0 + 2, 160), (PX1 - 2, 160), (PX1 - 8, 190), (PX0 + 8, 190)])
leaves = ell(PX0 - 2, 136, PX1 + 2, 166)
draw((leaves, LEAF, {'d': 2}),
     (potm, POT, {'d': 3}),
     (rrect(PX0 - 2, 155, PX1 + 2, 163, 1), POT, {'d': 1, 'contour': True}))
cv.fill(rect(PX0 - 1, 156, PX1 + 1, 156), POT['r'])
for fx, fy, s in ((28, 140, 7), (46, 134, 8), (66, 140, 7), (38, 152, 6), (58, 152, 6)):
    bloom = blank()
    for dx, dy in ((0, -s // 2 - 1), (s // 2 + 1, 0), (0, s // 2 + 1), (-s // 2 - 1, 0)):
        bloom |= ell(fx + dx - s // 2, fy + dy - s // 2, fx + dx + s // 2, fy + dy + s // 2)
    draw((bloom, PETAL, {'d': 2}))
    cv.fill(ell(fx - 2, fy - 2, fx + 2, fy + 2), GOLD['r'])
for k, (lx0, ly0) in enumerate(((22, 172), (40, 176), (58, 172))):     # stitched band on the pot
    pass
cv.fill(potm & rect(0, 174, W, 175), POT['s'])

# ---------------------------------------------------------------- RIGHT BACK: white picket fence section
FX0, FX1, FB = 210, 292, 128
shadow(FX0, FB - 2, FX1 + 6, FB + 4)
pk = blank()
for x in range(FX0, FX1 - 6, 14):
    pk |= poly([(x, FB), (x, 78), (x + 4, 72), (x + 8, 78), (x + 8, FB)])
rails = rect(FX0 - 4, 88, FX1 + 2, 93) | rect(FX0 - 4, 112, FX1 + 2, 117)
draw((rails, PICKET, {'d': 1}), (pk, PICKET, {'d': 2, 'contour': True}))

# ---------------------------------------------------------------- RIGHT FRONT: round stepping stones running back into the lawn
for (x0, y0, x1, y1) in ((222, 140, 244, 148), (232, 152, 262, 163), (246, 168, 284, 182), (254, 184, 298, 199)):
    t = max(1, (y1 - y0) // 5)
    draw((ell(x0, y0 + t, x1, y1 + t) & rect(0, 0, W, H - 1), FLAG, {'d': 1, 'rim': False}),
         (ell(x0, y0, x1, y1), FLAG, {'d': 1, 'contour': True}))

HOTSPOTS = [
    {'id': 'lantern', 'label': 'Lantern post', 'x': 10, 'y': 2, 'w': 70, 'h': 128},
    {'id': 'planter', 'label': 'Flower planter', 'x': 6, 'y': 130, 'w': 88, 'h': 68},
    {'id': 'birdbath', 'label': 'Birdbath', 'x': 94, 'y': 32, 'w': 112, 'h': 156},
    {'id': 'fence', 'label': 'Picket fence', 'x': 206, 'y': 64, 'w': 92, 'h': 70},
    {'id': 'path', 'label': 'Stepping stones', 'x': 214, 'y': 136, 'w': 86, 'h': 64},
]

if __name__ == '__main__':
    out = sys.argv[1] if len(sys.argv) > 1 else None
    n = save_scene(cv, NAME, HOTSPOTS, out)
    print(NAME + ':', n, 'colours')
