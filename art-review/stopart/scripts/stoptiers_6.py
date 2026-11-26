#!/usr/bin/env python3
"""POLISH of game/assets/img/stoptiers/ferry-2.png (96x96 RGBA tier sticker). Staging only: writes art-review/stopart/out/stoptiers/ferry-2.png."""
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from stoptiers_kit import *  # noqa

NAME = 'ferry-2'


def retouch(im):
    """The see-through gap under the boom becomes sticker felt: hole filled (old black ring -> umber contour),
    band-mid felt, and a dashed gold thread through it."""
    fill_holes(im)
    remap(im, (56, 48, 70, 58), {'4a2c1a': '#74462a'})
    for x in range(58, 66, 3):  # dashed thread through the felt
        for dx in (0, 1):
            if hexof(im.getpixel((x + dx, 53))) == '74462a':
                im.putpixel((x + dx, 53), hexrgba('#e8a317'))


if __name__ == '__main__':
    im = load(NAME)
    retouch(im)
    finish(NAME, im)
