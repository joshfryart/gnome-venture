#!/usr/bin/env python3
"""emerald-python "Emerald Python" (snake rig, 87 x 51, 8 parts): "Hangs from the canopy like a green rope, and a rope that hugs back." (rainforest/wetland, L25; Snake Fang, Jade Eye)
A felt emerald tree python rearing up out of a coil: s1 = the prehensile tail lying in a loose loop on the ground, its tip curled
back over the loop; s2..s6 = a thick emerald body sewn from five segments: a deep-green back, bright emerald flanks and a broad
cream belly facing forward, with the tree python's broken white dorsal bars running down the spine. The neck narrows so the broad
spade-shaped boa head stands out: deep-green crown with white brow marks, cream lips with a row of dark heat pits, a nostril and a
little forked pink tongue. eyes = a big jade-gold eye with a black vertical slit pupil under a green brow scale.
Chained segments are lit against the whole snake (ref=), so the joints read as soft seams, not caterpillar beads."""
import math, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from rigkit import *  # noqa

R = Rig('emerald-python')
P = {k: R.pv(k) for k in R.ids}
EM = ('#a6f2a0', '#3ccf6e', '#26a352', '#17733c')       # bright emerald flank
BACK = ('#3aa05c', '#22804a', '#176038', '#0e3d22')     # deep green back
BELLY = ('#fffbe2', '#f4ebb0', '#d6c878', '#9a8c48')    # cream-yellow belly
WHITE = '#fbfff4'
JADE = ('#e6f08a', '#b8dc52', '#6fae3a')                # jade-gold iris
ALL = lambda x, y: True
G = R.ground + 1.0                                     # nothing below the ground row

# tail: from the s2 pivot back along the ground, a loose loop, the tip curled back over the top of the loop
curl = [P['s2'], (9, 43.4), (4.4, 41), (3.6, 35.6), (6.4, 30.4), (11, 29.8), (13.2, 32.6), (12.8, 35.4)]
chain = [('s2', P['s2'], (23, 41.2), P['s3'], 10.5, 12.5), ('s3', P['s3'], (34, 41.0), P['s4'], 12.5, 13.5),
         ('s4', P['s4'], None, P['s5'], 13.5, 13), ('s5', P['s5'], None, P['s6'], 13, 11),
         ('s6', P['s6'], None, P['head'], 11, 8)]


def segcap(a, m, b, w0, w1):
    return inter(capsule([a] + ([m] if m else []) + [b], w0, w1), lambda x, y: y < G)


TAIL = inter(capsule(curl, 9.5, 2.2), lambda x, y: y < G)
REF = R.part('s1').m(TAIL, *[segcap(a, m, b, w0, w1) for _, a, m, b, w0, w1 in chain], capsule([P['head'], (68, 11)], 8, 8))


def band(a, b, r, cap, upper=True, k=.25):
    """back band (upper=True: on the up-normal side further than k*r from the centre line) or belly band"""
    if upper:
        return inter(cap, minus(ALL, below(a, b, -r * k)))
    return inter(cap, below(a, b, r * k))


def dorsal(p, a, b, r, ts, cap, s=1.0):
    """broken white dorsal bars straddling the spine, tilted back"""
    dx, dy = b[0] - a[0], b[1] - a[1]; L = math.hypot(dx, dy); nx, ny = dy / L, -dx / L   # up-normal
    ang = math.degrees(math.atan2(dy, dx))
    for t in ts:
        cx, cy = a[0] + dx * t + nx * r * .62, a[1] + dy * t + ny * r * .62
        p.add(p.m(inter(rell(cx, cy, 2.2 * s, 1.25 * s, ang + 70), cap)), (WHITE,) * 4, flat=True)


# s1: the tail in a loose coil on the ground
p = R.part('s1')
tm = p.add(p.m(TAIL), EM, ref=REF)
lowloop = [P['s2'], (9, 43.4), (4.4, 41)]
p.add(p.m(inter(TAIL, minus(capsule([(3.6, 35.6), (6.4, 30.4), (11, 29.8), (13.2, 32.6)], 1.0), ell(8.6, 35.2, 3.6, 4.3)), lambda x, y: y < 40)), BACK, ref=REF)                     # the upper arc shows its back
p.add(p.m(inter(capsule(lowloop, 10, 6), lambda x, y: y >= 42.6 and y < G)), BELLY, ref=REF)   # belly showing on the lower run
p.add(p.m(rell(3.2, 37.0, 1.5, .9, 80), rell(8.6, 28.6, 1.4, .8, 10), rell(12.6, 39.4, 1.6, 1.0, 70)), (WHITE,) * 4, flat=True)

