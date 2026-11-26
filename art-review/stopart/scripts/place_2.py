#!/usr/bin/env python3
"""Stitched Toy redraw of game/assets/img/town/place-green.png (144x108 RGBA card). Staging only: writes art-review/stopart/out/town/place-green.png."""
import math, os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from place_kit import *  # noqa


def draw(c):
    sky_hills(c, horizon=80, clouds=((100, 15, 12, 4),))
    tufts(c, [(20, 94), (50, 92), (64, 97), (86, 95), (132, 93)])
    c.add(ell(111, 88, 23, 6.5), WATER)
    c.line([(100, 87), (108, 87)], '#e0f2fa')
    c.line([(114, 90), (122, 90)], '#e0f2fa')
    c.g = 'tree'
    c.add(OR(rect(23, 38, 32, 84), poly([(19, 86), (23, 78), (23, 86)]), poly([(36, 86), (32, 78), (32, 86)])), WOOD_D)
    c.add(OR(ell(28, 26, 19, 16), ell(16, 34, 8, 7), ell(40, 33, 9, 7)), LEAF, stitch='#2f6a3a')
    c.g = 'table'
    c.add(rect(58, 62, 62, 86), WOOD_D)
    c.add(rect(86, 62, 90, 86), WOOD_D)
    c.add(rect(50, 72, 98, 76), WOOD)
    c.add(rect(54, 56, 94, 62), WOOD)
    c.g = None
    for (x, y) in ((20, 22), (34, 18), (40, 34), (24, 34)):
        c.fill(x, y, x + 3, y + 3, '#c8382e')
        c.px(x, y, '#ec6a4e')


if __name__ == '__main__':
    run('green', draw)
