#!/usr/bin/env python3
"""wild-boar "Wild Boar" (quad.bear rig, 107 x 49, 10 parts; large; forest, grassland; drops Leaf Mould Clump, Oak Gall; attack: charge)
"Roots up the acorn path like a plough with bristles, and your plot looks like next."
A front-heavy felt boar in warm bark-brown: a tall bristled shoulder hump with a dark spiky crest sewn along the spine, the back
sloping down to a small rump, a darker belly band. Short slim legs on dark cloven hooves. A thin tail with a dark tassel (tail).
A long wedge head ending in a flat pink snout disc with two nostrils, a cream tusk curling up out of the lip, a pointed ear;
a small dark button eye with a cream glint (eyes). An oak leaf caught in the bristles (leaf) and a cream snort puff (puff)."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from rigkit import *  # noqa
import importlib
K = importlib.import_module('_quad_wild-boar')

R = Rig('wild-boar')
FUR = ('#b08a68', '#86634a', '#644634', '#3e2a20')
FAR = darker(FUR)
DARK = ('#6a5040', '#4a3428', '#36261e', '#2a1a10')
HOOF = ('#6a5648', '#4a3a32', '#2e221c', '#2a1a10')
SNOUT = PETAL
OAK = ('#c8d09f', '#7ab55c', '#4f8a3e', '#2f5a2a')

# far legs (behind the body)
K.leg(R, 'legBF', 41, FAR, 6.5, 3.5, top=4, foot=HOOF, foot_w=4)
K.leg(R, 'legFF', 70, FAR, 6.5, 3.5, top=4, foot=HOOF, foot_w=4)

# tail: thin, hanging off the rump, with a dark tassel
p = R.part('tail')
p.add(p.m(capsule([(31.5, 21), (26, 22.5), (23.5, 27)], 2.6, 2.0)), FUR, local=True)
p.add(p.m(ell(23, 29.5, 2.2, 3.0)), DARK, local=True)

# body: small rump, tall shoulder hump, deep chest; bristle crest along the spine, dark belly band
p = R.part('body')
torso = union(ell(38, 24, 10, 10), ell(56, 21, 15, 13), poly([(30, 20), (44, 13), (58, 8), (66, 18), (70, 30), (34, 32)]))
crest = K.spikes([(37, 16), (41, 14), (45, 12), (49, 10.3), (53, 9), (57, 8.6), (61, 9.4), (65, 11.5)], 6, 2.3, lean=-1.8)
belly = K.tufts([(36, 33), (41, 34), (46, 34.5), (51, 34.5), (56, 34), (61, 33.5)], 2.4, 1.8)
p.add(p.m(torso, belly), FUR, stitch=FUR[3])
p.add(p.m(crest), DARK, local=True)
p.add(p.m(inter(union(torso, belly), lambda x, y: y > 30.5)), DARK, local=True)
for x, y in ((44, 19), (49, 17), (54, 15), (59, 16), (47, 24), (53, 22), (58, 26), (41, 25)):   # bristle ticks
    p.px(x, y, FUR[3]); p.px(x - 1, y - 1, FUR[3])

# leaf: a lobed oak leaf caught in the bristles, rising up and forward from its stem pivot
p = R.part('leaf')
lv = K.tufts([(47, 10.5), (50, 8), (53, 5.5), (48, 6.5), (51.5, 10.5), (54.5, 8.5), (51, 4)], 2.1)
p.add(p.m(capsule([R.pv('leaf'), (46, 12)], 1.6), lv, rell(50.5, 7.7, 5, 3, -40)), OAK, local=True)
p.line([(44, 14), (47, 11), (53, 5)], OAK[3]); p.line([(49, 9), (48, 7)], OAK[3]); p.line([(51, 7), (53, 8)], OAK[3])

# near legs: haunch and shoulder pads sewn onto the body
p, m = K.leg(R, 'legBN', 35, FUR, 7, 4, top=4, thigh=(6, 7), foot=HOOF, foot_w=4.5)
p.edge(p.m(inter(ell(35, 30, 6, 7), lambda x, y: y < 33)), FUR[3], sides=((0, -1), (-1, 0)))
p, m = K.leg(R, 'legFN', 64.5, FUR, 7, 4, top=4, thigh=(5, 6.5), foot=HOOF, foot_w=4.5)
p.edge(p.m(inter(ell(63.5, 30, 5, 6.5), lambda x, y: y < 32)), FUR[3], sides=((0, -1), (1, 0)))

# head: thick neck, long wedge face, pointed ear, pink snout disc, curled tusk
p = R.part('head')
ear = poly([(68, 16), (70.5, 7), (76, 14.5)])
p.add(p.m(ear), FUR, local=True)
p.add(p.m(poly([(70, 15), (71, 10), (73.5, 14)])), (PETAL[2],) * 4, flat=True)
face = union(ell(68.5, 24, 8, 9), poly([(65, 16), (74, 14), (84, 18.5), (92, 21.5), (92.5, 29.5), (84, 31), (74, 33), (64, 32)]))
p.add(p.m(face), FUR)
p.edge({q for q in p.m(face) if q[0] < 64}, INK, sides=((-1, 0), (0, -1)))       # seam where the head lies on the shoulder
p.add(p.m(inter(face, below((66, 29), (92, 27), 0))), DARK, local=True)            # dark jowl
p.add(p.m(ell(93, 25.5, 2.4, 4.2)), SNOUT, local=True)                               # snout disc
p.px(93, 24, PETAL[3]); p.px(93, 27, PETAL[3])                                       # nostrils
p.line([(86, 30), (79, 30.5)], INK)                                                 # mouth
tusk = p.m(capsule([(84, 31), (87.5, 29), (88.5, 23)], 3.4, 2.2))                   # tusk: added last so it sits over the lip
p.add(tusk, (CREAM, CREAM, CREAM, CREAM), flat=True)
for q in tusk:
    if (q[0] - 1, q[1]) not in tusk or (q[0], q[1] + 1) not in tusk:
        p.px(q[0], q[1], PAPER[2])
p.line([(72, 18), (75, 18.5), (77, 19.5)], DARK[2])                                  # brow
for a, b in (((70, 22), (71, 25)), ((78, 22), (79, 25))):
    p.line([a, b], FUR[3])

p = R.part('eyes')
K.eye_dot(p, 75, 21, r=1.2)

# puff: a cream snort cloud at the snout (hidden until it snorts; scales out from its pivot)
p = R.part('puff')
cloud = K.tufts([(96, 25), (99, 23.5), (102, 24.5), (100, 27), (103, 21.5)], 2.0)
p.add(p.m(cloud), (CREAM, '#f1ece0', STONE[1], STONE[2]), local=True)

R.save()