# s2..s6: the body
for pid, a, m, b, w0, w1 in chain:
    p = R.part(pid)
    cap = segcap(a, m, b, w0, w1)
    r = (w0 + w1) / 4
    a2 = m or a
    p.add(p.m(cap), EM, ref=REF)
    bk = .0 if pid in ('s5', 's6') else .25
    belly_k = .3
    p.add(p.m(band(a2, b, r, cap, False, belly_k)), BELLY, ref=REF)
    if m:
        p.add(p.m(band(a, m, r, inter(cap, lambda x, y, m=m: x < m[0]), False, belly_k)), BELLY, ref=REF)
        p.add(p.m(band(a, m, r, inter(cap, lambda x, y, m=m: x < m[0]), True, .3)), BACK, ref=REF)
    p.add(p.m(band(a2, b, r, inter(cap, lambda x, y, a2=a2: not m or x >= a2[0]), True, .3)), BACK, ref=REF)
    dx, dy = b[0] - a2[0], b[1] - a2[1]
    bel = band(a2, b, r, cap, False, belly_k + .35)
    for t in (.2, .45, .7, .95):                                     # belly scute lines
        cx, cy = a2[0] + dx * t, a2[1] + dy * t
        p.fill(p.m(inter(bel, lambda x, y, cx=cx, cy=cy: abs((x - cx) * dx + (y - cy) * dy) < .5 * math.hypot(dx, dy))), BELLY[2])
    if m:
        dorsal(p, a, m, r, (.55,), cap)
    dorsal(p, a2, b, r, {'s2': (.6,), 's3': (.55,), 's4': (.3, .8), 's5': (.3, .78), 's6': (.45,)}[pid], cap, .85 if pid == 's6' else 1)
    if pid != 's2':                                                  # a soft seam onto the segment behind, back side only
        ex, ey = (m or b)[0] - a[0], (m or b)[1] - a[1]
        p.fill(p.m(inter(cap, minus(ALL, below(a, b, r * .1)),
                         lambda x, y, a=a, ex=ex, ey=ey, w0=w0: math.hypot(x - a[0], y - a[1]) > w0 / 2 - 1.1 and (x - a[0]) * ex + (y - a[1]) * ey < 0)), BACK[3])

# head: broad spade-shaped boa head on the narrower neck
p = R.part('head')
neck = capsule([P['head'], (67, 12)], 8, 8.5)
skull = union(ell(72.0, 9.4, 8.6, 6.6), ell(79.0, 10.2, 5.6, 4.6), ell(83.0, 10.8, 2.4, 2.6))
p.add(p.m(neck, skull), EM)
jaw = union(inter(skull, lambda x, y: y > 11.8 - (x - 70) * .06), inter(neck, lambda x, y: y > 11.8 and x - 62 > (y - 12) * .9))
p.add(p.m(jaw), BELLY)
p.add(p.m(inter(union(skull, neck), lambda x, y: y < 7.6 + (x - 72) * .14 or (x < 68 and y < 11))), BACK)
p.line([(85, 11), (80, 12), (74, 12.8), (69, 13.4)], BACK[3])        # the long lip line
for x in (71, 74, 77, 80, 83):                                       # heat pits along the upper lip
    p.px(x, 12 if x < 80 else 11, BACK[3])
p.add(p.m(rell(65.5, 9.6, 2.0, 1.1, 60), rell(68.6, 5.4, 1.8, .9, -15), rell(77.2, 5.6, 1.7, .9, -5)), (WHITE,) * 4, flat=True)   # white brow marks
p.px(83, 9, BACK[3])                                                 # nostril
p.add(p.m(capsule([(85.0, 12.2), (85.6, 12.2)], 1.1)), (PETAL[2],) * 4, flat=True)   # forked tongue
p.px(84, 13, PETAL[2]); p.px(85, 13, PETAL[2])
p.add(p.m(ell(73.5, 14.4, 1.3, .8)), (BLUSH,) * 4, flat=True)

# eyes: a big jade-gold eye with a vertical slit pupil, green brow scale over it
p = R.part('eyes')
ex, ey = 72.4, 7.6
p.add(p.m(ell(ex, ey, 3.3, 3.1)), (INK,) * 4, flat=True)
p.add(p.m(ell(ex, ey, 2.5, 2.3)), (JADE[1],) * 4, flat=True)
p.add(p.m(inter(ell(ex, ey, 2.5, 2.3), lambda x, y: y > ey + 1)), (JADE[2],) * 4, flat=True)
p.add(p.m(rect(72, 5, 73, 10)), (INK,) * 4, flat=True)               # slit pupil
p.px(71, 6, JADE[0]); p.px(70, 7, '#ffffff')
p.add(p.m(inter(ell(ex, ey, 3.3, 3.1), lambda x, y: y < 5.4)), (BACK[1],) * 4, flat=True)

R.save()
