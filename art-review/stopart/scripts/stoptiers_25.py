#!/usr/bin/env python3
"""POLISH of game/assets/img/stoptiers/mill-1.png (96x96 RGBA tier sticker). Staging only: writes art-review/stopart/out/stoptiers/mill-1.png."""
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from stoptiers_kit import *  # noqa

NAME = 'mill-1'


def retouch(im):
    """The open gap under the crane beam becomes one die-cut piece: mid felt backing (not a dark slab), umber contour where
    it meets the drawing, a lit upper-left edge and a deeper lower-right edge, so it reads as sticker felt behind the sacks."""
    W, H = im.size
    s = sil(im)
    seen = set()
    stack = [p for p in [(x, y) for x in range(W) for y in (0, H - 1)] + [(x, y) for y in range(H) for x in (0, W - 1)] if p not in s]
    seen.update(stack)
    while stack:
        x, y = stack.pop()
        for dx, dy in N4:
            q = (x + dx, y + dy)
            if 0 <= q[0] < W and 0 <= q[1] < H and q not in s and q not in seen:
                seen.add(q)
                stack.append(q)
    hole = {(x, y) for y in range(H) for x in range(W) if (x, y) not in s and (x, y) not in seen}
    for (x, y) in hole:
        col = BAND_MID
        if (x - 2, y) not in hole or (x, y - 2) not in hole:
            col = BAND_LIGHT
        if (x + 2, y) not in hole or (x, y + 2) not in hole:
            col = '#4a2c1a'
        im.putpixel((x, y), hexrgba(col))
    for (x, y) in hole:
        for dx in (-1, 0, 1):
            for dy in (-1, 0, 1):
                q = (x + dx, y + dy)
                if q not in hole and q in s and im.getpixel(q)[:3] == (0, 0, 0):
                    im.putpixel(q, hexrgba(BAND_DARK))


if __name__ == '__main__':
    im = load(NAME)
    retouch(im)
    finish(NAME, im)
