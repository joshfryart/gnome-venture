#!/usr/bin/env python3
"""Stitched Toy redraw of game/assets/img/stops/ferry.png (48x48 RGBA). Staging only: writes art-review/stopart/out/stops/ferry.png."""
import math, os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from stops_kit import *  # noqa


def draw(c):
    c.add(ell(24, 41.5, 23, 5), WATER)
    c.add(rect(22, 3, 25, 32), WOOD_D, shade=False)
    c.add(poly([(25, 5), (25, 29), (43, 29)]), CLOTH, stitch=THREAD_B)
    c.add(poly([(21, 9), (21, 29), (6, 29)]), RED)
    c.add(poly([(25, 2), (32, 4), (25, 6)]), GOLD, shade=False)
    hull = poly([(3, 30), (45, 30), (39, 41), (9, 41)])
    c.add(hull, WOOD, stitch=THREAD)
    c.add(AND(hull, lambda x, y: 32 < y < 35), CLOTH, shade=False)
    for x0 in (4, 16, 30):
        c.line([(x0, 43), (x0 + 2, 42), (x0 + 4, 42), (x0 + 6, 43)], "#a9d6ea")


if __name__ == '__main__':
    run('ferry', draw)
