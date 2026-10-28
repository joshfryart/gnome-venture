"""Gather tab scene for the FOREST land (2026-10-28): game/assets/img/gather/scene-forest.png.

Usage: python3 -B aseprite-source/scenes-pil/gather_forest.py
Deep green shade under an oak canopy: shafts of light from the upper left, tall trunks fading back, a moss floor with
leaf litter and acorns. Focal prop: a big hollow fallen oak log (left) with red toadstools on its back and two eyes
peeking out of the dark hollow; ferns rustle by the right-hand trunk. The find lands on a fairy ring of tiny caps.
Same composition as every gather scene: far layer on top, ground from y 50, the shared open satchel at its fixed place
(grid x 146..214, y 34..104), a clear landing ring at x 96..144, y 92..112; the top corners stay calm for the UI chips.
"""
import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from pixlib import Canvas, ramp, rect, rrect, ell, poly, line, blank, shift, W, H  # noqa: E402
from gather_common import draw_satchel, save_scene  # noqa: E402

BARK = ramp('#7a4a1f', '#5c3420', '#9a6b3f')
OAK = ramp('#4f9a45', '#2f6a3a', '#7ab55c')
DEEP = ramp('#2f6a3a', '#1f3f3a', '#4f9a45')
LEAF = ramp('#7ab55c', '#4f9a45', '#a4b86a')
BURLAP = ramp('#c9a96e', '#9a6b3f', '#f2e4c0')
SHROOM = ramp('#d6322b', '#a8241f', '#f08a24')
CREAM = ramp('#f2e4c0', '#c9a96e', '#f2e4c0')
ACORN = ramp('#b07a3a', '#7a4a1f', '#d9a35a')
CUP = ramp('#5c3420', '#4a2c1a', '#7a4a1f')

HAZE0, HAZE1, HAZE2, HAZE3 = '#e6efd8', '#d6e3b4', '#c4d698', '#a4b86a'
GROUND = 50


def rnd(seed):
    st = [seed * 2654435761 % 4294967296 or 1]

    def r(a, b):
        st[0] = (st[0] * 1103515245 + 12345) % 2147483648
        return a + (st[0] >> 8) % (b - a + 1)
    return r


# ------------------------------------------------------------------ far layer
def far_wood(cv):
    cv.fill(rect(0, 0, W - 1, H - 1), HAZE0)
    cv.fill(rect(0, 26, W - 1, H - 1), HAZE1)
    # light shafts from the upper left, behind everything
    for x0 in (30, 96, 150):
        cv.fill(poly([(x0, 0), (x0 + 12, 0), (x0 + 50, GROUND), (x0 + 34, GROUND)]), HAZE0)
    # far trunks (hazy), then a mid row
    r = rnd(4)
    x = -2
    while x < W:
        w = r(2, 4)
        cv.fill(rect(x, 8, x + w, GROUND), HAZE2)
        x += w + r(8, 15)
    r = rnd(9)
    x = 4
    while x < W:
        w = r(5, 8)
        if not (92 <= x <= 130):
            cv.fill(rect(x, 10, x + w, GROUND + 2), HAZE3)
            cv.fill(rect(x + w - 1, 10, x + w, GROUND + 2), '#93a85c')
        x += w + r(18, 30)
    # far undergrowth along the horizon
    r = rnd(5)
    x = -8
    while x < W:
        w = r(14, 24)
        cv.fill(ell(x, GROUND - r(8, 12), x + w, GROUND + 4), HAZE3)
        x += w - r(3, 7)


def canopy(cv):
    """Leaf roof: one flat dark mass (calm in the corners for the UI chips), then outlined clumps hanging lower."""
    m = rect(0, 0, W - 1, 8)
    r = rnd(3)
    x = -10
    while x < W + 10:
        w = r(16, 26)
        m |= ell(x, -6, x + w, 12 + r(0, 6))
        x += w - r(5, 9)
    cv.fill(m, '#2f6a3a')
    cv.fill(m & ~shift(m, 0, 2) & rect(40, 0, 200, H), '#1f3f3a')
    r = rnd(12)
    x = 36
    while x < 214:
        w, h = r(22, 32), r(14, 20)
        top = r(2, 8)
        rp = (OAK, DEEP, LEAF, OAK)[r(0, 3)]
        o = cv.obj()
        o.part(ell(x, top, x + w, top + h), rp, d=3)
        if r(0, 1):
            hx = x + r(6, w - 12)
            o.part(ell(hx, top + h - 6, hx + 10, top + h + 5), rp, d=2)
        o.draw()
        for k in range(2):
            px, py = x + r(6, w - 8), top + r(5, h - 5)
            cv.fill(line([(px, py), (px + 3, py - 2)]), rp['s'])
        x += w - r(5, 9)


