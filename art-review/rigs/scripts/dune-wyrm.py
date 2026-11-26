#!/usr/bin/env python3
"""dune-wyrm "Dune Wyrm" (snake rig, 117 x 84, 9 parts, boss lv 30, desert): "The sand ripples. Then the sand stands up."
A colossal ringed sand wyrm in sandstone felt, rearing out of the dune: a blunt tail tip half sunk in a drift of sand with wind
ripples (s1), a huge body (s2..s5) of thick armour rings, alternating ochre and sandstone bands with dark sewn grooves and a pale
belly under a dashed seam, a massive neck (s6). hood = a mane of big round sandstone plates flaring behind the head like a collar
of stones, two-toned with sewn seams, sand trickling off them (the strike pose flares it). head = a blunt armoured head with
heavy brow plates and ring grooves, its huge maw gaping wide open on rows of cream fangs and a dark throat.
eyes = a small, deep-set ember eye under the heavy brow."""
import importlib, math, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from rigkit import *  # noqa
S = importlib.import_module('_snake_grass-snake')
ALL = S.ALL

R = Rig('dune-wyrm')
SIDE = ('#f8e0a8', '#e8c47e', '#bc9250', '#7a5226')       # sandstone band
RING = ('#e49a44', '#c47a2c', '#925420', '#5e3416')       # ochre band
BACK = ('#e6bc70', '#d0a256', '#9a6e34', '#6a4620')
BELLY = ('#fff3c8', '#f2e4c0', '#d8c08a', '#9a7a4a')
GROOVE = '#4a2812'
PLATE = ('#f8e2b0', '#e6c88e', '#b8925a', '#6a4e30')       # pale sandstone plate
PLATE2 = ('#e8a858', '#c8863c', '#98602a', '#5e3a1a')      # its darker ochre half
SAND = '#fff3c8'
TIP = (6, 74)
W = (8, 17, 21, 24, 26, 25, 22)
MID = {'s2': (30.5, 70.5), 's3': (45.5, 69.5), 's4': (59.5, 68)}


def marks(p, pid, shape, a, b, r):
    dx, dy, L = S.unit(a, b)
    n = 1
    for k in range(n):                                    # the armour rings: an ochre band, a pale lip and a dark sewn groove per ring
        V0, V1 = -r, (L - r * .8 if pid != 's6' else L * .6)   # the span of this segment the next one leaves visible
        t0 = V0 + k * (V1 - V0) / n; t1 = t0 + .5 * (V1 - V0) / n
        p.add(p.m(inter(shape, S.along(a, b, t0, t1), minus(ALL, below(a, b, r * .45)))), RING, ref=p.REF)
        p.fill(p.m(inter(shape, S.along(a, b, t1, t1 + 1.6))), GROOVE)
        p.fill(p.m(inter(shape, S.along(a, b, t1 + 1.6, t1 + 2.4))), SIDE[0])
        g = sorted(p.m(inter(shape, S.along(a, b, t1 + .3, t1 + 1.3))), key=lambda q: (q[1], q[0]))
        p.fill({q for i, q in enumerate(g) if i % 4 == 1}, BELLY[2])     # cross stitches over the groove
    for t in (.3, .75):                                   # sand speckles on the back
        cx, cy = a[0] + dx * L * t + dy * r * .55, a[1] + dy * L * t - dx * r * .55
        p.px(cx, cy, SAND)


P, REF, out = S.snake(R, TIP, W, SIDE, BACK, BELLY, mid=MID, pattern=marks, back_band=.45, belly_band=.45, seam=SIDE[3], belly_stitch=BELLY[3])
p = R.part('s1')                                          # the drift of sand the tail is still half buried in
drift = inter(union(ell(10.5, 77.5, 9, 6), ell(21, 79.5, 9, 4)), lambda x, y: y < R.ground + 1)
DRIFT = ('#fff3c8', '#f0d8a0', '#d4b47a', '#a8844e')
p.add(p.m(drift), DRIFT, local=True)
for y, x0, x1 in ((74, 6, 10), (76, 3, 7), (77, 12, 17), (78, 21, 26)):   # wind ripples in the drift
    p.line([(x0, y), (x1, y)], DRIFT[2])

# hood: a mane of big round sandstone plates fanned behind the head
p = R.part('hood')
C0 = (83, 33)
core = ell(C0[0], C0[1], 12, 12)
p.add(p.m(core), PLATE2)
PL = ((118, 15, 7.5), (152, 17, 8.5), (186, 18, 9), (220, 18, 9), (254, 18, 9), (288, 17, 8.5), (318, 15, 7))
masks = []
for k, (ang, ln, rr) in enumerate(PL):
    a = math.radians(ang)
    c = (C0[0] + math.cos(a) * ln, C0[1] + math.sin(a) * ln)
    disc = ell(c[0], c[1], rr, rr)
    m = p.m(disc)
    p.add(m, PLATE2, local=True)
    # two-toned: the upper half of each plate is pale sandstone, the lower half ochre
    p.add(p.m(inter(disc, lambda x, y, c=c: y < c[1] + .5 + (x - c[0]) * .35)), PLATE, local=True)
    masks.append((m, c, a, rr))
