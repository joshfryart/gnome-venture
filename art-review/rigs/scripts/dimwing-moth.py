#!/usr/bin/env python3
"""dimwing-moth "Dimwing Moth" (bug.moth rig, 53 x 44, 10 parts): "A pale moth with clay-grey wings that only beat when nobody is
looking. It is drawn to the glow crystals and to your lantern." (trek, clay-bound caves, level 19; Wing Dust)
A plump, sleepy felt silk-moth, flying right: big ROUNDED clay-grey wings (not the dusk moth's swept points): a broad forewing with
a scalloped clay cross line, a pale dim ring spot and a dusting of glow-crystal blue (wingF), a round hind lobe with soft clay bands
(wingH), the far wing behind in darker clay (wingB); a fat fluffy cream body with a woolly collar and furry rings (body), a round
woolly head (head), a big dark moth eye under a heavy sleepy lid (eyes), wide feathery comb antennae (antL / antR) and two short
furry legs (leg1 / leg2)."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from rigkit import *  # noqa

R = Rig('dimwing-moth')
CLAY = ('#efe8dc', '#c9bdac', '#968a7c', '#655a50')
WOOL = ('#fffaf0', '#f2e4c0', '#d6c49a', '#9a8a6a')
GLOW = '#a9d6ea'

for pid, pts in (('leg1', [(24.5, 29.5), (22, 33.5), (21, 37)]), ('leg2', [(30.5, 29.5), (32.5, 33.5), (34, 36.5)])):
    p = R.part(pid)
    p.add(p.m(capsule(pts, 3, 2.2)), WOOL, crescent=0)
    p.px(pts[1][0] - 1, pts[1][1], WOOL[2])

# wingB: the far wing behind, rounded, darker clay
p = R.part('wingB')
wb = union(ell(30.5, 10, 4.6, 8), capsule([(31.5, 20.5), (30.5, 10)], 6))
p.add(p.m(wb), darker(CLAY), stitch=CLAY[3])

# wingF: the broad round forewing
p = R.part('wingF')
wf = union(ell(14.5, 11.5, 12, 9.4), capsule([(25.5, 21), (17, 13)], 8))
p.add(p.m(wf), CLAY, stitch=CLAY[3])
p.add(p.m(inter(wf, capsule([(9, 3.5), (6.5, 8), (8, 11), (6.5, 14.5), (11, 19)], 1.8))), (CLAY[2],) * 4, flat=True)   # the scalloped cross line
p.add(p.m(inter(wf, capsule([(21, 3.5), (19.5, 7), (21, 10.5), (20, 14)], 1.6))), (CLAY[2],) * 4, flat=True)
p.add(p.m(ell(15.5, 10.5, 2.6, 2.6)), (CLAY[3],) * 4, flat=True)                         # the dim ring spot
p.add(p.m(ell(15.5, 10.5, 1.5, 1.5)), (CLAY[0],) * 4, flat=True)
for q in ((6, 7), (5, 12), (10, 12), (12, 5), (18, 15), (21, 8), (24, 12), (9, 17), (17, 3)):
    p.px(q[0], q[1], GLOW)

# wingH: the round hind lobe with soft bands
p = R.part('wingH')
wh = union(ell(12, 27, 8.8, 5.8), capsule([(23.5, 24), (14, 25)], 7))
p.add(p.m(wh), CLAY, stitch=None)
p.add(p.m(inter(wh, minus(ell(12, 26.5, 6.6, 4), ell(12, 26.5, 5.2, 2.8)))), (CLAY[2],) * 4, flat=True)
p.px(8, 26, GLOW); p.px(14, 29, GLOW)
p.edge(p.m(wh), CLAY[3], sides=((0, -1), (-1, 0)))                                       # seam over the forewing

# body: fat, fluffy cream with a woolly collar and furry rings
p = R.part('body')
th = ell(27.5, 24.8, 6.2, 6)
ab = capsule([(24, 26), (17.5, 28.5), (14, 29.5)], 10.5, 7)
p.add(p.m(th, ab), WOOL)
for x0 in (15.5, 18.5, 21.5):
    p.add(p.m(inter(ab, lambda x, y, x0=x0: x0 <= x < x0 + 1, minus(lambda x, y: True, th))), (WOOL[2],) * 4, flat=True)
p.add(p.m(inter(th, ell(28.5, 20.6, 5.6, 2.6))), ('#ffffff', '#fffaf0', WOOL[1], WOOL[1]), flat=True)   # woolly collar
for q in ((23, 19), (26, 18), (29, 18), (32, 19.5), (13, 28), (12, 30)):
    p.px(q[0], q[1], '#ffffff')

# head: round and woolly
p = R.part('head')
hd = union(ell(35.5, 22.5, 6, 6), capsule([R.pv('head'), (33, 23)], 6, 6))
p.add(p.m(hd), WOOL)
for q in ((39, 18), (41, 21), (41, 25), (37, 27.5)):
    p.px(q[0], q[1], '#ffffff')
p.add(p.m(ell(38.5, 25, 1.3, 1)), (BLUSH,) * 4, flat=True)

# eyes: a big dark moth eye under a heavy, sleepy lid
p = R.part('eyes')
ex, ey = 36.3, 20.6
p.add(p.m(ell(ex, ey + .3, 3.2, 3.2)), (INK,) * 4, flat=True)
p.add(p.m(inter(ell(ex, ey + .3, 3.2, 3.2), lambda x, y: y < ey - 1)), (CLAY[1],) * 4, flat=True)
p.line([(ex - 3, ey - 1), (ex + 2.5, ey - 1)], INK)
p.px(37, 21, '#ffffff'); p.px(35, 22, UMBER2); p.px(36, 22, UMBER2)

# antennae: wide feathery fronds (a tan leaf on a short stalk, a dark rib, barbs stitched across)
import math
TAN = ('#e0c690', '#c9a96e', '#9a6b3f', '#74462a')
for pid, a, b in (('antL', (33, 16.5), (25, 5.5)), ('antR', (37, 16.5), (48, 8))):
    p = R.part(pid)
    L = math.hypot(b[0] - a[0], b[1] - a[1]); ang = math.degrees(math.atan2(b[1] - a[1], b[0] - a[0]))
    c = (a[0] + (b[0] - a[0]) * .6, a[1] + (b[1] - a[1]) * .6)
    p.add(p.m(capsule([a, c], 1.6), rell(c[0], c[1], L * .42, 2.6, ang)), TAN, crescent=0)
    dx, dy = (b[0] - a[0]) / L, (b[1] - a[1]) / L
    for t in (.4, .55, .7, .85):
        x, y = a[0] + dx * L * t, a[1] + dy * L * t
        p.line([(x - dy * 2, y + dx * 2), (x + dy * 2, y - dx * 2)], TAN[2])
    p.line([a, (a[0] + dx * (L - 1), a[1] + dy * (L - 1))], TAN[3])

R.save()
