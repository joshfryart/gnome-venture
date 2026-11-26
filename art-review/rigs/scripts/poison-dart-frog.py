#!/usr/bin/env python3
"""poison-dart-frog "Poison Dart Frog" (frog rig, 55 x 40, 5 parts, front view): "Jewel-bright and very sure of itself. Admire it from two
gnome-lengths away." (medium; rainforest, wetland; rain; Frog Skin, Morpho Scales, Fiddleheads)
A small, proud felt dart frog sitting UP on straight front legs, so its silhouette is a tall pear, not the squat toad loaf of its batch
siblings: glossy cobalt-blue body sewn with ink-black spots, a short smug smile, slim straight arms ending in round sticky toe discs
(body, squashes from the ground); thin folded hind legs in deeper blue with black speckles and long splayed toes with disc pads,
sticking out at both sides (footL / footR); and two big glossy all-black dart-frog eyes on blue domes, each with a bright glint
(eyeL / eyeR, they squash down onto their pivots)."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from rigkit import *  # noqa

R = Rig('poison-dart-frog')
BLUE = ('#8fd0ff', '#2a7fe8', '#1a56c4', '#123a8c')        # glossy jewel cobalt
LEG = ('#4f9cf0', '#1a56c4', '#123a8c', '#0c2662')         # deeper blue for limbs
SPOT = '#000000'                                            # ink-black spots (pure black allowed, RULINGS 1)
CX = 28

def toes(x, y, dirs, w=1.2):
    """long thin toes from (x, y) with a round sticky disc at each tip"""
    out = []
    for dx, dy in dirs:
        out += [capsule([(x, y), (x + dx, y + dy)], w), ell(x + dx, y + dy, 1.3, 1.1)]
    return union(*out)

def spot(p, x, y, r, rot=0):
    """an irregular sewn-on black spot: two overlapping ovals"""
    p.add(p.m(rell(x, y, r * 1.15, r * .8, rot), ell(x + r * .5, y + r * .35, r * .7, r * .65)), (SPOT,) * 4, flat=True)

for pid in ('footL', 'footR'):                                  # folded hind legs at the sides, long splayed toes
    p = R.part(pid)
    x, y = R.pv(pid)
    s = -1 if pid == 'footL' else 1
    foot = toes(x + s * 1, 33.6, ((s * 6.5, 1.2), (s * 6.5, -1.8), (s * 4, -4.2), (-s * 1.5, 1.4)))
    p.add(p.m(foot), LEG, local=True, crescent=0)
    thigh = rell(x - s * 1.2, 28.0, 6.0, 3.2, -s * 35)
    shin = capsule([(x + s * 3.5, 26.5), (x + s * 1.0, 33.2)], 2.4, 2.0)
    p.add(p.m(thigh, shin), LEG)
    p.pxs([(x - s * 3, 27), (x + s * 0, 29), (x - s * 1, 26), (x + s * 3, 30)], SPOT)    # black speckles

p = R.part('body')
# tall pear: narrow head and shoulders, round full haunches, sitting up
head = ell(CX, 15.5, 9.6, 6.6)
torso = poly([(CX - 7.5, 17), (CX + 7.5, 17), (CX + 12, 30), (CX - 12, 30)])
haunch = ell(CX, 29.5, 12.2, 6.0)
bod = union(head, torso, haunch, rect(CX - 9, 31, CX + 9, 35.4))
p.add(p.m(bod), BLUE, stitch=None)
for (x, y, r, rot) in ((28.3, 12.2, 1.3, 20), (20.6, 14.6, .8, -30), (17.6, 25.0, 1.4, 40), (38.6, 24.6, 1.3, -20),
                       (28.2, 24.2, 1.6, 15), (31.0, 29.6, 1.0, 60), (25.0, 30.0, 1.0, -45), (16.6, 31.0, 1.0, 0),
                       (39.6, 30.8, 1.1, 30), (30.6, 20.6, .8, 0), (25.6, 21.2, .7, 0)):
    spot(p, x, y, r, rot)
# glossy highlight on the crown and the belly curve
p.pxs([(23, 11), (24, 10), (25, 10), (19, 22), (19, 23)], BLUE[0])
# slim straight front legs: shoulder to ground, round sticky toe discs; seam-outlined so they read on the body
ARM = ('#c4e8ff', '#5eaaf6', '#3a86e6', '#123a8c')          # arms catch the light: a paler blue in front of the body
for hx in (21.5, 34.5):
    s2 = -1 if hx < CX else 1
    fx = hx + s2 * 1.2
    arm = capsule([(hx, 21.5), (fx, 33.2)], 4.0, 3.4)
    am = p.add(p.m(arm), ARM, local=True, crescent=1)
    p.edge(am, LEG[3], sides=((-s2, 0),))                                                  # seam on the body side
    disc = union(*(ell(fx + dx, 34.5 + dy, 1.6, 1.2) for dx, dy in ((-3.0, 0), (3.0, 0), (0, .5))))
    dm = p.add(p.m(disc, minus=(arm,)), ARM, flat=True)
    p.edge(dm, LEG[3], sides=((0, 1),))
    p.pxs([(int(hx), 25), (int(hx) + 1, 25), (int(fx) - s2, 29)], SPOT)                  # spots carry onto the arm
# smug smile: a clear grin, the right corner (facing side) curled up higher
mouth = [(22, 17.2), (23, 18.2), (25, 19.0), (28, 19.3), (31, 19.0), (33, 18.2), (34.5, 16.8), (35.5, 15.6)]
p.line(mouth, INK)
p.px(21, 17, INK)
p.px(36, 15, INK)
p.pxs([(26, 15), (30, 15)], BLUE[3])                                                      # nostrils
p.pxs([(33, 16), (34, 15)], BLUSH)                                                        # cheek over the curled corner

for pid in ('eyeL', 'eyeR'):
    p = R.part(pid)
    x, y = R.pv(pid)
    p.add(p.m(ell(x, y - 4.8, 6.0, 5.8)), BLUE)                                             # blue dome
    p.add(p.m(ell(x + .3, y - 5.0, 4.6, 4.6)), (SPOT,) * 4, flat=True)                     # big glossy all-black eye
    p.add(p.m(ell(x - 1.2, y - 6.6, 1.4, 1.3)), ('#ffffff',) * 4, flat=True)              # glint
    p.px(int(x + 2), int(y - 3), '#9aa8c0')                                                 # small second glint
    p.line([(x - 2.5, y - 10.2), (x + 2.5, y - 10.2)], BLUE[0])                            # dome gloss

R.save()
