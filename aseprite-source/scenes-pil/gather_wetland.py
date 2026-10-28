"""Gather tab scene, WETLAND: a misty morning bog, a grey heron on one leg in a peat pool, the find lands on a lily pad.

Usage: python3 -B aseprite-source/scenes-pil/gather_wetland.py   -> game/assets/img/gather/scene-wetland.png (480 x 270)
Drawn on the 240 x 135 grid with pixlib; the shared open satchel comes from gather_common.draw_satchel (fixed place,
grid x 146..214, y 34..104, strap to x 100, y 22). Same layout as the forest scene: sky and far layer on top, ground
from y 50 down, landing spot x 96..144, y 92..112 (here a big flat lily pad), props left (x 8..90) and far right.
Top corners (x < 40 or x > 200, y < 14) stay plain sky for the UI chips.
Focal prop: the heron (left). Small life: ripple rings with nothing in them (the plop you never see), frog eyes.
Palette: Part A families + Part D ramps (moss, water, stone, umber); hazy far tints borrowed from the wetland stages.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from pixlib import Canvas, ramp, rect, rrect, ell, poly, line, shift, dil4, W, H  # noqa: E402
from gather_common import draw_satchel, save_scene  # noqa: E402
from stops import bands, wave, tufts  # noqa: E402

MOSS = ramp('#4f9a45', '#2f6a3a', '#7ab55c')
FEATHER = ramp('#c9c5bc', '#8b8f96', '#f1ece0')
WING = ramp('#8b8f96', '#5b6470', '#c9c5bc')
SLATE = ramp('#5b6470', None)
REED = ramp('#a4b86a', '#4f9a45', None)
POOL, POOL_LT, MUD = '#5b8aa0', '#8fb4c4', '#5c3420'
MIST, HAZE, FAR, FAR2 = '#f1ece0', '#cde6e8', '#a4b8a8', '#7a9a7a'


def pool(cv, m, rings=(), seed=0):
    """A sunken peat pool: dark mud lip on the far (top) side, water, a lit streak or two, silent ripple rings."""
    lip = m & ~shift(m, 0, 2)
    cv.fill(m, POOL)
    cv.fill(lip, MUD)
    ys, xs = m.nonzero()
    for k, y in enumerate(range(ys.min() + 4, ys.max() - 1, 4)):
        x = xs.min() + 6 + ((k * 13 + seed) % 17)
        cv.fill(rect(x, y, x + 4 + (k % 3) * 2, y) & shift(m, 0, -3), POOL_LT)
    for (cx, cy, r) in rings:
        for rr in (r, r + 4):
            ring = ell(cx - rr, cy - rr // 3, cx + rr, cy + rr // 3) & ~ell(cx - rr + 1, cy - rr // 3 + 1, cx + rr - 1, cy + rr // 3 - 1)
            cv.fill(ring & m & ~lip, POOL_LT)


def pad(cv, x, y, w, flower=False):
    """A small floating lily pad, notch to the right; optional pink bud."""
    m = ell(x, y, x + w, y + max(3, w // 3)) & ~poly([(x + w // 2, y + w // 6), (x + w + 1, y), (x + w + 1, y + w // 3)])
    cv.fill(m, '#4f9a45')
    cv.fill(m & ~shift(m, 0, -1), '#7ab55c')
    cv.fill(m & ~shift(m, 0, 1) & ~shift(m, -1, 0), '#2f6a3a')
    if flower:
        bx = x + w // 3
        cv.fill(rect(bx, y - 1, bx + 2, y), '#e46a9b')
        cv.dots([(bx + 1, y - 2), (bx, y - 2)], '#f6b8cf')


def cattail(cv, x, base, h, head=True, lean=0):
    cv.fill(line([(x, base), (x + lean, base - h)]), '#2f6a3a')
    if head:
        hx = x + lean
        cv.fill(rect(hx - 1, base - h + 2, hx + 1, base - h + 8), '#7a4a1f')
        cv.dots([(hx - 1, base - h + 3), (hx - 1, base - h + 4)], '#9a6b3f')
        cv.dots([(hx, base - h), (hx, base - h + 1)], '#2f6a3a')


def blade(cv, x, base, h, lean, col):
    cv.fill(poly([(x - 1, base), (x + 1, base), (x + lean, base - h)]), col)


def heron(cv, x, base):
    """Grey heron on one leg, facing right (toward the satchel). x = foot, base = waterline."""
    # reflection first (hard, broken stripes in the pool)
    for k, (a, b) in enumerate(((x - 14, x + 16), (x - 10, x + 13), (x - 6, x + 8), (x - 1, x + 2))):
        cv.fill(rect(a + (k % 2) * 2, base + 3 + k * 2, b, base + 3 + k * 2), POOL_LT)
    o = cv.obj(cx=x + 2, cy=base - 34)
    leg = rect(x, base - 26, x + 1, base)
    o.part(leg, SLATE, d=0)
    o.part(line([(x + 1, base - 26), (x + 7, base - 20), (x + 2, base - 18)], 2), SLATE, d=0)    # tucked leg
    body = ell(x - 16, base - 44, x + 14, base - 24) | poly([(x - 16, base - 36), (x - 26, base - 28), (x - 10, base - 28)])
    o.part(body, FEATHER, d=3)
    wing = ell(x - 18, base - 41, x + 8, base - 27) | poly([(x - 18, base - 34), (x - 28, base - 27), (x - 8, base - 29)])
    o.part(wing & shift(body, 0, 0), WING, d=2, contour=True)
    neck = line([(x + 6, base - 40), (x + 12, base - 47), (x + 10, base - 54), (x + 12, base - 62)], 6)
    o.part(neck, FEATHER, d=2)
    head = ell(x + 8, base - 68, x + 20, base - 60)
    o.part(head, FEATHER, d=1)
    o.draw()
    # bill: long dagger toward the satchel
    cv.fill(poly([(x + 19, base - 66), (x + 33, base - 63), (x + 19, base - 61)]), '#e8a317')
    cv.fill(rect(x + 20, base - 62, x + 27, base - 62), '#b07a10')
    cv.fill(rect(x + 20, base - 65, x + 24, base - 65), '#f5cf6a')
    # black eye stripe running back into a trailing crest plume, eye
    cv.fill(rect(x + 10, base - 65, x + 14, base - 65), '#5b6470')
    cv.fill(rect(x + 14, base - 66, x + 17, base - 66), '#5b6470')
    cv.fill(line([(x + 10, base - 65), (x + 4, base - 63), (x - 1, base - 62)], 1), '#5b6470')
    cv.dots([(x + 16, base - 66)], '#2a1a10')
    cv.dots([(x + 15, base - 66)], '#f5cf6a')
    # neck streaks and flight-feather tips
    for k in range(4):
        cv.dots([(x + 12 + (k % 2), base - 56 + k * 3), (x + 12 + (k % 2), base - 55 + k * 3)], '#5b6470')
    for k in range(4):
        cv.dots([(x - 24 + k * 4, base - 28), (x - 23 + k * 4, base - 28)], '#5b6470')
    # water ring round the leg
    cv.fill(rect(x - 4, base + 1, x + 5, base + 1), POOL_LT)
    cv.fill(rect(x - 2, base, x + 3, base), '#2f6a3a')


def scene():
    cv = Canvas('#a9d6ea')
    # sky: three calm hard bands, a pale morning sun low behind the mist
    bands(cv, [(0, '#a9d6ea'), (16, HAZE), (30, MIST)])
    cv.fill(ell(56, 14, 72, 30), '#f5cf6a')
    cv.fill(rect(48, 26, 90, 27), HAZE)
    # two far herons flapping home (shallow Vs)
    for (x, y) in ((86, 10), (98, 14)):
        cv.fill(line([(x, y + 2), (x + 3, y), (x + 5, y + 2), (x + 7, y), (x + 10, y + 2)]), '#8b8f96')
    # far layer: alder and willow line, half eaten by mist
    for (x, w) in ((-8, 22), (8, 16), (20, 26), (42, 18), (56, 24), (76, 14), (86, 22), (104, 16), (128, 26), (150, 18),
                   (164, 24), (184, 16), (196, 26), (218, 18), (230, 22)):
        cv.fill(ell(x, 50 - w * 3 // 4, x + w, 56), FAR)
    snag = line([(118, 52), (120, 34)], 2) | line([(119, 40), (114, 33)], 1) | line([(120, 38), (125, 31)], 1)
    cv.fill(snag, FAR2)
    near = wave(45, [(2, 31, 2.5), (1, 13, 0.7)], bottom=52)
    cv.fill(near, FAR2)
    for (x0, x1, y) in ((-4, 70, 39), (100, 150, 37), (178, 244, 41), (30, 120, 45), (150, 230, 47)):
        cv.fill(rrect(x0, y, x1, y + 1, 1), MIST)
    # open water at the foot of the far bank
    cv.fill(rect(0, 50, W - 1, 57), POOL_LT)
    cv.fill(rect(0, 50, W - 1, 50), FAR2)
    for (x, y, l) in ((6, 53, 9), (40, 55, 6), (78, 52, 12), (126, 54, 7), (170, 52, 10), (216, 55, 8)):
        cv.fill(rect(x, y, x + l, y), HAZE)
    # bog: moss tussock ground with a lit upper lip, darker near band
    g = wave(57, [(1.5, 53, 0.9), (1, 17, 2.2)])
    cv.fill(g, '#4f9a45')
    cv.fill(g & ~shift(g, 0, 2), '#7ab55c')
    cv.fill(wave(118, [(2, 70, 1.7), (1, 23, 0.4)]), '#2f6a3a')
    # far-bank reeds standing in the open water (thin, no outline)
    for x0 in (20, 30, 62, 92, 122, 222):
        for k in range(5):
            x = x0 + k * 2 + (k * 5) % 3
            h = 3 + (x * 7 + k * 3) % 6
            cv.fill(rect(x, 57 - h, x, 58), '#7a9a7a')
    # tussock flecks
    for y in range(64, 118, 7):
        for x in range((y * 11) % 19, W, 21):
            cv.fill(rect(x, y, x + 2, y), '#2f6a3a')
            cv.dots([(x + 1, y - 1)], '#7ab55c')
    # pools: the heron's pool (left), the landing pool, a little one bottom right
    pl = ell(4, 84, 92, 112) | ell(20, 98, 70, 120)
    pool(cv, pl, rings=((24, 104, 5),), seed=3)
    pm = ell(84, 92, 150, 120)
    pool(cv, pm, rings=(), seed=7)
    pr = ell(196, 108, 244, 126)
    pool(cv, pr, rings=((222, 119, 4),), seed=11)
    tufts(cv, [(96, 76), (122, 84), (24, 78), (78, 70), (132, 66), (190, 112), (100, 126), (150, 128), (60, 128)], '#2f6a3a')
    tufts(cv, [(108, 70), (40, 72), (176, 126), (226, 128)], '#a4b86a')
    # small pads in the pools
    pad(cv, 8, 94, 9, flower=True)
    pad(cv, 70, 104, 7)
    pad(cv, 40, 114, 8)
    pad(cv, 228, 112, 8, flower=True)
    # frog eyes peeking out of the little pool (the only one that saw the plop)
    for ex in (205, 210):
        cv.fill(rect(ex, 113, ex + 2, 114), '#7ab55c')
        cv.dots([(ex + 1, 113)], '#2a1a10')
    cv.fill(rect(203, 115, 214, 115), POOL_LT)
    # left framing: tall cattails and sword reeds at the very edge
    for (x, h, ln) in ((2, 54, 1), (6, 44, -1), (10, 60, 2), (14, 38, 0)):
        cattail(cv, x, 92, h, lean=ln)
    for (x, h, ln, c) in ((0, 30, 3, '#4f9a45'), (5, 24, -3, '#a4b86a'), (12, 28, 5, '#4f9a45'), (17, 18, 4, '#a4b86a')):
        blade(cv, x, 92, h, ln, c)
    # the heron, focal prop
    heron(cv, 52, 102)
    # far right: a reed bed with cattails (behind and right of the satchel)
    for (x, h, ln) in ((218, 58, -1), (222, 46, 1), (226, 66, 0), (230, 50, 2), (234, 40, -1), (237, 56, 1)):
        cattail(cv, x, 110, h, lean=ln)
    for (x, h, ln, c) in ((216, 26, -4, '#4f9a45'), (221, 34, -2, '#a4b86a'), (228, 30, 3, '#4f9a45'),
                          (233, 22, -3, '#a4b86a'), (239, 32, -2, '#4f9a45')):
        blade(cv, x, 110, h, ln, c)
    # landing spot: one big flat lily pad, floating free, notch to the lower left
    lp = ell(96, 97, 144, 113) & ~poly([(120, 105), (96, 109), (104, 115)])
    cv.fill(shift(lp, 1, 1) & ~lp & pm, '#1f3f3a')
    cv.fill(lp, '#4f9a45')
    cv.fill(lp & ~shift(lp, 1, 1), '#7ab55c')
    cv.fill(lp & ~shift(lp, -1, -1), '#2f6a3a')
    cv.fill(line([(120, 105), (131, 100)]) & lp & shift(lp, -1, -1), '#2f6a3a')
    cv.dots([(141, 100), (139, 99)], '#e46a9b')
    cv.dots([(140, 98)], '#f6b8cf')
    draw_satchel(cv)
    return cv


if __name__ == '__main__':
    cv = scene()
    n = cv.colours()
    assert n <= 32, n
    save_scene(cv, 'wetland')
    print('wetland colours', n)
