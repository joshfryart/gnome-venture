"""Stage backdrops for grassland, forest and coast, three variants each (2026-10-27):
game/assets/img/scenes/stage-<land>.png (v1), stage-<land>-v2.png, stage-<land>-v3.png.

Usage: python3 -B aseprite-source/scenes-pil/stages_grass_forest_coast.py [out_dir] [name ...]
       names: grassland grassland-v2 grassland-v3 forest forest-v2 forest-v3 coast coast-v2 coast-v3 (default all)
Drawn on the 240 x 135 scene grid with pixlib, written at 2x (480 x 270), same kit as shops.py and stops.py.

Layout (grid px; exported px = 2x), what the stage code (assets/stage.js, .gvs-* in style.css) needs:
- Units stand with their feet at y 107 (front pair), 97 (second row) and 87 (back row); the party fills x 10..100 on the
  left, foes x 140..230 on the right, heads reach up to y 37. So the ground is flat open grass/sand/moss from y 86 down,
  and nothing raised stands in x 8..100 or x 140..232 below y 86; the far/mid layers behind the units stay calm.
- The centre (x 100..140) holds each scene's one feature, sitting on the horizon (y 30..90) so it reads between the parties.
- Phones (data-crop) show only y 30..115: the feature and the horizon sit inside it; sky detail above 30 and the
  foreground strip below 115 are decoration only and may be lost.
- No dark top band and no sun badge (both were only art in the old PNGs; no code draws over them).
Variants are the same land at another time or weather: v1 midday, v2 golden (dawn / late afternoon / sunset), v3 rain.
Palette: Part A families plus the Part D ramp recipe, and the same few haze tints the stop scenes use. Cap 32 colours.
"""
import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from pixlib import (Canvas, ramp, rect, rrect, ell, poly, line, blank, shift, W, H)  # noqa: E402
from shops import (WOOD, DWOOD, CREAM, STONE, BRICK, PETAL, MOSS, LEAF, WATER, DUSK, EMBER, GOLD, stitch_h)  # noqa: E402
from stops import (bands, wave, cloud, pine, tufts, ripples)  # noqa: E402

CANVAS = ramp('#f2e4c0', '#c9a96e', '#fff3c8')
BURLAP = ramp('#c9a96e', '#9a6b3f', '#f2e4c0')
HAY = ramp('#e8a317', '#b07a10', '#f5cf6a')
ROOF = ramp('#d6322b', '#a8241f', '#e0501f')
PINE = ramp('#2f6a3a', '#1f3f3a', '#4f9a45')
BARK = ramp('#7a4a1f', '#5c3420', '#9a6b3f')
OAK = ramp('#4f9a45', '#2f6a3a', '#7ab55c')
AUTUMN = ramp('#e8a317', '#b07a10', '#f5cf6a')
RUST = ramp('#e0501f', '#a8241f', '#f08a24')
SAND = ramp('#e8cf98', '#c9a96e', '#f2e4c0')
SHROOM = ramp('#d6322b', '#a8241f', '#f08a24')
COPPERL = ramp('#f08a24', '#b07a10', '#f5cf6a')

GROUND_Y = 86


