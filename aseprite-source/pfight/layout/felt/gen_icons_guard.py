#!/usr/bin/env python3
"""Guard-variant type icons for Puzzle Combat: brace, roll, thornhide, mending. Hard pixels only, no anti-aliasing.

Run:  python3 gen_icons_guard.py [out dir]      (default: game/assets/img/pfight)
Writes ico-<name>.png (32x32, cream halo) and ico-<name>-s.png (20x20, ink outline only, redrawn, not scaled).

Same finish as the shipped ico-*.png: those come from aseprite-source/pfight/gen_pfight.py, so this reuses its
finish_icon (per-pixel bevel: warm light top-left, hue-shifted cool shade lower-right, 1 px ink outline, 1 px cream
halo on the 32 px size) and its TYPES / dark_of / light_of palette.

Silhouettes (shape carries identity, colour only helps):
  brace     - brick wall slab with a wooden prop beam wedged against it, both standing on a ground plank
              (a right triangle with a hole in it)
  roll      - curled ball with a spiral, three motion streaks trailing off to the left
  thornhide - saguaro cactus (trunk + two raised arms, spines poking out) in a blue guard pot
  mending   - round-bottomed shield with a green plaster X whose four tabs stick out past the rim
"""
import os
import sys
from PIL import Image, ImageDraw

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.normpath(os.path.join(HERE, '..', '..')))      # aseprite-source/pfight
import gen_pfight as P                                                    # noqa: E402

INK, CREAM, WHITE = P.INK, P.CREAM, P.WHITE
BLUE = P.TYPES['guard']
BLUE_D = P.dark_of(BLUE)
BLUE_L = P.light_of(BLUE)
WOOD = (150, 100, 60)                 # same cork brown as the item jar lid
WOOD_D = P.dark_of(WOOD)
WOOD_L = P.light_of(WOOD)
CACT = (52, 156, 96)                  # cactus green, bluer than heal so it sits between guard and heal
CACT_D = P.dark_of(CACT)
PLAST = (96, 200, 140)                # plaster strip, heal-green family
PLAST_D = P.dark_of(P.TYPES['heal'])


def canvas(S):
    im = Image.new('RGBA', (S, S), (0, 0, 0, 0))
    return im, ImageDraw.Draw(im)


def put(im, pts, c):
    for x, y in pts:
        im.putpixel((x, y), c + (255,))


def finish(im, S, gloss):
    return P.finish_icon(im, halo=(S == 32), gloss=gloss)


def thorns(im, pts, halo):
    """ink thorns poking out of the ink outline (the foe-frame bramble language), re-wrapped in cream halo."""
    S = im.size[0]
    px = im.load()
    for x, y in pts:
        px[x, y] = INK + (255,)
    if halo:
        for x, y in pts:
            for dx in (-1, 0, 1):
                for dy in (-1, 0, 1):
                    xx, yy = x + dx, y + dy
                    if 0 <= xx < S and 0 <= yy < S and px[xx, yy][3] == 0:
                        px[xx, yy] = CREAM + (255,)
    return im


