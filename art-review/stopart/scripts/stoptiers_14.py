#!/usr/bin/env python3
"""POLISH of game/assets/img/stoptiers/inn-2.png (96x96 RGBA tier sticker). Staging only: writes art-review/stopart/out/stoptiers/inn-2.png."""
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from stoptiers_kit import *  # noqa

NAME = 'inn-2'


HORSE = {'o': '#20100c', 'K': '#2a1a10', 'L': '#c47a52', 'H': '#a8582f', 'S': '#803424', 'M': '#57181d',
         'W': '#eaddb8', 'E': '#20100c', 'w': '#fff1c8', 'N': '#d9a07a', 'P': '#9e4936'}


def retouch(im):
    """The muddled stall horse is redrawn front-on in the same stall: chestnut head lit upper left,
    dark forelock, white blaze, two eyes, pale muzzle with nostrils."""
    for y in range(57, 86):
        for x in range(63, 82):
            im.putpixel((x, y), hexrgba('#2a1a10'))
    paint(im, 61, 58, [
        '...oo.........oo...',
        '..oLLo.......oHSo..',
        '..oLHo.......oHSo..',
        '..oLHHoooooooHHSo..',
        '...oLHMMMMMMMHSo...',
        '...oLHHMMMMMHHSo...',
        '...oLHHHMMMHHHSo...',
        '..oLLHHHHWHHHHSSo..',
        '..oLEEHHHWHHHEESo..',
        '..oLEwHHHWHHHEwSo..',
        '..oLHHHHHWHHHHHSo..',
        '...oLHHHHWHHHHSo...',
        '...oLHHHHWHHHHSo...',
        '...oLHHHHWHHHHSo...',
        '...oLHHHHWHHHHSo...',
        '...oLHHHWWWHHHSo...',
        '...oLHHHWWWHHHSo...',
        '..oNNNNNNNNNNNPPo..',
        '..oNNNNNNNNNNNNPo..',
        '..oNEENNNNNNEENPo..',
        '..oNEENNNNNNEEPPo..',
        '..oNNNNNNNNNNNPPo..',
        '...oPPNNNNNNPPPo...',
        '...ooPPPPPPPPPoo...',
        '.....ooooooooo.....',
    ], HORSE, scale=1)


if __name__ == '__main__':
    im = load(NAME)
    retouch(im)
    finish(NAME, im)
