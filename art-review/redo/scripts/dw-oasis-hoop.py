#!/usr/bin/env python3
"""dw-oasis-hoop "Oasis Hoop": an inner-BBBB (double) piece that IS a coral-and-cream swim ring floating in the oasis pool.
Rounded square ring body, double blanks bitten into all four sides, the hole is the purple pool (cell 9-6) with its
pink/orange sunset reflection streaks; felt face peeks from the pool in the hole, a lily pad hat and a date in hand."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

ROOT = '/home/user/gnome-venture'
CORAL = K.ramp('#e88b62')      # pool reflection orange
CREAM = ('#f2e4c0', '#c9b48a', '#fff6e0')
POOL = K.ramp('#5a3c86')       # oasis water, a touch lighter than #453069 so it reads inside the umber
PINK = '#d06a78'
PEACH = '#c88a59'
LILY = ('#5aa04a', '#3a7034', '#8cc86a')
DATE = ('#8a4a24', '#5e3018', '#b06a3a')


def sq(cx, cy, r, p=4.0):
    return lambda x, y: (abs(x - cx) / r) ** p + (abs(y - cy) / r) ** p < 1


def hoop(c):
    k = 1.15 if c.small else 1.0
    R = 4.0 * k
    core = sq(32, 33, 26, 4.2)
    blanks = (K.knob('B', 'double', 32, 7, 0, -1, r=R), K.knob('B', 'double', 32, 59, 0, 1, r=R),
              K.knob('B', 'double', 6, 33, -1, 0, r=R), K.knob('B', 'double', 58, 33, 1, 0, r=R))
    body = c.m(core, minus=blanks)
    c.add(body, CORAL, stitch=None)
    # life-ring cream segments on the four diagonals
    diag = lambda x, y: abs(abs(x - 32) - abs(y - 33)) < 6.5 and (abs(x - 32) > 4)
    seg = body & c.m(diag)
    c.add(seg, CREAM)
    # the pool seen through the hole
    hole = c.m(K.ell(32, 33, 12.5, 12))
    c.add(hole, POOL)
    c.edge(seg, CORAL[1])
    c.edge(hole, CORAL[1])
    # reflection streaks in the water
    if not c.small:
        c.line([(23, 40), (28, 40)], PINK)
        c.line([(35, 42), (41, 42)], CORAL[0])
        c.line([(26, 23.5), (31, 23.5)], PINK)
    else:
        c.line([(36, 42.5), (41, 42.5)], CORAL[0])
    # felt face peeking up from the pool
    c.eye(27.5, 31, disc=True)
    c.eye(36.5, 31, disc=True)
    c.smile(32, 36, CREAM if not c.small else CREAM)
    if not c.small:
        c.blush(23.5, 35)
        c.blush(40, 35)
    # lily pad hat on the upper-right corner
    pad = c.m(K.ell(49, 14, 9 * (1.05 if c.small else 1), 5.2), minus=(lambda x, y: 49 <= x < 58 and abs(y - 14 - (x - 49) * 0.25) < 1.4,))
    c.add(pad, LILY)
    c.edge(pad, LILY[1])
    # the date it keeps for a friend, lower-left corner
    date = c.m(K.ell(13, 53, 4.6 * k, 6.4 * k))
    c.add(date, DATE)
    c.px(*c.P(13, 47.5), LILY[1])
    if not c.small:
        c.px(*c.P(11.5, 51), DATE[2])


K.render_pal(hoop, 'dw-oasis-hoop', 'Oasis Hoop', ROOT + '/art-review/redo/out',
             cellfile=ROOT + '/art-review/redo/_src/dw-oasis-hoop-cell.png',
             oldfile=ROOT + '/game/assets/img/puzzles/pals/dw-oasis-hoop.png')
