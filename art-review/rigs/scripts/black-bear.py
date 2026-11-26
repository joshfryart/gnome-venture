#!/usr/bin/env python3
"""black-bear "Black Bear" (quad.bear rig, 91 x 48, 8 parts; large; drops Badger Pelt, Leaf Mould Clump; attack: slam)
A big woodland black bear in soft charcoal-plum felt (lightened dark felt, so it reads on the dark theme): a high rounded shoulder
hump, a broad level back and a round rump with a shaggy tufted top line, a stitched seam all round. Thick pillar legs with wide
paws, tan pads and cream claws; the near haunch and shoulder are big round pads sewn onto the body. A tiny stub tail (tail).
A round head with two round ears (tan inside), a long tan muzzle with a button nose, a cream V blaze at the throat;
a small dark button eye with a cream glint (eyes)."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from rigkit import *  # noqa
import importlib
K = importlib.import_module('_quad_black-bear')

R = Rig('black-bear')
FUR = ('#8e7d8a', '#665462', '#4a3b48', '#2e222c')
FAR = ('#665462', '#4a3b48', '#382c36', '#2e222c')
TAN = ('#f2d9a8', '#d9b07a', '#b48a4e', '#7a5530')
PADC = ('#c9a96e', '#9a6b3f', '#74462a', '#4a2c1a')
CLAW = CREAM

# far legs (under the body)
K.leg(R, 'legBF', 30.5, FAR, 9, 7.5, paw=(4.6, 2.6), pad=PADC, claws=TAN[1])
K.leg(R, 'legFF', 61.5, FAR, 9, 7.5, paw=(4.6, 2.6), pad=PADC, claws=TAN[1])

# tail: a tiny round stub on the rump
p = R.part('tail')
p.add(p.m(ell(21.2, 19.5, 3.0, 2.6)), FUR)

# body: rump, big shoulder hump, deep belly; shaggy tufts along the top line
p = R.part('body')
torso = union(ell(31, 23, 10.5, 10), ell(49, 19.5, 12.5, 11.5), ell(56, 26, 7.5, 7),
              poly([(24, 18), (40, 12), (52, 9), (58, 18), (60, 31), (26, 31)]))
tufts = K.fur([(25, 15), (29, 12.6), (33.5, 11.6), (38, 11), (42.5, 9.3), (47, 8.4), (51.5, 8.4), (56, 10)], 2.2)
belly = K.fur([(30, 32.3), (35, 32.6), (40, 32.6), (45, 32.4), (50, 32)], 2.2, 1.7)
p.add(p.m(torso, tufts, belly), FUR, stitch=FUR[3])
p.line([(36, 24), (37, 27)], FUR[3]); p.line([(43, 18), (44, 21)], FUR[3]); p.line([(41, 28), (42, 30)], FUR[3])

# near legs (over the body): round haunch / shoulder pads sewn on
p, m = K.leg(R, 'legBN', 25.5, FUR, 9.5, 8, paw=(4.8, 2.7), thigh=(8, 8.5), pad=PADC, claws=CLAW)
p.edge(p.m(inter(ell(27, 28, 8, 8.5), lambda x, y: y < 31)), FUR[3], sides=((0, -1), (-1, 0)))
p, m = K.leg(R, 'legFN', 56.5, FUR, 9.5, 8, paw=(4.8, 2.7), thigh=(6.5, 7), pad=PADC, claws=CLAW)
p.edge(p.m(inter(ell(55.5, 28, 6.5, 7), lambda x, y: y < 30)), FUR[3], sides=((0, -1), (1, 0)))

# head: neck, round skull, round ears, long tan muzzle, button nose, throat blaze
p = R.part('head')
ears = union(ell(61.5, 12.8, 3.4, 3.4), ell(69, 12, 3.4, 3.4))
p.add(p.m(ears), FUR, local=True)
p.add(p.m(union(ell(61.7, 13.2, 1.6, 1.6), ell(69.2, 12.4, 1.6, 1.6))), (TAN[2],) * 4, flat=True)
skull = union(ell(66, 20, 8.2, 7.2), capsule([R.pv('head'), (62, 22)], 11, 11))
muzzle = union(ell(75.5, 23, 7.5, 4.6), capsule([(72, 22.5), (81.5, 22.6)], 6.5, 5.5))
p.add(p.m(skull), FUR)
hm = p.m(skull, ears)
p.edge({q for q in hm if q[0] < 63}, INK, sides=((-1, 0), (0, -1)))           # seam where the head lies on the body
p.add(p.m(muzzle), TAN, local=True)
p.add(p.m(ell(83.6, 22.0, 2.3, 2.1)), (INK,) * 4, flat=True)                     # button nose
p.px(83, 21, FUR[0])
p.line([(83, 24), (79, 25.5), (75, 25.5)], INK)                                    # mouth
p.add(p.m(ell(67.5, 17.3, 2.6, 1.2)), (TAN[2],) * 4, flat=True)                  # tan brow spot over the eye
p.add(p.m(poly([(57, 28.5), (61, 30.5), (64, 27.5), (61, 29)])), (CREAM, CREAM, TAN[0], TAN[0]), flat=True)   # throat V

p = R.part('eyes')
K.eye_dot(p, 66.6, 19.7, r=1.4)

R.save()
