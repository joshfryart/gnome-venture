"""Rest stop headers, one scene per stop type (2026-10-27): game/assets/img/scenes/stop-<type>.png.

Usage: python3 aseprite-source/scenes-pil/stops.py [out_dir] [type ...]   (default: game/assets/img/scenes, all 12)
Drawn on the 240 x 135 scene grid with pixlib, written at 2x (480 x 270). The place header shows a 2:1 band with
object-position 62%, so about 9 grid px off the top and 6 off the bottom are cropped: every subject sits in y 10..128.
Each stop has its own sky, far layer, ground and composition (no shared template). Palette: Part A families plus the
Part D ramp recipe; a few hazy sky / far-layer tints per scene, the same family across the set.
"""
import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from pixlib import (Canvas, ramp, rect, rrect, ell, poly, line, blank, shift, W, H)  # noqa: E402
from shops import (WOOD, DWOOD, CREAM, BREAD, STONE, BRICK, PETAL, COPPER, MOSS, LEAF, WATER, DUSK, EMBER, GOLD,
                   stitch_h, barrel)  # noqa: E402

PINE = ramp('#2f6a3a', '#1f3f3a', '#4f9a45')
THATCH = ramp('#e8a317', '#b07a10', '#f5cf6a')
CANVAS = ramp('#f2e4c0', '#c9a96e', '#fff3c8')
BURLAP = ramp('#c9a96e', '#9a6b3f', '#f2e4c0')
ROOF = ramp('#d6322b', '#a8241f', '#e0501f')


# ------------------------------------------------------------------ helpers
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


def tree(cv, x, y, w, h, leaf=LEAF, trunk=WOOD, th=10, fruit=None, fcol2=None):
    """Round clumpy tree; each clump gets its own crescent so the canopy reads as leaves, not a ball."""
    o = cv.obj()
    cx = x + w // 2
    o.part(rect(cx - 2, y + h - 6, cx + 2, y + h + th), trunk, d=1)
    o.part(poly([(cx - 2, y + h + th), (cx - 6, y + h + th + 1), (cx + 6, y + h + th + 1), (cx + 2, y + h + th)]), trunk, d=0)
    clumps = [(x, y + h * 0.35, x + w * 0.55, y + h), (x + w * 0.45, y + h * 0.3, x + w, y + h),
              (x + w * 0.12, y, x + w * 0.62, y + h * 0.6), (x + w * 0.4, y + h * 0.05, x + w * 0.9, y + h * 0.62),
              (x + w * 0.25, y + h * 0.3, x + w * 0.75, y + h * 0.85)]
    for (a, b, c, d) in clumps:
        o.part(ell(round(a), round(b), round(c), round(d)), leaf, d=2)
    o.draw()
    if fruit:
        k = 0
        for (fx, fy) in ((0.22, 0.55), (0.5, 0.3), (0.7, 0.62), (0.38, 0.75), (0.82, 0.4), (0.3, 0.32), (0.58, 0.82)):
            px, py = round(x + w * fx), round(y + h * fy)
            cv.fill(rect(px, py, px + 2, py + 2), fruit if (fcol2 is None or k % 3) else fcol2)
            cv.dots([(px, py)], '#f5cf6a')
            k += 1


def pine(cv, x, ybot, w, h, rp=PINE, trunk=DWOOD, outline=True, flat=None):
    """Three-tier pine. flat=colour draws a hazy far silhouette with no outline or shading."""
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
        return
    o = cv.obj(outline)
    o.part(m_tr, trunk, d=0)
    for t in tiers:
        o.part(t, rp, d=2)
    o.draw()