# ---------------------------------------------------------------- brace
def ico_brace(S):
    im, d = canvas(S)
    if S == 32:
        d.rectangle([3, 3, 13, 26], fill=BLUE)                                        # brick wall slab
        for y in (8, 14, 20):
            d.line([(3, y), (13, y)], fill=BLUE_D)                                    # mortar courses
        for r, (y0, y1) in enumerate(((3, 7), (9, 13), (15, 19), (21, 26))):
            for x in ((8,) if r % 2 == 0 else (5, 11)):
                d.line([(x, y0), (x, y1)], fill=BLUE_D)
        d.polygon([(14, 8), (17, 8), (29, 24), (29, 26), (25, 26), (14, 13)], fill=WOOD)   # prop beam
        d.line([(15, 10), (26, 24)], fill=WOOD_L)                                     # grain
        d.rectangle([14, 8, 14, 13], fill=WOOD_D)                                     # beam head against the wall
        d.rectangle([2, 27, 29, 29], fill=WOOD_D)                                     # ground plank
        d.line([(3, 27), (28, 27)], fill=WOOD)
        put(im, [(7, 28), (19, 28)], INK)                                             # plank nails
        g = [(5, 4), (6, 4), (5, 5)]
    else:
        d.rectangle([1, 1, 8, 16], fill=BLUE)
        for y in (5, 10):
            d.line([(1, y), (8, y)], fill=BLUE_D)
        put(im, [(4, 1), (4, 2), (4, 3), (4, 4), (2, 6), (2, 7), (2, 8), (2, 9), (6, 6), (6, 7), (6, 8), (6, 9),
                 (4, 11), (4, 12), (4, 13), (4, 14), (4, 15), (4, 16)], BLUE_D)
        d.polygon([(9, 5), (11, 5), (18, 15), (18, 16), (15, 16), (9, 8)], fill=WOOD)
        d.rectangle([1, 17, 18, 18], fill=WOOD_D)
        g = []
    return finish(im, S, g)


# ---------------------------------------------------------------- roll
def ico_roll(S):
    im, d = canvas(S)
    if S == 32:
        d.ellipse([10, 5, 29, 24], fill=BLUE)                                         # curled ball
        d.arc([13, 8, 26, 21], 200, 470, fill=CREAM, width=2)                         # outer curl
        d.arc([16, 11, 23, 18], 20, 290, fill=CREAM, width=2)                         # inner curl
        d.rectangle([19, 14, 20, 15], fill=BLUE_D)                                    # tucked nose
        for y, x0, x1 in ((8, 5, 9), (14, 2, 8), (20, 5, 9)):                         # motion streaks
            d.rectangle([x0, y, x1, y + 1], fill=BLUE_L)
        g = [(14, 8), (15, 7), (13, 9)]
    else:
        d.ellipse([6, 2, 18, 14], fill=BLUE)
        d.arc([8, 4, 16, 12], 200, 470, fill=CREAM, width=1)
        d.arc([10, 6, 14, 10], 20, 290, fill=CREAM, width=1)
        for y, x0, x1 in ((4, 2, 4), (8, 1, 4), (12, 2, 4)):
            d.line([(x0, y), (x1, y)], fill=BLUE_L)
        g = []
    return finish(im, S, g)


# ---------------------------------------------------------------- thornhide
def ico_thornhide(S):
    im, d = canvas(S)
    if S == 32:
        d.rounded_rectangle([13, 3, 18, 22], radius=2, fill=CACT)                     # trunk
        d.rectangle([5, 15, 13, 18], fill=CACT)                                       # left arm
        d.rounded_rectangle([4, 7, 8, 18], radius=2, fill=CACT)
        d.rectangle([18, 12, 26, 15], fill=CACT)                                      # right arm
        d.rounded_rectangle([23, 4, 27, 15], radius=2, fill=CACT)
        d.line([(15, 5), (15, 20)], fill=CACT_D)                                      # ribs
        d.line([(6, 9), (6, 16)], fill=CACT_D)
        d.line([(25, 6), (25, 13)], fill=CACT_D)
        spines = [(2, 9), (1, 8), (2, 14), (1, 13), (6, 5), (6, 4), (11, 6), (10, 5), (11, 11), (10, 10),
                  (20, 7), (21, 6), (20, 18), (21, 17), (16, 1), (29, 6), (30, 5), (29, 11), (30, 10), (25, 2), (25, 1)]
        put(im, [(17, 8), (14, 12), (17, 16), (14, 19), (7, 12), (24, 9)], CREAM)     # areoles
        d.rectangle([7, 21, 24, 23], fill=BLUE)                                       # pot rim
        d.polygon([(9, 24), (22, 24), (21, 29), (10, 29)], fill=BLUE)                 # pot
        d.line([(10, 26), (21, 26)], fill=CREAM)                                      # pot band
        put(im, [(12, 26), (15, 26), (18, 26)], BLUE_D)
        g = [(14, 4), (14, 5)]
    else:
        d.rounded_rectangle([8, 2, 11, 13], radius=1, fill=CACT)
        d.rectangle([3, 9, 8, 10], fill=CACT)
        d.rectangle([3, 4, 4, 10], fill=CACT)
        d.rectangle([11, 7, 16, 8], fill=CACT)
        d.rectangle([15, 2, 16, 8], fill=CACT)
        d.line([(9, 4), (9, 12)], fill=CACT_D)
        spines = [(1, 6), (18, 4), (9, 0), (6, 4), (13, 11), (1, 9)]
        put(im, [(9, 7), (10, 10), (4, 7), (15, 5)], CREAM)
        d.rectangle([4, 13, 15, 14], fill=BLUE)
        d.rectangle([5, 15, 14, 18], fill=BLUE)
        d.line([(6, 16), (13, 16)], fill=CREAM)
        g = []
    return thorns(finish(im, S, g), spines, S == 32)


