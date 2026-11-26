#!/usr/bin/env python3
"""POLISH of game/assets/img/stoptiers/jetty-1.png (96x96 RGBA tier sticker). Staging only: writes art-review/stopart/out/stoptiers/jetty-1.png."""
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from stoptiers_kit import *  # noqa

NAME = 'jetty-1'


def retouch(im):
    """The unreadable grey nubs sticking up off the crate are removed so the crate top is one clean lit edge."""
    for y in range(0, 26):
        for x in range(30, 60):
            im.putpixel((x, y), CLEAR)


if __name__ == '__main__':
    im = load(NAME)
    retouch(im)
    finish(NAME, im)
