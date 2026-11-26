#!/usr/bin/env python3
"""Stitched Toy redraw of game/assets/img/town/place-stones.png (144x108 RGBA card). Staging only: writes art-review/stopart/out/town/place-stones.png."""
import math, os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from place_kit import *  # noqa


def draw(c):
    sky_hills(c, horizon=82, clouds=((40, 16, 12, 4),))
    tufts(c, [(14, 94), (46, 92), (88, 96), (130, 93)])
    c.g = 'dolmen'
    c.add(rect(56, 36, 69, 91), STONE, stitch=STONE[2])
    c.add(rect(94, 36, 107, 91), STONE, stitch=STONE[2])
    c.add(rect(48, 27, 115, 37), DGREY)
    for i, (x0, y0) in enumerate(((30, 52), (114, 54))):
        c.g = 'stand%d' % i
        c.add(OR(rect(x0, y0, x0 + 13, 91), ell(x0 + 6.5, y0, 6.5, 2.5)), STONE, stitch=STONE[2])
        c.g = 'candle%d' % i
        c.add(rect(x0 + 5, y0 - 6, x0 + 9, y0 - 1), CREAMWALL)
        c.add(ell(x0 + 7, y0 - 9, 2, 3.2), FLAME_IN, shade=False)
    c.g = 'rock'
    c.add(ell(81.5, 88, 10, 5), DGREY)
    c.g = None


if __name__ == '__main__':
    run('stones', draw)
