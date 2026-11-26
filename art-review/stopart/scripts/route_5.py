#!/usr/bin/env python3
"""route_5.py: Stitched Toy redraw of game/assets/img/town/route-market.png (144 x 108 felt card). Staging only, see route_kit.py."""
import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from route_kit import *  # noqa: E402,F401,F403

c = Card('market')
c.sky(SKY, SKY2, 56)
c.ground(88, back=HILL2, back_y=70)
# the sign: post and board with a gold coin
c.piece(c.mask(rect(116, 54, 121, 94)), WOOD_D)
c.piece(c.mask(rect(100, 34, 136, 58)), CLOTH, stitch=THREAD_B, crescent=1)
c.piece(c.mask(circ(118, 46, 7)), GOLD, crescent=1)
c.piece(c.mask(circ(118, 46, 3.6)), GOLD, outline=False, crescent=0, rim=False)
for (x, y) in c.mask(circ(118, 46, 4.2), minus=(circ(118, 46, 3.2),)):
    c.dot(x, y, GOLD[1])
# the stall: back posts, counter, produce
c.piece(c.mask(rect(12, 26, 17, 66)), WOOD_D)
c.piece(c.mask(rect(91, 26, 96, 66)), WOOD_D)
fruit = [(22, FRUIT_R), (34, FRUIT_O), (46, FRUIT_G), (58, FRUIT_R), (70, FRUIT_O), (82, FRUIT_G)]
for i, (fx, rmp) in enumerate(fruit):
    c.piece(c.mask(circ(fx, 60, 5.5)), rmp, crescent=1)
    c.dots([(fx, 54), (fx + 1, 53)], LEAF[1])
for i, (fx, rmp) in enumerate(fruit[:-1]):
    c.piece(c.mask(circ(fx + 6, 54, 5)), fruit[(i + 2) % 6][1], crescent=1)
    c.dot(fx + 6, 49, LEAF[1])
c.piece(c.mask(rect(8, 64, 100, 94)), WOOD, stitch=THREAD_C, crescent=2)
c.hline(10, 97, 72, WOOD[1])
for x in (30, 54, 78):
    c.vline(x, 73, 91, WOOD[1])
# the striped awning with a scalloped hem
for i, x in enumerate(range(6, 138, 12)):
    rmp = RED if i % 2 == 0 else CLOTH
    c.piece(c.mask(rect(x, 6, x + 12, 22), ell(x + 6, 22, 6, 4)), rmp, crescent=1, rim=True)
c.piece(c.mask(rect(6, 6, 138, 9)), RED, outline=False, flat=True)
c.hline(6, 137, 9, UMBER)
c.stitch_line([(7, 7), (137, 7)], THREAD_C, dash=2)
for x in (124, 132, 106):
    c.tuft(x, 100)
finish(c)
