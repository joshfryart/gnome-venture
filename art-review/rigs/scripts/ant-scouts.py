#!/usr/bin/env python3
"""ant-scouts "Ant Scouts" (bug.ant rig, 57 x 43, 9 parts): "A patrol of ants who think your satchel smells delicious." (any; Ant Chitin, Forager's Crumb)
A plump rust-red felt scout ant in profile, the friendly forager of the batch: a big round gaster sewn from three stitched bands on a
little petiole knot (abdo, behind), a round thorax with a moss-green scout neckerchief (body), a round head with a cheeky smile and a
cream bread crumb clamped in its mandibles (head: the Forager's Crumb), one button eye (eyes), two elbowed feelers waving up and
forward with knobbed tips (antL far / antR near), and three thin jointed legs, hind one trailing, front one reaching (leg1..leg3)."""
import math, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from rigkit import *  # noqa

R = Rig('ant-scouts')
P = {k: R.pv(k) for k in R.ids}
RUST = ('#ee9a5c', '#c8622e', '#8f3f22', '#5c2418')
LEGC = ('#8f3f22', '#6e2e1c', '#4a2c1a', '#4a2c1a')
CRUMB = ('#fff3c8', '#f5cf6a', '#c9a96e', '#9a6b3f')
DY = 0      # the ashen ant uses the same skeleton 4 px higher

# legs: thin, jointed, knee raised
for pid, pts in (('leg1', [(24, 28), (19, 29.5), (16.5, 37)]),
                 ('leg2', [(29, 28), (32.5, 31), (31.5, 37)]),
                 ('leg3', [(33.5, 28), (39.5, 30), (43.5, 37)])):
    p = R.part(pid)
    p.add(p.m(capsule(pts, 2.6, 1.9)), LEGC, crescent=0)
    fx, fy = pts[-1]
    p.add(p.m(ell(fx + (1 if pid != 'leg1' else -1), fy + .1, 1.5, .9)), LEGC, local=True, crescent=0)   # a little felt foot

# abdo: the big round gaster in three stitched bands, on a petiole knot
p = R.part('abdo')
gas = rell(12.5, 23.5, 9.6, 7.4, -10)
p.add(p.m(gas, capsule([(19, 24), (24, 24.5)], 2.4, 2.2)), RUST)
p.add(p.m(ell(22, 23.2, 1.8, 2.4)), RUST, local=True)                                    # petiole knot
for cx in (9.2, 15.2):                                                                      # band seams
    p.add(p.m(inter(gas, rell(cx, 23.5, 1.0, 9, -10))), (RUST[2],) * 4, flat=True)
for (x, y) in ((6, 19), (7, 18), (12, 17), (13, 17), (18, 18)):                             # felt shine
    p.px(x, y, RUST[0])

# body: round thorax, sternum strip for the hips, scout neckerchief
p = R.part('body')
th = ell(28.6, 22.6, 6.4, 4.8)
p.add(p.m(th, capsule([(24, 26.8), (33.5, 26.8)], 3)), RUST)
p.line([(26, 19), (25, 22), (26, 25)], RUST[2])                                             # shoulder seam

# head: round head, smile, mandibles holding the crumb
p = R.part('head')
hd = ell(40, 20.2, 6.6, 5.6)
p.add(p.m(hd, capsule([P['head'], (37, 21.5)], 4, 5)), RUST)
p.add(p.m(ell(50.2, 22.4, 4.2, 3.6)), CRUMB, local=True)                                  # the Forager's Crumb
for q in ((49, 21), (51, 23), (52, 21)):
    p.px(q[0], q[1], CRUMB[3])
p.add(p.m(capsule([(45.5, 21.5), (48.5, 19.4), (51.5, 19.2)], 2.2, 1.6)), LEGC, local=True, crescent=0)   # top mandible
p.add(p.m(capsule([(45.5, 24.2), (48.5, 26.2), (51.5, 25.8)], 2.2, 1.6)), LEGC, local=True, crescent=0)     # bottom mandible
nk = p.m(poly([(32.4, 20.8), (39.6, 22.6), (36, 30.2)]))
p.add(nk, MOSS, flat=True); p.edge(nk, MOSS[3])                                             # scout neckerchief
p.px(35, 23, GOLD[0]); p.px(36, 23, GOLD[1])                                                # its gold toggle
hm = p.m(hd)
for (x, y) in hm:                                                                           # seam where the head meets the neck
    if (x - 1, y) not in hm and x < 37 and y < 24:
        p.px(x, y, RUST[3])
p.line([(42, 23), (43, 24), (44, 23)], RUST[3])                                            # smile
p.px(40, 22, BLUSH); p.px(41, 22, BLUSH)

p = R.part('eyes')
ex, ey = 42, 18
p.add(p.m(ell(ex + .5, ey + .9, 2.3, 2.3)), (INK,) * 4, flat=True)
p.add(p.m(ell(ex + .5, ey + .9, 1.4, 1.4)), (CREAM,) * 4, flat=True)
p.add(p.m(rect(43, 18, 44, 20)), (INK,) * 4, flat=True)

# feelers: elbowed, knobbed
for pid, pts, ramp in (('antL', [(37, 15.4), (34.8, 10.5), (39.5, 7)], darker(LEGC)),
                       ('antR', [(41, 15.4), (42, 9.5), (48.5, 6)], LEGC)):
    p = R.part(pid)
    p.add(p.m(capsule(pts, 2, 1.6), ell(pts[-1][0], pts[-1][1], 1.6)), ramp, crescent=0)

R.save()
