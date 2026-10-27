"""Stage backdrops for mountain, wetland and desert, three variants each (2026-10-27):
game/assets/img/scenes/stage-<land>.png (v1), stage-<land>-v2.png, stage-<land>-v3.png.

Usage: python3 -B aseprite-source/scenes-pil/stages_mountain_wetland_desert.py [out_dir] [name ...]
       (default out_dir: game/assets/img/scenes; names like mountain, mountain-v2, desert-v3; default all nine)
Drawn on the 240 x 135 scene grid with pixlib (same kit as shops.py / stops.py), written at 2x (480 x 270), <= 32 colours.

Layout the stage code relies on (assets/stage.js, style.css .gvs-*), in grid px (export px = 2x):
- units stand with their feet on y 87..107 (front row 107, back rows 97 and 87), party on x 10..100, foes on x 140..230;
  so the ground from y 86 down is a calm, flat walkable meadow / sand / boardwalk with only tiny tufts on it;
- on phones (and the 480 px wide adventure column) data-crop shows only y 30..115, so the horizon, the landmark and
  the sun or moon all sit inside that band; the strip below y 115 is a quiet foreground that may be cut;
- the centre x 100..140 behind the lane holds the land's landmark (cairn, hut, heron, duck house, arch, oasis),
  the left and right thirds stay calm (framing props only at the very edges).
The old art's dark dripping top band and the round sun badge were painted into the PNGs (no overlay used them): dropped.
Palette: Part A families plus the Part D ramp recipe; borrowed hazy tints are noted where used.
"""
import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from pixlib import (Canvas, ramp, rect, rrect, ell, poly, line, blank, shift, W, H)  # noqa: E402
from shops import (WOOD, DWOOD, CREAM, STONE, PETAL, MOSS, LEAF, WATER, GOLD, EMBER, stitch_h)  # noqa: E402
from stops import (bands, wave, cloud, pine, rock, tufts, ripples, steam, lantern, PINE, ROOF, CANVAS)  # noqa: E402

GROUND = 86          # top of the walkable strip
NEAR = 113           # darker near band (mostly outside the phone crop)


