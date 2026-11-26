#!/usr/bin/env python3
"""pl-wcen-5 "Ripples Running Late": inner-BBBB keyhole. A square piece of cenote pool: slate stone rim (cell 2-2 greys) with
hanging green vine, turquoise water filled with concentric white ripple rings spreading out from a pebble that peeks up with a
sleepy, late face. All four keyhole blanks bite into the pool, so the rings bend around them."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

RIM = K.ramp('#6e7d8e')
WATER = K.ramp('#2aaabb')
DEEP = K.ramp('#1f8598')
SAND = K.ramp('#efe2b4')
PEB = K.ramp('#8c96a0')
VINE = K.ramp('#4cb848')
FOAM = '#e6f6f2'


def ring(cx, cy, rx, ry, w):
    return lambda x, y: (1 - w / rx) ** 2 < ((x - cx) / rx) ** 2 + ((y - cy) / ry) ** 2 < 1


def fn(c):
    k = 1.15 if c.small else 1.0
    core = lambda x, y: 6 <= x < 58 and 6 <= y < 58 and not (
        (min(x - 6, 58 - x) < 4 and min(y - 6, 58 - y) < 4) and
        (min(x - 6, 58 - x) - 4) ** 2 + (min(y - 6, 58 - y) - 4) ** 2 > 16)
    bl = [K.knob('B', 'keyhole', 32, 6, 0, -1, r=3.4 * k, nw=2.0),
          K.knob('B', 'keyhole', 32, 58, 0, 1, r=3.4 * k, nw=2.0),
          K.knob('B', 'keyhole', 6, 32, -1, 0, r=3.4 * k, nw=2.0),
          K.knob('B', 'keyhole', 58, 32, 1, 0, r=3.4 * k, nw=2.0)]
    body = c.m(core, minus=bl)
    c.add(body, RIM, stitch=None)
    pool = c.m(K.rect(10, 10, 54, 54), minus=bl) & body
    c.add(pool, DEEP)
    c.edge(pool, RIM[1])
    cx, cy = 32, 33
    water = c.m(K.ell(cx, cy, 20, 19)) & pool
    c.add(water, WATER)
    sand = c.m(K.ell(cx, cy + 1, 9.5, 7)) & pool
    c.add(sand, SAND)
    # ripple rings (2 units wide so they survive at 36 px)
    w = 1.6 if c.small else 1.1
    for rx, ry in ((13, 10.5), (17.5, 15), (22, 19.5)):
        rm = c.m(ring(cx, cy + 1, rx, ry, w)) & pool
        for p in rm:
            c.px(p[0], p[1], FOAM)
    # vine hanging from the top rim (cell's green strand)
    c.add(c.m(K.thick_path([(13, 6), (13, 22), (14, 27)], 2.8)) & body, VINE)
    c.add(c.m(K.ell(14, 27.5, 2.0, 2.0)) & body, VINE)
    c.add(c.m(K.thick_path([(50, 6), (50, 16)], 2.6)) & body, VINE)
    # the pebble that is late
    peb = c.m(K.ell(cx, cy + 1, 7.5, 5.5))
    c.add(peb, PEB)
    c.eye(29, 33)
    c.eye(35.5, 33)
    if not c.small:
        for x in range(c.P(27, 0)[0], c.P(31, 0)[0] + 1):
            c.px(x, c.P(0, 30.2)[1], K.UMBER2)
        for x in range(c.P(33.5, 0)[0], c.P(37.5, 0)[0] + 1):
            c.px(x, c.P(0, 30.2)[1], K.UMBER2)
    x, y = c.P(32.2, 36.4)
    c.px(x, y, K.UMBER)
    c.px(x + 1, y, K.UMBER)
    c.blush(26.5, 35.5)
    c.blush(37.5, 35.5)


rep = K.render_pal(fn, 'pl-wcen-5', 'Ripples Running Late', '/home/user/gnome-venture/art-review/redo/out',
                   cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wcen-5-cell.png',
                   oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wcen-5.png')
print(rep)
