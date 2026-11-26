#!/usr/bin/env python3
"""POLISH of game/assets/img/stoptiers/camp-2.png (96x96 RGBA tier sticker). Staging only: writes art-review/stopart/out/stoptiers/camp-2.png."""
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from stoptiers_kit import *  # noqa

NAME = 'camp-2'


FLAME = {'Q': '#e0501f', 'O': '#ae2a2a', 'P': '#ff9158', 'R': '#ffc27a', 'U': '#ffd86a', 'L': '#3d2a1c',
         'E': '#b07a45', 'F': '#8a4f2a', 'C': '#d9a660', 'S': '#5e2f1e', 'H': '#2a1a10'}


def retouch(im):
    """The flat flame triangle with a yellow disc becomes three stepped felt tongues (light left, shade right);
    the plum logs become brown logs with cut ends."""
    # clear the old flame back to the hood's dark felt (art px x17..31, y17..29)
    for y in range(17 * 2, 30 * 2):
        for x in range(17 * 2, 32 * 2):
            if hexof(im.getpixel((x, y))) in ('e0501f', 'ae2a2a', 'ff9158', 'ffc27a', 'ffd86a'):
                im.putpixel((x, y), hexrgba('#3d2a1c'))
    paint(im, 17, 17, [
        '.......Q.......',
        '.......QO......',
        '......QPO......',
        '....Q.QPQO.....',
        '....QOQPQO.Q...',
        '...QPQQRPQOQO..',
        '...QPQRURQQPO..',
        '..QPQRUUURQPOO.',
        '..QPRUUUUURQQO.',
        '.QPRUUUUUUURQO.',
        '.QPRUUUUUUURQOO',
        '.QQRRUUUUURRQOO',
        '.OQQRRRRRRRQQOO',
    ], FLAME)
    paint(im, 16, 30, [
        'CEEEEEEUUUEEEEEEC',
        'CFFSFFFFFFFFSFFFC',
    ], FLAME)


if __name__ == '__main__':
    im = load(NAME)
    retouch(im)
    finish(NAME, im)
