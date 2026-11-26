#!/usr/bin/env python3
"""griffon-vulture "Griffon Vulture" (bird rig, large, 69 x 61, 8 parts): "Circles very patiently. It has plenty of time." (mountain, desert; lv 24)
A big hunched felt griffon vulture, waiting: a sandy buff body (body) with a thick fluffy cream ruff round the base of the neck,
a broad folded wing with buff coverts over dark brown flight feathers hanging low like a cloak (wing, +r lifts it), a short dark
wedge tail (tail), shaggy buff trousers (thighs), stout grey legs with dark talons (legB darker behind, legF in front), a long bare
neck in white down with a small pale bluish-grey head and a heavy horn hooked beak with a dark tip (head), and a dark patient eye under
a drooping lid (eyes). Hunched shoulders + ruff + snaking white neck keep it apart from the upright hawk and the sleek crow."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from rigkit import *  # noqa

R = Rig('griffon-vulture')
BUFF = ('#f2dca8', '#d8b878', '#a8844a', '#74562a')
DBR = ('#8a6a50', '#5a3e2a', '#46301f', '#2e1e12')
DOWN = ('#ffffff', '#ece6dc', '#c9c0b4', '#8b8f96')
SKIN = ('#e4ecf4', '#b8c4d0', '#8b98a8', '#5b6470')
HORN = ('#fff3c8', '#e0d0a4', '#b0a070', '#7a6a44')
LEG = ('#c9c5bc', '#9a98a0', '#6e6c76', '#4a4852')
G = R.ground


def leg(pid, ramp):
    p = R.part(pid)
    x, y = R.pv(pid)
    xi = int(x)
    p.add(p.m(rect(xi - 1, y, xi + 2, G - 1)), ramp, flat=True)                       # stout 3 px shank
    p.add(p.m(rect(xi - 3, G - 1, xi + 6, G + 1)), ramp, flat=True)                  # toes
    p.cut |= {(xi - 3, G - 1), (xi + 4, G - 1), (xi + 5, G - 1)}
    p.px(xi - 3, G, INK); p.px(xi + 5, G, INK)                                      # dark talons
    p.px(xi, y + 3, ramp[2]); p.px(xi, y + 6, ramp[2]); p.px(xi, y + 9, ramp[2])


leg('legB', darker(LEG))
leg('legF', LEG)

# tail: short dark wedge, down and back
p = R.part('tail')
t = poly([(27, 30), (16, 38), (8, 45), (12, 48), (19, 45), (28, 38)])
p.add(p.m(t), DBR, local=True)
p.line([(24, 36), (12, 45)], DBR[3])

# body: hunched sandy body and the fluffy ruff
p = R.part('body')
bod = union(rell(34, 31, 14, 14, -20), ell(40, 21, 7, 6))
p.add(p.m(bod), BUFF, stitch=BUFF[3])
for (x, y) in ((42, 33), (45, 30), (43, 38), (39, 40), (46, 35)):                     # streaky breast
    p.line([(x, y), (x - 1, y + 2)], BUFF[2])
ruff = union(ell(40.5, 20.5, 7.5, 5), *[ell(40.5 + 7.6 * math.cos(a), 20.5 + 5.2 * math.sin(a), 1.7) for a in [i * .62 for i in range(11)]])
rm = p.add(p.m(ruff), ('#ffffff', '#fff8ea', '#e0d4bc', '#b0a080'))
p.edge(rm, '#c9b890')
p.pxs([(39, 18), (42, 21), (44, 18), (40, 22)], DOWN[2])

# thighs: shaggy buff trousers
p = R.part('thighs')
tr = union(ell(31, 44.5, 4.4, 3.6), ell(40, 44.5, 4.6, 3.6), ell(36, 43, 3, 2.5))
p.add(p.m(tr), BUFF)
for x in (28, 31, 34, 38, 41, 44):
    p.px(x, 47, BUFF[3])

# wing: buff coverts over a dark cloak of flight feathers
p = R.part('wing')
w = poly([(26, 19.5), (34, 18), (39, 23), (40, 31), (36, 41), (28, 48), (20, 51), (13, 47), (17, 38), (21, 27)])
wm = p.add(p.m(w), BUFF, stitch=None)
p.edge(wm, BUFF[3], sides=((0, -1), (1, 0)))
dark = inter(w, poly([(8, 34), (24, 30), (38, 33), (37, 44), (26, 54), (8, 54)]))
p.add(p.m(dark), DBR)
for a, b in (((35, 36), (16, 46)), ((34, 40), (20, 50)), ((30, 33), (17, 40))):
    p.line([a, b], DBR[3])
for (x, y) in ((28, 23), (32, 25), (26, 27), (30, 29), (35, 28)):                     # covert scallops
    p.line([(x, y), (x + 1, y + 1)], BUFF[2])

# head: long white-down neck, small pale head, heavy hooked horn beak
p = R.part('head')
neck = capsule([(42, 19), R.pv('head'), (45, 11), (48.5, 9)], 5.5, 4)
skull = ell(49.5, 8.5, 5, 4.4)
p.add(p.m(neck), ('#f4f0ea', '#d4d2d4', '#aaa8b2', '#8b8f96'))
p.add(p.m(skull), SKIN)
beak = poly([(52.5, 5.5), (58, 6), (61.5, 8.5), (62, 13), (60, 11.5), (57, 11.5), (52.5, 12)])
p.add(p.m(beak), HORN, local=True)
p.add(p.m(inter(beak, lambda x, y: x > 59)), ('#5b6470', '#343842', '#2a1a10', '#2a1a10'), flat=True)
p.line([(53, 10), (59, 10)], HORN[3])
p.px(55, 7, HORN[3])
p.add(p.m(ell(47, 13.5, 1.8, 1.4)), DOWN, flat=True)
p.pxs([(44, 15), (46, 12), (43, 18)], DOWN[2])                                       # downy fluff on the neck

# eyes: dark, patient, a heavy lid
p = R.part('eyes')
ex, ey = 48, 7
p.add(p.m(ell(ex + 1, ey + 1, 1.7, 1.6)), ('#8a5a30',) * 4, flat=True)
p.add(p.m(rect(ex, ey, ex + 2, ey + 2)), (INK,) * 4, flat=True)
p.px(ex, ey, CREAM)
p.line([(ex - 1, ey - 1), (ex + 3, ey - 1)], SKIN[3])

R.save()
