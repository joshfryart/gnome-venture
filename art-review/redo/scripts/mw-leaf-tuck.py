#!/usr/bin/env python3
"""Leaf Tuck (mw-leaf-tuck): a red maple leaf folded over itself, tucked into a leaf pile. Edge-TTB, round knobs.
Flat bottom = the leaf pile it sits in; round tab N = the leaf's central lobe with its stem; round tab E = a curled orange leaf;
round blank W. Pointed maple lobes at the upper corners. Colours from cell 4-2 of Maplewold: maple red/orange leaves, slate sky."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, thick_path, knob, ramp

RED = ramp('#d6312b')
ORANGE = ramp('#e7841f')
GOLD = ramp('#f0b92b')
STEM = ramp('#794a1e')
SLATE = ramp('#8fb3c9')
VEIN = '#a8241f'


def fn(c):
    s = 1.15 if c.small else 1.0
    core = rect(11, 20, 52, 57)
    tabN = knob('T', 'round', 31.5, 20, 0, -1, r=5.4 * s)
    tabE = knob('T', 'round', 52, 39, 1, 0, r=4.8 * s)
    blankW = knob('B', 'round', 11, 38, -1, 0, r=4.0 * s)
    lobeL = poly([(11, 30), (4, 16), (9, 17), (10, 11), (21, 20), (11, 20)])
    lobeR = poly([(52, 30), (59, 16), (54, 17), (53, 11), (42, 20), (52, 20)])
    leaf = c.m(core, tabN, lobeL, lobeR, minus=(blankW,))
    c.add(leaf, RED, stitch=None if c.small else '#f08a6a')
    # curled orange leaf = east tab
    c.add(c.m(tabE, minus=(core,)) | (c.m(tabE) & c.m(rect(50, 0, 53, 64))), ORANGE)
    # stem sprouting from the north tab
    c.add(c.m(thick_path([(31.5, 10.5), (33, 6), (36, 4)], 2.8 if not c.small else 3.2)), STEM)
    # veins: midrib + branches into the lobes
    w = 1.6 if not c.small else 2.0
    vein = c.m(thick_path([(31.5, 54), (31.5, 13)], w), thick_path([(31.5, 30), (13, 19), (8, 15)], w),
               thick_path([(31.5, 30), (50, 19), (55, 15)], w))
    c.edge(set(), VEIN)
    for p in vein:
        if p in leaf:
            c.px(p[0], p[1], RED[1])
    # leaf pile at the flat bottom: a low scalloped heap of gold / orange leaves the leaf is tucked into
    pile = c.m(lambda x, y: 11 <= x < 52 and y >= 53 - 4 * (1 - (abs(((x - 11) % 8) - 4) / 4) ** 2))
    c.add(pile, GOLD)
    lf = [poly([(13, 57), (18, 53), (23, 57), (18, 61)]), poly([(38, 58), (43, 54), (49, 58), (43, 61.5)])]
    c.add(c.m(*lf) & pile, ORANGE)
    c.add(c.m(poly([(26, 60), (30, 56.5), (34, 60), (30, 63)])) & pile, RED)
    c.edge(pile, GOLD[1])
    # tucked-in tip: the leaf's own bottom lobe folded over the pile (slate-sky shadow line from the cell's mountains)
    c.add(c.m(poly([(26, 50), (37, 50), (31.5, 56)])), RED)
    sh = c.m(lambda x, y: 11 <= x < 52 and 47.5 <= y < 49) - c.m(poly([(26, 50), (37, 50), (31.5, 56)]))
    for p in sh:
        if p in leaf:
            c.px(p[0], p[1], SLATE[0])
    # face
    c.eye(24, 35)
    c.eye(39, 35)
    c.blush(20, 40)
    c.blush(42, 40)
    c.smile(31.5, 41)


if __name__ == '__main__':
    rep = K.render_pal(fn, 'mw-leaf-tuck', 'Leaf Tuck', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/mw-leaf-tuck-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/mw-leaf-tuck.png')
    print(rep)
