#!/usr/bin/env python3
"""Stitched Toy redraw of game/assets/img/town/place-monastery.png (144x108 RGBA card). Staging only: writes art-review/stopart/out/town/place-monastery.png."""
import math, os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from place_kit import *  # noqa


def draw(c):
    sky_hills(c, horizon=86, hills=False, clouds=((26, 16, 12, 4), (112, 14, 9, 3)))
    tufts(c, [(18, 95), (46, 93), (88, 96), (124, 94)])
    c.g = 'mount'
    c.add(poly([(4, 90), (68, 20), (140, 90)]), GREY, stitch=STONE[2])
    c.add(poly([(56, 33), (68, 20), (80, 33), (74, 30), (68, 35), (62, 30)]), SNOW, shade=False)
    c.bg(lambda x, y: y > 86, GRASS)
    # prayer flags on a sagging line
    flags = [BLUE, SNOW, RED, GREEN, YELLOWP]
    pts = [(x, 40 + 5 * math.sin(math.pi * (x - 8) / 128)) for x in range(8, 137)]
    for (x, y) in pts:
        c.px(x, round(y), UMBER)
    for i, x in enumerate(range(12, 132, 11)):
        y = round(40 + 5 * math.sin(math.pi * (x - 8) / 128)) + 1
        c.add(rect(x, y, x + 7, y + 7), flags[i % 5], group='flag%d' % i)
    c.g = 'house'
    c.add(rect(92, 58, 130, 88), CREAMWALL, stitch=THREAD_B)
    c.add(poly([(86, 60), (111, 46), (136, 60)]), RED)
    c.add(rect(106, 70, 115, 88), WOOD_D)
    c.add(rect(96, 66, 102, 72), DARK)
    c.add(rect(120, 66, 126, 72), DARK)
    c.g = 'bench'
    c.add(rect(48, 76, 52, 89), WOOD_D)
    c.add(rect(68, 76, 72, 89), WOOD_D)
    c.add(rect(45, 74, 75, 78), WOOD)
    c.add(rect(47, 64, 73, 68), WOOD)
    c.add(rect(48, 68, 51, 74), WOOD_D)
    c.add(rect(69, 68, 72, 74), WOOD_D)
    c.g = None
    c.px(113, 79, GOLD[0])


if __name__ == '__main__':
    run('monastery', draw)
