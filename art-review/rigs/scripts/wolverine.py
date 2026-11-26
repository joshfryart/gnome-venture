#!/usr/bin/env python3
"""wolverine "Wolverine" (quad.bear rig, 95 x 51, 8 parts; drops Badger Claw, Frost Crystal)
A stout snow-country wolverine in deep chocolate felt: a strongly arched back that peaks mid-body and drops to a low head and
low rump, shaggy tufted fur along the top line with frost on the tips. The wolverine's tan "skunk-bear" band is sewn along the
flank from the shoulder over the hip to the tail root. Short thick legs, dark boots, big paws with long cream claws.
A long bushy tail held out and up behind (tail) with a frosted tip. A broad low head with small round ears, a pale silver brow
band, a dark mask and short muzzle, a snarl with cream teeth; a small amber eye (eyes)."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from rigkit import *  # noqa
import importlib
K = importlib.import_module('_quad_black-bear')

R = Rig('wolverine')
FUR = ('#a27a5e', '#74503b', '#563a2a', '#3a2418')
FAR = ('#74503b', '#563a2a', '#45301f', '#3a2418')
BOOT = ('#563a2a', '#45301f', '#3a2418', '#2a1a10')
BAND = ('#f5dfaa', '#dcb878', '#b8915a', '#8a6438')
BROW = ('#f4eee0', '#d8cfbe', '#b0a690', '#8a7f6a')
FROST = '#e4f6ff'

# far legs (under the body)
K.leg(R, 'legBF', 31.5, FAR, 9, 7.5, paw=(4.8, 2.6), pad=BOOT, claws=BAND[0])
K.leg(R, 'legFF', 63.5, FAR, 9, 7.5, paw=(4.8, 2.6), pad=BOOT, claws=BAND[0])

# tail: a long bushy brush held out and up behind, frost on the tip
p = R.part('tail')
brush = union(capsule([(27, 25), (20, 20.5), (13.5, 15)], 6, 10.5), ell(12, 13.5, 5, 4.6),
              K.fur([(22, 17), (17.5, 13.5), (13.5, 10), (9, 11.5), (8.5, 16), (12, 19.5), (17, 22.5)], 1.8))
p.add(p.m(brush), FUR, stitch=FUR[3])
p.line([(20, 18), (15, 14)], FUR[3]); p.line([(17, 21), (12, 17)], FUR[3])
p.pxs([(13, 8), (8, 10), (7, 15)], FROST)

# body: arched back peaking mid-body, shaggy top, flank band from shoulder to tail root
p = R.part('body')
torso = union(ell(31.5, 27, 9.5, 9), ell(43, 23, 12.5, 12.5), ell(57, 28, 8.5, 8),
              poly([(24, 26), (32, 16), (44, 11), (56, 17), (63, 30), (60, 36.5), (28, 36.5)]))
tufts = K.fur([(26.5, 21), (30, 17.3), (34, 14.5), (38.5, 12.4), (43, 11.4), (47.5, 12.2), (52, 14.3), (56, 17.5), (59.5, 21.5)], 2.1)
skirt = K.fur([(30, 36.6), (35, 37.2), (40, 37.4), (45, 37.4), (50, 37.2), (55, 36.6)], 2.3, 1.8)
p.add(p.m(torso, tufts, skirt), FUR, stitch=FUR[3])
band = capsule([(25.5, 25), (33, 21), (43, 19.5), (52, 22), (59, 27)], 3.6, 4.2)
p.add(p.m(inter(band, torso)), BAND, local=True)
p.pxs([(38, 10), (43, 9), (48, 10), (34, 12)], FROST)

# near legs (over the body), thick haunch and shoulder pads
p, m = K.leg(R, 'legBN', 27, FUR, 10, 8, paw=(5, 2.7), thigh=(7.5, 7.5), pad=BOOT, claws=CREAM)
p.edge(p.m(inter(ell(29, 31, 7.5, 7.5), lambda x, y: y < 33)), FUR[3], sides=((0, -1), (-1, 0)))
p, m = K.leg(R, 'legFN', 58.5, FUR, 10, 8, paw=(5, 2.7), thigh=(6, 6.5), pad=BOOT, claws=CREAM)
p.edge(p.m(inter(ell(57.5, 31, 6, 6.5), lambda x, y: y < 33)), FUR[3], sides=((0, -1), (1, 0)))

# head: low broad head on a thick neck, small round ears, silver brow band, dark mask, short snout, snarl
p = R.part('head')
ears = union(ell(63, 17.6, 3.0, 3.0), ell(70, 17.2, 3.0, 3.0))
skull = union(ell(68, 24.5, 8.5, 7), capsule([R.pv('head'), (63, 26)], 12, 12))
snout = poly([(70, 19.5), (80, 22), (84, 24.5), (83.5, 28), (76, 31), (68, 30)])
p.add(p.m(ears), FUR, local=True)
p.add(p.m(union(ell(63.2, 18, 1.4, 1.4), ell(70.2, 17.6, 1.4, 1.4))), (BAND[2],) * 4, flat=True)
p.add(p.m(skull, snout), FUR)
p.edge({q for q in p.m(skull, ears) if q[0] < 64}, INK, sides=((-1, 0), (0, -1)))
p.add(p.m(inter(capsule([(61, 22.5), (66, 20.2), (73, 20.6)], 3.2, 2.6), skull)), BROW, local=True)   # silver brow band
p.add(p.m(inter(snout, lambda x, y: x > 72)), BOOT, local=True)                    # dark mask / muzzle
p.add(p.m(ell(83.5, 24.4, 1.8, 1.5)), (INK,) * 4, flat=True)                       # nose
p.line([(83, 28), (78, 29), (73, 27.5)], INK)                                      # snarl
p.pxs([(75, 28), (77, 29), (79, 28), (81, 28)], CREAM)                             # teeth
p.px(76, 29, PETAL[2])

p = R.part('eyes')
K.eye_dot(p, 68.6, 22.7, r=1.3, iris='#e8a317')

R.save()
