#!/usr/bin/env python3
"""POLISH of game/assets/img/stoptiers/inn-1.png (96x96 RGBA tier sticker). Staging only: writes art-review/stopart/out/stoptiers/inn-1.png."""
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from stoptiers_kit import *  # noqa

NAME = 'inn-1'


FIRE = {'Q': '#e0501f', 'O': '#ae2a2a', 'P': '#ff9158', 'R': '#ffc27a', 'U': '#ffd86a', 'K': '#2a1a10',
        'E': '#b07a45', 'F': '#6b3a1f', 'C': '#20100c', 'S': '#3d2a1c'}


def retouch(im):
    """The flat orange dome in the hearth becomes stepped felt flame tongues (lit left, ember right) on two cut logs."""
    for y in range(52, 75):
        for x in range(36 if y < 67 else 42, 66):
            if hexof(im.getpixel((x, y))) in ('e0501f', 'ae2a2a', 'ff9158', 'ffc27a', 'ffd86a', 'e8a317', 'b8661a',
                                              '6b1b2c', 'dd3a2a', '20100c'):
                im.putpixel((x, y), hexrgba('#2a1a10'))
    paint(im, 43, 53, [
        '..........Q.........',
        '.........QQ.........',
        '.........QPQ.....Q..',
        '....Q...QPPQ.....QO.',
        '....QQ..QPPQO...QQO.',
        '...QPQ.QPPRQO..QPQO.',
        '...QPQQQPRRQQO.QPQO.',
        '..QPPQQPRRRPQOQPPQOO',
        '..QPRQPRRUURPQQPRQQO',
        '..QPRRPRUUURPQPRRPQO',
        '.QPRRRRUUUURRPPRURQO',
        '.QPRRUUUUUUURRRUURQO',
        '.QPRUUUUUUUUURUUURQO',
        '.QPRUUUUUUUUUUUUURQO',
        '.QQRRUUUUUUUUUUURRQO',
        '..QQRRRUUUUUUURRQQO.',
        '...OQQRRRRRRRRRQQOO.',
        'CEEEEEEEEEEEEEEEEEC.',
        'CFFSFFFFFFFFFFSFFFC.',
        '.CEEEEEEEEEEEEEEEEEC',
        '.CFFFFSFFFFFFSFFFFFC',
    ], FIRE, scale=1)


if __name__ == '__main__':
    im = load(NAME)
    retouch(im)
    finish(NAME, im)
