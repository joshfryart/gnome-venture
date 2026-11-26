#!/usr/bin/env python3
"""tide-crab-knight "Tide Crab Knight" (crab rig, front view, 99 x 58, 10 parts): "Wears a shell like plate armour and duels anything
on its beach." (large, lv 19, coast and island; Tide Shell, Pearl)
A sea-blue felt crab dressed as a knight: a wide blue body with a stitched smile under the armour rim (body); over it a silver felt
breastplate helm with a raised centre ridge, a gold trim band, a plate seams, rivets and a tall red plume (shell); two stern button
eyes on stalks peering over the helm (eyeL / eyeR, sprung); a SHIELD claw on the left, the broad hand plated as a silver heater shield
with a gold cross and two stubby fingers on top (clawL), and a RAPIER claw on the right, its fixed finger drawn out into a long silver
blade with a short blue finger beside it (clawR); four blue legs with silver knee cops (leg1..leg4, behind).
Silhouette: plume and blade high, shield low and broad; asymmetric, unlike the shore crab's twin mittens."""
import math, os, sys
from importlib import import_module
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from rigkit import *  # noqa
CK = import_module('_crab_shore-crab')

R = Rig('tide-crab-knight')
X = CK.mirror(R)
SEA = ('#8fcbe4', '#3f8fb0', '#25637d', '#1f4a6a')
STEEL = ('#ffffff', '#dde3ea', '#a9b2bd', '#6b7480')
PLUME = EMBER
cx = R.pv('body')[0]

for pid, knee, foot in (('leg1', (14, 36), (4, 52.5)), ('leg2', (25, 40), (16.5, 52.5))):
    for q, k2, f2 in ((pid, knee, foot), ('leg4' if pid == 'leg1' else 'leg3', (X(knee[0]), knee[1]), (X(foot[0]), foot[1]))):
        p = CK.leg(R, q, k2, f2, SEA if pid == 'leg1' else darker(SEA), w=(4.6, 3.8, 1.8), tip=SEA[3])
        p.add(p.m(ell(k2[0], k2[1] - .5, 2.4, 2.2)), STEEL, local=True, crescent=1)       # knee cop

p = R.part('body')
bod = union(ell(cx, 38.5, 27, 9.5), ell(cx, 30, 18, 9), ell(cx, 32, 22.5, 6.5))
p.add(p.m(bod), SEA, stitch=SEA[3])
p.line([(cx - 3.5, 43.5), (cx - 1.5, 44.5), (cx + 1.5, 44.5), (cx + 3.5, 43.5)], INK)    # stern little mouth
CK.blush(p, cx - 9, 43); CK.blush(p, cx + 9, 43)

p = R.part('shell')
helm = inter(ell(cx, 33.5, 21, 14), lambda x, y: y < 39.5)
tufts = [((cx - 1, 15.5), 3.4), ((cx - 3, 11), 3.6), ((cx - 6.5, 7.5), 3.6), ((cx - 11, 5.5), 3.3), ((cx - 15.5, 5.5), 2.8), ((cx - 19, 7), 2.2)]
p.add(p.m(*[ell(c[0], c[1], r, r) for c, r in tufts], capsule([c for c, r in tufts], 5, 3)), PLUME, local=True)   # the plume, a row of felt tufts
for (c, r), (d, _) in zip(tufts, tufts[1:]):
    p.px((c[0] + d[0]) / 2, (c[1] + d[1]) / 2 + 1, PLUME[3])                                 # the seams between tufts
p.add(p.m(ell(cx, 19.5, 3, 2.4)), GOLD, local=True)                                           # the plume socket
p.add(p.m(helm), STEEL, stitch=STEEL[3])
p.add(p.m(inter(helm, rect(cx - 1, 0, cx + 1, 99))), (STEEL[0], STEEL[0], STEEL[1], STEEL[2]), flat=True)   # raised centre ridge
p.line([(cx - 2, 21), (cx - 2, 36)], STEEL[2]); p.line([(cx + 1, 21), (cx + 1, 36)], STEEL[2])
p.add(p.m(inter(helm, lambda x, y: y >= 36.5)), GOLD, flat=False)                            # gold trim band
for k in (-1, 1):                                                                             # curved plate seams (pauldron lames)
    p.line([(cx + k * 6, 24), (cx + k * 11, 27.5), (cx + k * 15, 33)], STEEL[2])
for x in (-16, -9, 8, 15):
    p.px(cx + x, 37.5, GOLD[3])                                                               # rivets on the band

for pid, br in (('eyeL', 1), ('eyeR', -1)):
    CK.stalk_eye(R, pid, 11, SEA, knob=4, stalk=3, look=1 if pid == 'eyeL' else 0, brow=br, lean=-1 if pid == 'eyeL' else 1)

p = R.part('clawL')                                                                           # the shield claw
a = R.pv('clawL')
p.add(p.m(capsule([a, (20, 31)], 5.6, 4.8), capsule([(20, 31), (15, 25)], 4.8, 5)), SEA, crescent=1)
p.add(p.m(capsule([(10, 11), (8, 5), (10, 3)], 4.2, 2.4), capsule([(18, 11), (19.5, 5.5), (17.5, 3.5)], 4.2, 2.4)), SEA, local=True, crescent=1)
shield = poly([(5, 9), (23, 9), (23.5, 18), (20, 25), (14, 29.5), (8, 25), (4.5, 18)])
p.add(p.m(shield), STEEL, stitch=GOLD[2])
p.add(p.m(inter(shield, union(rect(12.5, 0, 15.5, 99), rect(0, 14, 99, 17)))), GOLD, flat=True)   # gold cross
p.pxs([(10, 3), (17, 3)], SEA[3])

p = R.part('clawR')                                                                           # the rapier claw
a = R.pv('clawR')
p.add(p.m(capsule([a, (79, 31)], 5.6, 4.8), capsule([(79, 31), (84, 24)], 4.8, 5.4)), SEA, crescent=1)
p.add(p.m(capsule([(86, 16), (90, 9), (94.5, 2.5)], 4.8, 1.8)), STEEL, local=True, crescent=1)    # the blade finger
p.line([(87.5, 13.5), (92.5, 5)], STEEL[0])
p.add(p.m(capsule([(81, 16), (79.5, 11), (81, 8)], 3.8, 2)), SEA, local=True, crescent=1)            # the short moving finger
p.add(p.m(ell(84, 20, 5.6, 5.6)), SEA, local=True)
p.add(p.m(rell(85, 17, 5.2, 1.5, 33)), GOLD, local=True, crescent=0)                                # the gold guard
p.px(81, 8, SEA[3])

R.save()
