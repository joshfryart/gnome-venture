#!/usr/bin/env python3
"""grumpy-lemming "Grumpy Lemming" (quad.rodent rig, 51 x 37, 8 parts; medium, tundra, lvl 6; drops Lemming Fluff)
"Small, round, furious."
A round ball of a lemming in orange-ginger felt with a fluffy tufted top line, a stitched seam, a cream belly; tiny stub legs with cream toes peeking out from under the ball. A tiny stub tail (tail; shipped sheet had none).
A big round head (head) with a BLACK CAP over the crown, a small round ear, FAT PUFFED CHEEKS, a pink nose, a downturned grumpy mouth with
two cream buck teeth bared, a heavy scowling brow over the eye and a red anger mark popping on the cap. Small button eye (eyes)."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from rigkit import *  # noqa
import importlib
K = importlib.import_module('_quad_sea-otter-bandit')

R = Rig('grumpy-lemming')
FUR = ('#f6b066', '#e08a3a', '#b8662a', '#7a4a1f')
FAR = darker(FUR)
CAP = ('#5a4a50', '#3e3038', '#2e2228', '#2a1a10')
BELLY = ('#fff3c8', '#f6dcae', '#dcb27c', '#b48a4e')
ANGER = '#dd3a2a'

# far legs: tiny stubs
K.leg(R, 'legBF', 17.5, FAR, 5, 4.5, paw=(3, 1.8))
K.leg(R, 'legFF', 36, FAR, 4.5, 4, paw=(2.6, 1.7))

# tail: a tiny stub poking out behind the ball
p = R.part('tail')
p.add(p.m(ell(7.3, 17.4, 2.5, 2.0)), FUR)

# body: a round furry ball, tufted top, cream belly
p = R.part('body')
ball = union(ell(21.5, 19.5, 13, 10.4), ell(31.5, 23, 6, 5.5), K.tufts([(11.5, 12.5), (16, 10.4), (21, 9.6), (26, 10)], 2.2))
p.add(p.m(ball), FUR, stitch=FUR[3])
p.add(p.m(inter(ball, ell(24, 30, 11, 5))), BELLY, local=True)

# near legs: tiny stubs with cream toes
p, m = K.leg(R, 'legBN', 13, FUR, 5.5, 5, paw=(3.3, 1.9), toes=BELLY[0])
p, m = K.leg(R, 'legFN', 32, FUR, 4.8, 4.2, paw=(2.8, 1.8), toes=BELLY[0])

# head: big round head, black cap over crown and nape, puffed cheeks, scowl, bared teeth, anger mark
p = R.part('head')
skull = union(ell(40, 13.8, 7.8, 7.3), capsule([R.pv('head'), (37, 15)], 9, 10))
cheek = ell(44.6, 17.6, 4.2, 3.6)
p.add(p.m(ell(35, 7.8, 2.2, 2.0)), CAP, local=True)                                                   # ear
p.add(p.m(skull), FUR)
p.add(p.m(cheek, ell(47, 14, 2.3, 2.0)), BELLY, local=True)
p.add(p.m(inter(skull, union(lambda x, y: y < 10.2 + (x - 36) * .1, lambda x, y: x < 34.8 - (y - 10) * .3 and y < 16))), CAP, local=True)
p.add(p.m(ell(48.6, 13.3, 1.3, 1.2)), ('#e46a9b',) * 4, flat=True)                                    # pink nose
p.line([(47, 20.5), (45.5, 20), (44, 20.5)], INK)                                                      # grumpy downturned mouth
p.add(p.m(rect(45, 21, 47, 23.4)), (CREAM, CREAM, CREAM, CREAM), flat=True)                            # buck teeth
p.line([(38.5, 11), (40.5, 11.4), (43.5, 12.4)], INK)                                                # heavy scowling brow
for dx, dy in ((1, 0), (3, 0), (0, 1), (1, 1), (3, 1), (4, 1), (0, 3), (1, 3), (3, 3), (4, 3), (1, 4), (3, 4)):   # anger mark
    p.px(37 + dx, 6 + dy, ANGER)
p.edge({q for q in p.m(skull) if q[0] < 34}, CAP[3], sides=((-1, 0),))

# eyes: small button eye under the scowl
p = R.part('eyes')
K.eye_dot(p, 41.6, 14.6, r=.9)

R.save()
