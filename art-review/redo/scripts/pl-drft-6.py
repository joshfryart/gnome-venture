#!/usr/bin/env python3
"""pl-drft-6 "Pinkhat Drummer" (rare, whimsy-drum, peg).
Concept: a barrel drum that is the piece body, a pink-hatted gnome popping out of its top behind the drumhead with two sticks.
Peg tab E (drum lug), peg tab S (drum foot), peg blank W cut into the barrel; the drum staves are banded in the cell's
sunset gradient (gold, peach, rose, plum, violet) with gold hoops; the hat is the beach-bar pink."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, thick_path, knob, ramp

GOLD = ramp('#ffcf7f')
PEACH = ramp('#f09878')
ROSE = ramp('#d06c84')
PLUM = ramp('#9a4c8c')
VIO = ramp('#6a3e86')
HOOP = ramp('#e8a317')
HEAD = ('#f4ead0', '#c9bca0', '#ffffff')
HAT = ramp('#e84a9a')
SKIN = ramp('#f2c1a3')
BEARD = ('#f4f0ec', '#c7c0c8', '#ffffff')
STICK = ramp('#b07a3a')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rect(11, 31, 53, 56)
    top = ell(32, 31, 21, 5)
    bot = ell(32, 56, 21, 3.5)
    tabE = knob('T', 'peg', 53, 43, 1, 0, r=4.4 * k)
    tabS = knob('T', 'peg', 32, 58.5, 0, 1, r=4.2 * k)
    blankW = knob('B', 'peg', 11, 43, -1, 0, r=4.4 * k)
    drum = c.m(core, top, bot, tabE, tabS, minus=(blankW,))
    # sunset bands down the barrel
    bands = [(0, 36, GOLD), (36, 41, PEACH), (41, 46, ROSE), (46, 51, PLUM), (51, 64, VIO)]
    for y0, y1, r in bands:
        c.add(drum & c.m(rect(0, y0, 64, y1)), r)
    # gold hoops top and bottom
    c.add(drum & c.m(rect(0, 33.5, 64, 36.5), minus=(blankW,)), HOOP)
    c.add(drum & c.m(rect(0, 53, 64, 56.5)), HOOP)
    # tabs in hoop gold so the knobs read as fittings
    c.add(c.m(tabE, minus=(core,)), HOOP)
    c.add(c.m(tabS, minus=(core, bot)), VIO)
    # gnome: beard and face behind the drumhead, hat on top
    c.add(c.m(ell(32, 25, 9, 6.5)), SKIN)
    c.add(c.m(poly([(20, 22), (44, 22), (40, 14), (35, 6), (37, 1.5), (31, 4), (26, 12)])), HAT, stitch=HAT[2])
    c.add(c.m(ell(32, 22, 12.5, 3)), HAT)
    # drumhead (cream)
    head = c.m(ell(32, 31, 19, 3.6))
    c.add(head, HEAD)
    c.edge(head, HOOP[1])
    # beard spilling over the drumhead rim
    c.add(c.m(ell(32, 30, 7.5, 4.2), minus=(rect(0, 0, 64, 27.5),)), BEARD)
    # drumsticks raised in both hands
    sw = 2.8 if c.small else 2.4
    c.add(c.m(thick_path([(17, 31), (9, 18)], sw)), STICK)
    c.add(c.m(thick_path([(47, 31), (55, 18)], sw)), STICK)
    c.add(c.m(ell(9, 17.5, 2.6, 2.6)), HEAD)
    c.add(c.m(ell(55, 17.5, 2.6, 2.6)), HEAD)
    c.add(c.m(ell(17.5, 31, 2.6, 2.2)), SKIN)
    c.add(c.m(ell(46.5, 31, 2.6, 2.2)), SKIN)
    # face
    c.eye(28.5, 25.5)
    c.eye(35.5, 25.5)
    c.blush(25.5, 27.5)
    c.blush(38.5, 27.5)
    # lacing zigzag on the barrel
    if not c.small:
        pts = []
        for i, x in enumerate(range(15, 52, 5)):
            pts.append((x, 38 if i % 2 == 0 else 51))
        c.line(pts, HEAD[1])
    else:
        c.line([(17, 38), (24, 51), (32, 38), (40, 51), (47, 38)], HEAD[1])


if __name__ == '__main__':
    rep = K.render_pal(fn, 'pl-drft-6', 'Pinkhat Drummer', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-drft-6-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-drft-6.png')
    print(rep)
