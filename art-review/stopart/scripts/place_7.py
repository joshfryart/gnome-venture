#!/usr/bin/env python3
"""Stitched Toy redraw of game/assets/img/town/place-special.png (144x108 RGBA card). Staging only: writes art-review/stopart/out/town/place-special.png."""
import math, os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from place_kit import *  # noqa


def star(cx, cy, r1, r2):
    pts = []
    for i in range(10):
        a = -math.pi / 2 + i * math.pi / 5
        r = r1 if i % 2 == 0 else r2
        pts.append((cx + r * math.cos(a), cy + r * math.sin(a)))
    return poly(pts)


def draw(c):
    sky_hills(c, horizon=80, clouds=((28, 16, 13, 4), (118, 22, 8, 3)))
    tufts(c, [(14, 92), (30, 96), (108, 94), (128, 91)])
    c.bg(poly([(62, 84), (84, 84), (112, 100), (36, 100)]), PATH)
    c.g = 'stump'
    c.add(OR(rect(30, 76, 40, 88), poly([(27, 89), (30, 83), (30, 89)]), poly([(43, 89), (40, 83), (40, 89)])), WOOD)
    c.add(ell(35, 76, 5, 2), CANVAS, shade=False)
    c.g = 'sign'
    c.add(rect(70, 36, 77, 88), WOOD_D)
    c.add(poly([(46, 46), (104, 46), (112, 53), (104, 60), (46, 60)]), WOOD, stitch=THREAD)
    c.g = 'star'
    c.add(star(73.5, 27, 15, 7), GOLD, stitch=GOLD[2])
    c.g = None
    c.px(70, 24, UMBER); c.px(70, 25, UMBER); c.px(76, 24, UMBER); c.px(76, 25, UMBER)


if __name__ == '__main__':
    run('special', draw)
