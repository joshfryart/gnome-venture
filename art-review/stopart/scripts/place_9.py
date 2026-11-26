#!/usr/bin/env python3
"""Stitched Toy redraw of game/assets/img/town/place-teahouse.png (144x108 RGBA card). Staging only: writes art-review/stopart/out/town/place-teahouse.png."""
import math, os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from place_kit import *  # noqa


def draw(c):
    c.bg(lambda x, y: True, CREAMWALL, shade=False)
    for y in range(18, 88, 10):
        c.uline([(8, y), (135, y)], CREAMWALL[1])
    c.bg(lambda x, y: y >= 88, PLANK, shade=False)
    for x in range(16, 136, 16):
        c.uline([(x, 89), (x, 99)], PLANK[1])
    c.uline([(8, 88), (135, 88)], PLANK[2])
    c.g = 'window'
    c.add(rect(12, 12, 50, 48), WOOD)
    c.add(rect(16, 16, 46, 44), ('#f5cf6a', '#e8a317', '#fde68a'), shade=False)
    c.add(ell(36, 25, 5, 5), ('#f8f0c0', '#f5cf6a', '#ffffff'), shade=False)
    c.add(rect(29, 16, 33, 44), WOOD)
    c.add(rect(16, 28, 46, 32), WOOD)
    c.g = 'shelf'
    c.add(rect(88, 30, 134, 34), WOOD)
    c.add(rect(92, 34, 95, 40), WOOD_D)
    c.add(rect(127, 34, 130, 40), WOOD_D)
    for i, (x, rp) in enumerate(((92, TEAPOT), (103, BLUE), (114, GREEN), (124, GOLD))):
        c.g = 'tin%d' % i
        c.add(rect(x, 20, x + 8, 30), rp)
        c.add(rect(x, 18, x + 8, 21), DARK)
    c.g = 'table'
    c.add(rect(108, 72, 113, 90), WOOD_D)
    c.add(rect(88, 68, 132, 73), WOOD)
    c.g = 'pot'
    c.add(thick_path([(116, 56), (124, 50)], 3), TEAPOT)
    c.add(OR(ell(104, 58, 6, 5), ell(92, 58, 2.5, 3.5)), TEAPOT, shade=True)
    c.add(ell(105, 59, 11, 9), TEAPOT, stitch=CREAM)
    c.add(OR(rect(102, 47, 109, 51), ell(105.5, 46, 2, 2)), DARK)
    c.g = 'cup'
    c.add(rect(119, 61, 128, 68), PAPER)
    c.add(rect(128, 62, 131, 65), PAPER)
    c.g = 'plant'
    c.add(OR(ell(66, 64, 5, 7), ell(74, 60, 5, 9), ell(80, 66, 5, 6)), HERB)
    c.add(poly([(64, 72), (84, 72), (81, 90), (67, 90)]), TERRA)
    c.add(rect(63, 70, 85, 75), TERRA)
    c.g = None
    for (x, y) in ((123, 56), (124, 54), (123, 52), (126, 57), (127, 55), (104, 41), (105, 39), (104, 37)):
        c.px(x, y, '#ffffff')


if __name__ == '__main__':
    run('teahouse', draw)
