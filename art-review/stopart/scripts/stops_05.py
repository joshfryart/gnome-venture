#!/usr/bin/env python3
"""Stitched Toy redraw of game/assets/img/stops/jetty.png (48x48 RGBA). Staging only: writes art-review/stopart/out/stops/jetty.png."""
import math, os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from stops_kit import *  # noqa


def draw(c):
    c.add(ell(24, 40, 23.5, 6.5), WATER)
    for x0 in (7, 21, 35):
        c.add(rect(x0, 28, x0 + 4, 44), WOOD_D)
    c.add(rect(2, 23, 46, 31), WOOD, stitch=THREAD)
    for x in (11, 20, 29, 38):
        c.line([(x, 24), (x, 29)], "#7a4a1f")
    c.add(rect(38, 9, 43, 31), WOOD_D)
    c.add(rect(5, 16, 9, 31), WOOD_D)
    c.add(rect(4, 14, 10, 17), WOOD_D, shade=False)
    c.add(OR(rect(38, 14, 43, 16), rect(38, 18, 43, 20)), CANVAS, shade=False)
    c.add(rect(37, 7, 44, 10), WOOD_D, shade=False)
    for x0 in (4, 18, 30):
        c.line([(x0, 37), (x0 + 2, 36), (x0 + 4, 36), (x0 + 6, 37)], "#a9d6ea")


if __name__ == '__main__':
    run('jetty', draw)
