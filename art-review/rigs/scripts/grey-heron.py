#!/usr/bin/env python3
"""grey-heron "Grey Heron" (bird rig, large, 89 x 75, 8 parts): "Stands like a statue. Strikes like lightning." (wetland, coast; lv 15)
A tall felt grey heron poised to strike: a hunched pale-grey body with a white breast fringe (body), a folded grey wing with a black
shoulder patch and slate primaries (wing, +r lifts it), a short drooping grey tail (tail), a white S-curved neck with a dotted black
stripe down its front (neck), a slim white head with the black eye stripe sweeping back into a long black plume and a long yellow
dagger bill (head), a gold eye (eyes), and very long olive-yellow stilt legs with a knobbly heel and long splayed toes
(legB darker behind, legF in front)."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from rigkit import *  # noqa

R = Rig('grey-heron')
GREY = ('#e4e6ea', '#b4b8c2', '#8b8f9c', '#5b6470')
SLATE = ('#8b8f9c', '#5b6470', '#454b56', '#2e323a')
WHITE = ('#ffffff', '#f1ece0', '#c9c5bc', '#8b8f96')
BLK = ('#4a4658', '#2e2a36', '#221e2a', '#141018')
BILL = ('#f5e08a', '#e8b83a', '#b8861a', '#7a5a14')
LEG = ('#d8c87a', '#b8a050', '#8a7638', '#5a4c22')
G = R.ground


def leg(pid, ramp):
    p = R.part(pid)
    x, y = R.pv(pid)
    knee = (x - .5, 56)
    p.add(p.m(capsule([(x, y + 1), knee], 2.2, 1.6), capsule([knee, (x + .5, G - 1)], 1.6)), ramp, flat=True)
    p.add(p.m(ell(knee[0] + .2, knee[1], 1.6, 1.4)), ramp, flat=True)                  # knobbly heel
    p.add(p.m(rect(int(x) - 3, G, int(x) + 7, G + 1)), ramp, flat=True)                   # long splayed toes
    p.px(int(x) + 1, G - 1, ramp[1]); p.px(int(x) + 3, G, ramp[3])
    p.add(p.m(ell(x, y + 1, 2.6, 2.6)), GREY if pid == 'legF' else darker(GREY), local=True)   # feathered thigh


leg('legB', darker(LEG))
leg('legF', LEG)

# tail: short, drooping
p = R.part('tail')
t = poly([(35, 31), (25, 34.5), (20, 37.5), (22, 39.5), (35, 38)])
p.add(p.m(t), SLATE, local=True)
p.line([(32, 35), (23, 37.5)], SLATE[3])

# body: hunched grey body, white breast fringe
p = R.part('body')
bod = union(rell(44, 33, 14.5, 8.5, -12), ell(53, 29, 5.5, 5))
p.add(p.m(bod), GREY, stitch=GREY[3])
fr = inter(bod, rell(54, 34, 5, 8, 15))
p.add(p.m(fr), WHITE)
for x, y in ((53, 37), (55, 39), (57, 36), (52, 40)):                                 # hanging breast plumes
    p.line([(x, y), (x, y + 2)], WHITE[2])

# wing: folded grey wing, black shoulder, slate primaries
p = R.part('wing')
w = union(poly([(37, 27), (47, 26), (51, 29), (50, 33), (44, 37), (33, 39.5), (26, 39), (30, 32)]), rell(42, 29.5, 8.5, 4.5, -8))
wm = p.add(p.m(w), GREY, stitch=None)
p.edge(wm, GREY[3], sides=((0, -1),))
p.add(p.m(inter(w, poly([(24, 34), (36, 33), (42, 36), (36, 41), (24, 41)]))), SLATE)   # slate primaries
p.add(p.m(inter(w, rell(50, 30, 1.6, 3.2, 20))), BLK, flat=True)                         # black shoulder patch
for a, b in (((44, 30), (31, 34.5)), ((46, 33), (34, 37.5))):
    p.line([a, b], GREY[2])

# neck: white S-curve with a dotted black stripe
p = R.part('neck')
path = [(53.5, 30), (57.5, 25.5), (55, 19), (57.5, 12.5)]
p.add(p.m(capsule(path, 7, 5)), WHITE)
for (x, y) in ((58, 24), (57, 22), (56, 20), (56, 18), (57, 16)):
    p.px(x, y, BLK[1])
p.line([(55, 26), (53, 28)], GREY[1])                                                   # grey nape where it meets the back

# head: white head, black stripe into the plume, long dagger bill
p = R.part('head')
skull = union(ell(60.5, 8.2, 5.8, 4.8), capsule([(57.5, 12), (59, 9)], 5))
p.add(p.m(skull), WHITE)
p.add(p.m(inter(skull, capsule([(55, 4.8), (63, 4.8), (66, 6)], 2.2))), BLK, flat=True)           # the black brow stripe
p.add(p.m(capsule([(56, 5.2), (46, 4), (38, 3.6)], 2.2, 1), capsule([(55.5, 6.5), (48, 7.5), (42, 8)], 1.8, .9)), BLK, local=True)   # long nape plume
bill = poly([(64, 6.8), (75, 8.3), (87, 10.2), (75, 11.3), (64, 12)])
p.add(p.m(bill), BILL, local=True)
p.line([(65, 9.6), (84, 10.2)], BILL[3])                                               # the mouth line
p.px(67, 8, BILL[3])

# eyes: a gold eye in the stripe
p = R.part('eyes')
ex, ey = 62, 6
p.add(p.m(ell(ex + 1, ey + 1, 2.2, 2.0)), (GOLD[0],) * 4, flat=True)
p.add(p.m(rect(ex + 1, ey, ex + 2, ey + 2)), (INK,) * 4, flat=True)
p.px(ex, ey, CREAM)

R.save()
