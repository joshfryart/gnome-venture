#!/usr/bin/env python3
"""route_3.py: Stitched Toy redraw of game/assets/img/town/route-hub.png (144 x 108 felt card). Staging only, see route_kit.py."""
import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from route_kit import *  # noqa: E402,F401,F403

c = Card('hub')
c.sky(SKY, SKY2, 54)
c.cloud(104, 16, 26)
c.ground(86, back=HILL2, back_y=66)
# stem with a door
c.piece(c.mask(rect(52, 52, 84, 90), ell(68, 90, 16, 3)), WALL_W, stitch=THREAD_B, crescent=2)
c.piece(c.mask(rect(62, 70, 75, 90), ell(68.5, 70, 6.5, 6)), WOOD_D, crescent=1)
c.stitch_line([(68, 66), (68, 89)], WOOD_D[1], dash=99)
c.dot(72, 80, GOLD[0])
c.piece(c.mask(circ(77.5, 64.5, 3.2)), SKY2, crescent=0)          # round window
# gills under the cap, then the cap
c.piece(c.mask(ell(68, 50, 50, 7)), CANVAS, flat=True)
for x in range(26, 112, 4):
    c.vline(x, 47, 51, CANVAS[1])
c.piece(c.mask(ell(68, 46, 58, 36), minus=(rect(0, 48, W, H),)), RED, stitch=THREAD_C, crescent=2)
for sx, sy, r in ((44, 26, 6), (80, 20, 5), (102, 34, 5), (60, 38, 4), (24, 40, 3.5), (88, 40, 3)):
    c.piece(c.mask(circ(sx, sy, r)), CLOTH, crescent=1)
for x in (14, 34, 100, 122):
    c.tuft(x, 99)
finish(c)
