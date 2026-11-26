#!/usr/bin/env python3
"""pl-wsta-3 Torchlet Wiggle: a beach tiki torch that is an inner-TBTB keyhole piece.
N tab = the flame (keyhole bulb + flicker tip), S tab = the torch pole stub, E/W keyhole blanks bite the woven cup.
Cup painted in the cell's indigo night-sky bands with starpath dots; flame in the picture's lantern gold, pole in canoe wood."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

R = '/home/user/gnome-venture/'
IND1 = K.ramp('#343078')   # light band
IND2 = K.ramp('#262866')
IND3 = K.ramp('#1c1e56')
FLAME = K.ramp('#f08a3a')
GLOW = ('#ffe9ab', '#f5c860', '#fff6d8')
WOOD = K.ramp('#cc763a')
GOLD = K.ramp('#e8b040')
STAR = '#fff6d8'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.poly([(11, 25), (53, 25), (50, 52), (14, 52)])
    rim = K.rect(8, 21, 56, 27)
    tabN = K.knob('T', 'keyhole', 32, 21, 0, -1, r=7.6 * k, nw=4.0)
    tip = K.poly([(27, 8), (31, 3), (33.5, -0.5), (35, 4), (37.5, 8)])
    lickL = K.ell(32, 14.5, 9.0 * k, 6.5)
    lickR = K.poly([(23.5, 15), (27, 5.5), (31, 9), (36, 2), (41, 15)])
    tabS = K.knob('T', 'keyhole', 32, 52, 0, 1, r=4.4 * k, nw=3.0)
    bE = K.knob('B', 'keyhole', 51.5, 40, 1, 0, r=3.4 * k)
    bW = K.knob('B', 'keyhole', 12.5, 40, -1, 0, r=3.4 * k)
    blanks = (bE, bW)
    # pole stub
    c.add(c.m(tabS, minus=(core,)), WOOD)
    # cup in night bands
    cup = c.m(core, minus=blanks)
    c.add(cup, IND2)
    c.add(cup & c.m(K.rect(0, 27, 64, 31)), IND1)
    c.add(cup & c.m(K.rect(0, 44, 64, 52)), IND3)
    # gold binding cords
    c.add(cup & c.m(K.rect(0, 47.5, 64, 50)), GOLD)
    # rim
    c.add(c.m(rim), GOLD)
    # flame
    fl = c.m(tabN, tip, lickL, lickR, minus=(rim,))
    c.add(fl, FLAME)
    inner = c.m(K.ell(32, 14, 4.2 * k, 5.4 * k), K.poly([(28.5, 11), (32.5, 3.5), (35.5, 11)]))
    c.add(inner & fl, GLOW)
    # wiggle flicker on the flame edge
    # starpath dots on the cup
    for (sx, sy) in ((17, 30), (47, 29), (24, 46), (41, 45)):
        if c.small and (sx, sy) in ((24, 46), (41, 45)):
            continue
        c.px(*c.P(sx, sy), STAR)
    # weave ticks on the rim
    if not c.small:
        y = c.P(0, 23.5)[1]
        for x in range(c.P(9, 0)[0], c.P(55, 0)[0], 3):
            c.px(x, y, GOLD[1])
    # face
    c.eye(26, 34.5, disc=True)
    c.eye(38, 34.5, disc=True)
    c.smile(32, 39, '#fff6d8')
    c.blush(21.5, 38.5)
    c.blush(41.5, 38.5)


K.render_pal(fn, 'pl-wsta-3', 'Torchlet Wiggle', R + 'art-review/redo/out',
             cellfile=R + 'art-review/redo/_src/pl-wsta-3-cell.png',
             oldfile=R + 'game/assets/img/puzzles/pals/pl-wsta-3.png')
