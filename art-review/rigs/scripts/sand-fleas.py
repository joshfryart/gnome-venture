#!/usr/bin/env python3
"""sand-fleas "Sand Flea Pack" (bug.plain rig, 51 x 37, 8 parts): "Hopping, nipping, impossible to pin down." (coast, island, desert; Flea Legs, Sea Glass)
A felt beach sandhopper, the pack leader, facing right: a high arched back of overlapping sandy plates (sewn seams across), curling
down at the rear into a tucked tail with a forked flick, sea-glass beads caught on its plates (body); a round head with a pale cheek (head), one big glossy black eye (eyes), a long
beaded antenna reaching forward (antR) and a short one up (antL); a big folded jumping leg at the back (leg1) and two short
walking legs under the chest (leg2, leg3)."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from rigkit import *  # noqa

R = Rig('sand-fleas')
SAND = ('#fbeed0', '#e6c88e', '#c09a5e', '#86643a')
PALE = ('#fffaf0', '#f6e6c0', '#e0c896', '#c09a5e')
GLASS = ('#e8fbf2', '#9fdcc8', '#5fae9c', '#3f8f80')
LEG = ('#e6c88e', '#c09a5e', '#9a7444', '#6e5030')

# legs: the folded jumping leg at the back, two short walkers in front
for pid, pts, w in (('leg1', [(16.5, 21.5), (11.5, 25.5), (14, 28.5), (8.5, 31.5)], 3.2),
                    ('leg2', [(24.5, 23), (23, 27.5), (25.5, 31.5)], 2.6),
                    ('leg3', [(31.5, 23), (34, 27), (37.5, 31)], 2.6)):
    p = R.part(pid)
    p.add(p.m(capsule(pts, w, 2)), LEG, crescent=0)
    p.add(p.m(ell(pts[-1][0], pts[-1][1], 1.6, 1)), LEG, crescent=0, local=True)
    if pid == 'leg1':
        p.add(p.m(rell(13, 24, 3.2, 2.2, 35)), LEG, crescent=0, local=True)          # a fat felt thigh

# body: the arched, plated back
p = R.part('body')
arc = capsule([(7, 26), (8.5, 19), (13, 14), (20, 11.5), (27, 13), (32, 17.5)], 7, 11)
belly = ell(21, 20.5, 11.5, 5)
tail = capsule([(7.5, 25), (5.5, 29), (3.5, 28.5)], 4.5, 2.4)
flick = union(capsule([(4, 28.5), (2.6, 25.5)], 1.8), capsule([(4, 29), (2.6, 30.6)], 1.6))
pup = union(ell(18.5, 6, 3.6, 2.3), capsule([(15.5, 6.5), (13.5, 8)], 1.6))
sil = p.add(p.m(arc, belly, tail, flick), SAND)
p.add(p.m(inter(belly, lambda x, y: y > 21.5)), PALE)
p.add(p.m(inter(arc, lambda x, y: y > 23.5 and x < 12)), PALE)
import math
BAND = ('#f2dcaa', '#d2a96a', '#ad864e', '#86643a')
C = (19, 42)
pol = lambda x, y: math.degrees(math.atan2(y - C[1], x - C[0])) % 360
edges = (222, 236, 249, 261, 273, 285, 300)
for k, (a0, a1) in enumerate(zip(edges, edges[1:])):                          # the back plates: alternating felt bands, seam between
    band = p.m(inter(arc, lambda x, y, a0=a0, a1=a1: a0 <= pol(x, y) < a1 and y < 21.5), minus=(pup,))
    p.add(band, BAND if k % 2 else SAND, ref=sil)
for ang in edges[1:-1]:
    a = math.radians(ang)
    seam = p.m(inter(capsule([(C[0] + math.cos(a) * 18, C[1] + math.sin(a) * 18), (C[0] + math.cos(a) * 36, C[1] + math.sin(a) * 36)], 1), arc, lambda x, y: y < 21.5), minus=(pup,))
    p.fill(seam, SAND[3])
    p.cut.add(max(seam, key=lambda q: (q[0] - C[0]) ** 2 + (q[1] - C[1]) ** 2))   # a notch in the back at each plate edge
p.line([(11, 22.5), (29, 22.5)], SAND[2])                                     # the belly seam
for q in ((10, 18), (24, 14.5), (16, 16), (29, 17)):                         # sea-glass beads caught on the plates
    p.add(p.m(ell(q[0] + .5, q[1] + .5, 1.2, 1.2)), GLASS, flat=True)
    p.px(q[0], q[1], GLASS[0])

# head: round, with a pale cheek and a little mouth
p = R.part('head')
hd = union(ell(35.5, 18.5, 5.6, 5.8), capsule([R.pv('head'), (33, 19)], 6, 6))
p.add(p.m(hd), SAND)
p.add(p.m(inter(hd, ell(38, 22.5, 3.6, 2.4))), PALE)
p.line([(39, 22), (41, 21.5)], SAND[3])
p.add(p.m(ell(37.5, 21, 1.2, .9)), (BLUSH,) * 4, flat=True)

# eyes: one big glossy black eye
p = R.part('eyes')
ex, ey = 36.5, 16.9
p.add(p.m(ell(ex, ey, 2.3, 2.3)), (INK,) * 4, flat=True)
p.px(36, 16, '#ffffff'); p.px(37, 17, UMBER2)

# antennae: beaded felt threads, a short one up, a long one forward
for pid, pts in (('antL', [(34, 13.5), (33.5, 8.5), (35, 4)]), ('antR', [(37.5, 13.5), (42, 10), (47.5, 8.5)])):
    p = R.part(pid)
    p.add(p.m(capsule(pts, 1.8, 1.3)), LEG, crescent=0, flat=True)
    for t in (.35, .65, 1.0):
        k = min(int(t * 2), 1)
        a, b = pts[k], pts[k + 1]
        u = t * 2 - k if t < 1 else 1
        p.add(p.m(ell(a[0] + (b[0] - a[0]) * u, a[1] + (b[1] - a[1]) * u, 1.3, 1.3)), LEG, flat=True)

R.save()
