#!/usr/bin/env python3
"""reef-turtle "Reef Turtle" (snail rig, 77 x 36, 4 parts): "Paddles up the beach like a slow green boulder and snaps at anything on its path." (island, L12)
A felt hawksbill hauling itself up the beach: shell = a low streamlined teardrop of amber tortoiseshell (scutes sewn with dark
umber thread, wavy brown flame streaks and gold flecks running back across every scute), a saw-toothed rim along the rear and
the flank; body = sea-green skin: one big front paddle-flipper swung forward and planted flat in the sand (light leading edge,
dark seam where it leaves the body, a claw), the far flipper braced behind it one shade darker, a small rear flipper dug in, a cream
plastron; head = a stretched neck tiled with light-edged scale plates and a horn hawk beak whose upper half hooks down over the
lower jaw; eyes = a round dark eye with a grumpy lid."""
import math, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from rigkit import *  # noqa
import importlib
H = importlib.import_module('_turtle_desert-tortoise')

R = Rig('reef-turtle')
SKIN = ('#bfeedd', '#5fb89c', '#3a8a76', '#235a52')          # sea-green felt
FAR = darker(SKIN)
SHELL = ('#f7c860', '#e0922c', '#b0601c', '#6e3816')         # amber tortoiseshell
RIM = ('#e8a840', '#b86a20', '#8a4818', '#5a2c12')
FLAME = '#6e3816'
FLAME2 = '#9a4a18'
FLECK = '#ffe08a'
SEAM = '#5a2c12'
EDGE = '#a8e4cc'
FLIP = ('#d6f6e8', '#7ccab0', '#4a9a84', '#235a52')     # the near flipper one step lighter so it reads off the neck
BEAK = ('#fbe6b0', '#dcae5c', '#a8762e', '#5e3a18')
PLAS = ('#fff3c8', '#f2e4c0', '#c9a96e', '#9a6b3f')
G = R.ground   # 31

# body: far flipper, rear flipper, torso + plastron, the big near front flipper planted in the sand
p = R.part('body')
p.add(p.m(poly([(40, 21), (44, 21), (47, 26), (46, 29.5), (42, 30.5), (41, 27)])), FAR)              # far flipper braced behind the near one
rear = p.add(p.m(poly([(17, 20.5), (24, 22), (22, 26.5), (16, 30), (8.5, 31), (9, 29.5), (13, 26)])), SKIN)
torso = p.add(p.m(ell(37, 22, 25, 5)), SKIN)
p.add(p.m(inter(ell(36, 21.8, 22, 3.6), lambda x, y: y > 21.5 and x < 44)), PLAS)
fl = poly([(42, 20.5), (48, 19.5), (54, 22.5), (61, 26.5), (68, 29), (72.5, 30.2), (72, 31), (56, 31), (50, 30), (45, 27.5), (41, 24)])
front = p.add(p.m(fl), FLIP, local=True)
H.scutes(p, {q for q in front if q[1] < 30}, [(46, 22.5), (50, 25), (54.5, 26.5), (59, 28), (64, 29.5), (47.5, 28)], SKIN[2], sx=1.3)
for (x, y) in front:                                                 # dark seam where the flipper lies over the body
    if any((x + dx, y + dy) in torso and (x + dx, y + dy) not in front for dx, dy in ((-1, 0), (0, 1), (-1, 1), (0, -1))):
        p.px(x, y, SKIN[3])
p.line([(48, 20), (54, 23), (61, 27), (68, 29.5), (71, 30.2)], FLIP[0])   # light leading edge
p.line([(53, 30), (70, 30)], FLIP[2])                                # pressed flat on the sand
p.px(70, 30, BEAK[2]); p.px(71, 30, BEAK[3])                         # claw
p.line([(18, 22), (20, 26), (15, 29.5)], SKIN[0])
for x, y in ((16, 27), (19, 24), (30, 25), (26, 24)):
    p.px(x, y, SKIN[3])