# ------------------------------------------------------------------ small helpers
def rock(cv, x0, y0, x1, y1, rp=STONE, moss=None, d=3):
    """A boulder; moss = a ramp for a mossy cap over its top third (drawn as one object with the stone)."""
    o = cv.obj()
    m = ell(x0, y0, x1, y1 + (y1 - y0) // 2) & rect(0, 0, W, y1)
    o.part(m, rp, d=d)
    if moss:
        k = max(3, (y1 - y0) // 3)
        cap = m & ~shift(m, 0, k)
        for x in range(x0, x1, 4):
            cap |= m & rect(x, y0, x + 1, y0 + k + 2) & ~shift(m, 0, k + 2)
        o.part(cap, moss, d=1, contour=True)
    o.draw()
    return m


def sun(cv, x, y, r, col='#f5cf6a', rim='#fff3c8'):
    cv.fill(ell(x - r, y - r, x + r, y + r), col)
    cv.fill(ell(x - r + 2, y - r + 2, x + r - 3, y + r - 3) & ~ell(x - r + 3, y - r + 3, x + r, y + r), rim)


def flowers(cv, pts, cols):
    for i, (x, y) in enumerate(pts):
        c = cols[i % len(cols)]
        cv.dots([(x, y), (x + 1, y), (x, y - 1), (x + 1, y - 1)], c)
        cv.dots([(x, y + 1)], '#2f6a3a')


def rain(cv, col, ymax=H - 1, step=11, seed=0, clear=None):
    """Slanted 1 px streaks, 3 px long, on a loose staggered grid. clear = mask kept dry."""
    m = blank()
    r = rnd(seed + 40)
    for row, y in enumerate(range(-4, ymax, step)):
        x = r(0, 16) - 10
        while x < W + 10:
            m |= line([(x, y), (x - 1, y + 3)])
            x += r(12, 22)
    m &= rect(0, 0, W - 1, ymax)
    if clear is not None:
        m &= ~clear
    cv.fill(m, col)


def puddle(cv, x0, y0, x1, y1, water='#a9d6ea', deep='#7fbcd8'):
    m = ell(x0, y0, x1, y1)
    cv.fill(m, deep)
    cv.fill(m & ~shift(m, 1, 1), water)
    cv.fill(rect((x0 + x1) // 2 - 2, (y0 + y1) // 2, (x0 + x1) // 2 + 1, (y0 + y1) // 2), water)


def birds(cv, pts, col='#5b6470'):
    for (x, y) in pts:
        cv.fill(line([(x, y + 2), (x + 2, y), (x + 4, y + 2), (x + 6, y), (x + 8, y + 2)]), col)


def rainbow(cv, cx, cy, r, clip):
    cols = ['#d6322b', '#f08a24', '#f5cf6a', '#7ab55c', '#3f8fb0', '#7a5cc0']
    for i, c in enumerate(cols):
        rr = r - i * 2
        ring = ell(cx - rr, cy - rr, cx + rr, cy + rr) & ~ell(cx - rr + 2, cy - rr + 2, cx + rr - 2, cy + rr - 2)
        cv.fill(ring & clip, c)


def fence(cv, x0, x1, y, step=14, rp=WOOD, h=12):
    o = cv.obj()
    for x in range(x0, x1 + 1, step):
        o.part(rect(x, y - h, x + 2, y), rp, d=1)
    o.part(rect(x0 - 2, y - h + 3, x1 + 4, y - h + 4) | rect(x0 - 2, y - h + 8, x1 + 4, y - h + 9), rp, d=0, contour=True)
    o.draw()


def far_fence(cv, x0, x1, y, col, step=8, h=5):
    m = rect(x0, y - h + 1, x1, y - h + 1) | rect(x0, y - h + 3, x1, y - h + 3)
    for x in range(x0, x1 + 1, step):
        m |= rect(x, y - h, x, y)
    cv.fill(m, col)


def grass_edge(cv, y, col, x0=0, x1=W - 1, period=5):
    """A row of tiny grass teeth along a band top (hard pixels)."""
    for x in range(x0, x1 + 1):
        if x % period in (0, 2):
            cv.dots([(x, y - 1)], col)
        if x % period == 1:
            cv.dots([(x, y - 2), (x, y - 1)], col)


def sheep(cv, x, y):
    o = cv.obj(outline=False)
    o.part(ell(x, y, x + 6, y + 4), ramp('#f2e4c0', '#c9a96e'), d=1)
    o.draw()
    cv.dots([(x + 6, y + 1), (x + 7, y + 1), (x + 7, y + 2)], '#3d2a1c')
    cv.dots([(x + 1, y + 5), (x + 4, y + 5)], '#3d2a1c')


def haybale(cv, x, y, r):
    """A round bale lying on its side: a rolled body, the spiral end facing the light."""
    o = cv.obj()
    o.part(rrect(x + 3, y, x + 2 * r + 8, y + 2 * r, 2), HAY, d=2)
    o.part(ell(x, y, x + r + 3, y + 2 * r), ramp('#f5cf6a', '#e8a317', '#fff3c8'), d=1, contour=True)
    o.draw()
    cv.dots([(x + r // 2, y + r - 1), (x + r // 2 + 1, y + r), (x + r // 2 + 2, y + r - 2), (x + r // 2 - 1, y + r + 2)], '#b07a10')
    for yy in range(y + 3, y + 2 * r - 1, 3):
        cv.fill(rect(x + r + 3, yy, x + 2 * r + 5, yy), '#b07a10')


def windmill(cv, x, ybot, h=40, body=CANVAS, roof=ROOF, sails=WOOD, angle=0.35, L=30):
    """A tower mill: tapered body, red cap, four lattice sails, on the horizon."""
    o = cv.obj()
    o.part(poly([(x - 10, ybot), (x + 10, ybot), (x + 7, ybot - h), (x - 7, ybot - h)]), body, d=2)
    o.part(poly([(x - 9, ybot - h), (x + 9, ybot - h), (x, ybot - h - 10)]), roof, d=1, contour=True)
    o.part(rrect(x - 4, ybot - 12, x + 3, ybot, 2), DWOOD, d=0, contour=True)
    o.part(rect(x - 3, ybot - h + 12, x + 2, ybot - h + 17), DWOOD, d=0, contour=True)
    o.draw()
    cv.fill(rect(x - 2, ybot - h + 13, x + 1, ybot - h + 16), '#f5cf6a')
    hubx, huby = x, ybot - h + 3
    o = cv.obj()
    frames = []
    for k in range(4):
        a = angle + k * math.pi / 2
        ux, uy = math.cos(a), math.sin(a)
        nx, ny = -uy, ux
        ex, ey = hubx + L * ux, huby + L * uy
        o.part(line([(hubx, huby), (round(ex), round(ey))], 2), sails, d=0)
        p0 = (hubx + 7 * ux, huby + 7 * uy)
        quad = [(round(p0[0] + 1 * nx), round(p0[1] + 1 * ny)), (round(ex + 1 * nx), round(ey + 1 * ny)),
                (round(ex + 8 * nx), round(ey + 8 * ny)), (round(p0[0] + 8 * nx), round(p0[1] + 8 * ny))]
        m = poly(quad)
        o.part(m, CANVAS, d=0, contour=True)
        frames.append((m, ux, uy, nx, ny))
    o.draw()
    for (m, ux, uy, nx, ny) in frames:
        for t in range(10, L, 4):
            px, py = hubx + t * ux, huby + t * uy
            cv.fill(line([(round(px), round(py)), (round(px + 8 * nx), round(py + 8 * ny))]) & m, '#c9a96e')
    o = cv.obj(); o.part(ell(hubx - 2, huby - 2, hubx + 2, huby + 2), STONE, d=0); o.draw()


def meadow_clump(cv, x, ybot, heads, seed=0, w=26):
    """Tall grass and flower heads in a bottom corner of the foreground (below every stand spot)."""
    r = rnd(seed + 11)
    for i in range(w // 2):
        bx = x + r(0, w)
        h = r(6, 14)
        lean = r(-3, 3)
        cv.fill(line([(bx, ybot), (bx + lean, ybot - h)]), '#2f6a3a' if i % 3 else '#7ab55c')
        if i % 3 == 0:
            hx, hy = bx + lean, ybot - h - 1
            c = heads[i % len(heads)]
            cv.fill(rect(hx - 1, hy - 1, hx + 1, hy + 1), c)
            cv.dots([(hx, hy)], '#e8a317' if c != '#e8a317' else '#b07a10')


def oak(cv, x, y, w, h, leaf=OAK, trunk=BARK):
    """The big lone tree: a stout trunk with two roots, a layered clumpy crown."""
    cx = x + w // 2
    o = cv.obj()
    o.part(poly([(cx - 5, y + h - 8), (cx + 5, y + h - 8), (cx + 6, y + h + 16), (cx + 12, y + h + 19), (cx - 12, y + h + 19), (cx - 6, y + h + 16)]), trunk, d=2)
    o.part(line([(cx + 2, y + h - 4), (cx + 14, y + h - 14)], 3), trunk, d=0)
    o.draw()
    o = cv.obj()
    clumps = [(0.0, 0.42, 0.42, 0.95), (0.58, 0.40, 1.0, 0.92), (0.08, 0.12, 0.55, 0.62), (0.45, 0.08, 0.92, 0.6),
              (0.26, 0.0, 0.74, 0.42), (0.22, 0.45, 0.78, 1.0)]
    for (a, b, c, d) in clumps:
        o.part(ell(round(x + w * a), round(y + h * b), round(x + w * c), round(y + h * d)), leaf, d=3)
    o.draw()
    for (a, b) in ((0.2, 0.55), (0.42, 0.28), (0.66, 0.5), (0.5, 0.72), (0.8, 0.66)):
        px, py = round(x + w * a), round(y + h * b)
        cv.fill(line([(px, py), (px + 3, py - 2)]), leaf['s'])


def bush(cv, x, y, w, rp=OAK, berries=None):
    o = cv.obj()
    o.part(ell(x, y + w // 5, x + w * 3 // 5, y + w // 2 + 2) | ell(x + w * 2 // 5, y + w // 6, x + w, y + w // 2 + 2) | ell(x + w // 5, y, x + w * 4 // 5, y + w // 2), rp, d=2)
    o.draw()
    if berries:
        for (dx, dy) in ((0.25, 0.25), (0.55, 0.15), (0.75, 0.32), (0.4, 0.38)):
            cv.fill(rect(x + round(w * dx), y + round(w * dy), x + round(w * dx) + 1, y + round(w * dy) + 1), berries)


def signpost(cv, x, ybot, arms=((-1, 0), (1, 6))):
    o = cv.obj()
    o.part(rect(x - 1, ybot - 26, x + 1, ybot), WOOD, d=1)
    for (s, dy) in arms:
        y0 = ybot - 24 + dy
        if s < 0:
            o.part(poly([(x - 14, y0 + 2), (x - 11, y0), (x + 2, y0), (x + 2, y0 + 4), (x - 11, y0 + 4)]), CANVAS, d=1, contour=True)
        else:
            o.part(poly([(x - 2, y0), (x + 11, y0), (x + 14, y0 + 2), (x + 11, y0 + 4), (x - 2, y0 + 4)]), CANVAS, d=1, contour=True)
    o.draw()


def fern(cv, x, y, s=1, rp=LEAF):
    """A fern: six serrated fronds fanning out of one root, the outer ones drooping."""
    o = cv.obj()
    m = blank()
    for (dx, dy, droop) in ((-13, -5, 4), (-8, -12, 2), (-2, -15, 0), (4, -14, 0), (10, -10, 2), (14, -4, 4)):
        dx, dy = dx * s, dy * s
        ln = math.hypot(dx, dy)
        nx, ny = -dy / ln, dx / ln
        left, right = [], []
        for i in range(1, 8):
            t = i / 8
            off = 3.2 * s * math.sin(math.pi * t) * (1.0 if i % 2 else 0.55)
            px, py = x + dx * t, y + dy * t + droop * t * t
            left.append((round(px + nx * off), round(py + ny * off)))
            right.append((round(px - nx * off), round(py - ny * off)))
        tip = (round(x + dx), round(y + dy + droop))
        m |= poly([(x, y)] + left + [tip] + right[::-1])
    o.part(m, rp, d=1)
    o.draw()
    cv.fill(line([(x, y), (x - 6 * s, y - 3 * s)]) | line([(x, y), (x + 1, y - 8 * s)]) | line([(x, y), (x + 6 * s, y - 4 * s)]), rp['s'])


def toadstool(cv, x, ybot, r=5, cap=SHROOM):
    o = cv.obj()
    o.part(rect(x - 1, ybot - r - 2, x + 1, ybot), CREAM, d=1)
    o.part(ell(x - r, ybot - r * 2 - 2, x + r, ybot - 2) & rect(0, 0, W, ybot - r - 2), cap, d=1, contour=True)
    o.draw()
    cv.dots([(x - r // 2, ybot - r - 5), (x + r // 2, ybot - r - 6), (x, ybot - r * 2)], '#f2e4c0')


def stump(cv, x0, x1, ytop, ybot, moss=True):
    o = cv.obj()
    body = rect(x0, ytop + 3, x1, ybot) | poly([(x0 - 4, ybot), (x0, ybot - 6), (x0, ybot)]) | poly([(x1, ybot - 6), (x1 + 5, ybot), (x1, ybot)])
    o.part(body, BARK, d=2)
    o.part(ell(x0, ytop, x1, ytop + 6), BURLAP, d=1, contour=True)
    if moss:
        o.part(ell(x0 - 1, ytop - 2, x1 - 6, ytop + 5), LEAF, d=1, contour=True)
    o.draw()
    cv.fill(ell(x0 + 4, ytop + 1, x1 - 4, ytop + 5) & ~ell(x0 + 6, ytop + 2, x1 - 6, ytop + 4), '#9a6b3f')
    for xx in range(x0 + 4, x1 - 1, 5):
        cv.fill(rect(xx, ytop + 9, xx, ybot - 2), '#5c3420')


def log(cv, x0, x1, y, r=6, rp=BARK, moss=True):
    o = cv.obj()
    o.part(rrect(x0, y, x1, y + 2 * r, 3), rp, d=2)
    o.part(ell(x1 - r, y, x1 + r, y + 2 * r), BURLAP, d=1, contour=True)
    if moss:
        o.part(rrect(x0 + 4, y - 2, x0 + (x1 - x0) // 2, y + 2, 2), LEAF, d=1, contour=True)
    o.draw()
    cv.fill(ell(x1 - r + 3, y + 3, x1 + r - 3, y + 2 * r - 3) & ~ell(x1 - r + 4, y + 4, x1 + r - 4, y + 2 * r - 4), '#9a6b3f')
    for xx in range(x0 + 6, x1 - r, 9):
        cv.fill(rect(xx, y + 5, xx + 4, y + 5), rp['s'])


def trunk(cv, x, w, ytop, ybot, rp=BARK, roots=True):
    o = cv.obj()
    m = rect(x, ytop, x + w, ybot)
    if roots:
        m |= poly([(x - 5, ybot), (x, ybot - 8), (x, ybot)]) | poly([(x + w, ybot - 8), (x + w + 6, ybot), (x + w, ybot)])
    o.part(m, rp, d=2)
    o.draw()
    for yy in range(ytop + 6, ybot - 4, 9):
        cv.fill(rect(x + 2 + (yy % 3), yy, x + 2 + (yy % 3), yy + 4), rp['s'])


def rnd(seed):
    """Tiny deterministic generator (the scenes must rebuild identically)."""
    st = [seed * 2654435761 % 4294967296 or 1]

    def r(a, b):
        st[0] = (st[0] * 1103515245 + 12345) % 2147483648
        return a + (st[0] >> 8) % (b - a + 1)
    return r


def canopy(cv, y, rps, seed=0, back=None, hang=True):
    """A leafy roof across the top: a flat darker back row, then clumps of mixed size, each outlined with its own crescent."""
    r = rnd(seed)
    if back:
        x = -12
        while x < W + 10:
            w = r(14, 24)
            if r(0, 2):
                cv.fill(ell(x, y - 14 + r(0, 8), x + w, y + 4 + r(0, 12)), back)
            x += w - r(4, 8)
    x = -16
    while x < W + 10:
        w, h = r(22, 38), r(18, 26)
        top = y - 20 + r(-3, 6)
        rp = rps[r(0, len(rps) - 1)]
        o = cv.obj()
        o.part(ell(x, top, x + w, top + h), rp, d=3)
        if hang and r(0, 2) == 0:
            hx = x + r(6, w - 10)
            o.part(ell(hx, top + h - 6, hx + 10, top + h + 6), rp, d=2)
        o.draw()
        for k in range(2):
            px, py = x + r(6, max(7, w - 8)), top + r(5, max(6, h - 6))
            cv.fill(line([(px, py), (px + 3, py - 2)]), rp['s'])
        x += w - r(6, 12)


# ------------------------------------------------------------------ GRASSLAND
def meadow_ground(cv, top, near, far_meadow, path_c, path_s, flowers_on=True, path=True):
    cv.fill(rect(0, top, W - 1, H - 1), far_meadow)
    cv.fill(rect(0, top + 22, W - 1, H - 1), near)
    grass_edge(cv, top + 22, near)
    if path:
        pm = poly([(114, top), (126, top), (150, H), (90, H)])
        cv.fill(pm, path_c)
        cv.fill(pm & ~shift(pm, -2, 0), path_s)
        cv.fill(pm & rect(0, top, W, top), path_s)


def grassland():
    cv = Canvas()
    bands(cv, [(0, '#7fbcd8'), (14, '#a9d6ea'), (30, '#cde6e8'), (44, '#e6efd8')])
    sun(cv, 200, 16, 9)
    cloud(cv, 18, 12, 36, '#f1ece0', '#cde6e8')
    cloud(cv, 150, 22, 28, '#f1ece0', '#cde6e8')
    cloud(cv, 80, 6, 22, '#f1ece0', '#cde6e8')
    birds(cv, [(64, 22), (76, 18)])
    # far hills: patchwork fields, one far windmill
    far = wave(56, [(4, 96, 0.4), (2, 41, 1.2)])
    cv.fill(far, '#b9cf8e')
    for x0 in range(-24, W, 30):
        cv.fill(far & poly([(x0, 40), (x0 + 12, 40), (x0 + 4, 80), (x0 - 8, 80)]), '#e8cf98')
    mid = wave(68, [(4, 130, 2.0), (2, 47, 0.6)])
    cv.fill(mid, '#a4b86a')
    for (x, w) in ((4, 12), (18, 16), (196, 14), (212, 18), (228, 12)):
        cv.fill(ell(x, 62, x + w, 62 + w), '#7ab55c')
    far_fence(cv, 150, 200, 74, '#7ab55c')
    for (x, y) in ((168, 66), (182, 70), (40, 70)):
        sheep(cv, x, y)
    meadow_ground(cv, GROUND_Y - 6, '#4f9a45', '#7ab55c', '#c9a96e', '#9a6b3f')
    grass_edge(cv, GROUND_Y - 6, '#7ab55c')
    # the lone oak at the end of the path, a hedge either side of it
    bush(cv, 84, 66, 22, berries='#e46a9b')
    bush(cv, 138, 68, 20)
    oak(cv, 92, 14, 58, 52)
    # meadow life, kept low and off the stand spots
    tufts(cv, [(20, 94), (60, 100), (180, 92), (210, 104), (100, 88), (148, 96), (36, 122), (200, 126), (8, 108), (232, 96)], '#4f9a45')
    tufts(cv, [(24, 124), (66, 128), (170, 120), (222, 130), (160, 132), (12, 132)], '#2f6a3a')
    flowers(cv, [(14, 90), (50, 92), (80, 104), (164, 102), (196, 90), (226, 108), (30, 112), (186, 112)],
            ['#f5cf6a', '#f2e4c0', '#e46a9b'])
    flowers(cv, [(6, 120), (44, 126), (78, 118), (162, 124), (210, 118), (234, 126), (24, 130), (190, 130)],
            ['#e46a9b', '#f5cf6a', '#f2e4c0', '#d6322b'])
    for (x, y) in ((106, 98), (128, 110), (118, 124)):
        cv.fill(rect(x, y, x + 2, y), '#e8cf98')
    meadow_clump(cv, -4, H, ['#d6322b', '#f1ece0'], seed=1)
    meadow_clump(cv, 214, H, ['#f1ece0', '#e46a9b'], seed=2)
    cv.remap({'#fff3c8': '#f1ece0', '#f2e4c0': '#f1ece0', '#c9c5bc': '#f1ece0'})
    return cv


def grassland_v2():
    """Golden dawn: sun rising behind the far hills, mist in the dips, a windmill on the knoll, hay bales."""
    cv = Canvas()
    bands(cv, [(0, '#c3b2ea'), (10, '#f6b8cf'), (22, '#f6d9b0'), (34, '#f5cf6a'), (46, '#f6d9b0')])
    sun(cv, 52, 50, 13, '#fff3c8', '#f1ece0')
    cloud(cv, 120, 10, 40, '#f6d9b0', '#f6b8cf')
    cloud(cv, 196, 18, 30, '#f6d9b0', '#f6b8cf')
    birds(cv, [(170, 34), (184, 28), (150, 30)], '#7a5cc0')
    far = wave(54, [(3, 110, 1.4), (2, 37, 0.2)])
    cv.fill(far, '#c9b48e')
    cv.fill(rect(0, 60, W - 1, 61) & far, '#e8dcc0')                     # mist ribbon
    mid = wave(66, [(5, 150, 0.4), (2, 53, 2.3)])
    cv.fill(mid, '#a4b86a')
    for x0 in range(-12, W, 26):                                         # ploughed rows on the mid hill
        cv.fill(mid & line([(x0, 64), (x0 + 20, 84)]), '#c9a96e')
    cv.fill(rect(0, 74, W - 1, 75) & mid, '#e8dcc0')
    for (x, w) in ((198, 16), (216, 20)):
        cv.fill(ell(x, 58, x + w, 58 + w), '#7ab55c')
    # the knoll with the windmill in the middle
    knoll = ell(70, 66, 170, 104) & rect(0, 0, W, GROUND_Y - 6)
    cv.fill(knoll, '#7ab55c')
    windmill(cv, 120, 76, angle=0.55)
    meadow_ground(cv, GROUND_Y - 6, '#4f9a45', '#7ab55c', '#e8cf98', '#c9a96e')
    cv.fill(rect(0, GROUND_Y - 6, W - 1, GROUND_Y - 5) & ~poly([(114, GROUND_Y - 6), (126, GROUND_Y - 6), (150, H), (90, H)]), '#a4b86a')
    # hay bales on the horizon line, a fence along the back of the field
    far_fence(cv, 4, 66, GROUND_Y - 7, '#9a6b3f', step=9, h=6)
    far_fence(cv, 174, 236, GROUND_Y - 7, '#9a6b3f', step=9, h=6)
    for (x, y, r) in ((12, 68, 6), (36, 71, 5), (180, 69, 6), (206, 72, 5)):
        haybale(cv, x, y, r)
    # dew, buttercups and clover, low
    tufts(cv, [(20, 94), (60, 100), (180, 92), (210, 104), (148, 96), (36, 122), (200, 126), (8, 108), (232, 96)], '#4f9a45')
    tufts(cv, [(24, 124), (66, 128), (170, 120), (222, 130), (12, 132)], '#2f6a3a')
    flowers(cv, [(14, 90), (50, 92), (84, 104), (164, 102), (196, 90), (226, 108), (30, 112), (186, 112)],
            ['#f5cf6a', '#f5cf6a', '#f2e4c0'])
    flowers(cv, [(6, 120), (44, 126), (78, 118), (162, 124), (210, 118), (234, 126)], ['#f5cf6a', '#e46a9b'])
    meadow_clump(cv, -4, H, ['#f5cf6a', '#f2e4c0'], seed=3)
    meadow_clump(cv, 214, H, ['#f5cf6a', '#e46a9b'], seed=4)
    cv.remap({'#f2e4c0': '#f6d9b0', '#c9c5bc': '#e8dcc0', '#f1ece0': '#fff3c8'})
    return cv


def grassland_v3():
    """A summer shower: grey-blue sky, a rainbow over the hills, puddles on the path, a hawthorn and a signpost."""
    cv = Canvas()
    bands(cv, [(0, '#8b8f96'), (12, '#a3abb3'), (26, '#c9c5bc'), (42, '#dcdccf')])
    for (x, y, w) in ((-6, 4, 48), (60, 0, 56), (150, 6, 44), (204, 2, 44)):
        cloud(cv, x, y, w, '#c9c5bc', '#8b8f96')
    sky = rect(0, 0, W - 1, 70)
    far = wave(58, [(4, 90, 2.4), (2, 33, 0.9)])
    rainbow(cv, 170, 78, 56, sky & ~far)
    cv.fill(far, '#9fb59a')
    mid = wave(70, [(4, 120, 1.0), (2, 45, 2.0)])
    cv.fill(mid, '#8fa86a')
    for (x, w) in ((6, 14), (22, 18), (204, 14), (220, 16)):
        cv.fill(ell(x, 62, x + w, 62 + w), '#6f9a5a')
    far_fence(cv, 40, 96, 76, '#6f9a5a')
    meadow_ground(cv, GROUND_Y - 6, '#4f9a45', '#6f9a5a', '#c9a96e', '#9a6b3f')
    grass_edge(cv, GROUND_Y - 6, '#6f9a5a')
    # centre: a hawthorn bush in flower by a signpost and a stone, all wet
    rock(cv, 80, 70, 100, 82, moss=LEAF)
    oak(cv, 98, 30, 46, 36)
    r = rnd(17)
    for i in range(26):                                                  # hawthorn blossom
        x, y = r(100, 142), r(32, 62)
        cv.dots([(x, y), (x + 1, y), (x, y + 1)], '#f1ece0' if i % 4 else '#f6b8cf')
    signpost(cv, 150, 82, ((-1, 0), (1, 7)))
    # puddles on the path and in the grass (ripples)
    puddle(cv, 108, 96, 124, 100)
    puddle(cv, 116, 112, 136, 118)
    puddle(cv, 30, 118, 50, 122)
    puddle(cv, 190, 120, 212, 124)
    rain(cv, '#dcdccf', ymax=GROUND_Y - 7, seed=2)
    rain(cv, '#a9d6ea', ymax=H - 1, step=19, seed=5, clear=rect(0, 0, W, GROUND_Y - 6))
    tufts(cv, [(20, 94), (60, 100), (180, 92), (210, 104), (148, 96), (36, 122), (200, 126), (8, 108), (232, 96)], '#2f6a3a')
    flowers(cv, [(14, 90), (50, 92), (84, 104), (164, 102), (196, 90), (226, 108)], ['#e46a9b', '#f5cf6a'])
    meadow_clump(cv, -4, H, ['#e46a9b', '#f1ece0'], seed=5)
    meadow_clump(cv, 214, H, ['#f5cf6a', '#f1ece0'], seed=6)
    cv.remap({'#fff3c8': '#f1ece0', '#f2e4c0': '#f1ece0'})
    return cv


# ------------------------------------------------------------------ FOREST
def forest_floor(cv, top, moss, dark, path_c, path_s):
    cv.fill(rect(0, top, W - 1, H - 1), moss)
    cv.fill(rect(0, top + 26, W - 1, H - 1), dark)
    grass_edge(cv, top + 26, dark)
    pm = poly([(108, top), (132, top), (162, H), (78, H)])
    cv.fill(pm, path_c)
    cv.fill(pm & ~shift(pm, -2, 0), path_s)
    for (x, y) in ((116, top + 8), (126, top + 18), (110, top + 30), (134, top + 40)):
        cv.fill(rect(x, y, x + 3, y), path_s)


def back_trunks(cv, col, ytop, ybot, wmin, wmax, gap, seed, shade=None):
    r = rnd(seed)
    x = r(-4, gap // 2)
    while x < W:
        w = r(wmin, wmax)
        cv.fill(rect(x, ytop, x + w, ybot), col)
        if shade:
            cv.fill(rect(x + w - 1, ytop, x + w, ybot), shade)
        x += w + r(gap // 2, gap)


def undergrowth(cv, y, col, seed):
    r = rnd(seed)
    x = -8
    while x < W:
        w = r(14, 24)
        cv.fill(ell(x, y - r(8, 14), x + w, y + 4), col)
        x += w - r(3, 7)


def forest():
    """Midday in the wood: green light, rows of trunks fading back, a big mossy stump with toadstools on the path."""
    cv = Canvas()
    bands(cv, [(0, '#e6efd8'), (36, '#d6e3b4'), (58, '#c4d698')])
    back_trunks(cv, '#c4d698', 16, GROUND_Y, 2, 4, 14, 3)
    cv.fill(wave(30, [(5, 47, 0.3), (3, 23, 1.9)], bottom=44), '#c4d698')
    back_trunks(cv, '#a4b86a', 18, GROUND_Y, 4, 7, 26, 7, shade='#93a85c')
    cv.fill(wave(22, [(5, 61, 1.1), (3, 29, 0.4)], bottom=34), '#a4b86a')
    undergrowth(cv, GROUND_Y - 2, '#7ab55c', 5)
    forest_floor(cv, GROUND_Y - 4, '#7ab55c', '#4f9a45', '#c9a96e', '#9a6b3f')
    for (x, y, w) in ((20, 96, 14), (60, 104, 10), (176, 98, 16), (206, 108, 12), (150, 90, 8), (34, 112, 12)):
        cv.fill(ell(x, y, x + w, y + 3), '#a4b86a')                       # sun spots on the moss
    trunk(cv, -6, 11, 0, GROUND_Y + 2)
    trunk(cv, 230, 13, 0, GROUND_Y + 4)
    trunk(cv, 52, 7, 0, GROUND_Y - 6)
    trunk(cv, 184, 8, 0, GROUND_Y - 8)
    canopy(cv, 16, [OAK, LEAF, OAK, MOSS], seed=3, back='#4f9a45')
    # the centrepiece: a big mossy stump, toadstools, ferns
    fern(cv, 88, GROUND_Y + 2)
    fern(cv, 152, GROUND_Y + 2, rp=MOSS)
    stump(cv, 102, 136, 60, GROUND_Y + 2)
    toadstool(cv, 144, GROUND_Y + 4, 7)
    toadstool(cv, 154, GROUND_Y + 5, 4)
    toadstool(cv, 96, GROUND_Y + 5, 4)
    toadstool(cv, 112, 62, 3)
    tufts(cv, [(20, 92), (52, 98), (186, 92), (220, 100), (34, 118), (196, 124), (8, 110), (230, 116)], '#4f9a45')
    tufts(cv, [(24, 124), (66, 130), (170, 122), (214, 132), (10, 132)], '#2f6a3a')
    flowers(cv, [(30, 102), (190, 106), (60, 120), (180, 126), (222, 112), (12, 98)], ['#f2e4c0', '#e46a9b'])
    for (x, y) in ((40, 128), (204, 122)):
        toadstool(cv, x, y, 3)
    fern(cv, 8, 134, rp=MOSS)
    fern(cv, 232, 134)
    cv.remap({'#fff3c8': '#f1ece0', '#f2e4c0': '#f1ece0', '#c9c5bc': '#f1ece0'})
    return cv


def forest_v2():
    """Late afternoon in autumn: gold light slanting from the upper left, a fallen log, leaves on the path."""
    cv = Canvas()
    bands(cv, [(0, '#f6d9b0'), (34, '#eed4a4'), (58, '#e0c99a')])
    back_trunks(cv, '#e0c99a', 16, GROUND_Y, 2, 4, 14, 11)
    cv.fill(wave(30, [(5, 53, 0.9), (3, 21, 0.2)], bottom=44), '#e0c99a')
    back_trunks(cv, '#c9a96e', 18, GROUND_Y, 4, 7, 26, 4, shade='#b08a55')
    cv.fill(wave(22, [(5, 67, 2.2), (3, 31, 1.4)], bottom=34), '#c9a96e')
    for x0 in (24, 92, 168):                                             # sunbeams: pale shafts from the upper left
        beam = poly([(x0, 0), (x0 + 14, 0), (x0 + 58, GROUND_Y - 4), (x0 + 38, GROUND_Y - 4)])
        cv.fill(beam, '#f6d9b0')
    undergrowth(cv, GROUND_Y - 2, '#a4b86a', 9)
    forest_floor(cv, GROUND_Y - 4, '#a4b86a', '#7ab55c', '#c9a96e', '#9a6b3f')
    for (x0, x1) in ((62, 102), (138, 176)):                             # the light lands on the floor too
        cv.fill(poly([(x0, GROUND_Y - 4), (x0 + 14, GROUND_Y - 4), (x1 + 8, GROUND_Y + 8), (x1 - 8, GROUND_Y + 8)]) & ~poly([(108, GROUND_Y - 4), (132, GROUND_Y - 4), (162, H), (78, H)]), '#c4d698')
    r = rnd(21)
    for i in range(46):                                                  # fallen leaves
        x, y = r(2, 236), r(GROUND_Y, H - 2)
        if 8 < x < 100 and GROUND_Y + 4 < y < 110 and i % 2:
            continue
        c = ('#e8a317', '#e0501f', '#f08a24')[i % 3]
        cv.fill(rect(x, y, x + 2, y) | rect(x + 1, y - 1, x + 1, y - 1), c)
    trunk(cv, -6, 11, 0, GROUND_Y + 2)
    trunk(cv, 230, 13, 0, GROUND_Y + 4)
    trunk(cv, 48, 7, 0, GROUND_Y - 6)
    trunk(cv, 186, 8, 0, GROUND_Y - 8)
    canopy(cv, 16, [AUTUMN, OAK, RUST, AUTUMN, COPPERL], seed=8, back='#e8a317')
    # the centrepiece: a fallen hollow log behind the path, bracket fungus, ferns turning gold
    fern(cv, 84, GROUND_Y + 1, rp=AUTUMN)
    log(cv, 86, 144, GROUND_Y - 16, 8)
    for (x, y) in ((100, GROUND_Y - 18), (110, GROUND_Y - 17)):
        o = cv.obj()
        o.part(ell(x, y, x + 9, y + 5) & rect(0, 0, W, y + 3), GOLD, d=1)
        o.draw()
    fern(cv, 158, GROUND_Y + 1)
    toadstool(cv, 150, GROUND_Y + 4, 5, cap=ramp('#c9a96e', '#9a6b3f', '#f2e4c0'))
    tufts(cv, [(20, 92), (52, 98), (186, 92), (220, 100), (34, 118), (196, 124), (8, 110), (230, 116)], '#7ab55c')
    tufts(cv, [(24, 124), (66, 130), (170, 122), (214, 132), (10, 132)], '#4f9a45')
    fern(cv, 8, 134, rp=AUTUMN)
    fern(cv, 232, 134, rp=RUST)
    cv.remap({'#fff3c8': '#f6d9b0', '#f2e4c0': '#f6d9b0', '#c9c5bc': '#f6d9b0', '#f1ece0': '#f6d9b0'})
    return cv


def forest_v3():
    """A misty wet morning: pines in the fog, rain, a mossy boulder with a toadstool ring and a little signpost."""
    cv = Canvas()
    bands(cv, [(0, '#c9c5bc'), (26, '#d6dccb'), (52, '#c3cdb6')])
    r = rnd(5)
    x = -6
    while x < W + 10:
        pine(cv, x, GROUND_Y - 6, r(14, 20), r(40, 56), flat='#c3cdb6')
        x += r(10, 16)
    cv.fill(rect(0, 50, W - 1, 52), '#d6dccb')                          # fog ribbon through the far pines
    x = 2
    while x < W + 10:
        pine(cv, x, GROUND_Y - 4, r(20, 26), r(54, 70), flat='#a3b59a')
        x += r(20, 30)
    cv.fill(rect(0, 64, W - 1, 65), '#c3cdb6')
    undergrowth(cv, GROUND_Y - 2, '#6f9a5a', 13)
    forest_floor(cv, GROUND_Y - 4, '#6f9a5a', '#4f9a45', '#9a6b3f', '#7a4a1f')
    trunk(cv, -6, 11, 0, GROUND_Y + 2)
    trunk(cv, 230, 13, 0, GROUND_Y + 4)
    pine(cv, 62, GROUND_Y - 4, 36, 90)
    pine(cv, 180, GROUND_Y - 6, 32, 82)
    # the centrepiece: a big mossy boulder, a ring of toadstools, a little signpost
    rock(cv, 98, 56, 142, GROUND_Y, moss=LEAF, d=4)
    rock(cv, 136, 72, 152, GROUND_Y)
    for (x, r_) in ((90, 3), (98, 4), (146, 4), (156, 3), (124, 3)):
        toadstool(cv, x, GROUND_Y + 4 + (1 if r_ == 3 else 0), r_, cap=ramp('#e46a9b', '#b8457a', '#f6b8cf'))
    signpost(cv, 86, GROUND_Y + 1, ((-1, 0),))
    fern(cv, 160, GROUND_Y + 2, rp=MOSS)
    puddle(cv, 104, 100, 122, 104)
    puddle(cv, 118, 116, 142, 121)
    puddle(cv, 26, 122, 46, 126)
    puddle(cv, 190, 118, 210, 122)
    rain(cv, '#e6efd8', ymax=GROUND_Y - 6, seed=4)
    rain(cv, '#a9d6ea', ymax=H - 1, step=19, seed=1, clear=rect(0, 0, W, GROUND_Y - 4))
    tufts(cv, [(20, 92), (52, 98), (186, 92), (220, 100), (34, 118), (196, 124), (8, 110), (230, 116)], '#4f9a45')
    tufts(cv, [(24, 124), (66, 130), (170, 122), (214, 132), (10, 132)], '#2f6a3a')
    for (x, y) in ((40, 104), (202, 98), (16, 126)):
        cv.dots([(x, y), (x + 1, y), (x, y - 1)], '#7a5cc0')
    fern(cv, 8, 134, rp=MOSS)
    fern(cv, 232, 134, rp=MOSS)
    cv.remap({'#fff3c8': '#f1ece0', '#f2e4c0': '#f1ece0', '#f6b8cf': '#f1ece0'})
    return cv


# ------------------------------------------------------------------ COAST
def lighthouse(cv, x, ybot, h=44, lit=False):
    o = cv.obj()
    tower = poly([(x - 7, ybot), (x + 7, ybot), (x + 5, ybot - h), (x - 5, ybot - h)])
    o.part(tower, CANVAS, d=2)
    o.part(rect(x - 6, ybot - h - 8, x + 6, ybot - h), STONE, d=1, contour=True)
    o.part(poly([(x - 7, ybot - h - 8), (x + 7, ybot - h - 8), (x, ybot - h - 15)]), ROOF, d=1, contour=True)
    o.part(rect(x - 8, ybot - h - 1, x + 8, ybot - h), DWOOD, d=0, contour=True)
    o.draw()
    for k in range(3):
        y0 = ybot - 7 - k * (h // 3)
        cv.fill(tower & rect(0, y0 - h // 7, W, y0), '#d6322b')
        cv.fill(tower & rect(x + 3, y0 - h // 7, W, y0), '#a8241f')
    cv.fill(rect(x - 4, ybot - h - 6, x + 4, ybot - h - 2), '#f5cf6a' if lit else '#a9d6ea')
    cv.fill(rect(x - 2, ybot - h - 6, x - 1, ybot - h - 2), '#fff3c8' if lit else '#f1ece0')
    cv.fill(rrect(x - 2, ybot - 9, x + 1, ybot - 1, 1), '#5c3420')


def headland(cv, pts, grass, top_lit, rockc=('#c9c5bc', '#8b8f96', '#5b6470'), cap=5):
    """A rocky headland (terrain: no outline): grey face with stepped strata, lit upper left, a grass cap on top."""
    m = poly(pts)
    cv.fill(m, rockc[1])
    ys, xs = m.nonzero()
    for i, y in enumerate(range(ys.min() + cap + 4, ys.max(), 6)):
        cv.fill(rect(0, y, W, y) & m & ~rect(0, 0, 4 + (i * 37) % 30, H), rockc[2])
    cv.fill(m & ~shift(m, -3, -3), rockc[2])
    cv.fill(m & ~shift(m, 2, 2), rockc[0])
    capm = m & ~shift(m, 0, cap)
    for x in range(0, W, 5):
        capm |= rect(x, 0, x + 2, H) & m & ~shift(m, 0, cap + 2)
    cv.fill(capm, grass)
    cv.fill(m & ~shift(m, 0, 1), top_lit)


def sea(cv, top, shore, cols, glints):
    """Sea bands from the horizon (top) down to the shore line."""
    bands(cv, [(top, cols[0]), (top + 8, cols[1]), (top + 20, cols[2])])
    ripples(cv, rect(0, top + 2, W - 1, top + 18), glints[0], step=4, ln=3, seed=4)
    ripples(cv, rect(0, top + 22, W - 1, shore - 2), glints[1], step=5, ln=5, seed=1)


def beach(cv, shore, sand, wet, foam, edge, dune=None, seed=0):
    """Shore line with a foam lip, a band of wet sand, then dry sand with ripples; a dune lip along the bottom."""
    s = wave(shore, [(1.5, 60, 0.4), (1, 23, 1.6)])
    cv.fill(s, wet)
    cv.fill(s & ~shift(s, 0, 1), foam)
    for x in range(4, W, 22):
        cv.fill(rect(x, shore - 2, x + 6, shore - 2), foam)
    d = wave(shore + 6, [(1.5, 70, 2.0), (1, 29, 0.1)])
    cv.fill(d, sand)
    cv.fill(d & ~shift(d, 0, 1), edge)
    r = rnd(seed + 7)
    for y in range(shore + 14, H, 7):                                    # wind ripples in the dry sand
        x = r(0, 20)
        while x < W:
            cv.fill(rect(x, y, x + r(3, 6), y), wet)
            x += r(16, 30)
    if dune:
        dm = wave(H - 9, [(2, 50, 0.7), (1.5, 21, 2.0)])
        cv.fill(dm, dune)
        cv.fill(dm & ~shift(dm, 0, 1), edge)


def marram(cv, x0, x1, ybot, col, lite, seed=0):
    r = rnd(seed + 3)
    x = x0
    while x < x1:
        h = r(6, 12)
        lean = r(-2, 3)
        cv.fill(line([(x, ybot), (x + lean, ybot - h)]), col)
        if r(0, 1):
            cv.fill(line([(x + 1, ybot), (x + lean + 3, ybot - h + 3)]), lite)
        x += r(2, 4)


def shells(cv, pts):
    for i, (x, y) in enumerate(pts):
        c = ('#f6b8cf', '#f1ece0', '#e8a317')[i % 3]
        cv.fill(rect(x, y, x + 2, y) | rect(x + 1, y - 1, x + 1, y - 1), c)


def starfish(cv, x, y, rp=ramp('#f08a24', '#e0501f', '#f5cf6a')):
    o = cv.obj(outline=False)
    m = blank()
    for k in range(5):
        a = -math.pi / 2 + k * 2 * math.pi / 5
        m |= line([(x, y), (round(x + 4 * math.cos(a)), round(y + 3 * math.sin(a)))], 2)
    o.part(m, rp, d=1)
    o.draw()


def boat_beached(cv, x, y):
    o = cv.obj()
    hull = poly([(x, y), (x + 54, y - 2), (x + 48, y + 12), (x + 8, y + 13)])
    o.part(hull, ramp('#3f8fb0', '#25637d', '#a9d6ea'), d=3)
    o.part(rect(x - 1, y - 3, x + 55, y), WOOD, d=1, contour=True)
    o.draw()
    cv.fill(rect(x + 4, y + 5, x + 50, y + 6) & hull, '#f1ece0')
    o = cv.obj()
    o.part(line([(x + 12, y - 3), (x + 40, y - 14)], 2), WOOD, d=0)
    o.part(poly([(x + 38, y - 14), (x + 46, y - 19), (x + 49, y - 16), (x + 41, y - 11)]), WOOD, d=0, contour=True)
    o.draw()
    cv.fill(line([(x + 54, y - 1), (x + 64, y + 9)]), '#c9a96e')
    o = cv.obj(); o.part(rect(x + 63, y + 6, x + 65, y + 11), DWOOD, d=0); o.draw()


def bucket_spade(cv, x, y):
    o = cv.obj()
    o.part(poly([(x, y), (x + 10, y), (x + 9, y + 9), (x + 1, y + 9)]), ROOF, d=1)
    o.part(rect(x - 1, y - 1, x + 11, y), ROOF, d=0, contour=True)
    o.draw()
    cv.fill(line([(x, y), (x + 5, y - 5), (x + 10, y)]), '#4a2c1a')
    o = cv.obj()
    o.part(line([(x + 15, y + 10), (x + 19, y - 6)], 2), WOOD, d=0)
    o.part(poly([(x + 13, y + 8), (x + 18, y + 9), (x + 16, y + 14), (x + 12, y + 13)]), ramp('#e8a317', '#b07a10', '#f5cf6a'), d=0, contour=True)
    o.draw()


def sail(cv, x, y, s, col='#f1ece0', hull='#7a4a1f'):
    o = cv.obj(outline=False)
    o.part(poly([(x, y - s - 4), (x, y), (x - s, y)]), ramp(col, None), d=0)
    o.part(poly([(x + 1, y - s), (x + 1, y), (x + s // 2 + 2, y)]), ramp(col, None), d=0)
    o.part(rect(x - s - 1, y + 1, x + s // 2 + 2, y + 2), ramp(hull, None), d=0)
    o.draw()


def coast():
    """Midday on the beach: a lighthouse on the headland, sails out at sea, a rowboat pulled up on the sand."""
    cv = Canvas()
    bands(cv, [(0, '#7fbcd8'), (14, '#a9d6ea'), (28, '#cde6e8'), (38, '#f1ece0')])
    cloud(cv, 20, 10, 40, '#f1ece0', '#cde6e8')
    cloud(cv, 120, 18, 30, '#f1ece0', '#cde6e8')
    birds(cv, [(86, 22), (100, 16), (150, 34)])
    sea(cv, 44, GROUND_Y - 8, ('#a9d6ea', '#7fbcd8', '#3f8fb0'), ('#cde6e8', '#a9d6ea'))
    cv.fill(wave(41, [(3, 40, 0.0)], 2, 60, 44), '#a4c8a0')              # far island
    cv.fill(rect(30, 38, 33, 41), '#f1ece0')
    sail(cv, 70, 56, 9)
    sail(cv, 142, 52, 6)
    # headland on the right, the lighthouse and its keeper's cottage on top
    headland(cv, [(158, GROUND_Y - 6), (170, 72), (184, 62), (198, 58), (246, 56), (246, GROUND_Y - 6)], '#7ab55c', '#a4b86a', cap=6)
    lighthouse(cv, 220, 58, 28)
    o = cv.obj()
    o.part(rect(190, 50, 204, 59), CANVAS, d=1)
    o.part(poly([(188, 51), (197, 43), (206, 51)]), ROOF, d=1, contour=True)
    o.draw()
    cv.fill(rect(194, 53, 197, 56), '#3f8fb0')
    beach(cv, GROUND_Y - 8, '#e8cf98', '#c9a96e', '#f1ece0', '#f2e4c0', dune='#c9a96e', seed=1)
    # rocks at the left of the waterline, the boat in the middle
    rock(cv, 6, 70, 30, 82)
    rock(cv, 24, 75, 38, 82, moss=ramp('#7ab55c', '#4f9a45', '#a4b86a'))
    boat_beached(cv, 90, 78)
    starfish(cv, 152, 90)
    shells(cv, [(20, 96), (58, 106), (180, 100), (214, 110), (110, 104), (140, 120), (36, 118), (200, 116)])
    marram(cv, 0, 40, H - 6, '#7ab55c', '#a4b86a', seed=1)
    marram(cv, 196, 240, H - 6, '#7ab55c', '#a4b86a', seed=2)
    cv.remap({'#fff3c8': '#f1ece0', '#f2e4c0': '#f1ece0'})
    return cv


def coast_v2():
    """Sunset over the sea: warm sky, the sun on the horizon with its path, the lighthouse lit on the left, a jetty."""
    cv = Canvas()
    bands(cv, [(0, '#7a5cc0'), (10, '#c3b2ea'), (20, '#f6b8cf'), (30, '#f6d9b0'), (40, '#f5cf6a')])
    sun(cv, 124, 46, 11, '#f08a24', '#f5cf6a')
    cloud(cv, 70, 14, 40, '#f6b8cf', '#c3b2ea')
    cloud(cv, 186, 8, 34, '#f6b8cf', '#c3b2ea')
    birds(cv, [(110, 26), (124, 20), (206, 30)], '#4e3a8a')
    sea(cv, 46, GROUND_Y - 8, ('#c3b2ea', '#7a5cc0', '#4e3a8a'), ('#f6b8cf', '#c3b2ea'))
    for y in range(47, GROUND_Y - 10, 3):                                # the sun path on the water
        hw = 4 + (y - 46) // 2
        cv.fill(rect(124 - hw, y, 124 + hw, y) & ~rect(0, y, 124 - hw + (y % 4), y), '#f5cf6a')
    sail(cv, 196, 58, 7, '#f6d9b0', '#4e3a8a')
    headland(cv, [(-6, 58), (30, 58), (44, 62), (58, 72), (70, GROUND_Y - 6), (-6, GROUND_Y - 6)], '#7a9a5a', '#a4b86a',
             rockc=('#c3b2ea', '#8b8f96', '#5b6470'))
    lighthouse(cv, 20, 60, 30, lit=True)
    beach(cv, GROUND_Y - 8, '#e8cf98', '#c9a96e', '#f6d9b0', '#f6d9b0', dune='#c9a96e', seed=2)
    # a little jetty running straight out into the sun path; a lantern at its end, lobster pots and rope by its foot
    deck = poly([(106, GROUND_Y - 4), (134, GROUND_Y - 4), (126, 58), (114, 58)])
    o = cv.obj()
    for (y, hh) in ((60, 4), (66, 5), (73, 6)):
        t = (y - 58) / (GROUND_Y - 62)
        xl, xr = round(114 - 8 * t), round(126 + 8 * t)
        o.part(rect(xl, y, xl + 1, y + hh), DWOOD, d=0)
        o.part(rect(xr - 1, y, xr, y + hh), DWOOD, d=0)
    o.draw()
    o = cv.obj()
    o.part(deck, WOOD, d=1)
    o.draw()
    y, gap = 60, 2
    while y < GROUND_Y - 5:
        cv.fill(rect(0, y, W, y) & deck, '#7a4a1f')
        y += gap
        gap = min(gap + 1, 5)
    o = cv.obj(); o.part(rect(113, 40, 114, 58), DWOOD, d=0); o.draw()
    o = cv.obj()
    o.part(rect(110, 34, 117, 35), STONE, d=0)
    o.part(rect(111, 36, 116, 40), ramp('#f5cf6a', '#e8a317', '#fff3c8'), d=1, contour=True)
    o.draw()
    for (x, y) in ((140, GROUND_Y - 8), (150, GROUND_Y - 5)):
        o = cv.obj()
        o.part(rrect(x, y, x + 12, y + 8, 3), BURLAP, d=2)
        o.draw()
        for xx in range(x + 3, x + 11, 3):
            cv.fill(rect(xx, y + 1, xx, y + 7), '#9a6b3f')
    o = cv.obj(); o.part(ell(88, GROUND_Y - 4, 102, GROUND_Y + 3), ramp('#c9a96e', '#9a6b3f', '#f2e4c0'), d=1); o.draw()
    cv.fill(ell(91, GROUND_Y - 3, 99, GROUND_Y + 1) & ~ell(92, GROUND_Y - 2, 98, GROUND_Y), '#9a6b3f')
    rock(cv, 192, 74, 214, 84, moss=ramp('#7a9a5a', '#4f9a45', '#a4b86a'))
    for (x, y) in ((176, 86), (64, 84), (220, 88)):
        cv.fill(line([(x, y), (x + 4, y - 1), (x + 8, y)]), '#4f9a45')
    starfish(cv, 140, 96)
    shells(cv, [(20, 96), (58, 106), (180, 100), (214, 110), (114, 104), (140, 120), (36, 118), (200, 116)])
    marram(cv, 0, 36, H - 6, '#7a9a5a', '#a4b86a', seed=3)
    marram(cv, 204, 240, H - 6, '#7a9a5a', '#a4b86a', seed=4)
    cv.remap({'#fff3c8': '#f6d9b0', '#f2e4c0': '#f6d9b0', '#f1ece0': '#f6d9b0', '#c9c5bc': '#f6d9b0'})
    return cv


def coast_v3():
    """A blowy wet day: grey sea with white horses, rain, a wave breaking on the rocks, a fisher's hut with a lit window."""
    cv = Canvas()
    bands(cv, [(0, '#5b6470'), (10, '#8b8f96'), (24, '#a3abb3'), (36, '#c9c5bc')])
    for (x, y, w) in ((-8, 2, 52), (52, -2, 60), (130, 4, 48), (186, 0, 60)):
        cloud(cv, x, y, w, '#8b8f96', '#5b6470')
    sea(cv, 44, GROUND_Y - 8, ('#8b8f96', '#5b8a9a', '#25637d'), ('#c9c5bc', '#a9d6ea'))
    for (x, y) in ((20, 50), (64, 56), (110, 52), (160, 60), (186, 54), (40, 66), (150, 70), (90, 64), (220, 68), (200, 74)):
        cv.fill(line([(x, y + 1), (x + 3, y), (x + 6, y + 1)]), '#f1ece0')
    # the lighthouse far out on its rock (right), lamp lit for the weather
    rk = poly([(192, 58), (198, 50), (204, 46), (224, 45), (232, 50), (238, 58)])
    cv.fill(rk, '#5b6470')
    cv.fill(rk & ~shift(rk, 2, 2), '#8b8f96')
    cv.fill(rect(200, 52, 230, 52) & rk, '#3d2a1c')
    cv.fill(rect(190, 58, 240, 58) | rect(186, 59, 194, 59) | rect(234, 59, 242, 59), '#f1ece0')
    lighthouse(cv, 214, 47, 24, lit=True)
    beach(cv, GROUND_Y - 8, '#c9a96e', '#9a6b3f', '#f1ece0', '#e8cf98', dune='#9a6b3f', seed=3)
    # the fisher's hut on the dune at the left, smoke blown sideways
    dune = wave(GROUND_Y - 14, [(4, 80, 1.0)], 0, 76, GROUND_Y - 4)
    cv.fill(dune, '#c9a96e')
    cv.fill(dune & ~shift(dune, 0, 1), '#e8cf98')
    o = cv.obj()
    o.part(rect(8, 50, 44, 72), ramp('#8b8f96', '#5b6470', '#c9c5bc'), d=2)
    o.part(poly([(2, 52), (26, 36), (50, 52)]), ramp('#3f8fb0', '#25637d', '#a9d6ea'), d=2, contour=True)
    o.part(rect(34, 32, 40, 44), BRICK, d=1)
    o.draw()
    for y in range(56, 72, 4):
        cv.fill(rect(9, y, 43, y), '#5b6470')
    cv.fill(rect(13, 56, 22, 64), '#f5cf6a')
    cv.fill(rect(17, 56, 18, 64) | rect(13, 60, 22, 60), '#7a4a1f')
    o = cv.obj(); o.part(rect(28, 58, 37, 72), DWOOD, d=1); o.draw()
    for (x, y, r_) in ((44, 27, 3), (51, 24, 4), (60, 22, 5)):
        cv.fill(ell(x - r_, y - r_, x + r_, y + r_ - 1), '#c9c5bc')
    o = cv.obj()                                                         # nets drying on two poles
    o.part(rect(50, 54, 51, 74) | rect(72, 54, 73, 74), DWOOD, d=0)
    o.draw()
    net = poly([(51, 55), (72, 55), (70, 68), (53, 68)])
    for k in range(52, 72, 3):
        cv.fill(line([(k, 55), (k - 2, 68)]) & net, '#a3abb3')
    for k in range(57, 69, 3):
        cv.fill(rect(51, k, 72, k) & net, '#a3abb3')
    marram(cv, 2, 76, GROUND_Y - 6, '#7a9a5a', '#a4b86a', seed=5)
    # centre: a wave breaking white over the rocks (spray first, the rocks in front of it)
    spray = blank()
    for (bx, ang, ln, w) in ((106, -58, 10, 2), (113, -30, 17, 2), (118, -8, 22, 3), (125, 14, 15, 2), (132, 40, 12, 2), (139, 60, 8, 2)):
        a = math.radians(ang)
        tx, ty = bx + ln * math.sin(a), 68 - ln * math.cos(a)
        spray |= poly([(bx - w, 70), (bx + w, 70), (round(tx + 1), round(ty)), (round(tx - 1), round(ty))])
        spray |= ell(round(tx) - 2, round(ty) - 2, round(tx) + 2, round(ty) + 2)
    spray |= ell(94, 62, 116, 74) | ell(108, 58, 134, 72) | ell(128, 62, 152, 74)
    cv.fill(spray, '#f1ece0')
    cv.fill(spray & ~shift(spray, -2, -1), '#c9c5bc')
    for (x, y) in ((98, 52), (148, 54), (110, 40), (130, 38), (122, 36), (142, 46), (102, 60)):
        cv.fill(rect(x, y, x + 1, y + 1), '#f1ece0')
    rock(cv, 100, 64, 132, GROUND_Y - 4, d=4)
    rock(cv, 126, 70, 146, GROUND_Y - 4)
    # crab pot and a puddled, rain-dark beach
    o = cv.obj(); o.part(rrect(156, 80, 170, 88, 3), BURLAP, d=2); o.draw()
    for xx in range(159, 169, 3):
        cv.fill(rect(xx, 81, xx, 87), '#9a6b3f')
    puddle(cv, 60, 100, 80, 104, '#a3abb3', '#8b8f96')
    puddle(cv, 150, 116, 174, 120, '#a3abb3', '#8b8f96')
    puddle(cv, 104, 108, 120, 111, '#a3abb3', '#8b8f96')
    rain(cv, '#c9c5bc', ymax=GROUND_Y - 9, seed=3)
    rain(cv, '#e8cf98', ymax=H - 1, step=19, seed=6, clear=rect(0, 0, W, GROUND_Y - 8))
    shells(cv, [(20, 96), (180, 100), (214, 110), (110, 98), (36, 118), (200, 116)])
    marram(cv, 0, 30, H - 6, '#7a9a5a', '#a4b86a', seed=6)
    marram(cv, 210, 240, H - 6, '#7a9a5a', '#a4b86a', seed=7)
    cv.remap({'#fff3c8': '#f1ece0', '#f2e4c0': '#f1ece0'})
    return cv


STAGES = {'grassland': grassland, 'grassland-v2': grassland_v2, 'grassland-v3': grassland_v3,
          'forest': forest, 'forest-v2': forest_v2, 'forest-v3': forest_v3,
          'coast': coast, 'coast-v2': coast_v2, 'coast-v3': coast_v3}

if __name__ == '__main__':
    out = sys.argv[1] if len(sys.argv) > 1 else os.path.join(os.path.dirname(__file__), '..', '..', 'game', 'assets', 'img', 'scenes')
    only = sys.argv[2:] or list(STAGES)
    for k in only:
        cv = STAGES[k]()
        p = os.path.join(out, 'stage-' + k + '.png')
        cv.save(p)
        print(k, 'colours', cv.colours(), '->', p)
