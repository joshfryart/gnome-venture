#!/usr/bin/env python3
"""mw-fourwind-finch: inner-TTTT, tri. A plump maple-red finch whose square body is the piece; its four tri tabs are the four
compass points: N crest, E beak, W tail, S a gold compass needle under its feet. Maple red / gold / orange from the big tree,
a sky-blue compass-rose star on the wing (cell 10-1: maple canopy over pale sky)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

RED = K.ramp('#d6312b')
DEEP = K.ramp('#a8241f')
GOLD = K.ramp('#f0b92b')
ORNG = K.ramp('#f18a23')
SKY = K.ramp('#c4e2ed')
BRN = K.ramp('#c88a13')


def rounded(x0, y0, x1, y1, r):
    return [K.rect(x0 + r, y0, x1 - r, y1), K.rect(x0, y0 + r, x1, y1 - r),
            K.ell(x0 + r, y0 + r, r, r), K.ell(x1 - r, y0 + r, r, r),
            K.ell(x0 + r, y1 - r, r, r), K.ell(x1 - r, y1 - r, r, r)]


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rounded(14, 15, 50, 49, 6)
    tabN = K.knob('T', 'tri', 30, 15, 0, -1, r=5.0 * k)
    tabE = K.knob('T', 'tri', 50, 29, 1, 0, r=4.6 * k)
    tabW = K.knob('T', 'tri', 14, 34, -1, 0, r=5.0 * k)
    tabS = K.knob('T', 'tri', 32, 49, 0, 1, r=4.6 * k)
    body = c.m(*core)
    c.add(body, RED, stitch=None if c.small else '#f08a6a')
    # breast: warm orange belly on the lower right
    breast = c.m(K.ell(37, 40, 13, 11)) & body
    c.add(breast, ORNG)
    # wing: deep red with gold maple flecks, lower left
    wing = c.m(K.poly([(16, 31), (22, 27), (30, 28), (34, 33), (32, 40), (26, 44), (17, 45), (14, 41)])) & body
    c.add(wing, DEEP)
    c.edge(wing, DEEP[1])
    if not c.small:
        c.line([(19, 40), (27, 39)], DEEP[1])
        c.line([(18, 43), (25, 42)], DEEP[1])
    # tabs
    c.add(c.m(tabN, minus=core), RED)
    c.add(c.m(tabE, minus=core), GOLD)
    c.add(c.m(tabW, minus=core), DEEP)
    c.add(c.m(tabS, minus=core), BRN)
    # tail feather split line, beak line
    if not c.small:
        c.line([(4, 34), (13, 34)], DEEP[1])
        c.line([(52, 29), (60, 29)], BRN[1])
    else:
        c.line([(6, 34), (13, 34)], DEEP[1])
    # sky-blue compass star on the wing
    sx, sy = c.P(24, 34)
    arms = 3 if not c.small else 2
    for d in range(-arms, arms + 1):
        c.px(sx + d, sy, SKY[0])
        c.px(sx, sy + d, SKY[0])
    c.px(sx, sy, '#ffffff')
    if not c.small:
        for dx, dy in ((-1, -1), (1, -1), (-1, 1), (1, 1)):
            c.px(sx + dx, sy + dy, SKY[2])
    # gold leaf flecks on the back
    for fx, fy in ((20, 22), (25, 19)) if not c.small else ((21, 22),):
        x, y = c.P(fx, fy)
        c.px(x, y, GOLD[0])
        c.px(x + 1, y, GOLD[0])
        if not c.small:
            c.px(x, y + 1, GOLD[2])
    # face near the beak
    c.eye(41, 26, disc=True)
    c.blush(44, 33)


K.render_pal(fn, 'mw-fourwind-finch', 'Fourwind Finch', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/mw-fourwind-finch-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/mw-fourwind-finch.png')
