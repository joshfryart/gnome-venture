#!/usr/bin/env python3
"""beaver-foreman "Beaver Foreman" (quad.rodent rig, 83 x 45, 8 parts; large, wetland/forest, lvl 22; drops Birch Log, Velvet Pelt, Cattail Root)
"Directs a dam crew with a flat tail and a loud slap. Everything is a lumber order."
A big, hunched, pear-shaped beaver in warm chestnut felt with a stitched seam round the body; short thick legs, big
dark webbed hind feet. A broad, flat, oval paddle tail in dark leathery felt with a stitched criss-cross scale pattern, lying out
behind (tail). A round head with small round ears, a fat tan muzzle with a button nose, two big orange buck teeth, and a yellow felt
FOREMAN HARD HAT with a brim and a ridge, a small ear peeking out under the brim; a tan chin. Small button eye under the brim (eyes)."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from rigkit import *  # noqa
import importlib
K = importlib.import_module('_quad_sea-otter-bandit')

R = Rig('beaver-foreman')
FUR = ('#c88a52', '#9c6236', '#764626', '#52301a')
FAR = darker(FUR)
TAN = ('#f6dcae', '#dcb27c', '#b88a52', '#8a6438')
FOOT = ('#6a5048', '#4e3a34', '#3a2a26', '#2a1a10')
PADDLE = ('#8a7a72', '#5e5050', '#463a3c', '#2e2428')
HAT = GOLD
TOOTH = ('#ffd27a', '#f0a030', '#c87a1a', '#7a4a1f')

# far legs
K.leg(R, 'legBF', 34, FAR, 8, 7, paw=(5, 2.4), pad=FOOT)
K.leg(R, 'legFF', 56, FAR, 6.5, 5.5, paw=(3.6, 2.2), pad=darker(FUR))

# tail: the flat paddle lying out behind, criss-cross scales
p = R.part('tail')
pad_ = rell(12.5, 30.5, 10.5, 4.6, -6)
p.add(p.m(pad_, capsule([R.pv('tail'), (19, 29)], 6, 5)), PADDLE, stitch=PADDLE[3])
for x0 in (6, 10, 14, 18):
    p.line([(x0, 27.5), (x0 + 3, 33)], PADDLE[0]); p.line([(x0 + 3, 27), (x0, 33)], PADDLE[0])

# body: a big hunched pear, tan belly, stitched seam
p = R.part('body')
torso = union(ell(34, 25, 13.5, 12.5), ell(45.5, 23, 10, 10.5), ell(51, 29, 6, 6))
p.add(p.m(torso), FUR, stitch=FUR[3])
for a, b in (((30, 17), (31, 20)), ((38, 15), (39, 18)), ):
    p.line([a, b], FUR[3])

# near legs: round haunch, big dark webbed hind foot; short front leg with a small hand
p, m = K.leg(R, 'legBN', 28, FUR, 9, 8, paw=(5.8, 2.6), haunch=(26.5, 29, 7, 6.5), pad=FOOT, toes=FOOT[0])
p.edge(p.m(inter(ell(26.5, 29, 7, 6.5), lambda x, y: y < 32)), FUR[3], sides=((0, -1), (-1, 0)))
p, m = K.leg(R, 'legFN', 51, FUR, 7, 6, paw=(3.8, 2.3), pad=darker(FUR), toes=CREAM)

# head: round skull, small ears, tan muzzle, nose, buck teeth, yellow hard hat
p = R.part('head')
skull = union(ell(58, 18.5, 8.6, 7.8), capsule([R.pv('head'), (55, 20)], 12, 12))
muzzle = ell(66.5, 21.5, 5.2, 4.4)
p.add(p.m(ell(51, 14.5, 2.3, 2.1)), FUR, local=True)                                             # ear, under the brim
p.add(p.m(skull), FUR)
p.add(p.m(muzzle, inter(skull, ell(58, 27, 6, 3.5))), TAN, local=True)
p.add(p.m(rect(64, 25, 69, 30.5)), TOOTH)                                                        # buck teeth
p.line([(66, 26), (66, 29)], TOOTH[3])
p.add(p.m(ell(71, 19.5, 1.9, 1.6)), (INK,) * 4, flat=True)                                         # nose
p.px(70, 19, FUR[0])
p.line([(70, 22), (68, 24), (65, 24)], INK)
p.pxs([(66, 21), (68, 22), (65, 22)], TAN[3])                                                       # whisker dots
hat = union(inter(ell(57.5, 12, 8.2, 6.5), lambda x, y: y < 12.6), capsule([(47.5, 12.5), (69, 12)], 2.6, 2.4))
p.add(p.m(hat), HAT, stitch=None)
p.line([(57, 6), (57, 11)], HAT[2]); p.line([(56, 6), (56, 11)], HAT[0])                            # the hat's ridge
p.line([(48, 13), (68, 13)], HAT[3])
p.edge({q for q in p.m(skull) if q[0] < 52}, INK, sides=((-1, 0),))

# eyes: small button eye under the brim
p = R.part('eyes')
K.eye_dot(p, 60.4, 16.4, r=1.3)

R.save()
