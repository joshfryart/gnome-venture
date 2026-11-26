#!/usr/bin/env python3
"""moss-golem "Moss Golem" (golem rig, front view, 67 x 79, 7 parts): "A boulder that woke up covered in moss and opinions."
(large, lv 20, forest / rainforest / mountain; Living Moss, Golem Pebble)
A round grey felt boulder that stood up grumbling: a fat egg-shaped stone torso with a thick moss mantle sewn over its shoulders,
moss drips hanging off the hem, two stitched crack seams and a pebble pocket (body); stubby round stone legs with three toe nubs
(legL / legR); heavy hanging arms ending in big round stone mitts, each with a moss cap on the knuckles (armL / armR); a lumpy
boulder head sunk into the shoulders, a moss cushion on top with three spore stalks nodding brown capsules, a low stony brow
pulled into a frown, a pebble nose and a drooping moss moustache: the opinions (head); two small cross button eyes (eyes).
Silhouette: round and hunched, low head, mossy cushion and spore stalks on top (Gneiss is tall and horned, Holler wide and flat)."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from rigkit import *  # noqa

R = Rig('moss-golem')
ROCK = ('#e9e3d4', '#b9b1a2', '#8d8578', '#625b52')
ROCK2 = ('#cfc8b9', '#a39b8d', '#7c7469', '#625b52')      # the far / under stone, a step darker
MOSSY = ('#c8e08f', '#7ab55c', '#4f8a3e', '#2f5a2a')
CAPS = ('#c9a96e', '#9a6b3f', '#74462a', '#4a2c1a')
G = R.ground                                                # 74

# legs: stubby round stone stumps with three toe nubs
for pid in ('legL', 'legR'):
    p = R.part(pid)
    x, y = R.pv(pid)
    p.add(p.m(capsule([(x, y - 1.5), (x, G - 4)], 12, 13), ell(x, G - 2.2, 8, 3.6)), ROCK2)
    for dx in (-4, 0, 4):
        p.line([(x + dx, G - 2), (x + dx, G)], ROCK2[3])
    p.line([(x - 5, y + 3), (x + 4, y + 3.5)], ROCK2[3])      # the knee seam

# body: the boulder torso, the moss mantle over the shoulders
p = R.part('body')
torso = union(ell(33.5, 48.5, 21.5, 15), ell(14.5, 41, 6.5, 5.5), ell(52.5, 41, 6.5, 5.5))
p.add(p.m(torso), ROCK, stitch=ROCK[3])
hem = union(lambda x, y: y < 41, *[ell(x, 41.5 + (k % 2) * 1.5, 3.3, 3) for k, x in enumerate(range(12, 58, 5))])
p.add(p.m(inter(torso, hem)), MOSSY, local=True)
for x, d in ((19.5, 5), (39.5, 4)):                          # two long moss tassels
    p.add(p.m(inter(capsule([(x, 43), (x, 43 + d)], 2.6, 2), torso)), MOSSY, local=True, crescent=0)
p.line([(20, 50), (23, 53), (22, 57)], ROCK[3])           # stitched crack seams
p.line([(44, 49), (47, 52), (46, 55), (49, 58)], ROCK[3])
p.add(p.m(ell(36, 55, 3, 2.4)), ('#f2e4c0', '#c9c0ad', '#9a917f', '#625b52'), local=True)   # a pebble in a pocket
p.pxs([(28, 40), (37, 39), (45, 41), (31, 43)], MOSSY[0])

# arms: hanging stone arms with round mitts and a moss cap
for pid, s in (('armL', -1), ('armR', 1)):
    p = R.part(pid)
    x, y = R.pv(pid)
    fx = x - s * 1.5
    p.add(p.m(ell(x, y + 1, 5.5, 5), capsule([(x, y + 2), (fx, y + 12)], 8, 10)), ROCK2, crescent=1)
    fist = union(ell(fx, y + 16, 7, 6), ell(fx + s * 4.5, y + 15, 2.6, 2.6))
    p.add(p.m(fist), ROCK, local=True)
    p.add(p.m(inter(ell(fx, y + 16, 6.6, 5.8), lambda X, Y, y=y: Y < y + 14.2 + ((int(X) % 3) == 0))), MOSSY, local=True, crescent=0)
    for k in (-2.5, 0, 2.5):
        p.line([(fx + k, y + 19), (fx + k, y + 21)], ROCK[3])   # knuckles
    p.line([(x - 3.5, y + 6), (x + 3, y + 6.5)], ROCK2[3])     # elbow seam

# head: lumpy boulder, moss cushion, spore stalks, frowning brow, moss moustache
p = R.part('head')
hx = 33.5
skull = union(ell(hx, 25, 14.5, 11.5), ell(hx - 6, 21, 8, 8), ell(hx + 7, 22, 7.5, 8))
for k, (sx, top) in enumerate(((26, 3.5), (34, 2), (41.5, 5))):
    p.add(p.m(capsule([(sx, 13), (sx + (k - 1) * .8, top + 2)], 1.2)), CAPS, flat=True)
    p.add(p.m(rell(sx + (k - 1) * .8, top + 1.5, 1.6, 2.2, (k - 1) * 20)), CAPS, local=True, crescent=1)
p.add(p.m(skull), ROCK, stitch=ROCK[3])
cushion = inter(union(ell(hx, 14.5, 13, 5), ell(hx - 9, 16, 5, 3.6), ell(hx + 9, 16.5, 5, 3.4)), lambda x, y: y < 18 + ((int(x) * 5) % 4 == 0))
p.add(p.m(cushion), MOSSY, local=True)
p.pxs([(28, 12), (36, 11), (40, 14), (31, 15)], MOSSY[0])
p.add(p.m(ell(23.5, 13, 1.6, 1.5)), PETAL, local=True, crescent=0)   # one small flower in the moss
p.add(p.m(poly([(22, 20), (32, 23.2), (33.5, 22), (35, 23.2), (46, 20), (46, 21.8), (35, 24.6), (32, 24.6), (22, 21.8)])), ROCK2, flat=True)
p.line([(22, 22), (32, 24.5)], ROCK[3]); p.line([(35, 24.5), (46, 22)], ROCK[3])  # the brow shadow: a scowl
p.add(p.m(ell(hx + .5, 29, 2.6, 2.2)), ROCK2, local=True)                # pebble nose
must = union(rell(hx - 3, 32.3, 4.6, 2, 12), rell(hx + 4, 32.3, 4.6, 2, -12), capsule([(hx - 7, 32.5), (hx - 8.5, 35)], 1.8, 1.2), capsule([(hx + 8, 32.5), (hx + 9.5, 35)], 1.8, 1.2))
p.add(p.m(must), MOSSY, local=True, crescent=0)
p.line([(hx - 2, 35.2), (hx + 3, 35.2)], INK)                          # a grumpy little mouth under it
p.add(p.m(ell(hx - 10.5, 29.5, 1.8, 1)), (BLUSH,) * 4, flat=True)
p.add(p.m(ell(hx + 11.5, 29.5, 1.8, 1)), (BLUSH,) * 4, flat=True)

# eyes: two small button eyes under the brow
p = R.part('eyes')
for ex in (28, 40):
    p.add(p.m(ell(ex + .5, 26, 2.6, 2.4)), (INK,) * 4, flat=True)
    p.px(ex - 1 + (ex > 30), 25, CREAM)

R.save()
