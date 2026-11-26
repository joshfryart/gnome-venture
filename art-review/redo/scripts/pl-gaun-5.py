#!/usr/bin/env python3
"""pl-gaun-5 "Noon Shade": an ombu tree that is an inner-BBBB round piece.
Round blanks N (into the crown top), E + W (into the crown sides) and S (the arch between the buttress roots).
Crown in the pampas greens of the picture, trunk and roots in the cell's roof plum/terracotta, terracotta blossoms from the roof tiles."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, knob, thick_path

LEAF = K.ramp('#6f9a34')
LEAF2 = K.ramp('#93b648')
SUN = K.ramp('#cfcc64')
BARK = K.ramp('#8d3b44')
ROOT = K.ramp('#a04a3c')
TILE = K.ramp('#e0603c')
TILE2 = '#f0845a'


def fn(c):
    k = 1.15 if c.small else 1.0
    # crown: square-ish with rounded, puffy corners
    crown = (rect(10, 6, 54, 40), rect(7, 10, 57, 36),
             ell(12, 11, 5.5, 5.5), ell(52, 11, 5.5, 5.5), ell(12, 35, 5.5, 5.5), ell(52, 35, 5.5, 5.5))
    trunk = poly([(24, 37), (40, 37), (39, 46), (25, 46)])
    roots = (poly([(7, 58), (57, 58), (56, 51), (42, 43), (22, 43), (8, 51)]),)
    bN = knob('B', 'round', 32, 6, 0, -1, r=4.3 * k)
    bE = knob('B', 'round', 57, 23, 1, 0, r=4.3 * k)
    bW = knob('B', 'round', 7, 23, -1, 0, r=4.3 * k)
    bS = knob('B', 'round', 32, 58, 0, 1, r=4.0 * k)
    blanks = (bN, bE, bW, bS)
    c.add(c.m(*roots, minus=blanks), ROOT)
    c.add(c.m(trunk, minus=blanks), BARK)
    crownm = c.m(*crown, minus=blanks)
    c.add(crownm, LEAF, stitch=None if c.small else LEAF[1])
    # sunlit upper-left puffs (noon light), darker leaf clumps lower right
    c.add(crownm & c.m(ell(18, 14, 9, 6), ell(40, 13, 7, 5)), LEAF2)
    c.add(crownm & c.m(ell(15, 12, 4, 2.6)), SUN)
    c.edge(crownm & c.m(ell(18, 14, 9, 6), ell(40, 13, 7, 5)), LEAF[1])
    # root lines: buttress roots fanning from the trunk
    rm = c.m(*roots, minus=blanks)
    c.edge(rm, ROOT[1])
    if not c.small:
        c.line([(27, 46), (16, 55)], ROOT[1])
        c.line([(37, 46), (48, 55)], ROOT[1])
        c.line([(31, 38), (30, 44)], BARK[1])
        c.line([(35, 39), (35, 43)], BARK[1])
    else:
        c.line([(27, 47), (17, 55)], ROOT[1])
        c.line([(37, 47), (47, 55)], ROOT[1])
    # terracotta blossoms (the roof tiles of the cell)
    for bx, by in ((46, 15), (14, 30), (48, 33), (24, 12)):
        x, y = c.P(bx, by)
        c.px(x, y, TILE2)
        c.px(x + 1, y, TILE[0])
        if not c.small:
            c.px(x, y + 1, TILE[0])
            c.px(x + 1, y + 1, TILE[1])
    # face on the calm crown
    c.eye(25, 24)
    c.eye(39, 24)
    c.smile(32, 29)
    c.blush(20.5, 28)
    c.blush(43, 28)


K.render_pal(fn, 'pl-gaun-5', 'Noon Shade', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-gaun-5-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-gaun-5.png')
