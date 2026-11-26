#!/usr/bin/env python3
"""POLISH of game/assets/img/stoptiers/market-3.png (96x96 RGBA tier sticker). Staging only: writes art-review/stopart/out/stoptiers/market-3.png."""
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from stoptiers_kit import *  # noqa

NAME = 'market-3'


GOODS = {'o': '#2a1a10', 'R': '#dd3a2a', 'r': '#ff9158', 'Y': '#e8a317', 'y': '#ffd86a', 'G': '#688f41', 'g': '#a8d070',
         'D': '#ae2a2a', 'B': '#b8661a', 'F': '#4a7a35'}


def retouch(im):
    """The stall openings under the two awnings (see-through holes in the shipped sticker) get a row of
    produce on the counter, like the tier-1 stall, so they read as stalls and not as gaps."""
    fruit = ['.ooo.', 'o{l}{m}{m}o', 'o{m}{m}{d}o', '.ooo.']
    def row(cols):
        rows = ['', '', '', '']
        for (l, m, d) in cols:
            for k, t in enumerate(fruit):
                rows[k] += t.format(l=l, m=m, d=d)
        return rows
    paint(im, 12, 39, row([('r', 'R', 'D'), ('y', 'Y', 'B'), ('g', 'G', 'F')]), GOODS, scale=1)
    paint(im, 62, 39, row([('g', 'G', 'F'), ('r', 'R', 'D'), ('y', 'Y', 'B')]), GOODS, scale=1)


if __name__ == '__main__':
    im = load(NAME)
    retouch(im)
    finish(NAME, im)
