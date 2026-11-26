#!/usr/bin/env python3
"""earwig "Earwig" (bug.plain rig, 67 x 33, 8 parts): a pal-fight critter (Nip / Forceps Clamp, Sting / Swagger Pinch,
Chitin Shell / Folded Wing Shield, Skitter / Cocked Tail Feint).
A long, low, flat felt earwig in glossy chestnut: a ringed abdomen that tapers back and curls UP into a big pair of cocked forceps
(the swagger: an open pincer held over its back, the silhouette nobody else in the batch has); short square tan wing covers sewn on
the shoulders with a centre seam and a pale wing tip peeking out; a small dark neck shield (body). A heart-shaped head with little jaws
(head), a bright button eye (eyes), long bead-chain antennae, one swept back, one reaching forward (antL / antR); three thin pale
legs (leg1..leg3)."""
import importlib, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from rigkit import *  # noqa
H = importlib.import_module('_insect_tallow-grub')

R = Rig('earwig')
CHEST = ('#d88a4e', '#a8542c', '#77341c', '#4a1c10')
DARK = ('#a8542c', '#77341c', '#55220f', '#3a160a')
TAN = ('#f5cf8a', '#d89a58', '#a8682e', '#74462a')
LEG = ('#f2d098', '#d8a868', '#a8763e', '#74462a')

for pid, pts, ft in (('leg1', [(21, 22.5), (18.5, 28.2)], -1), ('leg2', [(30.5, 23), (29, 28.2)], -1), ('leg3', [(45.5, 22.5), (48.5, 28.2)], 1)):
    H.leg(R, pid, pts, LEG, (3.2, 2.6, 2), foot=ft)

# body: forceps, ringed abdomen, wing covers, neck shield
p = R.part('body')
for pts, w in (([(13, 14.5), (8.5, 12), (6, 7.5), (7.5, 3.5), (10.5, 2.2)], (3.2, 1.6)),    # the near prong: up, back, then hooking in
               ([(13.5, 13), (13.5, 8.5), (16, 5.5), (14.5, 3)], (2.8, 1.5))):            # the far prong, shorter, curving back to meet it
    p.add(p.m(capsule(pts, *w)), CHEST, local=True, crescent=1)
p.line([(9, 11), (7, 7.5), (8, 4.5)], CHEST[0])
abdo = union(capsule([(36, 17.5), (26, 17), (17, 15.5), (12.5, 14)], 9, 5.2), ell(34, 18, 5.5, 4.6))
ab = p.add(p.m(abdo), CHEST)
for x in (15, 18.5, 22, 25.5):                                        # the rings, sewn
    p.fill(p.m(inter(abdo, capsule([(x, 10), (x + 1, 24)], 1))), CHEST[3])
p.line([(14, 12.5), (26, 13.4)], CHEST[0])
wing = union(ell(31.5, 15.8, 6, 3.9), rect(26.5, 15.5, 36.5, 19.4))
p.add(p.m(wing), TAN)
H.stitch_line(p, [(27.5, 17.5), (28, 14.5), (31, 13), (35, 14), (36, 17)], TAN[2], gap=1)
p.add(p.m(rell(25.5, 14.5, 3, 1.6, -8)), ('#fffbe8', '#f2e4c0', '#c9a96e', '#9a6b3f'), local=True, crescent=1)    # the folded hind-wing tip
p.line([(32, 12.5), (31.5, 19.5)], TAN[3])
p.add(p.m(ell(39.8, 16.8, 4, 4.2)), DARK, local=True)                 # neck shield
p.line([(37.5, 13.5), (41.5, 13.5)], CHEST[0])

# head: heart-shaped, little jaws, a blush
p = R.part('head')
p.add(p.m(rell(52, 19.6, 2.6, 1.2, 25), rell(52.3, 17.6, 2.4, 1.1, -15)), DARK, local=True, crescent=0)
p.add(p.m(ell(46.6, 16.8, 5, 4.3), capsule([R.pv('head'), (45, 17)], 5, 5)), CHEST)
p.line([(44, 13.2), (48, 13)], CHEST[0])
p.px(49, 19, BLUSH)

p = R.part('eyes')
H.button_eye(p, 46.9, 15.9, 1.5)

# antennae: bead chains
for pid, pts in (('antL', [(44.5, 13), (43.5, 8), (41, 4.5), (37.5, 3)]), ('antR', [(48, 13), (52, 9.5), (57, 7), (62, 6.5)])):
    p = R.part(pid)
    p.add(p.m(capsule(pts, 1.6, 1.3)), CHEST, crescent=0)
    for i, ((ax, ay), (bx, by)) in enumerate(zip(pts, pts[1:])):
        for t in (.35, .8):
            p.px(ax + (bx - ax) * t, ay + (by - ay) * t, TAN[0])

R.save()
