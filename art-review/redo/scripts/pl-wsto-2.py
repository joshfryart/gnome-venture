#!/usr/bin/env python3
"""pl-wsto-2 "Roll-Away Seed": a gold acorn-seed that is an edge-TBB keyhole piece.
Flat S (it sits on the grass), keyhole tab N = the cap's stalk with a green sprout, keyhole blanks W and E bitten into the gold nut.
The cap is the stone-head brow from cell 6-7: lavender stone with the cream band and the dark purple line; nut gold like the little bird."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, thick_path, knob, ramp

GOLD = ramp('#e8a830')
STONE = ramp('#bcacb4')
STONE2 = ramp('#867898')
BAND = ramp('#f0e4d4')
LINE = '#5a4e7c'
LEAF = ramp('#74c050')
GRASS = ramp('#3f9048')


def fn(c):
    k = 1.15 if c.small else 1.0
    nut = lambda x, y: (10 <= x < 54 and 30 <= y < 57) and not (
        (x < 14 and y > 53 and (x - 14) ** 2 + (y - 53) ** 2 > 16) or (x > 50 and y > 53 and (x - 50) ** 2 + (y - 53) ** 2 > 16))
    cap = lambda x, y: ell(32, 32, 24, 15)(x, y) and y < 33
    tabN = knob('T', 'keyhole', 32, 17, 0, -1, r=4.6 * k)
    blankW = knob('B', 'keyhole', 10, 45, -1, 0, r=4.2 * k)
    blankE = knob('B', 'keyhole', 54, 45, 1, 0, r=4.2 * k)
    body = c.m(nut, cap, minus=(blankW, blankE))
    stalk = c.m(tabN, minus=(cap,))
    # gold nut
    c.add(body, GOLD, stitch=None if c.small else GOLD[1])
    # stone cap with cream brow band and purple line
    capm = c.m(cap) & body
    c.add(capm, STONE)
    c.add(capm & c.m(rect(0, 24, 64, 29.5)), BAND)
    c.edge(capm, STONE2[1])
    c.add(stalk, STONE2)
    if not c.small:
        c.line([(9, 30), (55, 30)], LINE)
        c.line([(9, 31), (55, 31)], STONE2[1])
    else:
        c.line([(9, 30.5), (55, 30.5)], LINE)
    # stone speckle / moss dots on cap like the heads
    # acorn-cap scale pattern: staggered stone chips in rows above the band
    rows = [(20, range(20, 46, 5)), (23, range(15, 52, 5))] if not c.small else [(21.5, range(18, 48, 7))]
    for ry, xs in rows:
        for i, x in enumerate(xs):
            xx = x + (2.5 if ry == 23 else 0)
            c.line([(xx, ry), (xx + 2, ry)], STONE2[0])
    # sprout leaf from the stalk tip
    lf = c.m(ell(39.5, 9, 6, 2.8), ell(24.5, 10, 5, 2.4))
    c.add(lf, LEAF)
    # grass blades at the flat foot
    gr = c.m(lambda x, y: 50.5 <= y < 57 and (x < 15 or x > 49) and nut(x, y),
             poly([(15, 57), (17, 50), (19, 57)]), poly([(45, 57), (47, 50.5), (49, 57)]))
    c.add(gr & body, GRASS)
    # face on the nut between the blanks
    c.eye(27, 41, disc=False)
    c.eye(37, 41, disc=False)
    c.blush(23, 46)
    c.blush(40, 46)
    c.smile(32, 47)
    # seed shine highlight upper-left of nut
    if not c.small:
        for (x, y) in [(15, 35), (15, 36), (16, 34)]:
            c.px(*c.P(x, y), GOLD[2])


if __name__ == '__main__':
    rep = K.render_pal(fn, 'pl-wsto-2', 'Roll-Away Seed', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wsto-2-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wsto-2.png')
    print(rep)
