#!/usr/bin/env python3
"""dune-scorpion "Dune Scorpion" (crab rig, front view, 81 x 57, 10 parts): "Its tail curls like a question you don't want answered."
(medium, lv 10, desert, dusk and night; Scorpion Stinger, Scorpion Plate)
A pale sand-straw felt scorpion squaring up to the gnome: a wide flat plated body with a raised head mound, stitched plate seams, cream
little jaws and a blush (body); two button eyes on short knobs on the mound (eyeL / eyeR, sprung); a tail of round felt beads rising
behind on the left and curling over into a question mark, ending in a fat amber bulb and a dark hooked sting (tail, behind);
big pincer arms out to both sides, bulbous hands raised with open amber-tipped fingers (clawL / clawR); four thin jointed legs splayed
out to the sand, the knees high (leg1..leg4, behind)."""
import math, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from rigkit import *  # noqa

R = Rig('dune-scorpion')
SAND = ('#fdf0c0', '#ecc878', '#c49650', '#8a6030')
AMBER = ('#f5b45a', '#d8803a', '#a8521f', '#6e3418')
STING = ('#8a5a48', '#5a3428', '#3e2218', '#2a1a10')

for pid, knee, foot in (('leg1', (12.5, 37), (3.5, 51)), ('leg2', (21, 40.5), (14.5, 51)), ('leg3', (60, 40.5), (66.5, 51)), ('leg4', (68.5, 37), (77.5, 51))):
    p = R.part(pid)
    a = R.pv(pid)
    p.add(p.m(capsule([a, knee], 3.6, 3), capsule([knee, foot], 3, 2)), darker(SAND) if pid in ('leg2', 'leg3') else SAND, crescent=0)
    p.px(int(knee[0]), int(knee[1]) + 1, SAND[3])                                          # knee joint
    p.px(int(foot[0]), int(foot[1]), AMBER[2])

p = R.part('tail')                                                                          # a question mark of felt beads
beads = [((29.5, 31), 4.6), ((27, 25.5), 4.4), ((25.5, 19.5), 4.2), ((26.5, 13.5), 4), ((30, 8.5), 3.8), ((35.5, 5.5), 3.7), ((41, 6), 3.6)]
p.add(p.m(capsule([b[0] for b in beads], 7, 6)), SAND, crescent=1)
for k, (c, r) in enumerate(beads[1:]):                                                      # beads, warming toward the sting
    p.add(p.m(ell(c[0], c[1], r, r)), SAND if k < 3 else ('#fbe0a0', '#e4b060', '#b87e3e', '#7a5028'), local=True, crescent=1)
p.add(p.m(ell(44.5, 11.5, 4.2, 4.6)), AMBER, local=True)                                    # the venom bulb
p.add(p.m(poly([(42.5, 14), (45, 15.5), (43, 19.5), (40.5, 21.5), (41.5, 17.5)])), STING, local=True, crescent=0)   # the hooked sting
p.px(44, 10, AMBER[0])

p = R.part('body')
mound = poly([(31, 37), (33.5, 29.5), (37, 27.5), (44, 27.5), (47.5, 29.5), (50, 37)])
bd = union(ell(40.5, 40, 20, 6.2), mound, ell(30.5, 35, 3, 2.6), ell(24.5, 35.5, 3.6, 3), ell(56.5, 35.5, 3.6, 3))
p.add(p.m(bd), SAND, stitch=None)
p.add(p.m(inter(bd, lambda x, y: y < 36.5 + abs(x - 40.5) * .12)), ('#e4b868', '#c99650', '#a4733a', '#7a5028'))   # the darker plated back
p.add(p.m(mound), ('#d8a860', '#b8843e', '#8e602c', '#6a4420'), local=True)                # the head plate
for k in (-2, -1, 1, 2):                                                                    # plate seams, receding behind
    x = 40.5 + k * 7.5
    p.line([(x, 34.5), (x + k * .4, 37.5)], SAND[3])
p.line([(31.5, 36.5), (36, 38.5), (45, 38.5), (49.5, 36.5)], SAND[3])                       # the plate rim over the face
p.line([(40, 29), (40, 35)], ('#8e602c'))                                                   # the groove down the head plate
p.add(p.m(union(ell(38.5, 42.5, 1.8, 1.8), ell(42.5, 42.5, 1.8, 1.8))), AMBER, local=True, crescent=0)   # little jaws
p.px(39, 43, AMBER[3]); p.px(42, 43, AMBER[3])
p.add(p.m(ell(33.5, 41, 1.6, 1)), (BLUSH,) * 4, flat=True)
p.add(p.m(ell(47.5, 41, 1.6, 1)), (BLUSH,) * 4, flat=True)
p.add(p.m(inter(bd, lambda x, y: y >= 45)), (SAND[2], SAND[2], SAND[3], SAND[3]), flat=True)

for pid in ('eyeL', 'eyeR'):
    p = R.part(pid)
    x, y = R.pv(pid)
    p.add(p.m(ell(x, y - 2.5, 3.6, 3.8)), ('#d8a860', '#b8843e', '#8e602c', '#6a4420'))     # a low knob on the head plate
    p.eye(x - .5 + (1 if pid == 'eyeR' else 0), y - 3, size=2, look=0)
    p.line([(x - 2.5, y - 6.5 + (1 if pid == 'eyeL' else 0)), (x + 2, y - 6.5 + (1 if pid == 'eyeR' else 0))], INK)   # a frowning brow

for pid, s in (('clawL', -1), ('clawR', 1)):
    p = R.part(pid)
    a = R.pv(pid)
    X = lambda dx: a[0] + s * dx
    elbow, wrist = (X(10), 33.5), (X(13), 27)
    p.add(p.m(capsule([a, elbow], 4.4, 3.6), capsule([elbow, wrist], 3.6, 3.8)), SAND, crescent=1)
    p.px(int(elbow[0]), int(elbow[1]), SAND[3])
    hand = union(rell(X(13.5), 21.5, 4.4, 6, s * -8), ell(X(13.2), 24, 4.6, 3.6))
    fingers = union(capsule([(X(11.5), 17), (X(9.5), 12), (X(10.5), 7.5)], 3.2, 1.8), capsule([(X(15.5), 17), (X(17.5), 12.5), (X(16), 9)], 3, 1.8))
    p.add(p.m(fingers), AMBER, local=True, crescent=0)
    p.add(p.m(hand), SAND, local=True)
    p.add(p.m(inter(hand, lambda x, y: y < 18)), AMBER, flat=True)
    p.pxs([(int(X(10.5)), 8), (int(X(16)), 10)], STING[1])                                    # dark finger tips
    p.line([(X(12), 20), (X(12.5), 24)], SAND[2])

R.save()
