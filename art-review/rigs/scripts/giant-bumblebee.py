#!/usr/bin/env python3
"""giant-bumblebee "Giant Bumblebee" (bug.wasp rig, 91 x 64, 11 parts): "A round fuzzy gentleman the size of a pony to a gnome,
warm, cross, and very hard to argue with." (grassland, forest; Wild Honeycomb, Beeswax)
A big round felt bumblebee in profile: a huge fuzzy abdomen in gold and umber bands with a cream "buff" tail (abdo, behind the body),
a round fuzzy thorax with a gold collar (body), a dark round head with a tan muzzle, a cross little mouth and a red bow tie (head),
one button eye behind a gold monocle (eyes: the gentleman), elbowed antennae with knobs (antL / antR), two pale stitched felt wings
standing up behind (wingB darker, wingF), and three thin umber legs, the hind one carrying a gold pollen basket (leg1..leg3)."""
import math, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from rigkit import *  # noqa

R = Rig('giant-bumblebee')
FUZZ = GOLD
DARK = ('#74462a', '#4a2c1a', '#2a1a10', '#2a1a10')
BUFF = ('#ffffff', '#fff3c8', '#f2e4c0', '#c9a96e')
WING = ('#ffffff', '#e4f6ff', '#a9d6ea', '#3f8fb0')


def rell2(a, b, w):
    """an ellipse whose long axis runs from a to b, w wide"""
    cx, cy = (a[0] + b[0]) / 2, (a[1] + b[1]) / 2
    L = math.hypot(b[0] - a[0], b[1] - a[1]) / 2
    return rell(cx, cy, L, w / 2, math.degrees(math.atan2(b[1] - a[1], b[0] - a[0])))


def fuzz(p, mask, col, step=3):
    """fur ticks: every few px along the top of the mask, a 1 px darker tick going in"""
    for (x, y) in sorted(mask):
        if (x, y - 1) not in mask and (x + y) % step == 0 and (x, y + 1) in mask:
            p.px(x, y + 1, col)


for pid, foot in (('leg1', (36, 57.5)), ('leg2', (47, 58)), ('leg3', (58.5, 57.5))):
    p = R.part(pid)
    x, y = R.pv(pid)
    knee = (x - 3.5, 51) if pid != 'leg3' else (x + 2.5, 51)
    p.add(p.m(capsule([(x, y - 1), knee], 3.2, 2.6), capsule([knee, foot], 2.6, 2)), DARK, crescent=0)
    p.px(int(foot[0]) + 1, int(foot[1]), DARK[0])
    if pid == 'leg1':
        p.add(p.m(ell(knee[0] - .5, knee[1] + 1, 3.4, 2.8)), FUZZ, local=True, crescent=1)   # the pollen basket

p = R.part('wingB')
wb = rell2(R.pv('wingB'), (18, 10), 12)
p.add(p.m(wb), darker(WING), stitch=WING[3])
p = R.part('wingF')
wf = rell2(R.pv('wingF'), (30, 3.5), 14)
p.add(p.m(wf), WING, stitch=WING[2])
p.line([(45, 24), (40, 15), (32, 6)], WING[2])                                            # a vein

p = R.part('abdo')
ab = rell(30.5, 37.5, 17.5, 14.5, -8)
p.add(p.m(ab), FUZZ)
ax = lambda x, y: (x - 30.5) * math.cos(math.radians(-8)) + (y - 37.5) * math.sin(math.radians(-8))   # position along the abdomen
p.add(p.m(inter(ab, lambda x, y: 3 < ax(x, y) < 9.5)), DARK)
p.add(p.m(inter(ab, lambda x, y: -9 < ax(x, y) < -3)), DARK)
p.add(p.m(inter(ab, lambda x, y: ax(x, y) < -12.5)), BUFF)
fuzz(p, p.m(ab), FUZZ[2])
p.px(13, 40, DARK[1]); p.px(12, 40, DARK[1])                                              # the tip of the (polite, folded) sting

p = R.part('body')
th = ell(50, 34.5, 12, 10.5)
p.add(p.m(th), DARK, stitch=None)
collar = inter(th, lambda x, y: x > 45.5 - (y - 34) * .3)
p.add(p.m(collar), FUZZ)
fuzz(p, p.m(th), FUZZ[2], 2)
for q in ((44, 24), (49, 23), (54, 23), (58, 25)):                                        # fuzz tufts on the top edge
    p.add(p.m(ell(q[0], q[1] + 1.2, 1.6, 1.6)), FUZZ, local=True, crescent=0)

p = R.part('head')
hd = union(ell(64, 35, 8.6, 8.5), capsule([R.pv('head'), (60, 35)], 9, 9))
p.add(p.m(hd), DARK)
p.add(p.m(inter(ell(70, 38.5, 4.4, 4), hd)), ('#e0c690', '#c9a96e', '#9a6b3f', '#74462a'))    # tan muzzle
p.line([(69, 40), (70, 39.5), (72, 40)], INK)                                               # a cross little mouth
p.add(p.m(union(poly([(57, 40), (60, 41.8), (57, 43.6)]), poly([(63, 40), (60, 41.8), (63, 43.6)]))), EMBER, local=True, crescent=0)   # bow tie
p.px(60, 41, EMBER[2]); p.px(60, 42, EMBER[2])
fuzz(p, p.m(hd), DARK[0], 2)

p = R.part('eyes')
ex, ey = 65.6, 32.8
p.add(p.m(ell(ex, ey, 3.8, 3.8)), (GOLD[1],) * 4, flat=True)                              # the monocle rim
p.add(p.m(ell(ex, ey, 2.8, 2.8)), (CREAM,) * 4, flat=True)
p.add(p.m(rect(65, 32, 67, 35)), (INK,) * 4, flat=True)
p.px(64, 31, '#ffffff')
p.add(p.m(capsule([(67.5, 36.2), (68.5, 39.5)], 1)), (GOLD[1],) * 4, flat=True)            # monocle cord
p.line([(62, 28.5), (67, 29.5)], INK)                                                       # a cross brow above

for pid, pts in (('antL', [(59, 27.2), (57, 20), (59.5, 13.5)]), ('antR', [(65, 27.2), (68, 20.5), (73, 16)])):
    p = R.part(pid)
    p.add(p.m(capsule(pts, 2.4, 2)), DARK, crescent=0)
    p.add(p.m(ell(pts[-1][0], pts[-1][1], 2, 2)), DARK, local=True, crescent=0)
    p.px(int(pts[-1][0]) - 1, int(pts[-1][1]) - 1, DARK[0])

R.save()
