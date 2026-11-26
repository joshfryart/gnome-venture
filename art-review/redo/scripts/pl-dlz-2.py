#!/usr/bin/env python3
"""pl-dlz-2 "Tongue Flicker" (edge-TBT, tri): a lizard head in profile whose square head IS the edge piece.
Flat side at the bottom (lower jaw rests on it); left tri tab = the red forked tongue flicking out of the mouth;
top tri blank cut between two cream horns; right tri tab = the green crest spike at the back of the head.
Colours from cell 0-6: dusty sunset terracotta with its checker dither for the head, the plum horizon band for the jaw,
the pale star-yellow for the eye; dragon green + horn cream from the den picture."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, thick_path, knob, UMBER, UMBER2

HEAD = K.ramp('#b06a5a')
DITH = '#be7e64'
JAW = K.ramp('#6a3a4c')
MOUTH = K.ramp('#c8506a')
GREEN = K.ramp('#6fa848')
HORN = K.ramp('#e8d0a0')
TONGUE = K.ramp('#d83a34')
STAR = '#ffe49a'


def fn(c):
    s = 1.15 if c.small else 1.0
    def rr(x0, y0, x1, y1, r):
        def f(x, y):
            if not (x0 <= x < x1 and y0 <= y < y1):
                return False
            cx = min(max(x, x0 + r), x1 - r)
            cy = min(max(y, y0 + r), y1 - r)
            return (x - cx) ** 2 + (y - cy) ** 2 < r * r
        return f
    # core: rounded top corners (snout front-left), square bottom (flat side)
    core_top = rr(11, 12, 53, 58, 8)
    core_bot = rect(11, 40, 53, 58)
    tabL = knob('T', 'tri', 11, 40, -1, 0, r=4.8 * s, nw=3.0 * s)
    tabR = knob('T', 'tri', 53, 30, 1, 0, r=4.6 * s)
    blankT = knob('B', 'tri', 36, 12, 0, -1, r=3.6 * s)
    body = c.m(core_top, core_bot, tabR, minus=(blankT,))
    upper = body & c.m(rect(0, 0, 64, 41))
    jaw = body - upper
    c.add(upper, HEAD, stitch=None if c.small else '#d49a80')
    c.add(jaw, JAW)
    chin = jaw & c.m(rect(0, 0, 64, 49))
    c.add(chin, K.ramp(DITH))
    if not c.small:
        for (x, y) in upper:
            if y >= 14 and x >= 33 and x % 4 == (y // 2) % 2 * 2 and y % 2 == 0:
                c.px(x, y, DITH)
    # green dragon crest: spikes down the back of the head and the right tab
    crest = c.m(tabR, poly([(53, 16), (46.5, 20), (53, 24)]), poly([(53, 34), (47, 38), (53, 42)]), rect(50, 14, 53, 44)) & body
    c.add(crest, GREEN)
    # swept-back horns, one each side of the top blank
    hornL = c.m(thick_path([(25, 15), (27, 8), (31, 4.5)], 4.4 * s))
    hornR = c.m(thick_path([(43, 15), (46, 8), (51, 5)], 4.4 * s))
    c.add(hornL, HORN)
    c.add(hornR, HORN)
    # open mouth with teeth; the tongue runs out of it into the left tab
    mouth = c.m(poly([(11, 37), (38, 41), (11, 45)])) & (upper | jaw)
    c.add(mouth, MOUTH)
    tongue = c.m(tabL, thick_path([(10, 40.5), (26, 40.5)], 4.4 * s))
    fork = poly([(0, 37), (8.0, 40.5), (0, 44)])
    tongue = tongue - c.m(fork)
    c.add(tongue, TONGUE)
    c.edge(jaw, JAW[1])
    c.edge(chin, HEAD[1])
    for tx in ((15, 20, 25, 30) if not c.small else (16, 24)):
        x, y = c.P(tx, 38.3)
        c.px(x, y, HORN[2])
    for tx in ((18, 23, 28) if not c.small else (20,)):
        x, y = c.P(tx, 43.3)
        c.px(x, y, HORN[2])
    c.line([(38, 41), (48, 40)], UMBER2)
    # big yellow lizard eye with slit pupil under a green brow
    ex, ey = 26 if not c.small else 25, 26
    brow = c.m(ell(ex, ey - 4.5, 8 * s, 3.2 * s))
    c.add(brow & upper, GREEN)
    eye = c.m(ell(ex, ey, 5.6 * s, 5.2 * s))
    c.add(eye, K.ramp('#f0c040'))
    cx, cy = c.P(ex, ey)
    for dy in range(-2 if not c.small else -1, 3 if not c.small else 2):
        c.px(cx, cy + dy, UMBER)
    c.px(cx - 1, cy - (2 if not c.small else 1), STAR)
    nx, ny = c.P(14.5, 30)
    c.px(nx, ny, UMBER2)
    if not c.small:
        c.px(nx + 1, ny, UMBER2)
        for (x, y) in ((20, 53), (28, 55), (36, 52), (44, 54), (32, 57)):
            px, py = c.P(x, y)
            c.px(px, py, JAW[2])
    c.blush(36, 33)


if __name__ == '__main__':
    out = '/home/user/gnome-venture/art-review/redo/out'
    print(K.render_pal(fn, 'pl-dlz-2', 'Tongue Flicker', out,
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-dlz-2-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-dlz-2.png'))
