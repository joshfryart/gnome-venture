#!/usr/bin/env python3
"""pl-jdf-6 "Lotus Perch": whimsy-lotus, hook knobs.
An open pink lotus (three upturned petals over a round cup) sitting on a wide lily pad. W hook tab sticks out of the cup's flank,
E hook blank cuts into the other flank, S hook tab is a lobe of the lily pad. Colours from lair-of-the-jade-dragon-fly cell 8-7:
pink lotus with umber petal seams, gold stamen, lime-green pad, teal pond water."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import ell, rect, poly, knob

PINK = ('#f2a0bc', '#d87098', '#fcd0de')
PINK2 = ('#e884a8', '#c25a84', '#f6b8cc')
PAD = ('#7cc450', '#4a9a3c', '#b4e080')
WATER = ('#2a9a8a', '#1d7368', '#6fcab8')
SEAM = '#b85a80'
GOLD = '#f0c838'
JADE = '#3fbf9a'


def fn(c):
    k = 1.15 if c.small else 1.0
    cup = poly([(13, 25), (51, 25), (51, 42), (13, 42)])
    cupb = ell(32, 38, 19, 8)
    pc = poly([(32, 4), (35, 7), (40, 15), (42, 27), (32, 32), (22, 27), (24, 15), (29, 7)])
    pl = poly([(13, 30), (11, 19), (12, 11), (15, 9), (21, 13), (27, 22), (28, 30)])
    pr = poly([(51, 30), (53, 19), (52, 11), (49, 9), (43, 13), (37, 22), (36, 30)])
    pad = ell(32, 44.5, 27, 6)
    tabW = knob('T', 'hook', 13, 32, -1, 0, r=4.6 * k)
    blkE = knob('B', 'hook', 51, 34, 1, 0, r=4.0 * k, flip=True)
    tabS = knob('T', 'hook', 32, 50, 0, 1, r=4.3 * k, flip=True)
    bl = (blkE,)
    body = c.m(cup, cupb, pc, pl, pr, tabW, minus=bl)
    c.add(body, PINK2)
    side = c.m(pl, pr, minus=bl)
    c.add(side, PINK2)
    c.edge(side, SEAM)
    mid = c.m(pc, cupb, poly([(22, 27), (42, 27), (46, 36), (18, 36)]), minus=bl)
    c.add(mid, PINK, stitch=None)
    c.edge(mid, SEAM)
    padm = c.m(pad, tabS, minus=bl)
    c.add(padm, PAD)
    c.edge(c.m(pad), PAD[1])
    # teal water lobe inside the S hook
    c.add(c.m(tabS, minus=(pad,)), WATER)
    if not c.small:
        c.line([(32, 40), (32, 44)], PAD[1])
        c.line([(11, 44), (21, 46)], PAD[1])
        c.line([(43, 46), (53, 44)], PAD[1])
        c.line([(32, 9), (32, 14)], SEAM)
        c.line([(18, 30), (21, 37), (26, 40)], SEAM)
        c.line([(46, 30), (43, 37), (38, 40)], SEAM)
    # gold stamen crown peeking between the petals
    for gx in (28, 32, 36):
        x, y = c.P(gx, 24 if gx == 32 else 25)
        c.px(x, y, GOLD)
        if not c.small:
            c.px(x + 1, y, GOLD)
    # a tiny jade dragon-fly napping on the left petal tip (64 px only)
    if not c.small:
        x, y = c.P(15, 13)
        for dx in range(0, 4):
            c.px(x + dx, y, '#2f8a6a')
        c.px(x, y - 1, JADE); c.px(x + 1, y - 1, JADE); c.px(x + 2, y - 2, '#c9f0e0'); c.px(x + 1, y - 2, '#c9f0e0')
    c.eye(28, 31)
    c.eye(36, 31)
    c.smile(32, 35.5)
    c.blush(24.5, 35)
    c.blush(39 if not c.small else 38, 35)


if __name__ == '__main__':
    rep = K.render_pal(fn, 'pl-jdf-6', 'Lotus Perch', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-jdf-6-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-jdf-6.png')
    print(rep)
