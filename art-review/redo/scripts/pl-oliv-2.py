#!/usr/bin/env python3
"""pl-oliv-2 "Leaf Sweep": an olive tree that is an edge-TBB peg piece.
Flat S side = the terracotta planter base on the piazza; peg tab N = a leafy sprig with two olives on top of the crown;
peg blanks W + E bite into the round silver-green crown. Gnarled grey trunk, a twig broom in its hand (cell 11-3 greens, jar terracotta)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, thick_path, knob

LEAF = K.ramp('#a9c282')
LEAFD = K.ramp('#52786a')
LEAFL = '#c8dc98'
TRUNK = K.ramp('#8a7a6c')
POT = K.ramp('#d88a58')
OLIVE = '#6f2f46'
TWIG = K.ramp('#c9a55a')


def fn(c):
    k = 1.15 if c.small else 1.0
    crown = lambda x, y: (rect(10, 18, 54, 42)(x, y) or ell(17, 18, 7, 6.5)(x, y) or ell(26, 15.5, 7, 5.5)(x, y)
                          or ell(38, 15.5, 7, 5.5)(x, y) or ell(47, 18, 7, 6.5)(x, y) or rect(14, 15, 50, 20)(x, y))
    pot = rect(10, 41, 54, 56)
    tabN = knob('T', 'peg', 32, 11, 0, -1, r=4.6 * k)
    blankW = knob('B', 'peg', 10, 28, -1, 0, r=4.2 * k)
    blankE = knob('B', 'peg', 54, 28, 1, 0, r=4.2 * k)
    body = c.m(crown, pot, tabN, minus=(blankW, blankE))
    # crown: dark under-mass, then lighter leaf clumps on top
    cr = c.add(body & c.m(crown, tabN), LEAFD)
    clumps = c.m(ell(18, 19, 7, 6), ell(27, 16.5, 6.5, 5), ell(38, 16.5, 6.5, 5), ell(46, 19, 7, 6), ell(32, 23, 8, 4.5),
                 ell(17, 33, 7, 6), ell(46, 33, 7, 6), tabN) & body
    c.add(clumps - c.m(rect(0, 41, 64, 64)), LEAF)
    c.edge(clumps, LEAFD[0])
    # planter
    pm = body & c.m(pot)
    c.add(pm, POT, stitch='#f0b888')
    c.add(body & c.m(rect(10, 41, 54, 44.5)), K.ramp('#b86a40'))
    # gnarled trunk rising out of the pot into the crown
    tr = c.m(poly([(25, 44.5), (28, 38), (24, 31), (28, 30), (31, 35), (35, 29), (39, 30.5), (36, 38), (39, 44.5)])) & body
    c.add(tr, TRUNK)
    c.line([(31, 43), (31.5, 38), (30, 35)], TRUNK[1])
    # leaf highlights (silver-green specks) on clumps
    for (lx, ly) in [(19, 17), (24, 22), (37, 16), (44, 21), (30, 13), (15, 32), (48, 32)]:
        x, y = c.P(lx, ly)
        c.px(x, y, LEAFL)
        if not c.small:
            c.px(x + 1, y, LEAFL)
            c.px(x + 1, y - 1, '#eef4d8')
    # olives (purple, from the picture's plum shadows) on the tab sprig and crown
    for (ox, oy) in [(30.5, 6), (34, 7.5), (21, 25), (42, 25.5)]:
        x, y = c.P(ox, oy)
        c.px(x, y, OLIVE)
        c.px(x, y + 1, OLIVE)
        if not c.small:
            c.px(x + 1, y, OLIVE)
            c.px(x + 1, y + 1, '#8e4a62')
    # broom: twig handle along the right side of the pot with a straw head
    c.add(c.m(thick_path([(47, 31), (49.5, 46)], 2.6)) & body, TWIG)
    hx, hy = c.P(47, 47)
    for dx in range(0, 3 if c.small else 5):
        for dy in range(0, 3 if c.small else 5):
            c.px(hx + dx - (1 if c.small else 2) + (dy // 2), hy + dy, TWIG[2] if (dx + dy) % 2 else TWIG[0])
    # face on the pot (the creature lives in its planter)
    c.eye(26.5, 49.5)
    c.eye(37.5, 49.5)
    c.smile(32, 52.5)
    c.blush(22.5, 52)
    c.blush(41.5, 52)


if __name__ == '__main__':
    R = '/home/user/gnome-venture/'
    rep = K.render_pal(fn, 'pl-oliv-2', 'Leaf Sweep', R + 'art-review/redo/out',
                       cellfile=R + 'art-review/redo/_src/pl-oliv-2-cell.png',
                       oldfile=R + 'game/assets/img/puzzles/pals/pl-oliv-2.png')
    print(rep)
