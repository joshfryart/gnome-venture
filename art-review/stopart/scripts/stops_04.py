#!/usr/bin/env python3
"""Stitched Toy redraw of game/assets/img/stops/inn.png (48x48 RGBA). Staging only: writes art-review/stopart/out/stops/inn.png."""
import math, os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from stops_kit import *  # noqa


def draw(c):
    c.add(ell(24, 43.5, 22, 3.5), MOSS)
    c.add(rect(31, 5, 37, 17), ("#a8574a", "#6e3028", "#d0806a"))
    c.add(rect(30, 3, 38, 6), STONE, shade=False)
    c.add(rect(8, 22, 40, 44), PLASTER, stitch=THREAD_B)
    c.add(poly([(2, 26), (24, 5), (46, 26)]), RED, stitch=THREAD)
    c.add(OR(rect(20, 32, 28, 44), ell(24, 32.5, 4, 3.5)), WOOD_D)
    c.px(26, 38, "#f5cf6a")
    for x0 in (11, 31):
        c.add(rect(x0, 29, x0 + 6, 36), GLASS, shade=False)
        c.line([(x0 + 3, 29), (x0 + 3, 35)], CONTOUR)
        c.line([(x0, 32), (x0 + 5, 32)], CONTOUR)
    c.add(OR(rect(21, 21, 27, 25)), GOLD, shade=False)


if __name__ == '__main__':
    run('inn', draw)
