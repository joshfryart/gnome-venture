"""Gather UI art, VARIATION A: "Picture-book meadow".

One wide scene per landscape (LANDSCAPES in game/includes/adventure_data.php) with 5 tappable hotspot props,
each sitting on a soft (hard-pixel, stepped) glow ring; plus 32x32 tool icons (gather tools in tools.php + hand).
Uses the shared pixlib kit: 240x135 grid, 2x nearest export, umber three-tone outlines, light from upper left.
Usage: python3 claude/art-variants/a/gather_a.py   -> PNGs next to this file, plus preview.png and hotspots.json
"""
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, '..', '..', '..', 'aseprite-source', 'scenes-pil'))
import numpy as np  # noqa: E402
from PIL import Image  # noqa: E402
from pixlib import Canvas, ramp, rect, rrect, ell, poly, line, blank, shift, OL, W, H, hx  # noqa: E402

WOOD = ramp('#9a6b3f', '#7a4a1f', '#c9a96e', '#8a5a30')
DWOOD = ramp('#7a4a1f', '#5c3420', '#9a6b3f')
STONE = ramp('#8b8f96', '#5b6470', '#c9c5bc')
MOSS = ramp('#4f9a45', '#2f6a3a', '#7ab55c')
LEAF = ramp('#7ab55c', '#4f9a45', '#a4b86a')
WATER = ramp('#3f8fb0', '#25637d', '#a9d6ea')
BERRY = ramp('#b8457a', '#7a2a55', '#e46a9b')
RED = ramp('#d6322b', '#a8241f', '#f08a24')
CREAM = ramp('#f2e4c0', '#c9a96e', '#fff3c8')
GOLD = ramp('#e8a317', '#b07a10', '#f5cf6a')
SAND = ramp('#e8cf96', '#c9a96e', '#f6e6b8')
DUSK = ramp('#7a5cc0', '#4e3a8a', '#c3b2ea')
ICE = ramp('#c9e4ef', '#8fb6c9', '#ffffff')
CORAL = ramp('#f0806a', '#c0504a', '#f6b8a0')
METAL = ramp('#c9c5bc', '#8b8f96', '#ffffff')
GLOW = ('#fff3c8', '#f5cf6a')


