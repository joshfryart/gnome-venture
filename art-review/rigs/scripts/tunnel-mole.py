#!/usr/bin/env python3
"""tunnel-mole "Tunnel Mole" (quad.bear rig, 77 x 32, 8 parts; level 9, grassland / forest; drops Velvet Pelt, Digging Claw):
"Bursts up through the soil like a furry earthquake."
A plump charcoal velvet mole fresh out of its tunnel: a low torpedo body with a soft sheen along the back, a few clods of brown
garden soil still sitting on it, and a stitched seam down the flank; tiny pink hind feet (legBN/legBF) and huge pink spade
hands turned palm-out with long cream digging claws (legFN/legFF); a little pink tail stub (tail); a cone-shaped head that runs
into a long fleshy pink nose with nostrils and whisker dots (head); a tiny squinting bead eye half buried in the velvet (eyes)."""
import os, sys, importlib
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from rigkit import *  # noqa
K = importlib.import_module('_quad_barn-rat')

R = Rig('tunnel-mole')
VEL = ('#8e88a4', '#625c78', '#47425c', '#2f2c40')
FAR = darker(VEL)
PINK = PETAL
DIRT = WOOD
g = R.ground + 1.0

def hind(pid, x, ramp, pink):
    p = R.part(pid)
    px_, py_ = R.pv(pid)
    p.add(p.m(capsule([(px_, py_ - 2), (x, g - 2.5)], 5, 4.5)), ramp)
    p.add(p.m(inter(ell(x + 1.5, g - 1.5, 3.6, 1.6), lambda x_, y: y < g)), pink, local=True, crescent=1)
    return p

def spade(pid, x, ramp, pink, claw):
    """a short velvet arm and a huge pink spade hand turned palm-out, claws forward"""
    p = R.part(pid)
    px_, py_ = R.pv(pid)
    p.add(p.m(capsule([(px_, py_ - 2.5), (x, g - 3)], 6, 5)), ramp)
    hand = inter(ell(x + 2.5, g - 3.6, 4.2, 3.6), lambda x_, y: y < g)
    hm = p.add(p.m(hand), pink, local=True)
    for cx, cy, dy in ((x + 5.5, g - 6, -.8), (x + 6.5, g - 3.8, 0), (x + 6.5, g - 1.5, .3)):
        p.add(p.m(inter(capsule([(cx - 1, cy), (cx + 3, cy + dy)], 1.7, 1.0), lambda x_, y: y < g)), claw, flat=True)
    for dy in (-2, 0):
        p.line([(x + 1, g - 3.5 + dy), (x + 4, g - 3.5 + dy * .6)], pink[2])     # finger seams on the palm
    return p

# far legs
hind('legBF', 28, FAR, darker(PINK))
spade('legFF', 51, FAR, darker(PINK), (PAPER[2],) * 4)

# tail: a little pink stub
p = R.part('tail')
p.add(p.m(capsule([(22.5, 13), (17.5, 10.5)], 3.6, 2.4)), PINK, local=True)

# body: low velvet torpedo, a sheen along the back, soil clods on top, a flank seam
p = R.part('body')
torso = union(ell(35.5, 14, 16.5, 11), ell(46, 15.5, 8, 7.5))
torso = inter(torso, lambda x, y: y < 24.5)
p.add(p.m(torso), VEL, stitch=VEL[3])
p.add(p.m(inter(rell(34, 7.8, 11, 2.2, 4), torso)), (VEL[0], VEL[0], VEL[1], VEL[1]), flat=True)   # velvet sheen
for cx, cy, rx in ((29, 4.2, 2.6), (35, 3.4, 2.2), (39.5, 4.6, 1.8), (32, 3.8, 1.4)):
    p.add(p.m(ell(cx, cy, rx, rx * .8)), DIRT, local=True, crescent=1)             # clods of garden soil
for x, y in ((26, 13), (32, 12), (38, 13), (29, 17), (35, 17.5), (42, 17)):
    p.px(x, y, VEL[2])                                                              # velvet nap

# near legs
hind('legBN', 23.5, VEL, PINK)
spade('legFN', 47, VEL, PINK, (CREAM, CREAM, PAPER[2], PAPER[3]))

# head: velvet cone into a long fleshy pink nose
p = R.part('head')
cone = union(ell(50.5, 14, 6.5, 7.5), poly([(48, 6.8), (57, 8.5), (64.5, 12), (64.5, 16.5), (57, 20), (48, 21.5)]))
p.add(p.m(cone), VEL)
nose = union(capsule([(63, 14.2), (72, 14.6)], 5, 3.8), ell(72.5, 14.6, 2.2, 2.5))
p.add(p.m(nose), PINK)
p.edge(p.m(inter(nose, lambda x, y: x < 64.5)), PINK[2], sides=((-1, 0),))
p.px(73, 14, PINK[3]); p.px(73, 15, PINK[3])                                         # nostrils
for x, y in ((61, 16), (62, 17), (60, 17.5), (59, 16.5)):
    p.px(x, y, VEL[3])                                                              # whisker dots
p.line([(63, 17), (68, 17.2)], PINK[3])                                             # mouth under the nose
p.add(p.m(ell(56.5, 11, 2.8, 2.1)), (VEL[0],) * 4, flat=True)                    # the eye's velvet hollow

p = R.part('eyes')
p.add(p.m(ell(56.5, 11, 1.6, 1.2)), (INK,) * 4, flat=True)
p.px(56, 10, CREAM)

R.save()
