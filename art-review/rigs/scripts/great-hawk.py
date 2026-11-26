#!/usr/bin/env python3
"""great-hawk "Great Hawk" (bird rig, boss, 83 x 88, 9 parts): "A shadow that crosses the meadow, and the meadow goes quiet." (grassland; lv 28)
A big felt red-tailed hawk standing bolt upright, the boss of the meadow: a brown body with a cream chest crossed by a speckled brown
belly band (body), a long folded brown wing with pale covert scallops and dark barred primaries reaching down past the tail root
(wing, +r lifts it), a fanned rufous tail with a dark band and cream tips (tail), feathered cream trousers with brown bars (thighs),
yellow scaly legs with hooked black talons (legB darker behind, legF in front), a broad brown head with a cream throat, a heavy
yellow-cered hooked beak and a dark brow ridge (head), a few raised nape hackles that bounce on the spring (crest), and a fierce
gold eye pinned under the brow (eyes)."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from rigkit import *  # noqa

R = Rig('great-hawk')
BRN = ('#c9a96e', '#9a6b3f', '#74462a', '#4a2c1a')
DARK = ('#9a6b3f', '#74462a', '#4a2c1a', '#2a1a10')
CRM = ('#fff3c8', '#f2e4c0', '#e0c690', '#c9a96e')
RUF = ('#f5b07a', '#d8743a', '#a8502a', '#6e2e1a')
YEL = ('#f5cf6a', '#e8a317', '#b87a14', '#7a4a1f')
CLAW = '#2a1a10'
G = R.ground


def leg(pid, ramp):
    p = R.part(pid)
    x, y = R.pv(pid)
    xi = int(x)
    p.add(p.m(rect(xi - 1, y, xi + 2, G - 1)), ramp, flat=True)                       # 3 px shank
    for yy in range(int(y) + 3, G - 2, 2):
        p.px(xi - 1, yy, ramp[2])                                                    # scutes
    p.add(p.m(capsule([(xi - 2.5, G - .5), (xi + 6, G - .5)], 2), capsule([(xi + .5, G - 2), (xi + 4, G - 1.5)], 2.2)), ramp, flat=True)
    for cx in (xi - 3, xi + 6):                                                       # hooked talons
        p.px(cx, G - 1, CLAW); p.px(cx, G, CLAW)
    p.px(xi + 3, G, CLAW)


leg('legB', darker(YEL))
leg('legF', YEL)

# tail: a rufous fan angled down and back
p = R.part('tail')
fan = poly([(31, 47), (20, 56), (10, 66), (6, 71), (10, 75), (16, 76), (24, 71), (32, 60)])
p.add(p.m(fan), RUF, stitch=None)
p.add(p.m(inter(fan, poly([(4, 66), (14, 61), (25, 66), (19, 74), (9, 74)]))), (RUF[2], RUF[3], RUF[3], RUF[3]), flat=True)   # dark band
p.add(p.m(inter(fan, poly([(2, 70), (9, 67), (20, 72), (16, 79), (4, 79)]))), CRM, flat=True)                          # cream tips
for a, b in (((28, 54), (9, 70)), ((29, 57), (14, 73)), ((30, 60), (20, 72))):
    p.line([a, b], RUF[3])

# body: upright, cream chest, speckled belly band
p = R.part('body')
bod = union(rell(42, 48, 14, 20, 12), ell(48, 34, 8, 7))
bm = p.add(p.m(bod), BRN, stitch=BRN[3])
chest = inter(bod, rell(48, 50, 9.5, 18, 12))
p.add(p.m(chest), CRM)
for (x, y) in ((44, 55), (47, 57), (50, 56), (53, 54), (45, 59), (49, 60), (52, 59), (55, 57), (47, 63), (51, 63)):   # belly band speckles
    if (x, y) in bm:
        p.px(x, y, BRN[2]); p.px(x + 1, y, BRN[2]); p.px(x, y + 1, BRN[3])
for (x, y) in ((50, 42), (54, 46), (52, 38)):                                          # a few fine chest streaks
    p.px(x, y, CRM[3])

# thighs: feathered cream trousers with brown bars
p = R.part('thighs')
tr = union(ell(37, 67.5, 5.2, 5), ell(48, 67.5, 5.6, 5), ell(43, 65.5, 4, 3))
p.add(p.m(tr), CRM, stitch=None)
for y in (65, 68, 71):
    for x in range(33, 54, 3):
        p.px(x, y, BRN[2])
p.line([(42.5, 67), (42.5, 72)], CRM[3])

# wing: long folded wing, scalloped coverts, barred primaries
p = R.part('wing')
w = poly([(33, 33), (40, 33), (46, 37), (48, 45), (46, 55), (41, 63), (35, 70), (30, 75), (27, 73), (28, 62), (29, 48)])
wm = p.add(p.m(w), BRN, stitch=None)
p.edge(wm, BRN[3], sides=((1, 0), (0, -1)))
prim = inter(w, poly([(25, 56), (40, 54), (46, 58), (34, 78), (24, 78)]))
p.add(p.m(prim), DARK)
for y0 in (60, 65, 70):
    p.line([(28, y0 + 2), (43, y0 - 4)], DARK[3])
for (x, y) in ((35, 39), (40, 40), (44, 43), (33, 45), (38, 46), (43, 48), (35, 51), (40, 52)):   # pale covert scallops
    p.line([(x - 1, y), (x + 1, y + 1)], BRN[0])

# head: broad head, cream throat, heavy hooked beak with a yellow cere, dark brow
p = R.part('head')
skull = union(ell(55, 22, 10, 9.5), capsule([R.pv('head'), (53, 26)], 12, 12), ell(49, 17, 4, 3))
p.add(p.m(skull), BRN)
p.add(p.m(inter(skull, ell(58.5, 30, 7.5, 5))), CRM)                                    # cream throat
beak = poly([(64, 17.5), (69, 17), (72.5, 19.5), (74, 24.5), (72.5, 29.5), (71, 26), (68, 24), (64, 24.5)])
p.add(p.m(beak), STONE, local=True)
p.add(p.m(inter(beak, lambda x, y: x > 71)), ('#5b6470', '#343842', '#2a1a10', '#2a1a10'), flat=True)   # dark hook tip
p.add(p.m(ell(64.5, 20, 3, 3)), YEL, local=True, crescent=1)                           # cere
p.line([(65, 23.5), (70, 23.5)], STONE[3])
p.px(66, 19, YEL[3])                                                                    # nostril
p.add(p.m(capsule([(53, 17.5), (63, 17)], 2.6)), DARK, flat=True)                       # the brow ridge
p.line([(57, 25), (62, 26)], BRN[3])                                                    # cheek line

# crest: raised nape hackles
p = R.part('crest')
for tip in ((40, 10), (42.5, 7), (46.5, 7.5)):
    p.add(p.m(capsule([(50.3, 16.1), tip], 5, 2)), BRN, local=True, crescent=1)
p.add(p.m(ell(50, 14.5, 3.5, 3)), BRN, local=True)
p.line([(48, 13), (43, 10)], BRN[3])

# eyes: fierce gold eye under the brow
p = R.part('eyes')
ex, ey = 58, 20
p.add(p.m(ell(ex + 1, ey + 1, 2.6, 2.3)), (YEL[0],) * 4, flat=True)
p.add(p.m(rect(ex, ey, ex + 2, ey + 2)), (INK,) * 4, flat=True)
p.px(ex + 1, ey, CREAM)
p.line([(ex - 2, ey - 1), (ex + 3, ey - 1)], DARK[2])

R.save()
