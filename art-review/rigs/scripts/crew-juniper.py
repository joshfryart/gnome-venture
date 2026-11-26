#!/usr/bin/env python3
"""crew-juniper "Juniper Kettleby" (folk rig, 45 x 52, 8 parts, front view): the Trek crew's cook, Brewroot mentor who runs the
Brewhouse on the Sunsprinkle Isles: "A cheerful hedgehog with a permanent apron and opinions about gravy" (Chatty; villagers.lua:
hedgehog, cream face #f2e4c0, brown spines #7a4a1f, orange clothes #e8a317, apron; "Juniper stirs up a snack").
A wide crown of soft felt spines fanning round a cream face with a little pointed snout, a dark button nose and round cheeks (head);
two button eyes (eyes); a red gingham kitchen kerchief knotted on top of the spines (hat); an orange smock under a big cream apron
with a pocket and a wooden spoon (body); orange sleeves with pink hedgehog paws, the left one carrying a copper kettle with a puff
of steam, the right one a ladle (armL / armR); stubby dark boots (footL / footR). The widest, roundest silhouette of the crew."""
import math, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from rigkit import *  # noqa

R = Rig('crew-juniper')
SPINE = ('#b07a48', '#7a4a1f', '#58331a', '#3a2210')
FACE = ('#fff3c8', '#f2e4c0', '#e0c690', '#c9a96e')
SMOCK = GOLD
APRON = ('#fffbe8', '#fff3c8', '#f2e4c0', '#c9a96e')
PAW = ('#fde0ea', '#f6b8cf', '#d98aa8', '#a8346a')
BOOT = ('#6a5648', '#4a2c1a', '#3a2214', '#2a1a10')
COPPER = ('#f6b48a', '#d9774a', '#a8502e', '#6e2e1a')
CHECK = EMBER

for pid in ('footL', 'footR'):
    p = R.part(pid)
    x, y = R.pv(pid)
    sx = -1 if pid == 'footL' else 1
    p.add(p.m(capsule([(x, y - 1.5), (x, y + 1.5)], 5), ell(x + sx * 1.2, 45.3, 4.6, 2.3)), BOOT)
    p.px(x + sx * 2.5, 44, BOOT[0])

p = R.part('body')
smock = union(poly([(14, 30), (31, 30), (33, 42), (22.5, 43.5), (12, 42)]), ell(22.5, 31.5, 9.5, 3))
p.add(p.m(smock), SMOCK, stitch=SMOCK[3])
apron = inter(smock, union(rect(16, 33, 29.5, 44), ell(22.5, 33, 6.5, 2.5)))
p.add(p.m(apron), APRON, local=True, crescent=1)
p.edge(p.m(apron), APRON[3])
p.add(p.m(rect(19.5, 37, 25.5, 40.5)), APRON, local=True, crescent=0)                   # apron pocket
p.edge(p.m(rect(19.5, 37, 25.5, 40.5)), APRON[3])
p.pxs([(21, 38), (23, 38), (22, 39)], EMBER[1])                                         # a stitched heart on the pocket
p.line([(13, 33), (16, 33)], APRON[2]); p.line([(29, 33), (32, 33)], APRON[2])         # apron ties
p.line([(17, 41), (28, 41)], EMBER[1])                                                  # red hem stripe

