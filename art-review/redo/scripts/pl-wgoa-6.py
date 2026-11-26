#!/usr/bin/env python3
"""pl-wgoa-6 "Supervising Billy" (rare, whimsy-goat, keyhole).
Concept: a cream-and-tan patched vineyard goat in side view whose woolly body IS a square piece: keyhole tab W (tail tuft),
keyhole blank N (dip in the back), keyhole blank S (the gap between the leg pairs), and the head + curled horn + purple grape
bunch break out of the NE corner as the goat's tab. Colours from the picture: cream wool, tan patches, sand horn, purple grapes,
vine green (cell 7-3 is the green terraced hill)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

WOOL = K.ramp('#f2e2c4')
PATCH = K.ramp('#a8785a')
LEGS = K.ramp('#a6886a')
HOOF = K.ramp('#754f44')
HORN = K.ramp('#dfbe80')
GRAPE = K.ramp('#8a5aa8')
LEAF = K.ramp('#6e9a4a')
NOSE = '#e8b8a0'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(8, 24, 46, 57)
    tabW = K.knob('T', 'keyhole', 8, 37, -1, 0, r=4.8 * k)
    blankN = K.knob('B', 'keyhole', 24, 24, 0, -1, r=4.6 * k)
    blankS = K.knob('B', 'keyhole', 27, 57, 0, 1, r=4.6 * k)
    # neck + head out of the NE corner
    neck = K.poly([(36, 26), (44, 13), (52, 12), (50, 28), (46, 30)])
    head = K.ell(50, 16, 7, 6)
    snout = K.poly([(52, 12), (60, 17), (59, 23), (53, 23), (47, 20)])
    body = c.m(core, tabW, neck, head, snout, minus=(blankN, blankS))
    c.add(body, WOOL, stitch=None if c.small else WOOL[1])
    # tan patches like the picture's goats
    c.add(body & c.m(K.ell(16, 41, 5, 4), K.ell(37, 44, 6.5, 5), minus=(blankN,)), PATCH)
    # legs: bottom band in leg tan, hooves
    legs = body & c.m(K.rect(8, 48, 46, 57))
    c.add(legs, LEGS)
    c.add(body & c.m(K.rect(8, 54, 46, 57)), HOOF)
    for gx in (16, 39):
        x, _ = c.P(gx, 0)
        for y in range(c.P(0, 50)[1], c.P(0, 57)[1]):
            if (x, y) in body:
                c.px(x, y, LEGS[1])
    # ear + horn curling back
    c.add(c.m(K.poly([(44, 16), (37, 18), (38, 21), (45, 20)])), PATCH)
    hw = 3.4 if not c.small else 4.0
    c.add(c.m(K.thick_path([(48, 12), (46, 6), (41, 3), (36, 4), (34, 8)], hw)), HORN)
    # beard
    c.add(c.m(K.poly([(52, 22), (56, 22), (54, 28)])), WOOL)
    # grape bunch in the mouth with a vine leaf
    gr = 2.4 if not c.small else 2.8
    c.add(c.m(*(K.ell(x, y, gr, gr) for x, y in ((57, 24), (61, 24), (59, 27.5), (55, 27.5), (57.5, 31), (61.5, 28)))), GRAPE)
    c.add(c.m(K.ell(61, 20, 2.6, 1.8)), LEAF)
    c.px(*c.P(59.5, 17), NOSE)
    c.eye(50, 15)
    if not c.small:
        c.px(*c.P(54, 20), K.UMBER2)


if __name__ == '__main__':
    print(K.render_pal(fn, 'pl-wgoa-6', 'Supervising Billy', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wgoa-6-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wgoa-6.png'))
