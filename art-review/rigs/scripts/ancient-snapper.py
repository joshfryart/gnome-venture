#!/usr/bin/env python3
"""ancient-snapper "Ancient Snapping Turtle" (snail rig, boss, 113 x 54, 4 parts): "Older than the marsh itself." (wetland, L28; Turtle Scute, Mossy Shell)
A felt alligator snapping turtle, the marsh boss: shell = a bark-brown carapace sewn from ringed scutes with three keels of
tall pointed spikes (the top keel breaks the silhouette like a saw), patches of moss felt on top and moss strands hanging off
the rim; body = olive-grey skin: thick clawed legs (far pair one step darker), a long tail with a saw ridge, the plastron;
head = a huge blocky head with a hooked horn beak, the jaw hanging a little open on a pink worm lure, warty spots and a
heavy brow; eyes = a small gold eye with a dark pupil under the brow."""
import math, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from rigkit import *  # noqa
import importlib
H = importlib.import_module('_turtle_desert-tortoise')

R = Rig('ancient-snapper')
SKIN = ('#b2b496', '#868a6a', '#5e634a', '#3c4030')       # olive-grey hide
FAR = darker(SKIN)
BARK = ('#b09868', '#7e6c44', '#56482c', '#342a1a')
BARKF = darker(BARK)
HORN = ('#948c80', '#66615a', '#484440', '#2c2927')       # old grey horn
CLAW = ('#fff3c8', '#f2e4c0', '#c9a96e', '#9a6b3f')
MOUTH = ('#7d2c5e', '#5a1f44', '#5a1f44', '#3e1530')
LURE = ('#fde0ea', '#f07aa8', '#e46a9b', '#a8346a')
G = R.ground   # 49


def warts(p, mask, seed, every, skip=lambda x, y: False):
    """raised warts: a light knob with a dark shadow under it"""
    for (x, y) in sorted(mask):
        if ((x * 73856093) ^ (y * 19349663) ^ seed) % every == 0 and (x, y + 1) in mask and (x, y - 1) in mask and not skip(x, y):
            p.px(x, y, SKIN[0]); p.px(x, y + 1, SKIN[2])


# body: far legs, tail with its saw ridge, torso, plastron, near legs with claws
p = R.part('body')
for x in (46, 88):
    p.add(p.m(capsule([(x, 37), (x, G - 3)], 11, 12), ell(x + 1, G - 1.5, 7, 2.4)), FAR)
tail = capsule([(28, 40), (16, 43.5), (4, 46)], 9, 2.5)
tcy = lambda x: 40 + (28 - x) * .29 if x > 16 else 43.5 + (16 - x) * .21
thw = lambda x: 1.25 + (x - 4) / 24 * 3.25
teeth = [poly([(x - 2.6, tcy(x) - thw(x) + 1.5), (x + 2, tcy(x) - thw(x) + 1.5), (x - 2.2, tcy(x) - thw(x) - 2.2 - x * .1)]) for x in (8, 12.5, 17, 21.5, 26)]
p.add(p.m(tail), SKIN)
p.add(p.m(*teeth), BARK, local=True)                                 # the saw ridge: horny bark-brown teeth along the tail
p.add(p.m(ell(55, 39, 34, 6)), SKIN)
p.add(p.m(inter(ell(55, 38.5, 30, 4.6), lambda x, y: y > 40)), ('#e8dcb4', '#cbbf8c', '#a89a62', '#7a6a3a'))   # plastron
for x in (34, 77):
    m = p.m(capsule([(x, 37), (x + 1, G - 3)], 13, 14), ell(x + 1.5, G - 1.5, 8.6, 2.6))
    p.add(m, SKIN)
    p.edge({q for q in m if q[1] > 39}, SKIN[3], sides=((-1, 0), (1, 0)))
    for k in (0, 3, 6):                                              # claws
        p.add(p.m(poly([(x + k + .5, G - 1.5), (x + k + 4, G + .9), (x + k + 1, G + .9)])), CLAW, flat=True)
    for dx, dy in ((-3, -9), (2, -8), (-1, -6), (3, -5), (-4, -4), (0, -3)):   # big leg scales
        p.px(x + dx, G + dy - 1, SKIN[0]); p.px(x + dx, G + dy, SKIN[3])
for x in range(6, 27, 4):
    p.px(x, round(tcy(x)) + 1, SKIN[3])

# shell: bark-brown carapace, three spiked keels (the far one peeks out between the tall middle spikes,
# the near one runs along the side as a row of hooked knobs), moss on top and dripping off the rim
p = R.part('shell')
top = lambda x: 34 - 25 * math.sqrt(max(0, 1 - ((x - 53) / 34) ** 2))
dome = inter(ell(53, 34, 34, 25), lambda x, y: y < 34)
far = union(*[poly([(x - 3, top(x) + 3), (x + 3.5, top(x) + 3), (x - 1, top(x) - 4.5)]) for x in (34, 44, 54, 64, 74)])
p.add(p.m(far), BARKF, local=True)                                   # far keel, one step darker
spikes = [poly([(x - 4, top(x - 4) + 3), (x + 4.5, top(x + 4) + 3), (x - 2.5, top(x) - 8.5)]) for x in (28, 39, 50, 61, 72, 82)]
rim = inter(ell(53, 33, 35.5, 4.2), lambda x, y: y > 30)
scallop = union(*[ell(x, 37.6, 1.8, 1.8) for x in range(21, 88, 6)])
cm = p.add(p.m(dome, minus(rim, scallop)), BARK)
for s in spikes:                                                      # middle keel: tall saw spikes, lit on their own
    p.add(p.m(s, minus=(dome,)), BARK, local=True)