def trunk(cv, x, w, ytop, ybot, roots=True, moss=True):
    o = cv.obj()
    m = rect(x, ytop, x + w, ybot)
    if roots:
        m |= poly([(x - 6, ybot), (x, ybot - 10), (x, ybot)]) | poly([(x + w, ybot - 10), (x + w + 7, ybot), (x + w, ybot)])
    o.part(m, BARK, d=2)
    o.draw()
    for yy in range(ytop + 4, ybot - 6, 8):
        xx = x + 2 + (yy * 3) % max(2, w - 4)
        cv.fill(rect(xx, yy, xx, yy + 4), BARK['s'])
    if moss:  # moss creeping up the shaded foot
        cv.fill(rect(x + 1, ybot - 7, x + 3, ybot) | rect(x + 1, ybot - 10, x + 1, ybot - 7), '#4f9a45')


# ------------------------------------------------------------------ ground
def floor(cv):
    top = GROUND
    cv.fill(rect(0, top, W - 1, H - 1), '#7ab55c')
    cv.fill(rect(0, top + 9, W - 1, H - 1), '#4f9a45')
    for x in range(W):                                      # little teeth where the bands meet
        if x % 5 in (0, 2):
            cv.dots([(x, top + 8)], '#4f9a45')
        if x % 5 == 1:
            cv.dots([(x, top + 7), (x, top + 8)], '#4f9a45')
    cv.fill(rect(0, top + 40, W - 1, H - 1), '#2f6a3a')     # deep shade near the viewer
    for x in range(W):
        if x % 7 in (0, 3):
            cv.dots([(x, top + 39)], '#2f6a3a')
        if x % 7 == 1:
            cv.dots([(x, top + 38), (x, top + 39)], '#2f6a3a')
    # the shafts of light land on the floor as pale pools
    for (x0, y0, x1) in ((62, 54, 92), (150, 53, 190), (14, 104, 40), (200, 120, 232)):
        c = '#a4b86a' if y0 < 90 else '#7ab55c'
        cv.fill(rect(x0, y0, x1, y0 + 1) | rect(x0 + 4, y0 + 2, x1 - 6, y0 + 2), c)


def litter(cv, keep_out):
    """Fallen leaves and twigs (hard 3 px flecks)."""
    r = rnd(21)
    cols = ('#9a6b3f', '#e8a317', '#c9a96e', '#b07a3a', '#9a6b3f')
    for i in range(110):
        x, y = r(2, 236), r(GROUND + 3, H - 2)
        if keep_out[y, x]:
            continue
        c = cols[i % len(cols)]
        if i % 2:
            cv.fill(rect(x, y, x + 2, y) | rect(x + 1, y - 1, x + 1, y - 1), c)
        else:
            cv.fill(rect(x, y, x + 1, y) | rect(x + 1, y + 1, x + 2, y + 1), c)
    for (x, y) in ((40, 118), (190, 124), (70, 128)):       # twigs
        cv.fill(line([(x, y), (x + 7, y - 2)]) | line([(x + 4, y - 1), (x + 6, y - 4)]), '#5c3420')


def fern(cv, x, y, s=1.0, rp=OAK, lean=0):
    o = cv.obj()
    m = blank()
    for (dx, dy, droop) in ((-13, -5, 4), (-8, -12, 2), (-2, -15, 0), (4, -14, 0), (10, -10, 2), (14, -4, 4)):
        dx, dy = dx * s + lean, dy * s
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
    cv.fill(line([(x, y), (round(x - 6 * s), round(y - 3 * s))]) | line([(x, y), (x + 1, round(y - 8 * s))]) |
            line([(x, y), (round(x + 6 * s), round(y - 4 * s))]), rp['s'])


