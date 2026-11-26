#!/usr/bin/env python3
"""POLISH of game/assets/img/stoptiers/spring-3.png (96x96 RGBA tier sticker). Staging only: writes art-review/stopart/out/stoptiers/spring-3.png."""
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from stoptiers_kit import *  # noqa

NAME = 'spring-3'


def retouch(im):
    # The three cream discs in the pool read as eyes / teeth. Make them foam bubbles that sit IN the water:
    # cream body -> steam-bubble blue (same ramp as the steam above), umber ring -> deep pool blue, plus a white glint upper-left and a blue shade lower-right.
    box = (26, 46, 70, 70)
    remap(im, box, {'f1ece0': '#b8d4d8', 'ceb393': '#8fb4c4', '2a1a10': '#2f6290'})
    snap = im.copy()

    def foam(x, y):
        return hexof(snap.getpixel((x, y))) == 'b8d4d8'
    for y in range(box[1], box[3], 2):        # art pixels (the set is drawn on a 2x grid)
        for x in range(box[0], box[2], 2):
            if not foam(x, y):
                continue
            up, lf, dn, rt = foam(x, y - 2), foam(x - 2, y), foam(x, y + 2), foam(x + 2, y)
            col = None
            if not up and not lf:
                col = '#f0fcf8'
            elif not dn or not rt:
                col = '#8fb4c4'
            if col:
                paint(im, x // 2, y // 2, ['a'], {'a': col})


if __name__ == '__main__':
    im = load(NAME)
    retouch(im)
    finish(NAME, im)
