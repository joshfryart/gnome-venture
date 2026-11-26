#!/usr/bin/env python3
"""deep-octopus "Deep Octopus" (octo rig, front view, 77 x 67, 9 parts, large lv 37, island and coast): "Eight arms, three hearts, and not
one of them is friendly today." (Sea Glass, Pearl, Glowing Bead)
A deep-water octopus in brick-red felt: a tall soft mantle that droops back a little, sewn from panels with a dashed seam, dotted
with glowing sea-green beads (the Glowing Bead drop) and pale felt freckles, a fat skirt where the arms join, a puckered siphon on one
cheek and a cross stitched frown (body); seven thick arms t1..t7 fanning out over the sea floor, each tapering into a tight curl with
cream suckers along its underside, alternate arms one shade darker so they separate (t1..t7, behind, sprung); eyes = two big gold eyes
with the octopus's flat bar pupils under heavy lids slanted in a scowl (blink squashes them on the pivot).
Silhouette: a tall bulb on a wide fringe of curled arms; the crab of the batch is wide and clawed, the two eels long and low."""
import math, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from rigkit import *  # noqa

R = Rig('deep-octopus')
RED = ('#f0896a', '#c8443a', '#962c2e', '#5e1a26')
RED2 = ('#c8443a', '#a83636', '#7e2428', '#5e1a26')
BEAD = ('#e8fbf2', '#9fe8c8', '#4fb89a', '#2f7a6a')
SUCK = ('#fff3c8', '#f6d2b8', '#e0a890', '#a86a5a')
cx = R.pv('body')[0]

# arms: from the pivot under the skirt down to the floor, out, and into a curl
XE = (9, 17.5, 27, 37, 49, 59, 67.5)
for i, pid in enumerate(R.ids[:7]):
    p = R.part(pid)
    a = R.pv(pid)
    s = -1 if i < 3 else 1
    xe = XE[i]
    path = [a, (a[0] + (xe - a[0]) * .45, 53.5), (xe, 59), (xe + s * 3.5, 58), (xe + s * 4, 54.5), (xe + s * 1.8, 53.2)]
    ramp = RED if i % 2 == 0 else RED2
    arm = capsule(path, 7.5 if i in (0, 6) else 7, 2.2)
    p.add(p.m(arm), ramp, crescent=1)
    for t in (.45, .62, .78):                                       # cream suckers on the underside, leading into the curl
        k = min(int(t * (len(path) - 1)), len(path) - 2)
        f = t * (len(path) - 1) - k
        x = path[k][0] + (path[k + 1][0] - path[k][0]) * f
        y = path[k][1] + (path[k + 1][1] - path[k][1]) * f
        p.add(p.m(inter(arm, ell(x, y + 1.6, 1.1, .9))), SUCK, flat=True)
    p.px(a[0] + (xe - a[0]) * .3, 50, ramp[3])                     # a felt crease near the root

# body: the drooping mantle, skirt, seams, glowing beads, siphon
p = R.part('body')
mantle = rell(cx - 1.5, 20, 17, 18.5, -10)
skirt = ell(cx, 40, 18.5, 7.5)
p.add(p.m(mantle, skirt, ell(cx - .5, 29, 17.2, 12)), RED)
p.add(p.m(inter(ell(cx, 42.5, 18, 5.5), lambda x, y: y > 41)), RED2, local=True)   # the skirt shadow where the arms join
for k, dx in enumerate((-8, 8)):                                    # sewn panel seams down the mantle
    for y in range(5, 24):
        x = cx - 1.5 + dx * (1 - ((y - 20) / 21) ** 2) ** .5 - (y - 20) * .17
        if (y // 2) % 2 == 0:
            p.px(x, y, RED[3])
for x, y, r in ((27, 12, 1.6), (44, 8, 1.4), (49, 18, 1.8), (33, 5, 1.2), (24, 22, 1.2), (39, 15, 1.1)):   # glowing beads
    p.add(p.m(ell(x, y, r + .9, r + .9)), (RED[0],) * 4, flat=True)
    p.add(p.m(ell(x, y, r, r)), BEAD, local=True, crescent=1)
p.pxs([(30, 17), (42, 22), (36, 9), (47, 12), (22, 16)], RED[0])                 # pale freckles
p.add(p.m(rell(53, 34, 2.6, 1.8, -25)), RED2, local=True)                       # the siphon on the cheek
p.px(54, 34, RED[3])
p.line([(35, 37), (37, 36), (40, 36), (42, 37)], INK)                            # cross little frown

# eyes: big gold eyes with flat bar pupils, scowling lids
p = R.part('eyes')
ey = 29.5
for ex, s in ((31, -1), (46, 1)):
    p.add(p.m(ell(ex, ey, 5.4, 4.8)), (INK,) * 4, flat=True)
    p.add(p.m(ell(ex, ey, 4.4, 3.8)), ('#f5cf6a',) * 4, flat=True)
    p.add(p.m(rect(ex - 3, ey - .5, ex + 3, ey + 1.5)), (INK,) * 4, flat=True)   # the bar pupil
    p.px(ex - 2, ey - 2, '#ffffff')
    lid = lambda x, y, ex=ex, s=s: y < ey - 1.2 + s * (ex - x) * .45
    p.add(p.m(inter(ell(ex, ey, 5.4, 4.8), lid)), (RED[2],) * 4, flat=True)
    p.line([(ex - 5.5, ey - 2 + s * 2.2), (ex + 5.5, ey - 2 - s * 2.2)], INK)

R.save()