# ---------------------------------------------------------------- mending
def strip(d, a, b, w, c):
    """a straight plaster strip of half-width w between points a and b, as a hard-edged polygon."""
    (x0, y0), (x1, y1) = a, b
    dx, dy = x1 - x0, y1 - y0
    n = (dx * dx + dy * dy) ** .5
    nx, ny = -dy / n * w, dx / n * w
    d.polygon([(x0 + nx, y0 + ny), (x1 + nx, y1 + ny), (x1 - nx, y1 - ny), (x0 - nx, y0 - ny)], fill=c)


def ico_mending(S):
    im, d = canvas(S)
    if S == 32:
        d.rectangle([6, 5, 25, 15], fill=BLUE)                                        # round-bottomed shield
        d.ellipse([6, 5, 25, 28], fill=BLUE)
        d.rectangle([6, 5, 25, 14], fill=BLUE)
        d.line([(10, 8), (13, 12), (11, 15), (14, 19)], fill=BLUE_D)                 # old crack peeking out
        d.line([(21, 22), (19, 19)], fill=BLUE_D)
        strip(d, (3.5, 3.5), (28, 28), 2.2, PLAST)                                    # plaster X, tabs past the rim
        strip(d, (28, 3.5), (3.5, 28), 2.2, PLAST)
        d.rectangle([13, 13, 18, 18], fill=CREAM)                                     # gauze pad where they cross
        put(im, [(14, 14), (17, 14), (14, 17), (17, 17), (6, 6), (25, 6), (6, 25), (25, 25)], PLAST_D)
        g = [(8, 7), (9, 7), (8, 8)]
    else:
        d.ellipse([3, 3, 16, 17], fill=BLUE)
        d.rectangle([3, 3, 16, 9], fill=BLUE)
        strip(d, (1.5, 1.5), (17.5, 17.5), 1.3, PLAST)
        strip(d, (17.5, 1.5), (1.5, 17.5), 1.3, PLAST)
        d.rectangle([8, 8, 11, 11], fill=CREAM)
        g = []
    return finish(im, S, g)


ICONS = {'brace': ico_brace, 'roll': ico_roll, 'thornhide': ico_thornhide, 'mending': ico_mending}


def build(out):
    os.makedirs(out, exist_ok=True)
    for n, f in ICONS.items():
        for S, suf in ((32, ''), (20, '-s')):
            im = f(S)
            assert im.size == (S, S) and im.mode == 'RGBA'
            assert all(a in (0, 255) for a in im.getchannel('A').getdata()), n   # hard pixels
            im.save(os.path.join(out, 'ico-%s%s.png' % (n, suf)))
    return list(ICONS)


if __name__ == '__main__':
    o = sys.argv[1] if len(sys.argv) > 1 else os.path.normpath(os.path.join(HERE, '..', '..', '..', '..', 'game', 'assets', 'img', 'pfight'))
    print(build(o), '->', o)
