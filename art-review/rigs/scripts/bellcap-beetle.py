#!/usr/bin/env python3
"""bellcap-beetle "Bellcap Beetle" (bug.beetle rig, 63 x 51, 8 parts): "A round beetle with a shell like a little bell. It chimes when it charges."
(trek, the Tally Gallery caves; Bellcap Shell, Bell Clapper)
A stout beetle wearing its wing cases as a brass handbell, the tall one of the batch: a bronze felt bell dome with a round handle
knob on the crown, a flared lip with a darker sound-bow band, an engraved tally-mark band and two verdigris patches from the damp
caves; the umber beetle belly peeks under the lip and a little clapper hangs between the legs (body). A small round umber head
pokes out under the front of the lip, with short mandibles (head), one bright button eye (eyes), two fan-tipped (lamellate)
feelers (antL far / antR near) and three sturdy legs (leg1..leg3)."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from rigkit import *  # noqa

R = Rig('bellcap-beetle')
P = {k: R.pv(k) for k in R.ids}
BRASS = GOLD
DARK = ('#74462a', '#4a2c1a', '#2a1a10', '#2a1a10')
VERD = ('#dfeadb', '#b4d4bc', '#86b49a', '#5a8a70')
HEAD = ('#9a6b3f', '#74462a', '#4a2c1a', '#2a1a10')

# legs: sturdy, knees out
for pid, pts in (('leg1', [(20.7, 32.1), (15.5, 38.5), (13.5, 45)]),
                 ('leg2', [(30.3, 32.1), (33.5, 38.5), (31.5, 45)]),
                 ('leg3', [(39.9, 32.1), (46.5, 37.5), (51, 45)])):
    p = R.part(pid)
    p.add(p.m(capsule(pts[:2], 4.6, 3.6), capsule(pts[1:], 3.2, 2.4)), HEAD, crescent=0)      # thick felt thigh, slimmer shin
    kx, ky = pts[1]
    p.add(p.m(ell(kx, ky, 2.1, 2.1)), DARK, local=True, crescent=0)                           # knee button
    fx, fy = pts[-1]
    p.add(p.m(ell(fx + (1.4 if pid != 'leg1' else -1.4), fy, 2.4, 1.2)), DARK, local=True, crescent=0)
    p.px(int(fx + (3 if pid != 'leg1' else -3)), int(fy) - 1, DARK[0])                        # a little hooked toe

# body: the bell
p = R.part('body')
bell = union(ell(27, 14, 9.6, 8.4),
             poly([(17.4, 14), (36.6, 14), (38.4, 22), (41.5, 28.5), (45.6, 32), (45.8, 35.4), (8.2, 35.4), (8.4, 32), (12.5, 28.5), (15.6, 22)]))
p.add(p.m(capsule([(12, 35), (42, 35)], 4.6)), DARK)                                        # belly under the lip
p.add(p.m(capsule([(27, 35), (27, 37.5)], 1.2)), DARK, local=True)
p.add(p.m(ell(27, 38.8, 2.1, 2.1)), BRASS, local=True, crescent=1)                           # the clapper
kn = p.m(ell(27, 4.4, 2.8, 2.3), rect(25.6, 5, 28.4, 8))
p.add(kn, BRASS, local=True)                                                                # handle knob
p.add(p.m(bell), BRASS, stitch=BRASS[3])
lip = inter(bell, lambda x, y: y > 31)
p.add(p.m(lip), (BRASS[1], BRASS[2], BRASS[3], BRASS[3]))                                   # sound-bow band
p.line([(11, 31), (43, 31)], BRASS[3])
p.line([(15, 22), (39, 22)], BRASS[3])                                                      # engraved band with rivets
for x in (17, 21, 25, 29, 33, 37):
    p.px(x, 24, BRASS[3]); p.px(x, 23, BRASS[0])
p.line([(26, 8), (28, 8)], BRASS[3])                                                        # seam under the knob
p.add(p.m(inter(bell, ell(34.5, 17, 2.6, 2))), VERD, local=True, crescent=0)                # verdigris
p.add(p.m(inter(bell, ell(13.5, 29.5, 2.2, 1.6))), VERD, local=True, crescent=0)
for q in ((22, 9), (21, 10), (20, 12), (19, 14), (19, 15)):                                 # shine
    p.px(q[0], q[1], '#fff3c8')

# head: small round umber head under the front of the lip
p = R.part('head')
hd = union(ell(48.2, 30.4, 6.4, 6), capsule([P['head'], (45, 30)], 5, 6))
p.add(p.m(hd), HEAD)
p.add(p.m(capsule([(53, 32.5), (56, 33.5), (55.5, 35.5)], 2, 1.4)), HEAD, local=True, crescent=0)   # mandible
p.line([(50, 34), (52, 33.5)], DARK[0])
p.px(52, 31, BLUSH)

p = R.part('eyes')
ex, ey = 48.7, 27.9
p.add(p.m(ell(ex + .3, ey + .6, 2.6, 2.6)), (INK,) * 4, flat=True)
p.add(p.m(ell(ex + .3, ey + .6, 1.7, 1.7)), (CREAM,) * 4, flat=True)
p.add(p.m(rect(49, 28, 51, 30)), (INK,) * 4, flat=True)
p.px(48, 27, '#ffffff')

# feelers: thin stalk, little three-leaf fan at the tip
for pid, pts, ramp in (('antL', [(46.5, 24.4), (45.8, 18.5), (47.5, 15)], darker(HEAD)),
                       ('antR', [(50.1, 24.4), (53, 19.5), (57, 17.5)], HEAD)):
    p = R.part(pid)
    tx, ty = pts[-1]
    fan = union(ell(tx, ty - 1.6, 1.3, 1.9), ell(tx + 1.6, ty - .4, 1.9, 1.3), ell(tx + 1, ty - 1.6, 1.4, 1.4))
    p.add(p.m(capsule(pts, 1.8, 1.4), fan), ramp, crescent=0)

R.save()
