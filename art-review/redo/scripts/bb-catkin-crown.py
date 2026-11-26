#!/usr/bin/env python3
"""bb-catkin-crown "Catkin Crown": inner-TTTT, double knobs.
A little birch-trunk sprite: the square piece body is a stout chunk of white birch bark (dark lenticel dashes), wearing a leafy
green crown. N double tab = two leaf lobes of the crown, E + W double tabs = bunches of gold-brown catkins hanging from the crown,
S double tab = two bark root-feet. Colours from cell 10-1 (birch white, catkin brown with gold, birch-leaf green)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, thick_path, knob

BARK = ('#f0ece0', '#c9c5bc', '#ffffff')
LEAF = ('#7ab947', '#4f8a2e', '#a8d860')
CATK = ('#9a6a3a', '#74462c', '#c8964c')
GOLD = K.ramp('#e8b830')
LENT = '#4a3428'


def fn(c):
    S = 1.15 if c.small else 1.0
    core = rect(14, 18, 50, 52)
    tabN = knob('T', 'double', 32, 18, 0, -1, r=5.8 * S)
    tabE = knob('T', 'double', 50, 36, 1, 0, r=5.0 * S)
    tabW = knob('T', 'double', 14, 36, -1, 0, r=5.0 * S)
    tabS = knob('T', 'double', 32, 52, 0, 1, r=5.0 * S)
    # bark body + root feet
    c.add(c.m(core, tabS), BARK, stitch=None)
    # lenticel dashes (birch bark marks), kept to the sides, away from the face
    for (x0, x1, y) in ((14, 21, 45), (41, 50, 43), (21, 27, 49.5), (35, 43, 50.5), (14, 18, 38), (46, 50, 36), (28, 33, 55), (25, 30, 30.5)):
        if c.small:
            c.add(c.m(rect(x0, y, x1, y + 2.2)), (LENT, LENT, LENT))
        else:
            c.add(c.m(rect(x0, y, x1, y + 1.6)), (LENT, LENT, LENT))
    # leafy crown band + N leaf lobes (wavy lower edge)
    import math
    crown = lambda x, y: 14 <= x < 50 and 17 <= y < 27 + 2.2 * math.sin((x - 14) / 36 * math.pi * 3)
    crownm = c.m(crown, tabN)
    c.add(crownm, LEAF)
    # leaf veins on the N lobes
    if not c.small:
        c.line([(28.5, 7), (28.5, 16)], LEAF[1])
        c.line([(35.5, 7), (35.5, 16)], LEAF[1])
    # catkin bunches: E and W tabs plus a catkin strand hanging from the crown down each side
    for side in (-1, 1):
        tab = tabE if side == 1 else tabW
        sx = 50 if side == 1 else 14
        strand = rect(sx - 4.5, 20, sx, 42) if side == 1 else rect(sx, 20, sx + 4.5, 42)
        cm = c.m(tab, strand)
        # extra hanging catkin tassels from the crown edge (like the cell's dangling strands)
        tx = 20 if side == -1 else 44
        cm2 = c.m(thick_path([(tx, 24), (tx + 0.5 * side, 31)], 3.0 if not c.small else 3.4))
        cm |= cm2
        c.add(cm, CATK)
        # gold pollen dots on the catkins
        for (x, y) in cm:
            if y % (3 if not c.small else 2) == 0:
                c.px(x, y, GOLD[0] if (x + y) % 2 else CATK[2])
        c.edge(cm, CATK[1])
    # a tiny gold sneeze-sparkle crown point between the lobes
    c.add(c.m(ell(32, 12, 1.8 * S, 2.2 * S)), GOLD)
    # face on the bark
    c.eye(26, 35)
    c.eye(38, 35)
    c.blush(22.5, 39.5)
    c.blush(40.5, 39.5)
    c.smile(32, 40)


K.render_pal(fn, 'bb-catkin-crown', 'Catkin Crown', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/bb-catkin-crown-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/bb-catkin-crown.png')
