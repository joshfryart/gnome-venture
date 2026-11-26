#!/usr/bin/env python3
"""snow-owl-monarch "Snow Owl Monarch" (bird rig, 55 x 86, 8 parts): "Ruler of the white silence." (boss, tundra and mountain, level 30)
A huge, broad felt snowy owl king in three-quarter view, frost-white with an icy blue shade: a big pear body with sparse black
chevron flecks and a soft frost-blue belly seam (body), a long white wing barred in black flecks with a pointed tip (wing, +r lifts
it), a short barred tail fan behind (tail), a wide flat-topped round head with a stern grey brow over two round lemon-yellow eyes,
a small dark beak half buried in face feathers and a gold felt crown set with ice-blue gems (head, eyes), big fluffy feathered
trousers (thighs) and snowshoe feet of shaggy white felt with black talons (legB darker behind, legF in front)."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from rigkit import *  # noqa

R = Rig('snow-owl-monarch')
SNOW = ('#ffffff', '#eef3f4', '#bcd0da', '#7f98a8')
FLECK = '#2b2630'
ICE = WATER
G = R.ground + 1


def leg(pid, ramp):
    p = R.part(pid)
    x, y = R.pv(pid)
    p.add(p.m(capsule([(x, y - 1), (x + .5, G - 4)], 7, 6.5), ell(x + 2, G - 2.6, 6, 2.6)), ramp)
    p.pxs([(int(x) + 8, G - 1), (int(x) + 8, G - 2), (int(x) + 5, G - 1), (int(x) + 2, G - 1), (int(x) - 3, G - 1)], INK)   # black talons
    p.pxs([(int(x) + 4, G - 2), (int(x) + 1, G - 2), (int(x) + 4, G - 3), (int(x) + 1, G - 3)], ramp[2])                      # toe seams
    p.pxs([(int(x) + 1, G - 4), (int(x) + 4, G - 4), (int(x) - 1, G - 8)], ramp[3])                    # shaggy felt ticks


def flecks(p, pts, col=FLECK):
    for x, y in pts:                                         # small black chevrons
        p.px(x, y, col); p.px(x + 1, y + 1, col); p.px(x + 2, y, col)


p = R.part('tail')
tail = poly([(17, 54), (6, 67), (8.5, 72), (14, 72.5), (22, 62)])
p.add(p.m(tail), SNOW)
p.line([(9, 68), (15, 67)], FLECK); p.line([(12, 63), (18, 62)], FLECK)

leg('legB', darker(SNOW))

p = R.part('body')
bod = union(ell(28, 52, 17, 19.5), ell(30, 36, 13, 8))
p.add(p.m(bod), SNOW, stitch=SNOW[2])
p.line([(41, 42), (43, 50), (42, 60), (38, 67)], SNOW[2])                    # frost-blue belly seam
flecks(p, ((38, 45), (31, 49), (36, 54), (40, 58), (29, 60), (34, 63)))
collar = inter(bod, ell(32, 37.5, 14, 4.2))
p.add(p.m(collar), ICE, local=True)                                          # ice-blue royal collar, ermine-spotted
p.pxs([(24, 37), (29, 39), (34, 38), (44, 37)], SNOW[0]); p.pxs([(25, 38), (35, 39)], FLECK)
p.add(p.m(ell(40.5, 39.5, 1.8, 1.8)), GOLD, local=True, crescent=0)          # gold clasp

leg('legF', SNOW)

p = R.part('thighs')
th = union(ell(24, 68, 6.5, 5), ell(35, 68, 7, 5.2))
p.add(p.m(th), SNOW, local=True)
p.pxs([(20, 72), (23, 73), (26, 72), (31, 73), (34, 73), (38, 72)], SNOW[2])
p.line([(30, 65), (30, 71)], SNOW[2])

p = R.part('wing')
wing = union(ell(23, 44, 8, 8), capsule([(22, 42), (17, 58), (10.5, 72)], 15, 4))
p.add(p.m(wing), SNOW, local=True)
p.edge(p.m(wing), SNOW[3], sides=((1, 0), (0, 1), (-1, 0)))
flecks(p, ((19, 41), (24, 43), (17, 48), (22, 50), (15, 55), (20, 57), (13, 62), (17, 64), (12, 68)))
p.line([(14, 60), (20, 52)], SNOW[2]); p.line([(12, 66), (17, 60)], SNOW[2])   # primary seams

p = R.part('head')
hx, hy = 31, 21.5
head = union(ell(hx, hy, 14.5, 12), ell(29, 29, 13, 5.5))
p.add(p.m(head), SNOW, stitch=SNOW[2])
p.add(p.m(poly([(37.5, 24), (41.8, 24), (40.6, 28.5), (39, 28)])), SOOT, local=True, crescent=0)   # small dark beak in the feathers
p.pxs([(37, 26), (42, 26), (36, 28)], SNOW[0])                                # face feathers over the beak
flecks(p, ((21, 15), (25, 13), (20, 21), (24, 26)))
crown = union(poly([(27, 12), (27.5, 5), (30, 8.5), (32.5, 3.5), (35, 8.5), (37.5, 5), (38, 12)]))
p.add(p.m(crown), GOLD, local=True, crescent=1)
p.line([(27, 11), (37, 11)], GOLD[3])
for gx in (29, 32, 35):                                                       # ice-blue gems on the band
    p.px(gx, 10, ICE[1])
p.px(32, 6, ICE[0]); p.px(32, 7, ICE[2])

p = R.part('eyes')
for ex in (36.0, 42.6):
    p.add(p.m(ell(ex, 21.8, 3, 3)), (INK,) * 4, flat=True)
    p.add(p.m(ell(ex, 21.8, 2.1, 2.1)), ('#f5e04a',) * 4, flat=True)
    p.add(p.m(rect(ex, 21, ex + 1.6, 23.4)), (INK,) * 4, flat=True)
    p.add(p.m(inter(ell(ex, 21.8, 3, 3), lambda x, y: y < 20.6)), (SNOW[3],) * 4, flat=True)   # heavy stern lid
p.line([(33, 18.5), (39, 20.2)], INK); p.line([(40, 20.2), (45, 18.5)], INK)  # the royal scowl

R.save()
