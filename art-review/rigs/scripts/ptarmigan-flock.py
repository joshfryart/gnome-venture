#!/usr/bin/env python3
"""ptarmigan-flock "Ptarmigan Flock" (bird rig, 47 x 41, 7 parts): "White in winter, brown in summer, and cross in every season." (tundra, mountain)
One plump felt ptarmigan caught between seasons: a round snow-white body with a mottled brown back coming through (body), a white
wing with grey primaries (wing, +r lifts it), a short black tail fan (tail), a round head with a brown speckled crown, short dark
beak and the red comb pulled down over the eye into a cross scowl (head), a small dark eye (eyes), and fluffy feathered
"snowshoe" feet (legB darker behind, legF in front). The rig has one bird, so the flock is the name, not the picture."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from rigkit import *  # noqa

R = Rig('ptarmigan-flock')
SNOW = ('#ffffff', '#f1ece0', '#c9c5bc', '#8b8f96')
BROWN = WOOD
TAIL = SOOT
COMB = EMBER


def leg(pid, ramp):
    p = R.part(pid)
    x, y = R.pv(pid)
    p.add(p.m(capsule([(x, y - 1), (x + .5, 33)], 5, 4.4), ell(x + 1.6, 34, 3.6, 1.9)), ramp)
    p.pxs([(int(x) + 1, 35), (int(x) + 3, 35)], ramp[3])                                 # toe tufts


leg('legB', darker(SNOW))

p = R.part('tail')
p.add(p.m(poly([(18, 19.5), (7, 15.5), (5.5, 19.5), (6.5, 23.5), (18, 25)])), TAIL)
p.line([(8, 18), (15, 20.5)], '#6a5648'); p.line([(8, 22), (15, 22.5)], '#6a5648')

p = R.part('body')
bod = ell(23, 21.5, 12.5, 9.5)
p.add(p.m(bod), SNOW, stitch=SNOW[2])
back = inter(bod, lambda x, y: y < 17 - (x - 23) * .1)
p.add(p.m(back), ('#c9a96e', '#9a6b3f', '#74462a', '#4a2c1a'))
for q in ((16, 15), (19, 13), (22, 14), (25, 13), (28, 15), (14, 17), (18, 16), (24, 16), (31, 16), (21, 12)):   # mottling
    p.px(q[0], q[1], '#f1ece0' if (q[0] + q[1]) % 3 == 0 else '#4a2c1a')
p.pxs([(22, 27), (26, 28), (18, 28)], SNOW[2])                                          # belly feather ticks

leg('legF', SNOW)

p = R.part('wing')
wing = union(ell(19.5, 18, 6, 4.6), capsule([(20, 17), (13.5, 20.5), (8.5, 23)], 8, 3.4))
p.add(p.m(wing), SNOW, local=True)
p.edge(p.m(wing), SNOW[3], sides=((1, 0), (0, 1), (-1, 0)))                         # its own seam (its ink ring sits behind the body)
for a, b in (((10, 22), (14, 21.5)), ((11, 23.5), (15, 23))):
    p.line([a, b], SNOW[3])                                                               # grey primaries
p.line([(17, 14.5), (23, 14)], '#9a6b3f')                                                # brown shoulder feathers

p = R.part('head')
head = union(ell(32.5, 9.9, 6.8, 6.1), capsule([R.pv('head'), (31.5, 11)], 7, 7))
p.add(p.m(head), SNOW)
crown = inter(head, lambda x, y: y < 8 - (x - 32) * .15)
p.add(p.m(crown), ('#c9a96e', '#9a6b3f', '#74462a', '#4a2c1a'))
p.pxs([(30, 6), (33, 5), (28, 8)], '#4a2c1a'); p.px(31, 7, '#f1ece0')
p.add(p.m(poly([(38.4, 8.6), (42.6, 10.6), (38.4, 12.6)])), ('#74462a', '#4a2c1a', '#4a2c1a', '#2a1a10'), local=True, crescent=0)   # short dark beak
p.add(p.m(poly([(32, 4.4), (38.6, 5.8), (38.2, 7.2), (32.6, 6.4)])), COMB, local=True, crescent=0)   # red comb, pulled into a scowl
p.px(33, 12, BLUSH); p.px(34, 12, BLUSH)

p = R.part('eyes')
p.add(p.m(rect(35, 7, 37, 10)), (INK,) * 4, flat=True)
p.px(35, 7, CREAM)

R.save()
