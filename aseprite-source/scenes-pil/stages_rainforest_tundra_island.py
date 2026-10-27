"""Stage backdrops, redrawn 2026-10-27 to match the shop and stop scenes: rainforest, tundra, island, 3 variants each.

Usage: python3 aseprite-source/scenes-pil/stages_rainforest_tundra_island.py [out_dir] [name ...]
       (default: game/assets/img/scenes, all nine; names like rainforest, rainforest-v2, tundra-v3)
Writes stage-<land>.png (variant 1), stage-<land>-v2.png, stage-<land>-v3.png: 240 x 135 grid, saved 2x (480 x 270).

Layout every variant keeps (assets/stage.js + .gvs CSS):
- figures stand with their feet on grid y 87 / 97 / 107 (CSS bottom 95 / 75 / 55 px), in x 10..100 (party) and
  140..230 (foes), and are about 50 grid px tall; so the walkable ground strip y 84..116 is flat ground with only
  flat marks (tufts, pebbles, puddles), and the left and right thirds above it hold only far, hazy layers;
- the phone crop (data-crop, width < 600) shows only grid y 30..115: the land reads inside that band, the sky
  above it and the low foreground below it are extras;
- no dark top band and no sun badge (those were painted into the old art, nothing in the game needs them);
- tall framing things (trunks, palms) hug the outer 14 px; low foreground props sit in the bottom corners.
Palette: Part A families plus the Part D ramp recipe, haze tints in the same family as the stop scenes, <= 32 colours.
"""
import math
import os
import random
import sys

sys.dont_write_bytecode = True
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from pixlib import (Canvas, ramp, rect, rrect, ell, poly, line, blank, shift, W, H)  # noqa: E402

# ---- ramps (same values as shops.py / stops.py, copied so this file stands alone) ----
WOOD = ramp('#9a6b3f', '#7a4a1f', '#c9a96e', '#8a5a30')
DWOOD = ramp('#7a4a1f', '#5c3420', '#9a6b3f')
STONE = ramp('#8b8f96', '#5b6470', '#c9c5bc')
MOSS = ramp('#4f9a45', '#2f6a3a', '#7ab55c')
LEAF = ramp('#7ab55c', '#4f9a45', '#a4b86a')
DLEAF = ramp('#2f6a3a', '#1f3f3a', '#4f9a45')
EMBER = ramp('#d6322b', '#a8241f', '#f08a24')
GOLD = ramp('#e8a317', '#b07a10', '#f5cf6a')
PETAL = ramp('#e46a9b', '#b8457a', '#f6b8cf')
CANVAS = ramp('#f2e4c0', '#c9a96e', '#fff3c8')
SNOW = ramp('#f1ece0', '#cde6e8', None)
ICE = ramp('#a9d6ea', '#7fbcd8', '#f1ece0')
SAND = ramp('#e8cf98', '#c9a96e', '#f2e4c0')
PINE = ramp('#2f6a3a', '#1f3f3a', '#4f9a45')


# ------------------------------------------------------------------ helpers (stops.py style)
def bands(cv, spec):
    """Stepped sky / haze bands: each (y, colour) paints from y to the bottom, in order."""
    for y, c in spec:
        cv.fill(rect(0, y, W - 1, H - 1), c)


def wave(base, terms, x0=0, x1=W - 1, bottom=H - 1):
    """A ridge or bank: column tops follow a sum of sines (hard steps, no blend)."""
    m = blank()
    for x in range(max(0, x0), min(W - 1, x1) + 1):
        t = base + sum(a * math.sin(x * 2 * math.pi / p + ph) for a, p, ph in terms)
        m[max(0, int(round(t))):bottom + 1, x] = True
    return m


