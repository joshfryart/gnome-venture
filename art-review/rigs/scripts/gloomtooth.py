#!/usr/bin/env python3
"""gloomtooth "Gloomtooth" (quad.bear rig, 125 x 50, 8 parts; boss, Lv 19, Chapter I's den; attack: slam)
"A blind old mole with a blackened muzzle. His digging made every tunnel down here." Sick with the blight, not wicked.
A huge low felt mole in slate-plum velvet (lightened dark felt): a long hunched loaf of a body with no neck, a stitched seam and
two sewn-on patches, lilac blight blotches seeping through the fur; tiny pink hind feet and two enormous pink spade forepaws turned
outward with cream claws (the near one in front of the chest). The head is a long tapering snout whose fur turns black from the
cheek to the nose, a small pink nose button, and one long cracked cream tooth hanging from under the snout (the gloom tooth).
His eye is blind: a milky cream button with no pupil under a heavy drooping lid (eyes). A tiny stub tail (tail)."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from rigkit import *  # noqa

R = Rig('gloomtooth')
FUR = ('#a79db4', '#7d7392', '#5a526e', '#3c3650')
FAR = ('#7d7392', '#5a526e', '#463f58', '#3c3650')
SNOUT = ('#6e5a72', '#4a3a50', '#33283a', '#241a2a')
BLIGHT = ('#c8a4c0', '#a07a9c', '#7a5878', '#56405a')
PAW = ('#fde0ea', '#f6b8cf', '#d98aa8', '#a8587a')
TOOTH = ('#ffffff', '#fff3c8', '#e6d6a8', '#b8a070')
G = R.ground + 1.0


def foot(pid, fx, ramp, w, big=False):
    p = R.part(pid)
    x, y = R.pv(pid)
    p.add(p.m(inter(union(capsule([(x, y - 4), (fx, G - 3)], w, w - 1), ell(x, y - 2, w / 2 + 1, w / 2 + 1)), lambda X, Y: Y < G)), ramp)
    if big:   # the spade forepaw turned outward: a broad pink palm, five long cream claws fanning forward along the ground
        palm = inter(rell(fx + 3, G - 5, 6, 4.6, -20), lambda X, Y: Y < G)
        p.add(p.m(palm), PAW, local=True)
        for k in range(4):
            a = (fx + 6 + k * .6, G - 8.5 + k * 2.3)
            b = (fx + 13 - k * .3, G - 7 + k * 1.9)
            p.add(p.m(capsule([a, b], 2.0, 1.0)), TOOTH, local=True, crescent=1)
        p.line([(fx - 1, G - 6), (fx + 3, G - 2)], PAW[3])
        p.px(fx + 1, G - 7, PAW[3]); p.px(fx + 3, G - 6, PAW[3])
    else:
        p.add(p.m(inter(ell(fx + 2.5, G - 2, 4.5, 2.4), lambda X, Y: Y < G)), PAW, local=True)
        for k in range(3):
            p.px(fx + 5 + (k == 1), G - 3 + k, TOOTH[1])
    return p


foot('legBF', 49, FAR, 8)
foot('legFF', 84, FAR, 8, big=True)

p = R.part('tail')
p.add(p.m(capsule([(36, 21), (30, 17)], 4.4, 3)), FUR)

# body: a long low hunched loaf, highest over the shoulders, seam + patches + blight
p = R.part('body')
loaf = union(ell(46, 26, 15, 13), ell(67, 22, 18, 15), ell(79, 27, 8, 9.5), ell(37, 30, 6, 8),
             poly([(33, 37), (38, 18), (62, 7), (84, 15), (87, 37)]))
p.add(p.m(loaf), FUR, stitch=FUR[3])
for q, r in (((72, 14), 4.2), ((50, 12), 3.0), ((80, 26), 3.0)):   # blight seeping out of the fur: a dark stain with a lilac halo
    blot = inter(union(ell(q[0], q[1], r * 1.5, r), ell(q[0] - r, q[1] + r * .6, r * .8, r * .6)), loaf)
    p.add(p.m(blot), BLIGHT, flat=True)
    p.add(p.m(inter(rell(q[0] + .3, q[1] + .2, r * 1.0, r * .55, 0), loaf)), SNOUT, flat=True)
patch = rect(52, 22, 59, 28)
p.add(p.m(patch), ('#c3b2ea', '#9a8cc0', '#74689a', '#4e3a8a'), local=True, crescent=1)
for x in range(52, 59, 2):
    p.px(x, 22, INK); p.px(x + 1, 27, INK)
p.line([(43, 34), (46, 31)], FUR[3]); p.line([(53, 9), (55, 12)], FUR[3]); p.line([(72, 30), (74, 33)], FUR[3])
for x in range(36, 86, 3):                                     # soft velvet tufts on the belly line
    p.px(x, 38 + (x % 2), FUR[2])

foot('legBN', 42, FUR, 10)
foot('legFN', 77, FUR, 9, big=True)

# head: cheek, long tapering snout blackening to the nose, pink nose button, the long tooth
p = R.part('head')
hx, hy = R.pv('head')
cheek = ell(89, 21, 11, 11)
snout = capsule([(92, 21), (104, 22), (116, 24.5)], 15, 6)
p.add(p.m(cheek, capsule([(hx, hy), (88, 22)], 12, 14)), FUR)
p.add(p.m(minus(snout, ell(86, 20, 9, 11))), SNOUT)
for q in ((96, 19), (100, 25), (95, 26)):                       # where the black creeps into the grey
    p.add(p.m(inter(ell(q[0], q[1], 2, 1.6), cheek)), SNOUT, flat=True)
p.add(p.m(ell(116.5, 24, 3.2, 3)), PAW, local=True)             # pink nose
p.px(117, 23, CREAM)
tooth = capsule([(107.5, 27), (108.5, 35)], 4.6, 3.4)
p.add(p.m(tooth), TOOTH, local=True, crescent=1)
p.line([(107, 30), (109, 32)], TOOTH[3])                        # a crack in the old tooth
p.line([(113, 27), (104, 27.5), (98, 28)], INK)                 # mouth line
for q in ((108, 20), (111, 21), (105, 23)):
    p.px(q[0], q[1], SNOUT[0])                                  # whisker pores
p.line([(112, 25), (118, 30)], SNOUT[0])

# eyes: blind, a milky button with no pupil under a heavy lid
p = R.part('eyes')
ex, ey = R.pv('eyes')
p.add(p.m(ell(ex, ey, 2.6, 2.4)), (INK,) * 4, flat=True)
p.add(p.m(ell(ex, ey + .3, 1.7, 1.5)), ('#cfc8d8',) * 4, flat=True)
p.add(p.m(inter(ell(ex, ey, 2.6, 2.4), lambda x, y: y < ey - .4)), (FUR[2],) * 4, flat=True)
p.line([(ex - 3, ey - 1), (ex + 2, ey - 1.5)], INK)

R.save()