def glow(cv, x, y, rw=13, rh=4):
    """Soft glow ring under a hotspot: a light stepped halo ring plus a dashed outer ring (no blends)."""
    outer = ell(x - rw - 2, y - rh - 1, x + rw + 2, y + rh + 1)
    inner = ell(x - rw, y - rh, x + rw, y + rh)
    core = ell(x - rw + 3, y - rh + 2, x + rw - 3, y + rh - 2)
    ring = outer & ~inner
    yy, xx = np.mgrid[0:H, 0:W]
    cv.fill(ring & (((xx + yy) // 2) % 2 == 0), GLOW[1])
    cv.fill(inner & ~core, GLOW[0])


# ---------------- props (x, y = foot centre) ----------------
def herbs(cv, x, y):
    for i, dx in enumerate((-6, -2, 2, 6)):
        o = cv.obj()
        o.part(poly([(x + dx - 2, y), (x + dx + 2, y), (x + dx + i % 2, y - 10 - i % 2 * 3)]), MOSS)
        o.part(ell(x + dx - 3, y - 7, x + dx + 1, y - 4), LEAF, d=1)
        o.draw()
    cv.dots([(x - 2, y - 13), (x + 3, y - 12)], '#f2e4c0')


def berry_bush(cv, x, y):
    o = cv.obj()
    o.part(ell(x - 11, y - 16, x + 11, y), MOSS, d=3)
    o.part(ell(x - 7, y - 19, x + 5, y - 9), LEAF, d=2)
    o.draw()
    for bx, by in ((-6, -8), (-1, -12), (4, -6), (7, -11), (0, -4), (-4, -14)):
        o = cv.obj(outline=False)
        o.part(rect(x + bx, y + by, x + bx + 1, y + by + 1), BERRY, d=1)
        o.draw()
        cv.dots([(x + bx, y + by)], BERRY['r'])


def log(cv, x, y):
    o = cv.obj()
    o.part(rrect(x - 14, y - 7, x + 10, y, 2), WOOD, d=2)
    o.part(ell(x + 7, y - 8, x + 14, y + 1), CREAM, d=1, contour=True)
    o.draw()
    cv.fill(ell(x + 9, y - 6, x + 12, y - 1), WOOD['bo'])
    cv.dots([(x + 10, y - 4)], CREAM['b'])
    for dx in (-10, -4, 1):
        cv.fill(rect(x + dx, y - 5, x + dx + 3, y - 5), WOOD['s'])
    o = cv.obj()
    o.part(ell(x - 8, y - 11, x - 3, y - 7), RED, d=1)
    o.part(rect(x - 6, y - 8, x - 5, y - 7), CREAM, flat=True)
    o.draw()


def pond(cv, x, y):
    o = cv.obj()
    o.part(ell(x - 15, y - 8, x + 15, y), STONE, d=1)
    o.draw()
    cv.fill(ell(x - 13, y - 7, x + 13, y - 1), WATER['b'])
    cv.fill(ell(x - 13, y - 7, x + 13, y - 1) & ~shift(ell(x - 13, y - 7, x + 13, y - 1), 0, 2), WATER['s'])
    cv.fill(rect(x - 6, y - 4, x - 2, y - 4), WATER['r'])
    cv.fill(rect(x + 3, y - 3, x + 5, y - 3), WATER['r'])
    o = cv.obj()
    o.part(ell(x + 4, y - 6, x + 9, y - 3), LEAF, d=1)
    o.draw()
    for dx in (-14, -12):
        o = cv.obj()
        o.part(rect(x + dx, y - 16, x + dx, y - 4), MOSS, d=0)
        o.part(rrect(x + dx - 1, y - 19, x + dx + 1, y - 14, 1), DWOOD, d=1)
        o.draw()


def rocks(cv, x, y):
    for (a, b, c, d) in ((-12, -8, 0, 0), (-2, -12, 11, 0), (-6, -16, 3, -8)):
        o = cv.obj()
        o.part(rrect(x + a, y + b, x + c, y + d, 2), STONE, d=2)
        o.draw()
    cv.dots([(x - 3, y - 14), (x + 6, y - 7)], STONE['r'])
    o = cv.obj()
    o.part(poly([(x + 8, y - 13), (x + 11, y - 19), (x + 13, y - 12)]), DUSK, d=1)
    o.draw()


def mushrooms(cv, x, y):
    for dx, h, rp in ((-6, 9, RED), (3, 12, GOLD), (8, 6, RED)):
        o = cv.obj()
        o.part(rect(x + dx - 1, y - h + 2, x + dx + 1, y), CREAM, d=1)
        o.part(ell(x + dx - 5, y - h - 3, x + dx + 5, y - h + 3) & rect(0, 0, W, y - h + 1), rp, d=1)
        o.draw()
        cv.dots([(x + dx - 2, y - h - 1), (x + dx + 2, y - h)], CREAM['r'])


def shells(cv, x, y):
    for dx, dy, rp in ((-8, 0, CORAL), (2, -2, CREAM), (9, 1, SAND)):
        o = cv.obj()
        o.part(poly([(x + dx - 5, y + dy), (x + dx + 5, y + dy), (x + dx, y + dy - 8)]), rp, d=1)
        o.draw()
        cv.fill(line([(x + dx, y + dy - 7), (x + dx, y + dy - 1)]), rp['s'])
    o = cv.obj()
    o.part(poly([(x - 3, y - 6), (x + 2, y - 14), (x + 4, y - 12), (x + 0, y - 5)]), MOSS, d=1)
    o.draw()


def tidepool(cv, x, y):
    pond(cv, x, y)
    o = cv.obj()
    o.part(poly([(x - 4, y - 5), (x - 2, y - 9), (x, y - 5)]) | poly([(x - 6, y - 7), (x + 2, y - 7), (x - 2, y - 4)]), CORAL, d=1)
    o.draw()


def reeds(cv, x, y):
    for i, dx in enumerate(range(-9, 10, 3)):
        h = 14 + (i * 5) % 7
        cv.fill(line([(x + dx, y), (x + dx + (i % 3) - 1, y - h)]), MOSS['b'] if i % 2 else MOSS['s'])
        if i % 2 == 0:
            o = cv.obj()
            o.part(rrect(x + dx - 1, y - h - 4, x + dx + 1, y - h + 1, 1), DWOOD, d=1)
            o.draw()


def flowers(cv, x, y):
    for dx, h, rp in ((-8, 8, BERRY), (-2, 12, GOLD), (4, 9, DUSK), (9, 7, CREAM)):
        cv.fill(line([(x + dx, y), (x + dx, y - h)]), MOSS['s'])
        o = cv.obj()
        o.part(rrect(x + dx - 2, y - h - 2, x + dx + 2, y - h + 2, 1), rp, d=1)
        o.draw()
        cv.dots([(x + dx, y - h)], GOLD['r'])


def cactus(cv, x, y):
    o = cv.obj()
    o.part(rrect(x - 3, y - 20, x + 3, y, 2), MOSS, d=2)
    o.part(rrect(x - 9, y - 14, x - 5, y - 5, 2) | rect(x - 6, y - 7, x - 3, y - 5), MOSS, d=1)
    o.part(rrect(x + 5, y - 17, x + 9, y - 9, 2) | rect(x + 3, y - 11, x + 6, y - 9), MOSS, d=1)
    o.draw()
    cv.dots([(x - 1, y - 18), (x + 1, y - 12), (x - 1, y - 6)], CREAM['r'])
    o = cv.obj()
    o.part(rrect(x - 2, y - 24, x + 2, y - 20, 1), BERRY, d=1)
    o.draw()


def crystals(cv, x, y):
    rocks(cv, x, y + 2)
    for dx, h in ((-3, 12), (2, 16), (6, 9)):
        o = cv.obj()
        o.part(poly([(x + dx - 2, y - 6), (x + dx + 2, y - 6), (x + dx + 2, y - h + 2), (x + dx, y - h), (x + dx - 2, y - h + 2)]), ICE, d=1)
        o.draw()


def butterflies(cv, x, y):
    flowers(cv, x, y)
    for bx, by, rp in ((x - 6, y - 20, GOLD), (x + 7, y - 24, DUSK)):
        o = cv.obj()
        o.part(rrect(bx - 4, by - 3, bx - 1, by + 1, 1) | rrect(bx + 1, by - 3, bx + 4, by + 1, 1), rp, d=1)
        o.part(rect(bx, by - 2, bx, by + 2), DWOOD, flat=True)
        o.draw()


def fern(cv, x, y):
    for ang in (-1, 0, 1):
        tip = (x + ang * 10, y - 15 + abs(ang) * 4)
        o = cv.obj()
        o.part(line([(x, y), tip], 2), MOSS, d=0)
        for t in (0.35, 0.6, 0.85):
            px, py = int(x + (tip[0] - x) * t), int(y + (tip[1] - y) * t)
            o.part(ell(px - 3, py - 2, px + 3, py + 1), LEAF, d=1)
        o.draw()


def snowdrift(cv, x, y):
    o = cv.obj()
    o.part(ell(x - 14, y - 9, x + 12, y + 1), ICE, d=2)
    o.draw()
    o = cv.obj()
    o.part(rrect(x - 4, y - 15, x + 4, y - 7, 2), STONE, d=2)
    o.draw()
    cv.dots([(x - 2, y - 13), (x + 1, y - 12), (x + 3, y - 10)], GOLD['b'])  # lichen


def coconut(cv, x, y):
    for dx in (-7, 0, 6):
        o = cv.obj()
        o.part(ell(x + dx - 4, y - 7, x + dx + 4, y), DWOOD, d=2)
        o.draw()
        cv.dots([(x + dx - 1, y - 5), (x + dx + 1, y - 5)], WOOD['s'])
    o = cv.obj()
    o.part(poly([(x - 12, y - 2), (x - 2, y - 12), (x + 1, y - 10), (x - 8, y)]), MOSS, d=1)
    o.draw()


def vines(cv, x, y):
    o = cv.obj()
    o.part(rrect(x - 3, y - 26, x + 3, y, 1), DWOOD, d=2)
    o.draw()
    for vy in range(y - 24, y - 2, 5):
        o = cv.obj()
        o.part(ell(x - 7, vy, x - 2, vy + 3), LEAF, d=1)
        o.part(ell(x + 2, vy + 2, x + 7, vy + 5), MOSS, d=1)
        o.draw()
    o = cv.obj()
    o.part(rrect(x + 3, y - 20, x + 9, y - 15, 2), BERRY, d=1)
    o.part(rect(x + 5, y - 18, x + 6, y - 17), GOLD, flat=True)
    o.draw()


PROPS = {f.__name__: f for f in (herbs, berry_bush, log, pond, rocks, mushrooms, shells, tidepool, reeds, flowers,
                                cactus, crystals, butterflies, fern, snowdrift, coconut, vines)}
TOOL_OF = {'herbs': 'forage', 'berry_bush': 'forage', 'mushrooms': 'forage', 'fern': 'forage', 'vines': 'forage',
           'flowers': 'forage', 'log': 'axe', 'pond': 'rod', 'reeds': 'rod', 'rocks': 'pick', 'crystals': 'pick',
           'snowdrift': 'pick', 'cactus': 'forage', 'shells': 'bucket', 'tidepool': 'bucket', 'butterflies': 'net',
           'coconut': 'hand'}

# landscape: sky, far, near, ground, ground-shade, deco colour, hotspots
SPOTS = [(34, 104), (82, 92), (126, 112), (170, 94), (208, 110)]
LAND = {
    'grassland':  ('#a9d6ea', '#a4b86a', '#7ab55c', '#9cc25e', '#7ab55c', '#f5cf6a', ['herbs', 'butterflies', 'flowers', 'rocks', 'berry_bush']),
    'forest':     ('#c9e4c0', '#2f6a3a', '#4f9a45', '#5f8a3a', '#4a7030', '#7a4a1f', ['mushrooms', 'fern', 'log', 'berry_bush', 'herbs']),
    'coast':      ('#a9d6ea', '#3f8fb0', '#25637d', '#e8cf96', '#c9a96e', '#f6e6b8', ['shells', 'tidepool', 'rocks', 'log', 'herbs']),
    'mountain':   ('#c3d8ea', '#8b8f96', '#5b6470', '#8a9a6a', '#6a7a50', '#c9c5bc', ['rocks', 'crystals', 'herbs', 'fern', 'pond']),
    'wetland':    ('#c9dccc', '#6a8a6a', '#4f7a55', '#6a9a55', '#4f7a45', '#3f8fb0', ['reeds', 'pond', 'flowers', 'log', 'butterflies']),
    'desert':     ('#f6d6a0', '#e0a050', '#c98a3a', '#e8c080', '#c9a060', '#f6e6b8', ['cactus', 'rocks', 'crystals', 'herbs', 'pond']),
    'rainforest': ('#b8e0c8', '#2f6a3a', '#1f5030', '#4f8a3a', '#3a6a2a', '#e46a9b', ['vines', 'mushrooms', 'pond', 'butterflies', 'fern']),
    'tundra':     ('#dfe8f6', '#c9e4ef', '#8fb6c9', '#eef4f8', '#c9dce6', '#ffffff', ['snowdrift', 'crystals', 'herbs', 'rocks', 'pond']),
    'island':     ('#9fdcef', '#3fafb0', '#25837d', '#f2dca0', '#d9bf80', '#f6e6b8', ['coconut', 'shells', 'tidepool', 'flowers', 'rocks']),
}


def scene(name):
    sky, far, near, gr, grs, deco, props = LAND[name]
    cv = Canvas(sky)
    cv.fill(ell(186, 12, 204, 30), '#fff3c8')  # sun, upper left light kept by props; sun sits as picture-book motif
    for cx, cy in ((40, 22), (120, 16)):
        cv.fill(ell(cx - 14, cy - 3, cx + 14, cy + 4) | ell(cx - 6, cy - 7, cx + 8, cy + 3), '#ffffff')
    if name in ('mountain', 'tundra'):
        for px, ph in ((50, 30), (110, 22), (175, 34)):
            cv.fill(poly([(px - 50, 70), (px, ph), (px + 50, 70)]), far)
            cv.fill(poly([(px - 9, ph + 8), (px, ph), (px + 9, ph + 8)]), '#ffffff')
    elif name in ('coast', 'island'):
        cv.fill(rect(0, 52, W - 1, 72), far)
        for x in range(4, W, 16):
            cv.fill(rect(x, 58 + (x // 16) % 3 * 4, x + 5, 58 + (x // 16) % 3 * 4), '#a9d6ea')
    else:
        cv.fill(ell(-40, 42, 140, 100) | ell(90, 38, 290, 104), far)
    if name in ('forest', 'rainforest'):
        for tx in range(-4, W, 22):
            cv.fill(poly([(tx - 10, 74), (tx, 36 + (tx * 7) % 12), (tx + 10, 74)]), near)
    elif name not in ('coast', 'island'):
        cv.fill(ell(-60, 58, 130, 100) | ell(110, 60, 300, 100), near)
    cv.fill(rect(0, 72, W - 1, H - 1), gr)
    cv.fill(ell(-30, 66, 120, 80) | ell(140, 68, 280, 80), gr)
    rng = np.random.RandomState(len(name))
    for _ in range(70):  # grass tufts / pebbles
        x, y = rng.randint(0, W), rng.randint(76, H)
        cv.dots([(x, y), (x + 1, y - 1)], grs)
    for _ in range(14):
        x, y = rng.randint(0, W), rng.randint(78, H)
        cv.dots([(x, y)], deco)
    spots = []
    for (x, y), p in sorted(zip(SPOTS, props), key=lambda t: t[0][1]):
        glow(cv, x, y)
        PROPS[p](cv, x, y - 1)
        spots.append({'prop': p, 'tool': TOOL_OF[p], 'x': x * 2, 'y': y * 2, 'r': 30})
    cv.save(os.path.join(HERE, f'gather-a-{name}.png'))
    return spots


# ---------------- tool icons, 32x32 (drawn on the grid, cropped) ----------------
def ic_hand(cv):
    sk = ramp('#f2c49a', '#c98a6a', '#ffe0c0')
    o = cv.obj()
    o.part(rrect(9, 13, 22, 27, 3), sk, d=2)
    for i, fx in enumerate((9, 13, 17)):
        o.part(rrect(fx, 5 + (i == 1) * -1, fx + 3, 15, 1), sk, d=1)
    o.part(rrect(20, 7, 23, 15, 1), sk, d=1)
    o.part(rrect(4, 14, 10, 18, 2), sk, d=1)
    o.part(rrect(9, 24, 22, 29, 1), MOSS, d=1, contour=True)
    o.draw()


def ic_forage(cv):  # foraging knife
    o = cv.obj()
    o.part(poly([(6, 25), (20, 6), (24, 8), (11, 27)]), METAL, d=1)
    o.part(rrect(3, 23, 11, 29, 2), WOOD, d=2, contour=True)
    o.draw()
    o = cv.obj()
    o.part(ell(19, 18, 28, 24) & rect(0, 0, 40, 21), RED, d=1)
    o.part(rect(22, 21, 24, 27), CREAM, d=1)
    o.draw()


def ic_pick(cv):
    o = cv.obj()
    o.part(line([(8, 28), (21, 9)], 3), WOOD, d=1)
    o.part(poly([(5, 8), (16, 4), (28, 10), (27, 13), (17, 8), (6, 11)]), METAL, d=1, contour=True)
    o.draw()


def ic_net(cv):
    o = cv.obj()
    o.part(line([(5, 28), (15, 16)], 3), WOOD, d=1)
    ringm = ell(12, 3, 29, 20) & ~ell(14, 5, 27, 18)
    o.part(ringm, METAL, d=0, contour=True)
    o.draw()
    mesh = ell(14, 5, 27, 18)
    yy, xx = np.mgrid[0:H, 0:W]
    cv.fill(mesh & (((xx + yy) % 4 == 0) | ((xx - yy) % 4 == 0)), CREAM['b'])


def ic_bucket(cv):
    o = cv.obj()
    o.part(poly([(6, 12), (26, 12), (23, 28), (9, 28)]), WATER, d=2)
    o.part(rect(5, 11, 27, 13), METAL, d=1, contour=True)
    o.draw()
    cv.fill(ell(6, 3, 26, 22) & ~ell(8, 5, 24, 22) & rect(0, 0, 40, 11), OL[1])
    o = cv.obj()
    o.part(poly([(12, 22), (16, 16), (20, 22)]), CORAL, d=1)
    o.draw()


def ic_axe(cv):
    o = cv.obj()
    o.part(line([(9, 28), (19, 5)], 3), WOOD, d=1)
    o.part(poly([(16, 6), (27, 4), (29, 12), (26, 16), (17, 13)]), METAL, d=2, contour=True)
    o.draw()


def ic_rod(cv):
    o = cv.obj()
    o.part(line([(4, 28), (26, 4)], 2), WOOD, d=0)
    o.part(ell(7, 21, 13, 27), METAL, d=1)
    o.draw()
    cv.fill(line([(26, 4), (27, 20)]), CREAM['b'])
    o = cv.obj()
    o.part(rrect(25, 19, 29, 24, 2), RED, d=1)
    o.draw()


def ic_basket(cv):
    o = cv.obj()
    o.part(ell(6, 4, 26, 24) & ~ell(9, 7, 23, 24) & rect(0, 0, 40, 15), WOOD, d=1)
    o.part(rrect(4, 14, 28, 28, 3), GOLD, d=2)
    o.draw()
    for y in (18, 22, 26):
        cv.fill(rect(6, y, 26, y), GOLD['s'])
    for x in range(8, 26, 4):
        cv.fill(rect(x, 15, x, 27), GOLD['bo'] if GOLD['bo'] else GOLD['s'])
    o = cv.obj()
    o.part(ell(9, 10, 15, 16), BERRY, d=1)
    o.part(ell(16, 9, 22, 15), LEAF, d=1)
    o.draw()


ICONS = {'hand': ic_hand, 'forage': ic_forage, 'pick': ic_pick, 'net': ic_net, 'bucket': ic_bucket,
         'axe': ic_axe, 'rod': ic_rod, 'basket': ic_basket}


def icon(name):
    cv = Canvas('#000000')
    cv.px[:] = 1  # sentinel background, turned transparent below
    ICONS[name](cv)
    a = cv.px[:32, :32]
    rgba = np.dstack([a, np.where(np.all(a == 1, axis=2), 0, 255).astype(np.uint8)])
    im = Image.fromarray(rgba, 'RGBA')
    im.save(os.path.join(HERE, f'tool-a-{name}.png'))
    im.resize((64, 64), Image.NEAREST).save(os.path.join(HERE, f'tool-a-{name}@2x.png'))
    return im


def main():
    meta = {n: scene(n) for n in LAND}
    icons = [icon(n) for n in ICONS]
    with open(os.path.join(HERE, 'hotspots.json'), 'w') as f:
        json.dump(meta, f, indent=1)
    cols, sw, sh, pad = 3, 480, 270, 8
    rows = (len(LAND) + cols - 1) // cols
    sheet = Image.new('RGBA', (cols * (sw + pad) + pad, rows * (sh + pad) + pad + 80), hx('#2a1a10') + (255,))
    for i, n in enumerate(LAND):
        sheet.paste(Image.open(os.path.join(HERE, f'gather-a-{n}.png')), (pad + i % cols * (sw + pad), pad + i // cols * (sh + pad)))
    y = pad + rows * (sh + pad)
    for i, im in enumerate(icons):
        big = im.resize((64, 64), Image.NEAREST)
        bg = Image.new('RGBA', (68, 68), hx('#f2e4c0') + (255,))
        sheet.paste(bg, (pad + i * 76, y))
        sheet.paste(big, (pad + 2 + i * 76, y + 2), big)
    sheet.save(os.path.join(HERE, 'preview.png'), optimize=True)


if __name__ == '__main__':
    main()
