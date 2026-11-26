#!/usr/bin/env python3
"""crystal-weaver "Crystal Weaver" (spider rig, 85 x 50, 7 parts): "A long-legged spider that spins threads so thin they ring. It does
not like to be rung." (medium, lv 25, trek ch3b crystal caves; Glass Thread)
A felt cave spider made of ice-lilac felt and glass: a smallish pear-shaped lilac abdomen with a pale cut-gem diamond pattern down its
back and a cluster of three mint felt crystals growing out of the top, spinnerets at the rear paying out a glinting glass thread to the
ground with a dewdrop bead on it, a dark-blue waist the legs grow from (body); a small pale-blue head-and-chest with two crystal fangs
and a palp (head); two button eyes and two bead eyes (eyes); eight very long, thin, three-jointed legs that rise to tall knees, kink
out at the ankle and stab down to the ground on points, pale ice blue with lilac crystal beads at the joints, two per part (leg1, leg2
behind and a shade darker; leg3, leg4 in front). Silhouette: stilts and crystals, much leggier and spikier than the orb spider."""
import importlib, math, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from rigkit import *  # noqa
H = importlib.import_module('_crawler_shale-slater')

R = Rig('crystal-weaver')
ABD = ('#f0ecfb', '#cdc2ee', '#9a88d4', '#5e4a9a')
CEP = ('#e4f0fa', '#b0cce6', '#7896c0', '#4a5e8a')
LEGC = ('#eef8ff', '#b8dcf0', '#7fb0d0', '#4a7aa0')
GEM = ('#ffffff', '#9ee8d2', '#4fb8a8', '#2a7a8a')
BEAD = LILAC


def leg(p, hip, knee, foot, ramp, bead):
    """hip -> tall knee -> ankle kinked outward -> pointed foot, beads at the joints"""
    out = 1 if foot[0] > knee[0] else -1
    ank = (knee[0] + (foot[0] - knee[0]) * .45 + out * 3, knee[1] + (foot[1] - knee[1]) * .45)
    p.add(p.m(capsule([hip, knee], 2.8, 2.3), capsule([knee, ank], 2.3, 2), capsule([ank, foot], 2, 1.1)), ramp, local=True, crescent=0)
    for q in (knee, ank):
        p.add(p.m(ell(q[0] + .5, q[1] + .5, 1.4, 1.4)), (bead[0], bead[1], bead[2], bead[2]), local=True, crescent=0)


for pid, legs, back in (('leg1', [((22, 8), (4, 44)), ((30, 13), (14, 44))], True), ('leg2', [((33, 3.5), (21, 44)), ((38.5, 8), (29, 44))], True),
                        ('leg3', [((55, 3), (63, 44)), ((50, 8.5), (55.5, 44))], False), ('leg4', [((64, 6), (80.5, 44)), ((59.5, 11.5), (72, 44))], False)):
    p = R.part(pid)
    a = R.pv(pid)
    for k, (knee, foot) in enumerate(legs):   # the far leg of each pair first, a shade darker
        far = back or k == 1
        leg(p, a, knee, foot, darker(LEGC) if far else LEGC, darker(BEAD) if far else BEAD)

# body: glass thread, waist, abdomen with gem pattern, crystal cluster
p = R.part('body')
p.add(p.m(capsule([(18, 33), (18, 43.5)], 1.1)), ('#ffffff',) * 4, flat=True)            # the glass thread
p.add(p.m(ell(18.5, 39, 1.6, 1.9)), GEM, local=True, crescent=0)                       # a dewdrop on it
p.add(p.m(ell(45, 29, 6, 4.2)), darker(CEP), local=True)                                 # the waist
crys = [poly([(20.5, 19.5), (16.5, 11), (17, 8), (19.5, 7.5), (25, 17)]),
        poly([(24.5, 17.5), (24.5, 5), (26.5, 2.2), (29, 3), (31, 16.5)]),
        poly([(30.5, 17), (33, 8.5), (35.5, 7), (37, 9.5), (36, 19)])]
for c in crys:
    p.add(p.m(c), GEM, local=True, crescent=1)
abd = union(rell(30, 26, 13.5, 10.5, -12), ell(18, 31, 3, 2.5))
p.add(p.m(abd), ABD, stitch=ABD[3])
for (a, b) in (((21, 25), (28, 19)), ((28, 19), (35, 25)), ((35, 25), (28, 31)), ((28, 31), (21, 25))):   # the cut-gem diamond
    p.line([a, b], ABD[0])
p.line([(28, 20), (28, 30)], ABD[2]); p.line([(22, 25), (34, 25)], ABD[2])
p.fill(p.m(inter(abd, lambda x, y: y > 32.5 - (x - 16) * .25)), ABD[2])                # darker belly
for pts in ([(18.5, 9), (22, 15)], [(26.5, 4), (27.5, 14)], [(35, 9), (33.5, 15)]):                # a bright facet down each crystal
    p.line(pts, GEM[0])
p.px(17, 31, ABD[3]); p.px(16, 32, ABD[3])                                                # spinnerets

# head: small, pale blue, crystal fangs, palp
p = R.part('head')
hd = union(ell(52.5, 27, 6.8, 5.6), capsule([R.pv('head'), (49, 27)], 6, 6))
p.add(p.m(capsule([(56, 30), (60, 31.5), (61, 34.5)], 2, 1.6)), darker(CEP), local=True, crescent=0)   # palp
for fx in (55.5, 58):
    p.add(p.m(poly([(fx - 1.4, 30.5), (fx + 1.4, 30.5), (fx + .4, 35.5), (fx - .8, 34)])), GEM, local=True, crescent=0)
p.add(p.m(hd), CEP)
p.add(p.m(ell(55.5, 28.8, 1.2, .9)), (BLUSH,) * 4, flat=True)

p = R.part('eyes')
H.button_eye(p, 53.4, 24.6, 2.4, look=1)
for ex, ey in ((57.8, 23.6), (50.8, 21), (54.2, 20.8)):
    p.add(p.m(ell(ex, ey, 1.2, 1.2)), (INK,) * 4, flat=True)

R.save()
