#!/usr/bin/env python3
"""pelican-parliament "Pelican Parliament" (bird rig, large, 79 x 53, 7 parts): "A solemn committee of bills. Motion carried: you are lunch."
(coast, island; lv 21; Long Feather, Sardine, Sea Glass)
A plump white felt pelican standing broadside, the chairbird of the committee: a round white body with a peachy breeding blush on
the chest (body), a folded white wing with a stitched covert seam and black flight feathers sweeping back over the tail (wing, +r
lifts it), a short white tail stub (tail), short orange legs on broad webbed feet (legB darker behind, legF in front), and the head
on an S-neck: a curly white nape crest like a barrister's wig, a very long yellow bill with a red hook tip and a deep orange pouch
hanging under it, the bulge of a sardine inside (head), and a solemn half-lidded eye (eyes)."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from rigkit import *  # noqa

R = Rig('pelican-parliament')
WHITE = ('#ffffff', '#f4f1ea', '#d6cfc2', '#a89e90')
BLACK = ('#6a6470', '#45404a', '#2e2a33', '#1e1a22')
BILL = ('#fbe39a', '#f5cf6a', '#e8a317', '#b87a14')
POUCH = ('#f8b070', '#f08a4a', '#c8602a', '#8a3a1a')
LEG = ('#f8b070', '#f08a4a', '#c8602a', '#8a3a1a')
G = R.ground


def leg(pid, ramp):
    p = R.part(pid)
    x, y = R.pv(pid)
    xi = int(x)
    p.add(p.m(capsule([(x, y - .5), (xi + .5, G - 2)], 3.2, 2.6)), ramp, flat=True)          # short shank
    web = poly([(xi - 2.5, G - 1.5), (xi + 2, G - 2.8), (xi + 7.5, G - .5), (xi + 7, G + 1), (xi - 3, G + 1)])
    p.add(p.m(web), ramp, local=True, crescent=1)                                          # broad webbed foot
    p.px(xi + 3, G, ramp[3]); p.px(xi + 5, G, ramp[3])                                      # toe seams
    p.px(xi + 3, y + 2, ramp[2]); p.px(xi + 1, y + 5, ramp[2])                              # knee scutes


leg('legB', darker(LEG))
leg('legF', LEG)

# tail: a short white tail stub poking back from under the body
p = R.part('tail')
p.add(p.m(poly([(30.5, 26.5), (22, 27.5), (16.5, 30), (19, 32.5), (24, 34), (31, 34)])), WHITE, local=True)
p.line([(26, 30), (19, 30.5)], WHITE[3])

# body: round, white, a peach blush on the chest, a stitched belly seam
p = R.part('body')
bod = union(rell(39.5, 30, 15.5, 10, -6), ell(49.5, 27, 7, 8), ell(29, 31.5, 6, 5))
p.add(p.m(bod), WHITE, stitch=WHITE[2])
p.add(p.m(inter(bod, ell(53, 27.5, 4.5, 6.5))), ('#fff3e8', '#fde0cc', '#f2b898', '#d08a6a'), flat=True)   # breeding blush
p.line([(31, 38), (38, 39.5), (46, 38.5)], WHITE[2])

# wing: folded white wing, black primaries sweeping back over the tail
p = R.part('wing')
WING = ('#ffffff', '#ece8e0', '#cbc3b6', '#8e8476')
w = poly([(34, 19.5), (41, 19), (47, 22), (49, 27), (45, 32), (38, 34.5), (28, 36), (14, 36.5), (12, 35), (21, 30), (28, 25)])
wm = p.add(p.m(w), WING, stitch=None)
p.edge(wm, WING[3], sides=((0, -1), (1, 0), (0, 1)))
prim = inter(w, poly([(8, 30), (31, 26.5), (36, 38), (8, 38)]))
p.add(p.m(prim), BLACK)
for a, b in (((30, 30), (16, 34)), ((32, 33), (20, 35.5)), ((27, 28), (19, 31.5))):
    p.line([a, b], BLACK[0])
p.line([(31, 27), (36, 36)], WING[3])
for (x, y) in ((38, 23), (42, 24), (45, 26), (37, 27), (41, 28), (44, 30)):            # covert scallops
    p.line([(x - 1, y), (x + 1, y + 1)], WHITE[2])

# head: S-neck, wig crest, long yellow bill, the orange pouch with a sardine bulge
p = R.part('head')
neck = capsule([R.pv('head'), (52, 19), (50.5, 15), (52.5, 11.5)], 7.5, 6.5)
skull = union(ell(54.5, 11, 5.3, 4.6), neck)
p.add(p.m(skull), WHITE)
for c in ((47.5, 8.5), (46.5, 11.5), (48.5, 6), (47.5, 14)):                            # curly wig crest at the nape
    p.add(p.m(ell(c[0], c[1], 2.3, 2)), WHITE, local=True, crescent=1)
    p.px(c[0] - .5, c[1] + .5, WHITE[3]); p.px(c[0] + .5, c[1] - .5, WHITE[3])
pouch = poly([(57, 13.5), (64, 15.5), (74, 15.5), (70, 19), (63, 22.5), (57.5, 20), (55, 16)])
p.add(p.m(pouch), POUCH, local=True)
p.add(p.m(ell(63.5, 19, 3, 1.8)), (POUCH[0], POUCH[0], POUCH[1], POUCH[1]), local=True)   # the sardine bulge
p.line([(60, 17), (70, 16.5)], POUCH[2])
bill = poly([(57.5, 9), (66, 10.5), (76, 12), (77.5, 14), (76, 16), (74, 14.5), (65, 14), (57, 13.5)])
p.add(p.m(bill), BILL, local=True)
p.add(p.m(inter(bill, lambda x, y: x > 74)), ('#f08a4a', '#dd3a2a', '#a8241f', '#6e2038'), flat=True)    # red hook tip
p.line([(59, 11.5), (73, 13)], BILL[3])                                                 # bill ridge
p.line([(57, 13), (74, 14.5)], INK)                                                     # gape

# eyes: solemn, half lidded
p = R.part('eyes')
ex, ey = 54, 12
p.add(p.m(ell(ex + 1, ey + 1, 3.3, 2.9)), (BILL[1],) * 4, flat=True)                     # bare yellow eye skin
p.add(p.m(ell(ex + 1, ey + 1, 2.2, 2.0)), (CREAM,) * 4, flat=True)
p.add(p.m(rect(ex + 1, ey, ex + 3, ey + 2)), (INK,) * 4, flat=True)
p.add(p.m(inter(ell(ex + 1, ey + 1, 3.3, 2.9), lambda x, y: y < ey)), (WHITE[2],) * 4, flat=True)   # heavy solemn lid
p.line([(ex - 2, ey), (ex + 3, ey)], INK)

R.save()
