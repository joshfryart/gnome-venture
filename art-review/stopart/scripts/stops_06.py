#!/usr/bin/env python3
"""Stitched Toy redraw of game/assets/img/stops/market.png (48x48 RGBA). Staging only: writes art-review/stopart/out/stops/market.png."""
import math, os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from stops_kit import *  # noqa


def draw(c):
    c.add(rect(7, 18, 41, 33), DARK)
    c.add(rect(4, 18, 8, 45), WOOD_D)
    c.add(rect(40, 18, 44, 45), WOOD_D)
    for i, (cx, col) in enumerate(((12, RED), (19, GOLD), (26, LEAF), (33, RED))):
        c.add(ell(cx + 0.5, 30, 3.8, 3.6), col)
    c.add(rect(3, 33, 45, 45), WOOD, stitch=THREAD)
    top = poly([(7, 5), (41, 5), (46, 17), (2, 17)])
    for k in range(7):
        x0 = 2 + k * 6.3
        band = lambda x, y, x0=x0: x0 <= x < x0 + 6.3
        col = RED if k % 2 == 0 else CLOTH
        c.add(OR(AND(top, band), AND(ell(x0 + 3.15, 17, 3.15, 3.2), band)), col)
    c.line([(5, 7), (43, 7)], "#e8a317")


if __name__ == '__main__':
    run('market', draw)
