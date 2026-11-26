#!/usr/bin/env python3
"""Stitched Toy redraw of game/assets/img/town/place-board.png (144x108 RGBA card). Staging only: writes art-review/stopart/out/town/place-board.png."""
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from place_kit import *  # noqa


def draw(c):
    sky_hills(c, horizon=82, clouds=((28, 16, 13, 4),))
    tufts(c, [(14, 92), (40, 96), (70, 93), (100, 95), (128, 91)])
    # stump
    c.g = 'stump'
    c.add(OR(rect(26, 72, 38, 84), ell(32, 84, 6, 1.6), poly([(23, 86), (26, 80), (26, 86)]), poly([(41, 86), (38, 80), (38, 86)])), WOOD)
    c.add(ell(32, 72, 6, 2.2), CANVAS, shade=False)
    c.g = None
    # notice board
    c.g = 'board'
    c.add(rect(62, 56, 67, 87), WOOD_D)
    c.add(rect(126, 56, 131, 87), WOOD_D)
    c.add(rect(55, 22, 137, 64), WOOD, stitch=THREAD)
    c.add(poly([(50, 23), (62, 11), (130, 11), (142, 23)]), RED)
    c.g = None
    notes = [(61, 28, 79, 44, PAPER, '#c8382e'), (84, 26, 100, 40, YELLOWP, '#3f7fc8'), (105, 28, 129, 42, BLUEP, '#c8382e'),
             (68, 47, 88, 60, YELLOWP, '#3f9a4a'), (96, 45, 118, 59, PAPER, '#e8a317')]
    for i, (x0, y0, x1, y1, rp, pin) in enumerate(notes):
        c.add(rect(x0, y0, x1, y1), rp, group='note%d' % i)
    for (x0, y0, x1, y1, rp, pin) in notes:
        for k, yy in enumerate(range(y0 + 4, y1 - 2, 3)):
            c.line([(x0 + 3, yy), (x1 - 4 - (k % 2) * 3, yy)], UMBER2)
        c.px((x0 + x1) // 2, y0, pin)
        c.px((x0 + x1) // 2, y0 + 1, pin)
    # stump rings
    c.line([(30, 72), (34, 72)], WOOD[1])


if __name__ == '__main__':
    run('board', draw)
