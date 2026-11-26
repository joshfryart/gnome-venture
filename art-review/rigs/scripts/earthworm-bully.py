#!/usr/bin/env python3
"""earthworm-bully "Earthworm Bully" (worm5 rig, 51 x 24, 7 parts): "A fat pink worm that thinks the tunnel is his, and shoves like it."
(trek, small, level 15; Honeydew)
A fat felt earthworm hunched up to shove: a thick pink body sewn from five segments with ring stitches all along it, a swollen coral
saddle band (the clitellum) on s2, a tail tapering to a blunt point on the soil (s5), a sticking plaster cross-stitched on the hump
(s3: he has been in scraps), and a big blunt round head pushed forward with a jutting grumpy lower lip and a soil smudge (head).
Eyes: one small button eye under a heavy brow slanting down to the snout, so he scowls."""
import importlib.util, os, sys
SDIR = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(SDIR, '..'))
from rigkit import *  # noqa
_s = importlib.util.spec_from_file_location('wk', os.path.join(SDIR, '_worm_earthworm-bully.py')); wk = importlib.util.module_from_spec(_s); _s.loader.exec_module(wk)

R = Rig('earthworm-bully')
SKIN = ('#ffd6cc', '#f2a0a0', '#cf6f7c', '#8e3e56')
SADDLE = ('#f49a86', '#d9645e', '#a8404e', '#6e2038')
SOIL = '#9a6b3f'
W = wk.Worm(R, (3.5, 16.6), (41, 12.4), [4.5, 8.5, 10.5, 10.8, 11.6, 12, 11.5], lift=[0, 0, .4, .6, .4, 0, 0])
REF = R.part('s1').m(W.all(), ell(43, 12, 5.6, 5.4))

for i, pid in enumerate(wk.SEGS):
    p = R.part(pid)
    cap = W.span(i)
    p.add(p.m(cap), SKIN, ref=REF)
    p.add(p.m(inter(cap, W.side(i, W.W[i] * .18))), (SKIN[1], SKIN[1], SKIN[2], SKIN[3]), ref=REF)   # a slightly deeper belly
    if pid == 's2':                                       # the swollen saddle band
        sad = inter(capsule([W.S[3], W.S[4]], 12.4, 12.8), lambda x, y: 28.5 < x < 35.5)
        p.add(p.m(sad), SADDLE, ref=p.m(cap, sad))
        for t in (.5,):
            W.ring(p, i, t, SADDLE[3], inset=1.4, bend=.3)
    else:
        for t in ((.45,) if pid == 's5' else (.3, .7)):
            W.ring(p, i, t, SKIN[2], inset=1.6, bend=.3)
    if pid != 's1':                                       # the sewn joint where this segment lies over the next one forward
        W.ring(p, i, 1.0, SKIN[3], inset=.9, bend=-.6)
    if pid == 's3':                                       # a sticking plaster on the hump
        pl = inter(rect(23, 4, 30, 8), lambda x, y: W.all()(x, y - 1.6))
        p.add(p.m(pl), ('#fff3c8', '#fff3c8', '#e0c890', '#c9a96e'), local=True, crescent=1)
        p.line([(24, 5), (26, 7)], SKIN[3]); p.line([(24, 7), (26, 5)], SKIN[3]); p.line([(27, 5), (29, 7)], SKIN[3]); p.line([(27, 7), (29, 5)], SKIN[3])
    if pid == 's5':
        p.px(4, 16, SKIN[3])

# head: the big blunt round head, pushed forward
p = R.part('head')
hd = union(ell(43, 12.2, 5.6, 5.5), capsule([(38.5, 12.6), (42, 12.4)], 11, 11))
p.add(p.m(hd), SKIN, ref=REF)
p.add(p.m(inter(hd, lambda x, y: y > 13.6 + (43 - x) * .1)), (SKIN[1], SKIN[1], SKIN[2], SKIN[3]), ref=REF)
p.add(p.m(ell(47.4, 15, 1.9, 1.4)), SKIN, local=True)                 # the jutting lower lip
p.line([(48.5, 14), (45, 14), (43.5, 15)], SKIN[3])
p.line([(39.5, 8), (38.5, 11), (38.5, 14), (39.5, 17)], SKIN[2])   # the neck crease                    # a grumpy mouth turned down at the back
W.ring(p, 4, 1.3, SKIN[2], inset=1, bend=-.4)
p.px(40, 16, SOIL); p.px(41, 16, SOIL); p.px(41, 17, SOIL)           # a soil smudge on the chin
p.add(p.m(ell(45.6, 12.5, 1.1, .7)), (BLUSH,) * 4, flat=True)

# eyes: one small button eye under a heavy scowling brow
p = R.part('eyes')
ex, ey = 44.1, 9.9
p.add(p.m(ell(ex, ey + .4, 2.9, 2.7)), (INK,) * 4, flat=True)
p.add(p.m(ell(ex, ey + .4, 2.0, 1.9)), (CREAM,) * 4, flat=True)
p.add(p.m(rect(44.5, 10, 46.5, 12.5)), (INK,) * 4, flat=True)
p.px(45, 10, '#ffffff')
p.add(p.m(inter(ell(ex, ey + .4, 2.9, 2.7), lambda x, y: y < 8.4 + (x - 41) * .4)), (SKIN[2],) * 4, flat=True)   # the heavy lid
p.line([(40, 6), (47, 8.6)], INK)                                                                             # the scowling brow, down to the snout

R.save()
