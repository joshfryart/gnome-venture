#!/usr/bin/env python3
"""Stitched Toy redraw of game/assets/img/stops/spring.png (48x48 RGBA). Staging only: writes art-review/stopart/out/stops/spring.png."""
import math, os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from stops_kit import *  # noqa


def draw(c):
    for pts in ([(15, 28), (12, 23), (16, 18), (12, 13), (15, 8)], [(24, 27), (21, 21), (25, 15), (21, 9), (24, 3)], [(33, 28), (30, 23), (34, 18), (30, 13), (33, 8)]):
        c.add(thick_path(pts, 3.2), STEAM)
    c.add(ell(24, 37.5, 22.5, 9), STONE, stitch=THREAD)
    c.add(ell(24, 36, 16, 5.2), WATER)
    for x0 in (14, 27):
        c.line([(x0, 35), (x0 + 4, 35)], "#a9d6ea")
    c.line([(20, 38), (23, 38)], "#a9d6ea")
    for (x, y) in ((4, 39), (10, 44), (38, 44), (44, 39)):
        c.add(ell(x, y, 3.6, 2.6), ("#b4b0b8", "#66626e", "#dcd8e0"))


if __name__ == '__main__':
    run('spring', draw)
