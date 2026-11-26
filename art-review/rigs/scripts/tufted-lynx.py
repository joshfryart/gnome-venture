#!/usr/bin/env python3
"""tufted-lynx "Tufted Lynx" (quad.feline rig, 71 x 55, 8 parts): "Tufted ears, soft paws and a way of being suddenly on your path." (forest, mountain; lv 23; Spotted Pelt, Bushy Tuft)
A lynx in grey-fawn felt: a short body that rises to high hindquarters (the opposite slope of the hyena), long legs on big soft
snowshoe paws, faint umber freckles, a cream belly. A stubby bobtail with an umber tip (tail, sprung up-left). A round head with tall
pointed ears ending in long umber tufts (the lynx's mark), a big cream side ruff hanging down the cheeks in sewn points, a cream
muzzle and a pink nose; a gold-green eye (eyes)."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from rigkit import *  # noqa
from _quad_savanna_hyena import leg, eye_round

R = Rig('tufted-lynx')
COAT = ('#f1ece0', '#cdb898', '#a08868', '#6a5648')
FAR = darker(COAT)
FRECK = '#7a6248'
CRM = ('#fff3c8', '#f2e4c0', '#d8c8a8', '#a08868')
TUFT = ('#6a5648', '#4a2c1a', '#2a1a10', '#2a1a10')


def freckles(p, pts, clip):
    for x, y in pts:
        p.fill(p.m(inter(ell(x, y, 1.1, 1), clip)), FRECK)


# far legs: long, big round paws
leg(R, 'legBF', 25.5, FAR, 7.5, 5.5, knee=(27, 42), paw=(4.6, 3))
leg(R, 'legFF', 51, FAR, 6.5, 5.5, paw=(4.6, 3))

# tail: a stubby bobtail flicked up, umber tip
p = R.part('tail')
p.add(p.m(capsule([(16, 27.5), (11.5, 24), (9.5, 21.5)], 6, 5.5)), COAT)
p.add(p.m(inter(ell(9.5, 21, 3.4, 3.2), capsule([(16, 27.5), (11.5, 24), (9.5, 21.5)], 6, 5.5))), TUFT, flat=True)

# body: short, high round rump, lower chest, cream belly, freckles
p = R.part('body')
torso = union(ell(23, 26.5, 10.5, 9.5), ell(45, 29.5, 9, 7.5), poly([(23, 17.5), (45, 22.5), (47, 36.5), (22, 36)]))
p.add(p.m(torso), COAT, stitch=True)
p.add(p.m(inter(torso, lambda x, y: y > 34.5 - (x - 20) * .04)), CRM)
freckles(p, [(17, 24), (21, 21), (25, 25), (29, 22), (33, 26), (37, 24.5), (41, 28), (20, 29.5), (28, 30), (36, 31)], torso)

# near legs over the body: a round haunch on the hind leg
p, m = leg(R, 'legBN', 20.5, COAT, 8, 5.8, knee=(22.5, 42), paw=(4.8, 3.1))
p.add(p.m(inter(ell(19, 32, 6, 6), lambda x, y: y > 26)), COAT)
p.edge(p.m(ell(19, 32, 6, 6)), COAT[2], sides=((0, -1), (-1, 0)))
freckles(p, [(17, 31), (21, 35), (19, 40)], lambda x, y: True)
p, m = leg(R, 'legFN', 45.5, COAT, 7, 5.8, paw=(4.8, 3.1))
freckles(p, [(44, 38), (46, 42)], lambda x, y: (int(x), int(y)) in m)

# head: tall tufted ears, round skull, sewn cream ruff, cream muzzle
p = R.part('head')
earL = poly([(49.5, 15), (51.5, 7), (53.5, 5.5), (56, 13)])
earR = poly([(56.5, 12), (59.5, 4.5), (61.5, 6), (63, 13.5)])
p.add(p.m(earL, earR), COAT, local=True)
p.add(p.m(union(poly([(51.5, 13), (52.5, 8.5), (54, 12.5)]), poly([(58.5, 12), (60, 7.5), (61, 12.5)]))), (PETAL[2],) * 4, flat=True)
tufts = union(capsule([(53, 7), (52, 2)], 2.2, 1.4), capsule([(60.5, 6), (61.5, 1.5)], 2.2, 1.4))
p.add(p.m(tufts, inter(union(earL, earR), lambda x, y: y < 8.5)), TUFT, flat=True)
skull = union(ell(57, 17.5, 8, 7), capsule([R.pv('head'), (53, 20)], 10, 10))
ruff = poly([(49.5, 20), (50.5, 31), (53.5, 27), (55.5, 32), (58, 27.5), (61, 31), (62, 25.5), (61.5, 22.5), (57, 21), (53, 22.5)])
p.add(p.m(skull), COAT)
p.add(p.m(ruff), CRM, local=True)
p.line([(52, 24), (53.5, 28)], CRM[3]); p.line([(57, 24), (58, 28)], CRM[3])      # ruff seams
p.add(p.m(ell(63.5, 21, 4, 3.2)), CRM)                                                     # muzzle
p.add(p.m(ell(66.5, 19.2, 1.5, 1.1)), (PETAL[2], PETAL[2], PETAL[3], PETAL[3]), flat=True)
p.line([(66.5, 20.5), (65.5, 22.5), (63.5, 23)], TUFT[1])                                   # mouth
p.line([(55, 13.5), (57, 12.5)], FRECK); p.line([(54, 16), (55.5, 15.5)], FRECK)
p.line([(62.5, 16), (62.5, 14)], FRECK)          # brow stripes
p.px(62, 21, FRECK); p.px(63, 22, FRECK)

p = R.part('eyes')
eye_round(p, 60, 18.4, '#a8c05a', r=2.3, ry=2.1)

R.save()
