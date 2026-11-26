#!/usr/bin/env python3
"""coconut-crab-titan "Coconut Crab Titan" (crab rig, front view, 129 x 75, 10 parts, boss lv 26, island): "Cracks coconuts like eggs.
Cracks gnomes like coconuts." (Titan Claw, Coconut Husk)
A huge rust-red felt robber crab, squat and heavy: a broad rust body with hairy cream-tipped mouth mitts and a grim stitched frown (body);
a wide domed carapace with the robber crab's dark H groove, lilac-blue mottles on the flanks and a sewn rim, and wedged on top a
cracked half coconut worn like a helmet, brown coir felt with fibre stitches and a cream flesh rim (shell); two tall eye stalks with
grumpy lidded button eyes and long whip antennae (eyeL / eyeR, sprung); two ENORMOUS lopsided claws raised high, the left the bigger,
fat mitts with lilac-blue knuckles, knobbly cream teeth and dark tips (clawL / clawR); four thick bristly legs with lilac knee bands and
dark claws (leg1..leg4, behind).
Silhouette: very wide and low, two giant raised mitts, a coconut dome in the middle; the batch's octopus is a tall bulb, the eels long."""
import math, os, sys
from importlib import import_module
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from rigkit import *  # noqa
CK = import_module('_crab_shore-crab')

R = Rig('coconut-crab-titan')
X = lambda x: 129 - x
RUST = ('#f29a62', '#d0583a', '#a03a28', '#66231c')
FAR = ('#d0583a', '#a8432c', '#80301f', '#66231c')
BLUE = ('#b68aa8', '#8f6890', '#6a4a74', '#43304f')
HUSK = ('#b98552', '#8a5a30', '#66401f', '#3e2612')
TOOTH = ('#ffffff', '#fff3c8', '#e3cf9e', '#a88a5a')
cx = R.pv('body')[0]

# legs: thick, bristly, a lilac knee band, dark claw toes
for pid, knee, foot, ramp in (('leg1', (17, 45), (5.5, 69), RUST), ('leg2', (31, 50), (22.5, 69), FAR)):
    for q, k2, f2 in ((pid, knee, foot), ('leg4' if pid == 'leg1' else 'leg3', (X(knee[0]), knee[1]), (X(foot[0]), foot[1]))):
        p = CK.leg(R, q, k2, f2, ramp, w=(9.5, 7.5, 3), tip=INK)
        p.add(p.m(inter(capsule([R.pv(q), k2, f2], 9.5, 3), ell(k2[0], k2[1], 2.6, 2.6))), BLUE, local=True, crescent=1)
        s = 1 if k2[0] < cx else -1
        for t in (.3, .55, .8):                                                           # bristles on the outer shin
            bx, by = k2[0] + (f2[0] - k2[0]) * t, k2[1] + (f2[1] - k2[1]) * t
            p.px(bx - s * 2, by - 1, ramp[3])

# body: broad rust underside with hairy mouth mitts and a frown
p = R.part('body')
p.add(p.m(ell(cx, 46, 31, 11.5), ell(cx, 37, 22, 10), ell(cx - 25, 40, 6, 5), ell(cx + 25, 40, 6, 5)), RUST)
for sx in (-1, 1):                                                                         # the hairy mouth mitts
    m = rell(cx + sx * 5.5, 51.5, 4.2, 5.2, sx * 12)
    p.add(p.m(m), BLUE, local=True)
    for k in range(3):
        p.px(cx + sx * (3.5 + k * 2), 56 - (k == 1), TOOTH[1])                              # cream hair tufts at their tips
p.line([(cx - 6, 45), (cx - 3, 43.5), (cx + 3, 43.5), (cx + 6, 45)], INK)                    # grim frown
p.add(p.m(ell(cx - 15, 49, 2.6, 1.3), ell(cx + 15, 49, 2.6, 1.3)), (RUST[0],) * 4, flat=True)  # lilac felt patches

# shell: the domed carapace with the H groove, and the half coconut helmet
p = R.part('shell')
dome = inter(ell(cx, 37.5, 27, 15), lambda x, y: y < 46)
p.add(p.m(dome), RUST, stitch=RUST[3])
for sx in (-1, 1):
    p.add(p.m(inter(dome, ell(cx + sx * 21, 41, 6, 4))), BLUE, local=True)               # lilac-blue flank mottles
    p.line([(cx + sx * 4, 29), (cx + sx * 5, 35), (cx + sx * 4, 43)], RUST[3])               # the H groove
    p.px(cx + sx * 12, 33, RUST[0]); p.px(cx + sx * 9, 38, RUST[0]); p.px(cx + sx * 15, 30, RUST[0])
