#!/usr/bin/env python3
"""leafcutter-column "Leafcutter Column" (bug.ant rig, 75 x 46, 10 parts): "A marching green parade of leaves, each carried by an ant
who has opinions about your trowel." (medium, rainforest, lvl 14; Ant Chitin, Fiddleheads)
A long-legged brick-red felt leafcutter in profile, marching under its load: a small heart-shaped gaster on a petiole knot (abdo,
behind), a hunched thorax bristling with three pairs of felt spines (body), a big heart-lobed soldier head with heavy mandibles
clamped on a leaf stalk (head), one stern button eye under a frown seam (eyes), two elbowed feelers (antL far / antR near), three
long jointed legs striding (leg1..leg3), and the leaf itself (leaf, behind the head, sprung): a big bright half-moon of leaf with a
bitten-out cut edge, sewn veins, and a tiny minim ant hitchhiking on top, the next ant of the column."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from rigkit import *  # noqa

R = Rig('leafcutter-column')
P = {k: R.pv(k) for k in R.ids}
RED = ('#e8905e', '#b8562e', '#86391f', '#561f14')
LEGC = ('#9a4424', '#74301c', '#4a2c1a', '#4a2c1a')
LEAF = ('#dcef90', '#8cc24a', '#5a9234', '#2f5a2a')

# legs: long, thin, jointed, striding
for pid, pts in (('leg1', [(32, 28.5), (25, 30.5), (20.5, 40)]),
                 ('leg2', [(38, 28.5), (42.5, 32.5), (41, 40)]),
                 ('leg3', [(43.5, 28.5), (51, 31), (56.5, 40)])):
    p = R.part(pid)
    p.add(p.m(capsule(pts, 2.6, 1.7)), LEGC, crescent=0)
    fx, fy = pts[-1]
    p.add(p.m(ell(fx + (1 if pid != 'leg1' else -1), fy, 1.5, .9)), LEGC, local=True, crescent=0)

# abdo: small heart-shaped gaster on a petiole knot
p = R.part('abdo')
gas = union(rell(18, 22.8, 8.8, 6.6, -14), rell(24, 23.6, 3.4, 3.4, 0))
p.add(p.m(gas, capsule([(25, 23.5), (32, 24.5)], 2.6, 2.4)), RED)
p.add(p.m(ell(28.8, 22.6, 1.8, 2.4)), RED, local=True)                                   # petiole knot
p.add(p.m(inter(gas, rell(15, 23.2, 1.0, 9, -14))), (RED[2],) * 4, flat=True)              # band seam
p.add(p.m(inter(gas, rell(21, 22.8, 1.0, 9, -14))), (RED[2],) * 4, flat=True)
for q in ((12, 18), (13, 18), (17, 17), (18, 17), (22, 18)):
    p.px(q[0], q[1], RED[0])

# body: hunched thorax with three pairs of spines, sternum strip for the hips
p = R.part('body')
th = union(rell(37, 21, 7.2, 5, -12), capsule([(31, 27.4), (44.5, 27.4)], 3))
spines = union(capsule([(32.5, 18), (29.5, 12.5)], 2.6, 1), capsule([(36.5, 16.5), (37, 11)], 2.6, 1),
               capsule([(41, 18), (44, 13.5)], 2.4, 1))
p.add(p.m(th, spines), RED)
p.line([(34, 18), (33, 22), (34, 25)], RED[3])                                             # shoulder seam
p.line([(39, 18), (40, 22)], RED[2])

# head: big heart-lobed soldier head, heavy mandibles on the leaf stalk
p = R.part('head')
hd = union(ell(51.5, 19.5, 7.6, 6.4), ell(47.5, 15.6, 4, 3.4), capsule([P['head'], (47, 21.5)], 5, 6))
p.add(p.m(hd), RED)
p.add(p.m(capsule([(57, 21.5), (61.5, 22), (65.5, 25)], 2.8, 2)), LEGC, local=True, crescent=0)   # top mandible
p.add(p.m(capsule([(56.5, 24.5), (61, 27), (65, 26.5)], 2.6, 1.8)), LEGC, local=True, crescent=0) # bottom mandible
hm = p.m(hd)
for (x, y) in hm:                                                                          # neck seam
    if (x - 1, y) not in hm and x < 46 and y > 17:
        p.px(x, y, RED[3])
p.line([(46, 14), (47, 17), (49, 18)], RED[2])                                             # the lobe dent of the heart head
p.line([(55, 23), (57, 24)], RED[3])                                                       # grumpy mouth
p.px(51, 22, BLUSH); p.px(52, 22, BLUSH)

p = R.part('eyes')
ex, ey = 53.7, 18
p.add(p.m(ell(ex, ey, 2.2, 2.2)), (INK,) * 4, flat=True)
p.add(p.m(ell(ex, ey, 1.3, 1.3)), (CREAM,) * 4, flat=True)
p.add(p.m(rect(54, 17, 55, 19)), (INK,) * 4, flat=True)
p.add(p.m(capsule([(51, 14.8), (56, 16)], 1.2)), (RED[3],) * 4, flat=True)                   # frown seam: opinions about trowels

# feelers: elbowed, forward
for pid, pts, ramp in (('antL', [(47.7, 13.3), (43, 8.5), (46.5, 4)], darker(LEGC)),
                       ('antR', [(52.5, 13.3), (49.5, 8), (53, 4.5)], LEGC)):
    p = R.part(pid)
    p.add(p.m(capsule(pts, 2, 1.5), ell(pts[-1][0], pts[-1][1], 1.3)), ramp, crescent=0)

# leaf: a big bitten half-moon held up by its stalk, veins, and a minim ant riding on top
p = R.part('leaf')
blade = minus(rell(62.5, 10, 11, 8.6, -22), ell(53, 19, 4.6), ell(73, 19, 3.6))
p.add(p.m(blade, capsule([(64.5, 25.5), (63.5, 19)], 1.8, 1.4)), LEAF, stitch=LEAF[2])
p.line([(64, 24), (63, 14), (61, 9)], LEAF[3])                                             # midrib
for a, b in (((63, 16), (56, 13)), ((63, 13), (70, 7)), ((64, 18), (71, 13))):
    p.line([a, b], LEAF[2])
minim = union(rell(59.3, 6.8, 2.6, 1.8, -20), ell(62.6, 5.4, 1.4, 1.3), ell(65.3, 4.3, 1.8, 1.7))
mm = p.m(minim); p.add(mm, (RED[0], RED[1], RED[2], RED[2]), local=True, crescent=0); p.edge(mm, INK)
p.px(66, 4, CREAM)
p.line([(61, 8), (60, 10)], INK); p.line([(63, 7), (64, 9)], INK); p.line([(66, 3), (68, 2)], INK)

R.save()
