#!/usr/bin/env python3
"""mangrove-crab-king "Mangrove Crab King" (crab rig, front view, 99 x 58, 10 parts): "Rules the root tangle with one huge claw and a
very small crown of barnacles." (large, lv 30, coast, island and wetland; Crab Shell, Crab Claw, Pearl)
A plum-purple felt mangrove crab with a royal lopsided build: a wide plum body with a smug stitched smile and blush (body); a domed,
darker carapace with pale mottles and a stitched rim, and on top, comically tiny, a crown of three cream barnacles with dark mouths
and a pearl in the middle (shell); two button eyes on stalks, lidded and haughty (eyeL / eyeR, sprung); a tiny red claw raised on the
left (clawL) and ONE HUGE red claw on the right, a fat felt mitt with cream knobbly teeth and dark tips held up like a sceptre
(clawR); four plum legs with red toes (leg1..leg4, behind).
Silhouette: lopsided, one giant claw; the knight has plume and blade, the shore crab twin mittens."""
import math, os, sys
from importlib import import_module
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from rigkit import *  # noqa
CK = import_module('_crab_shore-crab')

R = Rig('mangrove-crab-king')
X = CK.mirror(R)
PLUM = ('#c3a0d8', '#8a5aa8', '#653c85', '#3f2458')
DARK = ('#a884c4', '#74489a', '#573478', '#3f2458')
CLAW = ('#f5986a', '#dd3a2a', '#a8241f', '#6e2038')
BARN = ('#ffffff', '#f2e4c0', '#c9b58e', '#8b7a5a')
cx = R.pv('body')[0]

for pid, knee, foot in (('leg1', (14, 36), (4, 52.5)), ('leg2', (25, 40), (16.5, 52.5))):
    for q, k2, f2 in ((pid, knee, foot), ('leg4' if pid == 'leg1' else 'leg3', (X(knee[0]), knee[1]), (X(foot[0]), foot[1]))):
        CK.leg(R, q, k2, f2, PLUM if pid == 'leg1' else darker(PLUM), w=(4.6, 3.8, 1.8), tip=CLAW[2])

p = R.part('body')
p.add(p.m(ell(cx, 38.5, 26, 9.5), ell(cx, 30, 18, 9), ell(cx, 32, 22.5, 6.5)), PLUM)
p.line([(cx - 22, 39), (cx - 12, 41.5), (cx + 12, 41.5), (cx + 22, 39)], PLUM[2])              # the seam under the carapace rim
p.line([(cx - 4, 43), (cx - 2, 44.5), (cx + 2, 44.5), (cx + 4, 43)], INK)                  # smug smile
CK.blush(p, cx - 9, 42.5); CK.blush(p, cx + 9, 42.5)

p = R.part('shell')
dome = inter(ell(cx, 31, 20, 11), lambda x, y: y < 37)
p.add(p.m(dome), DARK)
p.line([(cx - 17, 33), (cx - 8, 35), (cx + 8, 35), (cx + 17, 33)], DARK[3])                # a sewn rim seam
for x, y in ((-11, 29), (8, 26), (12, 32), (-3, 32)):        # pale mottles
    p.add(p.m(ell(cx + x, y, 1.6, 1.1)), (PLUM[0],) * 4, flat=True)
p.add(p.m(rect(cx - 6, 19, cx + 6, 22)), GOLD, local=True, crescent=0)                         # the crown band
for x, h in ((-4, 4), (0, 5.5), (4, 4)):                                                      # three barnacles stand on it
    p.add(p.m(poly([(cx + x - 2.2, 19.5), (cx + x - 1.2, 19.5 - h), (cx + x + 1.2, 19.5 - h), (cx + x + 2.2, 19.5)])), BARN, local=True, crescent=1)
    p.px(cx + x - .5, 19.5 - h, DARK[3]); p.px(cx + x + .5, 19.5 - h, DARK[3])               # each barnacle's little mouth
p.add(p.m(ell(cx, 20.5, 1.3, 1.2)), ('#ffffff', '#fff3c8', '#e4dcf6', '#c3b2ea'), local=True, crescent=0)   # a pearl set in the band

for pid, look in (('eyeL', 1), ('eyeR', 1)):
    e = CK.stalk_eye(R, pid, 12, PLUM, knob=3.8, stalk=2.8, look=look, lean=-1.5 if pid == 'eyeL' else 1.5)
    x = R.pv(pid)[0] + (-1.5 if pid == 'eyeL' else 1.5)
    e.add(e.m(inter(ell(x, 12, 3.8, 3.9), lambda X_, Y: Y < 11)), (PLUM[2],) * 4, flat=True)   # heavy royal lids
    e.line([(x - 3, 11), (x + 3, 11)], INK)

p = R.part('clawL')                                                                            # the tiny claw
a = R.pv('clawL')
p.add(p.m(capsule([a, (22, 28)], 4.6, 3.6), capsule([(22, 28), (19, 22)], 3.6, 3.6)), PLUM, crescent=1)
p.add(p.m(capsule([(16.5, 18), (15, 14.5), (16, 12.5)], 2.8, 1.6), capsule([(21, 18), (22, 14.5), (20.5, 13)], 2.8, 1.6)), CLAW, local=True, crescent=0)
p.add(p.m(ell(19, 20, 3.6, 3.2)), CLAW, local=True)

p = R.part('clawR')                                                                            # the huge claw
a = R.pv('clawR')
p.add(p.m(capsule([a, (76, 31)], 6, 5.6), capsule([(76, 31), (80, 26)], 5.6, 6)), PLUM, crescent=1)
mitt = union(rell(84, 21, 9.5, 7.5, -62), ell(80.5, 26, 5, 4))
fixed = capsule([(88.5, 15), (93.5, 8), (91.5, 2.5)], 6.6, 2.6)
moving = capsule([(80, 15), (75.5, 9), (78.5, 3)], 5.8, 2.4)
p.add(p.m(fixed, moving), CLAW, local=True, crescent=1)
p.add(p.m(mitt), CLAW)
for k in range(3):                                                                             # knobbly cream teeth inside the gape
    p.px(79 + (k > 0), 11 - k * 2.5, BARN[1]); p.px(90 - (k > 0), 11 - k * 2.5, BARN[1])
p.pxs([(91, 2), (90, 2), (79, 2), (80, 2)], CLAW[3])
p.line([(76.5, 17.5), (80.5, 15.5), (85, 15.5), (90, 17)], CLAW[2])                             # where the fingers are sewn on
p.add(p.m(ell(81, 22, 2.4, 1.5)), (CLAW[0],) * 4, flat=True)                                  # a felt sheen on the mitt
p.pxs([(86, 24), (88, 21), (84, 27)], CLAW[3])                                                 # coarse felt bumps

R.save()
