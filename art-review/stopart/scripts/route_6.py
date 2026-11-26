#!/usr/bin/env python3
"""route_6.py: Stitched Toy redraw of game/assets/img/town/route-village.png (144 x 108 felt card). Staging only, see route_kit.py."""
import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from route_kit import *  # noqa: E402,F401,F403

c = Card('village')
c.sky(SKY, SKY2, 58)
c.cloud(10, 12, 30)
c.ground(86, back=HILL2, back_y=68)
# path from the blue door down to the edge
c.piece(c.mask(poly([(70, 88), (80, 88), (98, 102), (58, 102)])), PATH, crescent=1)
# tree
c.piece(c.mask(rect(119, 60, 125, 90)), WOOD_D)
c.piece(c.mask(circ(122, 50, 14), circ(112, 58, 8)), LEAF, stitch=THREAD_B, crescent=2)
# house 1: chimney with smoke, plaster walls, red roof
c.piece(c.mask(rect(38, 26, 45, 44)), STONE2)
c.piece(c.mask(circ(43, 20, 3.5)), CLOUD, crescent=1)
c.piece(c.mask(circ(47, 13, 2.6)), CLOUD, crescent=0)
c.piece(c.mask(rect(12, 56, 52, 90)), PLASTER, stitch=THREAD_B, crescent=2)
c.piece(c.mask(tri(6, 58, 32, 32, 58, 58)), ROOF_R, stitch=THREAD_C, crescent=2)
c.piece(c.mask(rect(18, 64, 28, 74)), SKY2, crescent=0)
c.hline(19, 27, 69, PLASTER[1]); c.vline(23, 65, 73, PLASTER[1])
c.piece(c.mask(rect(36, 70, 46, 90), circ(41, 70, 5)), WOOD_D)
c.dot(44, 80, GOLD[0])
# house 2: cream walls, blue roof
c.piece(c.mask(rect(60, 62, 98, 90)), WALL_W, stitch=THREAD_B, crescent=2)
c.piece(c.mask(tri(54, 64, 79, 40, 104, 64)), ROOF_B, stitch=THREAD_C, crescent=2)
c.piece(c.mask(rect(70, 72, 80, 90), circ(75, 72, 5)), WOOD_D)
c.dot(78, 81, GOLD[0])
c.piece(c.mask(rect(85, 70, 94, 79)), SKY2, crescent=0)
c.hline(86, 93, 74, WALL_W[1]); c.vline(89, 71, 78, WALL_W[1])
for x in (12, 26, 104, 132):
    c.tuft(x, 99)
finish(c)