def cloud(cv, x, y, w, col, sh):
    h = max(6, w // 3)
    m = ell(x, y + h // 3, x + w, y + h + 3) | ell(x + w // 6, y, x + w * 3 // 5, y + h) | ell(x + w // 2, y + h // 6, x + w * 7 // 8, y + h)
    m &= rect(0, 0, W, y + h)
    cv.fill(m, col)
    cv.fill(m & ~shift(m, 0, -2), sh)


def top_edge(m, k=1):
    """The k px under the upper edge of a mask (snow caps, lit grass lips)."""
    return m & ~shift(m, 0, k)


def tufts(cv, pts, col):
    for (x, y) in pts:
        cv.dots([(x, y), (x + 2, y), (x + 1, y - 1), (x - 1, y - 2), (x + 3, y - 2)], col)


def pebbles(cv, pts, col, lite=None):
    for (x, y) in pts:
        cv.fill(rect(x, y, x + 2, y), col)
        if lite:
            cv.dots([(x, y - 1)], lite)


def ripples(cv, mask, col, step=6, ln=4, seed=0):
    ys, xs = mask.nonzero()
    if not len(ys):
        return
    for y in range(ys.min() + 2, ys.max(), step):
        off = ((y * 7 + seed) % 13) * 3
        for x in range(off % 23, W, 23):
            cv.fill(rect(x, y, x + ln + (y % 3), y) & mask, col)


def rock(cv, x0, y0, x1, y1, rp=STONE, cap=None, capk=3, d=3):
    """Boulder; cap = (ramp) for moss or snow on its top."""
    o = cv.obj()
    m = ell(x0, y0, x1, y1 + (y1 - y0) // 2) & rect(0, 0, W, y1)
    o.part(m, rp, d=d)
    if cap:
        o.part(top_edge(m, max(capk, (y1 - y0) // 3)) & ~rect(0, y0 + (y1 - y0) // 2, W, H), cap, d=1)
    o.draw()
    return m


def pine(cv, x, ybot, w, h, rp=PINE, trunk=DWOOD, flat=None, snow=None):
    """Three-tier spruce. flat = colour draws a hazy silhouette; snow = colour lays caps on each tier."""
    m_tr = rect(x - 1, ybot - 5, x + 1, ybot)
    tiers = []
    top = ybot - 4 - h
    for i in range(3):
        ty = top + round(h * 0.26 * i)
        by = top + round(h * (0.42 + 0.29 * i))
        hw = w / 2 * (0.5 + 0.25 * i)
        tiers.append(poly([(x, ty), (x + hw, by), (x - hw, by)]))
    if flat:
        cv.fill(m_tr, flat)
        for t in tiers:
            cv.fill(t, flat)
        if snow:
            for t in tiers:
                cv.fill(top_edge(t, 2) & ~shift(t, 2, 0), snow)
        return
    o = cv.obj()
    o.part(m_tr, trunk, d=0)
    for t in tiers:
        o.part(t, rp, d=2)
    o.draw()
    if snow:
        for i, t in enumerate(tiers):
            cap = top_edge(t, 3) & ~shift(t, 3, 0)
            cv.fill(cap, snow)
            ys, xs = t.nonzero()
            by = ys.max()
            for dx in (-2, 3):
                xx = x + dx * (i + 1)
                cv.fill(rect(xx, by - 1, xx + 1, by), snow)


def seeded(seed):
    return random.Random(seed)


def rain(cv, seed, n, col, ys=(0, 86), xs=(0, W - 1), ln=5, avoid=None):
    """Slanted 1 px streaks, a few px each, hard pixels."""
    r = seeded(seed)
    for _ in range(n):
        x, y = r.randint(*xs), r.randint(*ys)
        m = line([(x, y), (x - 2, y + ln)])
        if avoid is not None:
            m &= ~avoid
        cv.fill(m, col)


def snowfall(cv, seed, n, col, ys=(0, 120), avoid=None):
    r = seeded(seed)
    for k in range(n):
        x, y = r.randint(0, W - 1), r.randint(*ys)
        m = rect(x, y, x + 1, y + 1) if k % 3 == 0 else rect(x, y, x, y)
        if avoid is not None:
            m &= ~avoid
        cv.fill(m, col)


def birds(cv, pts, col):
    for (x, y) in pts:
        cv.fill(line([(x, y + 2), (x + 2, y), (x + 4, y + 2), (x + 6, y), (x + 8, y + 2)]), col)


# ------------------------------------------------------------------ plant / prop kit
def bezier(p0, p1, p2, t):
    return ((1 - t) ** 2 * p0[0] + 2 * (1 - t) * t * p1[0] + t * t * p2[0],
            (1 - t) ** 2 * p0[1] + 2 * (1 - t) * t * p1[1] + t * t * p2[1])


def palm(cv, base, ctrl, top, w0=7, w1=4, fronds=None, leaf=LEAF, nuts=True):
    """Leaning palm: ringed trunk along a curve, drooping fronds with hanging leaflets, coconuts."""
    o = cv.obj()
    rings = []
    left, right = [], []
    n = 30
    for k in range(n + 1):
        t = k / n
        x, y = bezier(base, ctrl, top, t)
        r = (w0 + (w1 - w0) * t) / 2
        left.append((round(x - r), round(y)))
        right.append((round(x + r), round(y)))
        if k % 2 == 1:
            rings.append((x, y, r))
    tr = poly(left + right[::-1])
    o.part(tr, WOOD, d=2)
    o.draw()
    for (x, y, r) in rings:
        cv.fill(rect(round(x - r) + 1, round(y), round(x + r) - 2, round(y)) & tr, '#7a4a1f')
    tx, ty = top
    fronds = fronds or [(-170, 30, 3), (-140, 34, 6), (-100, 26, 10), (-60, 30, 8), (-20, 34, 5), (10, 28, 3), (-200, 24, 2)]
    o = cv.obj()
    for (ang, ln, droop) in fronds:
        a = math.radians(ang)
        pts = []
        for k in range(0, ln + 1):
            s = k / ln
            pts.append((tx + math.cos(a) * k, ty + math.sin(a) * k + droop * s * s * 1.6))
        spine = line([(round(px), round(py)) for px, py in pts], 3)
        lf = spine
        for k in range(3, ln, 3):
            px, py = pts[k]
            s = k / ln
            ll = round(7 * (1 - s) + 3)
            dx = math.cos(a) * 2
            lf |= line([(round(px), round(py)), (round(px + dx), round(py + ll))], 2)
        o.part(lf, leaf, d=1)
    o.draw()
    if nuts:
        for (dx, dy) in ((-3, 2), (1, 3), (-1, 5)):
            oo = cv.obj()
            oo.part(ell(tx + dx - 2, ty + dy - 2, tx + dx + 2, ty + dy + 2), DWOOD, d=1)
            oo.draw()


def big_leaf(cv, cx, cy, ln, wd, ang, rp=MOSS, slits=0, rib=None):
    """A broad tropical leaf (banana / monstera): pointed oval along an angle, midrib, vein lines, slits."""
    a = math.radians(ang)
    ca, sa = math.cos(a), math.sin(a)
    pts_u, pts_l = [], []
    for k in range(0, 21):
        s = k / 20
        half = wd / 2 * math.sin(math.pi * s) ** 0.8
        x, y = cx + ca * ln * s, cy + sa * ln * s
        pts_u.append((x - sa * half, y + ca * half))
        pts_l.append((x + sa * half, y - ca * half))
    m = poly([(round(x), round(y)) for x, y in pts_u + pts_l[::-1]])
    for k in range(1, slits + 1):
        s = k / (slits + 1)
        x, y = cx + ca * ln * s, cy + sa * ln * s
        for sgn in (1, -1):
            ex, ey = x + sgn * (-sa) * wd * 0.6 + ca * 3, y + sgn * ca * wd * 0.6 + sa * 3
            mx, my = x + sgn * (-sa) * wd * 0.18, y + sgn * ca * wd * 0.18
            m &= ~line([(round(mx), round(my)), (round(ex), round(ey))], 1)
    o = cv.obj()
    o.part(m, rp, d=2)
    o.draw()
    cv.fill(line([(round(cx), round(cy)), (round(cx + ca * ln * 0.92), round(cy + sa * ln * 0.92))]) & m, rib or rp['r'] or rp['s'])
    return m


def fern(cv, x, y, ln, ang, rp=LEAF, droop=0.5):
    """Arched fern frond: spine with leaflets on both sides that shorten to the tip."""
    a = math.radians(ang)
    pts = [(x + math.cos(a) * k, y + math.sin(a) * k + droop * k * k / ln) for k in range(ln + 1)]
    m = line([(round(px), round(py)) for px, py in pts], 2)
    for k in range(2, ln - 1, 3):
        px, py = pts[k]
        s = k / ln
        ll = max(2, round(7 * (1 - s)))
        nx, ny = -math.sin(a), math.cos(a)
        for sgn in (1, -1):
            m |= line([(round(px), round(py)), (round(px + sgn * nx * ll + math.cos(a) * 2), round(py + sgn * ny * ll + math.sin(a) * 2))], 2)
    o = cv.obj()
    o.part(m, rp, d=1)
    o.draw()


def bromeliad(cv, x, y, rp=LEAF, heart=EMBER):
    """Rosette of strap leaves with a red heart (sits on a branch or the ground)."""
    o = cv.obj()
    m = blank()
    for (dx, h) in ((-9, 5), (-6, 9), (-2, 12), (2, 12), (6, 9), (9, 5)):
        m |= poly([(x, y), (x + dx, y - h), (x + dx // 2 + (1 if dx > 0 else -1), y - h // 2)]) | line([(x, y), (x + dx, y - h)], 2)
    o.part(m, rp, d=1)
    o.part(poly([(x - 2, y - 1), (x, y - 8), (x + 2, y - 1)]), heart, d=1, contour=True)
    o.draw()


def heliconia(cv, x, ybot, h, bracts=4):
    """Lobster-claw flower: stem with zig-zag red bracts tipped gold."""
    cv.fill(rect(x, ybot - h, x + 1, ybot), '#2f6a3a')
    o = cv.obj()
    for k in range(bracts):
        y = ybot - h + 3 + k * 5
        sg = 1 if k % 2 else -1
        o.part(poly([(x + (0 if sg > 0 else 1), y), (x + sg * 7, y - 3), (x + sg * 4, y + 3)]), EMBER, d=1)
    o.draw()
    for k in range(bracts):
        y = ybot - h + 3 + k * 5
        sg = 1 if k % 2 else -1
        cv.dots([(x + sg * 6, y - 3), (x + sg * 7, y - 3)], '#f5cf6a')


def butterfly(cv, x, y, col='#3f8fb0', lite='#a9d6ea'):
    cv.fill(rect(x, y, x + 1, y + 1) | rect(x + 3, y, x + 4, y + 1) | rect(x, y + 2, x + 1, y + 2) | rect(x + 3, y + 2, x + 4, y + 2), col)
    cv.dots([(x, y), (x + 4, y)], lite)
    cv.fill(rect(x + 2, y, x + 2, y + 3), '#3d2a1c')


def vine(cv, x, y0, y1, col='#4f9a45', leafc='#7ab55c', ph=0.0):
    """Hanging liana with leaf pairs."""
    pts = [(round(x + 2 * math.sin(y / 7.0 + ph)), y) for y in range(y0, y1 + 1)]
    cv.fill(line(pts), col)
    for i, (px, py) in enumerate(pts[3::6]):
        sg = 1 if i % 2 else -1
        cv.fill(rect(px + (1 if sg > 0 else -2), py, px + (2 if sg > 0 else -1), py + 1), leafc)


def buttress_tree(cv, x0, x1, ytop, ybase, bark=DWOOD, flare=10, side='l'):
    """Giant rainforest trunk with flared root buttresses and bark grooves."""
    o = cv.obj()
    trunk = rect(x0, ytop, x1, ybase)
    fl = poly([(x0, ybase - 22), (x0 - flare, ybase + 1), (x1 + flare, ybase + 1), (x1, ybase - 22)])
    o.part(trunk | fl, bark, d=3)
    o.draw()
    for gx in range(x0 + 3, x1 - 1, 4):
        cv.fill(rect(gx, ytop, gx, ybase - 4) & trunk, bark['s'])
    for (a, b) in ((x0 + 2, x0 - flare + 2), (x1 - 2, x1 + flare - 3), ((x0 + x1) // 2, (x0 + x1) // 2 + 1)):
        cv.fill(line([(a, ybase - 18), (b, ybase)]), bark['s'])
    return trunk | fl


def canopy(cv, clumps, rp=MOSS):
    o = cv.obj()
    for (a, b, c, d) in clumps:
        o.part(ell(a, b, c, d), rp, d=3)
    o.draw()


def starfish(cv, x, y, rp=ramp('#f08a24', '#e0501f', '#f5cf6a')):
    pts = []
    for k in range(10):
        a = -math.pi / 2 + k * math.pi / 5
        r = 5 if k % 2 == 0 else 2
        pts.append((round(x + r * math.cos(a)), round(y + r * math.sin(a))))
    o = cv.obj()
    o.part(poly(pts), rp, d=1)
    o.draw()


def shell(cv, x, y, rp=PETAL):
    o = cv.obj()
    o.part(ell(x, y, x + 7, y + 6) & rect(0, 0, W, y + 4) | poly([(x + 2, y + 4), (x + 5, y + 4), (x + 4, y + 6), (x + 3, y + 6)]), rp, d=1)
    o.draw()
    for k in (2, 4):
        cv.fill(line([(x + 3 + (1 if k > 3 else 0), y + 5), (x + k - 1 + (k // 2), y + 1)]), rp['s'])


def coconut(cv, x, y):
    o = cv.obj()
    o.part(ell(x, y, x + 6, y + 6), DWOOD, d=2)
    o.draw()
    cv.dots([(x + 2, y + 2), (x + 4, y + 2)], '#3d2a1c')


def grass_clump(cv, x, ybot, col='#4f9a45', hi='#7ab55c', h=8, n=5):
    for k in range(n):
        dx = (k - n // 2) * 2
        cv.fill(line([(x + dx // 2, ybot), (x + dx, ybot - h + abs(dx))]), col if k % 2 else hi)


# ================================================================== RAINFOREST
def rf_ground(cv, y0=84, soil='#7a4a1f'):
    """Mossy clearing with a winding soil path through it where the figures stand; leaf litter marks only."""
    g = wave(y0, [(1.2, 80, 0.4), (0.8, 33, 1.7)])
    cv.fill(g, '#4f9a45')
    cv.fill(top_edge(g, 2), '#7ab55c')
    lane = wave(y0 + 11, [(2.0, 120, 2.0), (1.0, 37, 0.5)]) & ~wave(y0 + 25, [(2.0, 100, 0.9), (1.0, 29, 2.2)])
    cv.fill(lane, '#9a6b3f')
    cv.fill(top_edge(lane, 1), '#7a4a1f')
    low = wave(116, [(1.5, 50, 0.3), (1.0, 19, 1.0)])
    cv.fill(low, '#2f6a3a')
    cv.fill(top_edge(low, 1), '#4f9a45')
    pebbles(cv, [(24, 102), (58, 108), (92, 100), (130, 104), (168, 101), (204, 106), (226, 100), (150, 108)], soil, '#c9a96e')
    for (x, y, c) in ((36, 90, '#e8a317'), (112, 112, '#d6322b'), (186, 90, '#e8a317'), (76, 112, '#a4b86a'), (214, 112, '#a4b86a'),
                      (140, 92, '#d6322b'), (60, 92, '#a4b86a')):
        cv.fill(rect(x, y, x + 2, y + 1), c)
        cv.dots([(x + 1, y - 1)], '#7a4a1f')
    tufts(cv, [(8, 92), (70, 89), (120, 89), (160, 92), (232, 90), (100, 114), (16, 113), (190, 113)], '#2f6a3a')


def rainforest_1():
    """Midday: sun shafts through the canopy, a far waterfall, giant buttress trees at the edges."""
    cv = Canvas()
    bands(cv, [(0, '#a9d6ea'), (16, '#cde6e8'), (30, '#e6efd8')])
    cloud(cv, 70, 16, 30, '#f1ece0', '#cde6e8')
    cloud(cv, 150, 22, 24, '#f1ece0', '#cde6e8')
    # far ridge and cliff with the waterfall in the middle
    cv.fill(wave(46, [(5, 70, 0.3), (3, 31, 1.1)]), '#c4dcc0')
    for x in range(-6, W + 6, 12):
        h = 14 + (x * 7) % 9
        cv.fill(ell(x, 52 - h, x + 16, 58), '#a4c8b0')
    cv.fill(rect(0, 54, W - 1, 64), '#a4c8b0')
    # a mossy cliff in the middle with a tall waterfall and its mist
    cliff = poly([(90, 44), (100, 30), (112, 26), (130, 26), (142, 30), (152, 44), (158, 70), (82, 70)])
    cv.fill(cliff, '#7ab58a')
    cv.fill(cliff & ~shift(cliff, 3, 0), '#a4c8b0')
    for (x, y, w) in ((84, 36, 12), (92, 30, 12), (101, 25, 11), (128, 24, 11), (137, 28, 12), (146, 34, 12)):
        cv.fill(ell(x, y, x + w, y + 8), '#4f7a5a')
        cv.fill(top_edge(ell(x, y, x + w, y + 8), 1), '#7ab58a')
    falls = rect(112, 28, 126, 70)
    cv.fill(falls, '#f1ece0')
    for x in (114, 118, 123):
        cv.fill(rect(x, 32 + (x % 4) * 3, x, 66), '#cde6e8')
    cv.fill(rect(111, 27, 127, 28), '#cde6e8')
    for (x, y, w) in ((102, 62, 36), (94, 66, 20), (128, 65, 22)):
        cv.fill(ell(x, y, x + w, y + 7), '#f1ece0')
    # mid jungle wall: round crowns in two greens, thin trunks
    for i, x in enumerate(range(-4, W + 6, 15)):
        if 98 < x < 142:
            continue
        h = 16 + (i * 11) % 8
        cv.fill(rect(x + 7, 64, x + 8, 84), '#4f7a5a')
        cv.fill(ell(x, 66 - h, x + 18, 70), '#7ab58a')
    cv.fill(wave(70, [(2, 40, 0.0), (1.5, 17, 1.0)]), '#7ab58a')
    for i, x in enumerate(range(2, W, 19)):
        cv.fill(ell(x, 70 + (i % 2) * 2, x + 22, 86), '#4f7a5a')
    rf_ground(cv)
    # sun shafts across the far layers only (flat pale bars, no blending)
    for (xa, xb) in ((40, 48), (64, 70), (178, 186), (200, 205)):
        sh = poly([(xa, 0), (xb, 0), (xb + 26, 84), (xa + 26, 84)]) & ~wave(84, [(1.2, 80, 0.4), (0.8, 33, 1.7)])
        cv.fill(sh & mask_of(cv, ['#a4c8b0', '#7ab58a', '#c4dcc0']), '#dfe9d0')
        cv.fill(sh & mask_of(cv, ['#4f7a5a']), '#7ab58a')
    # framing giants: buttress trunks at the outer edges, canopy in the top corners, lianas
    buttress_tree(cv, -6, 10, 0, 90, flare=9)
    buttress_tree(cv, 228, 244, 0, 88, flare=9)
    canopy(cv, [(-24, -16, 30, 20), (6, -14, 50, 14), (-10, 6, 22, 30), (200, -18, 256, 18), (180, -12, 226, 12), (222, 4, 252, 30)])
    for (x, y0, y1, ph) in ((26, 8, 46, 0.0), (36, 4, 30, 1.5), (204, 8, 52, 2.0), (192, 6, 28, 0.7)):
        vine(cv, x, y0, y1, ph=ph)
    bromeliad(cv, 12, 46, LEAF)
    bromeliad(cv, 230, 40, LEAF, GOLD)
    # foreground corners: banana and monstera leaves, ferns, heliconia
    big_leaf(cv, -4, 132, 40, 16, -40, MOSS, slits=3)
    big_leaf(cv, 6, 134, 34, 14, -70, LEAF)
    fern(cv, 30, 130, 26, -30, LEAF)
    heliconia(cv, 44, 130, 18)
    big_leaf(cv, 244, 132, 40, 16, -140, MOSS, slits=3)
    big_leaf(cv, 236, 134, 32, 14, -105, LEAF)
    fern(cv, 210, 130, 24, -150, LEAF)
    for (x, y) in ((176, 126), (186, 128)):
        o = cv.obj(); o.part(rect(x + 2, y + 3, x + 3, y + 6), CANVAS, d=0)
        o.part(ell(x, y, x + 5, y + 4) & rect(0, 0, W, y + 3), EMBER, d=1, contour=True); o.draw()
        cv.dots([(x + 2, y + 1)], '#f2e4c0')
    butterfly(cv, 150, 46)
    butterfly(cv, 86, 58, '#e8a317', '#f5cf6a')
    birds(cv, [(170, 12), (182, 8)], '#4f7a5a')
    cv.remap({'#fff3c8': '#f2e4c0', '#c9c5bc': '#f1ece0', '#e6efd8': '#dfe9d0'})
    return cv


def rainforest_2():
    """Misty dawn: pink-gold sky, layered hazy canopies, a slow river with stepping stones, a kapok giant."""
    cv = Canvas()
    bands(cv, [(0, '#d9d4ee'), (12, '#f6d9e0'), (26, '#f6d9b0'), (38, '#f1ece0')])
    cv.fill(ell(150, 30, 172, 52) & rect(0, 0, W, 46), '#f5cf6a')
    cv.fill(ell(154, 34, 168, 48) & rect(0, 0, W, 46), '#fff3c8')
    for (x, y, w) in ((20, 22, 60), (176, 18, 50), (120, 28, 40)):
        cv.fill(rrect(x, y, x + w, y + 2, 1), '#f6d9e0')
    # three hazy canopy layers, lighter = farther, mist strips between
    for i, x in enumerate(range(-8, W + 8, 11)):
        h = 10 + (i * 7) % 8
        cv.fill(ell(x, 50 - h, x + 14, 54), '#d9c4cc')
    cv.fill(rect(0, 50, W - 1, 60), '#d9c4cc')
    cv.fill(rrect(0, 54, 120, 56, 1) | rrect(150, 52, 240, 54, 1), '#f1ece0')
    # two emergent giants rising out of the mist: forked trunks, broad clumpy crowns in tiers
    for (cx, top, sc) in ((72, 16, 1.0), (176, 26, 0.7)):
        tr = rect(cx - round(3 * sc), top + round(10 * sc), cx + round(2 * sc), 70)
        tr |= line([(cx, top + round(22 * sc)), (cx - round(16 * sc), top + round(8 * sc))], 2)
        tr |= line([(cx, top + round(18 * sc)), (cx + round(15 * sc), top + round(6 * sc))], 2)
        cv.fill(tr, '#a4b8a8')
        cr = blank()
        for (dx, dy, rw, rh) in ((-26, 4, 20, 9), (-12, 0, 22, 10), (4, 2, 22, 9), (-30, 10, 14, 6), (14, 8, 16, 6), (-6, -4, 16, 8)):
            cr |= ell(cx + round(dx * sc), top + round(dy * sc), cx + round((dx + rw) * sc), top + round((dy + rh) * sc))
        cv.fill(cr, '#a4b8a8')
        cv.fill(top_edge(cr, 1), '#d9c4cc')
    for i, x in enumerate(range(-6, W + 8, 14)):
        h = 12 + (i * 5) % 9
        cv.fill(ell(x, 62 - h, x + 18, 66), '#a4b8a8')
    cv.fill(rect(0, 62, W - 1, 70), '#a4b8a8')
    cv.fill(rrect(30, 64, 90, 66, 1) | rrect(170, 66, 236, 68, 1), '#e6efe6')
    for i, x in enumerate(range(-4, W + 6, 17)):
        h = 10 + (i * 13) % 7
        cv.fill(ell(x, 72 - h, x + 20, 76), '#7a9a7a')
    cv.fill(rect(0, 72, W - 1, 80), '#7a9a7a')
    # the river: a calm brown-green band behind the clearing, mist lying on it
    riv = wave(76, [(1, 50, 0.5)]) & ~wave(85, [(1.5, 70, 1.0)])
    cv.fill(riv, '#7fbcd8')
    cv.fill(riv & ~shift(riv, 0, 2), '#a9d6ea')
    for (x, y, w) in ((40, 79, 14), (150, 80, 18), (206, 78, 10), (96, 81, 8)):
        cv.fill(rect(x, y, x + w, y), '#f1ece0')
    for (x, y, w) in ((110, 77, 10), (124, 79, 9), (138, 78, 10)):          # stepping stones
        o = cv.obj(); o.part(ell(x, y, x + w, y + 5) & rect(0, 0, W, y + 4), STONE, d=1); o.draw()
    rf_ground(cv, y0=85)
    # framing: tree fern on the left edge, a strangler fig trunk on the right, vines from the top corners
    o = cv.obj(); o.part(rect(12, 34, 16, 92) | poly([(10, 92), (12, 84), (16, 84), (19, 92)]), DWOOD, d=2); o.draw()
    for k in range(38, 86, 5):
        cv.fill(rect(13, k, 15, k), '#5c3420')
    for (ang, ln) in ((-178, 22), (-150, 26), (-118, 22), (-62, 22), (-30, 26), (-2, 22)):
        fern(cv, 14, 34, ln, ang, LEAF, droop=0.7)
    o = cv.obj(); o.part(ell(10, 30, 18, 36), LEAF, d=1); o.draw()
    buttress_tree(cv, 226, 246, 0, 90, flare=8)
    vf = blank()
    for (xa, xb) in ((222, 214), (230, 236)):
        vf |= line([(xa, 10), (xb, 50), (xa, 86)], 2)
    cv.fill(vf, '#5c3420')
    canopy(cv, [(196, -18, 254, 16), (176, -12, 214, 8)], MOSS)
    for (x, y0, y1, ph) in ((190, 6, 40, 0.3), (204, 8, 58, 1.8), (44, 0, 24, 0.9)):
        vine(cv, x, y0, y1, ph=ph)
    # foreground: giant leaves and ferns in the corners, an orchid sprig
    big_leaf(cv, -2, 134, 38, 15, -35, LEAF)
    fern(cv, 24, 132, 28, -40, MOSS)
    big_leaf(cv, 242, 134, 42, 16, -150, MOSS, slits=2)
    fern(cv, 214, 132, 26, -140, LEAF)
    for (x, y) in ((40, 124), (46, 120), (52, 125)):
        cv.fill(rect(x, y, x + 2, y + 1), '#e46a9b')
        cv.dots([(x + 1, y)], '#f6b8cf')
    cv.fill(line([(42, 126), (46, 132)]) | line([(52, 127), (50, 132)]), '#2f6a3a')
    birds(cv, [(118, 16), (128, 12)], '#7a9a7a')
    butterfly(cv, 136, 60, '#e8a317', '#f5cf6a')
    cv.remap({'#c9c5bc': '#f1ece0', '#f2e4c0': '#f1ece0', '#cde6e8': '#e6efe6', '#b8457a': '#d6322b'})
    return cv


def rainforest_3():
    """Warm rain: soft green-grey sky, rain streaks, a swollen creek, a fallen mossy log, puddles on the lane."""
    cv = Canvas()
    bands(cv, [(0, '#a4b8a8'), (14, '#b8ccb8'), (28, '#c4dcc0')])
    for (x, y, w) in ((10, 10, 44), (120, 6, 50), (190, 16, 40)):
        cloud(cv, x, y, w, '#dfe9d0', '#a4b8a8')
    # far rain-veiled hills and crowns
    cv.fill(wave(44, [(6, 90, 0.8), (3, 37, 0.1)]), '#b8ccb8')
    for i, x in enumerate(range(-6, W + 8, 13)):
        h = 12 + (i * 9) % 8
        cv.fill(ell(x, 58 - h, x + 16, 62), '#a4b8a8')
    cv.fill(rect(0, 58, W - 1, 68), '#a4b8a8')
    for i, x in enumerate(range(-4, W + 6, 16)):
        h = 12 + (i * 7) % 9
        cv.fill(rect(x + 8, 62, x + 9, 76), '#4f7a5a')
        cv.fill(ell(x, 68 - h, x + 20, 72), '#7a9a7a')
    cv.fill(rect(0, 68, W - 1, 76), '#7a9a7a')
    # the creek: from a little cascade at the back right, across behind the clearing
    crk = wave(74, [(1.5, 60, 0.0)]) & ~wave(84, [(1.5, 90, 2.0)])
    cv.fill(crk, '#3f8fb0')
    cv.fill(top_edge(crk, 2), '#a9d6ea')
    for (x, y) in ((20, 79), (70, 80), (104, 78), (164, 80), (210, 79)):
        cv.fill(rect(x, y, x + 5, y), '#a9d6ea')
    casc = poly([(176, 60), (188, 60), (190, 76), (174, 76)])
    cv.fill(casc, '#dfe9d0')
    cv.fill(rect(180, 62, 180, 74) | rect(185, 61, 185, 75), '#a9d6ea')
    rock(cv, 160, 60, 178, 74, cap=MOSS)
    rock(cv, 188, 58, 208, 74, cap=MOSS)
    rf_ground(cv, y0=84)
    # fallen mossy log behind the lane, centre-left (low, so it never hides a figure)
    o = cv.obj()
    lg = rrect(54, 74, 128, 84, 3)
    o.part(lg, DWOOD, d=2)
    o.part(top_edge(lg, 3) & ~rect(54, 0, 58, H), MOSS, d=1)
    o.part(ell(124, 73, 134, 85), WOOD, d=1, contour=True)
    o.draw()
    cv.fill(ell(127, 76, 131, 82) & ~ell(128, 77, 130, 81), '#7a4a1f')
    for (x, y) in ((70, 71), (88, 70), (106, 71)):
        o = cv.obj(); o.part(rect(x + 2, y + 3, x + 3, y + 5), CANVAS, d=0)
        o.part(ell(x, y, x + 5, y + 4) & rect(0, 0, W, y + 3), GOLD, d=1, contour=True); o.draw()
    # puddles on the lane (flat, so figures can stand in them), rain rings
    for (x, y, w) in ((30, 104, 22), (120, 98, 16), (176, 108, 26), (74, 112, 14)):
        pd = ell(x, y, x + w, y + 5)
        cv.fill(pd, '#7fbcd8')
        cv.fill(top_edge(pd, 1), '#3f8fb0')
        cv.fill(rect(x + w // 3, y + 2, x + w // 3 + 3, y + 2), '#dfe9d0')
    # framing: big buttress trunk left, palm-like banana plant right, with water dripping off leaves
    buttress_tree(cv, -8, 12, 0, 90, flare=10)
    canopy(cv, [(-26, -16, 34, 18), (10, -12, 50, 10)], DLEAF)
    vine(cv, 22, 6, 42, ph=0.4)
    bromeliad(cv, 14, 50, LEAF)
    # banana plant at the right edge: a thick soft stem and long drooping, rain-split leaves
    o = cv.obj()
    o.part(poly([(226, 92), (229, 44), (236, 44), (240, 92)]), ramp('#a4b86a', '#7ab55c', '#dfe9d0'), d=2)
    o.draw()
    cv.fill(rect(231, 50, 231, 88), '#7ab55c')
    for (ang, ln, rp, sl) in ((-200, 40, MOSS, 2), (-160, 44, LEAF, 3), (-125, 34, MOSS, 2), (-95, 26, LEAF, 0), (-60, 22, MOSS, 1)):
        big_leaf(cv, 232, 46, ln, 14, ang, rp, slits=sl)
    for (x, y) in ((196, 54), (200, 64), (210, 34), (192, 44)):
        cv.fill(rect(x, y, x, y + 1) | rect(x, y + 4, x, y + 4), '#a9d6ea')
    # foreground corners
    big_leaf(cv, -4, 134, 40, 16, -45, MOSS, slits=3)
    fern(cv, 26, 132, 24, -35, LEAF)
    heliconia(cv, 216, 132, 20, 5)
    big_leaf(cv, 244, 134, 34, 14, -130, MOSS)
    # rain over everything above the lane, sparse over the lane itself
    sky_area = rect(0, 0, W - 1, 84)
    rain(cv, 7, 150, '#dfe9d0', ys=(0, 80), ln=5)
    rain(cv, 8, 26, '#a9d6ea', ys=(86, 126), ln=3)
    for (x, y) in ((40, 106), (130, 100), (186, 110)):
        cv.dots([(x - 1, y), (x + 1, y), (x, y - 1)], '#dfe9d0')
    cv.remap({'#fff3c8': '#f2e4c0', '#c9c5bc': '#dfe9d0', '#f1ece0': '#dfe9d0', '#cde6e8': '#dfe9d0'})
    return cv


# ================================================================== TUNDRA
def snow_patch(x, y, w, h, seed):
    """A flat, ragged-edged lie of snow: each row's ends wander a little."""
    r = seeded(seed)
    m = blank()
    for k in range(h):
        t = (k + 0.5) / h
        half = w / 2 * math.sin(math.pi * t) ** 0.5
        a = round(x + w / 2 - half + r.randint(-2, 2))
        b = round(x + w / 2 + half + r.randint(-2, 2))
        m |= rect(a, y + k, b, y + k)
    return m


def tundra_ground(cv, y0=84, snow='#f1ece0', shade='#cde6e8', grass='#c9a96e', thaw=False):
    """Tundra lane. Snowy: flat snow with wind ripples, sedge showing through. thaw: sedge and moss with flat
    snow patches left over (snow = moss colour, shade = darker moss, grass = straw)."""
    g = wave(y0, [(1.0, 90, 0.2), (0.8, 41, 1.5)])
    cv.fill(g, snow)
    if thaw:
        cv.fill(top_edge(g, 1), grass)
        for (x, y, w, sd) in ((-6, 87, 30, 1), (156, 86, 34, 2), (100, 93, 18, 3), (214, 98, 30, 4), (44, 106, 16, 5), (128, 110, 22, 6)):
            p = snow_patch(x, y, w, 5, sd)
            cv.fill(p, '#f1ece0')
            cv.fill(p & ~shift(p, 0, -1), '#cde6e8')
        for (x, y, w) in ((60, 96, 20), (170, 100, 18), (16, 112, 14), (220, 106, 12), (84, 112, 16)):
            cv.fill(rect(x, y, x + w, y), grass)
            cv.fill(rect(x + 3, y + 1, x + w - 4, y + 1), shade)
        low = wave(117, [(1.5, 50, 0.6)])
        cv.fill(low, shade)
        cv.fill(top_edge(low, 1), grass)
        tufts(cv, [(6, 98), (56, 90), (140, 96), (230, 90), (92, 104), (214, 114), (160, 114)], '#7a4a1f')
        for (x, y) in ((22, 100), (122, 98), (178, 106), (66, 110)):
            cv.dots([(x, y), (x + 1, y)], '#8b8f96')
        return
    for (x, y, w) in ((12, 90, 26), (64, 96, 30), (150, 92, 24), (196, 100, 28), (104, 106, 22), (30, 110, 20), (176, 112, 26)):
        cv.fill(rect(x, y, x + w, y), shade)
        cv.fill(rect(x + 4, y + 1, x + w - 6, y + 1), shade)
    cv.fill(rect(0, 116, W - 1, H - 1), shade)
    cv.fill(wave(118, [(1.5, 50, 0.6)]), snow)
    tufts(cv, [(6, 88), (56, 88), (140, 87), (230, 89), (92, 114), (214, 116)], grass)
    for (x, y) in ((22, 98), (122, 94), (178, 102), (218, 94)):
        cv.dots([(x, y), (x + 1, y)], '#8b8f96')


def cottongrass(cv, pts, stem='#a4b86a', head='#f1ece0'):
    for (x, y, h) in pts:
        cv.fill(rect(x, y - h, x, y), stem)
        cv.fill(rect(x - 1, y - h - 2, x + 1, y - h), head)


def bearberry(cv, x, y):
    o = cv.obj()
    o.part(ell(x, y, x + 18, y + 8) & rect(0, 0, W, y + 6), ramp('#4f9a45', '#2f6a3a', '#a4b86a'), d=1)
    o.draw()
    for (dx, dy) in ((3, 2), (8, 1), (13, 3), (6, 4), (11, 4)):
        cv.fill(rect(x + dx, y + dy, x + dx + 1, y + dy + 1), '#d6322b')
        cv.dots([(x + dx, y + dy)], '#f08a24')


def inukshuk(cv, x, ybot, s=1.0):
    """Stacked-stone waymarker: two legs, a lintel, a body, long arms, a head."""
    def r(a, b, c, d):
        return rect(round(x + a * s), round(ybot - b * s), round(x + c * s), round(ybot - d * s))
    o = cv.obj()
    o.part(r(-8, 12, -3, 0), STONE, d=1)
    o.part(r(3, 12, 8, 0), STONE, d=1)
    o.part(r(-10, 16, 10, 12), STONE, d=1, contour=True)
    o.part(r(-6, 26, 6, 16), STONE, d=2, contour=True)
    o.part(r(-16, 30, 16, 26), STONE, d=1, contour=True)
    o.part(r(-4, 37, 4, 30), STONE, d=1, contour=True)
    o.draw()
    cv.fill(r(-10, 16, 10, 16) | r(-16, 30, 16, 30) | r(-4, 37, 4, 37), '#f1ece0')


def igloo(cv, cx, ybot, r=22, glow=True):
    o = cv.obj()
    dome = ell(cx - r, ybot - r, cx + r, ybot + r) & rect(0, 0, W, ybot)
    o.part(dome, SNOW, d=3)
    tun = ell(cx - 9, ybot - 12, cx + 9, ybot + 12) & rect(0, 0, W, ybot)
    o.part(shift(tun, -4, 0), SNOW, d=2, contour=True)
    o.draw()
    for k, y in enumerate(range(ybot - r + 6, ybot, 6)):
        cv.fill(rect(0, y, W, y) & dome & ~shift(tun, -4, 0), '#a9d6ea')
        for x in range(cx - r + (k % 2) * 4, cx + r, 8):
            cv.fill(rect(x, y + 1, x, y + 5) & dome & ~shift(tun, -4, 0), '#a9d6ea')
    door = ell(cx - 9, ybot - 7, cx + 1, ybot + 7) & rect(0, 0, W, ybot)
    cv.fill(door, '#7a4a1f')
    if glow:
        cv.fill(ell(cx - 7, ybot - 5, cx - 1, ybot + 5) & rect(0, 0, W, ybot), '#f5cf6a')
        cv.fill(ell(cx - 5, ybot - 3, cx - 2, ybot + 3) & rect(0, 0, W, ybot), '#f08a24')


def caribou(cv, x, y, col, face=1):
    """Tiny far silhouette (about 10 px long): body, legs, neck, antlers."""
    cv.fill(ell(x, y, x + 8, y + 4), col)
    cv.fill(rect(x + 1, y + 3, x + 1, y + 7) | rect(x + 7, y + 3, x + 7, y + 7) | rect(x + 3, y + 3, x + 3, y + 6), col)
    hx_ = x + 9 if face > 0 else x - 2
    cv.fill(line([(x + (7 if face > 0 else 1), y + 1), (hx_, y - 2)], 2), col)
    cv.fill(rect(hx_ - 1, y - 3, hx_ + 1, y - 2), col)
    cv.fill(line([(hx_, y - 3), (hx_ - face * 2, y - 7)]) | line([(hx_ - face, y - 5), (hx_ + face, y - 7)]), col)


def tundra_1():
    """Clear midday thaw: blue sky, snow peaks, a half-frozen lake, an inukshuk beyond it, sedge and snow patches."""
    cv = Canvas()
    bands(cv, [(0, '#7fbcd8'), (12, '#a9d6ea'), (26, '#cde6e8'), (40, '#e6efe6')])
    cloud(cv, 24, 14, 34, '#f1ece0', '#cde6e8')
    cloud(cv, 168, 10, 44, '#f1ece0', '#cde6e8')
    peaks = poly([(-10, 62), (18, 38), (36, 48), (62, 28), (92, 52), (120, 38), (150, 56), (182, 26), (212, 44), (250, 32), (250, 66), (-10, 66)])
    cv.fill(peaks, '#a9d6ea')
    cv.fill(peaks & ~shift(peaks, -3, 0) & ~rect(0, 0, W, 32), '#7fbcd8')
    caps = (poly([(18, 38), (27, 47), (9, 47)]) | poly([(62, 28), (75, 43), (49, 43)]) | poly([(120, 38), (129, 47), (111, 47)])
            | poly([(182, 26), (197, 43), (167, 43)]) | poly([(250, 32), (250, 45), (237, 43)]))
    cv.fill(caps & peaks, '#f1ece0')
    cv.fill(caps & peaks & ~shift(caps & peaks, -2, 0), '#cde6e8')
    # far tundra plain: grey-green moss with lingering snow
    far = wave(58, [(2, 110, 0.6), (1.5, 47, 2.1)])
    cv.fill(far, '#a4b8a8')
    cv.fill(top_edge(far, 1), '#cde6e8')
    for (x, y, w, sd) in ((8, 60, 26, 11), (150, 59, 30, 12), (200, 62, 26, 13), (56, 63, 18, 14)):
        cv.fill(snow_patch(x, y, w, 3, sd), '#f1ece0')
    mid = wave(66, [(2, 90, 1.6), (1, 31, 0.3)])
    cv.fill(mid, '#a4b86a')
    cv.fill(top_edge(mid, 1), '#c9a96e')
    # the lake in the middle: blue water with ice floes and a snowy rim
    lake = ell(70, 67, 176, 84)
    cv.fill(lake, '#3f8fb0')
    cv.fill(lake & ~shift(lake, 0, -2), '#7fbcd8')
    for (x0, y0, x1, y1) in ((80, 73, 100, 76), (108, 70, 130, 72), (136, 74, 150, 78), (154, 71, 166, 73), (96, 79, 112, 81)):
        f = rrect(x0, y0, x1, y1, 1) & lake
        cv.fill(f, '#f1ece0')
        cv.fill(f & ~shift(f, 0, -1), '#a9d6ea')
    for (x, y, w) in ((118, 77, 12), (88, 70, 6), (140, 70, 8)):
        cv.fill(rect(x, y, x + w, y), '#a9d6ea')
    # an inukshuk beyond the lake, on its own small rise in the middle (between the two sides)
    rise = ell(104, 58, 140, 70) & rect(0, 0, W, 66)
    cv.fill(rise, '#a4b86a')
    cv.fill(top_edge(rise, 1), '#c9a96e')
    inukshuk(cv, 122, 64, 0.62)
    tundra_ground(cv, 84, '#a4b86a', '#7ab55c', '#c9a96e', thaw=True)
    # spruces: a far stand on the left, a near snowy pair hugging the left edge
    for (x, yb, w, h) in ((38, 70, 10, 18), (48, 72, 12, 22), (58, 70, 9, 16)):
        pine(cv, x, yb, w, h, flat='#4f7a5a', snow='#f1ece0')
    pine(cv, 8, 92, 18, 46, snow='#f1ece0')
    pine(cv, 22, 88, 12, 30, snow='#f1ece0')
    # foreground corners: lichen boulders, bearberry, cottongrass
    for (x0, y0, x1, y1) in ((-8, 112, 34, 134), (206, 114, 250, 134)):
        rock(cv, x0, y0, x1, y1)
        for (dx, dy) in ((8, 6), (14, 4), (20, 8), (30, 6)):
            cv.fill(rect(x0 + dx, y0 + dy, x0 + dx + 2, y0 + dy + 1), '#e8cf98')
    bearberry(cv, 34, 120)
    bearberry(cv, 186, 122)
    cottongrass(cv, [(52, 126, 8), (56, 124, 10), (60, 127, 7), (176, 124, 9), (180, 126, 7), (230, 104, 8), (234, 106, 6), (90, 116, 6)])
    birds(cv, [(118, 18), (128, 14), (138, 20)], '#5b6470')
    cv.remap({'#fff3c8': '#f1ece0', '#c9c5bc': '#e6efe6'})
    return cv


def tundra_2():
    """Dawn: low sun on the horizon, pink snow and violet shadows, a caribou herd on the far ridge, ice slabs."""
    cv = Canvas()
    bands(cv, [(0, '#9f8ad6'), (12, '#c3b2ea'), (24, '#f6d9e0'), (36, '#f6d9b0')])
    cv.fill(ell(40, 34, 64, 58) & rect(0, 0, W, 48), '#f5cf6a')
    cv.fill(ell(45, 39, 59, 53) & rect(0, 0, W, 48), '#fff3c8')
    for (x, y, w) in ((90, 20, 50), (170, 14, 46), (8, 26, 30)):
        cv.fill(rrect(x, y, x + w, y + 2, 1), '#f6d9e0')
        cv.fill(rect(x + 4, y + 2, x + w - 6, y + 2), '#c3b2ea')
    # long low far ridges
    cv.fill(wave(48, [(2, 120, 0.4), (1.5, 41, 1.0)]), '#c3b2ea')
    cv.fill(rect(30, 46, 74, 48) & ~wave(48, [(2, 120, 0.4), (1.5, 41, 1.0)]), '#f5cf6a')
    r2 = wave(56, [(3, 90, 2.2), (1.5, 33, 0.3)])
    cv.fill(r2, '#9f8ad6')
    cv.fill(top_edge(r2, 1), '#f6d9e0')
    for (x, y, f) in ((118, 54, 1), (132, 53, 1), (146, 55, -1), (160, 54, 1), (174, 56, 1)):
        caribou(cv, x, y, '#7a5cc0', f)
    # pink snow plain, frozen river with ice slabs
    mid = wave(64, [(2, 130, 0.9)])
    cv.fill(mid, '#f6d9e0')
    riv = wave(70, [(1.5, 80, 0.2)]) & ~wave(80, [(1.5, 70, 1.4)])
    cv.fill(riv, '#c3b2ea')
    cv.fill(top_edge(riv, 1), '#9f8ad6')
    for (x, y, w) in ((20, 73, 16), (70, 75, 12), (200, 74, 20)):
        cv.fill(rect(x, y, x + w, y), '#f6d9e0')
    for (x0, y0, x1, y1) in ((94, 64, 108, 80), (106, 70, 122, 82), (124, 72, 132, 81), (150, 68, 164, 80)):
        o = cv.obj()
        sl = poly([(x0, y1), (x0 + 2, y0 + 5), (x0 + 5, y0), (x1 - 3, y0 + 4), (x1, y1)])
        o.part(sl, ramp('#d9d4ee', '#9f8ad6', '#f1ece0'), d=2)
        o.draw()
        cv.fill(sl & poly([(x0, y1), (x0 + 5, y0), (x0 + 7, y1)]), '#f1ece0')
        cv.fill(line([(x0 + 5, y0 + 1), (x0 + 7, y1 - 1)]) & sl, '#c3b2ea')
    tundra_ground(cv, 84, '#f6d9e0', '#c3b2ea', '#c9a96e')
    # snow-laden spruce pair on the right edge (sunlit side faces left)
    pine(cv, 228, 92, 20, 50, snow='#f1ece0')
    pine(cv, 214, 90, 12, 28, snow='#f1ece0')
    # foreground: wind-carved drift left, rocks and sedge
    drift = poly([(-4, 122), (14, 116), (30, 118), (44, 126), (48, 135), (-4, 135)])
    cv.fill(drift, '#f1ece0')
    cv.fill(drift & ~shift(drift, -2, -2), '#c3b2ea')
    rock(cv, 34, 116, 58, 132, cap=ramp('#f6d9e0', '#c3b2ea', '#f1ece0'))
    rock(cv, 200, 118, 246, 135, cap=ramp('#f6d9e0', '#c3b2ea', '#f1ece0'))
    cottongrass(cv, [(70, 126, 8), (74, 128, 6), (190, 124, 9), (194, 126, 7)], '#c9a96e', '#f1ece0')
    birds(cv, [(98, 30), (108, 26)], '#7a5cc0')
    cv.remap({'#c9c5bc': '#d9d4ee', '#f2e4c0': '#f1ece0', '#cde6e8': '#d9d4ee', '#a4b86a': '#c9a96e'})
    return cv


def tundra_3():
    """Soft snowfall: pale overcast, a snow house with a warm doorway, an inukshuk and spruces in the haze."""
    cv = Canvas()
    bands(cv, [(0, '#c9c5bc'), (14, '#d9d4ee'), (30, '#e6efe6')])
    cv.fill(wave(46, [(5, 100, 1.4), (3, 43, 0.4)]), '#d9d4ee')
    cv.fill(wave(56, [(4, 80, 0.2), (2, 29, 2.0)]), '#c9c5bc')
    for x in range(120, W + 10, 9):
        pine(cv, x, 66 + (x * 5) % 5, 12, 22 + (x * 7) % 10, flat='#a4b8a8', snow='#e6efe6')
    mid = wave(64, [(2, 110, 0.6)])
    cv.fill(mid, '#f1ece0')
    cv.fill(top_edge(mid, 1), '#cde6e8')
    # snow house on the left, back of the clearing; sled beside it
    igloo(cv, 52, 82, 22)
    o = cv.obj()
    o.part(rect(80, 76, 104, 79), WOOD, d=1)
    o.part(line([(80, 82), (104, 82), (108, 78)], 2), DWOOD, d=0)
    o.part(rect(84, 72, 98, 76), EMBER, d=1, contour=True)
    o.draw()
    cv.fill(rect(82, 80, 83, 81) | rect(100, 80, 101, 81), '#5c3420')
    # inukshuk centre-right back, spruces right
    inukshuk(cv, 150, 80, 0.95)
    pine(cv, 188, 82, 14, 30, snow='#f1ece0')
    pine(cv, 200, 84, 18, 40, snow='#f1ece0')
    tundra_ground(cv, 84, '#f1ece0', '#cde6e8', '#c9a96e')
    # footprints-free flat lane; drifts and rocks in the corners
    drift = poly([(176, 135), (196, 114), (222, 108), (244, 112), (244, 135)])
    cv.fill(drift, '#f1ece0')
    cv.fill(drift & ~shift(drift, 2, 2), '#cde6e8')
    rock(cv, -10, 110, 30, 134, cap=SNOW)
    rock(cv, 222, 98, 244, 114, cap=SNOW)
    o = cv.obj(); o.part(rect(36, 112, 38, 132), DWOOD, d=0); o.part(rect(30, 112, 44, 114), DWOOD, d=0); o.draw()
    o = cv.obj(); o.part(rect(32, 115, 42, 124), ramp('#f5cf6a', '#e8a317', '#fff3c8'), d=1, contour=True); o.draw()
    cv.fill(rect(36, 117, 38, 121), '#f08a24')
    cottongrass(cv, [(50, 126, 7), (54, 128, 5), (170, 126, 8)], '#c9a96e', '#f1ece0')
    # falling snow: big flakes on darker things, fine flakes everywhere
    snowfall(cv, 3, 260, '#f1ece0', ys=(0, 132))
    snowfall(cv, 4, 70, '#a9d6ea', ys=(64, 132), avoid=~mask_of(cv, ['#f1ece0']))
    cv.remap({'#fff3c8': '#f1ece0', '#f2e4c0': '#f1ece0', '#7ab55c': '#a4b86a'})
    return cv


# ================================================================== ISLAND
def island_beach(cv, y0=84, wet='#c9a96e', dry='#e8cf98', foam='#f1ece0', sea=None):
    """Sea edge with foam, then a flat sand lane the figures stand on; shells and ripples only."""
    surf = wave(y0 - 6, [(1.5, 60, 0.7), (1, 23, 2.0)])
    cv.fill(surf, wet)
    cv.fill(top_edge(surf, 1), foam)
    beach = wave(y0, [(1.0, 90, 0.3)])
    cv.fill(beach, dry)
    cv.fill(top_edge(beach, 1), wet)
    for (x, y, w) in ((14, 96, 18), (70, 104, 22), (128, 94, 16), (178, 102, 24), (100, 112, 18), (210, 110, 14)):
        cv.fill(rect(x, y, x + w, y), wet)
    cv.fill(rect(0, 117, W - 1, H - 1), '#c9a96e')
    cv.fill(wave(119, [(1.2, 40, 0.9)]), dry)
    for (x, y) in ((40, 100), (152, 108), (90, 92), (222, 96)):
        cv.dots([(x, y), (x + 1, y), (x + 2, y - 1)], '#f2e4c0')


def island_1():
    """Midday: turquoise lagoon, a far volcano isle with a smoke puff, a sail, palms framing the beach."""
    cv = Canvas()
    bands(cv, [(0, '#7fbcd8'), (14, '#a9d6ea'), (28, '#cde6e8')])
    cloud(cv, 30, 12, 36, '#f1ece0', '#cde6e8')
    cloud(cv, 150, 20, 28, '#f1ece0', '#cde6e8')
    # sea: horizon line, lagoon bands
    bands(cv, [(46, '#7fbcd8'), (56, '#7fc8c8'), (70, '#bfe6e0')])
    # volcano isle right of centre
    vol = poly([(120, 46), (150, 24), (162, 24), (196, 46)])
    cv.fill(vol, '#7ab58a')
    cv.fill(vol & ~shift(vol, -4, 0), '#4f7a5a')
    cv.fill(poly([(147, 27), (150, 24), (162, 24), (165, 27)]), '#8b8f96')
    for (x, y, w) in ((150, 16, 8), (156, 10, 10), (164, 6, 8)):
        cv.fill(ell(x, y, x + w, y + w * 2 // 3), '#f1ece0')
    cv.fill(rect(116, 45, 200, 46), '#a4b86a')
    for (x, w) in ((124, 6), (132, 5), (186, 6)):
        cv.fill(ell(x, 40, x + w, 46), '#4f7a5a')
    # a little sail far out left
    o = cv.obj(outline=False)
    o.part(poly([(66, 34), (66, 48), (56, 48)]), ramp('#f1ece0', None), d=0)
    o.part(poly([(68, 38), (68, 48), (74, 48)]), ramp('#e46a9b', None), d=0)
    o.part(rect(54, 49, 76, 51), ramp('#7a4a1f', None), d=0)
    o.draw()
    ripples(cv, rect(0, 50, W - 1, 68), '#bfe6e0', step=4, ln=4, seed=2)
    ripples(cv, rect(0, 70, W - 1, 78), '#7fc8c8', step=4, ln=3, seed=5)
    island_beach(cv)
    # palms: left one leans in from the edge, right one from the right edge
    palm(cv, (8, 116), (0, 70), (24, 26), w0=8, w1=5)
    palm(cv, (234, 116), (244, 76), (216, 32), w0=8, w1=5,
         fronds=[(-10, 30, 3), (-40, 34, 6), (-80, 26, 10), (-120, 30, 8), (-160, 34, 5), (170, 28, 3), (20, 24, 2)])
    # foreground corners
    for (x, y) in ((28, 118), (34, 122)):
        coconut(cv, x, y)
    starfish(cv, 50, 126)
    shell(cv, 70, 124)
    shell(cv, 172, 126, ramp('#f2e4c0', '#c9a96e', '#fff3c8'))
    starfish(cv, 196, 122, ramp('#e46a9b', '#b8457a', '#f6b8cf'))
    grass_clump(cv, 214, 130, '#4f9a45', '#7ab55c', 9, 6)
    grass_clump(cv, 12, 132, '#4f9a45', '#7ab55c', 8, 5)
    birds(cv, [(96, 16), (106, 12), (204, 18)], '#5b6470')
    cv.remap({'#fff3c8': '#f2e4c0', '#c9c5bc': '#f1ece0', '#a8241f': '#b8457a'})
    return cv


def island_2():
    """Dawn: the sun lifting off the sea, a gold path on the water, a beached outrigger, tide pools."""
    cv = Canvas()
    bands(cv, [(0, '#c3b2ea'), (12, '#f6b8cf'), (24, '#f6d9b0'), (36, '#f5cf6a')])
    cv.fill(ell(106, 30, 134, 58) & rect(0, 0, W, 45), '#fff3c8')
    for (x, y, w) in ((10, 16, 50), (150, 10, 60), (60, 26, 30), (176, 28, 40)):
        cv.fill(rrect(x, y, x + w, y + 3, 1), '#f6d9e0')
        cv.fill(rect(x + 4, y + 3, x + w - 4, y + 3), '#e46a9b')
    # far isles as violet silhouettes
    cv.fill(wave(42, [(3, 40, 0.3)], 0, 60, 45) | wave(40, [(4, 60, 1.0)], 176, W - 1, 45), '#9f8ad6')
    bands(cv, [(46, '#e6b8c8'), (54, '#c3b2ea'), (66, '#a9d6ea')])
    for y in range(47, 76, 3):
        hw = 8 + (y - 46) // 2
        cv.fill(rect(120 - hw, y, 120 + hw - (y % 4), y), '#f5cf6a')
    ripples(cv, rect(0, 56, W - 1, 64), '#f6d9e0', step=4, ln=4, seed=1)
    ripples(cv, rect(0, 66, W - 1, 76), '#f1ece0', step=4, ln=3, seed=3)
    island_beach(cv)
    # a dugout canoe pulled up at the water's edge in the middle, paddle across it
    o = cv.obj()
    hull = poly([(92, 77), (146, 77), (152, 73), (148, 83), (98, 84), (89, 80)])
    o.part(hull, WOOD, d=2)
    o.part(rect(94, 76, 148, 77), DWOOD, d=0, contour=True)
    o.draw()
    cv.fill(rect(97, 80, 146, 80) & hull, '#d6322b')
    cv.fill(rect(97, 81, 146, 81) & hull, '#f1ece0')
    o = cv.obj(); o.part(line([(104, 72), (136, 76)], 2), DWOOD, d=0); o.part(rrect(134, 73, 144, 78, 2), WOOD, d=1, contour=True); o.draw()
    # tide pool among low rocks at the right edge, by the palm
    for (x0, y0, x1, y1) in ((196, 78, 214, 86), (222, 76, 240, 86)):
        rock(cv, x0, y0, x1, y1, d=2)
    tp = ell(202, 83, 232, 89)
    cv.fill(tp & ~rect(0, 0, W, 84), '#a9d6ea')
    cv.fill(rect(208, 86, 214, 86), '#f1ece0')
    # palms: tall one leaning in from the right edge, a short one from the left edge
    palm(cv, (230, 118), (246, 70), (212, 22), w0=8, w1=5,
         fronds=[(-10, 30, 3), (-40, 34, 6), (-80, 26, 10), (-120, 30, 8), (-160, 34, 5), (170, 28, 3), (20, 24, 2)])
    palm(cv, (6, 112), (-2, 84), (14, 52), w0=7, w1=5, leaf=MOSS,
         fronds=[(-170, 22, 2), (-130, 24, 5), (-90, 18, 8), (-50, 24, 7), (-15, 26, 4), (15, 22, 3)])
    # foreground
    for (x0, y0, x1, y1) in ((-10, 116, 30, 135), (206, 120, 250, 135)):
        rock(cv, x0, y0, x1, y1, d=3)
    starfish(cv, 40, 126)
    shell(cv, 190, 128)
    shell(cv, 58, 124, ramp('#f2e4c0', '#c9a96e', '#fff3c8'))
    grass_clump(cv, 30, 130, '#4f9a45', '#7ab55c', 8, 5)
    birds(cv, [(70, 24), (80, 20), (160, 26)], '#7a5cc0')
    cv.remap({'#c9c5bc': '#f1ece0', '#f2e4c0': '#f1ece0', '#a8241f': '#d6322b', '#f08a24': '#e8a317', '#7a5cc0': '#9f8ad6'})
    return cv


def island_3():
    """Golden late afternoon: low orange sun, a rocky point with a little lighthouse, a hammock between palms."""
    cv = Canvas()
    bands(cv, [(0, '#7a5cc0'), (10, '#c3b2ea'), (20, '#f6b8cf'), (30, '#f08a24'), (40, '#f5cf6a')])
    cv.fill(ell(56, 30, 84, 58) & rect(0, 0, W, 45), '#fff3c8')
    for (x, y, w) in ((100, 14, 56), (20, 10, 40), (176, 20, 44)):
        cv.fill(rrect(x, y, x + w, y + 3, 1), '#f6b8cf')
        cv.fill(rect(x + 3, y + 3, x + w - 3, y + 3), '#e46a9b')
    # sea in warm evening bands, sun path
    bands(cv, [(46, '#e46a9b'), (54, '#9f8ad6'), (66, '#7fbcd8')])
    for y in range(47, 74, 3):
        hw = 6 + (y - 46) // 2
        cv.fill(rect(70 - hw, y, 70 + hw - (y % 4), y), '#f5cf6a')
    ripples(cv, rect(0, 56, W - 1, 64), '#c3b2ea', step=4, ln=4, seed=4)
    ripples(cv, rect(0, 66, W - 1, 76), '#a9d6ea', step=4, ln=3, seed=6)
    # rocky point with a lighthouse, right of centre on the horizon
    # (the whole lighthouse sits below grid y 30 so the phone crop keeps its roof)
    lx = 126
    for (x0, y0, x1, y1) in ((lx - 26, 62, lx + 18, 77), (lx + 8, 65, lx + 36, 78), (lx - 36, 68, lx - 14, 78)):
        rock(cv, x0, y0, x1, y1, d=3)
    o = cv.obj()
    tw = poly([(lx - 7, 66), (lx + 7, 66), (lx + 5, 44), (lx - 5, 44)])
    o.part(tw, CANVAS, d=2)
    o.part(rect(lx - 7, 38, lx + 7, 44), ramp('#3d2a1c', '#2a1a10', '#5c3420'), d=0, contour=True)
    o.part(poly([(lx - 9, 38), (lx, 31), (lx + 9, 38)]), EMBER, d=1, contour=True)
    o.part(rect(lx - 9, 44, lx + 9, 46), DWOOD, d=0, contour=True)
    o.draw()
    for y in (50, 58):
        cv.fill(rect(lx - 15, y, lx + 15, y + 3) & tw, '#d6322b')
    cv.fill(rect(lx - 4, 39, lx + 4, 43), '#f5cf6a')
    cv.fill(rect(lx - 1, 40, lx + 1, 42), '#fff3c8')
    cv.fill(rrect(lx - 2, 60, lx + 2, 65, 1), '#7a4a1f')
    for (dx, dy, l2) in ((-11, 41, 6), (11, 41, 6)):                    # little light rays
        cv.fill(rect(lx + dx - (l2 if dx < 0 else 0), dy, lx + dx + (0 if dx < 0 else l2), dy), '#fff3c8')
    island_beach(cv, 84, '#c9a96e', '#e8cf98', '#f6d9e0')
    # palms with a hammock slung between their trunks, at the very edges
    palm(cv, (10, 118), (2, 72), (28, 28), w0=8, w1=5, leaf=MOSS)
    palm(cv, (232, 118), (244, 80), (220, 30), w0=8, w1=5, leaf=MOSS,
         fronds=[(-10, 30, 3), (-40, 34, 6), (-80, 26, 10), (-120, 30, 8), (-160, 34, 5), (170, 28, 3), (20, 24, 2)])
    # driftwood log and a little beach fire low in the foreground, below where the figures stand
    o = cv.obj(); o.part(rrect(76, 120, 116, 126, 2), ramp('#c9a96e', '#9a6b3f', '#f2e4c0'), d=1); o.draw()
    cv.fill(rect(82, 123, 110, 123), '#9a6b3f')
    fx, fy = 134, 118
    for (x, y, w, c) in ((fx - 6, fy, 12, '#d6322b'), (fx - 4, fy + 3, 8, '#f08a24'), (fx - 2, fy + 6, 4, '#f5cf6a')):
        cv.fill(poly([(x, fy + 9), (x + w // 2, y), (x + w, fy + 9)]), c)
    o = cv.obj()
    for k in range(6):
        a = k * 2 * math.pi / 6
        sx, sy = fx + round(9 * math.cos(a)), fy + 10 + round(2 * math.sin(a))
        o.part(ell(sx - 2, sy - 1, sx + 2, sy + 2), STONE, d=1)
    o.draw()
    # foreground
    starfish(cv, 46, 124)
    coconut(cv, 26, 120)
    shell(cv, 184, 126)
    shell(cv, 60, 128, ramp('#f2e4c0', '#c9a96e', '#fff3c8'))
    grass_clump(cv, 212, 130, '#4f9a45', '#7ab55c', 9, 6)
    for (x, y) in ((30, 22), (40, 18), (120, 26)):
        birds(cv, [(x, y)], '#7a5cc0')
    cv.remap({'#c9c5bc': '#f1ece0', '#f2e4c0': '#f1ece0', '#a8241f': '#d6322b', '#2a1a10': '#3d2a1c'})
    return cv


# ------------------------------------------------------------------ util needing numpy on the canvas
import numpy as np  # noqa: E402


def mask_of(cv, cols):
    from pixlib import hx
    m = np.zeros((H, W), bool)
    for c in cols:
        m |= np.all(cv.px == hx(c), axis=2)
    return m


STAGES = {'rainforest': rainforest_1, 'rainforest-v2': rainforest_2, 'rainforest-v3': rainforest_3,
          'tundra': tundra_1, 'tundra-v2': tundra_2, 'tundra-v3': tundra_3,
          'island': island_1, 'island-v2': island_2, 'island-v3': island_3}

if __name__ == '__main__':
    out = sys.argv[1] if len(sys.argv) > 1 else os.path.join(os.path.dirname(__file__), '..', '..', 'game', 'assets', 'img', 'scenes')
    only = sys.argv[2:] or list(STAGES)
    for k in only:
        cv = STAGES[k]()
        n = cv.colours()
        p = os.path.join(out, 'stage-' + k + '.png')
        cv.save(p)
        print(k, 'colours', n, '(over the 32 cap!)' if n > 32 else '', '->', p)
