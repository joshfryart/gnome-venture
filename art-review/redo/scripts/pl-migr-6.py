#!/usr/bin/env python3
"""pl-migr-6 Pinstripe Plodder (rare, whimsy-zebra, keyhole).
Concept: a chibi zebra in profile whose barrel body IS the square piece core (straight sides), keyhole blank cut into the back (N),
keyhole tab = the tail tuft (E), head + mane break out top-left, stubby legs on the flat S. Herd purples from cell 4-5
(wildebeest flank #614c5c / #3f3241) as the dark stripes, cream-lavender light stripes, sunset orange mane tips from the sky."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, thick_path, knob

LIGHT = K.ramp('#ece2dc')
DARK = K.ramp('#4a3a4c')
MUZ = K.ramp('#614c5c')
SUN = K.ramp('#f09a48')
HOOF = K.ramp('#3f3241')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rect(18, 23, 54, 48)
    blankN = knob('B', 'keyhole', 43, 23, 0, -1, r=4.4 * k)
    tabE = knob('T', 'keyhole', 54, 34, 1, 0, r=4.6 * k)
    neck = poly([(13, 14), (21, 9), (26.5, 22), (20, 36)])
    head = ell(12.5, 17, 8.5, 6.8)
    muzzle = ell(7, 22.5, 5.6, 4.8)
    ear = ell(16, 7.5, 2.6, 4.6)
    legs = [rect(x, 46, x + 6, 57) for x in (19, 27, 40, 48)]
    body = c.m(core, neck, head, ear, *legs, minus=(blankN,))
    c.add(body, LIGHT, stitch=None)
    # stripes: bold bands across the barrel, neck and legs (wide enough to survive 36 px)
    period, w = (9.0, 4.6) if not c.small else (10.0, 5.2)
    stripe = lambda x, y: x > 17 and ((x + (y - 34) * 0.18) % period) < w
    c.add(body & c.m(stripe, minus=(head, muzzle)), DARK)
    hstripe = lambda x, y: ((y + x * 0.5) % 7.0) < 3.0 and x > 9
    c.add(c.m(head, minus=(muzzle,)) & c.m(hstripe) & body, DARK)
    # muzzle
    c.add(c.m(muzzle), MUZ)
    # hooves
    c.add(body & c.m(rect(0, 54, 64, 58)), HOOF)
    # tail: dark stem, keyhole tuft in sunset orange
    c.add(c.m(tabE, minus=(core,)), SUN)
    # mane: a mohawk along the neck top, dark with sunset tips
    mw = 4.2 if not c.small else 4.8
    mane = c.m(thick_path([(17, 7), (23, 10), (25.5, 16), (27, 21)], mw))
    c.add(mane, DARK)
    c.add(mane & c.m(lambda x, y: (x + y) % 6 < 2.4), SUN)
    c.edge(c.m(muzzle), MUZ[1])
    # face
    c.eye(13, 15.5)
    nx, ny = c.P(4.5, 21.5)
    c.px(nx, ny, K.UMBER)
    if not c.small:
        c.px(nx, ny + 1, K.UMBER)
    c.smile(7.5, 24.5, K.UMBER2)
    c.blush(15, 20)


if __name__ == '__main__':
    rep = K.render_pal(fn, 'pl-migr-6', 'Pinstripe Plodder', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-migr-6-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-migr-6.png')
    print(rep)
