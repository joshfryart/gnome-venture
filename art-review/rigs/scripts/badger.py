#!/usr/bin/env python3
"""badger "Badger" (quad.bear rig, 79 x 46, 8 parts; drops Badger Claw; woodland digger)
A European badger in grizzled silver-grey felt: a low wedge-shaped body, widest and highest at the hips, the back sloping down to the
shoulders, with a long fringed fur skirt hanging along the belly over the tops of the legs (darker grey underside).
Short black legs, big spade paws with cream digging claws on the front. A short grey brush tail (tail).
A long pointed white head with the badger's two black stripes running from the snout over the eyes to the ears, small white-tipped
ears, a black button nose; a small dark eye inside the stripe with a cream glint (eyes)."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from rigkit import *  # noqa
import importlib
K = importlib.import_module('_quad_black-bear')

R = Rig('badger')
GREY = ('#dedad2', '#aeaaa4', '#86848a', '#5f5e68')
UNDER = ('#86848a', '#5f5e68', '#4a4952', '#34333c')
LEGC = ('#5a5660', '#3e3b45', '#2f2c35', '#25232b')
FAR = ('#3e3b45', '#2f2c35', '#28252d', '#25232b')
WHITE = ('#fffaf0', '#f2ede2', '#d6cfc0', '#a8a090')
STRIPE = ('#4a4752', '#34313b', '#2a2830', '#25232b')
GRIZ = '#c9c5bc'

# far legs (under the body)
K.leg(R, 'legBF', 27.5, FAR, 8, 6.5, paw=(4.4, 2.4))
K.leg(R, 'legFF', 56, FAR, 8, 6.5, paw=(4.4, 2.4), claws=WHITE[2])

# tail: a short grey brush, pale tip
p = R.part('tail')
t = union(capsule([(19, 19.5), (13, 17.5)], 5, 5.5), K.fur([(12, 15.5), (11, 19)], 1.8))
p.add(p.m(t), GREY)
p.add(p.m(inter(t, lambda x, y: x < 13)), WHITE, local=True)

# body: low wedge, high at the hips, sloping to the shoulders; long fringed skirt; grizzle flecks
p = R.part('body')
torso = union(ell(26, 20, 10.5, 10), ell(44, 22, 11, 9), poly([(18, 14), (28, 9.5), (40, 11.5), (54, 16), (57, 28), (22, 29)]))
skirt = K.fur([(20, 29), (24.5, 31), (29, 32), (33.5, 32.5), (38, 32.5), (42.5, 32), (47, 31.2), (51.5, 30)], 2.4, 2.4)
whole = union(torso, skirt)
p.add(p.m(whole), GREY, stitch=GREY[3])
p.add(p.m(inter(whole, lambda x, y: y > 27.5 - (x - 20) * .03)), UNDER, local=True)
for x, y in ((24, 14), (30, 13), (36, 15), (42, 17), (27, 19), (33, 18), (39, 21), (46, 21), (23, 24), (30, 24), (36, 25), (50, 23)):
    p.px(x, y, GRIZ); p.px(x + 1, y + 1, GREY[3])                                   # grizzled guard hairs
for x in (24, 30, 36, 42, 48):
    p.line([(x, 31), (x + .5, 33)], UNDER[3])                                       # fringe parting

# near legs (over the body): short and black, hidden at the top by the skirt
p, m = K.leg(R, 'legBN', 22, LEGC, 8.5, 7, paw=(4.6, 2.5), thigh=(5.5, 5.5))
p, m = K.leg(R, 'legFN', 51, LEGC, 8.5, 7, paw=(4.8, 2.5), thigh=(5, 5.5))
g = R.ground
for x in (54, 56, 58):                                                              # digging claws
    p.line([(x, g - 1), (x + 1.5, g)], CREAM)

# head: long, pointed, white, two black stripes over the eyes to the ears
p = R.part('head')
ears = union(ell(54, 15.5, 2.6, 2.4), ell(59.5, 14.4, 2.4, 2.2))
skull = union(ell(57, 20.5, 6.8, 6), capsule([R.pv('head'), (54, 21.5)], 10, 9))
snout = poly([(58, 15.5), (66, 18), (72.5, 21), (72.5, 23.5), (66, 25.5), (57, 26)])
p.add(p.m(ears), STRIPE, local=True)
p.add(p.m(union(ell(53.6, 14.2, 1.6, 1), ell(59.2, 13.2, 1.5, 1))), (WHITE[0],) * 4, flat=True)   # white ear tips
head = union(skull, snout)
p.add(p.m(head), WHITE)
p.add(p.m(inter(head, lambda x, y: y > 24.5 - max(0, x - 60) * .12)), UNDER, local=True)     # dark throat
p.edge({q for q in p.m(skull, ears) if q[0] < 53}, INK, sides=((-1, 0), (0, -1)))
stripe = capsule([(53, 17), (58, 17), (64, 18.8), (70, 21.2)], 4.2, 2.0)
p.add(p.m(inter(stripe, head)), STRIPE, flat=True)
p.add(p.m(inter(capsule([(48, 19.5), (54, 20.5)], 4, 3), head)), GREY, local=True)  # grey cheek back to the body
p.add(p.m(ell(72.4, 21.7, 1.5, 1.4)), (INK,) * 4, flat=True)                       # nose
p.line([(71.5, 24), (67, 24.5)], STRIPE[0])                                        # mouth

p = R.part('eyes')
p.add(p.m(ell(60.6, 17.7, 1.3, 1.2)), (INK,) * 4, flat=True)
p.px(60, 17, CREAM)

R.save()