def rock(cv, x0, y0, x1, y1, rp=STONE, moss=None, d=3):
    o = cv.obj()
    m = ell(x0, y0, x1, y1 + (y1 - y0) // 2) & rect(0, 0, W, y1)
    o.part(m, rp, d=d)
    if moss:
        o.part(m & ~shift(m, 0, -max(3, (y1 - y0) // 3)) & ~rect(0, y0 + (y1 - y0) // 2, W, H), moss, d=1)
    o.draw()
    return m


def tufts(cv, pts, col):
    for (x, y) in pts:
        cv.dots([(x, y), (x + 2, y), (x + 1, y - 1), (x - 1, y - 2), (x + 3, y - 2)], col)


def ripples(cv, mask, col, step=6, ln=4, seed=0):
    ys, xs = mask.nonzero()
    if not len(ys):
        return
    for y in range(ys.min() + 2, ys.max(), step):
        off = ((y * 7 + seed) % 13) * 3
        for x in range(off % 23, W, 23):
            seg = rect(x, y, x + ln + (y % 3), y) & mask
            cv.fill(seg, col)


def lantern(cv, x, y, glow='#f5cf6a'):
    o = cv.obj()
    o.part(rect(x - 3, y, x + 3, y + 1), STONE, d=0)
    o.part(rect(x - 2, y + 2, x + 2, y + 7), ramp(glow, '#e8a317', '#fff3c8'), d=1, contour=True)
    o.part(rect(x - 3, y + 8, x + 3, y + 9), STONE, d=0, contour=True)
    o.draw()
    cv.fill(rect(x - 1, y + 4, x, y + 6), '#f08a24')


def cobbles(cv, mask, base, line_c, lite, w=10, h=5):
    cv.fill(mask, base)
    ys, xs = mask.nonzero()
    y0 = ys.min()
    r = 0
    for y in range(y0, H, h):
        off = 0 if r % 2 else w // 2
        cv.fill(rect(0, y, W - 1, y) & mask, line_c)
        for x in range(off, W, w):
            cv.fill(rect(x, y, x, y + h - 1) & mask, line_c)
            cv.fill(rect(x + 2, y + 1, x + 3, y + 1) & mask, lite)
        r += 1
        h = h + 1 if r % 2 == 0 and h < 8 else h
        w = w + 2 if r % 2 == 0 and w < 18 else w


# ================================================================== MARKET: stalls and awnings at midday
def market():
    cv = Canvas()
    bands(cv, [(0, '#7fbcd8'), (16, '#a9d6ea'), (34, '#cde6e8')])
    cloud(cv, 14, 14, 30, '#f1ece0', '#cde6e8')
    cloud(cv, 168, 20, 40, '#f1ece0', '#cde6e8')
    # far town: plaster houses with hazy roofs, a church tower in the middle
    houses = [(-4, 26, 30), (20, 22, 36), (40, 30, 28), (66, 24, 38), (88, 20, 30), (128, 26, 34), (152, 22, 28),
              (172, 30, 38), (200, 24, 30), (222, 22, 36)]
    for (x, w, h) in houses:
        top = 76 - h
        cv.fill(rect(x, top, x + w, 80), '#e8dcc0')
        cv.fill(poly([(x - 2, top + 1), (x + w // 2, top - w // 2 + 2), (x + w + 2, top + 1)]), '#d9875a')
        cv.fill(rect(x + w - 3, top, x + w, 80), '#c9b48e')
        for wx in range(x + 4, x + w - 5, 8):
            cv.fill(rect(wx, top + 6, wx + 2, top + 9), '#c9b48e')
    cv.fill(rect(108, 22, 126, 80), '#e8dcc0')
    cv.fill(rect(122, 22, 126, 80), '#c9b48e')
    cv.fill(poly([(105, 23), (117, 6), (129, 23)]), '#d9875a')
    cv.fill(ell(113, 30, 121, 38), '#c9b48e')
    # bunting across the square (the strings sit fully inside the crop)
    for (xa, xb, ya, sag, off) in ((-2, 120, 13, 9, 0), (120, 242, 13, 9, 3)):
        pts = [(x, ya + round(sag * (1 - ((2 * (x - xa) / (xb - xa)) - 1) ** 2))) for x in range(xa, xb + 1)]
        cv.fill(line(pts), '#4a2c1a')
        cols = ['#d6322b', '#e8a317', '#3f8fb0', '#e46a9b', '#4f9a45']
        for i, (x, y) in enumerate(pts[4::10]):
            o = cv.obj(outline=False)
            o.part(poly([(x - 3, y + 1), (x + 3, y + 1), (x, y + 7)]), ramp(cols[(i + off) % 5], None), d=0)
            o.draw()
    # hedge of round shrubs behind the stalls
    hed = blank()
    for x in range(-6, W, 14):
        hed |= ell(x, 70, x + 18, 86)
    cv.fill(hed | rect(0, 78, W - 1, 90), '#4f9a45')
    cv.fill((hed | rect(0, 78, W - 1, 90)) & ~shift(hed, 0, 2) & rect(0, 0, W, 84), '#7ab55c')
    # the square: cobbles
    sq = rect(0, 88, W - 1, H - 1)
    cobbles(cv, sq, '#c9c5bc', '#8b8f96', '#f1ece0', w=12, h=5)

    def stall(x0, x1, cols, goods):
        # posts
        o = cv.obj()
        o.part(rect(x0 + 1, 50, x0 + 4, 104), WOOD, d=1)
        o.part(rect(x1 - 4, 50, x1 - 1, 104), WOOD, d=1)
        o.draw()
        cv.fill(rect(x0 + 5, 56, x1 - 5, 86), '#5c3420')
        # awning: slanted top + scalloped valance, striped
        top = poly([(x0 + 4, 34), (x1 - 4, 34), (x1 + 4, 48), (x0 - 4, 48)])
        val = rect(x0 - 4, 48, x1 + 4, 53)
        for x in range(x0 - 4, x1 + 4, 8):
            val |= ell(x, 50, x + 7, 58)
        stripes = blank()
        for x in range(x0 - 8, x1 + 8, 8):
            stripes |= poly([(x + 4 + (x - (x0 + x1) // 2) // 6, 34), (x + 8 + (x - (x0 + x1) // 2) // 6, 34), (x + 8, 58), (x + 4, 58)])
        a, b = cols
        o = cv.obj()
        o.part(top, a, d=2)
        o.part(val, a, d=2, contour=True)
        o.draw()
        cv.fill((top | val) & stripes, b['b'])
        cv.fill(val & stripes & ~shift(val, -2, -2), b['s'])
        cv.fill(rect(x0 - 4, 48, x1 + 4, 48), a['s'])
        # counter
        o = cv.obj()
        o.part(rect(x0 - 2, 82, x1 + 2, 86), WOOD, d=1)
        o.part(rect(x0, 87, x1, 106), DWOOD, d=2, contour=True)
        o.draw()
        for x in range(x0 + 4, x1 - 2, 6):
            cv.fill(rect(x, 89, x, 104), '#5c3420')
        goods(x0, x1)

    def apples(x0, x1):
        for i, xx in enumerate(range(x0 + 2, x1 - 14, 18)):
            o = cv.obj()
            o.part(rect(xx, 74, xx + 15, 82), WOOD, d=1)
            o.draw()
            cv.fill(rect(xx, 77, xx + 15, 77), '#7a4a1f')
            rp = EMBER if i % 2 == 0 else ramp('#a4b86a', '#4f9a45', '#f5cf6a')
            for (dx, dy) in ((1, 69), (6, 68), (11, 69), (3, 72), (9, 72)):
                o = cv.obj(outline=False); o.part(ell(xx + dx, dy, xx + dx + 5, dy + 5), rp, d=1); o.draw()
        for (hx_, hy) in ((x0 + 12, 58), (x0 + 30, 60), (x0 + 48, 58)):          # garlic strings under the awning
            cv.fill(rect(hx_, 56, hx_, hy + 2), '#c9a96e')
            for k in range(3):
                o = cv.obj(); o.part(ell(hx_ - 2, hy + 2 + k * 5, hx_ + 2, hy + 6 + k * 5), CANVAS, d=1); o.draw()

    def bread(x0, x1):
        for (bx, by) in ((x0 + 4, 72), (x0 + 20, 70), (x0 + 50, 72)):
            o = cv.obj(); o.part(ell(bx, by, bx + 16, by + 11), BREAD, d=2); o.draw()
            cv.fill(line([(bx + 4, by + 6), (bx + 7, by + 3)]) | line([(bx + 9, by + 7), (bx + 12, by + 4)]), '#b07a10')
        o = cv.obj()                                                    # stacked cheese wheels
        o.part(rrect(x0 + 34, 76, x0 + 50, 82, 2), GOLD, d=1)
        o.part(rrect(x0 + 36, 69, x0 + 48, 75, 2), GOLD, d=1, contour=True)
        o.draw()
        cv.fill(rect(x0 + 38, 70, x0 + 46, 70) | rect(x0 + 36, 77, x0 + 48, 77), '#f5cf6a')
        for k in range(4):                                               # hanging sausages
            xx = x0 + 10 + k * 14
            cv.fill(rect(xx, 56, xx, 58), '#4a2c1a')
            o = cv.obj(); o.part(rrect(xx - 2, 59, xx + 2, 66, 1), ramp('#a8241f', '#7a2a20', '#d6322b'), d=1); o.draw()

    def pots(x0, x1):
        for i, (px, rp) in enumerate(((x0 + 2, PETAL), (x0 + 18, GOLD), (x0 + 34, DUSK), (x0 + 50, PETAL))):
            o = cv.obj()
            o.part(ell(px - 1, 64, px + 13, 76), LEAF, d=2)
            o.part(poly([(px, 74), (px + 12, 74), (px + 10, 82), (px + 2, 82)]), BRICK, d=1, contour=True)
            o.draw()
            for (fx, fy) in ((2, 66), (7, 64), (10, 68), (4, 70)):
                cv.fill(rect(px + fx, fy, px + fx + 1, fy + 1), rp['b'])
        o = cv.obj(); o.part(rect(x0 + 6, 56, x1 - 6, 58), WOOD, d=0); o.draw()
        for k in range(3):                                                # baskets hanging
            xx = x0 + 10 + k * 18
            o = cv.obj(); o.part(ell(xx, 58, xx + 10, 66) & rect(0, 61, W, H), BURLAP, d=1); o.draw()

    stall(10, 70, (EMBER, CANVAS), apples)
    stall(90, 152, (GOLD, CANVAS), bread)
    stall(172, 232, (WATER, CANVAS), pots)
    # foreground: barrel of apples left, sack and basket right
    barrel(cv, 2, 110, 30, H + 1)
    for (x, y) in ((6, 104), (13, 103), (20, 105)):
        o = cv.obj(); o.part(ell(x, y, x + 6, y + 6), EMBER, d=1); o.draw()
    o = cv.obj()
    o.part(poly([(204, H + 1), (236, H + 1), (236, 118), (230, 110), (210, 110), (204, 118)]), BURLAP, d=3)
    o.part(rect(212, 106, 228, 111), WOOD, d=1, contour=True)
    o.draw()
    stitch_h(cv, 207, 233, 114, '#7a4a1f')
    o = cv.obj()
    o.part(poly([(176, 116), (200, 116), (196, 132), (180, 132)]), BURLAP, d=2)
    o.draw()
    for (x, y, rp) in ((178, 110, GOLD), (186, 108, EMBER), (192, 111, GOLD)):
        o = cv.obj(); o.part(ell(x, y, x + 7, y + 7), rp, d=1); o.draw()
    for y in (120, 125):
        cv.fill(rect(178, y, 198, y) & poly([(176, 116), (200, 116), (196, 132), (180, 132)]), '#9a6b3f')
    cv.remap({'#fff3c8': '#f1ece0', '#f2e4c0': '#f1ece0', '#7a2a20': '#a8241f'})
    return cv


# ================================================================== MILL: wheel, stream, fields in the morning
def mill():
    cv = Canvas()
    bands(cv, [(0, '#7fbcd8'), (12, '#a9d6ea'), (24, '#cde6e8'), (40, '#f1ece0')])
    cv.fill(ell(196, 12, 214, 30), '#f5cf6a')
    cloud(cv, 30, 12, 34, '#f1ece0', '#cde6e8')
    # far hills: patchwork fields
    far = wave(54, [(4, 90, 0.4), (2, 37, 1.3)])
    cv.fill(far, '#a4b86a')
    for x0 in range(-20, W, 34):
        cv.fill(far & poly([(x0, 40), (x0 + 16, 40), (x0 + 6, 80), (x0 - 10, 80)]), '#e8cf98')
    mid = wave(66, [(5, 120, 2.1), (2, 44, 0.3)])
    cv.fill(mid, '#7ab55c')
    for (x, w) in ((6, 16), (26, 12), (150, 14), (226, 16)):
        cv.fill(ell(x, 60, x + w, 60 + w), '#4f9a45')
        cv.fill(rect(x + w // 2, 60 + w, x + w // 2 + 1, 70), '#7a4a1f')
    near = wave(84, [(3, 150, 1.0)])
    cv.fill(near, '#4f9a45')
    # the stream: from under the wheel, curling down and out to the bottom right
    st = poly([(150, 92), (178, 92), (196, 104), (214, 118), (240, 124), (240, 135), (196, 135), (178, 118), (156, 104)])
    cv.fill(st, '#3f8fb0')
    cv.fill(st & ~shift(st, 0, 2), '#25637d')
    ripples(cv, st, '#a9d6ea', step=5, ln=5, seed=3)
    cv.fill(st & ~shift(st, -2, 0) & ~shift(st, 2, 0), '#a9d6ea')
    # mill house (stone, thatch), wheel on the right
    o = cv.obj()
    o.part(rect(62, 46, 140, 100), STONE, d=3)
    o.part(poly([(54, 50), (101, 14), (148, 50)]), THATCH, d=3, contour=True)
    o.part(rect(116, 18, 126, 36), BRICK, d=2)
    o.draw()
    for (y, xs) in ((56, (66, 90, 112, 132)), (66, (76, 100, 124)), (76, (66, 88, 110, 132)), (86, (78, 100, 122))):
        cv.fill(rect(63, y, 139, y), '#5b6470')
        for x in xs:
            cv.fill(rect(x, y - 9, x, y), '#5b6470')
    for y in range(24, 50, 6):                                          # thatch rows
        hw = round((y - 14) * 47 / 36)
        cv.fill(rect(101 - hw + 2, y, 101 + hw - 2, y) & poly([(54, 50), (101, 14), (148, 50)]), '#b07a10')
    o = cv.obj()
    o.part(rect(80, 70, 98, 100), DWOOD, d=2)
    o.part(rect(110, 58, 124, 70), DWOOD, d=1)
    o.draw()
    cv.fill(rect(112, 60, 122, 68), '#f5cf6a')
    cv.fill(rect(117, 60, 117, 68) | rect(112, 64, 122, 64), '#7a4a1f')
    cv.fill(rect(89, 72, 89, 99), '#5c3420')
    cv.fill(rect(94, 84, 95, 86), '#e8a317')
    # chute + wheel
    o = cv.obj()
    o.part(poly([(122, 36), (186, 36), (186, 41), (122, 41)]), WOOD, d=1)
    o.part(rect(180, 41, 184, 64), WOOD, d=1)
    o.draw()
    cv.fill(rect(166, 42, 172, 60), '#a9d6ea')
    cx, cy, R = 162, 72, 26
    o = cv.obj()
    o.part(ell(cx - R, cy - R, cx + R, cy + R) & ~ell(cx - R + 5, cy - R + 5, cx + R - 5, cy + R - 5), WOOD, d=2)
    sp = blank()
    for k in range(6):
        a = k * math.pi / 6
        sp |= line([(cx - (R - 4) * math.cos(a), cy - (R - 4) * math.sin(a)), (cx + (R - 4) * math.cos(a), cy + (R - 4) * math.sin(a))], 2)
    o.part(sp, DWOOD, d=0, contour=True)
    pad = blank()
    for k in range(12):
        a = k * math.pi / 6 + 0.26
        px, py = cx + (R + 1) * math.cos(a), cy + (R + 1) * math.sin(a)
        pad |= ell(round(px) - 3, round(py) - 3, round(px) + 3, round(py) + 3)
    o.part(pad, WOOD, d=1, contour=True)
    o.part(ell(cx - 5, cy - 5, cx + 5, cy + 5), STONE, d=2, contour=True)
    o.draw()
    cv.fill(ell(cx - 2, cy - 2, cx + 2, cy + 2), '#5b6470')
    # splash where the wheel meets the stream
    for (x, y) in ((140, 94), (150, 92), (176, 93), (184, 96), (168, 96), (158, 97)):
        cv.fill(ell(x, y, x + 6, y + 4), '#f1ece0')
    # sacks and a cart wheel by the door
    for (x, y) in ((60, 92), (70, 96), (52, 98), (64, 102)):
        o = cv.obj()
        o.part(poly([(x, y + 12), (x + 14, y + 12), (x + 13, y + 3), (x + 10, y), (x + 4, y), (x + 1, y + 3)]), CANVAS, d=2)
        o.draw()
        stitch_h(cv, x + 3, x + 11, y + 3, '#c9a96e')
    # path + foreground: grass bank, flowers, fence
    path = poly([(82, 100), (98, 100), (118, 135), (60, 135)])
    cv.fill(path, '#c9a96e')
    cv.fill(path & ~shift(path, -3, 0), '#9a6b3f')
    for (x, y) in ((70, 120), (92, 112), (100, 126), (80, 130)):
        cv.fill(rect(x, y, x + 2, y), '#f1ece0')
    o = cv.obj()
    for x in (6, 26, 46):
        o.part(rect(x, 96, x + 3, 120), WOOD, d=1)
    o.part(rect(2, 102, 52, 104) | rect(2, 110, 52, 112), WOOD, d=1, contour=True)
    o.draw()
    tufts(cv, [(12, 126), (40, 128), (130, 118), (146, 130), (170, 112), (226, 112), (30, 90), (210, 96)], '#2f6a3a')
    for (x, y, c) in ((18, 118, '#f5cf6a'), (34, 124, '#f1ece0'), (136, 124, '#f5cf6a'), (154, 112, '#e46a9b'), (220, 106, '#f1ece0')):
        cv.fill(rect(x, y, x + 1, y + 1), c)
    for (x, c) in ((24, '#f6b8cf'), (34, '#e46a9b'), (230, '#f6b8cf')):    # hollyhocks
        cv.fill(rect(x, 78, x, 96), '#2f6a3a')
        for y in range(78, 94, 4):
            cv.fill(ell(x - 2, y, x + 2, y + 3), c)
    # ducks on the stream and a sack-cart by the door
    for (x, y) in ((200, 112), (214, 120)):
        o = cv.obj()
        o.part(ell(x, y, x + 10, y + 6) & rect(0, 0, W, y + 4), CANVAS, d=1)
        o.part(ell(x + 6, y - 4, x + 11, y + 1), MOSS, d=0, contour=True)
        o.draw()
        cv.dots([(x + 12, y - 2), (x + 13, y - 2)], '#f08a24')
    cv.remap({'#fff3c8': '#f1ece0', '#f2e4c0': '#f1ece0', '#c9c5bc': '#f1ece0'})
    return cv


# ================================================================== INN: dusk, lit windows, hanging sign
def inn():
    cv = Canvas()
    bands(cv, [(0, '#4e3a8a'), (12, '#7a5cc0'), (26, '#c3b2ea'), (38, '#f6b8cf'), (48, '#f5cf6a')])
    for (x, y) in ((20, 14), (60, 10), (210, 16), (182, 11), (228, 24)):
        cv.dots([(x, y), (x + 1, y)], '#f5cf6a')
    # far hills + tree silhouettes in dusk violet
    h1 = wave(58, [(5, 110, 0.6), (3, 41, 2.0)])
    cv.fill(h1, '#7a5cc0')
    for (x, w) in ((8, 14), (24, 18), (198, 16), (214, 20)):
        cv.fill(ell(x, 50, x + w, 50 + w), '#7a5cc0')
    h2 = wave(72, [(3, 140, 2.4)])
    cv.fill(h2, '#4e3a8a')
    # lane
    cv.fill(rect(0, 96, W - 1, H - 1), '#4f9a45')
    lane = poly([(96, 96), (132, 96), (170, H), (60, H)])
    cv.fill(lane, '#c9a96e')
    cv.fill(lane & ~shift(lane, -3, 0), '#9a6b3f')
    # warm light spilling from the door onto the lane
    spill = poly([(104, 97), (124, 97), (138, 116), (92, 116)])
    cv.fill(spill & lane, '#f5cf6a')
    # the inn: timber frame, two floors, steep red roof, chimney with smoke
    body = rect(46, 44, 178, 100)
    o = cv.obj()
    o.part(rect(144, 14, 156, 34), BRICK, d=2)
    o.part(body, CREAM, d=3, contour=True)
    o.part(poly([(36, 46), (78, 16), (146, 16), (188, 46)]), ROOF, d=3, contour=True)
    o.draw()
    for y in range(22, 46, 5):
        cv.fill(rect(36, y, 188, y) & poly([(36, 46), (78, 16), (146, 16), (188, 46)]), '#a8241f')
    for (x, y) in ((70, 26), (94, 31), (122, 26), (150, 36), (60, 36), (108, 21)):
        cv.fill(rect(x, y + 1, x + 3, y + 1), '#e0501f')
    for (x, y, w) in ((156, 12, 8), (162, 8, 10), (172, 10, 7)):
        cv.fill(ell(x, y, x + w, y + w * 2 // 3), '#c3b2ea')
    # timbers
    tim = rect(46, 44, 178, 47) | rect(46, 70, 178, 73) | rect(46, 44, 49, 100) | rect(175, 44, 178, 100)
    for x in (80, 110, 144):
        tim |= rect(x, 44, x + 3, 100)
    tim |= line([(50, 70), (78, 48)], 3) | line([(148, 48), (174, 70)], 3)
    cv.fill(tim, '#5c3420')
    cv.fill(tim & ~shift(tim, -1, -1), '#3d2a1c')
    # glowing windows: upper three, lower two + the open door
    def window(x0, y0, x1, y1):
        o = cv.obj()
        o.part(rect(x0 - 2, y0 - 2, x1 + 2, y1 + 2), DWOOD, d=1)
        o.draw()
        cv.fill(rect(x0, y0, x1, y1), '#f5cf6a')
        cv.fill(rect(x0, y1 - 2, x1, y1) | rect(x1 - 2, y0, x1, y1), '#e8a317')
        cv.fill(rect((x0 + x1) // 2, y0, (x0 + x1) // 2, y1) | rect(x0, (y0 + y1) // 2, x1, (y0 + y1) // 2), '#7a4a1f')
        o = cv.obj(); o.part(rect(x0 - 3, y1 + 3, x1 + 3, y1 + 4), WOOD, d=0); o.draw()
    window(56, 52, 72, 64)
    window(88, 52, 102, 64)
    window(118, 52, 136, 64)
    window(152, 52, 168, 64)
    window(56, 80, 72, 92)
    window(150, 80, 168, 92)
    o = cv.obj()
    o.part(rrect(100, 76, 124, 100, 3) & rect(0, 0, W, 100), DWOOD, d=2)
    o.draw()
    cv.fill(rrect(103, 79, 121, 100, 2) & rect(0, 0, W, 100), '#f5cf6a')
    cv.fill(rect(103, 79, 106, 100) & rrect(103, 79, 121, 100, 2), '#7a4a1f')
    cv.fill(rect(112, 86, 118, 100), '#e8a317')
    # flower boxes under the lower windows
    for x0 in (54, 148):
        o = cv.obj(); o.part(rect(x0, 95, x0 + 20, 99), WOOD, d=1); o.draw()
        for k in range(5):
            cv.fill(rect(x0 + 2 + k * 4, 92, x0 + 4 + k * 4, 94), '#e46a9b' if k % 2 else '#f08a24')
    # hanging sign on an iron bracket: a mug and a pillow, no words
    o = cv.obj()
    o.part(rect(178, 54, 204, 56), DWOOD, d=0)
    o.part(line([(180, 64), (194, 56)], 2), DWOOD, d=0)
    o.draw()
    cv.fill(rect(186, 57, 186, 60) | rect(200, 57, 200, 60), '#4a2c1a')
    o = cv.obj()
    o.part(rrect(182, 60, 206, 80, 2), WOOD, d=2)
    o.draw()
    cv.fill(rrect(184, 62, 204, 78, 1), '#7a4a1f')
    o = cv.obj(outline=False)
    o.part(rect(187, 66, 195, 76), GOLD, d=1)
    o.part(rect(196, 68, 199, 73) & ~rect(197, 69, 197, 72), GOLD, d=0)
    o.draw()
    cv.fill(rect(187, 65, 195, 67), '#f1ece0')
    # lantern on a post by the lane, bench and barrels
    o = cv.obj(); o.part(rect(36, 62, 39, 108), DWOOD, d=1); o.part(rect(36, 60, 46, 62), DWOOD, d=0); o.draw()
    lantern(cv, 44, 63)
    cv.fill(ell(26, 104, 52, 110) & ~rect(0, 0, W, 105), '#2f6a3a')
    o = cv.obj()
    o.part(rect(186, 96, 222, 99), WOOD, d=1)
    o.part(rect(189, 100, 191, 108) | rect(216, 100, 218, 108), WOOD, d=0)
    o.draw()
    barrel(cv, 2, 96, 30, 122)
    barrel(cv, 204, 108, 236, H + 1)
    # hedge bushes at the corners of the foreground
    for (x, y, w) in ((-6, 116, 40), (180, 120, 30)):
        o = cv.obj(); o.part(ell(x, y, x + w, y + 30), MOSS, d=3); o.draw()
    tufts(cv, [(40, 120), (70, 104), (150, 106), (176, 116), (14, 102)], '#2f6a3a')
    cv.remap({'#fff3c8': '#f2e4c0', '#c9c5bc': '#f2e4c0', '#f1ece0': '#f2e4c0'})
    return cv


# ================================================================== SHRINE: misty pines, mossy stones and a bell
def shrine():
    cv = Canvas()
    bands(cv, [(0, '#a4c8b0'), (20, '#c4dcc0'), (44, '#dfe9d0')])
    # far pines in two layers of mist
    for x in range(-6, W + 10, 13):
        pine(cv, x, 78 + (x * 7) % 9, 16, 50 + (x * 13) % 14, flat='#a4c8b0')
    for x in range(2, W + 10, 19):
        pine(cv, x, 92 + (x * 5) % 7, 20, 58 + (x * 11) % 12, flat='#7ab58a')
    cv.fill(rect(0, 92, W - 1, H - 1), '#4f9a45')
    # gravel path climbing to the shrine
    path = poly([(104, 92), (136, 92), (164, H), (76, H)])
    cv.fill(path, '#c9c5bc')
    for (x, y) in ((100, 104), (128, 100), (114, 116), (138, 120), (92, 126), (148, 130), (120, 108), (106, 128)):
        cv.fill(rect(x, y, x + 1, y), '#8b8f96')
    # stone steps
    for i, y in enumerate((84, 89, 94)):
        o = cv.obj()
        o.part(rect(94 - i * 4, y, 146 + i * 4, y + 4), STONE, d=1)
        o.draw()
        cv.fill(rect(94 - i * 4, y, 146 + i * 4, y) & ~rect(110, 0, 132, H), '#7ab55c')
    # the shrine: stone plinth, wooden house with a moss blanket over its roof
    o = cv.obj()
    o.part(rect(98, 70, 142, 84), STONE, d=2)
    o.part(rect(104, 42, 136, 70), ramp('#d6322b', '#a8241f', '#e0501f'), d=2, contour=True)
    roof = poly([(90, 46), (104, 26), (136, 26), (150, 46)])
    o.part(roof, DWOOD, d=2, contour=True)
    moss = poly([(92, 42), (104, 24), (136, 24), (148, 42)]) | ell(88, 38, 102, 48) | ell(138, 38, 152, 48) | ell(112, 18, 128, 30)
    o.part(moss, MOSS, d=2, contour=True)
    o.draw()
    for (x, y, h) in ((96, 46, 4), (108, 44, 3), (124, 44, 5), (142, 46, 3)):     # moss drips
        cv.fill(rect(x, y, x + 1, y + h), '#4f9a45')
    cv.fill(rect(110, 48, 130, 70), '#3d2a1c')
    cv.fill(rect(112, 50, 128, 70) & ~rect(114, 52, 126, 70), '#5c3420')
    o = cv.obj(); o.part(ell(114, 54, 126, 66), STONE, d=2); o.part(rrect(116, 62, 124, 70, 1), STONE, d=1, contour=True); o.draw()
    cv.fill(rect(119, 57, 121, 59), '#f5cf6a')
    for (x, y) in ((100, 74), (118, 76), (134, 73), (108, 80)):
        cv.fill(rect(x, y, x + 4, y), '#5b6470')
    for (x, y) in ((96, 28), (116, 22), (140, 32), (104, 36)):
        cv.dots([(x, y), (x + 1, y)], '#a4b86a')
    # the bell in its frame (left)
    o = cv.obj()
    o.part(rect(40, 32, 43, 96) | rect(76, 32, 79, 96), DWOOD, d=1)
    o.part(rect(34, 28, 86, 32), DWOOD, d=1, contour=True)
    o.draw()
    cv.fill(rect(60, 33, 60, 38), '#4a2c1a')
    o = cv.obj()
    o.part(rrect(55, 38, 65, 42, 1) | poly([(54, 42), (66, 42), (70, 60), (50, 60)]), ramp('#b07a10', '#7a4a1f', '#e8a317'), d=2)
    o.part(rect(48, 59, 72, 62), ramp('#b07a10', '#7a4a1f', '#e8a317'), d=1, contour=True)
    o.draw()
    cv.fill(rect(54, 49, 66, 50) & poly([(54, 42), (66, 42), (70, 60), (50, 60)]), '#7a4a1f')
    cv.fill(rect(60, 63, 60, 82), '#e46a9b')
    cv.fill(rect(59, 82, 61, 86), '#d6322b')
    # stone lanterns either side of the steps
    for x in (78, 154):
        o = cv.obj()
        o.part(rect(x + 3, 70, x + 9, 96), STONE, d=1)
        o.part(rect(x, 62, x + 12, 72), STONE, d=2, contour=True)
        o.part(poly([(x - 3, 62), (x + 6, 54), (x + 15, 62)]), STONE, d=2, contour=True)
        o.part(rect(x - 1, 94, x + 13, 98), STONE, d=1, contour=True)
        o.draw()
        cv.fill(rect(x + 4, 65, x + 8, 69), '#f5cf6a')
        cv.fill(poly([(x - 2, 62), (x + 6, 56), (x + 14, 62)]) & ~shift(poly([(x - 2, 62), (x + 6, 56), (x + 14, 62)]), 0, -2), '#7ab55c')
    # stacked cairns of mossy stones (right) and big moss boulders
    for (x, y, w, h) in ((186, 90, 30, 14), (190, 78, 22, 12), (194, 68, 14, 10), (198, 61, 8, 7)):
        rock(cv, x, y, x + w, y + h, moss=MOSS, d=2)
    rock(cv, 168, 100, 232, 128, moss=MOSS)
    rock(cv, -8, 102, 50, 132, moss=MOSS)
    rock(cv, 216, 112, 248, 134, moss=MOSS, d=2)
    # near pine trunks framing the scene
    for (x, w) in ((4, 8), (226, 8)):
        o = cv.obj(); o.part(rect(x, 0, x + w, 100), DWOOD, d=2); o.draw()
        cv.fill(rect(x + 2, 20, x + 2, 60) | rect(x + 5, 50, x + 5, 90), '#5c3420')
    o = cv.obj()
    o.part(ell(-20, -14, 36, 22), PINE, d=3)
    o.part(ell(204, -16, 260, 20), PINE, d=3)
    o.draw()
    tufts(cv, [(60, 110), (170, 96), (66, 124), (180, 130), (24, 98)], '#2f6a3a')
    # offerings on the plinth, red ribbons on the bell frame, mushrooms in the moss
    for (x, c) in ((104, '#e8a317'), (132, '#e8a317')):
        o = cv.obj(); o.part(rect(x, 80, x + 4, 83), ramp(c, '#b07a10', '#f5cf6a'), d=0); o.draw()
    cv.fill(rect(36, 33, 38, 44) | rect(81, 33, 83, 44), '#d6322b')
    cv.fill(rect(37, 44, 37, 46) | rect(82, 44, 82, 46), '#a8241f')
    for (x, y) in ((60, 102), (66, 104), (176, 98), (210, 100)):
        o = cv.obj(); o.part(rect(x + 2, y + 3, x + 3, y + 6), CANVAS, d=0); o.part(ell(x, y, x + 5, y + 4) & rect(0, 0, W, y + 3), PETAL, d=1, contour=True); o.draw()
        cv.dots([(x + 2, y + 1)], '#f1ece0')
    cv.remap({'#fff3c8': '#dfe9d0', '#c9c5bc': '#dfe9d0', '#9a6b3f': '#7a4a1f'})
    return cv


# ================================================================== JETTY: planks over open water, early light
def jetty():
    cv = Canvas()
    bands(cv, [(0, '#a9d6ea'), (14, '#cde6e8'), (28, '#f1ece0'), (40, '#f6d9b0')])
    cv.fill(ell(30, 30, 50, 50) & rect(0, 0, W, 44), '#f5cf6a')
    cloud(cv, 150, 12, 44, '#f1ece0', '#cde6e8')
    # headland with a far cottage on the left
    hd = wave(36, [(4, 60, 0.0)], 0, 70, 46) | poly([(60, 38), (100, 46), (60, 46)])
    cv.fill(hd, '#7ab58a')
    cv.fill(rect(16, 30, 26, 38), '#f1ece0')
    cv.fill(poly([(14, 31), (21, 25), (28, 31)]), '#d9875a')
    # sea: banded, ripples, sun path
    sea = rect(0, 46, W - 1, H - 1)
    bands(cv, [(46, '#a9d6ea'), (54, '#7fbcd8'), (70, '#3f8fb0'), (100, '#25637d')])
    for y in range(48, 70, 3):
        cv.fill(rect(32 - (y - 46) // 2, y, 48 + (y - 46) // 2, y), '#f5cf6a')
    ripples(cv, rect(0, 72, W - 1, H - 1), '#7fbcd8', step=6, ln=6, seed=1)
    ripples(cv, rect(0, 50, W - 1, 68), '#cde6e8', step=4, ln=3, seed=4)
    # a little sail far out
    o = cv.obj(outline=False)
    o.part(poly([(196, 40), (196, 54), (186, 54)]), ramp('#f1ece0', None), d=0)
    o.part(rect(184, 55, 202, 57), ramp('#7a4a1f', None), d=0)
    o.draw()
    # the jetty: planks running from the near left out to the right, posts down into the water
    deck = poly([(-4, 102), (176, 74), (196, 76), (40, 120), (-4, 122)])
    posts = []
    for i in range(7):
        t = i / 6
        x = round(-2 + t * 186)
        y = round(116 - t * 40)
        hgt = round(26 - t * 14)
        wd = max(3, round(7 - t * 4))
        posts.append((x, y, hgt, wd))
    o = cv.obj()
    for (x, y, hgt, wd) in posts:
        o.part(rect(x, y - hgt // 2, x + wd, y + hgt // 2 + 6), DWOOD, d=1)
    o.draw()
    o = cv.obj()
    o.part(deck, WOOD, d=2)
    o.part(poly([(-4, 122), (40, 120), (196, 76), (196, 79), (40, 126), (-4, 128)]), DWOOD, d=0, contour=True)
    o.draw()
    for k in range(1, 30):                                            # plank seams across the deck
        t = k / 30
        xa, ya = -4 + t * 180, 102 - t * 28
        xb, yb = 40 + t * 156, 120 - t * 44
        cv.fill(line([(round(xa), round(ya)), (round(xb), round(yb))]) & deck, '#7a4a1f')
    for (x, y, hgt, wd) in posts[1::2]:                              # posts poking above the deck, a bucket at each
        o = cv.obj(); o.part(rect(x + 30, y - 20, x + 30 + wd, y - 6), DWOOD, d=1); o.draw()
    for i, (x, y, hgt, wd) in enumerate(posts[:5]):
        bx, by = x + 14 + i * 4, y - 14 - i
        s = max(5, 10 - i)
        o = cv.obj()
        o.part(poly([(bx, by), (bx + s, by), (bx + s - 1, by + s), (bx + 1, by + s)]), STONE, d=1)
        o.draw()
        cv.fill(rect(bx + 1, by, bx + s - 1, by + 1), '#25637d')
    # rods leaning out over the water with lines
    for (x0, y0, x1, y1) in ((60, 98, 104, 54), (120, 86, 160, 50)):
        o = cv.obj(); o.part(line([(x0, y0), (x1, y1)], 2), WOOD, d=0); o.draw()
        cv.fill(line([(x1, y1), (x1 + 6, y1 + 40)]), '#f1ece0')
        cv.fill(rect(x1 + 5, y1 + 40, x1 + 7, y1 + 41), '#d6322b')
    # rowboat moored on the right
    o = cv.obj()
    hull = poly([(178, 98), (236, 98), (228, 112), (186, 112)])
    o.part(hull, ramp('#d6322b', '#a8241f', '#e0501f'), d=3)
    o.part(rect(176, 96, 238, 99), WOOD, d=1, contour=True)
    o.draw()
    cv.fill(rect(186, 104, 228, 105) & hull, '#f1ece0')
    cv.fill(line([(176, 97), (164, 84)]), '#c9a96e')
    o = cv.obj(); o.part(line([(196, 94), (222, 86)], 2), WOOD, d=0); o.draw()
    cv.fill(ell(174, 110, 242, 118) & ~hull, '#25637d')
    # net heap and a crate on the near deck, gulls
    o = cv.obj()
    o.part(ell(10, 96, 40, 112) & rect(0, 0, W, 108), ramp('#a4b86a', '#4f9a45', '#f5cf6a'), d=2)
    o.draw()
    for x in range(12, 40, 4):
        cv.fill(line([(x, 100), (x + 3, 107)]) & ell(10, 96, 40, 112), '#4f9a45')
    for (x, y) in ((18, 98), (30, 100)):
        cv.fill(ell(x, y, x + 3, y + 3), '#e8a317')
    for (x, y) in ((96, 24), (112, 18), (220, 30)):
        cv.fill(line([(x, y + 2), (x + 3, y), (x + 5, y + 2), (x + 8, y), (x + 10, y + 2)]), '#5b6470')
    # a red and cream buoy, a fish in the near bucket, foam round the posts
    o = cv.obj()
    o.part(ell(140, 92, 152, 104) & rect(0, 0, W, 100), ramp('#d6322b', '#a8241f', '#f08a24'), d=2)
    o.part(rect(140, 96, 152, 97) & ell(140, 92, 152, 104), CANVAS, d=0)
    o.draw()
    for (x, y, hgt, wd) in posts[2:]:
        cv.fill(rect(x - 2, y + hgt // 2 + 6, x + wd + 2, y + hgt // 2 + 6), '#f1ece0')
    o = cv.obj(outline=False); o.part(ell(17, 98, 25, 102), ramp('#8b8f96', '#5b6470', '#c9c5bc'), d=1); o.draw()
    cv.remap({'#fff3c8': '#f1ece0', '#f2e4c0': '#f1ece0'})
    return cv


# ================================================================== HERB CROFT: raised beds, drying racks, skep
def herb():
    cv = Canvas()
    bands(cv, [(0, '#a9d6ea'), (20, '#cde6e8'), (36, '#e6efd8')])
    cloud(cv, 100, 10, 36, '#f1ece0', '#cde6e8')
    hills = wave(46, [(5, 140, 1.7), (2, 50, 0.2)])
    cv.fill(hills, '#a4b86a')
    for (x, w) in ((150, 18), (166, 22), (186, 16), (208, 24), (226, 18)):
        cv.fill(ell(x, 34, x + w, 34 + w), '#7ab55c')
    cv.fill(rect(0, 60, W - 1, H - 1), '#7ab55c')
    # the croft cottage, back left: whitewash, thatch, round window, smoke
    o = cv.obj()
    o.part(rect(14, 40, 70, 74), CREAM, d=3)
    o.part(poly([(6, 44), (24, 18), (60, 18), (78, 44)]) | ell(4, 36, 80, 50) & rect(0, 0, W, 46), THATCH, d=3, contour=True)
    o.part(rect(56, 12, 63, 22), STONE, d=1)
    o.draw()
    for y in (24, 30, 36, 42):
        cv.fill(rect(10, y, 74, y) & poly([(6, 44), (24, 18), (60, 18), (78, 44)]), '#b07a10')
    cv.fill(ell(56, 4, 64, 10) | ell(60, 0, 68, 6), '#f1ece0')
    o = cv.obj(); o.part(rect(24, 54, 36, 74), ramp('#4f9a45', '#2f6a3a', '#7ab55c'), d=1); o.draw()
    o = cv.obj(); o.part(ell(46, 50, 60, 64), DWOOD, d=1); o.draw()
    cv.fill(ell(48, 52, 58, 62), '#f5cf6a')
    cv.fill(rect(53, 52, 53, 62) | rect(48, 57, 58, 57), '#7a4a1f')
    # wattle fence along the back
    fen = rect(80, 58, W - 1, 70)
    o = cv.obj()
    o.part(fen, ramp('#9a6b3f', '#7a4a1f', '#c9a96e'), d=1)
    o.draw()
    for y in (61, 65):
        for x in range(80, W, 6):
            cv.fill(rect(x + (y % 2) * 3, y, x + 2 + (y % 2) * 3, y + 1), '#7a4a1f')
    for x in range(84, W, 16):
        o = cv.obj(); o.part(rect(x, 54, x + 2, 72), DWOOD, d=0); o.draw()
    # hollyhocks against the fence
    for (x, c) in ((90, '#e46a9b'), (100, '#f6b8cf'), (230, '#e46a9b')):
        cv.fill(rect(x, 40, x, 60), '#2f6a3a')
        for y in range(40, 58, 4):
            cv.fill(ell(x - 2, y, x + 2, y + 3), c)
    # drying rack (right): A-frames, two poles, hanging bundles
    o = cv.obj()
    o.part(line([(150, 100), (160, 30)], 3) | line([(170, 100), (160, 30)], 3), WOOD, d=0)
    o.part(line([(212, 100), (222, 30)], 3) | line([(232, 100), (222, 30)], 3), WOOD, d=0)
    o.part(rect(152, 34, 230, 36) | rect(154, 58, 228, 60), WOOD, d=1, contour=True)
    o.draw()
    bundles = [(166, 36, MOSS), (178, 36, DUSK), (190, 36, LEAF), (202, 36, GOLD), (214, 36, MOSS),
               (170, 60, DUSK), (184, 60, LEAF), (198, 60, ramp('#f1ece0', '#c9a96e', '#fff3c8'))]
    for (x, y, rp) in bundles:
        cv.fill(rect(x + 3, y + 1, x + 3, y + 3), '#4a2c1a')
        o = cv.obj()
        o.part(poly([(x, y + 4), (x + 7, y + 4), (x + 10, y + 18), (x - 3, y + 18)]), rp, d=2)
        o.part(rect(x + 1, y + 3, x + 6, y + 5), BURLAP, d=0, contour=True)
        o.draw()
        cv.fill(line([(x + 3, y + 7), (x + 2, y + 17)]) | line([(x + 6, y + 8), (x + 7, y + 17)]), rp['s'])
    # bee skep on a stump (far right), bees
    o = cv.obj()
    o.part(rect(218, 86, 236, 100), WOOD, d=2)
    o.part(ell(214, 62, 240, 92) & rect(0, 0, W, 87), THATCH, d=3, contour=True)
    o.draw()
    for y in (68, 74, 80):
        cv.fill(rect(214, y, 240, y) & ell(214, 62, 240, 92), '#b07a10')
    cv.fill(rect(225, 82, 229, 86), '#3d2a1c')
    for (x, y) in ((206, 68), (200, 78), (210, 56)):
        cv.fill(rect(x, y, x + 2, y + 1), '#e8a317')
        cv.dots([(x + 1, y)], '#3d2a1c')
    # raised beds: three wooden frames in perspective, rows of herbs
    beds = [((4, 84), (74, 84), (78, 104), (0, 104), 'lav'), ((86, 84), (150, 84), (156, 104), (82, 104), 'sage'),
            ((-4, 110), (96, 110), (100, 134), (-8, 134), 'cham'), ((112, 110), (244, 110), (248, 134), (110, 134), 'mint')]
    for (a, b, c, d, kind) in beds:
        top = poly([a, b, c, d])
        o = cv.obj()
        o.part(top, ramp('#7a4a1f', '#5c3420', '#9a6b3f'), d=0)
        o.part(poly([d, c, (c[0], c[1] + 4), (d[0], d[1] + 4)]), WOOD, d=0, contour=True)
        o.draw()
        cv.fill(poly([(a[0] + 2, a[1] + 2), (b[0] - 2, b[1] + 2), (c[0] - 3, c[1] - 1), (d[0] + 3, d[1] - 1)]), '#5c3420')
        yy = range(a[1] + 1, d[1] - 4, 7)
        for y in yy:
            for x in range(a[0] + 4 - (y - a[1]) // 5, b[0] - 4 + (y - a[1]) // 5, 9):
                if kind == 'lav':
                    o = cv.obj(outline=False); o.part(ell(x, y, x + 7, y + 7), LEAF, d=1); o.draw()
                    cv.fill(rect(x + 1, y - 3, x + 2, y + 1) | rect(x + 5, y - 2, x + 6, y + 1), '#7a5cc0')
                    cv.dots([(x + 1, y - 3), (x + 5, y - 2)], '#c3b2ea')
                elif kind == 'sage':
                    o = cv.obj(outline=False); o.part(ell(x, y, x + 8, y + 7), ramp('#a4b86a', '#7ab55c', '#f1ece0'), d=1); o.draw()
                elif kind == 'cham':
                    o = cv.obj(outline=False); o.part(ell(x, y, x + 8, y + 7), MOSS, d=1); o.draw()
                    for (fx, fy) in ((1, 1), (5, 0), (3, 4)):
                        cv.fill(rect(x + fx, y + fy, x + fx + 1, y + fy + 1), '#f1ece0')
                        cv.dots([(x + fx + 1, y + fy + 1)], '#e8a317')
                else:
                    o = cv.obj(outline=False); o.part(ell(x, y, x + 8, y + 8), ramp('#4f9a45', '#2f6a3a', '#a4b86a'), d=2); o.draw()
    # basket and a trowel on the path between the beds
    o = cv.obj()
    o.part(ell(96, 98, 112, 108) & rect(0, 0, W, 104) | poly([(96, 104), (112, 104), (110, 112), (98, 112)]), BURLAP, d=2)
    o.draw()
    cv.fill(ell(98, 100, 110, 106), '#7a5cc0')
    # calendula and poppies in the path edges, a watering can
    for (x, y, c) in ((80, 98, '#f08a24'), (84, 104, '#d6322b'), (106, 116, '#f08a24'), (102, 124, '#d6322b'), (160, 100, '#f08a24')):
        cv.fill(rect(x, y, x + 1, y + 1), c)
        cv.dots([(x, y + 2)], '#2f6a3a')
    o = cv.obj()
    o.part(rrect(160, 112, 178, 124, 2), COPPER, d=2)
    o.part(line([(178, 116), (186, 108)], 2), COPPER, d=0)
    o.part(line([(162, 112), (169, 106), (176, 112)], 1), COPPER, d=0)
    o.draw()
    cv.remap({'#fff3c8': '#f1ece0', '#f2e4c0': '#f1ece0', '#c9c5bc': '#f1ece0', '#f6b8cf': '#f1ece0', '#c3b2ea': '#f1ece0'})
    return cv


# ================================================================== WORKSHOP: barn with forge glow, tools, sparks
def workshop():
    cv = Canvas()
    bands(cv, [(0, '#e0b27a'), (16, '#ebc890'), (32, '#f5dfae')])
    # mesas / dry hills
    m1 = wave(44, [(3, 50, 0.3)], 120, W - 1) & ~rect(0, 0, 150, H)
    cv.fill(m1 | poly([(150, 60), (156, 44), (240, 44), (240, 60)]), '#d9a070')
    m2 = poly([(-2, 60), (8, 38), (40, 38), (52, 60)])
    cv.fill(m2, '#d9a070')
    cv.fill(wave(62, [(3, 90, 1.2)]), '#c9a96e')
    cv.fill(rect(0, 92, W - 1, H - 1), '#c9a96e')
    cv.fill(wave(100, [(2, 60, 0.4)]), '#9a6b3f')
    # the barn
    body = rect(56, 40, 184, 104)
    o = cv.obj()
    o.part(body, ramp('#a8241f', '#7a2a20', '#d6322b'), d=3)
    o.part(poly([(46, 44), (90, 12), (150, 12), (194, 44)]), ramp('#5b6470', '#3d2a1c', '#8b8f96'), d=2, contour=True)
    o.part(rect(140, 8, 150, 26), BRICK, d=2)
    o.draw()
    for x in range(60, 184, 8):
        cv.fill(rect(x, 44, x, 104), '#7a2a20')
    for y in range(18, 44, 6):
        cv.fill(rect(46, y, 194, y) & poly([(46, 44), (90, 12), (150, 12), (194, 44)]), '#3d2a1c')
    # gable window with a gear in it
    o = cv.obj(); o.part(ell(108, 18, 132, 40), CREAM, d=2); o.draw()
    cv.fill(ell(111, 21, 129, 37), '#3d2a1c')
    o = cv.obj(outline=False)
    g = ell(113, 23, 127, 35)
    for k in range(8):
        a = k * math.pi / 4
        g |= rect(round(120 + 7 * math.cos(a)) - 1, round(29 + 7 * math.sin(a)) - 1, round(120 + 7 * math.cos(a)) + 1, round(29 + 7 * math.sin(a)) + 1)
    o.part(g & ~ell(117, 26, 123, 32), GOLD, d=1)
    o.draw()
    # open doors: warm interior, forge, anvil silhouette, tools on the wall
    door = rect(84, 52, 156, 104)
    cv.fill(door, '#5c3420')
    cv.fill(rect(84, 52, 156, 56), '#3d2a1c')
    o = cv.obj()
    o.part(rect(72, 50, 84, 104), WOOD, d=2)
    o.part(rect(156, 50, 168, 104), WOOD, d=2)
    o.part(rect(80, 46, 160, 51), DWOOD, d=1, contour=True)
    o.draw()
    for (x0, x1) in ((72, 84), (156, 168)):
        cv.fill(line([(x0 + 1, 54), (x1 - 1, 100)], 2) | rect(x0, 76, x1, 77), '#7a4a1f')
    o = cv.obj()                                                       # forge
    o.part(rect(126, 62, 152, 98), BRICK, d=2)
    o.part(rect(130, 54, 148, 62), STONE, d=1, contour=True)
    o.draw()
    cv.fill(rrect(132, 72, 146, 86, 2), '#f08a24')
    cv.fill(rrect(135, 76, 143, 86, 1), '#f5cf6a')
    glow = ell(108, 64, 168, 112) & door & ~rect(126, 54, 152, 98)
    cv.fill(glow, '#7a4a1f')
    for (x, y) in ((92, 60), (100, 60), (108, 60), (116, 60)):
        cv.fill(rect(x, 58, x, 62), '#3d2a1c')
    o = cv.obj(outline=False)                                           # hanging tools: tongs, saw, hammer
    o.part(line([(92, 62), (90, 78)], 2) | line([(92, 62), (95, 78)], 2), STONE, d=0)
    o.part(rect(98, 62, 100, 80) | rect(96, 62, 104, 66), STONE, d=0)
    o.part(poly([(106, 62), (118, 62), (118, 76), (106, 72)]), STONE, d=0)
    o.draw()
    # anvil out front, sparks flying
    o = cv.obj()
    o.part(rect(108, 102, 120, 114), ramp('#5b6470', '#3d2a1c', '#8b8f96'), d=1)
    o.part(poly([(96, 92), (130, 92), (126, 100), (100, 100), (92, 95)]) | rect(104, 99, 124, 102), ramp('#8b8f96', '#5b6470', '#c9c5bc'), d=2, contour=True)
    o.part(rect(102, 114, 126, 118), WOOD, d=1, contour=True)
    o.draw()
    o = cv.obj(); o.part(line([(118, 90), (130, 78)], 3), WOOD, d=0); o.part(rect(126, 74, 134, 80), STONE, d=1, contour=True); o.draw()
    for (x, y, c) in ((110, 84, '#f5cf6a'), (104, 80, '#f08a24'), (98, 86, '#f5cf6a'), (116, 76, '#f08a24'), (92, 82, '#f5cf6a'),
                      (122, 70, '#f5cf6a'), (100, 72, '#f08a24'), (88, 90, '#f08a24'), (108, 68, '#f5cf6a')):
        cv.fill(rect(x, y, x + 1, y + 1), c)
    # cart wheel against the wall, plank stack, sawhorse
    cx, cy, R = 44, 92, 18
    o = cv.obj()
    o.part(ell(cx - R, cy - R, cx + R, cy + R) & ~ell(cx - R + 4, cy - R + 4, cx + R - 4, cy + R - 4), WOOD, d=2)
    sp = blank()
    for k in range(4):
        a = k * math.pi / 4
        sp |= line([(cx - (R - 3) * math.cos(a), cy - (R - 3) * math.sin(a)), (cx + (R - 3) * math.cos(a), cy + (R - 3) * math.sin(a))], 2)
    o.part(sp, DWOOD, d=0, contour=True)
    o.part(ell(cx - 4, cy - 4, cx + 4, cy + 4), STONE, d=1, contour=True)
    o.draw()
    for i in range(4):
        o = cv.obj()
        o.part(rect(186 + i * 2, 100 - i * 6, 238, 105 - i * 6), WOOD if i % 2 else ramp('#c9a96e', '#9a6b3f', '#f2e4c0'), d=1)
        o.draw()
    o = cv.obj()                                                       # sawhorse with a plank and a saw
    o.part(line([(184, 128), (194, 108)], 3) | line([(204, 128), (194, 108)], 3), DWOOD, d=0)
    o.part(line([(214, 128), (224, 108)], 3) | line([(234, 128), (224, 108)], 3), DWOOD, d=0)
    o.part(rect(176, 105, 240, 110), ramp('#c9a96e', '#9a6b3f', '#f2e4c0'), d=1, contour=True)
    o.draw()
    o = cv.obj()
    o.part(poly([(204, 92), (226, 92), (226, 104), (210, 104)]), STONE, d=1)
    o.part(rrect(196, 90, 206, 98, 1), EMBER, d=1, contour=True)
    o.draw()
    for x in range(212, 226, 3):
        cv.dots([(x, 104)], '#5b6470')
    # toolbox and a coil of rope in the foreground left
    o = cv.obj()
    o.part(rect(6, 112, 40, 130), ramp('#3f8fb0', '#25637d', '#a9d6ea'), d=2)
    o.part(rect(16, 106, 30, 109) | rect(16, 106, 18, 112) | rect(28, 106, 30, 112), STONE, d=0, contour=True)
    o.draw()
    cv.fill(rect(6, 118, 40, 118), '#25637d')
    o = cv.obj(); o.part(ell(48, 114, 76, 130), BURLAP, d=2); o.draw()
    for r in (4, 8):
        cv.fill(ell(62 - r, 122 - r // 2, 62 + r, 122 + r // 2) & ~ell(63 - r, 123 - r // 2, 61 + r, 121 + r // 2), '#9a6b3f')
    for (x, y) in ((140, 120), (156, 126), (82, 122), (170, 116)):
        cv.fill(rect(x, y, x + 3, y), '#9a6b3f')
    # copper pipes and a water butt on the barn wall, a weathervane, a bottle of oil
    o = cv.obj()
    o.part(rect(186, 52, 189, 96) | rect(170, 52, 189, 55), COPPER, d=1)
    o.draw()
    o = cv.obj()
    o.part(rrect(186, 70, 200, 98, 2), ramp('#3f8fb0', '#25637d', '#a9d6ea'), d=2)
    o.part(rect(185, 74, 201, 75) | rect(185, 92, 201, 93), STONE, d=0, contour=True)
    o.draw()
    cv.fill(rect(120, 2, 120, 12) | rect(114, 6, 126, 6), '#3d2a1c')
    cv.fill(poly([(120, 8), (130, 10), (120, 12)]), '#b07a10')
    o = cv.obj(); o.part(rrect(160, 116, 166, 128, 1), MOSS, d=1); o.part(rect(162, 112, 164, 116), CANVAS, d=0, contour=True); o.draw()
    cv.remap({'#fff3c8': '#f2e4c0', '#c9c5bc': '#f2e4c0', '#e0501f': '#d6322b', '#a9d6ea': '#f2e4c0'})
    return cv


# ================================================================== ORCHARD: rows of fruit trees, ladders, baskets
def orchard():
    cv = Canvas()
    bands(cv, [(0, '#7fbcd8'), (10, '#a9d6ea'), (20, '#cde6e8'), (30, '#f6d9b0'), (40, '#f5cf6a')])
    cv.fill(rect(0, 50, W - 1, H - 1), '#a4b86a')
    cv.fill(rect(0, 66, W - 1, H - 1), '#7ab55c')
    # back row: small hazy trees
    for x in range(-6, W, 22):
        cv.fill(ell(x, 34, x + 18, 52), '#7ab55c')
        cv.fill(rect(x + 8, 52, x + 9, 58), '#9a6b3f')
        cv.dots([(x + 5, 42), (x + 12, 46)], '#e46a9b')
    # middle row
    for x in (2, 46, 150, 196):
        tree(cv, x, 32, 34, 30, LEAF, th=8, fruit='#d6322b')
    # a cream tent between the rows
    o = cv.obj()
    o.part(poly([(84, 82), (112, 44), (140, 82)]), CANVAS, d=3)
    o.part(rect(110, 40, 113, 46), WOOD, d=0)
    o.draw()
    cv.fill(poly([(106, 82), (112, 60), (118, 82)]), '#7a4a1f')
    cv.fill(line([(112, 44), (112, 82)]) & ~poly([(106, 82), (112, 60), (118, 82)]), '#c9a96e')
    o = cv.obj(outline=False); o.part(rect(110, 32, 111, 40) | poly([(112, 32), (120, 35), (112, 38)]), ramp('#d6322b', None), d=0); o.draw()
    # front row: big apple and pear trees
    tree(cv, -16, 6, 64, 62, LEAF, th=26, fruit='#d6322b', fcol2='#e8a317')
    tree(cv, 172, 4, 70, 64, LEAF, th=28, fruit='#d6322b', fcol2='#d6322b')
    for (x, y) in ((22, 26), (196, 22), (214, 44), (8, 46)):
        o = cv.obj(); o.part(ell(x, y, x + 6, y + 6), EMBER, d=1); o.draw()
        cv.dots([(x + 3, y - 1)], '#7a4a1f')
    # ladders against the front trees
    for (xb, yb, xt, yt) in ((48, 112, 34, 40), (178, 114, 196, 36)):
        o = cv.obj()
        o.part(line([(xb, yb), (xt, yt)], 2) | line([(xb + 10, yb), (xt + 8, yt)], 2), WOOD, d=0)
        rungs = blank()
        for k in range(1, 9):
            t = k / 9
            rungs |= line([(round(xb + (xt - xb) * t), round(yb + (yt - yb) * t)), (round(xb + 10 + (xt + 8 - xb - 10) * t), round(yb + (yt - yb) * t))], 1)
        o.part(rungs, WOOD, d=0)
        o.draw()
    # cider press (centre right)
    o = cv.obj()
    o.part(rect(146, 70, 150, 104) | rect(170, 70, 174, 104), DWOOD, d=1)
    o.part(rect(142, 66, 178, 71), DWOOD, d=1, contour=True)
    o.part(rect(158, 60, 162, 84), STONE, d=0)
    o.part(rect(148, 84, 172, 102), WOOD, d=2, contour=True)
    o.part(rect(144, 102, 176, 106), DWOOD, d=1, contour=True)
    o.draw()
    for x in (152, 158, 164, 170):
        cv.fill(rect(x, 86, x, 101), '#7a4a1f')
    o = cv.obj(); o.part(rect(150, 58, 170, 60), STONE, d=0); o.draw()
    o = cv.obj()                                                       # cider jug by the press
    o.part(rrect(128, 96, 142, 110, 3), ramp('#c9a96e', '#9a6b3f', '#f2e4c0'), d=2)
    o.part(rect(132, 92, 137, 96), ramp('#c9a96e', '#9a6b3f', '#f2e4c0'), d=0, contour=True)
    o.part(rect(141, 99, 144, 105) & ~rect(142, 100, 142, 104), ramp('#c9a96e', '#9a6b3f', '#f2e4c0'), d=0)
    o.draw()
    cv.fill(rect(128, 101, 142, 102) & rrect(128, 96, 142, 110, 3), '#7a4a1f')
    # baskets of apples on the grass
    for (x, y, rp) in ((60, 104, EMBER), (84, 110, GOLD), (110, 106, EMBER), (198, 116, EMBER)):
        o = cv.obj()
        o.part(poly([(x, y), (x + 22, y), (x + 19, y + 14), (x + 3, y + 14)]), BURLAP, d=2)
        o.draw()
        for yy in (y + 5, y + 9):
            cv.fill(rect(x + 2, yy, x + 20, yy) & poly([(x, y), (x + 22, y), (x + 19, y + 14), (x + 3, y + 14)]), '#9a6b3f')
        for (dx, dy) in ((1, -5), (6, -6), (11, -5), (16, -4), (4, -2), (13, -2)):
            o = cv.obj(outline=False); o.part(ell(x + dx, y + dy, x + dx + 5, y + dy + 5), rp, d=1); o.draw()
    # windfalls and grass
    for (x, y) in ((30, 120), (140, 118), (226, 104), (96, 126), (160, 128)):
        cv.fill(rect(x, y, x + 2, y + 2), '#d6322b')
    tufts(cv, [(20, 112), (74, 126), (128, 122), (186, 128), (232, 122), (100, 96), (60, 90)], '#4f9a45')
    # blossom-dotted grass and a far hazy hill line
    for (x, y, c) in ((16, 96, '#f6b8cf'), (70, 92, '#f1ece0'), (124, 94, '#f6b8cf'), (176, 100, '#f1ece0'), (226, 96, '#f6b8cf'),
                      (40, 126, '#f1ece0'), (148, 124, '#f6b8cf'), (210, 128, '#f1ece0')):
        cv.fill(rect(x, y, x + 1, y + 1), c)
        cv.dots([(x + 2, y + 1)], '#2f6a3a')
    cv.fill(rect(0, 128, W - 1, H - 1), '#4f9a45')
    for (x, y) in ((96, 18), (104, 14), (226, 30)):
        cv.fill(line([(x, y + 2), (x + 2, y), (x + 4, y + 2), (x + 6, y), (x + 8, y + 2)]), '#4e3a8a')
    cv.remap({'#fff3c8': '#f2e4c0', '#c9c5bc': '#f2e4c0', '#e0501f': '#d6322b'})
    return cv


# ================================================================== FERRY: broad misty river, landing, flat boat on a rope
def ferry():
    cv = Canvas()
    bands(cv, [(0, '#c3b2ea'), (14, '#d9d4ee'), (30, '#e6efe6')])
    cv.fill(ell(150, 16, 166, 32), '#f1ece0')
    # far bank: hazy trees of mixed sizes, reeds, a little hut and the far rope post
    for (x, w) in ((-6, 22), (12, 14), (24, 26), (48, 16), (62, 20), (80, 12), (90, 24), (112, 18), (128, 14), (140, 26),
                   (164, 16), (178, 22), (198, 14), (210, 24), (230, 18)):
        cv.fill(ell(x, 50 - w * 2 // 3, x + w, 54 + w // 4), '#a4b8a8')
    cv.fill(rect(0, 48, W - 1, 54), '#a4b8a8')
    cv.fill(rect(0, 51, W - 1, 55), '#7a9a7a')
    cv.fill(rect(40, 38, 52, 50), '#c9b48e')
    cv.fill(poly([(38, 39), (46, 32), (54, 39)]), '#7a9a7a')
    cv.fill(rect(30, 40, 31, 52), '#7a9a7a')
    # the river
    bands(cv, [(55, '#a9d6ea'), (62, '#7fbcd8'), (78, '#3f8fb0')])
    for y in range(57, 62, 2):
        cv.fill(rect(140 + (y % 4) * 3, y, 176 - (y % 4) * 3, y), '#f1ece0')
    ripples(cv, rect(0, 64, W - 1, H - 1), '#a9d6ea', step=5, ln=6, seed=2)
    for (x, y, w) in ((150, 58, 90), (-10, 60, 50), (170, 66, 50)):            # mist strips
        cv.fill(rrect(x, y, x + w, y + 2, 1), '#e6efe6')
    # ferry rope across the river, from the tall post on the landing to the far post
    cv.fill(line([(194, 58), (31, 41)]), '#4a2c1a')
    # the flat boat mid-river: a punt with low rails, crates, a lamp pole and a pulley mast on the rope
    o = cv.obj()
    o.part(poly([(24, 70), (118, 70), (110, 78), (32, 78)]), DWOOD, d=1)
    o.part(poly([(30, 66), (112, 66), (118, 70), (24, 70)]), WOOD, d=1, contour=True)
    o.part(rect(30, 58, 32, 66) | rect(108, 58, 110, 66) | rect(30, 58, 110, 60), WOOD, d=0)
    o.draw()
    for x in range(36, 112, 8):
        cv.fill(line([(x, 67), (x - 2, 69)]), '#7a4a1f')
    o = cv.obj(); o.part(rect(38, 50, 54, 66), WOOD, d=2); o.part(rect(54, 56, 68, 66), BURLAP, d=2); o.draw()
    cv.fill(rect(38, 57, 54, 57), '#7a4a1f')
    stitch_h(cv, 56, 66, 59, '#9a6b3f')
    o = cv.obj(); o.part(rect(83, 46, 85, 66), DWOOD, d=0); o.draw()
    cv.fill(rect(81, 45, 87, 47), '#5b6470')
    o = cv.obj(); o.part(rect(101, 54, 103, 66), DWOOD, d=0); o.draw()
    lantern(cv, 102, 44)
    o = cv.obj(); o.part(line([(70, 66), (76, 34)], 2), WOOD, d=0); o.draw()
    cv.fill(rect(26, 79, 116, 80), '#25637d')
    for x in range(24, 120, 9):
        cv.fill(rect(x, 82, x + 4, 82), '#7fbcd8')
    # near left bank: reeds and cattails
    lb = poly([(-4, 100), (30, 98), (64, 106), (84, 120), (90, H), (-4, H)])
    cv.fill(lb, '#4f9a45')
    cv.fill(lb & ~shift(lb, 0, 2), '#7ab55c')
    for x in range(2, 76, 5):
        hgt = 16 + (x * 7) % 12
        base = 104 + max(0, x - 40) // 3
        cv.fill(rect(x, base - hgt, x, base), '#2f6a3a')
        if x % 3 == 0:
            cv.fill(rect(x - 1, base - hgt, x + 1, base - hgt + 6), '#7a4a1f')
    # landing stage from the right bank, posts into the water
    rb = poly([(196, 92), (244, 86), (244, H), (210, H)])
    cv.fill(rb, '#4f9a45')
    cv.fill(rb & ~shift(rb, 0, 2), '#7ab55c')
    o = cv.obj()
    for x in (104, 130, 156, 182):
        o.part(rect(x, 106, x + 4, 126), DWOOD, d=1)
    o.draw()
    stage = poly([(108, 98), (214, 98), (226, 106), (100, 106)])
    o = cv.obj()
    o.part(stage, WOOD, d=1)
    o.part(rect(100, 106, 226, 110), DWOOD, d=1, contour=True)
    o.draw()
    for x in range(110, 220, 7):
        cv.fill(line([(x, 98), (x - 4, 106)]), '#7a4a1f')
    # tall rope post on the stage, rope coil
    o = cv.obj(); o.part(rect(191, 56, 197, 100), DWOOD, d=1); o.draw()
    cv.fill(rect(190, 60, 198, 61) | rect(190, 64, 198, 65), '#c9a96e')
    o = cv.obj(); o.part(ell(170, 94, 188, 102), BURLAP, d=1); o.draw()
    cv.fill(ell(175, 96, 183, 100) & ~ell(177, 97, 181, 99), '#9a6b3f')
    # bell post at the end of the stage
    o = cv.obj()
    o.part(rect(126, 66, 129, 99), DWOOD, d=1)
    o.part(rect(126, 64, 146, 67), DWOOD, d=1, contour=True)
    o.draw()
    o = cv.obj()
    o.part(poly([(136, 70), (142, 70), (145, 82), (133, 82)]) | rrect(136, 67, 142, 71, 1), ramp('#e8a317', '#b07a10', '#f5cf6a'), d=2)
    o.draw()
    cv.fill(rect(139, 83, 139, 94), '#c9a96e')
    # toll hut on the right bank
    o = cv.obj()
    o.part(rect(204, 62, 240, 96), CANVAS, d=3)
    o.part(poly([(198, 64), (222, 46), (246, 64)]), ROOF, d=2, contour=True)
    o.draw()
    o = cv.obj(); o.part(rect(212, 70, 228, 84), DWOOD, d=1); o.draw()
    cv.fill(rect(214, 72, 226, 82), '#f5cf6a')
    cv.fill(rect(220, 72, 220, 82) | rect(214, 77, 226, 77), '#7a4a1f')
    for (x, y) in ((146, 88), (160, 90), (152, 82)):
        o = cv.obj(); o.part(rect(x, y + 8, x + 12, y + 16), WOOD, d=2); o.draw()
        cv.fill(line([(x + 1, y + 9), (x + 11, y + 15)]), '#7a4a1f')
    tufts(cv, [(12, 126), (40, 130), (64, 122), (232, 128), (222, 112)], '#2f6a3a')
    cv.remap({'#fff3c8': '#f1ece0', '#f2e4c0': '#f1ece0', '#c9c5bc': '#f1ece0', '#e0501f': '#d6322b', '#c3b2ea': '#d9d4ee'})
    return cv


# ================================================================== TOWER: tall watchtower on a ridge, far peaks
def tower():
    cv = Canvas()
    bands(cv, [(0, '#7a5cc0'), (12, '#9f8ad6'), (24, '#c3b2ea'), (38, '#d9d4ee'), (50, '#f1ece0')])
    cloud(cv, 18, 20, 34, '#f1ece0', '#d9d4ee')
    cloud(cv, 104, 14, 26, '#f1ece0', '#d9d4ee')
    # far snowy peaks
    peaks = poly([(-10, 80), (20, 48), (40, 62), (70, 38), (100, 66), (150, 44), (182, 64), (214, 36), (250, 74), (250, 94), (-10, 94)])
    cv.fill(peaks, '#9f8ad6')
    snow = (poly([(20, 48), (28, 56), (12, 56)]) | poly([(70, 38), (80, 50), (60, 50)]) | poly([(150, 44), (160, 54), (140, 54)])
            | poly([(214, 36), (226, 50), (202, 50)]))
    cv.fill(snow & peaks, '#f1ece0')
    cv.fill(wave(82, [(4, 70, 0.9), (2, 31, 0.2)]), '#7a5cc0')
    # the ridge rising to the right where the tower stands
    ridge = poly([(-4, 116), (60, 106), (110, 92), (150, 84), (200, 80), (244, 84), (244, H), (-4, H)])
    cv.fill(ridge, '#7ab55c')
    cv.fill(ridge & ~shift(ridge, 0, 3), '#a4b86a')
    cv.fill(poly([(-4, 124), (80, 112), (140, 104), (244, 104), (244, H), (-4, H)]) & ridge, '#4f9a45')
    # winding path up to the tower door
    p = line([(20, 135), (46, 122), (90, 116), (120, 106), (150, 98), (176, 100)], 5)
    cv.fill(p, '#c9a96e')
    cv.fill(p & ~shift(p, 0, -2), '#9a6b3f')
    # the tower: stone base, timber legs and braces, lookout hut, beacon basket
    cx, dy = 178, 10
    base = poly([(cx - 22, 92 + dy), (cx + 22, 92 + dy), (cx + 18, 66 + dy), (cx - 18, 66 + dy)])
    o = cv.obj()
    o.part(base, STONE, d=3)
    legs = line([(cx - 16, 66 + dy), (cx - 10, 26 + dy)], 4) | line([(cx + 16, 66 + dy), (cx + 10, 26 + dy)], 4)
    o.part(legs, WOOD, d=1)
    br = line([(cx - 15, 62 + dy), (cx + 12, 40 + dy)], 2) | line([(cx + 15, 62 + dy), (cx - 12, 40 + dy)], 2) | rect(cx - 15, 50 + dy, cx + 15, 52 + dy)
    o.part(br & ~legs, DWOOD, d=0)
    o.part(rect(cx - 16, 24 + dy, cx + 16, 28 + dy), WOOD, d=1, contour=True)
    o.part(rect(cx - 12, 14 + dy, cx + 12, 24 + dy), WOOD, d=2, contour=True)
    o.part(poly([(cx - 17, 15 + dy), (cx, 5 + dy), (cx + 17, 15 + dy)]), ROOF, d=2, contour=True)
    o.draw()
    for (y, xs) in ((72, (cx - 10, cx + 6)), (78, (cx - 16, cx, cx + 12)), (84, (cx - 8, cx + 8)), (90, (cx - 14, cx + 2, cx + 16))):
        cv.fill(rect(cx - 20, y + dy, cx + 20, y + dy) & base, '#5b6470')
        for x in xs:
            cv.fill(rect(x, y - 5 + dy, x, y + dy) & base, '#5b6470')
    cv.fill(rrect(cx - 4, 80 + dy, cx + 4, 92 + dy, 2) & rect(0, 0, W, 92 + dy), '#3d2a1c')
    cv.fill(rect(cx - 8, 17 + dy, cx + 8, 21 + dy), '#3d2a1c')
    cv.fill(rect(cx - 6, 18 + dy, cx - 3, 21 + dy), '#f5cf6a')
    o = cv.obj()                                                        # beacon basket on a pole beside the roof
    o.part(rect(cx + 19, 16 + dy, cx + 21, 28 + dy), DWOOD, d=0)
    o.part(poly([(cx + 14, 12 + dy), (cx + 26, 12 + dy), (cx + 23, 18 + dy), (cx + 17, 18 + dy)]), ramp('#5b6470', '#3d2a1c', '#8b8f96'), d=1, contour=True)
    o.draw()
    cv.fill(poly([(cx + 15, 12 + dy), (cx + 20, 2 + dy), (cx + 25, 12 + dy)]), '#f08a24')
    cv.fill(poly([(cx + 18, 12 + dy), (cx + 20, 6 + dy), (cx + 22, 12 + dy)]), '#f5cf6a')
    o = cv.obj()                                                        # ladder up the side
    lad = line([(cx - 28, 92 + dy), (cx - 20, 28 + dy)], 1) | line([(cx - 22, 92 + dy), (cx - 14, 28 + dy)], 1)
    for k in range(1, 12):
        t = k / 12
        lad |= line([(round(cx - 28 + 8 * t), round(92 + dy - 64 * t)), (round(cx - 22 + 8 * t), round(92 + dy - 64 * t))])
    o.part(lad, WOOD, d=0)
    o.draw()
    o = cv.obj(); o.part(rect(228, 48, 230, 90), DWOOD, d=0); o.draw()       # signal flags to a pole
    cv.fill(line([(cx + 16, 26 + dy), (229, 49)]), '#4a2c1a')
    for i in range(5):
        x = cx + 22 + i * 6
        y = 26 + dy + round((x - cx - 16) * (49 - 26 - dy) / (229 - cx - 16))
        cv.fill(rect(x - 2, y + 1, x + 2, y + 5), ('#d6322b', '#e8a317', '#3f8fb0', '#f1ece0', '#4f9a45')[i])
    # pines on the slope, boulders, a bench with a spyglass
    for (x, yb, w, h) in ((20, 110, 18, 34), (38, 108, 14, 26), (104, 98, 14, 24), (226, 112, 18, 30)):
        pine(cv, x, yb, w, h)
    rock(cv, 120, 110, 150, 124, moss=MOSS)
    rock(cv, 60, 118, 96, 134, moss=MOSS)
    o = cv.obj()
    o.part(rect(196, 114, 224, 117), WOOD, d=1)
    o.part(rect(199, 118, 201, 126) | rect(219, 118, 221, 126), WOOD, d=0)
    o.draw()
    o = cv.obj(); o.part(line([(204, 112), (218, 108)], 3), GOLD, d=0); o.draw()
    tufts(cv, [(160, 122), (176, 128), (232, 124), (40, 126), (100, 128)], '#2f6a3a')
    # wild flowers on the ridge and a kite of birds
    for (x, y, c) in ((30, 118, '#f5cf6a'), (86, 112, '#e46a9b'), (140, 100, '#f5cf6a'), (206, 98, '#e46a9b'), (160, 112, '#f1ece0'), (52, 126, '#e46a9b')):
        cv.fill(rect(x, y, x + 1, y + 1), c)
    for (x, y) in ((70, 26), (80, 22), (88, 28)):
        cv.fill(line([(x, y + 2), (x + 2, y), (x + 4, y + 2), (x + 6, y), (x + 8, y + 2)]), '#4e3a8a')
    cv.remap({'#fff3c8': '#f1ece0', '#f2e4c0': '#f1ece0', '#c9c5bc': '#f1ece0', '#e0501f': '#d6322b'})
    return cv


def steam(cv, x, y, h, col='#f1ece0', sh='#cde6e8', ph=0.0):
    """A rising wisp: a column of small puffs that sway and shrink as they climb."""
    for k in range(0, h, 3):
        r = max(1, 4 - k * 4 // h)
        cx = x + round(3 * math.sin(k / 5.0 + ph))
        cy = y - k
        cv.fill(ell(cx - r, cy - r + 1, cx + r, cy + r - 1), col)
        cv.dots([(cx - r, cy)], sh)


# ================================================================== SPRING: steaming terraced pools among rocks
def spring():
    cv = Canvas()
    bands(cv, [(0, '#a9d6ea'), (14, '#cde6e8'), (28, '#f6d9e0'), (40, '#f1ece0')])
    peaks = poly([(-10, 70), (30, 30), (56, 48), (90, 22), (130, 52), (170, 26), (210, 46), (250, 30), (250, 80), (-10, 80)])
    cv.fill(peaks, '#d9c4cc')
    cv.fill(peaks & (poly([(30, 30), (44, 44), (16, 44)]) | poly([(90, 22), (106, 38), (74, 38)]) | poly([(170, 26), (186, 42), (154, 42)])
                     | poly([(250, 30), (250, 46), (232, 44)])), '#f1ece0')
    # pine slope behind the basin
    cv.fill(wave(60, [(4, 54, 0.5), (3, 29, 2.0)]), '#7a9a7a')
    for x in range(-4, W + 6, 11):
        pine(cv, x, 70, 12, 18 + (x * 7) % 10, flat='#4f7a5a')
    cv.fill(rect(0, 70, W - 1, H - 1), '#8b8f96')
    # bath hut on the left: timber, steep roof, lantern
    o = cv.obj()
    o.part(rect(8, 46, 52, 76), WOOD, d=3)
    o.part(poly([(0, 50), (30, 28), (60, 50)]), ramp('#5b6470', '#3d2a1c', '#8b8f96'), d=2, contour=True)
    o.draw()
    for x in range(12, 52, 6):
        cv.fill(rect(x, 50, x, 76), '#7a4a1f')
    for y in range(36, 50, 5):
        cv.fill(rect(0, y, 60, y) & poly([(0, 50), (30, 28), (60, 50)]), '#3d2a1c')
    o = cv.obj(); o.part(rect(20, 56, 34, 76), PETAL, d=2); o.draw()            # pink noren curtain
    cv.fill(rect(27, 60, 27, 76), '#b8457a')
    lantern(cv, 44, 54)
    # pools: back right high, middle, front left large; each with a rock lip
    def pool(x0, y0, x1, y1):
        lip = ell(x0 - 6, y0 - 4, x1 + 6, y1 + 6)
        o = cv.obj(); o.part(lip, STONE, d=3); o.draw()
        w = ell(x0, y0, x1, y1)
        cv.fill(w, '#7fc8c8')
        cv.fill(w & ~shift(w, 0, 3), '#3f9aa0')
        cv.fill(w & ~shift(w, 0, -2), '#bfe6e0')
        for k in range(3):
            yy = y0 + 4 + k * (y1 - y0) // 4
            cv.fill(rect(x0 + 8 + k * 6, yy, x0 + 14 + k * 6, yy) & w, '#bfe6e0')
        return w
    pool(150, 64, 226, 82)
    pool(92, 86, 176, 104)
    pool(8, 102, 120, 128)
    for (x, y0, y1) in ((160, 82, 92), (106, 104, 112)):                        # little falls between pools
        cv.fill(rect(x, y0, x + 4, y1), '#bfe6e0')
        cv.fill(rect(x + 1, y0, x + 1, y1), '#f1ece0')
    o = cv.obj(); o.part(line([(240, 54), (210, 62)], 4), ramp('#a4b86a', '#7ab55c', '#f5cf6a'), d=0); o.draw()
    for x in (218, 230):
        cv.fill(rect(x, 58, x + 1, 58), '#7ab55c')
    cv.fill(rect(208, 63, 210, 70), '#bfe6e0')
    # rocks around (one mossy)
    for (x0, y0, x1, y1, m) in ((56, 72, 96, 90, MOSS), (222, 86, 250, 118, None), (124, 110, 168, 134, None),
                                (196, 118, 230, 136, MOSS), (-10, 78, 12, 100, None)):
        rock(cv, x0, y0, x1, y1, moss=m, d=3)
    # towel bench on the right, egg basket on the near rock
    o = cv.obj()
    o.part(rect(178, 108, 218, 111), WOOD, d=1)
    o.part(rect(182, 112, 184, 122) | rect(212, 112, 214, 122), WOOD, d=0)
    o.draw()
    o = cv.obj()
    o.part(rrect(182, 100, 198, 108, 1), PETAL, d=2)
    o.part(rrect(196, 102, 212, 108, 1), ramp('#f1ece0', '#c9c5bc', '#fff3c8'), d=2, contour=True)
    o.draw()
    stitch_h(cv, 183, 197, 104, '#f1ece0')
    o = cv.obj()
    o.part(poly([(132, 104), (158, 104), (154, 116), (136, 116)]), BURLAP, d=2)
    o.part(line([(134, 104), (145, 96), (156, 104)], 1), BURLAP, d=0)
    o.draw()
    for (x, y) in ((136, 99), (142, 98), (148, 99), (139, 101), (151, 101)):
        o = cv.obj(outline=False); o.part(ell(x, y, x + 5, y + 6), ramp('#f1ece0', '#c9c5bc'), d=1); o.draw()
    cv.fill(rect(134, 109, 156, 109) & poly([(132, 104), (158, 104), (154, 116), (136, 116)]), '#9a6b3f')
    # steam rising off each pool
    for (x, y, h, ph) in ((170, 70, 34, 0.0), (192, 72, 28, 2.0), (210, 70, 22, 4.0), (112, 92, 30, 1.0), (140, 94, 36, 3.0),
                          (30, 108, 30, 0.5), (60, 106, 40, 2.5), (90, 110, 26, 4.5)):
        steam(cv, x, y, h, ph=ph)
    # a pink flowering shrub (hue 345) by the top pool
    o = cv.obj(); o.part(ell(222, 64, 246, 84), MOSS, d=2); o.draw()
    for (x, y) in ((226, 68), (232, 66), (238, 70), (230, 74), (240, 76)):
        cv.fill(rect(x, y, x + 1, y + 1), '#e46a9b')
    cv.remap({'#fff3c8': '#f1ece0', '#f2e4c0': '#f1ece0', '#f6b8cf': '#f6d9e0', '#7ab55c': '#a4b86a', '#c9a96e': '#c9c5bc'})
    return cv


# ================================================================== CAMP: dusk clearing, tents, logs, fire
def camp():
    cv = Canvas()
    bands(cv, [(0, '#4e3a8a'), (16, '#7a5cc0'), (28, '#e46a9b'), (40, '#f08a24'), (50, '#f5cf6a')])
    for (x, y) in ((30, 12), (90, 14), (150, 11), (206, 15)):
        cv.dots([(x, y), (x + 1, y)], '#f5cf6a')
    # forest wall: a dense back layer, then darker near pines at the sides
    for i, x in enumerate(range(-6, W + 10, 8)):
        h = 30 + (i * 37) % 14
        pine(cv, x, 78, 14, h, flat='#7a5cc0')
    cv.fill(rect(0, 64, W - 1, 84), '#7a5cc0')
    for i, x in enumerate(range(-2, W + 10, 13)):
        if 60 < x < 180:
            continue
        pine(cv, x, 88, 22, 48 + (i * 23) % 16, flat='#4e3a8a')
    # clearing floor: warm grass, lit circle round the fire
    cv.fill(rect(0, 84, W - 1, H - 1), '#2f6a3a')
    cv.fill(ell(30, 86, 210, 140), '#4f9a45')
    cv.fill(ell(78, 96, 162, 130), '#7ab55c')
    # tents: a patched canvas one left, a striped one right
    o = cv.obj()
    o.part(poly([(14, 100), (46, 48), (80, 100)]), CANVAS, d=3)
    o.part(rect(44, 44, 47, 50), WOOD, d=0)
    o.draw()
    cv.fill(poly([(38, 100), (47, 70), (56, 100)]), '#3d2a1c')
    cv.fill(poly([(42, 100), (47, 82), (52, 100)]) & ~rect(0, 0, W, 90), '#f08a24')
    o = cv.obj(outline=False); o.part(rect(24, 80, 32, 88), ramp('#4f9a45', '#2f6a3a'), d=1); o.draw()
    stitch_h(cv, 24, 32, 80, '#f5cf6a')
    cv.dots([(24, y) for y in range(80, 89) if y % 3 != 2], '#f5cf6a')
    o = cv.obj()
    t2 = poly([(166, 100), (194, 58), (226, 58), (238, 100)])
    o.part(t2, ramp('#e8a317', '#b07a10', '#f5cf6a'), d=3)
    o.draw()
    for x in range(170, 240, 10):
        cv.fill(t2 & poly([(x, 100), (x + 5, 100), (x + 5 + (210 - x) // 4, 58), (x + (210 - x) // 4, 58)]), '#d6322b')
    cv.fill(poly([(186, 100), (196, 72), (206, 100)]), '#3d2a1c')
    # log seats round the fire
    for (x0, y0, x1, y1) in ((70, 96, 106, 104), (136, 96, 172, 104), (90, 120, 152, 129)):
        o = cv.obj()
        o.part(rrect(x0, y0, x1, y1, 2), WOOD, d=2)
        o.part(ell(x1 - 6, y0, x1 + 2, y1), BURLAP, d=1, contour=True)
        o.draw()
        cv.fill(ell(x1 - 4, y0 + 2, x1, y1 - 2) & ~ell(x1 - 3, y0 + 3, x1 - 1, y1 - 3), '#9a6b3f')
        cv.fill(rect(x0 + 3, y0 + 3, x1 - 9, y0 + 3), '#7a4a1f')
    # the fire: stone ring, crossed logs, flames, sparks
    o = cv.obj()
    for k in range(9):
        a = k * 2 * math.pi / 9
        x, y = 120 + 19 * math.cos(a), 111 + 6 * math.sin(a)
        o.part(ell(round(x) - 4, round(y) - 3, round(x) + 4, round(y) + 3), STONE, d=1)
    o.draw()
    cv.fill(ell(106, 107, 134, 115), '#3d2a1c')
    o = cv.obj(); o.part(line([(108, 112), (132, 104)], 3) | line([(108, 104), (132, 112)], 3), DWOOD, d=0); o.draw()
    for (x0, x1, top, col) in ((108, 132, 76, '#d6322b'), (112, 128, 82, '#f08a24'), (116, 124, 88, '#f5cf6a')):
        f = poly([(x0, 110), (x1, 110), ((x0 + x1) // 2 + 2, top)]) | poly([(x0, 110), ((x0 + x1) // 2, 110), (x0 + 2, top + 10)]) | poly([((x0 + x1) // 2, 110), (x1, 110), (x1 - 1, top + 8)])
        cv.fill(f, col)
    for (x, y) in ((114, 70), (126, 66), (120, 60), (110, 76), (132, 72)):
        cv.fill(rect(x, y, x + 1, y + 1), '#f5cf6a')
    o = cv.obj()                                                        # kettle on a tripod
    o.part(line([(102, 116), (120, 64)], 2) | line([(138, 116), (120, 64)], 2), DWOOD, d=0)
    o.draw()
    cv.fill(rect(120, 66, 120, 74), '#4a2c1a')
    o = cv.obj()
    o.part(ell(112, 74, 128, 86) & rect(0, 0, W, 84), STONE, d=2)
    o.part(line([(127, 79), (132, 76)], 2), STONE, d=0)
    o.draw()
    o = cv.obj(); o.part(rect(64, 70, 66, 98), DWOOD, d=0); o.part(rect(64, 70, 72, 71), DWOOD, d=0); o.draw()
    lantern(cv, 71, 72)
    for (x, y) in ((10, 118), (26, 118), (18, 110), (34, 110), (2, 110)):  # firewood pile
        o = cv.obj(); o.part(rrect(x, y, x + 20, y + 7, 2), WOOD, d=1); o.part(ell(x + 16, y, x + 22, y + 7), BURLAP, d=0, contour=True); o.draw()
    o = cv.obj()                                                        # bedroll
    o.part(rrect(178, 110, 230, 122, 4), ramp('#3f8fb0', '#25637d', '#a9d6ea'), d=2)
    o.part(ell(218, 106, 236, 124), ramp('#d6322b', '#a8241f', '#f08a24'), d=2, contour=True)
    o.draw()
    stitch_h(cv, 182, 214, 115, '#f5cf6a')
    tufts(cv, [(60, 112), (170, 112), (40, 128), (200, 130), (156, 92), (84, 92)], '#1f3f3a')
    # glowing mugs on the near log, mushrooms, fireflies over the grass
    for x in (100, 140):
        o = cv.obj(); o.part(rect(x, 113, x + 5, 119), ramp('#3f8fb0', '#25637d', '#a9d6ea'), d=1); o.draw()
    for (x, y) in ((154, 116), (60, 104)):
        o = cv.obj(); o.part(rect(x + 2, y + 3, x + 3, y + 6), CANVAS, d=0); o.part(ell(x, y, x + 5, y + 4) & rect(0, 0, W, y + 3), EMBER, d=1, contour=True); o.draw()
        cv.dots([(x + 2, y + 1)], '#f2e4c0')
    for (x, y) in ((24, 70), (150, 80), (90, 66), (218, 46), (60, 84)):
        cv.fill(rect(x, y, x + 1, y + 1), '#f5cf6a')
        cv.dots([(x - 1, y), (x + 2, y + 1)], '#a4b86a')
    cv.remap({'#fff3c8': '#f2e4c0', '#c9c5bc': '#f2e4c0', '#e0501f': '#d6322b'})
    return cv


STOPS = {'market': market, 'mill': mill, 'inn': inn, 'shrine': shrine, 'jetty': jetty, 'herb': herb, 'workshop': workshop,
         'orchard': orchard, 'ferry': ferry, 'tower': tower, 'spring': spring, 'camp': camp}

if __name__ == '__main__':
    out = sys.argv[1] if len(sys.argv) > 1 else os.path.join(os.path.dirname(__file__), '..', '..', 'game', 'assets', 'img', 'scenes')
    only = sys.argv[2:] or list(STOPS)
    for k in only:
        cv = STOPS[k]()
        p = os.path.join(out, 'stop-' + k + '.png')
        cv.save(p)
        print(k, 'colours', cv.colours(), '->', p)
