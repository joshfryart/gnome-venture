#!/usr/bin/env python3
"""raccoon "Raccoon" (quad.bear rig, 103 x 50, 8 parts; large; forest, wetland; night/dusk; drops Raccoon Pelt, Stolen Bauble; attack: charge)
"A masked bandit with clever hands."
A hunched felt raccoon in soft ash-grey: the back arches up high over the hips and runs down to low shoulders, a pale belly
fringe, a stitched seam all round. Short legs with dark little hands and cream finger ticks (legs). A big bushy tail swept up
and back over the rump with five dark sewn rings and a dark tip (tail). A wedge head with round ears rimmed in cream, the
black bandit mask across the eyes under a cream brow, a white muzzle, a button nose, a cream cheek ruff, and a gold Stolen
Bauble clenched in its teeth (head). A button eye glinting out of the mask (eyes)."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from rigkit import *  # noqa
import importlib
K = importlib.import_module('_quad_wild-boar')

R = Rig('raccoon')
FUR = ('#c4c0ca', '#96929e', '#706c7a', '#4e4a58')
FAR = darker(FUR)
MASK = ('#5a5262', '#3e3646', '#2e2834', '#2a1a10')
PALE = ('#fff3c8', '#f1ece0', '#c9c5bc', '#8b8f96')
HAND = ('#6a6474', '#4e4858', '#3a3442', '#2a1a10')

# far legs
for pid, fx in (('legBF', 39), ('legFF', 67)):
    p, m = K.leg(R, pid, fx, FAR, 6.5, 4.5, top=4, foot=HAND, foot_w=5, foot_h=2.6, cloven=False)

# tail: big bushy ringed tail swept up and back over the rump
p = R.part('tail')
path = [R.pv('tail'), (23, 20), (17, 15), (13.5, 9.5), (14, 6)]
p.add(p.m(capsule(path, 9.5, 8.5)), FUR)
segs, tot = [], 0.0
for a, b in zip(path, path[1:]):
    L = ((b[0] - a[0]) ** 2 + (b[1] - a[1]) ** 2) ** .5; segs.append((a, b, tot, L)); tot += L
import rigkit
def along(x, y):
    best = min((rigkit._segd(x, y, a[0], a[1], b[0], b[1]) + (s0, L) for a, b, s0, L in segs), key=lambda r: r[0])
    return best[2] + best[1] * best[3]
rings = lambda x, y: along(x, y) > 6 and (int((along(x, y) - 6) / 3.4) % 2 == 0 or along(x, y) > tot - 2.5)
p.add(p.m(inter(capsule(path, 9.5, 8.5), rings)), MASK)

# body: low shoulders, back arched high over the hips, pale belly fringe
p = R.part('body')
torso = union(ell(38, 21, 12.5, 12), ell(56, 24.5, 11.5, 9.5), poly([(28, 16), (36, 9), (46, 10.5), (62, 15.5), (68, 29), (67.5, 33.5), (30, 32)]))
belly = K.tufts([(36, 32.5), (41, 33.3), (46, 33.5), (51, 33.3), (56, 32.8), (61, 32.6)], 3.0, 1.9)
p.add(p.m(torso, belly), FUR, stitch=FUR[3])
p.add(p.m(inter(union(torso, belly), lambda x, y: y > 32.5)), PALE, local=True)
for x, y in ((40, 17), (45, 19), (50, 22), (36, 24), (44, 26), (55, 27)):
    p.line([(x, y), (x + 1, y + 2)], FUR[3])

# near legs: haunch and shoulder pads, dark hands with cream finger ticks
for pid, fx, th in (('legBN', 33.5, (7, 7.5)), ('legFN', 62, (5.5, 6.5))):
    px_, py_ = R.pv(pid)
    p, m = K.leg(R, pid, fx, FUR, 7, 5, top=4, thigh=th, foot=HAND, foot_w=5.5, foot_h=3, cloven=False, toes=PALE[2])
    p.add(p.m(inter(capsule([(fx, 39), (fx, 42)], 5.4), lambda x, y: y < 42.5)), HAND, local=True)
    p.edge(p.m(inter(ell(px_, py_ - .8, th[0], th[1]), lambda x, y: y < py_ + 2)), FUR[3], sides=((0, -1), (-1, 0) if pid == 'legBN' else (1, 0)))

# head: round ears, wedge face, bandit mask, white muzzle, button nose, cheek ruff, the stolen bauble
p = R.part('head')
ears = union(ell(66.5, 14, 3.3, 3.5), ell(73.5, 13.2, 3.3, 3.5))
p.add(p.m(ears), FUR, local=True)
p.add(p.m(union(ell(66.5, 14.4, 1.7, 1.9), ell(73.5, 13.6, 1.7, 1.9))), (MASK[1],) * 4, flat=True)
face = union(ell(70, 22, 8.5, 7.5), capsule([R.pv('head'), (66, 25)], 11, 10), poly([(74, 17), (86, 23.5), (86.5, 26.5), (76, 29)]))
ruff = K.tufts([(64, 28.5), (68, 29.5), (72, 29.5)], 2.6, 2.0)
p.add(p.m(face, ruff), FUR)
p.edge({q for q in p.m(face) if q[0] < 62}, INK, sides=((-1, 0), (0, -1)))
p.add(p.m(inter(face, ell(74, 18.3, 7, 2.2))), PALE, local=True)                        # cream brow
p.add(p.m(inter(face, union(rell(72.5, 22, 7.5, 2.8, 10), ell(72, 22.5, 3.6, 3.4)))), MASK, local=True)   # the mask
p.add(p.m(inter(face, poly([(76, 24.5), (86.5, 24.5), (86, 27), (76, 30)]))), PALE, local=True)            # white muzzle
p.add(p.m(ruff), PALE, local=True)
p.add(p.m(ell(86, 24.2, 1.9, 1.7)), (INK,) * 4, flat=True)                              # button nose
# the stolen bauble: a gold ornament with a little cap, held in the teeth
p.add(p.m(ell(90.5, 28.5, 3.6, 3.6)), GOLD)
p.add(p.m(rect(89, 23.5, 92, 25.5)), STONE, flat=True)
p.px(89, 27, CREAM); p.px(90, 26, CREAM)
p.line([(87, 30), (92, 29.5)], GOLD[3])
p.line([(84, 28), (79, 28.5)], INK)                                                       # mouth

p = R.part('eyes')
K.eye_dot(p, 72.5, 22, r=1.2, glint='#ffffff')

R.save()
