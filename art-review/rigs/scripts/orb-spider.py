#!/usr/bin/env python3
"""orb-spider "Orb Spider" (spider rig, 85 x 50, 7 parts): "Weaves wheels of silk across the path and waits." (medium, lv 5, anywhere;
Spider Silk, Spider Fang)
A felt garden cross spider in profile: a big round russet abdomen with the cream cross and a row of pale dots along its back, a stitched
seam, little spinnerets at the rear paying out a silk line to the ground (body; it also carries the dark waist the legs grow from);
a smaller brown head-and-chest with cream hooked fangs and a short palp (head); two button eyes and two tiny bead eyes (eyes);
eight long legs, two per part, arching high at the knee and down to the ground, brown with cream bands (leg1, leg2 behind, darker;
leg3, leg4 in front)."""
import math, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from rigkit import *  # noqa

R = Rig('orb-spider')
ABD = ('#f4b47e', '#d67c40', '#a4522a', '#6e321c')
CEP = ('#c8906a', '#9a5e3a', '#6e3e24', '#4a2618')
LEG = ('#b07850', '#86522e', '#5e3820', '#3e2414')
BAND = ('#fff3c8', '#f2e4c0', '#c9a96e', '#9a6b3f')


def leg(p, pts, ramp, band):
    """a jointed spider leg: thick femur up to the knee, thinner tibia down to the foot, cream bands at the joints"""
    p.add(p.m(capsule(pts[:2], 3, 2.6), capsule(pts[1:], 2.6, 1.6)), ramp, local=True, crescent=0)
    for (a, b), ts in ((pts[1:], (.0, .55)),):
        for t in ts:
            c = (a[0] + (b[0] - a[0]) * t, a[1] + (b[1] - a[1]) * t)
            p.fill(p.m(inter(ell(c[0], c[1], 1.6, 1.6), capsule([a, b], 3, 2))), band)
    p.px(int(pts[-1][0]), int(pts[-1][1]), ramp[3])


for pid, legs, back in (('leg1', [[(23, 8.5), (4, 44)], [(30, 14), (14, 44)]], True), ('leg2', [[(33, 3.5), (21, 44)], [(39, 8), (29, 44)]], True),
                        ('leg3', [[(55, 3), (63, 44)], [(50, 8.5), (55, 44)]], False), ('leg4', [[(64, 6.5), (80.5, 44)], [(60, 12), (72, 44)]], False)):
    p = R.part(pid)
    a = R.pv(pid)
    for k, (knee, foot) in enumerate(legs):    # the far leg of the pair first, a shade darker
        leg(p, [a, knee, foot], darker(LEG) if back or k == 1 else LEG, BAND[2] if back or k == 1 else BAND[1])

p = R.part('body')
abd = union(rell(30, 27, 15.5, 13, -10), ell(16.5, 33, 3, 2.6))
p.add(p.m(capsule([(16.5, 35), (16.5, 43.5)], 1.2)), (CREAM,) * 4, flat=True)         # the silk line, down to the ground
p.add(p.m(ell(45, 29, 6, 4.2)), CEP, local=True)                                    # the waist the legs grow from
p.add(p.m(abd), ABD, stitch=ABD[3])
p.add(p.m(inter(abd, lambda x, y: y > 33 - (x - 16) * .3)), (ABD[2], ABD[2], ABD[3], ABD[3]), flat=True)   # darker belly
for q in ((20, 19), (25, 16), (31, 15), (37, 16.5), (41.5, 20)):                     # pale dots along the back
    p.add(p.m(ell(q[0], q[1] + 1, 1.3, 1.1)), BAND, flat=True)
cx, cy = 32, 22                                                                       # the cream cross
p.add(p.m(union(capsule([(cx - 4, cy), (cx + 4, cy)], 2), capsule([(cx, cy - 4), (cx, cy + 4.5)], 2))), BAND, flat=True)
p.px(16, 32, ABD[3]); p.px(15, 33, ABD[3])                                           # spinnerets

p = R.part('head')
hd = union(ell(53.5, 26.5, 8, 6.6), capsule([R.pv("head"), (50, 27)], 6.5, 6.5))
p.add(p.m(capsule([(57, 29), (61.5, 31), (62.5, 34)], 2.2, 1.8)), darker(CEP), local=True, crescent=0)   # palp
p.add(p.m(hd), CEP)
for fx in (57, 59.5):                                                                   # cream hooked fangs
    p.add(p.m(poly([(fx - 1.5, 31), (fx + 1.5, 31), (fx + .5, 35), (fx - 1, 34)])), BAND, local=True, crescent=0)
p.add(p.m(ell(56.5, 29.3, 1.2, .9)), (BLUSH,) * 4, flat=True)

p = R.part('eyes')
for ex, ey, r in ((53.5, 24.6, 2.6), (57.6, 25.2, 2.2)):                               # two button eyes
    p.add(p.m(ell(ex, ey, r + .9, r + .9)), (INK,) * 4, flat=True)
    p.add(p.m(ell(ex, ey, r, r)), (CREAM,) * 4, flat=True)
    p.add(p.m(rect(int(ex), int(ey) - 1, int(ex) + 2, int(ey) + 1)), (INK,) * 4, flat=True)
for ex, ey in ((52, 20.8), (55.5, 21.2)):                                              # and two little bead eyes on top
    p.add(p.m(ell(ex, ey, 1.2, 1.2)), (INK,) * 4, flat=True)

R.save()
