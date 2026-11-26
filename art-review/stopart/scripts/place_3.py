#!/usr/bin/env python3
"""Stitched Toy redraw of game/assets/img/town/place-grind.png (144x108 RGBA card). Staging only: writes art-review/stopart/out/town/place-grind.png."""
import math, os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from place_kit import *  # noqa


def draw(c):
    sky_hills(c, horizon=82, clouds=((70, 28, 10, 3),))
    tufts(c, [(46, 95), (78, 93), (110, 96), (130, 92)])
    # striped awning with a scalloped hem
    c.g = 'awning'
    for i in range(8):
        x0 = 8 + i * 16
        c.add(OR(rect(x0, 8, x0 + 8, 16), ell(x0 + 4, 16, 4, 3.5)), RED, contour=False)
        c.add(OR(rect(x0 + 8, 8, x0 + 16, 16), ell(x0 + 12, 16, 4, 3.5)), CLOTH, contour=False)
    c.g = 'sack'
    c.add(OR(poly([(14, 86), (12, 70), (16, 52), (22, 48), (36, 48), (40, 56), (42, 74), (40, 86)])), BURLAP, stitch=THREAD_B)
    c.add(ell(28, 49, 12, 6), HERB)
    c.g = 'mortar'
    c.add(thick_path([(56, 64), (72, 44)], 5), WOOD)
    c.add(OR(AND(ell(64, 68, 14, 16), rect(48, 68, 81, 84)), rect(60, 82, 69, 87)), GREY)
    c.add(rect(49, 65, 80, 69), DGREY)
    c.g = 'bowlY'
    c.add(ell(100, 74, 12, 6), SPICE_Y)
    c.add(AND(ell(100, 74, 15, 12), rect(84, 74, 117, 90)), STONE)
    c.g = 'bowlR'
    c.add(ell(125, 76, 9, 5), SPICE_R)
    c.add(AND(ell(125, 76, 12, 10), rect(112, 76, 140, 90)), STONE)
    c.g = None
    for (x, y) in ((86, 50), (94, 42), (110, 46), (118, 36), (102, 58)):
        c.px(x, y, GOLD[0]); c.px(x + 1, y, GOLD[2]); c.px(x, y + 1, GOLD[1])


if __name__ == '__main__':
    run('grind', draw)
