#!/usr/bin/env python3
"""sand-viper-matriarch "Sand Viper Matriarch" (snake rig, 87 x 56, 9 parts, large lv 31, desert): "Hidden in the dune until the moment you step on her dinner."
The mother of all sand vipers, in heavy rust-and-sand felt: thick coils lying along the dune (s1..s4) with the adder's dark zigzag
chain of diamonds stitched down her back and a cream belly, rising into a stout neck (s5, s6). hood = her crown: a fan of raised,
cream-tipped horn scales standing up behind the head like a matriarch's spiked crown (the strike pose flares it wide).
head = a broad arrowhead viper head, mouth open on two long cream fangs, a heat pit below the eye, a pink tongue.
eyes = a fierce gold slit eye under a heavy scaled brow."""
import importlib, math, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from rigkit import *  # noqa
S = importlib.import_module('_snake_grass-snake')
ALL = S.ALL

R = Rig('sand-viper-matriarch')
SIDE = ('#f6d29a', '#e2a868', '#c07c46', '#7a4a26')        # sand flanks
BACK = ('#e08a4c', '#c0652f', '#93441f', '#5e2414')        # rust back
BELLY = ('#fffbe8', '#fff3c8', '#ecd2a0', '#c9a96e')
RIM = '#fff3c8'
ZIG = '#3e1a10'                                           # the dark diamonds
HORN = ('#e08a4c', '#c0652f', '#93441f', '#5e2414')
TIP = (3.5, 49.4)
W = (3, 10, 12, 13, 13, 11.5, 10)
MID = {'s2': (22.5, 46), 's4': (44.5, 43.6)}
NDIA = {'s1': 1, 's2': 2, 's3': 2, 's4': 2, 's5': 2, 's6': 2}


def marks(p, pid, shape, a, b, r):
    """the adder chain: dark cream-rimmed diamonds touching tip to tip down the middle of the back"""
    dx, dy, L = S.unit(a, b)
    nx, ny = -dy, dx
    n = NDIA[pid]
    ang = math.degrees(math.atan2(dy, dx))
    ra = L / (2 * n) + .4
    rb = r * .62
    off = r * .28
    for k in range(n):
        t = (k + .5) / n
        if pid == 's1':
            t = .62
        cx, cy = a[0] + dx * L * t - nx * off, a[1] + dy * L * t - ny * off
        rr = ra if pid != 's1' else 2.6
        bb = rb if pid != 's1' else 2.2
        p.add(p.m(inter(shape, S.diamond(cx, cy, rr + 1.1, bb + 1.1, ang))), (RIM,) * 4, flat=True)
        p.add(p.m(inter(shape, S.diamond(cx, cy, rr, bb, ang))), (ZIG,) * 4, flat=True)
        p.px(cx, cy, BACK[2])                                 # a rust heart in each diamond
        # dark side blotches low on the flank between diamonds
        if pid != 's1':
            sx, sy = a[0] + dx * L * (t + .5 / n) + nx * r * .3, a[1] + dy * L * (t + .5 / n) + ny * r * .3
            if t + .5 / n < 1.0:
                p.add(p.m(inter(shape, ell(sx, sy, 1.3, 1.1))), (BACK[3],) * 4, flat=True)


P, REF, out = S.snake(R, TIP, W, SIDE, BACK, BELLY, mid=MID, pattern=marks, back_band=.05, belly_band=.42, seam=SIDE[2], belly_stitch=BELLY[3])

# hood = her crown: a fan of separate horn scales standing up behind the head (rust, cream tips)
p = R.part('hood')
C0 = (60.5, 15.5)
base = union(ell(C0[0], C0[1], 4.2, 4.2), ell(61.6, 19.5, 4, 3.5))
spikes = []
for g, L in ((184, 14), (210, 16.5), (236, 16.5), (262, 14.5), (288, 13)):
    gr = math.radians(g)
    ux, uy = math.cos(gr), math.sin(gr)
    vx, vy = -uy, ux
    root = (C0[0] + ux * 3, C0[1] + uy * 3)
    tip = (C0[0] + ux * L, C0[1] + uy * L)
    mid = (C0[0] + ux * (L - 5), C0[1] + uy * (L - 5))
    spikes.append((poly([(root[0] + vx * 2.4, root[1] + vy * 2.4), (mid[0] + vx * 2.1, mid[1] + vy * 2.1), tip,
                         (mid[0] - vx * 2.1, mid[1] - vy * 2.1), (root[0] - vx * 2.4, root[1] - vy * 2.4)]), tip, (ux, uy)))
fan = union(base, *[s for s, _, _ in spikes])
p.add(p.m(fan), HORN, local=True)
for s, tip, (ux, uy) in spikes:
    p.add(p.m(inter(s, lambda x, y, t=tip, u=(ux, uy): (x - t[0]) * -u[0] + (y - t[1]) * -u[1] < 4.2)), ('#ffffff', CREAM, '#f2e4c0', '#c9a96e'), local=True)   # cream tip
    p.line([(C0[0] + ux * 6.5, C0[1] + uy * 6.5), (tip[0] - ux * 5, tip[1] - uy * 5)], HORN[3])                              # a centre rib

# head: broad arrowhead, mouth gaping open on two long fangs, heat pit, eye stripe, tongue
p = R.part('head')
hp = P['head']
neck = capsule([hp, (67, 17)], 10, 10.5)
upper = poly([(61, 13.5), (65.5, 9), (75, 8.4), (82.5, 11.4), (84.2, 14.2), (76, 15.8), (66, 17.6)])
lower = poly([(64, 21.4), (72, 22), (79.5, 24.6), (78.5, 26.8), (70, 26.2), (63, 25.2)])
shape = union(neck, upper, lower)
p.add(p.m(shape), SIDE)
p.add(p.m(inter(upper, lambda x, y: y < 11.6)), BACK)
p.add(p.m(lower), BELLY, local=True)
gap = poly([(67, 17.2), (84.2, 14.4), (83, 16.2), (80.5, 24.4), (72.5, 22), (67, 20.5)])
p.add(p.m(minus(gap, lower)), ('#7d2c5e', '#6e2038', '#5a1f44', '#4a1838'), flat=True)
for fx, top in ((74.5, 16.2), (80, 15.2)):                             # two long fangs hanging from the upper jaw
    p.fill(p.m(inter(minus(gap, lower), poly([(fx - 1.2, top - 1), (fx + 1.8, top - 1.2), (fx + 1.0, top + 7), (fx + .1, top + 7)]))), CREAM)
p.px(82, 12, ZIG)                                                       # nostril
p.add(p.m(ell(78.2, 13.8, .9, .8)), (ZIG,) * 4, flat=True)              # heat pit
p.add(p.m(inter(upper, rell(66.5, 14.6, 5.5, 1.0, -10))), (ZIG,) * 4, flat=True)   # dark stripe behind the eye
for (cx, cy) in ((61.5, 21.5),):                             # the chain carries on up the neck and crown
    p.add(p.m(inter(shape, S.diamond(cx, cy, 3.1, 2.6))), (RIM,) * 4, flat=True)
    p.add(p.m(inter(shape, S.diamond(cx, cy, 2.0, 1.6))), (ZIG,) * 4, flat=True)
S.tongue(p, (79, 22), 4, col=PETAL[2], up=0)

# eyes: fierce gold slit eye under a heavy brow
p = R.part('eyes')
S.eyeball(p, 72.6, 12.4, 2.2, '#f5cf6a', lid=BACK[2], lidcut=11.2)
p.line([(69, 9.6), (76, 11.4)], INK)

R.save()
