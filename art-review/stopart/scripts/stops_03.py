#!/usr/bin/env python3
"""Stitched Toy redraw of game/assets/img/stops/herb.png (48x48 RGBA). Staging only: writes art-review/stopart/out/stops/herb.png."""
import math, os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from stops_kit import *  # noqa


def draw(c):
    c.add(ell(24, 42.5, 17, 4.5), SOIL, stitch=THREAD)
    c.add(thick_path([(24, 42), (24, 11)], 3), ("#3f7a3a", "#2f5a2a", "#6aa04a"), shade=False)
    leaves = [(14, 31, 10, 6, -25), (34, 29, 10, 6, 25), (16, 19, 8, 5, -30), (32, 17, 8, 5, 30)]
    for cx, cy, rx, ry, a in leaves:
        c.add(rot_ell(cx, cy, rx, ry, a), LEAF)
    for cx, cy, rx, ry, a in leaves:
        r = math.radians(a)
        dx, dy = math.cos(r) * (rx - 2), math.sin(r) * (rx - 2)
        c.line([(round(cx - dx), round(cy - dy)), (round(cx + dx * 0.6), round(cy + dy * 0.6))], "#2f6a3a")
    c.add(OR(ell(24, 8, 4.2, 4.2), ell(20, 11, 2.6, 2.6), ell(28, 11, 2.6, 2.6)), PURPLE)
    c.px(23, 6, "#c8b8ec")


if __name__ == '__main__':
    run('herb', draw)
