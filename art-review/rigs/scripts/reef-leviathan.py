#!/usr/bin/env python3
"""reef-leviathan "Reef Leviathan" (snake rig, 135 x 79, 9 parts, boss lv 29, coast): "An eel as long as a village street." (Eel Skin,
Sea Glass, Pearl)
A colossal sea serpent in deep-sea navy felt with a sea-glass green belly: a broad fan tail fin standing up off the sand (s1); a huge
body (s2..s5) with a dark back, pale sea-glass speckles and a dashed belly seam, carrying tall webbed sail fins of sea-glass felt with
dark rays and spine tips (s3..s5); a thick neck (s6). hood = a big three-spined webbed crest flaring up behind the head (the strike
pose fans it). head = a long heavy serpent head, a cruel grin with fangs hanging over the lip, cream barnacles crusted on the snout
and two drooping whisker barbels from the chin. eyes = a pale glowing sea-glass eye with a slit pupil under a heavy brow.
Silhouette: long, sailed and crested, with a tall tail fan; the eel lord is a smaller olive moray with a coral crown."""
import importlib, math, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from rigkit import *  # noqa
S = importlib.import_module('_snake_grass-snake')
ALL = S.ALL

R = Rig('reef-leviathan')
SIDE = ('#6aa8c8', '#3a7aa0', '#285a7e', '#183a5a')
BACK = ('#3a6a90', '#2a4e74', '#1e3a5a', '#122640')
BELLY = ('#e8fbf2', '#bfe8dc', '#88c8b8', '#4a8a80')
FIN = ('#d8f8f0', '#8fdcd0', '#4fa8a8', '#2a6a78')
BARN = ('#ffffff', '#f2e4c0', '#c9b58e', '#8b7a5a')
TIP = (17, 68)
W = (10, 19, 23, 25, 25, 23, 20)
MID = {'s3': (54.5, 63), 's5': (83, 53.5)}
SAILS = {'s3': (.2, .85, 11), 's4': (.15, .85, 13), 's5': (.1, .65, 14)}


def marks(p, pid, shape, a, b, r):
    dx, dy, L = S.unit(a, b)
    nx, ny = -dy, dx
    if pid in SAILS:                                  # a webbed sail fin with dark rays and pale spine tips
        t0, t1, h = SAILS[pid]
        base = [(a[0] + dx * L * t - nx * (r - 1.5), a[1] + dy * L * t - ny * (r - 1.5)) for t in (t0, (t0 + t1) / 2, t1)]
        tips = [(x - nx * h - dx * 4, y - ny * h - dy * 4) for x, y in base]
        sail = poly([base[0], tips[0], ((tips[0][0] + tips[1][0]) / 2 + nx * 2.5, (tips[0][1] + tips[1][1]) / 2 + ny * 2.5), tips[1],
                     ((tips[1][0] + tips[2][0]) / 2 + nx * 2.5, (tips[1][1] + tips[2][1]) / 2 + ny * 2.5), tips[2], base[2]])
        p.add(p.m(sail, minus=[shape]), FIN, local=True, crescent=1)
        sm = p.layers[-1][0]
        for (bx, by), (tx, ty) in zip(base, tips):
            p.fill({q for q in p.m(capsule([(bx, by), (tx, ty)], 1.2)) if q in sm}, FIN[3])
            p.px(tx, ty + .5, FIN[0])
    for t, off in ((.3, -.15), (.65, .05), (.5, -.5)):   # pale sea-glass speckles
        x, y = a[0] + dx * L * t + nx * off * r, a[1] + dy * L * t + ny * off * r
        p.px(x, y, SIDE[0])


P, REF, out = S.snake(R, TIP, W, SIDE, BACK, BELLY, mid=MID, pattern=marks, back_band=.3, belly_band=.52, seam=SIDE[2], belly_stitch=BELLY[3])

# s1: the broad fan tail fin standing up off the sand
p = R.part('s1')
fan = poly([(24, 63), (4, 43), (8, 54), (13, 62), (3, 73), (24, 72)])
p.add(p.m(fan, minus=[lambda x, y: y >= R.ground + 1]), FIN, local=True)
for q in ((5, 44.5), (8, 56), (4, 72)):
    p.line([(19, 66), q], FIN[3])

# hood: the three-spined webbed crest behind the head
p = R.part('hood')
C0 = (92, 31)
spines = [(80, 8), (88, 3), (97, 7)]
web = poly([(86, 36), (78, 7), (84, 10.5), (88, 2.5), (92, 9), (97.5, 6), (98, 30)])
p.add(p.m(web, ell(C0[0], C0[1], 6, 6)), FIN, stitch=FIN[2])
for q in spines:
    p.fill(p.m(inter(web, capsule([C0, q], 1.6))), FIN[3])
    p.px(q[0] + .5, q[1] + 1.5, FIN[0])

# head: long heavy serpent head, fanged grin, barnacles, barbels
p = R.part('head')
hp = P['head']
skull = union(capsule([hp, (102, 25)], 18, 21), poly([(97, 15), (110, 13.5), (123, 20), (126, 27), (121, 32), (100, 35)]))
jaw = poly([(96, 37), (104, 32), (120, 31), (121, 34), (110, 38.5), (98, 41)])
p.add(p.m(skull, jaw), SIDE)
p.add(p.m(inter(skull, lambda x, y: y < 18.5 + (x - 96) * .2)), BACK)
p.add(p.m(inter(jaw, lambda x, y: y > 36 - (x - 100) * .12)), BELLY, local=True)
p.line([(101, 33), (108, 31.5), (121, 30.5)], INK)                                     # the long grin
for x in (110, 114, 118):                                                              # fangs over the lip
    p.px(x, 31.5, CREAM); p.px(x, 32.5, CREAM)
for x in (106, 112, 116):
    p.px(x, 30.5, CREAM)
for x, y, r in ((116, 21, 1.6), (119.5, 23.5, 1.2), (112.5, 19, 1.1)):               # barnacles on the snout
    p.add(p.m(ell(x, y, r + .4, r)), BARN, local=True, crescent=0)
    p.px(x, y - .5, BARN[3])
p.px(122, 25, BACK[3])                                                                 # nostril
p.add(p.m(capsule([(110, 36.5), (111, 41), (108, 45), (104, 46)], 1.8, 1.1), capsule([(116, 34.5), (119, 38.5), (119, 42.5)], 1.8, 1.1)), BACK, local=True, flat=True)

# eyes: pale glowing sea-glass eye, slit pupil, heavy brow
p = R.part('eyes')
S.eyeball(p, 107, 22.1, 2.6, '#c8f8e8', lid=BACK[2], lidcut=20.4, pupil='round')
p.line([(103, 18.6), (111, 20.6)], INK)

R.save()
