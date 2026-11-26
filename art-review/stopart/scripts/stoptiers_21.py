#!/usr/bin/env python3
"""POLISH of game/assets/img/stoptiers/market-1.png (96x96 RGBA tier sticker). Staging only: writes art-review/stopart/out/stoptiers/market-1.png."""
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from stoptiers_kit import *  # noqa

NAME = 'market-1'


def retouch(im):
    pass


if __name__ == '__main__':
    im = load(NAME)
    retouch(im)
    finish(NAME, im)
