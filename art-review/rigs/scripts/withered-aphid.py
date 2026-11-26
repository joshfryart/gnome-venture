#!/usr/bin/env python3
"""withered-aphid "Withered Aphid" (bug.plain rig, 51 x 35, 8 parts): "A grey, papery aphid. Blight has dried it out and made it mean."
(small, lv 15, trek blight foe; Aphid Wings)
A small felt aphid gone dry and grey: a fat pear-shaped body, low at the back, with wrinkled seams, sickly plum blight blotches,
two little tail-pipe cornicles poking up at the rear and a crumpled papery wing folded tent-wise over its back (body);
a small grey head with a sucking beak tucked down (head); one red button eye under a mean slanted brow (eyes);
thin kinked feelers, the front one drooping at the tip (antL / antR); three thin knobbly legs (leg1..leg3)."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from rigkit import *  # noqa

R = Rig('withered-aphid')
DRY = ('#e8e4cc', '#bab59a', '#8c8770', '#5e5a4a')        # dried grey-green felt
LEG = ('#a89a84', '#7a6c5a', '#5a4c3e', '#3e3228')
WING = ('#fbf6e6', '#e6dcc0', '#c4b48e', '#9a8a68')        # crumpled paper
BLIGHT = ('#b08aa0', '#8a6a80', '#6a4a62', '#4a3046')

for pid, knee, foot in (('leg1', (12, 23.5), (9.5, 29.5)), ('leg2', (24, 25), (22, 29.5)), ('leg3', (32, 23.5), (35, 29.5))):
    p = R.part(pid)
    x, y = R.pv(pid)
    p.add(p.m(capsule([(x, y - 1), knee], 2.4, 2), capsule([knee, foot], 2, 1.6)), darker(LEG) if pid == 'leg1' else LEG, crescent=0)
    p.px(int(knee[0]), int(knee[1]), LEG[3])                                             # knobbly knee
    p.px(int(foot[0]) + 1, int(foot[1]), LEG[3])

p = R.part('body')
pear = union(ell(17.5, 16.5, 10, 9.2), capsule([(20, 17.5), (30, 17.5)], 11, 8))
pipes = union(capsule([(10, 18.5), (5, 16.5)], 2.6, 2.2), capsule([(11, 21), (6.5, 21.5)], 2.6, 2.2))
p.add(p.m(pipes), darker(DRY), local=True, crescent=0)
p.add(p.m(pear), DRY, stitch=None)
p.add(p.m(inter(pear, lambda x, y: y > 22.5)), (DRY[1], DRY[2], DRY[3], DRY[3]), flat=True)   # dusty underside
for q, r in (((13.5, 21), 2), ((22.5, 20.5), 1.5), ((9.5, 15), 1.3)):                   # blight blotches
    p.add(p.m(inter(ell(q[0], q[1], r * 1.2, r), pear)), BLIGHT, local=True, crescent=0)
for x0 in (12, 17, 22):                                                                   # dry wrinkles, curved round the body
    p.line([(x0 + 2, 11), (x0, 14), (x0 - .5, 18), (x0 + 1, 23)], DRY[2])
p.line([(27.5, 12.5), (27, 17), (28, 21.5)], DRY[3])                                     # the neck seam
wing = poly([(27, 12), (21, 8), (13, 4.5), (6, 3), (4.5, 4.5), (7, 6), (5.5, 7.5), (9, 9), (8, 10.5), (13, 11.5), (17, 13.5), (22, 14)])
p.add(p.m(wing), WING, stitch=None)
p.line([(26, 12), (17, 8.5), (8, 5)], WING[3])                                           # veins
p.line([(17, 8.5), (12, 10.5)], WING[3])
p.line([(21, 10.5), (18, 12.5)], WING[2])

p = R.part('head')
hd = union(ell(33.5, 17.5, 4.8, 4.6), capsule([R.pv('head'), (32, 17.5)], 6, 6))
p.add(p.m(hd), darker(DRY))
p.add(p.m(capsule([(36, 20.5), (35.5, 23), (33.5, 25)], 2, 1.4)), LEG, local=True, crescent=0)   # the sucking beak, tucked under
p.px(37, 19, DRY[3])
p.add(p.m(inter(ell(31.5, 15, 1.2, 1), hd)), BLIGHT, local=True, crescent=0)

p = R.part('eyes')
ex, ey = 34.8, 17.1
p.add(p.m(ell(ex, ey, 2.9, 2.9)), (INK,) * 4, flat=True)
p.add(p.m(ell(ex, ey, 2.0, 2.0)), ('#e0503a',) * 4, flat=True)
p.add(p.m(rect(35, 16, 36, 18)), (INK,) * 4, flat=True)
p.px(34, 16, '#ffd0b0')
p.add(p.m(inter(ell(ex, ey, 2.7, 2.7), lambda x, y: y < 15.6 + (x - 32) * .5)), (DRY[3],) * 4, flat=True)   # mean lid, low at the front
p.line([(32, 14), (37, 16)], INK)

for pid, pts in (('antL', [R.pv('antL'), (30.5, 8.5), (32, 5.5), (30.5, 3)]), ('antR', [R.pv('antR'), (40.5, 9.5), (46, 8), (48, 10.5)])):
    p = R.part(pid)
    p.add(p.m(capsule(pts, 2, 1.4)), LEG, crescent=0)
    p.px(int(pts[1][0]), int(pts[1][1]), LEG[3])                                         # a dry kink

R.save()
