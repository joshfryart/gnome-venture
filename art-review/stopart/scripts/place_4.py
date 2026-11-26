#!/usr/bin/env python3
"""Stitched Toy redraw of game/assets/img/town/place-library.png (144x108 RGBA card). Staging only: writes art-review/stopart/out/town/place-library.png."""
import math, os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from place_kit import *  # noqa


BOOKS = [('#c8382e', '#8e221c', '#ec6a4e'), ('#3f7fc8', '#245a8e', '#7aaee0'), ('#e8a317', '#b07a10', '#f5cf6a'),
         ('#5a46a0', '#3a2c6e', '#8a78c8'), ('#3f9a4a', '#2f6a3a', '#7ab55c'), ('#f4f0e4', '#c9c5bc', '#ffffff'),
         ('#2a9a9a', '#1d7378', '#7fd0c8')]


def draw(c):
    c.bg(lambda x, y: True, WALLWOOD, shade=False)
    for x in range(70, 136, 12):
        c.uline([(x, 8), (x, 83)], WALLWOOD[1])
    c.bg(lambda x, y: y >= 84, PLANK, shade=False)
    for x in range(20, 136, 18):
        c.uline([(x, 85), (x, 99)], PLANK[1])
    c.uline([(8, 84), (135, 84)], PLANK[2])
    # bookshelf
    c.g = 'shelf'
    c.add(rect(9, 9, 62, 85), WOOD_D)
    rows = [(12, 25), (29, 42), (46, 59), (63, 76)]
    k = 0
    for (y0, y1) in rows:
        c.add(rect(12, y0, 59, y1 + 1), DARK, shade=False)
    for (y0, y1) in rows:
        x = 13
        while x < 56:
            w = 3 + (k * 7) % 3
            h = (y1 - y0) - (k * 5) % 4
            if x + w > 58:
                break
            c.add(rect(x, y1 - h + 1, x + w, y1 + 1), BOOKS[(k * 3) % len(BOOKS)], contour=False)
            x += w + (1 if k % 4 == 3 else 0)
            k += 1
        c.add(rect(10, y1 + 1, 61, y1 + 4), WOOD)
    c.g = None
    # hanging lamp
    c.line([(116, 8), (116, 20)], UMBER)
    c.g = 'lamp'
    c.add(rect(112, 20, 121, 23), WOOD_D)
    c.add(rect(113, 23, 120, 31), GOLD)
    c.g = 'chair'
    c.add(rect(72, 58, 75, 90), WOOD_D)
    c.add(rect(84, 72, 87, 90), WOOD_D)
    c.add(rect(72, 70, 88, 74), WOOD)
    c.add(rect(72, 52, 86, 62), RED)
    c.g = 'lectern'
    c.add(poly([(100, 88), (104, 62), (112, 62), (116, 88)]), WOOD)
    c.add(poly([(94, 60), (124, 52), (126, 58), (96, 66)]), WOOD_D)
    c.g = 'book'
    c.add(poly([(95, 55), (109, 50), (110, 57), (96, 61)]), PAPER)
    c.add(poly([(110, 50), (124, 46), (125, 53), (111, 57)]), PAPER)
    c.g = None
    c.line([(98, 56), (106, 53)], UMBER2)
    c.line([(113, 51), (121, 48)], UMBER2)


if __name__ == '__main__':
    run('library', draw)
