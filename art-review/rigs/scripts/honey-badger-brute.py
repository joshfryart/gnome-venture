#!/usr/bin/env python3
"""honey-badger-brute "Honey Badger Brute" (quad.bear rig, 79 x 42, 8 parts; lv 32, by the well / picnic knoll; drops Badger Claw)
A thick-set honey badger bruiser: a long, low, flat-backed body in charcoal felt (lightened, cool) with the honey badger's
silver-cream cape sewn over the whole top, from the crown of the head along the back to the tail; a big muscled shoulder.
Short black legs, the front paws with long cream digging claws. A short thick tail, cape on top (tail).
A small flat-topped head with only a tiny ear ridge, the cape running over the crown, a black face and blunt snout,
a stolen chunk of gold honeycomb clamped in the jaws with a honey drip; a small mean ember eye under a scowl (eyes)."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from rigkit import *  # noqa
import importlib
K = importlib.import_module('_quad_black-bear')

R = Rig('honey-badger-brute')
COAL = ('#74727c', '#4c4a54', '#38363f', '#25232b')
FAR = ('#4c4a54', '#38363f', '#2e2c34', '#25232b')
CAPE = ('#fffaf0', '#ece6d6', '#cbc3b0', '#9a917e')
HONEY = GOLD


def cape_of(a, b):
    """everything above the line a->b (the cape edge)"""
    return minus(lambda x, y: True, below(a, b, 0))


# far legs (under the body)
K.leg(R, 'legBF', 27.5, FAR, 8.5, 7, paw=(4.4, 2.4), claws=CAPE[2])
K.leg(R, 'legFF', 56, FAR, 8.5, 7, paw=(4.4, 2.4), claws=CAPE[2])

# tail: a short thick stub, cape on top
p = R.part('tail')
t = capsule([(18.5, 16), (13.5, 13.5)], 5.5, 4.5)
p.add(p.m(t), COAL)
p.add(p.m(inter(t, cape_of((19, 15.5), (11, 13.5)))), CAPE, local=True)

# body: long, low, flat back, big shoulder; cape over the top half, a hard sewn edge
p = R.part('body')
torso = union(ell(24, 19.5, 9, 9.5), ell(45, 17.5, 12, 11.5), poly([(17, 13), (26, 9), (46, 6.5), (55, 10), (57, 27), (22, 28)]),
              K.fur([(24, 28.4), (29, 28.8), (34, 29), (39, 29), (44, 28.8), (49, 28.2)], 2.3, 1.6))
p.add(p.m(torso), COAL, stitch=COAL[3])
ce = ((14, 18.5), (36, 16.5), (58, 19))
cape = inter(torso, lambda x, y: y < 18.5 - (x - 14) * .09 + max(0, x - 36) * .2)
p.add(p.m(cape), CAPE, stitch=CAPE[3])
p.edge(p.m(cape), CAPE[3], sides=((0, 1),))
p.line([(44, 21), (46, 25)], COAL[3])                                               # shoulder muscle seam

# near legs (over the body)
p, m = K.leg(R, 'legBN', 22, COAL, 9, 7.5, paw=(4.6, 2.5), thigh=(6.5, 6.5), claws=CAPE[2])
p.edge(p.m(inter(ell(23, 25, 6.5, 6.5), lambda x, y: y < 27)), COAL[3], sides=((0, -1), (-1, 0)))
p, m = K.leg(R, 'legFN', 51, COAL, 10, 7.5, paw=(4.6, 2.5), thigh=(6.5, 7), top=4.5)
g = R.ground
for i, x in enumerate((54, 56, 58)):                                                 # long digging claws
    p.line([(x, g - 1), (x + 1.5, g)], CREAM)

# head: thick neck, flat crown under the cape, ear ridge, black blunt face, honeycomb in the jaws
p = R.part('head')
skull = union(ell(58, 15.5, 7.4, 6.4), capsule([R.pv('head'), (55, 16)], 11, 10))
snout = poly([(60, 11), (65.5, 12.2), (68.6, 14.6), (68.4, 18.2), (63, 20.5), (58, 20)])
p.add(p.m(skull, snout), COAL)
p.edge({q for q in p.m(skull) if q[0] < 54}, INK, sides=((-1, 0), (0, -1)))
crown = inter(union(skull, snout), lambda x, y: y < 12.4 + max(0, x - 57) * .3 + max(0, 54 - x) * .35)
p.add(p.m(crown), CAPE, local=True)
p.add(p.m(ell(55, 10.8, 1.8, 1.2)), (COAL[2],) * 4, flat=True)                     # tiny ear ridge
p.add(p.m(ell(68.2, 14.6, 1.5, 1.4)), (INK,) * 4, flat=True)                         # nose
comb = poly([(62.5, 18), (70.5, 17), (72.5, 19.5), (71, 22.5), (63.5, 22.5)])
p.add(p.m(comb), HONEY, local=True)
for x, y in ((64.5, 19), (67.5, 18.5), (70, 19), (66, 21), (69, 21)):           # comb cells
    p.pxs([(x, y), (x + 1, y)], HONEY[3])
p.add(p.m(capsule([(66.5, 22), (66.5, 24)], 1.2, 2.2)), HONEY, flat=True)            # honey drip
p.line([(63, 18.5), (61, 18.5)], INK)                                                 # jaw corner

p = R.part('eyes')
K.eye_dot(p, 60.6, 13.7, r=1.1, glint=EMBER[0])
p.line([(58, 11.5), (61, 12.5), (62.5, 12.5)], INK)                                 # scowl

R.save()
