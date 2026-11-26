#!/usr/bin/env python3
"""POLISH of game/assets/img/stoptiers/herb-2.png (96x96 RGBA tier sticker). Staging only: writes art-review/stopart/out/stoptiers/herb-2.png."""
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from stoptiers_kit import *  # noqa

NAME = 'herb-2'


HEN = {'g': '#2a1a10', 'o': '#2a1a10', 'T': '#f1ece0', 'U': '#d7bfa7', 'S': '#a7664b', 'C': '#dd3a2a',
       'B': '#f2793a', 'V': '#e8a317', 'X': '#688f41', 'Y': '#7ab55c'}


def retouch(im):
    """The muddled hen is redrawn in the same spot: cream felt body lit upper left, red comb and wattle, gold beak and feet."""
    paint(im, 29, 31, [
        '......goBoBog',
        '......oCCCCog',
        '......oTTTTog',
        '......oTTgTVg',
        'ggggggoTTTUog',
        'goooggTTTUCog',
        'oTTToTTTTUogg',
        'oUTTTTTTTUogg',
        'oUTTTTTTUSogg',
        'YoUUUUUSSoXgg',
        'XXoVooVoXXXgg',
    ], HEN)


if __name__ == '__main__':
    im = load(NAME)
    retouch(im)
    finish(NAME, im)
