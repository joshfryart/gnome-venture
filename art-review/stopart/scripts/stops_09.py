#!/usr/bin/env python3
"""Stitched Toy redraw of game/assets/img/stops/shrine.png (48x48 RGBA). Staging only: writes art-review/stopart/out/stops/shrine.png."""
import math, os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from stops_kit import *  # noqa


def draw(c):
    c.add(OR(rect(8, 40, 18, 46), rect(30, 40, 40, 46)), STONE)
    c.add(rect(11, 13, 15, 41), RED)
    c.add(rect(33, 13, 37, 41), RED)
    c.add(rect(6, 19, 42, 23), RED)
    c.add(rect(5, 12, 43, 15), RED, shade=False)
    c.add(poly([(1, 3), (9, 7), (39, 7), (47, 3), (45, 13), (3, 13)]), PURPLE, stitch=THREAD)
    c.add(rect(21, 12, 27, 20), GOLD, shade=False)
    c.line([(24, 14), (24, 17)], "#7a4a1f")


if __name__ == '__main__':
    run('shrine', draw)