H.scutes(p, cm, [(40, 13), (53, 10.5), (66, 13), (78, 19), (30, 24), (43, 22), (56, 21.5), (69, 22.5), (81, 27)], BARK[3],
         ring=BARK[2], rings=(.5,), sx=1.25)
p.line([(19, 30), (87, 30)], BARK[3])
for x in range(24, 87, 6):
    p.line([(x, 31), (x, 34)], BARK[3])
for x, y in ((30, 24), (43, 22), (56, 21.5), (69, 22.5), (81, 27)):  # near keel: a hooked knob on every side scute
    x, y = int(x), int(y)
    p.pxs([(x - 2, y), (x - 1, y), (x, y), (x + 1, y), (x - 1, y - 1), (x, y - 1), (x - 1, y - 2)], BARK[0])
    p.pxs([(x - 2, y + 1), (x - 1, y + 1), (x, y + 1), (x + 1, y + 1), (x + 2, y + 1), (x + 1, y)], BARK[3])
for x in (28, 39, 50, 61, 72, 82):                                    # dark back edge of each tall spike
    p.line([(x - 2.5, top(x) - 7.5), (x + 3, top(x + 4) + 1)], BARK[2])
moss = p.m(inter(union(ell(50, 8.5, 8, 3), ell(58, 10.5, 4.5, 2.2), ell(34, 17.5, 4.5, 2.6), ell(37, 20, 2.5, 1.8), ell(76, 16.5, 4.5, 2.4), ell(63, 27.5, 4, 1.8)), dome))
for (x, y) in sorted(moss):                                          # moss felt sewn over the scutes
    p.px(x, y, MOSS[0] if (x * 7 + y * 13) % 7 == 0 else (MOSS[2] if (x, y + 1) not in moss else MOSS[1]))
for x, n in ((24, 5), (37, 4), (51, 6), (66, 4), (83, 5)):          # moss strands hanging off the rim
    p.add(p.m(capsule([(x, 31), (x - .5, 31 + n)], 2, 1.5)), MOSS, flat=True)

# head: huge blocky head with a heavy brow, hooked horn beak, jaw hanging open on a pink worm lure
p = R.part('head')
neck = capsule([R.pv('head'), (82, 27)], 15, 14)
skull = poly([(72, 22), (78, 16.5), (84, 15), (99, 15.5), (101, 17.5), (102, 28.5), (86, 29.5), (74, 31)])
cheek = ell(83, 27, 8, 6)
jaw = poly([(76, 33), (85, 31.5), (98, 33.5), (100, 37), (92, 38.5), (80, 38)])
hm = p.add(p.m(neck, skull, cheek, jaw), SKIN)
p.edge({q for q in hm if q[0] < 83 and q[1] < 33}, SKIN[3], sides=((-1, 0), (0, -1)))
gap = p.m(poly([(84.5, 30), (102, 28.5), (105.5, 34.5), (98, 34), (85.5, 31.5)]))
p.add(gap, MOUTH, flat=True)
lure = p.m(capsule([(90, 31.6), (92.5, 30.6), (95, 32), (97.5, 30.8), (100, 31.8), (101.5, 31)], 2.2))
p.add(lure, LURE, flat=True)                                          # the worm lure on the tongue
p.px(92, 30, LURE[0]); p.px(97, 30, LURE[0]); p.px(101, 30, LURE[0])
beak = p.add(p.m(poly([(99, 17), (103, 17.2), (106.5, 19.5), (109, 23.5), (110.3, 29), (109.2, 34), (106.5, 38.5), (105.2, 34.5),
                (103.5, 30.5), (100.5, 29), (99.5, 22)])), HORN, local=True)   # hooked upper beak
p.edge({q for q in beak if q[0] < 101}, HORN[3], sides=((-1, 0),))
p.add(p.m(poly([(97, 33.8), (104, 34.6), (105.5, 36.5), (101, 39), (96, 38.6)])), HORN, local=True)    # lower beak
p.line([(101, 18.5), (104, 19.5), (106.5, 23), (107.5, 29)], HORN[0])               # horn shine
p.px(106, 20, HORN[3]); p.px(107, 20, HORN[3])                       # nostril
p.line([(84, 30), (79, 30.5)], SKIN[3])                              # mouth corner crease
p.line([(79, 36), (85, 37.5), (93, 37.5)], SKIN[2])                  # chin fold
warts(p, hm, 5, 19, skip=lambda x, y: (x, y) in gap or (x, y) in lure or x > 97 or 15 < y < 22 and 83 < x < 99)
# heavy brow: a thick overhanging ridge, lit on top, deep shadow under it
brow = p.m(poly([(82, 19.5), (85, 14.5), (90, 12), (96, 12.2), (100, 15), (99.5, 19), (93, 18.5), (87, 19.2), (84, 21)]))
p.add(brow, SKIN, local=True)
p.line([(84, 21), (87, 19.6), (93, 19), (98, 19.8)], SKIN[3]); p.line([(86, 20.6), (88, 20.2)], SKIN[3]); p.line([(94, 20), (97, 20.6)], SKIN[3])
p.line([(85, 16.6), (88, 14.2), (91, 13.2), (96, 13.4)], SKIN[0])

# eyes: a small mean gold eye tucked under the brow
p = R.part('eyes')
ex, ey = 91.1, 21.1
p.add(p.m(ell(ex, ey, 2.8, 2.8)), (INK,) * 4, flat=True)
p.add(p.m(ell(ex, ey, 1.9, 1.9)), (GOLD[0],) * 4, flat=True)
p.add(p.m(rect(91, 20, 93, 23)), (INK,) * 4, flat=True)
p.px(90, 21, CREAM)
p.add(p.m(inter(ell(ex, ey, 2.9, 2.9), lambda x, y: y < 20.2 - (x - ex) * .35)), (SKIN[3],) * 4, flat=True)

R.save()