sil = p.m(core).union(*[m for m, _, _, _ in masks])
for i, (m, c, a, rr) in enumerate(masks):
    vis = m - set().union(*[q for q, _, _, _ in masks[i + 1:]])
    # a dark seam where this plate lies on the earlier ones / the core
    p.fill({q for q in vis if any((q[0] + dx, q[1] + dy) in sil and (q[0] + dx, q[1] + dy) not in vis for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)))}, PLATE[3])
    # a dashed sewn seam across the plate where its two felt halves meet
    seam = {q for q in vis if abs(q[1] + .5 - (c[1] + .5 + (q[0] + .5 - c[0]) * .35)) < .6 and math.hypot(q[0] + .5 - c[0], q[1] + .5 - c[1]) < rr - 1.5}
    p.fill({q for q in seam if q[0] % 3 != 2}, PLATE[3])
    # sand trickling off the plate's rim
    if math.sin(a) < .3:
        p.pxs([(c[0] + math.cos(a) * (rr - 1.5), c[1] + 2 + k * 2) for k in range(2)], SAND)

# head: blunt armoured head, maw gaping wide on cream fangs and a dark throat
p = R.part('head')
hp = P['head']
HINGE = (92, 33.5)
UTIP = (114, 22.5)                                          # upper jaw tip
LTIP = (112.5, 46)                                        # lower jaw tip
neck = capsule([hp, (92, 30)], 22, 20)
skull = union(ell(96, 24, 13, 10.5), poly([(92, 14.5), (106, 13.5), (112.5, 16.5), (114.5, 21), UTIP, (104, 29.5), HINGE, (88, 33)]))
ljaw = poly([(85, 41), HINGE, (100, 37.5), LTIP, (113.5, 47.5), (108, 50.5), (97, 49.5), (87, 46)])
throat = inter(poly([(HINGE[0] - 1, HINGE[1]), (112.5, 23.5), (111.5, 45.5)]), ell(100, 34.5, 14, 12))
shape = union(neck, skull, ljaw, throat)
p.add(p.m(shape), SIDE)
p.add(p.m(inter(skull, lambda x, y: y < 19)), BACK)
p.add(p.m(ljaw), RING, local=True)
p.add(p.m(inter(ljaw, lambda x, y: y > 44.5 + (x - 90) * .1)), BELLY, local=True)
p.edge(p.m(minus(ljaw, throat)), SIDE[3], sides=((0, -1),))
for t in (3, 8.5):                                        # armour rings across the back of the head
    p.fill(p.m(inter(minus(shape, throat, ljaw), S.along(hp, (96, 22), t, t + 1.6))), GROOVE)
    p.fill(p.m(inter(minus(shape, throat, ljaw), S.along(hp, (96, 22), t + 1.6, t + 2.4))), SIDE[0])
for x0 in (91, 96, 101, 106):                            # sewn seam along the jaw plate
    p.px(x0, 44 + (x0 - 91) * .2, BELLY[3]); p.px(x0 + 1, 44 + (x0 - 91) * .2, BELLY[3])
# the open maw: gum lining, a deep throat, rows of cream fangs
p.add(p.m(throat), ('#b84a52', '#a83a4a', '#7a2a40', '#5a1f34'), flat=True)
p.add(erode(p.m(throat)), ('#3a1420',) * 4, flat=True)
p.add(p.m(inter(throat, ell(99, 35, 8, 6))), ('#1a080c',) * 4, flat=True)
p.add(p.m(inter(throat, ell(96.5, 35, 3.5, 2.5))), ('#000000',) * 4, flat=True)
FANG = ('#ffffff', CREAM, '#e8d6a8', '#c9a96e')


def fangs(a, b, n, size, sgn):
    """n fangs along the jaw edge a->b, pointing into the mouth (sgn: +1 down, -1 up)"""
    for k in range(n):
        t = (k + .7) / n
        x, y = a[0] + (b[0] - a[0]) * t, a[1] + (b[1] - a[1]) * t
        h = size * (.6 + .4 * t)
        p.add(p.m(inter(throat, poly([(x - h * .55, y - sgn * 1), (x + h * .55, y - sgn * 1), (x + .3, y + sgn * h)]))), FANG, flat=True)
        p.px(x - .5, y - sgn * .2, '#ffffff')


fangs((HINGE[0] + 3, HINGE[1] - 1.8), (112, 24), 6, 5.2, +1)
fangs((HINGE[0] + 3, HINGE[1] + 1.8), (111, 44.8), 6, 4.8, -1)
# heavy brow plates and a nose plate
for (cx, cy, rx, ry, d) in ((95, 17.5, 7, 3.6, -10), (104.5, 16.5, 5.8, 3.2, 6), (110.5, 19, 3.6, 2.6, 30)):
    pl = inter(shape, rell(cx, cy, rx, ry, d))
    m = p.m(pl)
    p.add(m, PLATE, local=True)
    p.edge(m, PLATE[3])
# a dark deep-set socket under the brow
p.add(p.m(ell(97.8, 24.4, 3.6, 3.1)), ('#4a2812',) * 4, flat=True)

# eyes: small deep-set ember eye under the brow
p = R.part('eyes')
S.eyeball(p, 97.8, 24.6, 2, '#f08a4a', pupil='slit', lid=PLATE[2], lidcut=23.4)

R.save()