for pid in ('armL', 'armR'):
    p = R.part(pid)
    x, y = R.pv(pid)
    sx = -1 if pid == 'armL' else 1
    hand = (x + sx * 2.5, 38.5)
    if pid == 'armL':                                                                   # copper kettle hanging from the paw
        pot = union(ell(7.5, 43, 5.5, 4), rect(2.5, 43, 12.5, 46))
        p.add(p.m(minus(ell(hand[0], 39.5, 3.2, 3), ell(hand[0], 39.5, 2, 1.8))), WOOD, flat=True)   # handle loop
        p.add(p.m(capsule([(3.5, 43), (2, 40.5), (2, 39)], 2.4, 1.6)), COPPER, local=True)               # spout
        p.add(p.m(pot), COPPER, local=True)
        p.add(p.m(ell(7.5, 39.6, 1.6, 1)), COPPER, local=True, crescent=0)                              # lid knob
        p.line([(4, 44), (11, 44)], COPPER[3])
        p.add(p.m(capsule([(2, 38.5), (3, 36), (2, 34), (3.5, 32)], 1.8, 1.2)), ('#ffffff', '#e4f6ff', '#c9d7e0', '#a9b8c4'), local=True, crescent=0)  # a curl of steam off the spout
    else:                                                                               # ladle over the shoulder
        p.add(p.m(capsule([(hand[0] + .5, hand[1]), (hand[0] + 3, 29.5)], 1.6)), WOOD, flat=True)
        p.add(p.m(ell(hand[0] + 3.3, 29.5, 2.2, 1.8)), STONE, local=True, crescent=0)
    p.add(p.m(capsule([(x, y + .5), hand], 5.4, 4.6)), SMOCK)
    p.add(p.m(ell(hand[0], hand[1] + 1.5, 2.4, 2.2)), PAW, local=True)
    p.line([(hand[0] - 2, 37.5), (hand[0] + 2, 37.5)], SMOCK[3])                        # cuff seam

p = R.part('head')
hx, hy = 22.5, 18
spines = [ell(hx, hy - .5, 11.5, 10)]
for k in range(12):                                                                     # soft felt spines fanning round the crown
    a = math.radians(-205 + k * (230 / 11))
    r1 = 19.5 if k % 2 else 17.5
    spines.append(capsule([(hx + math.cos(a) * 9, hy + math.sin(a) * 7.5), (hx + math.cos(a) * r1, hy + math.sin(a) * r1 * .78)], 4.4, 1))
p.add(p.m(union(*spines)), SPINE)
for k in range(11):                                                                     # dark grooves between the spines
    a = math.radians(-205 + (k + .5) * (230 / 11))
    p.line([(hx + math.cos(a) * 9.5, hy + math.sin(a) * 8), (hx + math.cos(a) * 12, hy + math.sin(a) * 9.8)], SPINE[3])
face = union(ell(hx, 21.5, 9.2, 7.5), ell(hx, 26.5, 6, 3.8))
p.add(p.m(face), FACE, stitch=None)
p.add(p.m(ell(hx, 24.5, 3.2, 2.6)), FACE, local=True, crescent=1)                       # the little snout
p.add(p.m(ell(hx, 22.8, 1.8, 1.3)), (SOOT[1],) * 4, flat=True)                          # button nose
p.px(21, 22, SOOT[0])
p.line([(21, 27), (22, 28), (23, 28), (24, 27)], SPINE[3])                              # smile
for sx in (-1, 1):
    p.add(p.m(ell(hx + sx * 9.5, 13.5, 2.4, 2.2)), FACE, local=True, crescent=1)        # little round ears among the spines
    p.px(hx + sx * 7 - (sx < 0), 23, BLUSH); p.px(hx + sx * 8 - (sx < 0), 23, BLUSH)

p = R.part('eyes')
for ex in (17, 27):
    p.add(p.m(ell(ex + .5, 18.8, 1.6, 2)), (INK,) * 4, flat=True)
    p.px(ex, 18, CREAM)

p = R.part('hat')                                                                       # red gingham kerchief knotted on top
hat = union(inter(ell(hx, 11.5, 7, 4.2), lambda x, y: y < 12.4), ell(hx + 5.5, 7, 2.4, 1.9), ell(hx + 8.3, 6, 2, 1.6))
p.add(p.m(hat), CHECK, stitch=None)
p.line([(16, 11), (29, 11)], APRON[1])                                                   # cream stitched hem
p.px(hx + 5, 7, CHECK[3])

R.save()
