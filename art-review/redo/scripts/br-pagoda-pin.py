#!/usr/bin/env python3
"""br-pagoda-pin "Pagoda Pin": inner-TTTT, double knobs. A little red pagoda that IS a plus-piece: square core of stacked red tiers and
slate-blue eaves (cell 10-1). Double tabs: N = gold finial with a spire pin, E + W = upswept slate eave tips, S = two red feet.
Face on the big middle tier, gold door strips in the top and bottom tiers."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

RED = K.ramp('#d8432d')
SLATE = K.ramp('#5b627f')
GOLD = K.ramp('#f5cf6a')
PIN = K.ramp('#e8a317')
DOOR = '#f5cf6a'
TILE = '#3f455f'


def fn(c):
    k = 1.15 if c.small else 1.0
    x0, x1, y0, y1 = 14, 50, 17, 51
    core = K.rect(x0, y0, x1, y1)
    # top roof: pitched cap, eaves overhang and curl up at the tips
    cap = K.poly([(20, 12.5), (44, 12.5), (x1 + 3.5, 20), (x1 + 4.5, 16.5), (x1 + 6, 17), (x1 + 5, 22.5),
                  (x0 - 5, 22.5), (x0 - 6, 17), (x0 - 4.5, 16.5), (x0 - 3.5, 20)])
    mid = K.poly([(x0 - 1, 29), (x1 + 1, 29), (x1 + 2.5, 31), (x1 + 3.5, 28.5), (x1 + 5, 29), (x1 + 4, 34.5),
                  (x0 - 4, 34.5), (x0 - 5, 29), (x0 - 3.5, 28.5), (x0 - 2.5, 31)])
    tabN = K.knob('T', 'double', 32, 12.5, 0, -1, r=4.4 * k)
    tabE = K.knob('T', 'double', x1, 42.5, 1, 0, r=4.6 * k)
    tabW = K.knob('T', 'double', x0, 42.5, -1, 0, r=4.6 * k)
    tabS = K.knob('T', 'double', 32, y1, 0, 1, r=4.8 * k)
    spire = K.rect(31, 1.5, 33.2, 6) if not c.small else K.rect(30.6, 1.5, 33.4, 6)
    body = c.m(core)
    c.add(body, RED, stitch=None)
    c.add(c.m(tabE, tabW, minus=(core,)), RED)
    c.add(c.m(cap), SLATE)
    c.add(c.m(mid), SLATE)
    c.add(c.m(tabN, spire, minus=(cap,)), PIN)
    c.add(c.m(K.rect(x0, 48, x1, y1), tabS), SLATE)
    step = 2 if c.small else 3
    for yy, xa, xb in ((19.5, x0 - 2, x1 + 2), (32, x0 - 2, x1 + 2)):
        _, py = c.P(0, yy)
        for x in range(c.P(xa, 0)[0], c.P(xb, 0)[0], step):
            c.px(x, py, TILE)
    for yy in (22.5, 34.5):
        _, py = c.P(0, yy)
        for x in range(c.P(x0, 0)[0], c.P(x1, 0)[0]):
            c.px(x, py + 1, RED[1])
    DR = (DOOR, '#c9a040', '#fbe6a8')
    c.add(c.m(K.rect(28.5, 23.5, 35.5, 29)), DR)
    c.add(c.m(K.rect(28.5, 44, 35.5, 48), K.ell(32, 44, 3.5, 2.5)), DR)
    c.eye(24.5, 38.5, disc=True)
    c.eye(39.5, 38.5, disc=True)
    c.smile(32, 41)
    c.blush(19.5, 41)
    c.blush(43.5, 41)


K.render_pal(fn, 'br-pagoda-pin', 'Pagoda Pin', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/br-pagoda-pin-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/br-pagoda-pin.png')
