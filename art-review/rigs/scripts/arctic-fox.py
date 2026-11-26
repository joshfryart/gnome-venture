#!/usr/bin/env python3
"""arctic-fox "Arctic Fox" (quad.canid rig, 89 x 56, 8 parts): "A ghost of the snow." (large, tundra, L16; White Pelt, Fox Fang)
A round winter puffball in snow-white felt: a deep fluffy body with a scalloped belly fringe and a big ruff at the chest (body),
short stocky legs on fat furry paws (near legs white with a blue-grey seam where they sit on the body, far legs a cold step down),
a huge round brush tail curled up over the back with tufted edges (tail, sprung), a small round head with short rounded ears,
a short muzzle, ink nose, cheek fluff and a knitted red scarf (head), a dark button eye (eyes).
Cold blue shading so it reads as snow (not as the cream dingo); the roundest, shortest-legged of the canid batch."""
import importlib.util, os, sys
_s = importlib.util.spec_from_file_location('qk', os.path.join(os.path.dirname(os.path.abspath(__file__)), '_quad_arctic-fox.py'))
qk = importlib.util.module_from_spec(_s); _s.loader.exec_module(qk)
from rigkit import *  # noqa

R = Rig('arctic-fox')
SNOW = ('#ffffff', '#eef1f4', '#c3ccd8', '#8b98aa')
FAR = ('#c3ccd8', '#aab4c4', '#8b98aa', '#6e7c92')
SCARF = ('#f08a4a', '#dd3a2a', '#a8241f', '#6e2038')
SEAM = '#7d8aa0'

# far legs: short and thick, a step darker
qk.hind(R, 'legBF', FAR, 6.5, 5, back=2)
qk.leg(R, 'legFF', 59.5, FAR, 6, 5)

# tail: a huge round brush curling up over the back, tufted along its outer edge
p = R.part('tail')
qk.brush(p, [(25, 27), (18, 26.5), (12, 22), (9, 15), (11.5, 8.5)], 8, 12, SNOW)
p.add(p.m(qk.fluff([(18, 30), (11, 28), (5.5, 21), (4, 13), (6, 6), (12, 3.5)], 2.2, 2.8)), SNOW)
for a, b in (((15, 22), (18, 24)), ((8, 16), (11, 17)), ((11, 9), (14, 11))):
    p.line([a, b], SNOW[3])                                                         # fur seams

# body: deep and round, a scalloped belly fringe, a ruff at the chest, a stitched back
p = R.part('body')
torso = union(ell(40, 28.5, 15.5, 8.5), ell(51, 26.5, 8.5, 9.5))
fringe = qk.fluff([(27, 36), (34, 38.5), (42, 38.5), (50, 36.5)], 2.4)
ruff = qk.fluff([(57, 18), (61, 24), (61, 30.5), (56.5, 35.5)], 2.6)
p.add(p.m(torso, fringe, ruff), SNOW, stitch=SNOW[2])
for a, b in (((30, 34), (32, 36.5)), ((38, 35), (39, 37.5)), ((46, 34.5), (47, 37)), ((56, 26), (58.5, 27)), ((55, 31), (57.5, 32.5))):
    p.line([a, b], SNOW[3])                                                         # tuft seams

qk.hind(R, 'legBN', SNOW, 7, 5, back=2, against=('legBF', 'body'), seamcol=SEAM)
qk.leg(R, 'legFN', 54, SNOW, 6, 5, against=('legFF', 'body'), seamcol=SEAM)

# head: small round skull, short muzzle, short round ears, cheek fluff, knitted scarf at the neck
p = R.part('head')
skull = ell(63, 15.5, 8.5, 7.5)
muzzle = poly([(66, 13), (74, 15.5), (77.5, 17.5), (76.5, 20), (70, 21.5), (64, 20.5)])
cheek = qk.fluff([(58, 12), (55.5, 17), (57.5, 22), (63, 23)], 2.5)
neck = capsule([R.pv('head'), (61, 17)], 10, 10)
ears = union(rell(57.5, 8.5, 3.2, 4.4, -20), rell(64.5, 6.8, 3.2, 4.4, 10))
p.add(p.m(ears), SNOW, local=True)
p.add(p.m(union(rell(57.8, 9.2, 1.4, 2.4, -20), rell(64.6, 7.6, 1.4, 2.4, 10))), (SNOW[2],) * 4, flat=True)
p.add(p.m(skull, muzzle, cheek, neck), SNOW)
p.add(p.m(inter(minus(muzzle, skull), lambda x, y: y > 18.5)), (SNOW[0], SNOW[0], SNOW[1], SNOW[2]))
qk.nose(p, 76, 17)
p.line([(76, 19.5), (73, 20), (71, 19.5)], SNOW[3])                                 # mouth
p.px(69, 19, BLUSH); p.px(68, 19, BLUSH)                                            # felt cheek
p.line([(58, 15), (60, 16)], SNOW[3]); p.line([(57, 19), (59.5, 19.5)], SNOW[3])  # cheek-tuft seams
scarf = union(capsule([(53, 22.5), (58, 24.5), (63.5, 23.5)], 4, 3.5), poly([(53, 23), (50.5, 30.5), (53.5, 31), (56, 24.5)]))
p.add(p.m(scarf), SCARF, local=True)
for x in (53, 56, 59, 62):
    p.px(x, 23 + (62 - x) * .25, SCARF[3])                                            # knit ribs
p.line([(50.5, 30.5), (53, 30.5)], '#f5cf6a')                                       # fringe

p = R.part('eyes')
qk.eye(p, 67.8, 15.1)

R.save()
