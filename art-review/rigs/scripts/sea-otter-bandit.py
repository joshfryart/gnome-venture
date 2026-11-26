#!/usr/bin/env python3
"""sea-otter-bandit "Sea Otter Bandit" (quad.rodent rig, 71 x 30, 8 parts; medium, coast, lvl 13; drops Blue Mussels, Bladderwrack, Seed Pearl)
"Cracks mussels on its tummy and considers your lunch pail an open shellfish."
A long, low felt sea otter in chocolate-brown felt with a stitched seam along the back, a pale cream-grey belly band; short stubby
legs, broad webbed hind flippers (tan pads). A long, thick, flat tail sticking out behind (tail). A pale, broad, flat-topped otter head
with tiny round ears, a fat whisker-pad muzzle with a button nose and cream whisker dots, a dark felt BANDIT MASK across the eyes and
a red polka-dot bandana knotted at the neck, its knot tails flapping back over the shoulder; a cream-and-ink eye peeks out of the mask (eyes)."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from rigkit import *  # noqa
import importlib
K = importlib.import_module('_quad_sea-otter-bandit')

R = Rig('sea-otter-bandit')
FUR = ('#b08460', '#80573a', '#5e3e28', '#3e2618')
FAR = darker(FUR)
PALE = ('#fbf3e2', '#e6d6b8', '#c4ab88', '#8a7458')
MASK = ('#4a3428', '#3a2820', '#2f2019', '#2a1a10')
PADC = ('#d9b07a', '#b48a4e', '#8a6438', '#5e3e28')
RED = EMBER

# far legs (behind the body)
K.leg(R, 'legBF', 27.5, FAR, 5, 5, paw=(4.2, 1.8), pad=darker(PADC))
K.leg(R, 'legFF', 49, FAR, 4.5, 4, paw=(2.8, 1.7))

# tail: long, thick, flat, tapering back and a little down
p = R.part('tail')
tail = capsule([(20, 14), (12, 16), (4.5, 19)], 9, 4.5)
p.add(p.m(tail), FUR, stitch=FUR[3])
p.line([(15, 13.5), (14, 16)], FUR[3]); p.line([(10, 15), (9.5, 17)], FUR[3])

# body: long low otter body, arched back, pale belly band, stitched seam
p = R.part('body')
torso = union(ell(26, 15, 10.5, 7.5), ell(38.5, 13.5, 11, 7.8), ell(45, 16, 6, 5.6), capsule([(18, 15.5), (46, 14)], 12, 11))
p.add(p.m(torso), FUR, stitch=FUR[3])
p.add(p.m(inter(torso, lambda x, y: y > 19.4 - (x - 20) * .06)), PALE)
p.line([(30, 12), (31, 14)], FUR[3]); p.line([(37, 11), (38, 13)], FUR[3])

# near legs: short stubby legs with round haunches; webbed hind flipper
p, m = K.leg(R, 'legBN', 23.5, FUR, 5.5, 5, paw=(4.6, 1.9), haunch=(22, 17, 5, 4), pad=PADC)
p.edge(p.m(inter(ell(22, 17, 5, 4), lambda x, y: y < 18.5)), FUR[3], sides=((0, -1), (-1, 0)))
for x in (25, 27):
    p.px(x, 25, PADC[3])
p, m = K.leg(R, 'legFN', 45, FUR, 4.5, 4, paw=(3, 1.8), pad=PADC, toes=PADC[3])

# head: pale, broad, flat-topped head, small ears, fat whisker muzzle, bandit mask, red bandana at the neck
p = R.part('head')
ears = union(ell(48.6, 5.0, 2.0, 1.8))
skull = union(ell(52.5, 9.6, 7.4, 6.1), capsule([R.pv('head'), (50, 11)], 9.5, 10))
muzzle = union(ell(59, 12, 4.6, 3.6))
p.add(p.m(ears), FUR, local=True)
p.add(p.m(skull, muzzle), PALE)
mask = inter(union(capsule([(46.5, 8.5), (51, 9.2), (56.5, 8.8)], 4.2, 3.6)), skull)
p.add(p.m(mask), MASK, flat=True)
p.pxs([(45, 9), (45, 10), (46, 11)], MASK[1])                                                     # the mask's tied end
p.add(p.m(ell(62.3, 10.8, 1.7, 1.4)), (INK,) * 4, flat=True)                                     # button nose
p.px(62, 10, PALE[0])
p.line([(62, 13), (60, 14), (57, 14)], INK)                                                       # mouth
p.pxs([(58, 11), (60, 12), (58, 13)], PALE[3])                                                     # whisker dots
collar = capsule([(46.3, 9), (48, 16.5)], 4.2, 4.2)
bib = poly([(45.5, 14.5), (52.5, 14), (49, 20.2)])
knot = union(poly([(45.5, 9), (40.5, 4.5), (39.5, 7), (43, 10.5)]), poly([(45, 10.5), (40.5, 11), (42.5, 13.5)]))
bm = p.m(collar, bib, knot)
p.add(bm, RED)
p.pxs([(47, 11), (48, 15), (50, 16), (48, 18), (42, 6), (43, 12)], CREAM)                          # polka dots
p.edge({q for q in p.m(skull) if q[0] < 46}, INK, sides=((-1, 0),))

# eyes: cream eye with an ink pupil peeking out of the mask
p = R.part('eyes')
ex, ey = 53, 9
p.add(p.m(ell(ex + .5, ey + .5, 1.9, 1.6)), K.solid(CREAM), flat=True)
p.add(p.m(rect(ex, ey - 1 + 1, ex + 2, ey + 2)), (INK,) * 4, flat=True)
p.px(ex + 1, ey, '#ffffff')

R.save()
