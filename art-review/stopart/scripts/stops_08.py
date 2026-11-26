#!/usr/bin/env python3
"""Stitched Toy redraw of game/assets/img/stops/orchard.png (48x48 RGBA). Staging only: writes art-review/stopart/out/stops/orchard.png."""
import math, os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from stops_kit import *  # noqa


def draw(c):
    c.add(ell(24, 44.5, 14, 3), MOSS)
    c.add(OR(poly([(20, 45), (22, 28), (26, 28), (28, 45)]), poly([(17, 45), (21, 40), (27, 40), (31, 45)])), WOOD)
    c.add(OR(ell(24, 19, 18, 15), ell(12, 27, 9, 7.5), ell(36, 27, 9, 7.5)), LEAF, stitch="#2f6a3a")
    for (x, y) in ((15, 17), (30, 12), (33, 26), (19, 28), (25, 20)):
        c.add(ell(x + 0.5, y + 0.5, 2.8, 2.8), RED)
        c.px(x, y - 3, "#4a2c1a")


if __name__ == '__main__':
    run('orchard', draw)
