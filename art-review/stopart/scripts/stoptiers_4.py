#!/usr/bin/env python3
"""POLISH of game/assets/img/stoptiers/camp-4.png (96x96 RGBA tier sticker). Staging only: writes art-review/stopart/out/stoptiers/camp-4.png."""
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from stoptiers_kit import *  # noqa

NAME = 'camp-4'


def retouch(im):
    """The near-black orb inside the gold rim reads as a pot; make it a round plank door (lit upper left, knob, centre seam)."""
    box = (20 * 2, 27 * 2, 27 * 2, 38 * 2)
    remap(im, box, {'3d2a1c': '#8a4f2a', '2e1c15': '#6a3a20', '200f0f': '#4a2c1a', '322317': '#4a2c1a',
                    'a68e46': '#b07a45', 'cdbc88': '#d9a660'})
    for y in range(29 * 2, 37 * 2):            # centre seam
        p = im.getpixel((23 * 2, y))
        if hexof(p) in ('8a4f2a', '6a3a20', 'b07a45'):
            for dx in (0, 1):
                im.putpixel((23 * 2 + dx, y), hexrgba('#4a2c1a'))
    paint(im, 25, 32, ['K'], {'K': '#e8a317'})   # knob


if __name__ == '__main__':
    im = load(NAME)
    retouch(im)
    finish(NAME, im)
