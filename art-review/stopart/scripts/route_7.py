#!/usr/bin/env python3
"""route_7.py: Stitched Toy redraw of game/assets/img/town/route-wonder.png (144 x 108 felt card). Staging only, see route_kit.py."""
import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from route_kit import *  # noqa: E402,F401,F403

c = Card('wonder')
c.sky(SKY, SKY2, 56)
c.cloud(12, 12, 28)
c.ground(88, back=HILL2, back_y=70)


def crystal(pts, rmp, facet):
    c.piece(c.mask(poly(pts)), rmp, stitch=None, crescent=2)
    c.stitch_line(facet, rmp[2], dash=99)


crystal([(26, 92), (28, 54), (37, 34), (46, 54), (48, 92)], CRYS_B, [(37, 38), (37, 90)])
crystal([(98, 92), (100, 56), (109, 38), (118, 56), (120, 92)], CRYS_B, [(109, 42), (109, 90)])
crystal([(54, 92), (56, 40), (70, 12), (84, 40), (86, 92)], CRYS_P, [(70, 16), (70, 90)])
c.stitch_line([(63, 44), (63, 88)], THREAD_C, dash=2)
c.stitch_line([(77, 44), (77, 88)], CRYS_P[1], dash=2)
# small shards at the foot
crystal([(46, 94), (48, 84), (52, 78), (56, 94)], CRYS_P, [(52, 82), (52, 92)])
crystal([(86, 94), (88, 82), (92, 76), (96, 94)], CRYS_B, [(92, 80), (92, 92)])
for x, y in ((18, 44), (124, 30), (92, 24), (130, 66), (50, 26)):
    c.sparkle(x, y)
for x in (12, 20, 128):
    c.tuft(x, 100)
finish(c)
