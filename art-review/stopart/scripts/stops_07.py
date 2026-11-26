#!/usr/bin/env python3
"""Stitched Toy redraw of game/assets/img/stops/mill.png (48x48 RGBA). Staging only: writes art-review/stopart/out/stops/mill.png."""
import math, os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from stops_kit import *  # noqa


def draw(c):
    c.add(ell(24, 44.5, 15, 3), MOSS)
    c.add(poly([(14, 45), (18, 19), (30, 19), (34, 45)]), CANVAS, stitch=THREAD_B)
    c.add(poly([(15, 21), (24, 11), (33, 21)]), RED)
    c.add(OR(rect(21, 37, 27, 45), ell(24, 37, 3, 3)), WOOD_D)
    c.add(OR(rect(22, 26, 26, 30)), GLASS, shade=False)
    hub = (24, 17)
    for a in (45, 135, 225, 315):
        r = math.radians(a)
        ux, uy, qx, qy = math.cos(r), math.sin(r), -math.sin(r), math.cos(r)
        P = lambda d, w: (hub[0] + ux * d + qx * w, hub[1] + uy * d + qy * w)
        c.add(poly([P(4, 0.5), P(21, 0.5), P(21, 6.5), P(4, 6.5)]), CLOTH)
    for a in (45, 135, 225, 315):
        r = math.radians(a)
        c.add(thick_path([hub, (hub[0] + math.cos(r) * 21, hub[1] + math.sin(r) * 21)], 2.2), WOOD_D, shade=False)
    c.add(ell(24, 17, 2.8, 2.8), GOLD, shade=False)


if __name__ == '__main__':
    run('mill', draw)
