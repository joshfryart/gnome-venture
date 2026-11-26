#!/usr/bin/env python3
"""old-pinch "Old Pinch" (crab rig, front view, boss, 129 x 75, 10 parts): the Chapter II-b boss of the Sour Cistern.
"A huge crab of the old cistern, caked head to claw in clay. She grabbed whatever came too close, and held on. Cranky, but not
wicked." Wide as a cart, she thinks the whole cistern is hers; she grabs with her big claw; the clay cracks off when she is beaten;
she kept the Cistern Pearl for a very long time.
An old rust-red felt crab under a crust of grey cistern clay: a wide flat body with a grumpy frown, sewn mouth plates and green
sour-water drips (body); a low domed carapace mostly caked in cracked grey clay, the old rust shell showing at the rim, the cloudy
Cistern Pearl pressed into the clay on top (shell); two eyes on clay-caked stalks with heavy cross brows (eyeL / eyeR, sprung); a
fair-sized left claw and one great grabbing right claw, a clay-crusted mitt with rust fingertips held open (clawL / clawR); four
rust legs with clay cuffs (leg1..leg4, behind).
Silhouette: very wide and flat, clay lumps and a pearl on the back, one big open claw (the mangrove king has a crown and a tiny claw)."""
import os, sys
from importlib import import_module
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from rigkit import *  # noqa
CK = import_module('_crab_shore-crab')

R = Rig('old-pinch')
X = CK.mirror(R)
RUST = ('#ec9e7c', '#c4644a', '#924434', '#5e2a2a')
CLAY = ('#e4e0d8', '#b4aea4', '#8a847a', '#5e5850')
SOUR = '#8fae4a'
PEARL = ('#ffffff', '#eef0dc', '#c9cfb2', '#8f9a7a')
cx = R.pv('body')[0]                                       # 64.5

for pid, knee, foot in (('leg1', (20, 43), (5, 68.5)), ('leg2', (33, 49), (21, 69))):
    for q, k2, f2 in ((pid, knee, foot), ('leg4' if pid == 'leg1' else 'leg3', (X(knee[0]), knee[1]), (X(foot[0]), foot[1]))):
        CK.leg(R, q, k2, f2, RUST if pid == 'leg1' else darker(RUST), w=(8, 6.4, 3), bands=CLAY[2], tip=RUST[3])

p = R.part('body')
p.add(p.m(ell(cx, 48, 42, 13.5), ell(cx, 54, 29, 9), ell(cx, 38, 17, 8.5)), RUST)
p.line([(cx - 36, 50), (cx - 18, 54), (cx + 18, 54), (cx + 36, 50)], RUST[2])          # the seam under the carapace rim
p.line([(cx - 7, 59), (cx - 4, 57), (cx + 4, 57), (cx + 7, 59)], INK)                  # a cranky frown
p.line([(cx - 3, 60.5), (cx + 3, 60.5)], RUST[2])                                       # and a pouting lip under it
for x, y, d in ((cx - 22, 55, 3), (cx + 25, 54, 4), (cx + 12, 57, 2)):                 # green sour-water drips
    p.add(p.m(capsule([(x, y), (x, y + d)], 1.8, 1.4)), (SOUR,) * 4, flat=True)

p = R.part('shell')
dome = inter(ell(cx, 42, 31, 13), lambda x, y: y < 50)
p.add(p.m(dome), RUST, stitch=RUST[3])
crust = inter(dome, union(ell(cx - 12, 37, 15, 8), ell(cx + 13, 38, 13, 7.5), ell(cx, 31, 9, 4), ell(cx - 18, 44, 8, 4), ell(cx + 16, 45, 9, 3.6)))
p.add(p.m(crust), CLAY, local=True)
for x, y, r in ((cx - 20, 33, 3.2), (cx + 21, 34, 2.8), (cx - 9, 31, 2.4)):            # clay lumps on the back
    p.add(p.m(ell(x, y, r, r * .8)), CLAY, local=True, crescent=1)
