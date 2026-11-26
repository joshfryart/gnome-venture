#!/usr/bin/env python3
"""sun-lizard "Sun Lizard" (snake rig, 71 x 35, 8 parts, medium lv 8, desert/grassland/rainforest):
"Basks on hot stones and darts at anything that moves."
A slim, quick felt lizard propped up on its long fore legs to catch the sun: a long thin whip tail on the ground (s1..s2) with
orange bars, a sunny yellow body with an orange back stripe and a row of cream sun dots, a little saw-tooth crest on the neck
(s5, s6), tall thin legs with long toes (hind on s3, fore on s5). head = a narrow pointed wedge held high, an orange-red throat
and a small smug smile. eyes = a round amber eye with a half-shut lid, warm and lazy in the sun."""
import importlib, math, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from rigkit import *  # noqa
L = importlib.import_module('_lizard_delta-gharial')

R = Rig('sun-lizard')
SIDE = GOLD
BACK = ('#f5a84a', '#e07a2a', '#b8541a', '#7a3414')
BELLY = PAPER
THROAT = ('#f08a4a', '#dd3a2a', '#a8241f', '#6e2038')
TIP = (3.2, 28.6)
W = (2, 5, 7.5, 8.5, 8, 6.5, 6)
pts = [TIP] + [R.pv(k) for k in L.CHAIN]

# a small saw-tooth crest along the neck and shoulders
crest = {}
for i, pid in ((4, 's5'), (5, 's6')):
    a, b = pts[i], pts[i + 1]
    dx, dy, Ln = L.unit(a, b)
    teeth = []
    for t in (.2, .55, .9):
        w = W[i] + (W[i + 1] - W[i]) * t
        cx, cy = a[0] + dx * Ln * t + dy * w / 2, a[1] + dy * Ln * t - dx * w / 2
        teeth.append(poly([(cx - 1.8, cy + 1.2), (cx + .6, cy - 3.2), (cx + 1.6, cy + 1.2)]))
    crest[pid] = union(*teeth)


def marks(p, pid, cap, a, b, r):
    dx, dy, Ln = L.unit(a, b)
    if pid in ('s1', 's2'):                  # orange bars on the whip tail
        for t in (.3, .7):
            cx, cy = a[0] + dx * Ln * t, a[1] + dy * Ln * t
            p.fill(p.m(inter(cap, rell(cx, cy, .8, r * 1.3, math.degrees(math.atan2(dy, dx)) + 10))), BACK[1])
    else:                                     # cream sun dots in a row along the back stripe
        for t in (.25, .75):
            p.px(a[0] + dx * Ln * t + dy * r * .55, a[1] + dy * Ln * t - dx * r * .55, CREAM)


legs = [('s3', (26, 26), (24.5, 28.5), 25.5, 2.2, False), ('s3', (22, 26), (17, 27.8), 18.5, 2.6, True),
        ('s5', (39, 22.5), (37.5, 26.5), 38, 2.1, False), ('s5', (42.5, 22.5), (41, 26.5), 42, 2.4, True)]
P, REF, segs = L.lizard(R, TIP, W, SIDE, BACK, BELLY, legs=legs, pattern=marks, extra=crest, back_band=.15, seam=False)

# head: a narrow pointed wedge, held high, with an orange-red throat
p = R.part('head')
neck = ell(52.5, 14, 3.8, 3.8)
skull = poly([(49, 15), (51, 9), (56, 6.5), (61, 7), (67.5, 10), (68, 11.8), (60, 14.2), (53.5, 17)])
p.add(p.m(neck, skull), SIDE)
p.add(p.m(inter(union(neck, skull), lambda x, y: y > 14.4 - (x - 50) * .15, lambda x, y: x < 58.5)), THROAT, local=True)
p.add(p.m(inter(skull, lambda x, y: y < 8.6 + (x - 56) * .2)), BACK, local=True)
p.line([(67, 11.5), (62, 12.2), (59, 12.6)], INK)                          # the smile
p.px(58, 12, INK)
p.px(66, 9, BACK[3])                                                         # nostril
p.add(p.m(ell(60.5, 13.6, 1, .8)), (BLUSH,) * 4, flat=True)

# eyes: a round amber eye, lid half shut in the warm sun
p = R.part('eyes')
L.eyeball(p, 59.5, 8.6, 1.1, '#e8a317', lid=BACK[0], lidcut=7.9, pupil='round')
p.line([(57.5, 7), (61, 6.7)], INK)

R.save()
