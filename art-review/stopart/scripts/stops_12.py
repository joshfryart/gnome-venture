#!/usr/bin/env python3
"""Stitched Toy redraw of game/assets/img/stops/workshop.png (48x48 RGBA). Staging only: writes art-review/stopart/out/stops/workshop.png."""
import math, os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from stops_kit import *  # noqa


def draw(c):
    def gear(x, y):
        dx, dy = x - 22, y - 20
        r = math.hypot(dx, dy)
        t = math.atan2(dy, dx)
        return r < 12.5 or (r < 16.6 and math.cos(8 * t) > 0.25)
    c.add(gear, GOLD, stitch="#7a4a1f")
    c.add(ell(22, 20, 4.2, 4.2), DARK)
    c.add(ell(22, 20, 1.6, 1.6), ("#2a1a10", "#2a1a10", "#2a1a10"), shade=False)
    c.add(thick_path([(29, 36), (41, 22)], 2.6), WOOD)
    c.add(thick_path([(37.5, 17.5), (45, 25)], 4.4), STONE)
    c.add(rect(2, 35, 46, 41), WOOD, stitch=THREAD)
    c.add(rect(5, 41, 9, 47), WOOD_D)
    c.add(rect(39, 41, 43, 47), WOOD_D)


if __name__ == '__main__':
    run('workshop', draw)
