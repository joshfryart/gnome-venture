#!/usr/bin/env python3
"""hermit-crab-hoarder "Hermit Crab Hoarder" (crab rig, front view, 79 x 63, 10 parts): "Wears three stolen shells at once and is still
looking for a fourth." (medium, lv 12, island and coast; Spiral Shell, Cowrie Shell, Sea Glass)
A small tangerine felt hermit crab under a wobbly tower of three stolen shells: a fat blue spiral shell with wound felt bands at
the bottom, a spotted cream cowrie with its toothed slit balanced on it, and a little pink turret shell on top, the tower leaning a
little (shell, behind the body, its pivot inside the bottom shell); a round soft orange body with a fuzzy cream bib, a little "o" of a
mouth and blush (body); two eyes on long thin stalks, wide and greedy (eyeL / eyeR, sprung); a big left claw clutching a green piece
of sea glass (clawL, the bigger claw like a real hermit) and a small open right claw (clawR); four legs banded orange and cream
(leg1..leg4, behind). Silhouette: a tall leaning shell tower, unlike its flat, plumed and lopsided siblings."""
import math, os, sys
from importlib import import_module
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from rigkit import *  # noqa
CK = import_module('_crab_shore-crab')

R = Rig('hermit-crab-hoarder')
X = CK.mirror(R)
TANG = ('#fbc08a', '#f08a4a', '#c8602c', '#7a3a1f')
MOON = ('#f0faff', '#c4e4f2', '#8ec0da', '#1f4a6a')
BAND = ('#8fc4e0', '#5a98bc', '#3f7ea4', '#1f4a6a')
COWRIE = ('#fffaf0', '#fff3c8', '#e8cf98', '#9a6b3f')
SPOT = '#a8683a'
TURRET = PETAL
GLASS = ('#e8fbf2', '#9ad8b0', '#5aa878', '#2f6a4a')
cx = R.pv('body')[0]

for pid, knee, foot in (('leg1', (12, 45), (4, 57.5)), ('leg2', (20.5, 48.5), (14, 57.5))):
    for q, k2, f2 in ((pid, knee, foot), ('leg4' if pid == 'leg1' else 'leg3', (X(knee[0]), knee[1]), (X(foot[0]), foot[1]))):
        CK.leg(R, q, k2, f2, TANG if pid == 'leg1' else darker(TANG), bands=CREAM if pid == 'leg1' else PAPER[2], tip=TANG[3])

p = R.part('shell')                                                                         # the stolen shell tower
p.add(p.m(rell(31.5, 7, 3.4, 6.5, -20), poly([(28, 10), (30, 1.5), (31.5, 1.5), (36, 11)])), TURRET, local=True, crescent=1)
for y in (5, 8):
    p.line([(28.5 + (y - 5) * .4, y + 1), (34 + (y - 5) * .4, y - .5)], TURRET[2])
cow = rell(33.5, 15.5, 8.6, 6, -12)
p.add(p.m(cow), COWRIE, local=True)
for x, y in ((28, 13), (31, 11.5), (35, 10.5), (38.5, 11), (30, 16), (34, 14), (38, 14.5), (27, 17)):
    p.add(p.m(ell(x + .5, y + .5, 1.1, 1.1)), (SPOT,) * 4, flat=True)                        # brown spots
p.line([(26.5, 19), (33, 18.5), (40.5, 15.5)], COWRIE[3])                                       # the toothed slit
moon = union(ell(35.5, 30, 13.5, 11.5), ell(29, 37, 6, 3.5))
p.add(p.m(moon), MOON, stitch=None)
def swirl(x, y, c=(37, 28.5)):                                                                  # spiral bands winding in to the apex
    r, t = math.hypot(x - c[0], (y - c[1]) * 1.1), math.atan2(y - c[1], x - c[0])
    return ((r - 4.6 * t / (2 * math.pi)) // 2.3) % 2 == 0 and r > 1.5
p.add(p.m(inter(moon, swirl)), BAND, ref=p.m(moon))
p.add(p.m(ell(37.5, 28.5, 1.6, 1.6)), (MOON[0],) * 4, flat=True)                              # the apex

p = R.part('body')
bod = union(ell(cx, 46, 19, 8.5), ell(cx, 40, 11, 6.5), ell(cx - 15, 40.5, 3.5, 3), ell(cx + 15, 40.5, 3.5, 3))
p.add(p.m(bod), TANG)
p.edge(p.m(bod), TANG[3], sides=((0, -1),))                                                   # its top seam where it sits on the shells
bib = inter(ell(cx, 49, 11, 5.5), lambda x, y: y > 45)
p.add(p.m(bib), PAPER, local=True)
for x in range(-9, 10, 3):
    p.px(cx + x, 45 + (abs(x) > 6), PAPER[2])                                                   # the fuzzy edge of the bib
p.add(p.m(rect(cx - 1, 42, cx + 1, 44)), (INK,) * 4, flat=True)                                # a greedy little "o"
CK.blush(p, cx - 6.5, 41.5); CK.blush(p, cx + 6.5, 41.5)

for pid in ('eyeL', 'eyeR'):
    CK.stalk_eye(R, pid, 25, TANG, knob=3.6, stalk=2, look=1 if pid == 'eyeL' else -1, lean=-1.5 if pid == 'eyeL' else 2)

p = R.part('clawL')                                                                            # big claw clutching sea glass
a = R.pv('clawL')
p.add(p.m(capsule([a, (16, 39)], 5, 4.4), capsule([(16, 39), (12, 33)], 4.4, 5)), TANG, crescent=1)
p.add(p.m(rell(11, 21.5, 3.8, 3, 20)), GLASS, local=True, crescent=1)                         # the sea glass
p.px(10, 20, '#ffffff')
p.add(p.m(capsule([(7, 26), (5, 21), (7.5, 18)], 4.2, 2.4), capsule([(15.5, 26), (17, 21.5), (14.5, 18.5)], 4.2, 2.4)), TANG, local=True, crescent=1)
p.add(p.m(ell(11, 29, 7, 5.6)), TANG, local=True)
p.pxs([(int(R.pv('clawL')[0]) - 13, 30), (int(R.pv('clawL')[0]) - 11, 32)], TANG[0])
p.line([(6.5, 26.5), (10, 25), (15, 26)], TANG[2])

p = R.part('clawR')                                                                            # small open claw
a = R.pv('clawR')
p.add(p.m(capsule([a, (62, 38)], 4.4, 3.8), capsule([(62, 38), (65, 33)], 3.8, 4)), TANG, crescent=1)
p.add(p.m(capsule([(63, 28), (61.5, 24.5), (63, 22)], 3.4, 1.8), capsule([(68, 28), (70, 24), (68.5, 21.5)], 3.4, 1.8)), TANG, local=True, crescent=1)
p.add(p.m(ell(65.5, 30.5, 4.6, 3.8)), TANG, local=True)
p.pxs([(63, 22), (68, 21)], TANG[3])

R.save()
