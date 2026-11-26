#!/usr/bin/env python3
"""grass-snake "Grass Snake" (snake rig, 87 x 53, 8 parts, large lv 14, grassland/wetland/rainforest/desert): "A green river of scales. Do not stand still."
A slim felt grass snake in olive green, lying in an S along the ground and rearing its neck: tail tip flat on the grass (s1), a long
slender body (s2..s5) with a row of short black side bars and a cream belly edged with the black chequers it shows when it plays
dead, a lifted neck (s6). head = a neat oval olive head with cream lip scales, the famous bright yellow collar with the black
crescent behind it, and a red forked tongue flicking out. eyes = a round gold eye with a round pupil (a harmless snake)."""
import importlib, math, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from rigkit import *  # noqa
S = importlib.import_module('_snake_grass-snake')
ALL = S.ALL

R = Rig('grass-snake')
SIDE = ('#b9c47e', '#8d9a4e', '#66742f', '#3e4820')
BACK = ('#9aa65a', '#7a8740', '#56632a', '#363f1b')
BELLY = ('#fff6d2', '#f1e9bd', '#cfc48c', '#8a8048')
BAR = '#161a0c'
BLACK = '#111111'
COLLAR = ('#fff1a0', '#ffd02a', '#eaa810', '#b87a0c')
TIP = (3.5, 46.5)
W = (2, 6.5, 8, 8.5, 8.5, 8, 7.5)
MID = {'s2': (22.5, 45.2), 's3': (33.5, 37.2), 's4': (44, 42.6), 's5': (53.5, 32.5), 's6': (61.5, 23.5)}


def marks(p, pid, shape, a, b, r):
    dx, dy, L = S.unit(a, b)
    nx, ny = -dy, dx
    ts = {'s1': (.35, .75), 's6': (.25, .7)}.get(pid, (.2, .5, .8))
    for t in ts:                                            # short black bars down the flank, alternating long/short
        cx, cy = a[0] + dx * L * t, a[1] + dy * L * t
        lo = .15 if t != .5 else -.15
        bar = capsule([(cx - nx * r * .95, cy - ny * r * .95), (cx + nx * r * lo, cy + ny * r * lo)], 1.2)
        p.fill(p.m(inter(bar, shape)), BAR)
    if pid != 's6':                                         # black chequers along the belly edge
        for t in ((.5,) if pid == 's1' else (.3, .75)):
            cx, cy = a[0] + dx * L * t + nx * r * .7, a[1] + dy * L * t + ny * r * .7
            p.fill(p.m(inter(rect(cx - 1, cy - .6, cx + 1, cy + 1.4), shape)), BAR)


P, REF, out = S.snake(R, TIP, W, SIDE, BACK, BELLY, mid=MID, pattern=marks, back_band=.3, belly_band=.5, seam=SIDE[2], belly_stitch=BELLY[2])

# head: neat oval olive head on the neck, cream lips, bright yellow collar with a black crescent behind it, red forked tongue
p = R.part('head')
hp = P['head']
neck = capsule([hp, (69, 13)], 8, 8)
skull = union(ell(74, 11.3, 7.6, 5.3), rell(79, 12.4, 4.6, 3.6, 8))
shape = union(neck, skull)
p.add(p.m(shape), SIDE)
p.add(p.m(inter(shape, lambda x, y: y < 9.8 - (x - 74) * .06)), BACK)
lip = inter(skull, lambda x, y: y > 13.4 and x > 71)
p.add(p.m(lip), BELLY, local=True)
p.line([(82, 13), (78, 13.6), (73, 14.4)], SIDE[3])                       # mouth seam
for x in (75, 78, 81):
    p.px(x, 15, BELLY[2])                                                   # lip scale stitches
O = (74.5, 11.6)
behind = lambda x, y: x < 71.5
yel = inter(shape, behind, rell(O[0], O[1], 10.8, 8.2, -20), minus(ALL, rell(O[0], O[1], 7.4, 5.4, -20)))
blk = inter(shape, behind, rell(O[0] - .8, O[1] + .4, 13.4, 10.4, -20), minus(ALL, rell(O[0], O[1], 10.8, 8.2, -20)))
p.add(p.m(yel), COLLAR, local=True)
p.add(p.m(blk), (BLACK,) * 4, flat=True)
p.px(82, 11, BACK[3])                                                       # nostril
p.add({(83, 14), (84, 14), (85, 13), (85, 15)}, ('#e0301f',) * 4, flat=True)                    # thin red forked tongue

# eyes: round gold eye, round black pupil, olive brow scale
p = R.part('eyes')
p.add(p.m(ell(73.4, 9.8, 2.6, 2.6)), (INK,) * 4, flat=True)
p.add(p.m(ell(73.4, 9.8, 1.8, 1.8)), ('#f5c84a',) * 4, flat=True)
p.add(p.m(rect(73, 9, 75, 11)), (BLACK,) * 4, flat=True)
p.px(72, 9, '#ffffff')
p.add(p.m(inter(ell(73.4, 9.8, 2.6, 2.6), lambda x, y: y < 8)), (BACK[2],) * 4, flat=True)

R.save()