for pts in (((cx - 14, 38), (cx - 10, 41), (cx - 12, 45)), ((cx - 10, 41), (cx - 5, 40)), ((cx + 8, 37), (cx + 12, 40), (cx + 18, 40)), ((cx + 12, 40), (cx + 11, 45))):
    p.line(list(pts), CLAY[3])                                                           # cracks in the crust
p.add(p.m(ell(cx + 1, 30.5, 5, 4.6)), PEARL, local=True)                                  # the Cistern Pearl, pressed in the clay
p.add(p.m(ell(cx + 2.5, 32, 1.8, 1.2)), ('#f6e0e8',) * 4, flat=True)   # a soft pink sheen
p.pxs([(cx - 1, 28), (cx, 28)], '#ffffff')
p.add(p.m(ell(cx - 26, 44.5, 1.8, 1.2), ell(cx + 27, 43, 1.4, 1)), (SOUR,) * 4, flat=True)

for pid in ('eyeL', 'eyeR'):
    lean = -2 if pid == 'eyeL' else 2
    e = CK.stalk_eye(R, pid, 12, RUST, knob=5.2, stalk=4, look=1, lean=lean)
    x = R.pv(pid)[0] + lean
    e.add(e.m(inter(capsule([(R.pv(pid)[0], 29), (x, 19)], 4.6), lambda X_, Y: Y > 21)), CLAY, local=True, crescent=1)   # clay up the stalk
    inward = 1 if pid == 'eyeL' else -1
    lid = lambda X_, Y, x=x, i=inward: Y < 10.2 + (X_ - x) * .35 * i
    e.add(e.m(inter(ell(x, 12, 5.2, 5.3), lid)), (RUST[2],) * 4, flat=True)                  # heavy cross lid, sloping in
    e.line([(x - 5, 10.2 - 5 * .35 * inward), (x + 5, 10.2 + 5 * .35 * inward)], INK)

p = R.part('clawL')                                                                      # the fair-sized left claw
a = R.pv('clawL')
p.add(p.m(capsule([a, (28, 33)], 9, 8), capsule([(28, 33), (24, 25)], 8, 8.5)), RUST, crescent=1)
p.add(p.m(capsule([(16.5, 18), (13.5, 11), (15.5, 6.5)], 6, 2.6), capsule([(27.5, 17), (29, 10), (26.5, 6)], 6, 2.6)), RUST, local=True, crescent=1)
ml = p.add(p.m(ell(22, 20, 8, 7)), RUST, local=True)
p.add(p.m(inter(ell(22, 20, 8, 7), union(ell(19, 23, 6, 4.5), ell(25, 17, 3, 2.5)))), CLAY, local=True)
p.line([(18, 23), (21, 20), (25, 21)], CLAY[3])

p = R.part('clawR')                                                                      # the great grabbing claw
a = R.pv('clawR')
p.add(p.m(capsule([a, (100, 31)], 11, 10), capsule([(100, 31), (105, 25)], 10, 10)), RUST, crescent=1)
fixed = capsule([(116, 15), (122, 7), (119.5, 3)], 9, 3.4)
moving = capsule([(101, 14), (96.5, 7.5), (99.5, 3)], 8, 3.2)
p.add(p.m(fixed, moving), RUST, local=True, crescent=1)
mitt = union(ell(109, 19, 12.5, 9.5), ell(105, 25, 7.5, 5.5))
p.add(p.m(mitt), RUST)
p.add(p.m(inter(mitt, union(ell(106, 23, 9, 6), ell(115, 15, 4, 3)))), CLAY, local=True)   # the clay cake on the mitt
for k in range(3):                                                                       # knobbly teeth inside the gape
    p.px(100 + (k > 0), 10 - k * 2.5, CLAY[0]); p.px(119 - (k > 0), 10 - k * 2.5, CLAY[0])
p.line([(98, 15.5), (103, 13), (110, 12.5), (117, 14.5)], CLAY[3])                     # where the fingers leave the clay
for pts in (((104, 18), (108, 21), (106, 25)), ((112, 16), (115, 20))):
    p.line(list(pts), CLAY[3])
p.add(p.m(ell(113, 24, 1.4, 2.2)), (SOUR,) * 4, flat=True)

R.save()
