#!/usr/bin/env python3
"""crew-tumble "Tumble Waymarsh" (folk rig, 35 x 64, 8 parts, front view): the Trek crew's pathfinder, Wayfinder mentor who keeps the
Trailmarker's Hut in the Rainroot Reaches: "A long-legged hare who knows every crossroads and half the shortcuts" (Curious;
villagers.lua: hare, face #d9a660, orange clothes #e8a317; "Tumble reads the signs").
A tan hare head with a cream muzzle, a pink nose, two buck teeth and whisker stitches (head); two bright button eyes (eyes); the tall
ears, pink inside, the right one kinked over at the tip, which wobble as one piece like a hat (hat); an orange trail waistcoat over
a cream shirt, a moss-green scarf with a hanging end, a brass compass on a cord and brown breeches (body); tan sleeves (cuffed),
the left hand holding a rolled trail map, the right gripping a tall walking staff with a little pennant (armL / armR); long hare
feet (footL / footR). The tallest, thinnest silhouette of the crew: ears plus staff."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from rigkit import *  # noqa

R = Rig('crew-tumble')
FUR = ('#ecc48a', '#d9a660', '#b5824a', '#8a5a2e')
MUZ = ('#fffbe8', '#fff3c8', '#f2e4c0', '#d8c495')
VEST = GOLD
SHIRT = PAPER
SCARF = MOSS
BREECH = WOOD
PINK = ('#fde0ea', '#f6b8cf', '#e46a9b', '#a8346a')

for pid in ('footL', 'footR'):                                                       # long hare feet
    p = R.part(pid)
    x, y = R.pv(pid)
    sx = -1 if pid == 'footL' else 1
    p.add(p.m(capsule([(x, y - 3), (x, y + 1.5)], 4.4), ell(x + sx * 1.5, 57.3, 5, 2.4)), FUR)
    p.line([(x + sx * 3 - 1, 58), (x + sx * 3 + 1, 58)], FUR[3])                     # toe stitches
    p.px(x + sx * 1, 58, FUR[3])

p = R.part('body')
vest = union(poly([(9.5, 42), (25.5, 42), (27, 50), (8, 50)]), ell(17.5, 42.8, 9.6, 2.6))
legs = union(poly([(9, 49), (26, 49), (25, 54.5), (19, 55), (17.5, 52.5), (16, 55), (10, 54.5)]))
p.add(p.m(legs), BREECH)
p.add(p.m(vest), VEST, stitch=VEST[3])
shirt = inter(vest, poly([(14.5, 41), (20.5, 41), (17.5, 49)]))
p.add(p.m(shirt), SHIRT, local=True, crescent=0)
p.line([(17, 45), (17, 49)], VEST[3])
p.pxs([(15, 46), (15, 48), (19, 46), (19, 48)], WOOD[3])                             # waistcoat buttons
p.add(p.m(ell(23, 47, 1.8, 1.8)), STONE, local=True, crescent=0)                       # brass-rimmed compass
p.edge(p.m(ell(23, 47, 1.8, 1.8)), GOLD[2]); p.px(23, 46, EMBER[1])
p.line([(21, 43), (23, 45)], WOOD[3])
p.add(p.m(ell(17.5, 42.3, 6.5, 2)), SCARF, local=True)                                 # scarf round the neck
p.add(p.m(capsule([(14, 43), (13, 48.5)], 2.6, 2.2)), SCARF, local=True)               # the hanging end
p.line([(12, 48), (14, 48)], SCARF[3])

for pid in ('armL', 'armR'):
    p = R.part(pid)
    x, y = R.pv(pid)
    sx = -1 if pid == 'armL' else 1
    hand = (x + sx * 1.8, 49.5)
    if pid == 'armR':                                                               # walking staff, pennant at the top
        p.add(p.m(capsule([(hand[0] + .5, 56), (hand[0] + 1.8, 30)], 1.8)), WOOD, flat=True)
        p.add(p.m(ell(hand[0] + 1.8, 30, 1.4, 1.4)), WOOD, local=True, crescent=0)
        p.add(p.m(poly([(hand[0] + 2.4, 31), (hand[0] + 6.5, 33), (hand[0] + 2.4, 35)])), EMBER, local=True, crescent=0)
    else:                                                                           # rolled trail map
        p.add(p.m(rell(hand[0] - 1.5, 52, 1.8, 4.2, -25)), SHIRT, local=True)
        p.line([(hand[0] - 3, 54), (hand[0] - .5, 49)], EMBER[1])
    p.add(p.m(capsule([(x, y + .5), hand], 4.6, 4)), SHIRT)
    p.add(p.m(rect(hand[0] - 2.2, 46.5, hand[0] + 2.2, 48.5)), VEST, local=True, crescent=0)   # rolled-up cuff
    p.add(p.m(ell(hand[0], 50.5, 2.2, 2.1)), FUR, local=True)

p = R.part('head')
hx, hy = 17.5, 31.5
skull = union(ell(hx, hy, 10.5, 9.8), ell(hx, 38.5, 7, 3.8))
p.add(p.m(skull), FUR)
muz = union(ell(hx - 1.8, 36, 2.4, 2), ell(hx + 1.8, 36, 2.4, 2))
p.add(p.m(muz), MUZ, local=True, crescent=1)                                           # cream whisker pads
p.add(p.m(poly([(hx - 1.8, 33), (hx + 1.8, 33), (hx, 35)])), PINK, local=True, crescent=0)   # nose
p.add(p.m(rect(hx - 1, 38.5, hx + 1, 40.5)), MUZ, flat=True)                           # buck teeth
p.line([(hx, 38.5), (hx, 40)], MUZ[3])
for sx in (-1, 1):                                                                    # whisker stitches
    p.line([(hx + sx * 5, 35), (hx + sx * 8, 34)], FUR[3]); p.line([(hx + sx * 5, 37), (hx + sx * 8, 37.5)], FUR[3])
p.pxs([(10, 33), (11, 33), (23, 33), (24, 33)], BLUSH)
p.px(13, 25, FUR[0]); p.px(14, 24, FUR[0])

p = R.part('eyes')
for ex in (13, 21):
    p.add(p.m(ell(ex + .5, 30.5, 1.6, 2)), (INK,) * 4, flat=True)
    p.px(ex, 29, CREAM)

p = R.part('hat')                                                                    # the long ears
p.add(p.m(ell(hx, 23.5, 5.5, 2.2)), FUR)
L = [(hx - 3, 24), (hx - 4.5, 13), (hx - 4, 3.5)]
Rr = [(hx + 3, 24), (hx + 5, 12.5), (hx + 9, 8.5)]
for pts, inner in ((L, [(hx - 3.4, 21), (hx - 4.4, 12), (hx - 4, 6)]), (Rr, [(hx + 3.4, 21), (hx + 4.8, 13)])):
    p.add(p.m(capsule(pts, 6.4, 4.6)), FUR, local=True)
    p.add(p.m(capsule(inner, 2.4, 1.6)), PINK, flat=True)
p.line([(hx + 5, 12), (hx + 7, 11)], FUR[3])                                           # the crease where the ear kinks over
p.px(hx + 10, 8, FUR[3]); p.px(hx + 10, 9, FUR[3])                                     # dark tip of the kinked ear

R.save()
