#!/usr/bin/env python3
"""pl-baob-1 "Pot Simmer": corner-TB, round. A lidded clay stew pot that is a corner piece.
Flat W (pot wall) and flat S (pot base on the step); round tab N = the lid's knob handle; round blank E cut into the belly.
Colours from cell 3-7 of the baobab inn: peach/terracotta clay, mauve dusk-hill lid, sand-dune belly band with dots."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, thick_path, knob

CLAY = K.ramp('#c8946c')
PEACH = K.ramp('#f0b080')
LID = K.ramp('#8a5a60')
LIDDK = K.ramp('#6e394e')
SAND = K.ramp('#f2c890')
STEW = K.ramp('#c07a58')
CREAMD = '#f9dca8'


def fn(c):
    Kk = 1.15 if c.small else 1.0
    # pot core: straight W and S sides, slight rounded shoulder at the top right only
    core = poly([(10, 21), (52, 21), (52, 58), (10, 58)])
    lidc = lambda x, y: 11 <= x < 51 and 13 <= y < 22 and ((x - 31) / 20.5) ** 2 + ((y - 22) / 9.5) ** 2 < 1
    rim = rect(8.5, 19.5, 53.5, 24.5)
    tabN = knob('T', 'round', 31, 13.5, 0, -1, r=4.8 * Kk)
    blankE = knob('B', 'round', 52, 42, 1, 0, r=4.6 * Kk)
    body = c.m(core, minus=(blankE,))
    c.add(body, CLAY, stitch=None)
    # peach front glow of the clay (light from the upper left)
    c.add(body & c.m(rect(13, 25, 19, 44)), PEACH)
    # sand band with dots (the dune ground of the picture)
    band = body & c.m(rect(10, 44, 53, 51))
    c.add(band, SAND)
    # lid dome + knob (the tab)
    c.add(c.m(lidc), LID, stitch='#a87478' if not c.small else None)
    c.add(c.m(tabN, minus=(lidc,)), LIDDK)
    # wooden ladle poking out under the lid, steam curl on the left
    c.add(c.m(thick_path([(45, 20), (51.5, 7.5)], 3.2 if not c.small else 3.6)), K.ramp('#b07a3a'))
    c.add(c.m(thick_path([(16, 15), (13.5, 11), (16.5, 7.5), (14, 3.5)], 2.8 if not c.small else 3.2)), K.ramp('#f9dca8'))
    # rim / lip, wider than the body
    c.add(c.m(rim), STEW)
    c.edge(c.m(rim), CLAY[1])
    # stew drip over the rim at the left
    c.add(c.m(ell(15, 25, 2.2, 2.6)), SAND)
    # dots on the band
    if not c.small:
        for gx in (14, 20, 26, 32, 38, 44):
            x, y = c.P(gx, 47.5)
            c.px(x, y, STEW[0]); c.px(x + 1, y, STEW[0])
    else:
        for gx in (14, 24, 34, 44):
            x, y = c.P(gx, 47.5)
            c.px(x, y, STEW[0])
    # foot shadow line
    y = c.P(0, 55.5)[1]
    for x in range(c.n):
        if (x, y) in body:
            c.px(x, y, CLAY[1])
    # steam curls on the lid (64 px only)
    if not c.small:
        pass
    # face on the belly
    c.eye(24, 33)
    c.eye(36, 33)
    c.smile(30, 38, wide=not c.small)
    c.blush(19.5, 37)
    c.blush(40, 37)


if __name__ == '__main__':
    rep = K.render_pal(fn, 'pl-baob-1', 'Pot Simmer', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-baob-1-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-baob-1.png')
    print(rep)
