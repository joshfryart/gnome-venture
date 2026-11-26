#!/usr/bin/env python3
"""gnat-cloud "Gnat Cloud" (bug.moth rig, 63 x 49, 11 parts): "Thousands of tiny wings, all aimed at your ears." (wetland, rainforest; dawn and dusk; Gnat Dust)
A felt swarm: a big lumpy dusk-grey fog puff (cloud, behind, on the 'cloud' spring) embroidered all over with tiny dark gnats, a few
strays loose at its edge; in front of it the ringleader gnat, flying right: a hunched dark thorax and a thin banded abdomen (body),
narrow clear glassy wings with a dark seam so they read over the fog (wingF near, wingB far), a little haltere knob (wingH), a small
round head with a long needle nose (head), one bright button eye (eyes), whorled thread antennae (antL / antR) and long thin
dangling legs (leg1 / leg2)."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from rigkit import *  # noqa

R = Rig('gnat-cloud')
FOG = ('#f4f1f8', '#d6d1e2', '#a8a1bf', '#6e688a')
GNAT = ('#9a8aa6', '#5a4a68', '#3c2e48', '#2a1a2e')
GLASS = ('#ffffff', '#e4f6ff', '#c8dcea', '#5e5878')

# legs: long and thin, dangling well below the cloud
for pid, legs in (('leg1', ([(28.5, 30.5), (25, 36), (23.5, 43)], [(29.5, 30.5), (28, 37), (29, 43)])),
                  ('leg2', ([(34.5, 30.5), (37.5, 36.5), (37, 43)], [(35, 30.5), (41, 35), (43.5, 42)]))):
    p = R.part(pid)
    p.add(p.m(*[capsule(l, 1.6, 1.2) for l in legs]), GNAT, crescent=0, flat=True)

# cloud: a lumpy fog puff, the swarm stitched into it
p = R.part('cloud')
lumps = [ell(16, 14.5, 9, 7), ell(29, 9.5, 11, 7.5), ell(43, 11, 10, 7.5), ell(53, 14, 6, 5.5), ell(8, 19, 4.5, 4),
         ell(30, 15.5, 23, 6), ell(13, 20.5, 5.5, 4), ell(45, 18.5, 6.5, 4.2), ell(54.5, 18.5, 4.5, 3.6), ell(21, 5.5, 5, 4), ell(38, 4.5, 5, 3.5), capsule([(28.5, 29.5), (29.5, 23), (27, 19)], 5, 7)]
cl = p.add(p.m(*lumps), FOG, stitch=FOG[2])
import random
rnd = random.Random(7)
spots = []
while len(spots) < 22:
    x, y = rnd.randint(7, 57), rnd.randint(3, 22)
    if all((x + dx, y + dy) in cl for dx in (-2, 0, 2) for dy in (-2, 0, 2)) and all(abs(x - a) + abs(y - b) > 5 for a, b in spots):
        spots.append((x, y))
for x, y in spots:                                    # tiny gnats: a dark dot body and a pale wing tick
    p.px(x, y, GNAT[1]); p.px(x + 1, y, GNAT[1]); p.px(x, y - 1, '#ffffff')
for x, y in ((3, 13), (59, 7), (57, 24), (11, 4), (6, 26)):   # strays outside the fog
    p.add(p.m(rect(x, y, x + 2, y + 1)), GNAT, flat=True)
    p.add(p.m(rect(x, y - 1, x + 1, y)), (GLASS[1],) * 4, flat=True)

# wingB: the far wing, narrow, standing up
p = R.part('wingB')
wb = capsule([(36.5, 25.5), (36, 17), (33.5, 10)], 4, 5)
p.add(p.m(wb), darker(GLASS), stitch=None)
p.edge(p.m(wb), GLASS[3])
p.line([(36, 23), (35, 13)], GLASS[2])

# wingF: the near wing, narrow, swept up and back
p = R.part('wingF')
wf = capsule([(30.5, 25.5), (24, 19), (16, 13.5)], 4, 6)
p.add(p.m(wf), GLASS, stitch=None)
p.edge(p.m(wf), GLASS[3])
p.line([(28.5, 23), (19, 15.5)], GLASS[2])

# wingH: the haltere, a little knob on a stalk
p = R.part('wingH')
p.add(p.m(capsule([(28.5, 28.5), (24, 28.5)], 1.4), ell(23.5, 28.5, 1.8, 1.6)), (FOG[0], CREAM, '#d6c49a', '#9a8a6a'), crescent=0)

# body: hunched dark thorax, thin banded abdomen
p = R.part('body')
th = ell(31.5, 29, 5.2, 4.4)
ab = capsule([(28, 30), (21, 31), (15.5, 31.5)], 4.6, 2.6)
p.add(p.m(th, ab), GNAT)
for x0 in (18, 21, 24):
    p.add(p.m(inter(ab, lambda x, y, x0=x0: x0 <= x < x0 + 1)), (GNAT[0],) * 4, flat=True)
p.add(p.m(inter(th, ell(31, 26.5, 3.6, 1.6))), (GNAT[0],) * 4, flat=True)

# head: small, round, with a long needle nose
p = R.part('head')
hd = union(ell(40.5, 28.3, 5.2, 4.6), capsule([R.pv('head'), (37, 29)], 4.5, 4.5))
p.add(p.m(hd, capsule([(43, 31), (49.5, 34.5)], 1.8, 1.2)), GNAT)
p.add(p.m(ell(43.5, 29.5, 1, .8)), (BLUSH,) * 4, flat=True)

# eyes: one bright button eye
p = R.part('eyes')
ex, ey = 41.3, 26.9
p.add(p.m(ell(ex, ey + .5, 2.3, 2.3)), (CREAM,) * 4, flat=True)
p.add(p.m(rect(41, 26, 43, 29)), (INK,) * 4, flat=True)
p.px(41, 26, '#ffffff')

# antennae: threads with whorl ticks
for pid, pts in (('antL', [(38, 25), (36, 21), (33, 19)]), ('antR', [(42, 25), (45.5, 21.5), (50, 20.5)])):
    p = R.part(pid)
    p.add(p.m(capsule(pts, 1.5, 1.1)), GNAT, crescent=0, flat=True)
    for k in (1, 2):
        x, y = pts[k]
        p.add(p.m(capsule([(x - 1.6, y - 1), (x + 1.6, y + 1)], 1.1)), GNAT, crescent=0, flat=True)

R.save()
