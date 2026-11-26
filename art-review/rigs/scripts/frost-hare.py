#!/usr/bin/env python3
"""frost-hare "Frost Hare" (quad.hare rig, 47 x 49, 8 parts; medium, tundra/mountain, lvl 11; drops Frost Fur, Frost Crystal)
"A white hare with breath like a winter wind."
A crouched hare in white winter felt shaded in cold ice blue: a high round rump, a big round hind haunch over a long flat hind foot
(the hare's foot runs far along the ground), thin front legs, a cotton-ball tail (tail). Pale ice-blue frost-crystal stitches on the
back. Head (head): a round head, a short soft muzzle with a pink nose, two LONG upright ears with pink insides and BLACK TIPS (the far
ear a shade darker, splayed back), a pink cheek. Dark button eye with a cream glint (eyes)."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from rigkit import *  # noqa
import importlib
K = importlib.import_module('_quad_sea-otter-bandit')

R = Rig('frost-hare')
SNOW = ('#ffffff', '#eef2f7', '#c2d0e2', '#8494b4')
FAR = ('#e2e8f0', '#c2d0e2', '#a2b2cc', '#8494b4')
TIP = ('#4a4050', '#3a3040', '#2a1a10', '#2a1a10')
ICE = '#a9d6ea'

# far legs
K.leg(R, 'legBF', 17, FAR, 6, 5, paw=(5.5, 1.8))
K.leg(R, 'legFF', 33, FAR, 3.4, 3, paw=(2.6, 1.6))

# tail: a cotton-ball tail on the rump
p = R.part('tail')
p.add(p.m(ell(7.2, 28.5, 3.4, 3.2)), SNOW)
p.px(6, 27, '#ffffff')

# body: high round rump sloping down to the chest, frost-crystal stitches
p = R.part('body')
torso = union(ell(16.5, 31, 10.5, 9.5), ell(26.5, 33, 7, 7.5), K.tufts([(9, 26), (13, 23), (18, 22), (23, 23.5)], 2.2))
p.add(p.m(torso), SNOW, stitch=SNOW[2])
for cx, cy in ((15, 27), (22, 29)):
    p.pxs([(cx, cy - 1), (cx, cy + 1), (cx - 1, cy), (cx + 1, cy)], ICE); p.px(cx, cy, '#ffffff')

# near legs: a big round haunch over a long flat hind foot; a thin front leg
p, m = K.leg(R, 'legBN', 12, SNOW, 6, 5, paw=(7, 2), haunch=(13, 34.5, 7.2, 6.6), toes=SNOW[3])
p.edge(p.m(inter(ell(13, 34.5, 7.2, 6.6), lambda x, y: y < 38)), SNOW[2], sides=((0, -1), (1, 0)))
p, m = K.leg(R, 'legFN', 28.5, SNOW, 3.6, 3.2, paw=(2.8, 1.7), toes=SNOW[3])

# head: round head, soft muzzle, pink nose, long black-tipped ears
p = R.part('head')
earF = rell(30.8, 12, 2.5, 9, -14)
earN = rell(34.6, 11.5, 2.7, 9.5, 6)
p.add(p.m(earF), FAR, local=True)
p.add(p.m(inter(rell(30.8, 12.5, 1.1, 6.5, -14), lambda x, y: y > 6.5)), (BLUSH,) * 4, flat=True)
p.add(p.m(inter(earF, lambda x, y: y < 6)), TIP, flat=True)
skull = union(ell(34, 24.5, 6.3, 5.5), capsule([R.pv('head'), (33, 25)], 8.5, 9))
p.add(p.m(skull, ell(39, 26.5, 3.6, 3)), SNOW)
p.add(p.m(earN), SNOW, local=True)
p.add(p.m(inter(rell(34.6, 12, 1.2, 7, 6), lambda x, y: y > 5.5)), ('#fde0ea', BLUSH, BLUSH, BLUSH), flat=True)
p.add(p.m(inter(earN, lambda x, y: y < 5)), TIP, flat=True)
p.add(p.m(ell(42, 25, 1.3, 1.1)), ('#e46a9b',) * 4, flat=True)                                    # pink nose
p.line([(41, 27), (40, 28), (38, 28)], SNOW[3])                                                     # mouth
p.add(p.m(ell(37, 27.5, 1.3, .9)), ('#fde0ea',) * 4, flat=True)                                     # cheek
p.edge({q for q in p.m(skull) if q[0] < 31}, SNOW[2], sides=((-1, 0),))

# eyes: dark button eye
p = R.part('eyes')
K.eye_dot(p, 36.6, 22.8, r=1.2)

R.save()
