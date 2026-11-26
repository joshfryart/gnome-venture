#!/usr/bin/env python3
"""Stitched Toy redraw of game/assets/img/town/place-pub.png (144x108 RGBA card). Staging only: writes art-review/stopart/out/town/place-pub.png."""
import math, os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from place_kit import *  # noqa


def draw(c):
    c.bg(lambda x, y: True, WALLWOOD, shade=False)
    for y in range(22, 84, 9):
        c.uline([(8, y), (135, y)], WALLWOOD[1])
    c.bg(rect(0, 8, 200, 16), PLANK)
    c.bg(lambda x, y: y >= 86, PLANK, shade=False)
    for x in range(14, 136, 18):
        c.uline([(x, 87), (x, 99)], PLANK[1])
    c.uline([(8, 86), (135, 86)], PLANK[2])
    c.g = 'hearth'
    c.add(rect(10, 34, 54, 88), STONE, stitch=STONE[2])
    c.add(rect(7, 30, 57, 36), DGREY)
    c.add(rect(19, 52, 45, 88), ('#3d2a1c', '#2a1a10', '#4a2c1a'), shade=False)
    c.g = 'fire'
    c.add(poly([(21, 86), (23, 70), (27, 76), (32, 58), (37, 74), (40, 68), (43, 86)]), FLAME)
    c.add(poly([(26, 86), (29, 76), (32, 80), (35, 72), (39, 86)]), FLAME_IN, shade=False)
    c.g = 'logs'
    for (x, y) in ((58, 82), (66, 82), (62, 76)):
        c.add(ell(x + 3, y + 3, 3.5, 3.5), WOOD)
        c.px(x + 3, y + 3, WOOD[1])
    c.g = 'table'
    c.add(rect(80, 70, 85, 88), WOOD_D)
    c.add(rect(105, 70, 110, 88), WOOD_D)
    c.add(rect(74, 64, 116, 70), WOOD)
    for i, x in enumerate((80, 100)):
        c.g = 'mug%d' % i
        c.add(OR(rect(x + 9, 52, x + 13, 54), rect(x + 11, 52, x + 13, 60), rect(x + 9, 58, x + 13, 60)), GLASS)
        c.add(rect(x, 50, x + 10, 64), ALE)
        c.add(OR(rect(x - 1, 46, x + 11, 51), ell(x + 3, 47, 3, 2.5)), FOAM, shade=False)
    c.g = 'barrel'
    c.add(AND(ell(126, 77, 11, 14), rect(116, 66, 137, 88)), WOOD)
    c.add(AND(ell(126, 77, 11, 14), rect(116, 70, 137, 72)), DGREY, contour=False)
    c.add(AND(ell(126, 77, 11, 14), rect(116, 82, 137, 84)), DGREY, contour=False)
    c.g = None


if __name__ == '__main__':
    run('pub', draw)
