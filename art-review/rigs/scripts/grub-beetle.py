#!/usr/bin/env python3
"""grub-beetle "Grubfield Beetle" (bug.beetle rig, 71 x 45, 8 parts): "A glossy black beetle that guards the soft soil.
Something glints under its wing case." (trek, level 17; Beetle Shell; it guards the cellar key)
A long, low, glossy blue-black satin-felt beetle (body): the wing case is a smooth long oval with a white satin sheen streak and
a sewn centre seam, its back end lifted a little like a lid, and under the lifted flap a gold key bow glints; a wide rounded
shoulder shield in front. A broad flat digger's head with two short curved mandibles (head), a button eye with a stern lid (eyes),
elbowed antennae with little gold fan tips (antL / antR), and three digging legs with toothed shins (leg1..leg3).
Silhouette: the long low oval with the raised tail flap, next to the ember beetle's tall dome."""
import importlib, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from rigkit import *  # noqa
H = importlib.import_module('_bug_ember-beetle')

R = Rig('grub-beetle')
GLOSS = ('#7d86a8', '#454a63', '#33364a', '#1e1e2a')
SHEEN = '#c9d2ec'
KEY = GOLD

for pid, knee, foot in (('leg1', (19.5, 31.5), (16.5, 38.5)), ('leg2', (35.5, 32.5), (34, 38.5)), ('leg3', (48.5, 31.5), (52, 38.5))):
    p = H.leg(R, pid, knee, foot, darker(GLOSS), w=(4.4, 3.6, 3))
    mx, my = (knee[0] + foot[0]) / 2, (knee[1] + foot[1]) / 2
    s = 1 if foot[0] >= knee[0] else -1
    p.px(mx + s * 2, my - 1, GLOSS[1]); p.px(mx + s * 2, my + 1.5, GLOSS[1])     # digging teeth on the shin

# body: the key under the flap, the shoulder shield, the long glossy case
p = R.part('body')
p.add(p.m(ell(9.5, 27, 3.6, 3.6), capsule([(12, 29.5), (20, 30.5)], 2.2), rect(16, 30, 18, 33), rect(19, 30, 20.5, 32.5)), KEY, local=True, crescent=0)
p.fill(p.m(ell(9.5, 27, 1.4, 1.4)), GLOSS[3])                                    # the cellar key, slipping out under the flap
p.px(8, 25, '#ffffff')
shield = rell(44, 22.5, 7.5, 8, 0)
p.add(p.m(shield), GLOSS, local=True)
case = minus(rell(28, 20.5, 19, 9.5, -6), lambda x, y: y > 29.8)
p.add(p.m(case), GLOSS, stitch=GLOSS[0])
p.fill(p.m(inter(case, lambda x, y: y > 27.8)), GLOSS[2])       # the case rim
p.fill(p.m(inter(rell(26, 16, 11, 2, -8), case)), SHEEN)                         # the satin sheen
p.fill(p.m(inter(rell(31, 14.6, 4, 1, -8), case)), '#ffffff')
p.line([(45, 13), (40, 17), (30, 23), (19, 27)], GLOSS[3])                       # the seam between the two wing cases
p.line([(10, 24.5), (14, 22.5), (16, 25)], GLOSS[3])                            # the lifted lip of the flap
p.fill(p.m(ell(44, 18, 3, 1.2)), GLOSS[0])                                       # shine on the shield

# head: broad and flat, two short hooked mandibles
p = R.part('head')
hd = union(rell(52, 24.5, 7.8, 5.6, 6), capsule([R.pv('head'), (49, 24)], 7, 7))
p.add(p.m(hd), GLOSS)
mand = union(capsule([(57, 26.5), (61.5, 26), (63, 23.5)], 2.6, 1.4), capsule([(56, 28.5), (60.5, 29.5), (62.5, 28)], 2.4, 1.3))
p.add(p.m(mand), darker(GLOSS), local=True, crescent=0)
p.fill(p.m(ell(51, 20.8, 3.2, 1)), GLOSS[0])
p.add(p.m(ell(55.5, 27, 1.3, 1)), (BLUSH,) * 4, flat=True)

p = R.part('eyes')
H.button_eye(p, 53.4, 22.6, 2.2, lid=GLOSS[2])
p.line([(50.5, 20.5), (56, 21.5)], INK)

for pid, pts in (('antL', [(50.9, 19.5), (49.5, 13.5), (53, 9)]), ('antR', [(54.5, 19.5), (58.5, 15.5), (63, 15)])):
    p = R.part(pid)
    p.add(p.m(capsule(pts, 1.9, 1.5)), GLOSS, crescent=0)
    tx, ty = pts[-1]
    fan = union(*[capsule([(tx, ty), (tx + dx, ty + dy)], 1.6, 1.4) for dx, dy in ((2.5, -2.5), (3.3, 0), (2.5, 2.2))])
    p.add(p.m(fan), KEY, local=True, crescent=0)

R.save()