# shell: the low amber teardrop, saw-toothed rim
p = R.part('shell')
dome = union(inter(ell(37, 20, 26, 15.8), lambda x, y: y < 18.5), poly([(9, 18.5), (13, 12.5), (14, 18.5)]))
band = inter(ell(36.5, 17.5, 27.5, 3.4), lambda x, y: y > 16)
teeth = union(*[poly([(x, 19.8), (x + 3, 19.8), (x + .3, 22.4)]) for x in range(9, 44, 3)])
rim = p.add(p.m(band, teeth, minus=(lambda x, y: x > 55 and y > 19.6,)), RIM)
cm = p.add(p.m(dome), SHELL)
H.scutes(p, cm, [(37, 7.5), (26, 9.5), (48, 9), (17, 15), (29, 15), (41, 14.5), (53, 14.5)], SEAM, sx=1.35)
for (x, y) in sorted(cm):                                            # flame streaks running back, gold flecks
    if (x, y) in p.over:
        continue
    v = math.sin(.62 * x - .9 * y + 1.8 * math.sin(.45 * y + x * .21))
    if v > .7:
        p.px(x, y, FLAME)
    elif v > .35:
        p.px(x, y, FLAME2)
    elif v < -.9 and y > 5:
        p.px(x, y, SHELL[0])
    elif (x * 37 + y * 91) % 23 == 0 and y > 4:
        p.px(x, y, FLECK)
rm = {q for q in rim if q not in cm}
for (x, y) in rm:
    if (x, y + 1) not in rm or (x + 1, y + 1) not in rm and y >= 20:   # tooth tips dark
        p.px(x, y, RIM[3])
p.line([(11, 18), (62, 18)], SEAM)                                   # rim seam
for x in range(14, 60, 4):
    p.px(x, 19, SEAM)

# head: neck, plated head, hooked beak
p = R.part('head')
hd = union(capsule([R.pv("head"), (58, 14.5), (61, 12)], 9.5, 9), ell(63, 10.3, 7.4, 5.6))
hm = p.add(p.m(hd), SKIN)
p.edge({q for q in hm if q[0] < 59 and q[1] < 20}, SKIN[3], sides=((-1, 0), (0, -1)))
for (x, y) in hm:                                                     # chin/throat seam over the flipper
    if (x, y + 1) not in hm and x < 68:
        p.px(x, y, SKIN[3])
plates = p.m(inter(ell(62, 10.5, 6.2, 4.4), lambda x, y: x < 67.5 and y < 12.5), capsule([(55, 17), (60, 13)], 5))
H.scutes(p, plates, [(59, 8), (64.5, 7), (61, 12), (56, 16)], EDGE)
up = p.add(p.m(poly([(67.5, 7.5), (71.5, 8), (74.5, 10), (76, 12.5), (76, 15.5), (74.8, 16.5), (74, 14), (70, 13.2), (67.5, 13)])), BEAK, local=True)
lo = p.add(p.m(poly([(67.5, 13.5), (73.6, 14), (73, 15.8), (69, 16.3), (67.5, 15.5)])), BEAK, local=True)
p.line([(73.5, 14), (69, 13.6), (66, 13.8)], INK)                   # mouth
p.px(74, 15, BEAK[3]); p.px(75, 15, BEAK[3])                         # hook tip
p.px(72, 10, BEAK[3])                                                 # nostril
p.add(p.m(ell(66, 14, 1.2, .9)), (BLUSH,) * 4, flat=True)

# eyes: round dark eye, grumpy lid
p = R.part('eyes')
ex, ey = 64.5, 10.2
p.add(p.m(ell(ex, ey, 2.3, 2.3)), (INK,) * 4, flat=True)
p.px(63, 10, CREAM)
p.add(p.m(inter(ell(ex, ey, 2.4, 2.4), lambda x, y: y < 9.4 - (x - ex) * .5)), (SKIN[2],) * 4, flat=True)

R.save()
