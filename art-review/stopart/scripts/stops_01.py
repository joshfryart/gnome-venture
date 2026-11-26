#!/usr/bin/env python3
"""Stitched Toy redraw of game/assets/img/stops/camp.png (48x48 RGBA). Staging only: writes art-review/stopart/out/stops/camp.png."""
import math, os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from stops_kit import *  # noqa


def draw(c):
    c.add(ell(24, 42.5, 22.5, 4.5), MOSS)
    c.add(thick_path([(19, 9), (19, 2)], 2), WOOD_D, shade=False)
    c.add(poly([(2, 42), (19, 7), (36, 42)]), CANVAS, stitch=THREAD_B)
    c.add(poly([(13, 42), (19, 23), (25, 42)]), DARK)
    c.add(poly([(19, 23), (25, 42), (28, 42)]), CANVAS)
    c.add(poly([(30, 40), (31, 29), (34, 32), (37.5, 18), (41, 28), (43.5, 25), (46, 40)]), FLAME)
    c.add(poly([(33.5, 40), (35.5, 32), (37.5, 35), (39.5, 28), (42.5, 40)]), FLAME_IN, shade=False)
    c.add(thick_path([(29, 43.5), (46, 38.5)], 3.2), WOOD)
    c.add(thick_path([(29, 38.5), (46, 43.5)], 3.2), WOOD_D)


if __name__ == '__main__':
    run('camp', draw)
