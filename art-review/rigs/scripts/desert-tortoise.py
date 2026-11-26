#!/usr/bin/env python3
"""desert-tortoise "Desert Tortoise" (snail rig, 77 x 41, 4 parts): "Carries a whole hill on its back and expects you to go around." (desert, L22)
A felt desert tortoise side-on: a tall sandy dome (shell) sewn from ringed scutes, each with a pale gold centre and a darker
growth ring, a scalloped rim of marginal scutes, and a little prickly pear (its drop) growing on top like a hill's crown;
body = dusty grey-tan skin: stumpy elephant legs (near pair bright, far pair one step darker) with cream toenails and scale
dots, a small pointed tail and the cream plastron edge under the rim; head = a wrinkled neck and a blunt head with a horny
beak; eyes = one small stubborn eye under a heavy brow."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from rigkit import *  # noqa
import importlib
import math


def scutes_ringed(p, mask, centres, sx=1.25):
    """sewn scutes: Voronoi cells in `mask`, seam thread at cell borders, a dark growth ring halfway out, and a pale-gold
    centre (areola) with its own dark ring around it"""
    near = {}
    for (x, y) in mask:
        X, Y = x + .5, y + .5
        near[(x, y)] = min(range(len(centres)), key=lambda i: ((X - centres[i][0]) / sx) ** 2 + (Y - centres[i][1]) ** 2)
    rad = {}
    for q, i in near.items():
        cx, cy = centres[i]
        rad[i] = max(rad.get(i, 0), math.hypot((q[0] + .5 - cx) / sx, q[1] + .5 - cy))
    core = set()
    for q, i in near.items():
        cx, cy = centres[i]
        d = math.hypot((q[0] + .5 - cx) / sx, q[1] + .5 - cy)
        if any((q[0] + dx, q[1] + dy) in near and near[(q[0] + dx, q[1] + dy)] != i for dx, dy in ((1, 0), (0, 1))):
            p.px(q[0], q[1], SEAM); continue
        r = min(rad[i], 6.5)
        if d < 2.6:
            core.add(q)
        elif d < 3.5:
            p.px(q[0], q[1], RING)
        elif abs(d - (3.5 + r) / 2 - .5) < .5:
            p.px(q[0], q[1], SAND[3])
    p.add(core, GOLDC, local=True)
    return near

R = Rig('desert-tortoise')
SKIN = ('#e0cfb0', '#bba887', '#8c7a5f', '#5e4e3c')   # dusty grey-tan
FAR = darker(SKIN)
SAND = ('#e2b276', '#c38b4e', '#97633a', '#6a3e22')
RIMC = ('#d9a868', '#b07a44', '#86552e', '#5a3620')
GOLDC = ('#fbe7a8', '#f3d07a', '#e2b456', '#c8963c')     # pale-gold scute centre
RING = '#7a4a26'                                        # dark growth ring
PAD = ('#b8d080', '#7aa64c', '#4f7a34', '#2f5a2a')
FRUIT = ('#f58ab0', '#d8336a', '#a3204f', '#6e2038')
SEAM = '#5a3620'
NAIL = ('#fff3c8', '#f2e4c0', '#c9a96e', '#9a6b3f')
G = R.ground   # 36

# body: far legs, tail, torso under the shell, plastron edge, near legs
p = R.part('body')
for x in (31, 58):                                                   # far legs, peeking between the near ones
    p.add(p.m(capsule([(x, 26), (x, G - 2)], 7, 8), ell(x + .5, G - 1, 4.6, 2.2)), FAR)
p.add(p.m(capsule([(17, 27), (12, 30), (10, 30.5)], 4.5, 1.5)), SKIN)    # tail
p.add(p.m(ell(38, 26, 22, 6)), SKIN)                                 # torso (shell + head pivots sit on it)
p.add(p.m(inter(ell(38, 27, 21, 4.4), lambda x, y: y > 29)), NAIL, flat=True)   # cream plastron edge
legs = []
for x0, x1 in ((22, 21), (50, 51)):                                  # near legs: thick columns, wider foot
    m = p.m(capsule([(x0, 25), (x1, G - 2.5)], 9, 10), ell(x1 + .5, G - 1.2, 6, 2.4))
    p.add(m, SKIN); legs.append((x1, m))
for x1, m in legs:
    for dx, dy in ((-2, -8), (1, -7), (-1, -5), (2, -4), (-3, -3)):  # big scales on the legs
        p.px(x1 + dx, G + dy, SKIN[2])
    for k in (-3, 0, 3):                                             # toenails
        p.px(x1 + k + 1, G, NAIL[1]); p.px(x1 + k + 1, G - 1, NAIL[0])
p.line([(34, 31), (44, 31)], SKIN[3])                                # a belly fold between the legs

# shell: the tall ringed dome with a scalloped rim and a prickly pear on top
p = R.part('shell')
dome = inter(ell(37, 26, 24.5, 20), lambda x, y: y < 23.5)
lobes = [ell(x, 27.2, 2.6, 2.6) for x in range(15, 62, 5)]          # marginal scutes: a row of round lobes = scalloped rim
band = inter(ell(37, 23.5, 26, 4.6), lambda x, y: y >= 21.5 and y < 27)
rim = union(band, *[l for l in lobes])
dm = p.add(p.m(dome), SAND)
rm = p.add(p.m(rim, minus=(dome,)), RIMC, local=True)
p.add(p.m(dome), SAND)                                                # dome over the band
scutes_ringed(p, p.m(dome), [(37, 10.5), (24.5, 13.5), (49.5, 13.5), (16.5, 20), (30.5, 19.5), (43.5, 19.5), (57.5, 20)])
p.edge(rm, SEAM, sides=((0, -1),))                                    # seam between dome and the rim
for x in range(17, 60, 5):                                            # marginal scute seams, between the lobes
    p.line([(x + .5, 23.5), (x + .5, 28)], SEAM)
for x in range(15, 62, 5):                                            # a tiny growth arc in each lobe
    p.px(x - 1, 24, RIMC[0]); p.px(x, 24, RIMC[0])
# the little prickly pear growing on the hilltop: two paddles, spines and red fruit
pc = p.add(p.m(ell(37, 5.4, 2.7, 3.7)), PAD, local=True)
pr = p.add(p.m(rell(41.2, 4.0, 1.9, 2.8, 35), minus=(ell(37, 5.4, 2.7, 3.7),)), darker(PAD), local=True)
pl = p.add(p.m(rell(33.4, 5.2, 1.7, 2.5, -35), minus=(ell(37, 5.4, 2.7, 3.7),)), darker(PAD), local=True)
p.edge({q for q in pc if q[1] > 6}, PAD[3])
for m in (pr, pl):
    p.edge(m, PAD[3])                       # sewn edge where the paddles sit on the dome
p.pxs([(36, 4), (38, 6), (37, 7), (41, 3), (34, 4)], CREAM)          # spine tufts
p.add(p.m(ell(37.5, 2.3, 1.1, 1.1), ell(42, 2.0, 1.1, 1.1)), FRUIT, local=True)   # fruit
p.px(37, 1, FRUIT[0]) if False else None

# head: wrinkled neck and a blunt head with a horny beak
p = R.part('head')
hd = union(capsule([R.pv('head'), (59, 20.5), (63, 18)], 9, 8), ell(65, 16, 7.2, 5.2), ell(70.5, 17.3, 3.6, 3.4))
hm = p.add(p.m(hd), SKIN)
p.edge({q for q in hm if q[0] < 61 and q[1] < 25}, SKIN[3], sides=((-1, 0), (0, -1)))   # seam where the neck lies over the shell
beak = inter(ell(70.5, 17.3, 3.6, 3.4), lambda x, y: x > 69)
p.add(p.m(beak), ('#c9a96e', '#9a7a52', '#74462a', '#4a2c1a'))
p.line([(73, 18.5), (69, 19), (65, 19)], SKIN[3])                   # mouth
p.px(73, 16, SKIN[3])                                                # nostril
for k, x in enumerate((55, 58)):                                     # neck folds: soft arcs
    p.line([(x, 25 - k * 2), (x + 1, 22.5 - k * 2), (x + 3, 21 - k * 2)], SKIN[2])
p.add(p.m(ell(67.5, 18.2, 1.3, 1)), (BLUSH,) * 4, flat=True)        # felt cheek
p.line([(61, 12.5), (64, 11.5), (67, 12)], SKIN[2])                 # head plates
p.px(63, 13, SKIN[0]); p.px(66, 12, SKIN[0])

# eyes: a small stubborn eye with a heavy brow
p = R.part('eyes')
ex, ey = 64.5, 15.2
p.add(p.m(ell(ex, ey, 2.2, 2.2)), (INK,) * 4, flat=True)
p.px(64, 14, CREAM)
p.add(p.m(inter(ell(ex, ey, 2.2, 2.2), lambda x, y: y < 14.2)), (SKIN[2],) * 4, flat=True)

R.save()
