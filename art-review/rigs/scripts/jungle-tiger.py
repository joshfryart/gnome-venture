#!/usr/bin/env python3
"""jungle-tiger "Jungle Tiger" (quad.feline rig, 89 x 56, 8 parts): "Stripes in the shade, then suddenly a tiger-shaped problem." (forest, rainforest; lv 26; Velvet Pelt, Spotted Pelt, Fox Fang)
A big tiger in orange velvet felt: a long, heavy, level body with tapered umber stripes sewn down from the back, a cream belly,
thick striped legs on broad paws, a long tail curving up behind with umber rings and an umber tip (tail, sprung up-left). A broad head
with small round ears (umber backs, cream spot), white flared cheek ruffs, a cream muzzle, a pink nose, forehead stripes and
cream brows; an amber eye (eyes). Heavier and more striped than the cloud-leopard sibling, orange where the jaguar is jade."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from rigkit import *  # noqa
from _quad_savanna_hyena import leg, eye_round

R = Rig('jungle-tiger')
ORNG = ('#f5cf6a', '#f08a4a', '#c8602a', '#8a3a1a')
FAR = darker(ORNG)
STR = '#3a2418'
WHT = ('#fff3c8', '#fff3c8', '#f2e4c0', '#c9a96e')


def stripes(p, xs, top, bot, clip, w=2.4, lean=-1.5):
    for x in xs:
        p.fill(p.m(inter(capsule([(x, top), (x + lean, bot)], w, .8), clip)), STR)


def striped_leg(pid, x, ramp, back):
    p, m = leg(R, pid, x, ramp, 9 if back else 8, 6.5, knee=(x + 2, 44) if back else None, paw=(5, 3))
    px_, py_ = R.pv(pid)
    stripes(p, [x - 2.5, x + 2], py_ + 2, py_ + 5, lambda X, Y: (int(X), int(Y)) in m, 1.8, -2.5)
    return p, m


striped_leg('legBF', 33, FAR, True)
striped_leg('legFF', 61.5, FAR, False)

# tail: long, curves up behind, rings and a dark tip
p = R.part('tail')
path = [(24, 28.5), (16, 30.5), (9, 27), (5.5, 19), (7.5, 11)]
tail = capsule(path, 6.5, 5)
p.add(p.m(tail), ORNG)
for a, b in (((15, 26), (14, 34)), ((9, 23), (5, 29)), ((2, 20), (9, 19)), ((2, 15), (9.5, 15.5))):
    p.add(p.m(inter(capsule([a, b], 2), tail)), (STR,) * 4, flat=True)
p.add(p.m(inter(ell(7.5, 10.5, 3.6, 3.2), tail)), (STR,) * 4, flat=True)

# body: long and level, cream belly, stripes down from the back
p = R.part('body')
torso = union(ell(30, 29, 11.5, 9.5), ell(53, 28.5, 12, 10), rect(30, 19.5, 53, 38))
p.add(p.m(torso), ORNG, stitch=True)
p.add(p.m(inter(torso, lambda x, y: y > 33.5)), WHT)
stripes(p, [22, 27, 32, 37, 42, 47, 52, 57], 18, 27, torso)
stripes(p, [25, 35, 45, 55], 30, 35, torso, 1.8, 1.5)

# near legs
striped_leg('legBN', 27.5, ORNG, True)
p, m = striped_leg('legFN', 56, ORNG, False)

# head: broad, small round ears, flared white cheek ruffs, cream muzzle and brows
p = R.part('head')
ears = union(ell(59.5, 10, 3.6, 3.4), ell(68.5, 8.2, 3.6, 3.4))
p.add(p.m(ears), ORNG, local=True)
p.edge(p.m(ears), STR)
p.add(p.m(union(ell(59.8, 10.8, 1.8, 1.7), ell(68.8, 9, 1.8, 1.7))), WHT, flat=True)
skull = union(ell(66.5, 18.5, 10, 9), capsule([R.pv('head'), (61, 22)], 12, 12))
cheek = poly([(57.5, 21), (56, 28.5), (60, 26.5), (61.5, 30.5), (65, 27), (70, 27.5), (66, 22)])
p.add(p.m(skull), ORNG)
p.add(p.m(cheek), WHT, local=True)
p.add(p.m(ell(74.5, 22.5, 4.8, 3.8)), WHT)                                         # muzzle
p.add(p.m(ell(77.8, 20.2, 1.7, 1.3)), (PETAL[2], PETAL[2], PETAL[3], PETAL[3]), flat=True)
p.line([(78, 21.5), (77, 23.5), (74.5, 24.5)], STR)                                 # mouth
p.px(75, 26, CREAM); p.px(77, 25.5, CREAM)                                          # fang tips
for a, b in (((64, 11), (65, 15)), ((67, 10.5), (67.5, 14)), ((70.5, 11), (70, 14.5))):
    p.line([a, b], STR)                                                             # forehead stripes
p.line([(58, 17), (62, 18)], STR); p.line([(58.5, 21), (61.5, 21)], STR)            # cheek stripes
p.add(p.m(ell(70.5, 16.2, 1.8, 1)), WHT, flat=True)                                 # cream brow

p = R.part('eyes')
eye_round(p, 69.2, 19.4, '#f5cf6a', r=2.5, ry=2.3)

R.save()
