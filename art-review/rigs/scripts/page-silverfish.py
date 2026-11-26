#!/usr/bin/env python3
"""page-silverfish "Page Silverfish" (bug.plain rig, 85 x 33, 8 parts): "A silver nibbler, no longer than a thumb, with a clay-grey
back. It only wants to read your pockets." (small, lv 18, trek ch2 Drowned Library; Silverfish Scales)
A felt silverfish in profile, long, low and carrot-shaped: a shiny silver body tapering from a round front to a thin tail, a clay-grey
back stripe, rows of pale scale chevrons, sewn segment seams, and three long bristle tails fanning out behind (body); a round silver
head with a torn scrap of a book page in its jaws, two lines of writing on it (head); one button eye (eyes); two long whippy feelers
(antL swept back over the body, antR forward); six short splayed legs under the front half, two per part (leg1..leg3).
Silhouette: the longest, flattest, most streamlined piece of the batch, all lines and points."""
import importlib, math, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from rigkit import *  # noqa
H = importlib.import_module('_crawler_shale-slater')

R = Rig('page-silverfish')
SILVER = ('#f4f6fa', '#c9d0dc', '#98a1b2', '#68707f')
CLAY = ('#c4b4a4', '#9c8a7a', '#76665a', '#54483f')
LEGC = darker(SILVER)

# legs: short and splayed, a near and a far one per part
for pid, feet in (('leg1', ((25.5, 27), (29, 27.2))), ('leg2', ((37.5, 27.2), (42, 27.2))), ('leg3', ((48, 27.2), (53.5, 27)))):
    p = R.part(pid)
    x, y = R.pv(pid)
    for k, f in enumerate(feet):
        ramp = darker(LEGC) if k == 0 else LEGC
        knee = (x + (k - .5) * 3.5, y + 4)
        H.thin_leg(p, [(x + (k - .5) * 1.5, y - 1), knee, f], ramp, 2.4, 1.6)

# body: the tapering silver carrot, the clay back, the scale chevrons, three bristle tails
p = R.part('body')
spine = [(50, 18.5), (40, 18.8), (30, 19.6), (21, 20.6), (15, 21.4)]
body = capsule(spine, 11, 3)
for q in ([(16, 21.4), (8, 17), (3, 13.5)], [(16, 21.6), (8, 21.8), (2.5, 22)], [(16, 21.8), (9, 25), (4, 27.5)]):
    p.add(p.m(capsule(q, 1.8, 1.2)), CLAY, local=True, crescent=0)
p.add(p.m(body), SILVER, stitch=None)
back = inter(body, lambda x, y: y < 18.6 + (50 - x) * .07 - (3.2 * max(0.0, x - 15) / 35))
H.blob(p, p.m(back), CLAY)
bm = p.m(body)
for sx in range(19, 49, 4):     # segment seams, and a pale scale chevron in each segment
    w = 1.5 + 4 * (sx - 15) / 35
    cy = 18.6 + (50 - sx) * .07
    for y in range(int(cy - w), int(cy + w) + 1):
        if (sx, y) in bm:
            p.px(sx, y, SILVER[2] if y > cy - w * .35 else CLAY[3])
    if sx < 47:
        p.line([(sx + 1, cy - .3), (sx + 2.5, cy + w * .45), (sx + 1, cy + w * .9)], SILVER[0])
p.fill(p.m(inter(body, lambda x, y: y > 21.6 + (50 - x) * .02)), SILVER[2])   # shaded belly

# head: round, with a scrap of page in its jaws
p = R.part('head')
hd = union(ell(53.5, 18.6, 5.5, 4.6), capsule([R.pv('head'), (52, 18.5)], 7, 7))
page = poly([(56.5, 19), (65, 16.8), (66.5, 19.5), (65.5, 20.8), (67, 22.5), (65.6, 24.2), (66.4, 26), (57.5, 26.5)])
p.add(p.m(page), ('#ffffff', '#fff8e0', '#e8d9a8', '#c9a96e'), local=True, crescent=1)
for yy in (19.6, 21.8, 24):
    p.line([(59.5, yy + .5), (63.5, yy - .4)], WATER[3])          # lines of writing, in faded blue ink
p.px(64, 25, '#e8d9a8'); p.px(65, 18, '#e8d9a8')
p.add(p.m(hd), SILVER)
H.blob(p, p.m(inter(hd, lambda x, y: y < 16 - (x - 52) * .1)), CLAY)
p.add(p.m(ell(56.5, 20.6, 1.2, .9)), (BLUSH,) * 4, flat=True)
p.line([(57.5, 21.7), (59, 22.3)], INK)        # the jaw biting the page

p = R.part('eyes')
H.button_eye(p, 54, 17.4, 1.9, look=1)

for pid, pts in (('antL', [(54.5, 15), (50, 7), (43, 3)]), ('antR', [(57, 15.5), (65, 8), (72, 6.5), (76, 9)])):
    p = R.part(pid)
    p.add(p.m(capsule(pts, 1.9, 1.2)), CLAY, local=True, crescent=0)

R.save()
