#!/usr/bin/env python3
"""route_1.py: Stitched Toy redraw of game/assets/img/town/route-delve.png (144 x 108 felt card). Staging only, see route_kit.py."""
import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from route_kit import *  # noqa: E402,F401,F403

c = Card('delve')
c.sky(DUSK, DUSK2, 44)
c.sun(117, 24, 9)
c.cloud(20, 18, 26)
# the mossy mound the mine runs into
c.piece(c.mask(ell(72, 104, 68, 70)), MOSS, stitch=THREAD_B, crescent=2)
for x, y in ((30, 60), (108, 56), (118, 72), (24, 78), (100, 44)):
    c.dots([(x, y), (x + 1, y), (x + 1, y - 1)], MOSS[1])
# grass at the foot
c.ground(90)
# rails running into the dark (drawn before the hole so they vanish into it)
for y in (91, 95, 99):
    t = (y - 88) / 13.0
    c.hline(round(64 - 12 * t) - 2, round(80 + 12 * t) + 2, y, WOOD_D[1])
    c.hline(round(64 - 12 * t) - 1, round(80 + 12 * t) + 1, y - 1, WOOD_D[0])
c.stitch_line([(64, 88), (52, 101)], STONE[1], dash=99)
c.stitch_line([(80, 88), (92, 101)], STONE[1], dash=99)
c.stitch_line([(65, 88), (53, 101)], STONE[2], dash=99)
c.stitch_line([(81, 88), (93, 101)], STONE[2], dash=99)
# the doorway: a dark arch under timber
c.piece(c.mask(rect(54, 60, 90, 90), ell(72, 61, 18, 12)), HOLE, flat=True)
c.piece(c.mask(rect(46, 52, 53, 92)), WOOD, crescent=1)
c.piece(c.mask(rect(91, 52, 98, 92)), WOOD, crescent=1)
c.piece(c.mask(rect(42, 45, 102, 53)), WOOD, stitch=None, crescent=1)
c.stitch_line([(44, 49), (100, 49)], WOOD[1], dash=2)
# nail heads
c.dots([(49, 55), (94, 55), (49, 88), (94, 88)], UMBER2)
# a lantern hanging from the lintel
c.vline(84, 54, 57, UMBER)
c.piece(c.mask(rect(81, 58, 88, 66)), GOLD, crescent=1)
c.dots([(83, 60), (84, 60), (83, 61), (84, 61), (84, 62)], '#fde68a')
# two rails glinting inside the dark
for x in (14, 34, 108, 126):
    c.tuft(x, 98)
finish(c)
