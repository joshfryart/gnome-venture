#!/usr/bin/env python3
"""ashen-ant "Ashen Ant" (bug.ant rig, 57 x 39, 9 parts): "An ant the colour of cold ashes. It no longer follows the scent trail, only you." (trek, blight; Ant Chitin)
A gaunt grey felt ant in profile, the blighted sibling of the scouts: a narrow pointed gaster hooked down at the tail, sewn in cold
ash-grey felt with cracked seams where a last ember still glows (abdo, behind), a thin hunched thorax with a spine on its back
(body), a long wedge head with open sickle mandibles and a cracked cheek (head), one hollow ember eye under a heavy brow (eyes),
two straight feelers aimed flat forward at you, not up at the air (antL far / antR near), and three long spindly legs (leg1..leg3)."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from rigkit import *  # noqa

R = Rig('ashen-ant')
P = {k: R.pv(k) for k in R.ids}
ASH = ('#d6d2c8', '#9a9a9c', '#6a6e76', '#464a52')
LEGC = ('#8b8f96', '#6a6e76', '#4e525a', '#4e525a')
GLOW = ('#f5cf6a', '#f08a4a', '#dd3a2a', '#a8241f')

# legs: long and spindly, knees high
for pid, pts in (('leg1', [(24, 24), (18.5, 26), (16, 33.5)]),
                 ('leg2', [(29, 24), (33, 27), (31, 33.5)]),
                 ('leg3', [(33.5, 24), (40.5, 26), (44.5, 33.5)])):
    p = R.part(pid)
    p.add(p.m(capsule(pts, 2.4, 1.5)), LEGC, crescent=0)

# abdo: narrow pointed gaster, hooked down at the tail, with glowing cracks
p = R.part('abdo')
gas = union(rell(12.6, 19.4, 8.4, 6.2, -8), capsule([(6.5, 22), (3.6, 25.6)], 4.4, 1.4))
p.add(p.m(gas, capsule([(19.5, 20.2), (24, 20.6)], 1.8)), ASH)
p.add(p.m(ell(22.2, 18.9, 1.5, 2.4)), ASH, local=True)                                     # petiole node
p.add(p.m(inter(gas, rell(16.2, 19.4, .9, 9, -8))), (ASH[2],) * 4, flat=True)                # band seam
p.line([(11, 15), (12, 18), (10, 20), (11, 23)], GLOW[2])                                  # cracked seams, a last ember
p.px(12, 18, GLOW[1]); p.px(10, 20, GLOW[0])

# body: thin hunched thorax with a back spine
p = R.part('body')
th = union(rell(29.2, 18.8, 5.2, 3.8, -16), poly([(24.4, 18), (25, 12.2), (28, 16.2)]))
p.add(p.m(th, capsule([(24, 22.8), (33.5, 22.8)], 2.6)), ASH)
p.line([(28, 17), (29, 20), (28, 22)], ASH[3])

# head: long wedge head, sickle mandibles open
p = R.part('head')
hd = union(rell(40.5, 15.8, 7.2, 4.6, 10), capsule([P['head'], (37, 17.5)], 4, 4.4))
p.add(p.m(hd), ASH)
p.add(p.m(capsule([(46, 16.5), (51.5, 15.2), (53, 18)], 2.2, 1.4)), LEGC, local=True, crescent=0)   # upper sickle
p.add(p.m(capsule([(45.5, 19.6), (50, 22.4), (52.5, 21)], 2.2, 1.4)), LEGC, local=True, crescent=0) # lower sickle
hm = p.m(hd)
for (x, y) in hm:
    if (x - 1, y) not in hm and x < 37 and y < 20:
        p.px(x, y, ASH[3])
p.line([(38, 19), (40, 18), (41, 20)], GLOW[2])                                            # a cracked cheek
p.px(40, 18, GLOW[1])

p = R.part('eyes')
ex, ey = 42.5, 15.4
p.add(p.m(ell(ex, ey, 2.3, 2.1)), (INK,) * 4, flat=True)                                     # a hollow socket ...
p.add(p.m(rect(42, 15, 44, 16)), (GLOW[1],) * 4, flat=True)                                  # ... with an ember for a pupil
p.add(p.m(rect(43, 15, 44, 16)), (GLOW[0],) * 4, flat=True)
p.add(p.m(capsule([(39.6, 12.6), (44.8, 13.4)], 1.2)), (ASH[3],) * 4, flat=True)              # heavy brow

# feelers: straight, aimed flat forward
for pid, pts, ramp in (('antL', [(37, 11.6), (38.5, 6.5), (43.5, 4)], darker(LEGC)),
                       ('antR', [(41, 11.6), (43, 7.5), (51, 6.5)], LEGC)):
    p = R.part(pid)
    p.add(p.m(capsule(pts, 1.8, 1.4)), ramp, crescent=0)

R.save()
