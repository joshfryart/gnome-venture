#!/usr/bin/env python3
"""pl-silk-1 "Potstack Teeter": corner-TT, keyhole. Two clay pots stacked as one corner piece.
Flat sides: left + bottom (the courtyard floor). Tab N: teal lid finial (keyhole) with a red tassel (camel's hat).
Tab E: a keyhole pot handle on the lower pot. Colours: camel tan + brick from cell 2-6, teal domes, red hat."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, knob, UMBER, UMBER2, CREAM

CLAY = K.ramp('#b8683c')      # brick/terracotta lower pot
TAN = K.ramp('#d4aa5c')       # camel tan upper pot
TEAL = K.ramp('#2f9a92')      # dome glaze
RED = K.ramp('#d0302a')       # camel's hat tassel
SAND = K.ramp('#ecc878')


def fn(c):
    s = 1.15 if c.small else 1.0
    import math
    th = math.radians(5)

    def tilt(f, ox=29, oy=33):   # lean the upper pot a little to the right (teetering)
        co, si = math.cos(th), math.sin(th)
        return lambda x, y: f(ox + (x - ox) * co + (y - oy) * si, oy - (x - ox) * si + (y - oy) * co)
    # lower pot: flat left + bottom, round belly bulging on the right, rounded bottom-right
    low_core = poly([(8, 56), (8, 33), (40, 33), (36, 56)])
    belly = lambda x, y: ell(34, 44, 18.5, 12.6)(x, y) and y < 56 and x > 20
    # upper pot: a round-shouldered jar with a neck and flared rim, tilted
    jar = lambda x, y: (ell(29, 26, 20.5, 10.5)(x, y) and y < 33.5) or rect(9, 26, 49, 33.5)(x, y)
    neck = rect(22, 11, 36, 17)
    rim = rect(20, 9, 38, 12.5)
    tabN = knob('T', 'keyhole', 29, 9, 0, -1, r=5.2 * s)
    tabE = knob('T', 'keyhole', 52.3, 45, 1, 0, r=4.8 * s)
    c.add(c.m(low_core, belly), CLAY, stitch='#e0a070')
    c.add(c.m(tilt(jar), tilt(neck)), TAN, stitch='#f4d8aa')
    c.add(c.m(tilt(rim), tilt(tabN)), TEAL)
    c.add(c.m(tilt(ell(29, 0.8 if not c.small else 1.2, 3.0 * s, 2.2 * s))), RED)
    # teal glaze lip of the lower pot where the pots meet
    c.add(c.m(rect(8, 32, 48, 35.5)), TEAL)
    c.add(c.m(tabE, minus=(belly,)), CLAY)
    # bunting-style zigzag band on the upper pot (flags over the gate)
    flags = ['#2f9a92', '#d0302a', '#f0c030', '#8a4a87', '#2f9a92', '#d0302a']
    for i, fx in enumerate((15, 20.5, 26, 31.5, 37, 42.5)):
        x, y = c.P(fx + (33 - 22) * 0.087, 22 - (fx - 29) * 0.087)
        col = flags[i]
        if c.small:
            c.px(x, y, col); c.px(x + 1, y, col); c.px(x, y + 1, col)
        else:
            for dx in range(3):
                c.px(x + dx, y, col)
            c.px(x, y + 1, col); c.px(x + 1, y + 1, col)
            c.px(x + 1, y + 2, col)
    # brick band on lower pot near the bottom (caravanserai wall)
    yb = c.P(0, 51)[1]
    for x in range(c.P(10, 0)[0], c.P(47, 0)[0]):
        if (x // (3 if c.small else 5)) % 2 == 0:
            c.px(x, yb, UMBER2)
    # upper pot: giggling closed eyes
    for ex in (22, 36):
        x, y = c.P(ex + 0.5, 28.5 - (ex - 29) * 0.087)
        if c.small:
            c.px(x, y, UMBER); c.px(x + 1, y - 1, UMBER); c.px(x + 2, y, UMBER)
        else:
            c.px(x - 1, y, UMBER); c.px(x, y - 1, UMBER); c.px(x + 1, y - 1, UMBER); c.px(x + 2, y, UMBER)
    # lower pot face
    c.eye(23, 41)
    c.eye(37, 41)
    c.smile(30, 45, wide=True)
    c.blush(18, 45)
    c.blush(41, 45)


K.render_pal(fn, 'pl-silk-1', 'Potstack Teeter', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-silk-1-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-silk-1.png')
