#!/usr/bin/env python3
"""pl-mirr-2 Pinklegs Strut: a flamingo that is an edge piece (edge-TTB, keyhole).
N keyhole tab = head on its neck (with a bent beak), E keyhole tab = tail plumes, W keyhole blank, flat S = lavender mirror-flat band with the legs."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, thick_path, knob, UMBER, CREAM

PINK = K.ramp('#fe88ae')
DEEP = K.ramp('#d8508a')
LAV = K.ramp('#a786c6')
SALT = K.ramp('#c8e0f0')
BEAK = K.ramp('#f4ece8')
LEG = K.ramp('#c8406e')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rect(10, 24, 52, 58)
    tabN = knob('T', 'keyhole', 25, 24, 0, -1, r=7.6 * k, nw=3.4)
    tabE = knob('T', 'keyhole', 52, 33, 1, 0, r=5.0 * k)
    blankW = knob('B', 'keyhole', 10, 42, -1, 0, r=4.6 * k)
    body = c.m(core, tabN, tabE, minus=(blankW,))
    c.add(body, PINK, stitch=None)
    # mirror-flat band at the bottom (flat side)
    band = body & c.m(rect(0, 47, 64, 64))
    c.add(band, LAV)
    c.add(body & c.m(rect(0, 47, 64, 49.5)), SALT)
    # tail plumes: east tab in deep pink
    c.add(c.m(tabE, minus=(rect(0, 0, 48, 64),)), DEEP)
    # folded wing
    wing = c.m(ell(37, 36, 11, 6.5))
    c.add(wing & body, DEEP)
    # legs into the water, with a knee and reflection
    lw = 3.0 if c.small else 2.4
    c.add(c.m(thick_path([(27, 44), (27, 51), (26, 57)], lw)) & body, LEG)
    c.add(c.m(thick_path([(34, 44), (35, 50), (37, 53), (36, 57)], lw)) & body, LEG)
    # beak: pale base, umber-brown bent tip, poking out of the head tab
    beak = c.m(poly([(28, 11.5), (37.5, 13), (40, 17), (39, 21.5), (36.5, 21), (36, 17.5), (28, 16.5)]))
    c.add(beak, BEAK)
    c.add(beak & c.m(rect(35, 0, 64, 64)), K.ramp('#5a3a3e'))
    # head blush + eye
    c.eye(24, 14)
    c.blush(21, 18)


K.render_pal(fn, 'pl-mirr-2', 'Pinklegs Strut', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-mirr-2-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-mirr-2.png')
