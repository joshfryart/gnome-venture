#!/usr/bin/env python3
"""storm-eagle "Storm Eagle" (bird rig, 83 x 85, 8 parts): "Rides the thunder above the peaks." (boss, mountain, level 32)
A big felt eagle leaning into the wind, side-on, the storm in its colours: a slate storm-cloud body with a paler rain-grey chest
and feather scallops (body), a broad folded thundercloud wing with a gold lightning bolt stitched down it and pale fingered primaries
(wing, +r lifts it), a long fanned tail with a white band at the tips behind (tail), a silver-white head with a swept-back crest
of storm feathers, a huge yellow hooked beak and a fierce gold eye under a black brow (head, eyes), shaggy slate trousers (thighs)
and scaly yellow legs with black talons (legB darker behind, legF in front)."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from rigkit import *  # noqa

R = Rig('storm-eagle')
STORM = ('#8f9aae', '#5d6880', '#3e4660', '#262b40')
CHEST = ('#c4ccd8', '#9aa4b6', '#6e7890', '#4a5268')
HEADW = ('#ffffff', '#e4e8ee', '#b9c0cc', '#8b8f96')
BEAK = ('#fff3c8', '#f5cf6a', '#e8a317', '#b87a14')
G = R.ground + 1


def leg(pid, ramp):
    p = R.part(pid)
    x, y = R.pv(pid)
    p.add(p.m(capsule([(x, y - 1), (x + .5, G - 3)], 4.2, 3.6)), ramp)
    p.add(p.m(capsule([(x - 2.5, G - 1.5), (x + 6, G - 1.5)], 3), capsule([(x, G - 2), (x - 4, G - 1.5)], 2.4)), ramp, local=True, crescent=0)
    for yy in range(int(y) + 4, int(G) - 4, 3):
        p.line([(x - 1, yy), (x + 1, yy)], ramp[3])                              # scales
    p.pxs([(int(x) + 7, G - 1), (int(x) + 7, G - 2), (int(x) + 3, G - 1), (int(x) - 5, G - 1)], INK)   # black talons


p = R.part('tail')
TIPS = ((7, 59), (8, 65), (11, 70), (16, 73.5))
feathers = [capsule([(31, 51), t], 7, 6) for t in TIPS]
p.add(p.m(*feathers), STORM)
p.add(p.m(inter(union(*feathers), union(*[ell(t[0], t[1], 4, 4) for t in TIPS]))), HEADW, local=True, crescent=0)   # white band at the tips
for t in TIPS[1:]:
    p.line([(27, 52), (t[0] + 2, t[1] - 3)], STORM[3])                          # feather seams

leg('legB', darker(GOLD))

p = R.part('body')
bod = union(rell(43, 46, 15.5, 20, 20), ell(47, 31, 9, 6), ell(53, 41, 7.5, 10))
p.add(p.m(bod), STORM, stitch=STORM[3])
chest = inter(bod, rell(55, 45, 6.5, 15, 18))
p.add(p.m(chest), CHEST)
for q in ((50, 36), (54, 41), (49, 44), (53, 49), (48, 53), (52, 57), (46, 60)):  # feather scallops
    p.px(q[0], q[1], CHEST[2]); p.px(q[0] + 1, q[1] + 1, CHEST[2]); p.px(q[0] + 2, q[1], CHEST[2])

leg('legF', GOLD)

p = R.part('thighs')
th = union(ell(38.5, 63.5, 7, 6), ell(48.5, 63.5, 7.5, 6.2))
p.add(p.m(th), STORM, local=True)
p.pxs([(34, 68), (37, 69), (40, 68), (45, 69), (48, 70), (51, 69), (54, 67)], STORM[3])
p.line([(43, 60), (43, 67)], STORM[2])

p = R.part('wing')
wing = union(ell(38.5, 40, 9.5, 9), capsule([(38, 39), (29, 56), (19, 69)], 18, 5))
p.add(p.m(wing), darker(STORM), local=True)
p.edge(p.m(wing), INK, sides=((1, 0), (0, 1)))
prim = inter(wing, lambda x, y: y > 56)
p.add(p.m(prim), STORM, local=True)
for a, b in (((25, 58), (20, 67)), ((29, 59), (23, 69)), ((33, 58), (27, 66))):
    p.line([a, b], STORM[3])                                                      # fingered primaries
p.line([(41, 34), (35, 44), (39, 45), (31, 55), (34, 56), (27, 64)], GOLD[0])  # stitched lightning bolt
p.line([(42, 34), (36, 44), (40, 45), (32, 55), (35, 56), (28, 64)], GOLD[1])

p = R.part('head')
hx, hy = 56, 19
head = union(ell(hx, hy, 9.5, 8.5), capsule([R.pv('head'), (53, 22)], 13, 13))
crest = union(capsule([(50, 13), (42, 7.5)], 5, 2), capsule([(49, 16), (40, 13.5)], 5, 2), capsule([(49, 19), (42, 20)], 4.5, 2))
p.add(p.m(head, crest), HEADW)
p.line([(44, 10), (50, 14)], HEADW[2]); p.line([(43, 13.5), (49, 17)], HEADW[2])
beak = poly([(62, 13), (69, 11.5), (74, 13.5), (76, 18), (75, 22.5), (73, 19.5), (69, 20.5), (69, 23), (62, 23)])
p.add(p.m(beak), BEAK, local=True, crescent=1)
p.line([(63, 20), (71, 19.5)], BEAK[3])                                          # gape
p.add(p.m(ell(64.5, 15.5, 2.6, 2.2)), ('#fff3c8', '#f5cf6a', '#f5cf6a', '#f5cf6a'), local=True, crescent=0)   # cere
p.px(65, 15, INK)                                                                # nostril
p.add(p.m(inter(head, ell(52, 30, 8, 3.5))), CHEST, local=True)                 # grey collar where the head meets the body

p = R.part('eyes')
ex, ey = 58, 17
p.add(p.m(ell(ex + .5, ey + .5, 2.6, 2.3)), (INK,) * 4, flat=True)
p.add(p.m(ell(ex + .5, ey + .5, 1.8, 1.5)), ('#f5cf6a',) * 4, flat=True)
p.add(p.m(rect(ex, ey, ex + 2, ey + 2)), (INK,) * 4, flat=True)
p.add(p.m(inter(ell(ex + .5, ey + .5, 2.6, 2.3), lambda x, y: y < ey + .2)), (STORM[2],) * 4, flat=True)   # heavy lid
p.line([(ex - 4, ey - 2.5), (ex + 4, ey - .5)], INK)                             # fierce brow

R.save()
