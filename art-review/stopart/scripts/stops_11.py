#!/usr/bin/env python3
"""Stitched Toy redraw of game/assets/img/stops/tower.png (48x48 RGBA). Staging only: writes art-review/stopart/out/stops/tower.png."""
import math, os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from stops_kit import *  # noqa


def draw(c):
    c.add(ell(24, 45, 14, 2.6), MOSS)
    c.add(poly([(18.5, 13), (20.5, 6), (22.5, 9), (24, 1), (25.5, 9), (27.5, 6), (29.5, 13)]), FLAME)
    c.add(poly([(21, 13), (23, 7), (24, 10), (25, 7), (27, 13)]), FLAME_IN, shade=False)
    c.add(poly([(14, 46), (16, 19), (32, 19), (34, 46)]), STONE, stitch=THREAD)
    c.add(OR(rect(12, 14, 36, 20), rect(12, 9, 18, 14), rect(30, 9, 36, 14)), ("#86828e", "#55525e", "#b4b0bc"))
    c.add(ell(24, 14, 6, 2.5), DARK, shade=False)
    c.add(OR(rect(20, 36, 28, 46), ell(24, 36, 4, 4)), WOOD_D)
    c.add(OR(rect(23, 24, 25, 30)), DARK, shade=False)
    c.line([(17, 33), (19, 33)], "#66626e")
    c.line([(29, 28), (31, 28)], "#66626e")


if __name__ == '__main__':
    run('tower', draw)