def toadstool(cv, x, ybot, r=5):
    o = cv.obj()
    o.part(rect(x - 1, ybot - r - 2, x + 1, ybot), CREAM, d=1)
    o.part(ell(x - r, ybot - r * 2 - 2, x + r, ybot - 2) & rect(0, 0, W, ybot - r - 2), SHROOM, d=1, contour=True)
    o.draw()
    cv.dots([(x - r // 2, ybot - r - 5), (x + r // 2, ybot - r - 6), (x, ybot - r * 2)], '#f2e4c0')


def acorn(cv, x, y):
    o = cv.obj()
    o.part(rrect(x, y + 2, x + 3, y + 6, 1), ACORN, d=1)
    o.part(rrect(x - 1, y, x + 4, y + 2, 1), CUP, d=0, contour=True)
    o.draw()
    cv.dots([(x + 1, y - 1)], '#5c3420')
    cv.dots([(x + 1, y + 3)], '#d9a35a')


# ------------------------------------------------------------------ the focal prop
def hollow_log(cv):
    """A fat fallen oak, cut end toward the satchel; something blinks in the hollow."""
    x0, x1, y, r = 6, 78, 70, 12               # body y 70..94, end disc centred at x1
    o = cv.obj()
    body = rrect(x0, y, x1, y + 2 * r, 5)
    o.part(body, BARK, d=3)
    o.part(ell(x0 + 12, y + 2 * r - 2, x0 + 24, y + 2 * r + 4) & rect(0, 0, W, y + 2 * r + 2), BARK, d=1)  # a broken root stub
    end = ell(x1 - 9, y - 1, x1 + 9, y + 2 * r + 1)
    o.part(end, BURLAP, d=2, contour=True)
    # moss blanket over the back, with drips down the side
    moss = rrect(x0 + 2, y - 3, x1 - 12, y + 4, 3)
    for xx in range(x0 + 6, x1 - 14, 7):
        moss |= rect(xx, y + 4, xx + 2, y + 6 + (xx % 3))
    o.part(moss, LEAF, d=1, contour=True)
    o.draw()
    # bark grain
    for (xx, yy, ln) in ((14, 80, 9), (30, 86, 12), (48, 79, 8), (56, 88, 10), (22, 90, 6), (40, 83, 5)):
        cv.fill(rect(xx, yy, xx + ln, yy), BARK['s'])
    # growth rings on the cut end, dark hollow, two eyes
    cv.fill(ell(x1 - 7, y + 1, x1 + 7, y + 2 * r - 1) & ~ell(x1 - 6, y + 2, x1 + 6, y + 2 * r - 2), '#9a6b3f')
    hollow = ell(x1 - 5, y + 4, x1 + 5, y + 2 * r - 4)
    cv.fill(hollow, '#4a2c1a')
    cv.fill(ell(x1 - 4, y + 6, x1 + 4, y + 2 * r - 5), '#2a1a10')
    ey = y + 11
    cv.fill(rect(x1 - 3, ey, x1 - 2, ey + 1) | rect(x1 + 1, ey, x1 + 2, ey + 1), '#f5cf6a')
    cv.dots([(x1 - 3, ey), (x1 + 1, ey)], '#f2e4c0')
    # toadstools sprouting from the mossy back, a bracket fungus on the flank
    toadstool(cv, 22, y - 1, 6)
    toadstool(cv, 33, y, 4)
    toadstool(cv, 58, y, 3)
    o = cv.obj()
    o.part(ell(46, 86, 56, 92) & rect(0, 0, W, 89), ramp('#e8a317', '#b07a10', '#f5cf6a'), d=1)
    o.draw()


def fairy_ring(cv):
    """Where the find lands: a flat moss patch ringed with tiny cream caps."""
    cv.fill(ell(94, 96, 146, 114), '#2f6a3a')
    cv.fill(ell(97, 97, 143, 112), '#7ab55c')
    cv.fill(ell(100, 99, 140, 110) & ~ell(102, 100, 138, 109), '#a4b86a')
    for k in range(14):
        a = k * 2 * math.pi / 14 + 0.2
        x = round(120 + 25 * math.cos(a))
        y = round(105 + 8.5 * math.sin(a))
        if y < 100:            # the back half of the ring stays tiny
            cv.dots([(x, y), (x + 1, y)], '#f2e4c0')
            continue
        cv.fill(rect(x - 1, y - 2, x + 1, y - 2) | rect(x - 2, y - 1, x + 2, y - 1), '#f2e4c0')
        cv.dots([(x + 1, y - 1), (x + 2, y - 1)], '#c9a96e')
        cv.fill(rect(x, y, x, y + 1), '#c9a96e')
        cv.dots([(x - 2, y), (x + 2, y)], '#2f6a3a')


def rustle(cv):
    """The ferns by the right-hand trunk are shaking: tick marks and a leaf shaken loose."""
    for (x, y, s) in ((215, 80, -1), (213, 86, -1), (217, 74, -1)):
        cv.fill(line([(x, y), (x + 2 * s, y - 2)]) | line([(x + 2 * s, y - 2), (x + 3 * s, y - 2)]), '#f2e4c0')
    for (x, y, c) in ((226, 62, '#e8a317'), (110, 40, '#e8a317'), (70, 30, '#b07a3a'), (134, 52, '#e8a317')):
        cv.fill(rect(x, y, x + 2, y) | rect(x + 1, y - 1, x + 1, y - 1), c)


def scene():
    cv = Canvas('#e6efd8')
    far_wood(cv)
    floor(cv)
    # tall trunks: a big oak behind the log, one at the far right, two slimmer ones mid-back
    trunk(cv, 86, 6, 10, 58, roots=False, moss=False)
    trunk(cv, 40, 13, 4, 74)
    trunk(cv, 222, 16, 4, 98)
    canopy(cv)
    keep = blank() | ell(92, 94, 148, 116) | rect(144, 30, 216, 106) | rrect(4, 64, 92, 100, 4) | rect(214, 60, 239, 104)
    litter(cv, keep)
    fairy_ring(cv)
    hollow_log(cv)
    # ferns: a clump at the log's foot, the rustling pair at far right, a front corner one
    fern(cv, 8, 104, 0.9, OAK)
    fern(cv, 226, 100, 1.0, OAK)
    fern(cv, 234, 104, 0.8, LEAF)
    fern(cv, 10, 134, 1.0, LEAF)
    rustle(cv)
    for (x, y) in ((84, 96), (90, 100), (218, 108), (30, 108)):
        acorn(cv, x, y)
    for (x, y) in ((64, 122), (124, 124)):
        acorn(cv, x, y)
    draw_satchel(cv)
    return cv


if __name__ == '__main__':
    cv = scene()
    save_scene(cv, 'forest')
    print('colours:', cv.colours())
