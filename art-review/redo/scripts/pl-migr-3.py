#!/usr/bin/env python3
"""pl-migr-3 "Acacia Umbrella": inner-TBTB keyhole. Flat-topped acacia canopy (green, picture's acacia) is the top edge with a keyhole tab N,
savanna ground keyhole tab S, keyhole blanks W and E cut into the sunset sky (cell 0-3: peach/orange sky, plum trunk)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, thick_path, knob

LEAF = K.ramp('#6a9a42')
LEAF2 = K.ramp('#81a54e')
SKY1 = K.ramp('#ffb868')
SKY2 = K.ramp('#ffd488')
SKY3 = K.ramp('#ffe8a8')
TRUNK = K.ramp('#6a3a40')
GROUND = K.ramp('#be976b')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rect(11, 14, 53, 54)
    tabN = knob('T', 'keyhole', 32, 14, 0, -1, r=4.6 * k)
    tabS = knob('T', 'keyhole', 32, 54, 0, 1, r=4.6 * k)
    blW = knob('B', 'keyhole', 11, 39, -1, 0, r=3.6 * k)
    blE = knob('B', 'keyhole', 53, 39, 1, 0, r=3.6 * k)
    # flat-topped umbrella canopy, overhanging the sides a little with rounded ends
    canopy = (rect(9, 14, 55, 25), ell(9, 19.5, 3.5, 5.5), ell(55, 19.5, 3.5, 5.5),
              ell(16, 25, 6, 4), ell(27, 26, 6.5, 4.2), ell(38, 26, 6.5, 4.2), ell(48, 25, 6, 4))
    body = c.m(core, tabN, tabS, *canopy, minus=(blW, blE))
    # sky bands (sunset, from the cell)
    c.add(body, SKY3)
    c.add(body & c.m(rect(0, 0, 64, 44)), SKY2)
    c.add(body & c.m(rect(0, 0, 64, 33)), SKY1)
    # ground strip + S tab
    c.add(body & c.m(rect(0, 51, 64, 64)), GROUND)
    # trunk with fork into the canopy
    tw = 5.0 if not c.small else 5.6
    bw = 3.2 if not c.small else 3.8
    trunk = c.m(thick_path([(32, 52), (32, 38)], tw), ell(32, 51, 4.2, 1.6),
                thick_path([(32, 40), (23, 28)], bw), thick_path([(32, 40), (41, 28)], bw), thick_path([(32, 38), (32, 28)], bw))
    c.add(trunk & body, TRUNK)
    # canopy
    can = c.m(*canopy, tabN) & body
    c.add(can, LEAF, stitch=None)
    # leafy tufts on top for texture (lighter green)
    tufts = c.m(ell(20, 17, 6, 2.6), ell(42, 17, 6, 2.6), ell(32, 9, 3, 2.5))
    c.add(tufts & can, LEAF2)
    if not c.small:
        for (x, y) in can:
            if (x * 3 + y * 5) % 11 == 0 and 18 < y < 27:
                c.px(x, y, LEAF[1])
    # face on the canopy
    c.eye(26, 21, disc=True)
    c.eye(38, 21, disc=True)
    c.smile(32, 24.5)
    c.blush(21.5, 24)
    c.blush(41.5, 24)
    # low sun glow in the sky
    sun = c.m(ell(44, 46, 3.6, 3.6)) & body
    for p in sun:
        c.px(*p, '#fff4cc')


if __name__ == '__main__':
    print(K.render_pal(fn, 'pl-migr-3', 'Acacia Umbrella', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-migr-3-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-migr-3.png'))
