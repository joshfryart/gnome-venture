#!/usr/bin/env python3
"""crew-wren "Wren Thimblewick" (folk rig, 39 x 57, 9 parts, front view): the Trek crew's travelling naturalist, a wren
("trades stories for seeds"; villagers.lua: wren, face #9a6b3f, pink cap #e46a9b, green clothes #4f9a45).
A round brown wren head with cream eyebrow streaks, a cream throat and a short pointed beak (head), two button eyes (eyes), a pink
felt cap with a leaf sprig (hat), a green field coat with a cream chest, satchel strap and stitched hem (body), green sleeves ending in
brown wing-feather hands (armL / armR), sturdy brown boots (footL / footR) and, behind, a canvas pack with a bedroll and a
butterfly net (back). Sized to fill the frame like the other crew, head about two fifths of the height."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from rigkit import *  # noqa

R = Rig('crew-wren')
FACE = WOOD
COAT = MOSS
CAP = PETAL
BOOT = ('#9a6b3f', '#74462a', '#4a2c1a', '#2a1a10')
CANVAS = ('#f2e4c0', '#c9a96e', '#9a6b3f', '#74462a')

p = R.part('back')
p.add(p.m(capsule([(7, 19), (9, 33)], 1.5)), WOOD, flat=True)                      # net pole
p.add(p.m(union(ell(6, 15.5, 3.6, 3.2), poly([(3, 16), (9, 16), (6.5, 22.5)]))), ('#fff3c8', '#f2e4c0', '#c9a96e', '#9a6b3f'), local=True, crescent=1)   # the net bag
p.pxs([(5, 17), (7, 17), (6, 19), (4, 15), (8, 15)], '#c9a96e')                      # mesh
p.add(p.m(minus(ell(6, 14.5, 3.8, 2.4), ell(6, 14.5, 2.6, 1.3))), WOOD, flat=True)   # hoop
p.add(p.m(union(poly([(28, 44), (31, 35), (34.5, 34), (33, 45)]))), WOOD, local=True)   # the cocked-up wren tail behind the right hip
p.line([(30, 41), (33.5, 40)], WOOD[3]); p.line([(31, 38), (34, 37)], WOOD[3])     # tail bars
p.add(p.m(poly([(4.5, 31), (14.5, 30), (15, 45), (5, 45.5)]), ell(9.5, 31, 5, 2)), CANVAS)   # the pack
p.add(p.m(capsule([(4.5, 30), (14, 30)], 3.6)), ('#c8d09f', '#9aa860', '#6b7a3a', '#3f4a22'), local=True)   # rolled bedroll
p.line([(5, 38), (13, 38)], CANVAS[3]); p.px(9, 39, GOLD[1])                         # flap + buckle

for pid in ('footL', 'footR'):
    p = R.part(pid)
    x, y = R.pv(pid)
    side = -1 if pid == 'footL' else 1
    p.add(p.m(capsule([(x, y - 1), (x, y + 2)], 4.2), ell(x + side * 1.2, 50.3, 4.2, 2.4)), BOOT)
    p.line([(x - 2, 48), (x + 2, 48)], '#c9a96e')                                   # boot cuff stitch

p = R.part('body')
torso = union(poly([(12, 35), (27, 35), (29.5, 47), (19.5, 49), (9.5, 47)]), ell(19.5, 36.5, 8, 3))
p.add(p.m(torso), COAT, stitch=COAT[3])
chest = inter(ell(19.5, 38, 4.2, 7), torso)
p.add(p.m(chest), ('#fff3c8', '#f2e4c0', '#e0c690', '#c9a96e'), flat=True)
p.edge(p.m(chest), COAT[2])
p.line([(26, 35), (13, 47)], WOOD[2])                                               # satchel strap
p.px(15, 44, GOLD[1])
p.pxs([(19, 41), (19, 44)], WOOD[3])                                                # buttons
p.line([(10, 46), (29, 46)], COAT[3])                                               # hem seam

for pid in ('armL', 'armR'):
    p = R.part(pid)
    x, y = R.pv(pid)
    side = -1 if pid == 'armL' else 1
    hand = (x + side * 2.6, 43.5)
    p.add(p.m(capsule([(x, y + .5), (x + side * 2, 40.5)], 5.2, 4.6)), COAT)
    p.add(p.m(union(ell(hand[0], hand[1], 2.6, 3), capsule([hand, (hand[0] + side * .8, 46.5)], 2.4, 1.4))), FACE, local=True)
    p.line([(x + side * .4 - 2, 40), (x + side * .4 + 2, 40)], COAT[3])              # cuff seam

p = R.part('head')
hx, hy = 19.5, 25.6
skull = ell(hx, hy, 10, 9.4)
p.add(p.m(skull), FACE, stitch=None)
p.add(p.m(inter(ell(hx, hy + 6.8, 5.4, 3.4), skull)), ('#fff3c8', '#f2e4c0', '#e0c690', '#c9a96e'))   # cream throat bib
for sx in (-1, 1):                                                                  # cream eyebrow streaks
    p.line([(hx + sx * 1.5, 21), (hx + sx * 6, 20.5), (hx + sx * 9, 22.5)], '#f2e4c0')
    p.line([(hx + sx * 3, 27.5), (hx + sx * 8, 26.5)], WOOD[3])                    # dark eye-stripe cheek line
p.add(p.m(poly([(17, 26.2), (22, 26.2), (19.5, 32)])), GOLD, local=True, crescent=1)   # a thin pointed beak
p.line([(17, 26), (21, 26)], GOLD[3]); p.line([(19, 28), (19, 31)], GOLD[2])
for q in ((13, 18), (16, 17), (23, 17), (26, 18), (12, 21), (27, 21)):             # barred feather ticks
    p.px(q[0], q[1], WOOD[3])
p.px(12, 28, BLUSH); p.px(13, 28, BLUSH); p.px(26, 28, BLUSH); p.px(27, 28, BLUSH)

p = R.part('eyes')
for ex in (15.5, 23.5):
    p.add(p.m(ell(ex, 24, 1.8, 2.1)), (INK,) * 4, flat=True)
    p.px(int(ex) - 1, 23, CREAM)

p = R.part('hat')
cap = inter(ell(19.5, 17, 9, 7.5), lambda x, y: y < 17.2)
p.add(p.m(cap), CAP, stitch=CAP[3])
p.add(p.m(ell(21.5, 17.2, 10, 1.8)), (CAP[1], CAP[2], CAP[3], CAP[3]), local=True)  # the peak
p.add(p.m(ell(19.5, 9.8, 1.6, 1.4)), CAP, local=True, crescent=1)                   # top button
p.add(p.m(capsule([(25, 13), (29.5, 8.5)], 2.6, 1.4)), MOSS, local=True, crescent=1)  # leaf sprig in the band
p.line([(11, 15), (28, 15)], '#fff3c8')                                              # cream hat band

R.save()
