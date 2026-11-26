#!/usr/bin/env python3
"""ashen-ant "Ashen Ant" (bug.ant rig, 57 x 39, 9 parts): "An ant the colour of cold ashes. It no longer follows the scent trail, only you." (trek, lv 16, blightling; Ant Chitin)
A felt ant gone cold and grey, the faded blightling copy of the scouts: a big round egg gaster sewn in three ash-grey bands, flecked with
pale ash and soot and mended with a dark darning cross (abdo, behind, on its waisted petiole knot); a small humped thorax (body);
a big round toy head with short curved mandibles and a dull blush (head); one pale, lost button eye under a drooping lid (eyes);
the true ant feelers, elbowed: a stalk up, then a bend aimed forward at you (antL far, darker / antR near); three jointed legs with
dark knees and feet (leg1..leg3). Cool lilac-grey felt so it reads apart from the warm siblings (sand scorpion, brass bellcap)."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from rigkit import *  # noqa

R = Rig('ashen-ant')
P = {k: R.pv(k) for k in R.ids}
ASH = ('#e6e2dc', '#b4b0b8', '#86838f', '#5c5966')
LEGC = ('#9a97a3', '#76737f', '#55525e', '#3e3c48')
FLECK, SOOT = '#f1ece0', '#5c5966'

# legs: jointed, knee bumped up, dark knee and foot
for pid, pts in (('leg1', [(24, 23.5), (18.5, 26.5), (15.5, 33.5)]),
                 ('leg2', [(29, 23.5), (31.5, 27.5), (29, 33.5)]),
                 ('leg3', [(33.5, 23.5), (39.5, 26.5), (43.5, 33.5)])):
    p = R.part(pid)
    p.add(p.m(capsule(pts[:2], 3.2, 2.6), capsule(pts[1:], 2.6, 1.8)), LEGC, crescent=0)
    kx, ky = pts[1]
    p.add(p.m(ell(kx, ky, 1.7, 1.7)), darker(LEGC), local=True, crescent=0)
    fx, fy = pts[2]
    p.add(p.m(ell(fx + (1 if pid != 'leg1' else -1), fy - .2, 1.8, 1)), darker(LEGC), local=True, crescent=0)

# abdo: the big round gaster on a waisted petiole knot
p = R.part('abdo')
gas = rell(12.2, 19.2, 9.4, 7.2, -6)
p.add(p.m(capsule([(19, 20), (25, 20.5)], 3)), ASH)
p.add(p.m(ell(21.6, 19.2, 2.2, 3)), ASH, local=True)                                         # petiole knot
p.add(p.m(gas), ASH, stitch=ASH[3])
for x0 in (10.5, 15.5):                                                                      # band seams
    p.add(p.m(inter(gas, rell(x0, 19.2, .7, 9, -12))), (ASH[2],) * 4, flat=True)
for q in ((7, 16), (13, 15), (17, 17), (8, 21), (12, 22)):
    p.px(q[0], q[1], FLECK)                                                                  # pale ash flecks
for q in ((10, 15), (6, 19), (14, 19), (17, 22)):
    p.px(q[0], q[1], SOOT)                                                                   # soot flecks
p.line([(5, 22), (7, 24)], ASH[3]); p.line([(7, 22), (5, 24)], ASH[3])                        # a darned cross

# body: a small humped thorax
p = R.part('body')
th = union(rell(29, 18.6, 6, 4.4, -10), capsule([(23.8, 22), (34, 22)], 3.4))
p.add(p.m(th), ('#c8c4cc', '#9a96a2', '#76737f', '#55525e'))                                 # a shade darker than gaster and head
p.px(28, 16, FLECK); p.px(31, 18, SOOT)
p.line([(24.5, 18), (24, 21)], '#55525e')                                                     # the waist seam

# head: big round toy head, curved mandibles
p = R.part('head')
hd = union(ell(41, 16.2, 6.8, 6), capsule([P['head'], (37, 18)], 5, 5))
for a in ([(46, 20), (50.5, 19.5), (52.5, 21.8)], [(45, 21.5), (48.5, 23), (51, 22.8)]):
    p.add(p.m(capsule(a, 2.6, 1.6)), LEGC, local=True, crescent=0)
p.add(p.m(hd), ASH)
p.line([(35.5, 15.5), (34.8, 18), (35.2, 21)], ASH[3])                                        # neck seam over the thorax
p.add(p.m(ell(44.2, 19.6, 1.4, 1)), ('#d8c0c8',) * 4, flat=True)                              # a faded blush
p.line([(46.5, 18.5), (47.5, 19.5)], ASH[3])                                                  # mouth seam

# eyes: one pale, lost button eye under a drooping lid
p = R.part('eyes')
ex, ey = 42, 14.9
p.add(p.m(ell(ex + .5, ey + .5, 2.9, 2.7)), (INK,) * 4, flat=True)
p.add(p.m(ell(ex + .5, ey + .5, 2.0, 1.8)), (FLECK,) * 4, flat=True)
p.add(p.m(rect(43, 15, 45, 17)), (INK,) * 4, flat=True)
p.add(p.m(inter(ell(ex + .5, ey + .5, 2.9, 2.7), lambda x, y: y < ey - .2)), (ASH[2],) * 4, flat=True)   # heavy lid
p.line([(ex - 2, ey - 1), (ex + 3, ey - 2)], INK)

# feelers: elbowed, stalk up then aimed forward, a little club tip
for pid, pts, ramp in (('antL', [(37, 11.5), (36.5, 6), (42, 3.5)], darker(LEGC)),
                       ('antR', [(41, 11.5), (42.5, 6.5), (49.5, 5.5)], LEGC)):
    p = R.part(pid)
    tx, ty = pts[-1]
    p.add(p.m(capsule(pts, 2, 1.6), ell(tx + .3, ty, 1.7, 1.5)), ramp, crescent=0)

R.save()
