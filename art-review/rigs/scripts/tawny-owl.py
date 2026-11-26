#!/usr/bin/env python3
"""tawny-owl "Tawny Owl" (bird rig, 43 x 65, 8 parts): "Silent wings in the dark. Listen for them." (large, forest and mountain, level 17, night/dusk)
A round, earless felt tawny owl in three-quarter view: a big round chestnut head with a pale buff facial disc sewn on with a dark
rim and a pale V between two big dark button eyes, a small horn hooked beak (head, eyes), an egg-shaped body with a buff chest
streaked in dark chestnut (body), a folded barred chestnut wing with a row of cream scapular spots (wing, +r lifts it), a short barred
tail poking out behind (tail), fluffy buff feathered trousers (thighs) and feathered legs ending in grey toes with dark talons
(legB darker behind, legF in front). No ear tufts: that is what tells it from the eagle-owl."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from rigkit import *  # noqa

R = Rig('tawny-owl')
TAWNY = ('#d8a066', '#b06a3a', '#7e4426', '#4a2c1a')
BUFF = ('#f6e0b4', '#e6bf88', '#c08f58', '#8a5a32')
DISC = ('#fff3c8', '#f2d8a8', '#d8b07a', '#9a6b3f')
TOE = ('#c9c5bc', '#8b8f96', '#5b6470', '#2a1a10')
G = R.ground + 1


def leg(pid, ramp):
    p = R.part(pid)
    x, y = R.pv(pid)
    p.add(p.m(capsule([(x, y - 1), (x + .5, G - 3)], 4.4, 4)), ramp)
    p.add(p.m(capsule([(x - 1, G - 1.5), (x + 4.5, G - 1.5)], 2.6), capsule([(x, G - 2), (x - 2.5, G - 1)], 2.2)), TOE, local=True, crescent=0)
    p.pxs([(int(x) + 5, G - 1), (int(x) - 3, G - 1)], INK)                     # talons
    p.line([(x - 1, G - 5), (x + 2, G - 5)], ramp[2])


p = R.part('tail')
tail = poly([(14, 40), (5, 52), (6.5, 55), (11.5, 54.5), (18, 46)])
p.add(p.m(tail), TAWNY)
p.line([(7, 52), (12, 51)], TAWNY[3]); p.line([(9, 48), (14.5, 47)], TAWNY[3])

leg('legB', darker(BUFF))

p = R.part('body')
bod = union(ell(21.5, 39, 12.2, 14), ell(22, 30, 10, 7))
p.add(p.m(bod), TAWNY, stitch=TAWNY[3])
chest = inter(bod, ell(26.5, 40, 8.2, 12.5))
p.add(p.m(chest), BUFF)
for x0, y0 in ((25, 31), (29, 33), (23, 37), (27, 39), (31, 40), (25, 44), (29, 46), (22, 48)):   # dark shaft streaks
    p.line([(x0, y0), (x0, y0 + 2)], TAWNY[2])

leg('legF', BUFF)

p = R.part('thighs')
th = union(ell(19.5, 51, 4.4, 3.6), ell(26.5, 51, 4.6, 3.8))
p.add(p.m(th), BUFF, local=True)
p.pxs([(18, 54), (20, 54), (25, 54), (27, 54), (29, 53)], BUFF[2])             # fluffy tips
p.line([(23, 49), (23, 53)], BUFF[2])

p = R.part('wing')
wing = union(ell(17.5, 32, 5.5, 5.5), capsule([(17, 31), (14.5, 42), (11, 52)], 10, 3.5))
p.add(p.m(wing), TAWNY, local=True)
p.edge(p.m(wing), TAWNY[3], sides=((1, 0), (0, 1), (-1, 0)))
for y in (38, 42, 46):                                                        # dark bars on the flight feathers
    p.line([(11 + (y - 38) * .3, y + 1), (18.5 - (y - 38) * .45, y)], TAWNY[3])
for q in ((14, 29), (18, 28), (20, 31), (15, 33), (19, 34)):                    # cream scapular spots
    p.px(q[0], q[1], DISC[0])

p = R.part('head')
hx, hy = 24, 14.5
head = union(ell(hx, hy, 12.5, 10.5), ell(22.5, 21.5, 11, 5.5))
p.add(p.m(head), TAWNY)
disc = inter(union(ell(27.8, 15.2, 5.2, 6.4), ell(33.6, 15.2, 4.6, 6.2)), head)
p.add(p.m(disc), BUFF, local=True)
p.edge(p.m(disc), TAWNY[3], sides=((-1, 0), (0, -1), (0, 1)))                # the sewn dark rim of the two-lobed facial disc
p.line([(27, 9.5), (31, 14), (35, 9.5)], DISC[0])                                # pale V brows between the eyes
p.add(p.m(poly([(29.5, 16.5), (32.6, 16.5), (31.6, 21), (30.2, 20.8)])), GOLD, local=True, crescent=0)   # small hooked beak
p.line([(31, 19), (31, 20)], GOLD[3])
p.pxs([(17, 6), (21, 5), (15, 10), (19, 8), (14, 15)], TAWNY[3])              # crown flecks
p.pxs([(16, 8), (20, 7)], TAWNY[0])

p = R.part('eyes')
for ex, r in ((27.6, 2.6), (34.2, 2.3)):
    p.add(p.m(ell(ex, 14.4, r, r + .2)), (INK,) * 4, flat=True)
    p.px(int(ex) - 1, 13, CREAM)

R.save()
