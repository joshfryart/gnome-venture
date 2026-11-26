#!/usr/bin/env python3
"""dew-leech "Dew Leech" (worm5 rig, 61 x 23, 7 parts): "A pale leech that drinks from the clean pools and keeps the water for itself."
(trek, medium, level 16; Clean Dew, Leech Slime)
A slim, pale, see-through felt leech looping over the ground: a pale mint body sewn from five segments, so full of clean water that a
blue core of it shows through along the middle with little bright bubbles; a fine ring stitch per segment, a neat small sucker on the
tail end (s5); a slender pale head (head) with pursed lips holding a fat dew drop it has just sipped, the drop hanging under the mouth.
Eyes: a small contented, half-lidded eye."""
import importlib.util, os, sys
SDIR = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(SDIR, '..'))
from rigkit import *  # noqa
_s = importlib.util.spec_from_file_location('wk', os.path.join(SDIR, '_worm_earthworm-bully.py')); wk = importlib.util.module_from_spec(_s); _s.loader.exec_module(wk)

R = Rig('dew-leech')
DEW = ('#f6fffb', '#cdeee2', '#94cfc4', '#5a9a9a')
CORE = ('#e4f6ff', '#a9d6ea', '#7cbad6', '#3f8fb0')
DROP = ('#ffffff', '#c4ecff', '#6ab8e0', '#3f8fb0')
W = wk.Worm(R, (5.5, 14.6), (49, 12.4), [4.6, 7.2, 8.2, 8.4, 8, 7.4, 6.6])
HEAD = union(capsule([(46, 12.4), (52.5, 11.6), (56.8, 12.2)], 6.8, 4), ell(57.4, 12.4, 2, 2))
REF = R.part('s1').m(W.all(), HEAD)

for i, pid in enumerate(wk.SEGS):
    p = R.part(pid)
    cap = W.span(i)
    if pid == 's5':                                        # a neat little tail sucker
        p.add(p.m(ell(6, 15.6, 3.6, 2)), darker(DEW), local=True, crescent=0)
    p.add(p.m(cap), DEW, ref=REF)
    core = inter(cap, lambda x, y, i=i: W.side(i, -W.W[i] * .14)(x, y) and not W.side(i, W.W[i] * .16)(x, y))
    if pid != 's5':
        p.add(p.m(core), CORE, flat=True)                  # the clean water showing through
    W.ring(p, i, .55, DEW[2], inset=1.2, bend=.3)
    if pid != 's1':
        W.ring(p, i, 1.0, DEW[3], inset=.8, bend=-.5)
    if pid in ('s4', 's3', 's2'):                          # bubbles in the water
        (cx, cy), _, _, _ = W.frame(i, .3 if pid != 's3' else .75)
        p.px(cx, cy, '#ffffff')
        if pid == 's3':
            (cx, cy), _, _, _ = W.frame(i, .25)
            p.px(cx, cy - 1, '#ffffff'); p.px(cx + 1, cy - 1, '#ffffff')

# head: slender, pale, pursed lips and the sipped dew drop hanging under them
p = R.part('head')
p.add(p.m(HEAD), DEW, ref=REF)
drop = union(ell(57.6, 17, 2.5, 2.5), poly([(55.4, 16.4), (57.6, 13.4), (59.8, 16.4)]))
dm = p.add(p.m(drop, minus=[HEAD]), DROP, local=True, crescent=1)
p.edge(dm, DROP[3], sides=((0, -1), (-1, 0)))
p.px(56, 16, '#ffffff'); p.px(56, 17, '#ffffff')
p.add(p.m(inter(HEAD, lambda x, y: 11.4 < y < 13 and x < 53)), CORE, flat=True)
p.add(p.m(ell(58.4, 12.8, 1.2, 1.2)), (BLUSH, BLUSH, PETAL[2], PETAL[2]), flat=True)        # the pursed lips
p.px(58, 13, PETAL[3])
p.line([(47.5, 9), (47, 12), (47.5, 15)], DEW[3])                                              # the neck seam

# eyes: a small contented, half-lidded eye
p = R.part('eyes')
ex, ey = 52.8, 9.9
p.add(p.m(ell(ex, ey, 2.1, 2.1)), (INK,) * 4, flat=True)
p.add(p.m(ell(ex, ey, 1.35, 1.35)), (CREAM,) * 4, flat=True)
p.add(p.m(rect(53, 10, 54, 11)), (INK,) * 4, flat=True)
p.add(p.m(inter(ell(ex, ey, 2.1, 2.1), lambda x, y: y < ey - .1)), (DEW[2],) * 4, flat=True)
p.line([(51, 9), (54, 9)], INK)

R.save()
