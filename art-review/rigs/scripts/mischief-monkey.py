#!/usr/bin/env python3
"""mischief-monkey "Mischief Monkey" (quad.rodent rig, 77 x 53, 8 parts; level 14, rainforest; drops Stolen Trinket):
"Steals your hat, then your seeds, then your dignity."
A cinnamon-brown felt monkey loping on all fours: a compact round body, higher at the shoulders, with a tan chest; long thin
arms with cream hands (legFN/legFF) and bent hind legs with long cream feet (legBN/legBF); a long thin tail that rises behind
and rolls into a curl at the tip (tail, the rodent spring). A round head with a big cup ear, a cream heart-shaped face and
a cheeky muzzle with a wide grin, and a stolen red gnome hat jammed on askew, its tip flopping back (head). Two bright eyes in
the face mask, 3/4 view (eyes)."""
import os, sys, importlib
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from rigkit import *  # noqa
K = importlib.import_module('_quad_barn-rat')

R = Rig('mischief-monkey')
FUR = ('#cf9660', '#a86b38', '#7a4a24', '#4f2e16')
FAR = darker(FUR)
FACE = ('#fff0d6', '#f6d6a8', '#dcae7c', '#b07e50')
HAT = ('#f08a4a', '#dd3a2a', '#a8241f', '#6e2038')
g = R.ground + 1.0

def hand(p, cx, rx, ramp):
    p.add(p.m(inter(ell(cx, g - 1.6, rx, 1.8), lambda x, y: y < g)), ramp, local=True, crescent=1)

# far limbs, one step darker
p, _ = K.limb(R, 'legBF', [(30, 32), (34, 39.5), (31.5, 45.5)], 5, 3.4, FAR)
hand(p, 34, 3.6, darker(FACE))
p, _ = K.limb(R, 'legFF', [(49.7, 32), (51, 46)], 4.2, 3.4, FAR)
hand(p, 52.5, 2.8, darker(FACE))

# tail: long and thin, rising behind and rolling into a curl
p = R.part('tail')
tail = capsule([(23, 25.5), (17, 24.5), (11.5, 21), (8.5, 15), (8.5, 9), (12, 5.5), (16, 6.5), (16.5, 10), (13.5, 11.5), (12, 9.5)], 3.6, 2.4)
p.add(p.m(tail), FUR)
p.line([(14, 23), (10, 18)], FUR[2])

# body: compact and round, a little higher at the shoulders; tan chest
p = R.part('body')
torso = union(rell(35, 27.5, 14.5, 9, -10), ell(44, 26, 7.5, 8.5), ell(47.5, 31, 4.5, 5.5))
p.add(p.m(torso), FUR, stitch=FUR[3])
p.add(p.m(inter(torso, ell(43, 33, 9, 5))), FACE, local=True)
for x, y in ((25, 22), (30, 20), (36, 19.5), (28, 26), (34, 25), (40, 23.5)):      # felt fur ticks
    p.line([(x, y), (x + 1, y + 1)], FUR[2])

# near limbs: bent hind leg with a long foot; long straight arm with a cream hand
p, _ = K.limb(R, 'legBN', [(24.6, 32), (29, 39.5), (26, 45.5)], 6, 3.8, FUR)
hand(p, 29.5, 4.4, FACE)
p.line([(22, 33), (25, 38)], FUR[2])
K.toes(p, (31, 33), int(g - 2), FACE[3])
p, _ = K.limb(R, 'legFN', [(44.6, 31), (46, 46)], 4.8, 3.8, FUR)
hand(p, 47.5, 3.2, FACE)
K.toes(p, (49,), int(g - 2), FACE[3])

# head: round cranium, cup ear, cream heart face and grinning muzzle, a stolen red gnome hat
p = R.part('head')
hat = poly([(48, 12.5), (49, 7), (45, 3), (41, 2.2), (45, 4.8), (50, 3.5), (56, 5), (60.5, 10.5), (54, 12)])
hatm = p.m(hat)
p.add(hatm, HAT, stitch=False)
p.add(p.m(ell(40.8, 2.8, 1.6, 1.4)), GOLD, local=True, crescent=1)                # the bobble on the hat tip
skull = union(ell(54, 17.5, 8, 7.5), capsule([R.pv('head'), (51, 20)], 9, 9))
p.add(p.m(skull), FUR)
ear = ell(46.2, 17.5, 3.4, 3.9)
em = p.add(p.m(ear), FUR, local=True)
p.add(p.m(ell(46.6, 17.8, 1.8, 2.3)), FACE, local=True, crescent=1)
p.edge(em, FUR[3])
face = union(ell(56.3, 15.8, 3.2, 3.5), ell(60.6, 15.8, 3.2, 3.5), ell(60, 21, 4.8, 3.9))
p.add(p.m(face), FACE, local=True)
p.add(p.m(inter(rect(47, 9, 62, 12), union(skull, hat))), (GOLD[0], GOLD[1], GOLD[2], GOLD[3]), local=True, crescent=1)   # hat band
p.line([(58, 22.5), (60, 23.5), (62, 23.5), (64, 22)], INK)                                       # grin
p.px(64, 19, FACE[3]); p.px(65, 19, FACE[3])                                        # nostrils
p.add(p.m(ell(56.5, 21.5, 1.3, 1)), (BLUSH,) * 4, flat=True)                        # felt cheek
for x, y in ((50, 6), (54, 7), (57, 9)):
    p.px(x, y, HAT[3])                                                              # hat stitch dots

p = R.part('eyes')
for x in (56.5, 61):
    p.add(p.m(ell(x, 16.5, 1.4, 1.8)), (INK,) * 4, flat=True)
    p.px(x - 1, 15, CREAM)

R.save()
