#!/usr/bin/env python3
"""crew-burdock "Burdock Deepdelve" (folk rig, 39 x 52, 8 parts, front view): the Trek crew's Rootwarden, "a broad, patient mole
who judges every garden by the smell of its soil. Keeps the Root Cellar" (Warm; villagers.lua: mole, face #8b8f96, straw hat
#f5cf6a, gold clothes #e8a317; "Burdock moves the roots").
A wide round grey velvet mole head with a paler muzzle, a long pink snout drooping over a small smile, two tiny contented squint
eyes (eyes) and pink cheeks (head); a broad woven straw hat with a red band and a purple burdock burr tucked in it (hat); a roomy
gold work smock with a brown twine belt, a sewn-on sprout patch pocket and a stitched hem (body); gold sleeves ending in big pink
spade paws with cream claws, the right one holding a short wooden trowel up (armL / armR); bare pink mole feet with claws
(footL / footR). Wide and low, a clear silhouette apart from the tall-capped, mandibled Bracken."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from rigkit import *  # noqa

R = Rig('crew-burdock')
FUR = ('#c9cbd2', '#8b8f96', '#6a6e78', '#4a4e58')
SMOCK = GOLD
STRAW = ('#fff3c8', '#f5cf6a', '#d9a84a', '#a8782a')
PAW = ('#fde0ea', '#f6b8cf', '#d98aa8', '#a8587a')
BURR = ('#c3b2ea', '#8a72c8', '#5a4096', '#3a2a66')

for pid in ('footL', 'footR'):
    p = R.part(pid)
    x, y = R.pv(pid)
    sx = -1 if pid == 'footL' else 1
    p.add(p.m(capsule([(x, y - 1.5), (x, y + 2)], 4.4), ell(x + sx * 1, 45.6, 4.6, 2.2)), PAW)
    for k in (-2, 0, 2):
        p.px(x + sx * 1 + k, 47, CREAM)                                              # toe claws

p = R.part('body')
smock = union(poly([(12, 30.5), (27, 30.5), (31, 43), (19.5, 44.2), (8, 43)]), ell(19.5, 31.5, 9, 2.6))
p.add(p.m(smock), SMOCK, stitch=SMOCK[3])
p.add(p.m(inter(smock, rect(8, 37, 31, 38.5))), WOOD, flat=True)                     # twine belt
p.px(22, 38, WOOD[3]); p.px(23, 39, WOOD[2])
pocket = rect(14, 39.5, 19, 43)
p.add(p.m(pocket), (GOLD[0], '#f0c040', GOLD[2], GOLD[3]), local=True, crescent=0)
p.edge(p.m(pocket), GOLD[3])
p.pxs([(16, 40), (17, 40), (16, 41)], MOSS[1])                                        # a sprout sewn on the pocket
p.line([(19, 31), (19, 36)], SMOCK[3])
p.add(p.m(ell(19.5, 31, 4, 1.4)), FUR, local=True, crescent=0)                       # a glimpse of grey neck fur

for pid in ('armL', 'armR'):
    p = R.part(pid)
    x, y = R.pv(pid)
    sx = -1 if pid == 'armL' else 1
    hand = (x + sx * 2, 38.5)
    if pid == 'armR':                                                                 # a short wooden trowel held up
        p.add(p.m(capsule([(hand[0] + 1, 39), (hand[0] + 2, 31)], 2.4)), WOOD, local=True, crescent=0)
        p.add(p.m(poly([(hand[0] - 1, 31.5), (hand[0] + 5, 31.5), (hand[0] + 5, 27), (hand[0] + 2.5, 23)])), STONE, local=True, crescent=0)
    p.add(p.m(capsule([(x, y + .5), (x + sx * 1.6, 36)], 5.6, 5)), SMOCK)
    p.add(p.m(ell(hand[0], hand[1], 3.2, 3)), PAW, local=True)
    for k in (-1.5, 0, 1.5):
        p.px(hand[0] + k, hand[1] + 2.5, CREAM)                                       # spade claws
    p.line([(x + sx * 1.4 - 2.5, 35.5), (x + sx * 1.4 + 2.5, 35.5)], SMOCK[3])       # cuff seam

p = R.part('head')
hx, hy = 19.5, 20
skull = union(ell(hx, hy, 13.5, 10), ell(hx, 28, 7, 3))
p.add(p.m(skull), FUR, stitch=FUR[2])
p.add(p.m(inter(ell(hx, hy + 6.5, 7, 4.2), skull)), ('#e6e4ea', '#c9cbd2', '#a6a9b2', '#8b8f96'), local=True)   # pale muzzle
for sx in (-1, 1):                                                                   # little round velvet ears peeking out
    p.add(p.m(ell(hx + sx * 13, hy - 3, 2.4, 2.2)), FUR, local=True, crescent=0)
snout = union(capsule([(hx, 21), (hx, 25)], 2.8, 3.6), ell(hx, 25.8, 2.8, 2.1))
p.add(p.m(snout), PAW, local=True)
p.pxs([(18, 26), (20, 26)], PAW[3])                                                    # nostrils
p.line([(16.5, 29), (19.5, 30), (22.5, 29)], INK)                                     # small smile under the snout
for sx in (-1, 1):
    p.pxs([(hx + sx * 9 - (sx < 0), 23), (hx + sx * 10 - (sx < 0), 23)], BLUSH)
    p.line([(hx + sx * 4.5, 26), (hx + sx * 8, 27)], FUR[2])                          # whisker stitches

p = R.part('eyes')
for ex in (14.5, 25):                                                                    # tiny contented squints
    p.add(p.m(rect(ex - 1.5, 19, ex - .5, 20), rect(ex - .5, 18, ex + .5, 19), rect(ex + .5, 19, ex + 1.5, 20)), (INK,) * 4, flat=True)

p = R.part('hat')
brim = ell(19.5, 13.3, 17, 3.2)
crown = inter(ell(19.5, 11, 9.5, 8), lambda x, y: y < 13)
p.add(p.m(brim, crown), STRAW, stitch=STRAW[3])
p.add(p.m(inter(crown, rect(9, 9.5, 30, 12))), EMBER, flat=True)                     # red band
for x in range(5, 35, 3):
    p.px(x, 14 + (x % 2), STRAW[2])                                                    # weave ticks on the brim
p.add(p.m(ell(25, 9.5, 2.2, 2.2)), BURR, local=True, crescent=0)                       # a burdock burr in the band
p.pxs([(24, 7), (27, 9), (25, 12), (23, 10)], BURR[3])

R.save()
