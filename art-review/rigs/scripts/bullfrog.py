#!/usr/bin/env python3
"""bullfrog "Bullfrog" (frog rig, 55 x 40, 6 parts, front view): "One gulp and you'd be lunch. Keep moving." (wetland, rainforest; Frog Skin, Croak Sac)
A big squat felt bullfrog filling the frame: a wide moss-green body with darker warts, a cream-yellow throat sac, the huge
wide mouth seam, round eardrums and little webbed hands (body, squashes from the ground); big hind legs folded at the sides with
splayed webbed feet (footL / footR, behind the body); two tall eye domes with gold eyes and slit pupils (eyeL / eyeR, they blink
by squashing down onto their pivots); and the fly it has its eye on, hovering above (fly)."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from rigkit import *  # noqa

R = Rig('bullfrog')
SKIN = MOSS
BACK = PINE
THROAT = ('#fff3c8', '#f2e4c0', '#e0c690', '#c9a96e')

for pid in ('footL', 'footR'):
    p = R.part(pid)
    x, y = R.pv(pid)
    s = -1 if pid == 'footL' else 1
    thigh = ell(x - s * 1, 27.5, 6.5, 6)
    foot = union(poly([(x - s * 3, 31.5), (x + s * 8, 30.5), (x + s * 9, 34.6), (x - s * 7, 34.8)]))
    p.add(p.m(foot), darker(SKIN))
    for k in (-4, 0, 4):                                                                 # webbed toes
        p.px(x + s * k, 34, SKIN[3]); p.px(x + s * k, 33, SKIN[3])
    p.add(p.m(thigh), SKIN)
    p.line([(x - s * 4, 25), (x + s * 2, 30)], SKIN[2])                                 # knee crease
    p.px(x - s * 2, 26, BACK[2]); p.px(x, 29, BACK[2])

p = R.part('body')
bod = ell(28, 24.4, 19.5, 10.9)
p.add(p.m(bod), SKIN, stitch=None)
top = inter(bod, lambda x, y: y < 20.5 + abs(x - 28) * .1)
p.add(p.m(top), (SKIN[1], BACK[0], BACK[1], BACK[2]))
throat = inter(ell(28, 31, 12, 6), bod)
p.add(p.m(throat), THROAT)
mouth = [(10.5, 23.5), (16, 26.5), (22, 27.8), (28, 28), (34, 27.8), (40, 26.5), (45.5, 23.5)]
p.line(mouth, INK)
p.px(10, 22, INK); p.px(46, 22, INK)                                                    # mouth corners turn up a little
for sx in (-1, 1):
    tx = 28 + sx * 14.5
    p.add(p.m(ell(tx, 19.5, 3.2, 3)), (SKIN[2], SKIN[2], SKIN[3], SKIN[3]), local=True, crescent=1)   # eardrum
    p.px(int(tx) - 1, 18, SKIN[1])
for q in ((21, 17), (35, 17), (25, 15), (31, 15), (14, 21), (42, 21), (28, 19), (19, 21), (37, 21)):   # warts
    p.px(q[0], q[1], BACK[2]); p.px(q[0], q[1] - 1, BACK[0])
p.pxs([(26, 22), (30, 22)], SKIN[3])                                                    # nostrils
for hx in (20, 36):                                                                     # little webbed hands at the front
    p.add(p.m(ell(hx, 34, 3.2, 1.5)), SKIN, local=True, crescent=0)
    p.pxs([(hx - 2, 34), (hx, 34), (hx + 2, 34)], SKIN[3])
p.px(17, 26, BLUSH); p.px(18, 26, BLUSH); p.px(38, 26, BLUSH); p.px(39, 26, BLUSH)

for pid in ('eyeL', 'eyeR'):
    p = R.part(pid)
    x, y = R.pv(pid)
    dome = ell(x, y - 4, 5.6, 5.4)
    p.add(p.m(dome), (SKIN[0], BACK[0], BACK[1], BACK[2]))
    p.add(p.m(ell(x, y - 3.6, 3.6, 3.4)), ('#f5cf6a', '#f5cf6a', '#e8a317', '#b87a14'), local=True, crescent=1)
    p.add(p.m(rect(x - 1.5, y - 4.6, x + 1.5, y - 2.4)), (INK,) * 4, flat=True)          # wide pupil
    p.px(int(x) - 2, int(y - 6), CREAM)
    p.line([(x - 3, y - 7.6), (x + 3, y - 7.6)], BACK[2])                                 # lid seam

p = R.part('fly')
fx, fy = R.pv('fly')
p.add(p.m(ell(fx - 2.2, fy - 1.6, 2, 1.4), ell(fx + 2.2, fy - 1.6, 2, 1.4)), ('#ffffff', '#e4f6ff', '#a9d6ea', '#3f8fb0'), local=True, crescent=0)
p.add(p.m(ell(fx, fy + .5, 2.2, 1.6)), STONE[1:] + (STONE[3],), local=True, crescent=0)
p.add(p.m(ell(fx, fy + .5, 2.2, 1.6)), ('#5b6470', '#5b6470', '#2a1a10', '#2a1a10'), local=True, crescent=0)
p.px(int(fx) + 1, int(fy), EMBER[1])

R.save(floating=('fly',))
