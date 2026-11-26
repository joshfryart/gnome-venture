#!/usr/bin/env python3
"""dung-beetle "Dung Beetle" (bug.beetle rig, 71 x 35, 9 parts): "Rolls a ball three times its size, and will roll you too." (grassland, desert; Beetle Shell, Dung Ball)
A low, wide scarab in deep indigo felt, the flat heavy one of the batch, head down and shoving its ball: a broad domed back sewn
as two wing cases and a front shield (pronotum), with stitched grooves and a teal sheen (body), a spade head with a toothed
shovel rim and a stubborn brow (head), one button eye (eyes), two short clubbed feelers (antL far / antR near), three spiny
digging legs braced wide (leg1..leg3), and the big round dung ball in front of it, brown felt with straw bits and a sprouting
seedling on top (ball: under the body, pivot where the head pushes it; the 'ball' spring bobs it)."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from rigkit import *  # noqa

R = Rig('dung-beetle')
P = {k: R.pv(k) for k in R.ids}
BEET = ('#a09cd2', '#6e6aa6', '#4c487c', '#322e58')
LEGC = ('#6e6aa6', '#504c82', '#38345e', '#38345e')
DUNG = ('#c9a96e', '#9a6b3f', '#74462a', '#4a2c1a')
SHEEN = '#7fc8b8'

# legs: spiny, braced wide
for pid, pts in (('leg1', [(26.5, 18), (21, 23), (19.5, 29)]),
                 ('leg2', [(34.5, 18), (38.5, 23.5), (37, 29)]),
                 ('leg3', [(42.5, 18), (48.5, 22.5), (53.5, 29)])):
    p = R.part(pid)
    p.add(p.m(capsule(pts, 3, 2.2)), LEGC, crescent=0)
    kx, ky = pts[1]
    p.add(p.m(ell(kx, ky - .3, 1.8, 1.5)), LEGC, local=True, crescent=0)                       # knee
    fx, fy = pts[2]
    for t in (.35, .7):                                                                         # spines on the shin
        sx, sy = kx + (fx - kx) * t, ky + (fy - ky) * t
        p.add(p.m(capsule([(sx, sy), (sx + (1.8 if pid == 'leg3' else -1.8), sy - .6)], 1)), LEGC, local=True, flat=True)

# ball: the dung ball, straw bits, a seedling
p = R.part('ball')
bx, by, br = 62.6, 22.6, 6.9
p.add(p.m(ell(bx, by, br, br), capsule([P['ball'], (58, 23)], 2)), DUNG, stitch=DUNG[3])
for a, b in (((59, 19), (60, 20)), ((64, 21), (66, 21)), ((61, 25), (62, 26)), ((65, 26), (66, 25)), ((66, 18), (67, 19))):
    p.line([a, b], GOLD[0])                                                                     # straw bits
for q in ((65, 19), (61, 23), (67, 26)):
    p.px(q[0], q[1], DUNG[3])
p.add(p.m(capsule([(63, 16.5), (63.5, 13)], 1.2)), MOSS, local=True, flat=True)               # seedling stem
p.add(p.m(ell(61.5, 12.6, 1.8, 1.1), ell(65.3, 12, 1.8, 1.1)), MOSS, local=True)              # two leaves

# body: domed back, two wing cases + pronotum
p = R.part('body')
back = union(rell(30.6, 12.4, 14.6, 9.6, 2), capsule([(24, 19), (44, 19.5)], 3.4))
p.add(p.m(back), BEET)
pro = inter(back, ell(45, 14.5, 7.8, 8.6))
p.add(p.m(pro), BEET, local=True)                                                                # pronotum, sewn on
p.edge(p.m(pro), BEET[3], sides=((-1, 0),))
for k, y0 in enumerate((7.5, 12)):                                                        # stitched grooves
    for x in range(19 + k * 2, 37, 3):
        y = y0 + ((x - 28) / 14.0) ** 2 * 4
        p.px(x, y, BEET[3])
p.line([(22, 5), (27, 3.5), (33, 3.5)], SHEEN)                                                  # teal sheen
p.px(42, 8, SHEEN); p.px(43, 8, SHEEN)

# head: spade head with a toothed shovel, stubborn brow
p = R.part('head')
hd = union(ell(49.2, 18, 5.6, 4.8), capsule([P['head'], (46, 17.5)], 5, 5))
p.add(p.m(hd), BEET)
shovel = poly([(50, 18.5), (56.8, 18.2), (57.6, 20.6), (56.2, 21.4), (55.6, 22.8), (53, 23.2), (49.5, 22)])
p.add(p.m(shovel), LEGC, local=True)                                                             # shovel rim
p.px(56, 22, BEET[3]); p.px(54, 23, BEET[3])
p.line([(47, 13.5), (51, 13)], BEET[3])                                                          # brow

p = R.part('eyes')
ex, ey = 50.3, 15.7
p.add(p.m(ell(ex + .2, ey + .6, 2.3, 2.1)), (INK,) * 4, flat=True)
p.add(p.m(ell(ex + .2, ey + .6, 1.4, 1.3)), (CREAM,) * 4, flat=True)
p.add(p.m(rect(51, 15, 52, 17)), (INK,) * 4, flat=True)

# feelers: short, clubbed
for pid, pts, ramp in (('antL', [(48.5, 13.6), (47.5, 9), (49, 6)], darker(LEGC)),
                       ('antR', [(51.5, 13.6), (54, 10), (57.5, 9)], LEGC)):
    p = R.part(pid)
    tx, ty = pts[-1]
    p.add(p.m(capsule(pts, 1.6, 1.4), ell(tx + .4, ty - .3, 1.9, 1.5)), ramp, crescent=0)

R.save(floating=('ball',))
