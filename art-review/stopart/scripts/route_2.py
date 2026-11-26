#!/usr/bin/env python3
"""route_2.py: Stitched Toy redraw of game/assets/img/town/route-haven.png (144 x 108 felt card). Staging only, see route_kit.py."""
import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from route_kit import *  # noqa: E402,F401,F403

c = Card('haven')
c.sky(DUSK, DUSK2, 40)
c.sun(112, 22, 9)
c.ground(84, back=HILL, back_y=64)
# tree behind the fire
c.piece(c.mask(rect(113, 56, 120, 88)), WOOD_D)
c.piece(c.mask(ell(115, 48, 17, 15)), LEAF, stitch=THREAD_B, crescent=2)
# the tent
c.piece(c.mask(tri(10, 88, 44, 26, 78, 88)), TENT, stitch=THREAD_C, crescent=2)
c.piece(c.mask(tri(34, 88, 44, 56, 54, 88)), HOLE, flat=True)
c.stitch_line([(44, 30), (44, 56)], TENT[1], dash=99)
c.dots([(44, 22), (44, 23), (44, 24), (44, 25), (45, 22), (46, 22), (46, 23)], UMBER)   # pole tip and pennant
c.dots([(45, 23), (47, 23)], GOLD[0])
# guy pegs
c.dots([(8, 90), (80, 90)], WOOD_D[1])
# campfire: stones, crossed logs, flame
for sx in (80, 87, 94, 101, 108):
    c.piece(c.mask(ell(sx + 2.5, 92, 3.6, 2.6)), STONE2, crescent=1)
c.piece(c.mask(thick_path([(82, 90), (106, 84)], 4)), WOOD_D)
c.piece(c.mask(thick_path([(82, 84), (106, 90)], 4)), WOOD)
c.piece(c.mask(poly([(86, 86), (88, 72), (91, 77), (94, 62), (98, 74), (100, 70), (102, 86)])), FLAME, crescent=1)
c.piece(c.mask(poly([(90, 86), (93, 76), (95, 79), (97, 72), (99, 86)])), FLAME_IN, outline=False, crescent=0, rim=False)
c.dots([(96, 56), (91, 52), (99, 48)], GOLD[2])          # sparks
for x in (16, 60, 124, 30):
    c.tuft(x, 99)
finish(c)
