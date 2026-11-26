#!/usr/bin/env python3
"""dusk-moth "Dusk Moth" (bug.moth rig, 53 x 44, 10 parts): "Dazzles you with powdery wings in the twilight." (forest, grassland, mountain; Moth Wing, Wing Dust)
A slim felt hawk-moth at dusk, flying right: a long swept, sharp-tipped forewing in twilight lilac with a dark plum band and cream
powder specks (wingF), a rose hindwing below with a big gold-and-ink eyespot, the dazzle (wingH), the far forewing standing up
behind in deep plum (wingB), a plum fuzzy body tapering to a pointed tail with pale bands (body), a round head with a curled
gold tongue (head), one big button eye (eyes), thin curved antennae with a hooked tip (antL / antR) and two thin legs (leg1 / leg2)."""
import math, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from rigkit import *  # noqa

R = Rig('dusk-moth')
FORE = LILAC
PLUM = ('#8a72c8', '#4e3a8a', '#3a2a6a', '#2a1a40')
ROSE = PETAL
FUR = ('#c3b2ea', '#6a52a8', '#4e3a8a', '#2a1a40')
POWDER = '#fff3c8'

# legs: thin, jointed, dangling under the hovering body
for pid, pts in (('leg1', [(24.5, 29.5), (21.5, 34), (20.5, 38)]), ('leg2', [(30.5, 29.5), (33, 34), (35.5, 37.5)])):
    p = R.part(pid)
    p.add(p.m(capsule(pts, 2.2, 1.6)), FUR, crescent=0)

# wingB: the far forewing standing up behind, deep plum, swept back
p = R.part('wingB')
wb = poly([(29, 21), (33.5, 20.5), (33, 12), (30.5, 5), (27.5, 2.5), (27, 8), (27.5, 15)])
p.add(p.m(wb), PLUM, stitch=PLUM[0])

# wingF: the near forewing, long and swept with a sharp apex up-left
p = R.part('wingF')
wf = poly([(26.8, 22.5), (27, 17), (22, 10.5), (14, 5), (6, 2.4), (2.4, 3), (3, 7.5), (5, 12.5), (8.5, 17), (13.5, 20.5), (20, 22.8)])
p.add(p.m(wf), FORE, stitch=None)
p.add(p.m(inter(wf, capsule([(15.5, 6), (12.5, 12), (12, 19.5)], 2.2))), PLUM, flat=True)       # a dark wavy cross line
p.add(p.m(inter(wf, capsule([(21, 10), (19.5, 15), (20.5, 22)], 1.4))), PLUM, flat=True)        # a thin inner line
p.add(p.m(inter(wf, union(capsule([(7, 3.5), (3.5, 4.5), (4.5, 9)], 2.4)))), PLUM, flat=True)    # dark apex tip
p.add(p.m(ell(16.5, 13, 1.4, 1.4)), (PLUM[3],) * 4, flat=True)                                  # the discal spot
for q in ((9, 6), (6, 11), (8, 14), (10, 9), (17, 8), (24, 17), (16, 18), (24, 13), (9, 17)):
    p.px(q[0], q[1], POWDER)

# wingH: the rose hindwing with the dazzle eyespot
p = R.part('wingH')
wh = union(poly([(24.5, 22.5), (24.5, 28), (20, 32.5), (14, 35.5), (8, 35.5), (3.4, 32), (4, 26.5), (9, 22.5), (16, 20.8)]), ell(9, 31, 6.2, 5.4))
p.add(p.m(wh), ROSE, stitch=ROSE[2])
p.add(p.m(inter(wh, ell(9, 31.5, 3.9, 3.8))), (PLUM[3],) * 4, flat=True)
p.add(p.m(inter(wh, ell(9, 31.5, 2.9, 2.8))), GOLD, flat=True)
p.add(p.m(ell(9, 31.5, 1.4, 1.4)), (INK,) * 4, flat=True)
p.px(7, 30, CREAM)
p.edge(p.m(wh), ROSE[3], sides=((0, -1), (-1, 0)))                                       # seam where it lies over the forewing

# body: fuzzy thorax and a long tapering abdomen with pale bands
p = R.part('body')
th = ell(27.5, 24.8, 5.8, 5.6)
ab = union(capsule([(24, 26), (18.5, 28.5), (15, 30)], 9.5, 4.6))
p.add(p.m(th, ab), FUR)
axv = lambda x, y: x
for x0 in (15, 18, 21):
    p.add(p.m(inter(ab, lambda x, y, x0=x0: x0 <= x < x0 + 1.2, minus(lambda x, y: True, th))), (FORE[1], FORE[1], FORE[2], FORE[2]), flat=True)
p.add(p.m(inter(th, ell(28.5, 21, 5, 2.4))), (FORE[0], FORE[1], FORE[1], FORE[1]), flat=True)   # a pale furry collar
for q in ((24, 20), (27, 19), (30, 19.5), (32, 21.5)):
    p.px(q[0], q[1], FUR[0])

# head: round, fuzzy, with a curled gold tongue
p = R.part('head')
hd = union(ell(35, 22.5, 5.6, 5.8), capsule([R.pv('head'), (33, 23)], 6, 6))
p.add(p.m(hd), FUR)
tongue = capsule([(38.5, 27), (40.5, 29.5), (40, 31.5), (38.3, 31.2), (38.6, 30)], 1.3)
p.add(p.m(tongue), GOLD, flat=True)
p.add(p.m(ell(37.5, 25, 1.3, 1)), (BLUSH,) * 4, flat=True)

# eyes: one big button eye looking forward
p = R.part('eyes')
ex, ey = 36.3, 20.4
p.add(p.m(ell(ex, ey, 2.9, 2.9)), (INK,) * 4, flat=True)
p.add(p.m(ell(ex, ey, 2.0, 2.0)), (CREAM,) * 4, flat=True)
p.add(p.m(rect(36, 19, 38, 22)), (INK,) * 4, flat=True)
p.px(35, 19, '#ffffff')

# antennae: thin, curved back, a hooked clubbed tip
for pid, pts in (('antL', [(33, 16.5), (31, 11), (28, 7.5), (26.5, 7.5)]), ('antR', [(37, 16.5), (40, 11.5), (44, 8.5), (46.5, 9)])):
    p = R.part(pid)
    p.add(p.m(capsule(pts, 1.8, 1.4), ell(pts[-2][0], pts[-2][1], 1.5, 1.5)), FUR, crescent=0)

R.save()
