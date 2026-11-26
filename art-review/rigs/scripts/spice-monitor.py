#!/usr/bin/env python3
"""spice-monitor "Spice Monitor" (snake rig, 91 x 34, 8 parts, medium lv 27, rainforest/island/coast):
"Smells of cinnamon and bad intentions. Its tongue tastes you from across the clearing."
A long, low felt monitor lizard in cinnamon-stick brown: a very long tapering tail dragged along the ground (s1, s2) with cream
rings, a lean body (s3..s5) speckled with rows of cream-and-saffron rosette spots, strong sprawled legs with long claws (hind on
s3, fore on s5), a long slender neck (s6). head = a long flat snake-like head with a nostril near the tip and a long forked pink
tongue flicking out to taste you. eyes = a narrow amber eye under a sly, scheming brow."""
import importlib, math, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from rigkit import *  # noqa
L = importlib.import_module('_lizard_spice-monitor')

R = Rig('spice-monitor')
SIDE = ('#e0a070', '#b86a3a', '#8a4a26', '#5a2e18')       # cinnamon
BACK = ('#b86a3a', '#8a4a26', '#64341c', '#3e2010')
BELLY = PAPER
SAFFRON = '#f5cf6a'
TONGUE = PETAL
TIP = (4.5, 27.6)
W = (2, 6, 9, 10, 9.5, 6.5, 6)


RING = '#f7e6b8'


def band(a, b, t, wid):
    """points of a cross band at fraction t along a->b, wid px wide (perpendicular to the axis)"""
    dx, dy, Ln = L.unit(a, b)
    c = Ln * t
    return lambda x, y: abs((x - a[0]) * dx + (y - a[1]) * dy - c) < wid / 2


def marks(p, pid, cap, a, b, r):
    dx, dy, Ln = L.unit(a, b)
    if pid in ('s1', 's2'):                       # bold cream rings right round the long tapering tail, dark-edged
        for t in ((.18, .42, .66, .88), (.25, .62, .95))[pid == 's2']:
            ring = p.m(inter(cap, band(a, b, t, 1.6 if pid == 's1' else 2.2)))
            p.fill(ring, RING)
            edge = p.m(inter(cap, band(a, b, t + (1.6 if pid == 's1' else 2.2) / Ln, 1.0)))
            p.fill(edge - ring, BACK[2])
        return
    if pid == 's6':                               # a few small speckles up the slim neck
        for t, off in ((.3, -.2), (.65, .05)):
            cx = a[0] + dx * Ln * t - dy * r * off * 2
            cy = a[1] + dy * Ln * t + dx * r * off * 2
            if cap(cx, cy):
                p.px(cx, cy, SAFFRON)
        return
    ts = {'s3': (.05, .4, .75), 's4': (.1, .45, .8), 's5': (.15, .6)}[pid]
    for row, off, col in ((0, -.4, SAFFRON), (1, -.02, CREAM), (2, .32, SAFFRON)):   # rosettes: dark ring round a 2 px cream / saffron dot, staggered rows
        for k, t in enumerate(ts):
            t = t + (.17 if row == 1 else 0)
            if t > .98:
                continue
            cx = int(a[0] + dx * Ln * t - dy * r * off * 2)
            cy = int(a[1] + dy * Ln * t + dx * r * off * 2)
            dot = [(cx, cy), (cx + 1, cy)]
            if not all(cap(x + .5, y + .5) for x, y in dot):
                continue
            for ox, oy in ((-1, 0), (2, 0), (0, -1), (1, -1), (0, 1), (1, 1)):
                if cap(cx + ox + .5, cy + oy + .5):
                    p.px(cx + ox, cy + oy, BACK[3] if row == 0 else SIDE[3] if row == 1 else SIDE[2])
            for x, y in dot:
                p.px(x, y, col)


legs = [('s3', (36, 25), (34, 27.5), 35.5, 2.6, False), ('s3', (32, 25.5), (27, 27.6), 29, 3.0, True),
        ('s5', (48.5, 22.5), (46.5, 26), 47.5, 2.6, False), ('s5', (52.5, 22.5), (49.5, 26), 51.5, 3.0, True)]
P, REF, segs = L.lizard(R, TIP, W, SIDE, BACK, BELLY, legs=legs, pattern=marks, back_band=.25, seam=False)

# head: long flat head on the slim neck, nostril near the tip, forked tongue flicking out
p = R.part('head')
neck = ell(62.3, 13.6, 3.6, 3.6)
skull = poly([(59, 15.5), (62, 9), (67, 6), (72, 6), (80, 9), (81.5, 10.8), (80.5, 12.2), (71, 13.6), (63.5, 16.5)])
tongue = union(capsule([(79.5, 11.6), (85.5, 11.6)], 1.0), capsule([(85, 11.6), (88, 9.8)], .9), capsule([(85, 11.6), (88, 13.4)], .9))
p.add(p.m(tongue), TONGUE, local=True)
p.add(p.m(neck, skull), SIDE)
p.add(p.m(inter(union(neck, skull), lambda x, y: y > 13.4 - (x - 62) * .12)), BELLY)
p.add(p.m(inter(skull, lambda x, y: y < 8.4 + (x - 66) * .2)), BACK, local=True)
p.line([(80, 11.4), (72, 12.3), (67, 13)], INK)                              # the long sly mouth
p.px(66, 13, INK)
p.px(78, 9, BACK[3])                                                          # nostril near the tip
for x, y in ((64, 11), (66, 10), (73, 10), (75, 11)):                         # spice speckles on the cheek
    p.px(x, y, SIDE[2])
p.add(p.m(ell(69, 13.8, 1, .7)), (BLUSH,) * 4, flat=True)

# eyes: a narrow amber eye under a sly, scheming brow
p = R.part('eyes')
L.eyeball(p, 69.5, 7.6, 1.2, '#e8a317', lid=BACK[1], lidcut=7.0)
p.line([(67, 6), (72, 7)], INK)

R.save()
