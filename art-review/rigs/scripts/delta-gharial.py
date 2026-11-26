#!/usr/bin/env python3
"""delta-gharial "Delta Gharial" (snake rig, 115 x 40, 8 parts, large lv 24, wetland):
"A river-bank log with a very long nose and no sense of humour about gnomes on its mud."
A felt gharial lying low like a log on the bank: olive-green back with a row of raised scute bumps from the tail tip to the
shoulders (the knobbly top line is its silhouette), dark bark bands across the tail, cream belly, splayed short legs (hind on s3,
fore on s5, far ones darker behind). head = a small domed skull with the eye turret on top and a very long, thin, needle-toothed
snout ending in the round ghara knob. eyes = a gold slit eye under a heavy olive lid, sitting on the turret."""
import importlib, math, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from rigkit import *  # noqa
L = importlib.import_module('_lizard_delta-gharial')

R = Rig('delta-gharial')
SIDE = OLIVE
BACK = ('#9aa860', '#6b7a3a', '#4f5a2a', '#2f3a18')
BELLY = PAPER
TIP = (17.5, 33.2)
W = (3.5, 7.5, 11, 13, 13, 11, 9)
pts = [TIP] + [R.pv(k) for k in L.CHAIN]

# the scute ridge: little round bumps riding along the top line of every body segment
ridge = {}
for i, pid in enumerate(('s1', 's2', 's3', 's4', 's5')):
    a, b = pts[i], pts[i + 1]
    dx, dy, Ln = L.unit(a, b)
    bumps = []
    for k in range(int(Ln // 3.6) + 1):
        t = (k + .5) * 3.6 / Ln
        if t > 1: break
        w = W[i] + (W[i + 1] - W[i]) * t
        cx, cy = a[0] + dx * t * Ln, a[1] + dy * t * Ln
        bumps.append(ell(cx + dy * (w / 2 + .2), cy - dx * (w / 2 + .2), 1.6, 1.5))
    ridge[pid] = union(*bumps)


def marks(p, pid, cap, a, b, r):
    dx, dy, Ln = L.unit(a, b)
    if pid in ('s1', 's2', 's3'):          # dark bark bands across the tail and hips
        for t in ((.35,), (.25, .75), (.35,))[('s1', 's2', 's3').index(pid)]:
            cx, cy = a[0] + dx * Ln * t, a[1] + dy * Ln * t
            p.fill(p.m(inter(cap, rell(cx, cy, .9, r * 1.2, math.degrees(math.atan2(dy, dx)) + 20), lambda x, y: not below(a, b, -r * .1)(x, y))), BACK[2])
    else:                                   # pale scute dots in a row along the flank
        for t in (.3, .75):
            p.px(a[0] + dx * Ln * t, a[1] + dy * Ln * t - 1, OLIVE[0])


legs = [('s3', (45, 30), (42.5, 32.5), 45, 3.0, False), ('s3', (40, 30), (34.5, 32.8), 36.5, 3.4, True),
        ('s5', (61, 26), (59, 30.5), 61, 2.8, False), ('s5', (66, 26), (62.5, 31), 65, 3.2, True)]
P, REF, segs = L.lizard(R, TIP, W, SIDE, BACK, BELLY, legs=legs, pattern=marks, extra=ridge)

# head: domed skull with the eye turret, then the long thin snout and the ghara knob on its tip
p = R.part('head')
skull = union(ell(79, 15, 6, 5), poly([(74, 18.5), (77, 9.5), (82, 6), (89, 8.5), (91, 12.5), (90, 18), (80, 19)]))
turret = ell(85.6, 6.2, 3.8, 3.2)
upper = capsule([(88, 13.2), (108, 13.6)], 4.2, 3.4)
lower = capsule([(84, 17), (108.5, 16.2)], 3.4, 2.6)
knob = ell(110.2, 13.4, 2.8, 2.6)
p.add(p.m(skull, turret, upper, lower, knob), SIDE)
p.add(p.m(inter(union(skull, lower), lambda x, y: y > 15.6)), BELLY)
p.add(p.m(inter(union(skull, turret, upper), lambda x, y: y < 11.5)), BACK)
p.add(p.m(knob), BACK, local=True)
p.line([(108, 15), (95, 15), (88, 15.6), (83, 16.6)], INK)                    # the long grin
for x in range(89, 108, 2):
    p.px(x, 16 if x % 4 == 1 else 14, CREAM)                                  # needle teeth, up and down
p.px(111, 12, BACK[3]); p.px(112, 13, BACK[3])                               # nostrils on the knob
p.line([(80, 9), (80, 17)], BACK[2])                                          # neck seam
p.add(p.m(ell(83, 17.6, 1.2, .9)), (BLUSH,) * 4, flat=True)

# eyes: gold slit eye under a heavy lid, on top of the turret
p = R.part('eyes')
L.eyeball(p, 85.8, 4.9, 1.8, '#f5cf6a', lid=BACK[1], lidcut=4.0)
p.line([(83, 3), (88, 3.5)], INK)

R.save()