p.line([(cx - 4, 35), (cx + 4, 35)], RUST[3])
p.line([(cx - 25, 43), (cx - 12, 45), (cx + 12, 45), (cx + 25, 43)], RUST[3])                 # the rim seam
nut = inter(ell(cx, 25, 11, 12), lambda x, y: y < 26)
p.add(p.m(nut), HUSK, stitch=HUSK[3])
p.add(p.m(rect(cx - 11, 24, cx + 11, 27.5)), ('#fffbe8', '#fff3c8', '#e3cf9e', '#a88a5a'), local=True, crescent=1)   # cream flesh rim
for k, x in enumerate((-6, -2, 2, 6)):                                                       # coir fibre stitches
    p.line([(cx + x, 15 + abs(x) * .5), (cx + x * 1.15, 22)], HUSK[3] if k % 2 else HUSK[0])
p.pxs([(cx - 2, 15), (cx + 1, 15), (cx - 1, 14)], HUSK[3])                                  # the three coconut eyes
p.pxs([(cx + 4, 20), (cx + 5, 21), (cx + 4, 22), (cx + 6, 22)], INK)                         # a crack

# eyes on tall stalks, grumpy lids, long whip antennae
for pid, s in (('eyeL', -1), ('eyeR', 1)):
    e = CK.stalk_eye(R, pid, 12, RUST, knob=4.4, stalk=3.4, look=1, lean=s * 1.5)
    x = R.pv(pid)[0] + s * 1.5
    e.add(e.m(inter(ell(x, 12, 4.4, 4.5), lambda X_, Y: Y < 10.5)), (RUST[2],) * 4, flat=True)
    e.line([(x - 4, 10 + (s < 0)), (x + 4, 10 + (s > 0))], INK)
    e.add(e.m(capsule([(x + s * 2, 17), (x + s * 6, 10), (x + s * 7, 4)], 1.4, 1)), RUST, local=True, flat=True)

# claws: huge felt mitts raised high, the left one bigger
for pid, big in (('clawL', 1.0), ('clawR', .85)):
    p = R.part(pid)
    f = (lambda x: x) if pid == 'clawL' else X
    a = R.pv(pid)
    d = (1 - big) * 22                                                                         # the small claw sits lower
    hand = rell(f(21), 24 + d * .3, 10.5 * big, 9 * big, -60 if pid == 'clawL' else 60)
    fixed = capsule([(f(15), 19 + d * .5), (f(10.5), 10 + d * .7), (f(12.5), 3 + d * .8)], 9 * big, 3)
    moving = capsule([(f(26), 18 + d * .5), (f(28.5), 11 + d * .7), (f(25), 5 + d * .8)], 7.5 * big, 2.6)
    p.add(p.m(capsule([a, (f(29), 33)], 12, 11)), RUST, crescent=1)
    p.add(p.m(fixed, moving), RUST, local=True, crescent=1)
    p.add(p.m(hand), RUST, stitch=RUST[3])
    p.add(p.m(inter(hand, ell(f(23), 30 + d * .3, 6 * big, 3.5 * big))), BLUE, local=True, crescent=1)   # lilac-blue underside
    for k in range(3):                                                                           # knobbly cream teeth in the gape
        y = 15 + d * .55 - k * 3
        p.px(f(15 + k * .3), y, TOOTH[1]); p.px(f(24.5 - k * .3), y + 1, TOOTH[1])
    p.pxs([(f(12), 3 + d * .8), (f(13), 3 + d * .8), (f(12), 4 + d * .8), (f(25), 5 + d * .8), (f(24), 5 + d * .8)], INK)   # dark tips
    p.add(p.m(ell(f(17), 21 + d * .3, 2.6, 1.6)), (RUST[0],) * 4, flat=True)                   # felt sheen
    p.pxs([(f(25), 24 + d * .3), (f(22), 27 + d * .3), (f(27), 20 + d * .3)], RUST[3])         # coarse felt bumps

R.save()