# ------------------------------------------------------------------ shared helpers
def peak(cv, x, top, wl, wr, base, lit, shade, snow=None, snow_sh=None, sh=None, seed=0):
    """A faceted peak: lit left face, shaded right face (light from the upper left), a jagged snow cap."""
    m = poly([(x - wl, base), (x, top), (x + wr, base)])
    cv.fill(m, lit)
    face = poly([(x, top), (x + wr, base), (x + max(2, wr // 6), base)])
    cv.fill(m & face, shade)
    if snow:
        sh = sh if sh is not None else max(5, (base - top) // 3)
        pts = [(x - wl, top - 1)]
        n = 9
        for i in range(n + 1):
            t = i / n
            xx = round(x - wl * 0.55 + (wl * 0.55 + wr * 0.55) * t)
            yy = top + sh + (3 if (i + seed) % 2 else -1) - round(abs(t - 0.45) * sh * 0.9)
            pts.append((xx, yy))
        pts.append((x + wr, top - 1))
        cap = m & poly(pts)
        cv.fill(cap, snow)
        if snow_sh:
            cv.fill(cap & face, snow_sh)
    return m


def mesa(cv, x0, x1, top, base, lit, shade, stripe=None, cap=None, step=5):
    """Flat-topped butte with stepped sides and strata; right side in shade."""
    s = max(3, (x1 - x0) // 8)
    m = poly([(x0, base), (x0 + s, top + 3), (x0 + s + 2, top), (x1 - s - 2, top), (x1 - s, top + 3), (x1, base)])
    cv.fill(m, lit)
    if stripe:
        for y in range(top + 4, base, step):
            cv.fill(rect(0, y, W - 1, y + 1) & m, stripe)
    cv.fill(m & poly([(x1 - s - 2, top), (x1, base), (x1 - s - 8, base), (x1 - s - 6, top)]), shade)
    if cap:
        cv.fill(m & rect(0, top, W, top + 1), cap)
    return m


def flowers(cv, pts):
    for (x, y, c) in pts:
        cv.fill(rect(x, y, x + 1, y + 1), c)


def stars(cv, pts, col='#f5cf6a'):
    for (x, y) in pts:
        cv.dots([(x, y)], col)


def meadow(cv, top_c, lit_c, near_c, base=GROUND, terms=((2, 90, 0.6), (1, 31, 1.7))):
    g = wave(base, list(terms))
    cv.fill(g, top_c)
    cv.fill(g & ~shift(g, 0, 2), lit_c)
    nb = wave(NEAR, [(2, 120, 2.2), (1, 37, 0.4)])
    cv.fill(nb, near_c)
    return g


def snowy_pine(cv, x, ybot, w, h, snow='#f1ece0'):
    pine(cv, x, ybot, w, h)
    top = ybot - 4 - h
    for i in range(3):
        ty = top + round(h * 0.26 * i)
        by = top + round(h * (0.42 + 0.29 * i))
        hw = w / 2 * (0.5 + 0.25 * i)
        t = poly([(x, ty), (x + hw, by), (x - hw, by)])
        cv.fill(t & ~shift(t, 0, -2) & ~shift(t, -1, 0), snow)


def cairn(cv, x, base):
    stones = [(x - 10, base - 7, x + 10, base), (x - 7, base - 13, x + 8, base - 6), (x - 5, base - 18, x + 5, base - 12),
              (x - 3, base - 22, x + 3, base - 17)]
    for (a, b, c, d) in stones:
        o = cv.obj()
        o.part(ell(a, b, c, d + 2) & rect(0, 0, W, d), STONE, d=2)
        o.draw()


def cattails(cv, x0, x1, base, hmin=14, hvar=12, col='#2f6a3a', head='#7a4a1f', every=3, step=4):
    for x in range(x0, x1, step):
        hgt = hmin + (x * 7) % hvar
        cv.fill(rect(x, base - hgt, x, base), col)
        if (x // step) % every == 0:
            cv.fill(rect(x - 1, base - hgt + 1, x + 1, base - hgt + 6), head)
            cv.dots([(x, base - hgt - 1)], col)


def lily(cv, x, y, w, pad='#4f9a45', lit='#7ab55c', flower=None):
    m = ell(x, y, x + w, y + max(3, w // 3)) & ~poly([(x + w // 2, y + w // 6), (x + w, y), (x + w, y + w // 3)])
    cv.fill(m, pad)
    cv.fill(m & ~shift(m, 0, -1), lit)
    if flower:
        cv.fill(rect(x + w // 3, y - 1, x + w // 3 + 2, y), flower)
        cv.dots([(x + w // 3 + 1, y - 2)], flower)


def rain(cv, col, n=140, seed=3, ymax=H - 1, ln=3):
    for i in range(n):
        x = (i * 53 + seed * 17) % (W + 20) - 10
        y = (i * 37 + (i * i) % 29 + seed) % (ymax + 1)
        cv.fill(line([(x, y), (x - 1, y + ln)]), col)


def saguaro(cv, x, base, h, arms=((0.45, -1, 10), (0.6, 1, 8)), rp=MOSS):
    o = cv.obj()
    o.part(rrect(x - 3, base - h, x + 3, base, 2), rp, d=2)
    for (t, side, ah) in arms:
        ay = round(base - h * t)
        ax = x + side * 8
        o.part(rect(min(x, ax), ay, max(x, ax), ay + 3), rp, d=1)
        o.part(rrect(ax - 2, ay - ah, ax + 2, ay + 3, 2), rp, d=2)
    o.draw()
    for k in range(base - h + 3, base - 2, 3):
        cv.dots([(x - 1, k), (x + 1, k + 1)], rp['s'])


def barrel_cactus(cv, x, base, w=10, rp=MOSS, flower='#e46a9b'):
    o = cv.obj()
    o.part(ell(x, base - w, x + w, base + 2) & rect(0, 0, W, base), rp, d=2)
    o.draw()
    for k in range(x + 2, x + w - 1, 3):
        cv.fill(rect(k, base - w + 3, k, base - 1), rp['s'])
    if flower:
        cv.fill(rect(x + w // 2 - 1, base - w - 1, x + w // 2 + 1, base - w), flower)


def palm(cv, x, base, h, lean=6):
    o = cv.obj()
    tr = blank()
    for k in range(0, h, 1):
        t = k / h
        xx = round(x + lean * t * t)
        tr |= rect(xx - 2, base - k, xx + 1, base - k)
    o.part(tr, WOOD, d=1)
    tx, ty = round(x + lean), base - h
    fr = blank()
    for (dx, dy, ex, ey) in ((-16, 4, -8, -2), (16, 5, 8, -2), (-12, -6, -4, -4), (12, -7, 4, -4), (-3, -9, 3, -9)):
        fr |= poly([(tx, ty), (tx + ex, ty + ey), (tx + dx, ty + dy), (tx + dx // 2, ty + dy // 2 + 2)])
    fr |= ell(tx - 3, ty - 3, tx + 3, ty + 3)
    o.part(fr, MOSS, d=1, contour=True)
    o.draw()
    for i in range(tr.shape[0]):
        pass
    for k in range(4, h, 4):
        xx = round(x + lean * (k / h) ** 2)
        cv.fill(rect(xx - 2, base - k, xx + 1, base - k), '#7a4a1f')


def heron(cv, x, base):
    o = cv.obj()
    o.part(rect(x + 3, base - 10, x + 3, base) | rect(x + 6, base - 10, x + 6, base - 1), ramp('#5b6470', None), d=0)
    body = ell(x - 2, base - 19, x + 11, base - 9)
    o.part(body, ramp('#c9c5bc', '#8b8f96', '#f1ece0'), d=2)
    o.part(rect(x + 9, base - 27, x + 11, base - 15), ramp('#c9c5bc', '#8b8f96', '#f1ece0'), d=0)
    o.part(ell(x + 8, base - 31, x + 14, base - 26), ramp('#c9c5bc', '#8b8f96', '#f1ece0'), d=1, contour=True)
    o.draw()
    cv.fill(line([(x + 14, base - 28), (x + 19, base - 27)]), '#e8a317')
    cv.dots([(x + 11, base - 29)], '#2a1a10')
    cv.fill(rect(x + 9, base - 31, x + 13, base - 31), '#5b6470')
    cv.fill(rect(x - 2, base - 15, x + 4, base - 14), '#8b8f96')


def duck(cv, x, y, head='#4f9a45'):
    o = cv.obj()
    o.part(ell(x, y, x + 10, y + 6) & rect(0, 0, W, y + 4), ramp('#c9a96e', '#9a6b3f', '#f2e4c0'), d=1)
    o.part(ell(x + 6, y - 4, x + 11, y + 1), ramp(head, None), d=0, contour=True)
    o.draw()
    cv.dots([(x + 12, y - 2), (x + 13, y - 2)], '#f08a24')


def check(cv, name):
    n = cv.colours()
    assert n <= 32, f'{name}: {n} colours (cap 32)'
    return n


# ================================================================== MOUNTAIN v1: clear midday, snowy peaks, meadow, cairn, waterfall
def mountain():
    cv = Canvas()
    bands(cv, [(0, '#7fbcd8'), (12, '#a9d6ea'), (26, '#cde6e8'), (40, '#e6efe6')])
    cv.fill(ell(186, 34, 202, 50), '#f5cf6a')
    cloud(cv, 22, 30, 30, '#f1ece0', '#cde6e8')
    cloud(cv, 128, 14, 24, '#f1ece0', '#cde6e8')
    # far range, hazy lavender
    for (x, t, wl, wr) in ((14, 40, 36, 30), (62, 34, 30, 34), (162, 38, 34, 30), (224, 32, 30, 40)):
        peak(cv, x, t, wl, wr, 78, '#c3b2ea', '#c3b2ea', '#f1ece0', None, seed=x)
    # near range, faceted, snow caps
    for (x, t, wl, wr, s) in ((36, 46, 44, 40, 7), (118, 30, 52, 56, 10), (204, 44, 42, 48, 7)):
        peak(cv, x, t, wl, wr, 84, '#9f8ad6', '#7a5cc0', '#f1ece0', '#d9d4ee', sh=s, seed=x)
    # waterfall down the right shoulder of the big peak
    cv.fill(rect(150, 50, 153, 76), '#a9d6ea')
    cv.fill(rect(151, 52, 151, 76), '#f1ece0')
    # forest band of hazy pines at the foot of the range
    for x in range(-4, W + 8, 9):
        pine(cv, x, 84 + (x * 5) % 4, 10, 12 + (x * 13) % 9, flat='#4f7a5a')
    cv.fill(ell(146, 77, 158, 82), '#f1ece0')
    cv.fill(rect(0, 82, W - 1, 87), '#4f7a5a')
    meadow(cv, '#7ab55c', '#a4b86a', '#4f9a45')
    # path from the near edge up to the cairn
    p = poly([(106, 135), (138, 135), (126, 88), (118, 88)])
    cv.fill(p, '#c9a96e')
    cv.fill(p & ~shift(p, -2, 0), '#9a6b3f')
    cairn(cv, 132, 90)
    # framing pines at the very edges, boulders in the near corners
    pine(cv, 4, 108, 26, 64)
    pine(cv, 238, 110, 28, 70)
    rock(cv, -10, 112, 34, 136, moss=MOSS)
    rock(cv, 196, 116, 230, 138, moss=MOSS)
    tufts(cv, [(40, 100), (84, 108), (160, 96), (190, 104), (60, 92), (150, 124), (90, 126)], '#4f9a45')
    flowers(cv, [(52, 96, '#f5cf6a'), (96, 102, '#e46a9b'), (176, 92, '#f5cf6a'), (210, 100, '#f1ece0'), (70, 120, '#e46a9b'),
                 (150, 116, '#f5cf6a'), (30, 90, '#f1ece0')])
    for (x, y) in ((70, 22), (78, 18), (86, 24)):
        cv.fill(line([(x, y + 2), (x + 2, y), (x + 4, y + 2), (x + 6, y), (x + 8, y + 2)]), '#4e3a8a')
    cv.remap({'#fff3c8': '#f1ece0', '#c9c5bc': '#d9d4ee', '#f2e4c0': '#f1ece0'})
    return cv


# ================================================================== MOUNTAIN v2: dawn, low sun, mist on a tarn, prayer flags
def mountain_v2():
    cv = Canvas()
    bands(cv, [(0, '#9f8ad6'), (10, '#c3b2ea'), (22, '#f6d9e0'), (34, '#f6d9b0'), (46, '#f5cf6a')])
    cv.fill(ell(56, 38, 80, 62), '#fff3c8')
    for (x, y, w) in ((140, 26, 46), (6, 18, 40), (188, 36, 40)):
        cv.fill(rrect(x, y, x + w, y + 2, 1), '#f6d9e0')
    for (x, t, wl, wr) in ((30, 38, 34, 30), (104, 32, 36, 30), (186, 36, 30, 36), (236, 42, 28, 30)):
        peak(cv, x, t, wl, wr, 74, '#d9c4cc', '#d9c4cc', '#f6d9e0', None, seed=x)
    for (x, t, wl, wr, s) in ((10, 42, 44, 40, 7), (150, 24, 62, 56, 11), (238, 44, 38, 44, 7)):
        peak(cv, x, t, wl, wr, 76, '#9f8ad6', '#7a5cc0', '#f6b8cf', '#c3b2ea', sh=s, seed=x)
    # the tarn: still water mirroring the dawn, a sun path and mist strips
    bands(cv, [(72, '#c3b2ea'), (76, '#a9d6ea'), (82, '#7fbcd8')])
    for y in range(73, 86, 2):
        cv.fill(rect(60 + (y % 4) * 2, y, 76 - (y % 4) * 2, y), '#fff3c8')
    for x in range(-2, W + 6, 8):
        pine(cv, x, 75 + (x * 3) % 3, 7, 6 + (x * 11) % 6, flat='#7a5cc0')
    for (x, y, w) in ((90, 74, 60), (170, 78, 52), (-6, 80, 44), (110, 82, 40)):
        cv.fill(rrect(x, y, x + w, y + 1, 1), '#f6d9e0')
    meadow(cv, '#7ab55c', '#a4b86a', '#4f9a45', base=GROUND + 1)
    # prayer-flag line between two posts behind the lane (centre)
    o = cv.obj()
    o.part(rect(96, 50, 98, 92) | rect(144, 54, 146, 92), DWOOD, d=1)
    o.draw()
    pts = [(x, 52 + round(9 * (1 - ((2 * (x - 97) / 48) - 1) ** 2))) for x in range(97, 146)]
    cv.fill(line(pts), '#4a2c1a')
    cols = ['#d6322b', '#f5cf6a', '#3f8fb0', '#f1ece0', '#4f9a45']
    for i, (x, y) in enumerate(pts[3::6]):
        o = cv.obj(outline=False)
        o.part(rect(x - 2, y + 1, x + 2, y + 6), ramp(cols[i % 5], None), d=0)
        o.draw()
    rock(cv, 112, 82, 128, 92, moss=MOSS, d=2)
    # one big framing pine on the right, boulders and a stone in the near left
    pine(cv, 232, 108, 30, 72)
    rock(cv, -6, 116, 46, 138, moss=MOSS)
    rock(cv, 170, 120, 200, 136, d=2)
    tufts(cv, [(30, 100), (76, 106), (166, 98), (206, 104), (56, 94), (122, 124)], '#4f9a45')
    flowers(cv, [(44, 96, '#f6b8cf'), (100, 104, '#f5cf6a'), (186, 94, '#f6b8cf'), (214, 98, '#f5cf6a'), (80, 122, '#f6b8cf'),
                 (140, 118, '#f5cf6a'), (24, 92, '#f6b8cf')])
    cv.remap({'#c9c5bc': '#d9c4cc', '#f2e4c0': '#fff3c8', '#f1ece0': '#fff3c8'})
    return cv


# ================================================================== MOUNTAIN v3: dusk alpenglow, first snow, a lit hut
def mountain_v3():
    cv = Canvas()
    bands(cv, [(0, '#4e3a8a'), (12, '#7a5cc0'), (24, '#9f8ad6'), (38, '#c3b2ea'), (50, '#f6b8cf')])
    stars(cv, [(14, 6), (40, 12), (66, 4), (98, 9), (150, 5), (176, 14), (224, 8), (128, 16), (8, 20), (210, 22)])
    moon = ell(186, 30, 200, 44) & ~ell(191, 28, 205, 42)
    cv.fill(moon, '#f1ece0')
    for (x, t, wl, wr) in ((20, 42, 34, 30), (84, 40, 30, 34), (170, 44, 34, 30), (230, 38, 30, 40)):
        peak(cv, x, t, wl, wr, 78, '#9f8ad6', '#9f8ad6', '#c3b2ea', None, seed=x)
    for (x, t, wl, wr, s) in ((50, 44, 46, 44, 8), (136, 32, 50, 54, 11), (226, 50, 40, 40, 7)):
        peak(cv, x, t, wl, wr, 84, '#7a5cc0', '#4e3a8a', '#f6b8cf', '#c3b2ea', sh=s, seed=x)
    for x in range(-4, W + 8, 9):
        pine(cv, x, 84 + (x * 5) % 4, 10, 12 + (x * 13) % 9, flat='#4e3a8a')
    cv.fill(rect(0, 82, W - 1, 87), '#4e3a8a')
    meadow(cv, '#d9d4ee', '#f1ece0', '#c3b2ea')
    for (x, y, w) in ((20, 96, 14), (70, 104, 10), (180, 100, 16), (150, 92, 8), (210, 108, 10)):
        cv.fill(rrect(x, y, x + w, y + 1, 1), '#c3b2ea')
    # the hut on the slope, centre, warm window and smoke
    o = cv.obj()
    o.part(rect(108, 70, 134, 88), WOOD, d=2)
    roof = poly([(102, 72), (121, 56), (140, 72)])
    o.part(roof, ramp('#f1ece0', '#c3b2ea', '#fff3c8'), d=2, contour=True)
    o.part(rect(128, 56, 132, 66), STONE, d=1)
    o.draw()
    for x in range(112, 134, 5):
        cv.fill(rect(x, 74, x, 88), '#7a4a1f')
    o = cv.obj(); o.part(rect(112, 76, 122, 84), DWOOD, d=1); o.draw()
    cv.fill(rect(114, 78, 120, 82), '#f5cf6a')
    cv.fill(rect(117, 78, 117, 82), '#e8a317')
    cv.fill(rect(124, 78, 131, 88), '#5c3420')
    cv.fill(poly([(108, 89), (120, 89), (124, 96), (104, 96)]), '#f5cf6a')
    for (x, y, w) in ((132, 50, 6), (136, 44, 8), (142, 38, 7)):
        cv.fill(ell(x, y, x + w, y + w * 2 // 3), '#c3b2ea')
    cv.fill(rect(105, 71, 105, 73), '#4a2c1a')
    lantern(cv, 105, 74)
    # snowy framing pines at the edges and a snowy boulder in the near right
    snowy_pine(cv, 6, 110, 28, 66)
    snowy_pine(cv, 30, 100, 16, 30)
    snowy_pine(cv, 236, 108, 26, 60)
    o = cv.obj()
    m = ell(186, 116, 232, 146) & rect(0, 0, W, 135)
    o.part(m, STONE, d=3)
    o.draw()
    cv.fill(m & ~shift(m, 0, -3), '#f1ece0')
    tufts(cv, [(50, 102), (90, 110), (166, 104), (200, 96)], '#4f9a45')
    # falling snow, sparse
    for i in range(70):
        x = (i * 47 + 11) % W
        y = (i * 29 + (i * i) % 17) % 120
        cv.dots([(x, y)], '#f1ece0')
    cv.remap({'#fff3c8': '#f1ece0', '#c9c5bc': '#d9d4ee', '#9a6b3f': '#7a4a1f', '#f2e4c0': '#f1ece0'})
    return cv


# ================================================================== WETLAND v1: midday pond, reeds, heron, willow
def wetland():
    cv = Canvas()
    bands(cv, [(0, '#7fbcd8'), (14, '#a9d6ea'), (30, '#cde6e8')])
    cv.fill(ell(198, 30, 214, 46), '#f5cf6a')
    cloud(cv, 140, 30, 40, '#f1ece0', '#cde6e8')
    cloud(cv, 70, 14, 26, '#f1ece0', '#cde6e8')
    # far bank: hazy round trees
    for (x, w) in ((-8, 24), (10, 18), (24, 28), (50, 16), (64, 24), (86, 18), (100, 26), (122, 14), (134, 24), (156, 18),
                   (170, 26), (192, 16), (204, 24), (226, 22)):
        cv.fill(ell(x, 56 - w * 2 // 3, x + w, 60 + w // 4), '#a4b8a8')
    cv.fill(rect(0, 56, W - 1, 61), '#7a9a7a')
    # the pond behind the lane
    bands(cv, [(61, '#a9d6ea'), (66, '#7fbcd8'), (76, '#3f8fb0')])
    ripples(cv, rect(0, 66, W - 1, 86), '#a9d6ea', step=4, ln=5, seed=2)
    for (x, w, f) in ((20, 12, None), (58, 9, '#f6b8cf'), (150, 12, None), (176, 8, '#f6b8cf'), (200, 11, None), (88, 7, None)):
        lily(cv, x, 72 + (x % 3) * 3, w, flower=f)
    heron(cv, 112, 82)
    cv.fill(rect(108, 82, 128, 82), '#a9d6ea')
    # big willow at the left edge, drooping over the water
    crown = ell(-18, 14, 16, 42) | ell(-2, 8, 34, 38) | ell(14, 16, 42, 44) | ell(-10, 26, 30, 52)
    o = cv.obj()
    o.part(rect(6, 44, 12, 92) | poly([(6, 92), (2, 94), (16, 94), (12, 92)]), DWOOD, d=2)
    for m in (ell(-18, 14, 16, 42), ell(14, 16, 42, 44), ell(-2, 8, 34, 38), ell(-10, 26, 30, 52)):
        o.part(m, LEAF, d=2)
    o.draw()
    for x in range(-14, 42, 2):
        col = crown[:, max(0, min(W - 1, x))]
        ys = col.nonzero()[0]
        if x < 0 or not len(ys):
            continue
        yb = ys.max()
        ln = 12 + (x * 7) % 14
        cv.fill(rect(x, yb - 2, x, yb + ln), '#4f9a45' if x % 2 else '#7ab55c')
        cv.dots([(x, yb + ln + 1)], '#4f9a45')
    # near bank: soft wet grass, mud edge
    g = meadow(cv, '#7ab55c', '#a4b86a', '#4f9a45', terms=((2, 70, 1.1), (1, 23, 0.3)))
    cv.fill(g & ~shift(g, 0, 1), '#9a6b3f')
    cattails(cv, 196, 238, 92, hmin=16, hvar=14)
    cattails(cv, 60, 76, 88, hmin=8, hvar=6, every=2)
    cattails(cv, 160, 172, 88, hmin=9, hvar=6, every=2)
    # foreground: a mossy log in the near left corner, reeds near right
    o = cv.obj()
    o.part(rrect(-6, 118, 44, 128, 3), WOOD, d=2)
    o.part(ell(38, 117, 48, 129), ramp('#c9a96e', '#9a6b3f', '#f2e4c0'), d=1, contour=True)
    o.part(rrect(-6, 116, 30, 119, 1), MOSS, d=0, contour=True)
    o.draw()
    cv.fill(ell(41, 120, 45, 126) & ~ell(42, 121, 44, 125), '#9a6b3f')
    tufts(cv, [(54, 102), (96, 108), (150, 100), (180, 108), (130, 124), (210, 124), (80, 96)], '#4f9a45')
    flowers(cv, [(70, 100, '#f5cf6a'), (120, 104, '#f1ece0'), (166, 96, '#e46a9b'), (30, 96, '#f5cf6a'), (190, 118, '#f1ece0')])
    for (x, y) in ((92, 36), (100, 32)):
        cv.fill(line([(x, y + 2), (x + 2, y), (x + 4, y + 2), (x + 6, y), (x + 8, y + 2)]), '#5b6470')
    cv.remap({'#fff3c8': '#f1ece0', '#f2e4c0': '#f1ece0', '#c9c5bc': '#f1ece0'})
    return cv


# ================================================================== WETLAND v2: soft rain, grey sky, duck house on a post
def wetland_v2():
    cv = Canvas()
    bands(cv, [(0, '#8b8f96'), (12, '#a3aab0'), (26, '#c9c5bc'), (40, '#d9dcd4')])
    for (x, y, w) in ((-10, 4, 70), (50, 0, 60), (120, 6, 64), (180, 0, 70)):
        cloud(cv, x, y, w, '#a3aab0', '#8b8f96')
    for (x, w) in ((-6, 20), (12, 26), (36, 16), (52, 24), (76, 18), (94, 22), (116, 16), (132, 26), (158, 18), (176, 22),
                   (198, 18), (214, 26)):
        cv.fill(ell(x, 58 - w * 2 // 3, x + w, 62 + w // 4), '#9aa89c')
    cv.fill(rect(0, 58, W - 1, 63), '#7a9a7a')
    bands(cv, [(63, '#8fb4c4'), (70, '#5b8aa0')])
    for i, (x, y) in enumerate(((20, 68), (52, 74), (90, 70), (150, 72), (184, 78), (214, 68), (130, 80), (36, 82), (70, 80))):
        r = 3 + i % 3
        cv.fill(ell(x - r, y - 1, x + r, y + 1) & ~ell(x - r + 1, y, x + r - 1, y), '#a9d6ea')
    for (x, w, f) in ((34, 12, None), (64, 8, None), (166, 12, '#f6b8cf'), (200, 9, None)):
        lily(cv, x, 74 + (x % 3) * 2, w, flower=f)
    # duck house on a post in the middle of the pond
    o = cv.obj()
    o.part(rect(118, 66, 121, 86), DWOOD, d=1)
    o.part(rect(110, 54, 130, 66), WOOD, d=2, contour=True)
    o.part(poly([(106, 56), (120, 44), (134, 56)]), ROOF, d=2, contour=True)
    o.draw()
    cv.fill(ell(116, 57, 124, 65) & rect(0, 0, W, 65), '#3d2a1c')
    cv.fill(rect(110, 66, 130, 66), '#5c3420')
    duck(cv, 144, 76)
    duck(cv, 88, 80, head='#9a6b3f')
    g = meadow(cv, '#4f9a45', '#7ab55c', '#2f6a3a', terms=((2, 80, 0.4), (1, 29, 2.0)))
    cv.fill(g & ~shift(g, 0, 1), '#5c3420')
    # puddles on the lane with rain rings
    for (x, y, w) in ((40, 100, 22), (170, 104, 26), (100, 120, 30)):
        p = ell(x, y, x + w, y + 4)
        cv.fill(p, '#8fb4c4')
        cv.fill(p & ~shift(p, 0, -1), '#5b8aa0')
        cv.dots([(x + w // 3, y + 2), (x + w // 3 + 1, y + 1), (x + w // 3 - 1, y + 1)], '#a9d6ea')
    cattails(cv, 0, 30, 96, hmin=20, hvar=16)
    cattails(cv, 212, 240, 94, hmin=18, hvar=14)
    rock(cv, 196, 118, 236, 136, moss=MOSS)
    tufts(cv, [(70, 106), (140, 98), (200, 106), (60, 124), (150, 126), (90, 94)], '#2f6a3a')
    rain(cv, '#c9d8de', n=150, seed=5)
    cv.remap({'#fff3c8': '#d9dcd4', '#f2e4c0': '#c9a96e', '#f1ece0': '#d9dcd4', '#c9c5bc': '#c9c5bc'})
    return cv


# ================================================================== WETLAND v3: dusk boardwalk over the marsh, fireflies
def wetland_v3():
    cv = Canvas()
    bands(cv, [(0, '#4e3a8a'), (12, '#7a5cc0'), (24, '#c3b2ea'), (36, '#f6b8cf'), (46, '#f5cf6a')])
    stars(cv, [(20, 6), (60, 10), (108, 4), (170, 8), (214, 12), (140, 14)])
    cv.fill(ell(150, 40, 170, 60), '#f5cf6a')
    cv.fill(ell(150, 40, 170, 60) & rect(0, 52, W, H), '#f08a24')
    # far tree line in dusk violet, a reed bed in front of it
    for (x, w) in ((-6, 22), (14, 28), (40, 18), (56, 26), (80, 16), (94, 24), (118, 18), (134, 22), (176, 26), (200, 18),
                   (216, 28)):
        cv.fill(ell(x, 56 - w * 2 // 3, x + w, 60 + w // 4), '#7a5cc0')
    cv.fill(rect(0, 56, W - 1, 61), '#4e3a8a')
    bands(cv, [(61, '#f6b8cf'), (66, '#c3b2ea'), (74, '#7a5cc0')])
    for y in range(62, 84, 2):
        cv.fill(rect(150 + (y % 4) * 2, y, 170 - (y % 4) * 2, y), '#f5cf6a')
    ripples(cv, rect(0, 70, W - 1, 84), '#c3b2ea', step=4, ln=5, seed=1)
    cattails(cv, 0, 70, 84, hmin=10, hvar=10, col='#4e3a8a', head='#3d2a1c', every=3, step=3)
    cattails(cv, 186, 240, 84, hmin=10, hvar=12, col='#4e3a8a', head='#3d2a1c', every=3, step=3)
    for (x, w) in ((84, 10), (110, 12), (136, 8)):
        lily(cv, x, 78, w, pad='#4e3a8a', lit='#7a5cc0')
    # the boardwalk: the lane itself, planks across the marsh, posts into the water below
    cv.fill(rect(0, 84, W - 1, H - 1), '#7a5cc0')
    ripples(cv, rect(0, 118, W - 1, H - 1), '#c3b2ea', step=5, ln=6, seed=4)
    o = cv.obj()
    for x in range(6, W, 34):
        o.part(rect(x, 112, x + 4, 128), DWOOD, d=1)
    o.draw()
    o = cv.obj()
    o.part(rect(-2, 86, W + 1, 111), WOOD, d=2)
    o.part(rect(-2, 112, W + 1, 115), DWOOD, d=1, contour=True)
    o.draw()
    for x in range(4, W, 11):
        cv.fill(rect(x, 88, x, 111), '#7a4a1f')
    cv.fill(rect(0, 86, W - 1, 86), '#c9a96e')
    for x in range(8, W, 22):
        cv.dots([(x + 3, 90), (x + 3, 107), (x + 14, 98)], '#5c3420')
    # rail posts with a rope at the back edge, a lantern at each end
    o = cv.obj()
    for x in (14, 66, 174, 226):
        o.part(rect(x, 72, x + 3, 88), DWOOD, d=1)
    o.draw()
    for (a, b) in ((14, 66), (174, 226)):
        pts = [(x, 74 + round(4 * (1 - ((2 * (x - a) / (b - a)) - 1) ** 2))) for x in range(a + 2, b + 2)]
        cv.fill(line(pts), '#c9a96e')
    lantern(cv, 15, 62)
    lantern(cv, 227, 62)
    # lily pads and a flower in the near water, fireflies over the marsh
    for (x, w, f) in ((30, 12, '#f6b8cf'), (120, 10, None), (196, 12, None), (80, 8, None)):
        lily(cv, x, 126 + (x % 3), w, flower=f)
    for (x, y) in ((40, 66), (90, 58), (120, 70), (196, 64), (150, 80), (60, 76), (210, 50), (24, 50)):
        cv.fill(rect(x, y, x + 1, y + 1), '#f5cf6a')
        cv.dots([(x - 1, y), (x + 2, y + 1)], '#a4b86a')
    cv.remap({'#fff3c8': '#f5cf6a', '#f2e4c0': '#c9a96e', '#c9c5bc': '#c3b2ea'})
    return cv


# ================================================================== DESERT v1: midday mesas, saguaro, a stone arch
def desert():
    cv = Canvas()
    bands(cv, [(0, '#7fbcd8'), (14, '#a9d6ea'), (28, '#cde6e8'), (40, '#f6d9b0')])
    cv.fill(ell(196, 32, 212, 48), '#fff3c8')
    cloud(cv, 30, 18, 30, '#f1ece0', '#cde6e8')
    # far mesas in warm haze (borrowed: ember 300 lightened toward soil 100)
    for (x0, x1, t) in ((-10, 40, 48), (64, 108, 52), (150, 196, 46), (210, 250, 54)):
        mesa(cv, x0, x1, t, 72, '#e8b48a', '#e8b48a')
    # mid mesas with red strata
    mesa(cv, 6, 70, 52, 82, '#e0805a', '#b8553a', stripe='#c96a40', cap='#f08a24')
    mesa(cv, 170, 236, 56, 82, '#e0805a', '#b8553a', stripe='#c96a40', cap='#f08a24')
    # dunes
    d1 = wave(74, [(4, 80, 0.3), (2, 33, 1.9)])
    cv.fill(d1, '#f5cf6a')
    cv.fill(d1 & ~shift(d1, -3, 0) & ~rect(0, 0, W, 76), '#e8a317')
    # the stone arch in the middle distance
    arch = (poly([(96, 88), (98, 62), (104, 54), (136, 54), (142, 62), (144, 88)]) & ~ell(106, 62, 134, 100)) | rect(96, 84, 106, 88)
    o = cv.obj()
    o.part(arch, ramp('#e0805a', '#b8553a', '#f6b89a'), d=3)
    o.draw()
    for y in (60, 66, 76):
        cv.fill(rect(96, y, 144, y) & arch & ~shift(arch, 0, 2), '#c96a40')
    # sand floor, ripple lines, near band
    g = meadow(cv, '#e8cf98', '#f6e7c0', '#c9a96e', terms=((1, 90, 0.6), (1, 41, 1.2)))
    for (x, y, w) in ((20, 96, 18), (64, 104, 22), (150, 98, 16), (188, 106, 20), (110, 100, 14), (40, 108, 12)):
        cv.fill(rect(x, y, x + w, y) | rect(x + 2, y - 1, x + w - 4, y - 1), '#d9b878')
    # framing: a tall saguaro at the left edge, prickly-pear and a rock at the right
    saguaro(cv, 14, 106, 54, arms=((0.42, 1, 14), (0.62, -1, 10)))
    saguaro(cv, 226, 92, 26, arms=((0.5, -1, 8),))
    barrel_cactus(cv, 196, 122, 12)
    barrel_cactus(cv, 152, 90, 8, flower='#f5cf6a')
    rock(cv, 30, 118, 70, 136, rp=ramp('#c9a96e', '#9a6b3f', '#f2e4c0'), d=3)
    rock(cv, 208, 118, 246, 138, rp=ramp('#e0805a', '#b8553a', '#f6b89a'), d=3)
    for (x, y) in ((60, 98), (130, 110), (176, 96), (100, 124), (88, 92)):
        cv.fill(rect(x, y, x + 2, y + 1), '#9a6b3f')
    cv.remap({'#f2e4c0': '#f6e7c0', '#f1ece0': '#f6e7c0', '#fff3c8': '#f6e7c0', '#cde6e8': '#f6e7c0'})
    return cv


# ================================================================== DESERT v2: cool dawn, the oasis with palms
def desert_v2():
    cv = Canvas()
    bands(cv, [(0, '#c3b2ea'), (12, '#d9d4ee'), (24, '#f6d9e0'), (36, '#f6d9b0'), (48, '#f5cf6a')])
    cv.fill(ell(34, 44, 58, 68), '#fff3c8')
    for (x, y, w) in ((90, 22, 50), (170, 30, 40), (10, 32, 30)):
        cv.fill(rrect(x, y, x + w, y + 2, 1), '#f6d9e0')
    for (x0, x1, t) in ((-10, 30, 50), (70, 120, 48), (176, 226, 52), (220, 256, 56)):
        mesa(cv, x0, x1, t, 70, '#c9a4b8', '#c9a4b8')
    # long dunes, lit from the low left sun
    d1 = wave(66, [(5, 110, 2.6), (2, 37, 0.4)])
    cv.fill(d1, '#f5cf6a')
    cv.fill(d1 & ~shift(d1, -4, 0) & ~rect(0, 0, W, 66), '#d99a4a')
    d2 = wave(76, [(4, 90, 0.9), (2, 29, 1.4)])
    cv.fill(d2, '#e8b878')
    cv.fill(d2 & ~shift(d2, -4, 0) & ~rect(0, 0, W, 78), '#d99a4a')
    # the oasis: a pool behind the lane, reeds and palms
    pool = ell(90, 76, 152, 90) & rect(0, 0, W, 88)
    cv.fill(ell(86, 74, 156, 92) & rect(0, 0, W, 88), '#a4b86a')
    cv.fill(pool, '#3f8fb0')
    cv.fill(pool & ~shift(pool, 0, -2), '#a9d6ea')
    for y in (81, 84):
        cv.fill(rect(100 + (y % 3) * 4, y, 116 + (y % 3) * 4, y), '#a9d6ea')
    palm(cv, 104, 84, 40, lean=-6)
    palm(cv, 138, 86, 46, lean=6)
    palm(cv, 122, 82, 24, lean=4)
    cattails(cv, 90, 100, 86, hmin=6, hvar=5, every=2, step=3)
    cattails(cv, 144, 154, 86, hmin=6, hvar=5, every=2, step=3)
    g = meadow(cv, '#e8cf98', '#f6e7c0', '#c9a96e', terms=((1, 90, 0.6), (1, 41, 1.2)))
    # long morning shadows across the sand from the palms
    cv.fill(poly([(140, 88), (204, 93), (206, 95), (144, 91)]), '#d9b878')
    cv.fill(poly([(104, 88), (150, 95), (150, 97), (106, 91)]) & ~ell(86, 74, 156, 92), '#d9b878')
    for (x, y, w) in ((20, 98, 18), (64, 106, 22), (170, 104, 16), (196, 98, 18), (120, 108, 14)):
        cv.fill(rect(x, y, x + w, y) | rect(x + 2, y - 1, x + w - 4, y - 1), '#d9b878')
    # framing rocks; a water jar left by the path
    rock(cv, -12, 108, 34, 136, rp=ramp('#e0805a', '#b8553a', '#f6b89a'), d=3)
    rock(cv, 214, 114, 250, 136, rp=ramp('#c9a96e', '#9a6b3f', '#f2e4c0'), d=3)
    o = cv.obj()
    o.part(ell(196, 118, 210, 134) & rect(0, 0, W, 132), ramp('#e0805a', '#b8553a', '#f08a24'), d=2)
    o.part(rect(200, 114, 206, 119), ramp('#e0805a', '#b8553a', '#f08a24'), d=1, contour=True)
    o.draw()
    cv.fill(rect(197, 123, 209, 124) & ell(196, 118, 210, 134), '#b8553a')
    barrel_cactus(cv, 40, 96, 9, flower='#e46a9b')
    for (x, y) in ((70, 120), (130, 126), (170, 116), (56, 92)):
        cv.fill(rect(x, y, x + 2, y + 1), '#9a6b3f')
    for (x, y) in ((186, 40), (194, 36), (202, 42)):
        cv.fill(line([(x, y + 2), (x + 2, y), (x + 4, y + 2), (x + 6, y), (x + 8, y + 2)]), '#7a5cc0')
    cv.remap({'#f2e4c0': '#f6e7c0', '#f1ece0': '#f6e7c0', '#c9c5bc': '#c9a4b8', '#e8a317': '#d99a4a'})
    return cv


# ================================================================== DESERT v3: sunset hoodoos, first stars, a lantern camp
def desert_v3():
    cv = Canvas()
    bands(cv, [(0, '#4e3a8a'), (12, '#7a5cc0'), (24, '#c36a9a'), (36, '#f08a24'), (48, '#f5cf6a')])
    stars(cv, [(14, 6), (52, 10), (90, 4), (130, 12), (176, 6), (220, 10), (200, 20), (30, 18)])
    cv.fill(ell(110, 44, 134, 68), '#fff3c8')
    for (x0, x1, t) in ((-10, 46, 50), (62, 102, 56), (146, 186, 52), (198, 252, 48)):
        mesa(cv, x0, x1, t, 76, '#c36a9a', '#c36a9a')
    # hoodoo pillars, left and right of the sun, back-lit (dark side toward us)
    for (x, top, w) in ((70, 44, 12), (86, 56, 9), (156, 48, 12), (172, 58, 9)):
        o = cv.obj()
        body = blank()
        k = 0
        for y in range(top + 6, 84, 6):
            ww = w if k % 2 == 0 else w - 4
            body |= ell(x + (w - ww) // 2, y, x + (w + ww) // 2, y + 8)
            k += 1
        body |= rect(x + 2, top + 8, x + w - 2, 84)
        o.part(body & rect(0, 0, W, 84), ramp('#e0805a', '#b8553a', '#f6b89a'), d=2)
        o.part(rrect(x - 2, top + 1, x + w + 2, top + 6, 2), ramp('#b8553a', '#7a2a40', '#e0805a'), d=1, contour=True)
        o.draw()
    d1 = wave(76, [(3, 90, 1.3), (2, 33, 0.2)])
    cv.fill(d1, '#e8a317')
    cv.fill(d1 & ~shift(d1, -3, 0) & ~rect(0, 0, W, 78), '#b07a10')
    g = meadow(cv, '#e8b878', '#f5cf6a', '#c98a1a', terms=((1, 90, 0.6), (1, 41, 1.2)))
    for (x, y, w) in ((20, 98, 18), (64, 106, 22), (160, 102, 16), (196, 96, 18), (40, 110, 12)):
        cv.fill(rect(x, y, x + w, y) | rect(x + 2, y - 1, x + w - 4, y - 1), '#c98a1a')
    # framing: saguaro silhouettes against the sunset at the edges, a lantern post and a bedroll at the right
    saguaro(cv, 16, 104, 58, arms=((0.45, 1, 16), (0.6, -1, 12)))
    saguaro(cv, 34, 96, 22, arms=((0.5, 1, 7),))
    o = cv.obj(); o.part(rect(224, 64, 226, 104), DWOOD, d=1); o.part(rect(218, 62, 226, 64), DWOOD, d=0); o.draw()
    lantern(cv, 219, 65)
    o = cv.obj()
    o.part(rrect(190, 118, 236, 128, 4), ramp('#3f8fb0', '#25637d', '#a9d6ea'), d=2)
    o.part(ell(226, 115, 242, 131), ramp('#d6322b', '#a8241f', '#f08a24'), d=2, contour=True)
    o.draw()
    stitch_h(cv, 194, 222, 122, '#f5cf6a')
    rock(cv, -10, 116, 40, 138, rp=ramp('#b8553a', '#7a2a40', '#e0805a'), d=3)
    for (x, y) in ((60, 100), (150, 112), (180, 96), (96, 124)):
        cv.fill(rect(x, y, x + 2, y + 1), '#7a2a40')
    cv.remap({'#f2e4c0': '#fff3c8', '#f1ece0': '#fff3c8', '#c9c5bc': '#fff3c8', '#a9d6ea': '#fff3c8'})
    return cv


STAGES = {'mountain': mountain, 'mountain-v2': mountain_v2, 'mountain-v3': mountain_v3,
          'wetland': wetland, 'wetland-v2': wetland_v2, 'wetland-v3': wetland_v3,
          'desert': desert, 'desert-v2': desert_v2, 'desert-v3': desert_v3}

if __name__ == '__main__':
    out = sys.argv[1] if len(sys.argv) > 1 else os.path.join(os.path.dirname(__file__), '..', '..', 'game', 'assets', 'img', 'scenes')
    only = sys.argv[2:] or list(STAGES)
    for k in only:
        cv = STAGES[k]()
        n = check(cv, k)
        p = os.path.join(out, 'stage-' + k + '.png')
        cv.save(p)
        print(k, 'colours', n, '->', p)
