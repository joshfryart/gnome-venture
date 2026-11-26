#!/usr/bin/env python3
"""gc-calabash-cup "Calabash Cup": corner-BB, round. A half-gourd cup brimming with roof rain, front on.
Flat sides N (the cup's rim, water showing) and W; round blanks E and S (the bowl's foot). Plank-brown gourd with dark ribs
(the wooden door of cell 1-5), thatch-gold lip from the eaves above it, rain blue water."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

GOURD = K.ramp('#9a6b3f')
RIB = '#5d3420'
LIP = K.ramp('#d9a84b')
WATER = K.ramp('#6fb0d8')
STEM = K.ramp('#6b4423')
LEAF = K.ramp('#4f9a3a')


def fn(c):
    k = 1.15 if c.small else 1.0
    R = 13
    core = (K.rect(9, 17, 55, 58 - R), K.rect(9 + R, 17, 55 - R, 58),
            K.ell(9 + R, 58 - R, R, R), K.ell(55 - R, 58 - R, R, R))
    blankE = K.knob('B', 'round', 55, 34, 1, 0, r=4.3 * k)
    blankS = K.knob('B', 'round', 32, 58, 0, 1, r=3.7 * k)
    body = c.m(*core, minus=(blankE, blankS))
    c.add(body, GOURD, stitch=None if c.small else '#c08a50')
    # ribs: gourd segments curving in toward the bowl's foot
    w = 2.2 if c.small else 1.6
    for top, mid, bot in (((21, 25), (17, 40), (22, 53)), ((43, 25), (47, 40), (42, 53))):
        c.add(c.m(K.thick_path([top, mid, bot], w)) & body, (RIB, RIB, RIB))
    # stem curl and leaf on the rim's left end (the vines of the canopy)
    c.add(c.m(K.thick_path([(14, 18), (13, 12), (16, 9), (19, 11)], 3.0 if not c.small else 3.6)), STEM)
    c.add(c.m(K.poly([(18, 14), (24, 9), (30, 10), (25, 15)])), LEAF)
    # thatch-gold lip band across the top
    lip = c.m(K.rect(9, 17, 55, 25.5)) & body
    c.add(lip, LIP)
    # water inside the rim
    wat = c.m(K.ell(32, 20.6, 19.5, 2.9 if not c.small else 3.4))
    c.add(wat & body, WATER)
    hx, hy = c.P(19, 20)
    for d in range(3 if not c.small else 2):
        c.px(hx + d, hy, WATER[2])
    # face
    c.eye(25.5, 34, look=(0, 0))
    c.eye(38.5, 34, look=(0, 0))
    c.smile(32, 39)
    c.blush(21, 39)
    c.blush(42, 39)


K.render_pal(fn, 'gc-calabash-cup', 'Calabash Cup', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/gc-calabash-cup-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/gc-calabash-cup.png')
