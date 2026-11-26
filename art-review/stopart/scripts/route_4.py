#!/usr/bin/env python3
"""route_4.py: Stitched Toy redraw of game/assets/img/town/route-lair.png (144 x 108 felt card). Staging only, see route_kit.py."""
import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from route_kit import *  # noqa: E402,F401,F403

c = Card('lair')
c.sky(DUSK, DUSK2, 40)
c.sun(116, 22, 9)
# the crag
c.piece(c.mask(poly([(0, 96), (0, 60), (14, 44), (22, 46), (34, 24), (44, 28), (56, 14), (70, 22), (82, 18), (96, 34), (106, 30), (124, 50), (134, 48), (144, 64), (144, 96)])), STONE, stitch=THREAD_C, crescent=2)
c.piece(c.mask(poly([(56, 14), (70, 22), (62, 30), (52, 26)])), STONE2, crescent=1)
c.piece(c.mask(poly([(96, 34), (106, 30), (116, 44), (104, 44)])), STONE2, crescent=1)
c.piece(c.mask(poly([(14, 44), (22, 46), (16, 56), (8, 54)])), STONE2, crescent=1)
c.ground(90)
# the mouth
c.piece(c.mask(poly([(38, 92), (40, 62), (52, 46), (66, 38), (82, 44), (96, 58), (100, 92)])), HOLE, flat=True)
# teeth: stalactites and stalagmites
for x, y, h in ((50, 52, 9), (60, 45, 12), (72, 42, 10), (84, 48, 11), (92, 58, 7)):
    c.piece(c.mask(tri(x - 3, y - 2, x + 3, y - 2, x, y + h)), BONE, crescent=0, outline=False)
for x, h in ((48, 8), (88, 10)):
    c.piece(c.mask(tri(x - 3, 92, x + 3, 92, x, 92 - h)), BONE, crescent=0, outline=False)
# two eyes in the dark
for ex in (60, 76):
    for (x, y) in c.mask(ell(ex + 1, 72, 4, 2.6)):
        c.dot(x, y, GOLD[0])
    c.dots([(ex, 71), (ex, 72), (ex + 1, 71), (ex + 1, 72)], UMBER)
    c.dots([(ex - 2, 71), (ex - 1, 71)], '#fde68a')
# a bone on the grass
c.piece(c.mask(rect(108, 92, 126, 96), circ(108, 92, 2.6), circ(108, 96, 2.6), circ(126, 92, 2.6), circ(126, 96, 2.6)), BONE, crescent=1)
for x in (14, 28, 104, 130):
    c.tuft(x, 100)
finish(c)
