#!/usr/bin/env python3
"""pl-skyc-4 "Stonestep Benches": inner-TTTT keyhole. A grassy stone staircase critter: the top-left of the piece climbs
in three big steps (green treads, sandstone risers) up to a flat summit; keyhole tabs N (summit), E, W (lowest step) and
S (a dark floating-rock clump). Underside is the island's plum-brown rock with hanging vines; colours from cell 9-5."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, knob, thick_path

STONE = K.ramp('#d8c4a0')
GRASS = ('#78b064', '#3a704a', '#a8d080')
ROCK = ('#7e5a5a', '#5a3a48', '#8e7476')
VINE = '#3a704a'


def fn(c):
    k = 1.15 if c.small else 1.0
    # stepped core: steps up from left to right
    s1 = rect(11, 30, 53, 51)    # lowest step (full width)
    s2 = rect(20, 21, 53, 51)
    s3 = rect(29, 12, 53, 51)
    tabN = knob('T', 'keyhole', 41, 12, 0, -1, r=5.4 * k)
    tabE = knob('T', 'keyhole', 53, 31, 1, 0, r=5.4 * k)
    tabW = knob('T', 'keyhole', 11, 41, -1, 0, r=5.4 * k)
    tabS = knob('T', 'keyhole', 32, 51, 0, 1, r=5.4 * k)
    body = c.m(s1, s2, s3, tabN, tabE, tabW, tabS)
    c.add(body, STONE)
    # rock underside (floating island) incl. bottom tab
    rock = body & c.m(lambda x, y: y >= 44 + 1.5 * ((int(x) // 5) % 2))
    c.add(rock, ROCK)
    # grass treads on each step top (and on the tabs N/W heads)
    gr = c.m(rect(0, 0, 20, 34.5), rect(20, 0, 29, 25.5), rect(29, 0, 64, 16.5)) & body
    c.add(gr, GRASS)
    # mortar: riser lines between steps + brick joints
    c.edge(c.m(s3) & body, STONE[1])
    c.edge(c.m(s2) & body, STONE[1])
    if not c.small:
        for (y, xs) in ((39, (17, 27, 47)), (30, (25, )), ):
            yy = c.P(0, y)[1]
            for x in range(c.P(11, 0)[0], c.P(53, 0)[0]):
                if (x, yy) in body and (x, yy) not in gr and (x, yy) not in rock:
                    c.px(x, yy, STONE[1])
            for xb in xs:
                for yv in range(yy - 4, yy):
                    p = (c.P(xb, 0)[0], yv)
                    if p in body and p not in gr:
                        c.px(*p, STONE[1])
    # hanging vines on the rock band
    for vx in (18, 40, 49):
        x = c.P(vx, 0)[0]
        for y in range(c.P(0, 45)[1], c.n):
            if (x, y) in rock and (x, y + 1) in body:
                c.px(x, y, VINE)
    # face on the big stone riser
    c.eye(35, 31)
    c.eye(45, 31)
    c.smile(40, 35)
    c.blush(31.5, 35)
    c.blush(48, 35)


if __name__ == '__main__':
    rep = K.render_pal(fn, 'pl-skyc-4', 'Stonestep Benches', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-skyc-4-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-skyc-4.png')
    print(rep)
