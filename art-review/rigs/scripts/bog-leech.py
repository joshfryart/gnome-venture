#!/usr/bin/env python3
"""bog-leech "Bog Leech" (worm5 rig, 61 x 31, 7 parts): "Wriggles out of the murk looking for a snack." (wetland, medium, level 6,
rain; Leech Slime; Water class)
A fat dark felt leech looping like an inchworm out of the bog: a flat, glossy olive-black body sewn from five segments, ridged with many
fine ring stitches, two rows of orange dashes down the flank (the bog leech's stripes) and a mustard belly; a wide round sucker disc
planted on the mud at the tail end (s5); the front tapers into a narrow questing head (head) that ends in a round open oral sucker,
dark inside with a ring of cream felt teeth, nosing down for a snack. Eyes: a small button eye on top of the head, looking ahead."""
import importlib.util, os, sys
SDIR = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(SDIR, '..'))
from rigkit import *  # noqa
_s = importlib.util.spec_from_file_location('wk', os.path.join(SDIR, '_worm_earthworm-bully.py')); wk = importlib.util.module_from_spec(_s); _s.loader.exec_module(wk)

R = Rig('bog-leech')
BOG = ('#7e8c52', '#4f5a34', '#363e24', '#232818')
BELLY = ('#b8a862', '#8e8040', '#6a5e30', '#4a4022')
STRIPE = '#f09a3e'
SHEEN = '#a8b878'
W = wk.Worm(R, (8, 22.4), (49, 20.8), [6.4, 9, 10.6, 11, 10.4, 9.6, 8.6])
HEAD = union(capsule([(46, 20.8), (52.5, 20.4), (56.5, 22.2)], 8.6, 5.4), ell(57.2, 22.8, 2.6, 3.2))
DISC = union(ell(8, 23.6, 7, 2.8), ell(8, 22.6, 4.6, 2.6))
REF = R.part('s1').m(W.all(), HEAD, DISC)

for i, pid in enumerate(wk.SEGS):
    p = R.part(pid)
    cap = W.span(i)
    if pid == 's5':                                        # the rear sucker disc planted on the mud
        p.add(p.m(DISC), ('#8e9a5e', '#5e6a3c', '#3e4628', '#232818'), local=True, crescent=1)
        p.line([(2, 23), (5, 22), (11, 22), (14, 23)], '#a8b878')
        p.line([(3, 25), (13, 25)], BOG[3])
    p.add(p.m(cap), BOG, ref=REF)
    p.add(p.m(inter(cap, W.side(i, W.W[i] * .2))), BELLY, ref=REF)
    p.add(p.m(inter(cap, lambda x, y, i=i: not W.side(i, -W.W[i] * .28)(x, y) and W.side(i, -W.W[i] * .4)(x, y))), (SHEEN,) * 4, flat=True)
    for t in (.5,):
        W.ring(p, i, t, BOG[2], inset=2.2, bend=.4)
    a, b = W.frame(i, 0)[0], W.frame(i, 1)[0]              # an orange running stitch down the flank (the bog leech's stripe)
    nx, ny = W.frame(i, .5)[2]
    o = (W.W[i] + W.W[i + 1]) / 4 * -.05
    wk.dashes(p, [(a[0] + nx * o, a[1] + ny * o), (b[0] + nx * o, b[1] + ny * o)], STRIPE, 2, 2)
    for t in (.3, .8):                                     # and dark spots along the back
        (cx, cy), _, (nx, ny), w = W.frame(i, t)
        p.px(cx - nx * w * .45, cy - ny * w * .45, BOG[3])
    if pid != 's1':
        W.ring(p, i, 1.0, BOG[3], inset=1.2, bend=-.6)

# head: the narrow questing head ending in the open oral sucker
p = R.part('head')
p.add(p.m(HEAD), BOG, ref=REF)
p.add(p.m(inter(HEAD, lambda x, y: y > 21.6 + (x - 46) * .1)), BELLY, ref=REF)
p.add(p.m(inter(HEAD, lambda x, y: 17.4 < y < 18.4 and x < 52)), (SHEEN,) * 4, flat=True)
p.add(p.m(ell(57.4, 23.2, 1.6, 2.2)), ('#7d2c5e', '#5a1f44', '#5a1f44', '#5a1f44'), flat=True)   # the open mouth
for q in ((57, 21), (56, 23), (57, 25), (58, 24)):
    p.px(q[0], q[1], CREAM)                                                                     # a ring of felt teeth
p.line([(47.5, 17), (47, 20), (47.5, 24)], BOG[3])                                             # the neck seam
wk.dashes(p, [(48, 21), (55, 21.4)], STRIPE, 2, 2)

# eyes: a small button eye on top of the head
p = R.part('eyes')
ex, ey = 52.8, 18.0
p.add(p.m(ell(ex, ey, 2.3, 2.3)), (INK,) * 4, flat=True)
p.add(p.m(ell(ex, ey, 1.5, 1.5)), ('#f5cf6a',) * 4, flat=True)
p.add(p.m(rect(53, 17, 54, 19)), (INK,) * 4, flat=True)
p.px(52, 17, '#ffffff')

R.save()
