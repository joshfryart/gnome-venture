#!/usr/bin/env python3
"""barn-rat "Barn Rat" (quad.rodent rig, 65 x 36, 8 parts; level 8, grassland / forest / coast, night): "A seed thief with a long memory."
A brown felt barn rat in a hunched scurry: a pear-shaped body arched high over the hips with a cream belly and a stitched seam
along the flank; big haunches with long pink hind feet, thin front arms with little pink hands; a long bare pink tail
with sewn rings that whips up behind (tail, the rodent spring); a pointed head with a big round pink-lined ear, a pink nose,
whisker dots, two cream incisors and a stolen gold grain kernel clamped in its teeth; a shiny black bead eye (eyes)."""
import os, sys, importlib
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from rigkit import *  # noqa
K = importlib.import_module('_quad_barn-rat')

R = Rig('barn-rat')
RAT = ('#c8a07a', '#9c7352', '#74513a', '#4f3526')
FAR = darker(RAT)
BELLY = ('#fff3c8', '#f2e4c0', '#d9c49a', '#b89a6a')
PINK = PETAL
g = R.ground + 1.0

def leg(pid, pts, w, ramp, toe, toe_rx, haunch=None):
    p = R.part(pid)
    shape = capsule(pts, w, w - .6)
    if haunch:
        shape = union(shape, haunch)
    p.add(p.m(shape, minus=[lambda x, y: y >= g - 1.6]), ramp)
    p.add(p.m(inter(union(ell(toe, g - 1.3, toe_rx, 1.4), capsule([pts[-1], (toe - 1, g - 1.4)], 2.4)), lambda x, y: y < g)),
          (PINK[0], PINK[1], PINK[2], PINK[3]) if ramp is RAT else (PINK[1], PINK[2], PINK[2], PINK[3]))
    return p

# far legs (behind the body), one step darker
leg('legBF', [(24.7, 22), (27, 27.5), (26.5, 29)], 4, FAR, 28.5, 3.8, haunch=ell(25, 22.5, 4, 4))
leg('legFF', [(42.4, 22), (43, 29)], 3, FAR, 44.2, 2.2)

# tail: long, bare, pink, sewn rings; leaves the rump and swings up behind
p = R.part('tail')
tail = capsule([(19.5, 17.5), (14, 21), (8, 21.5), (4, 18.5), (3, 13.5), (4.5, 10.5)], 3.2, 1.6)
tm = p.m(tail)
p.add(tm, PINK)
for x, y in ((14, 20), (10, 21), (6, 20), (4, 16), (4, 12)):
    p.px(x, y, PINK[3])

# body: hunched pear, high arched back over the hips, cream belly, flank seam
p = R.part('body')
torso = union(ell(28, 18.5, 12.5, 10), ell(37.5, 20.5, 7.5, 6.5))
p.add(p.m(torso), RAT, stitch=RAT[3])
p.add(p.m(inter(torso, lambda x, y: y > 24 - (x - 20) * .12)), BELLY, local=True)
for x, y in ((22, 12), (27, 10), (32, 11.5), (25, 16), (31, 15.5), (36, 17)):      # felt fur flecks
    p.line([(x, y), (x + 1, y + 1)], RAT[2])

# near legs: big round haunch with a long hind foot; thin front arm with a little hand
p = leg('legBN', [(20.3, 22), (22, 27.5), (21.5, 29)], 4.4, RAT, 24, 4.4, haunch=ell(20.5, 22, 5.2, 4.8))
p.line([(17, 21), (18, 24)], RAT[2])
toe = R.part('legBN'); K.toes(toe, (26, 28), int(g - 2), PINK[3])
p = leg('legFN', [(38.3, 22), (39.2, 29)], 3.2, RAT, 40.8, 2.4)
K.toes(p, (42,), int(g - 2), PINK[3])

# head: pointed wedge, big round pink-lined ear, pink nose, teeth with a stolen grain kernel
p = R.part('head')
ear = ell(43.5, 7.5, 4.2, 4.6)
p.add(p.m(ear), RAT, local=True)
p.add(p.m(ell(44, 8, 2.6, 3.1)), PINK, local=True, crescent=1)
skull = union(ell(46.5, 14.5, 6.5, 5.6), capsule([R.pv('head'), (45, 17)], 8, 8))
snout = poly([(45, 10), (52, 12), (58.5, 15.3), (58.5, 17.8), (52, 20.5), (44, 20.5)])
p.add(p.m(skull, snout), RAT)
p.add(p.m(inter(union(skull, snout), union(ell(50, 21, 7.5, 2.6), ell(44, 21, 3, 3)))), BELLY, local=True)   # cream chin
p.add(p.m(ell(56.6, 20.4, 2.1, 1.6)), GOLD, local=True, crescent=1)                 # the stolen grain kernel
p.px(56, 19, GOLD[0])
p.add(p.m(ell(58.6, 16.3, 1.7, 1.5)), PINK, local=True, crescent=1)                 # nose
p.px(57, 18, CREAM); p.px(58, 18, CREAM)                                            # incisors
p.line([(52, 18.5), (55, 18.5)], RAT[3])                                            # mouth
for x, y in ((53, 16), (55, 16), (54, 17)):                                         # whisker dots
    p.px(x, y, RAT[3])
p.line([(41.5, 12), (42.5, 15)], RAT[2])                                            # neck fold

p = R.part('eyes')
K.bead(p, 48, 13, r=1.3)

R.save()
