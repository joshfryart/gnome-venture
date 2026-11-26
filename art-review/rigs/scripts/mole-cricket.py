#!/usr/bin/env python3
"""mole-cricket "Mole Cricket" (bug.plain rig, 77 x 37, 8 parts): "A shovel-clawed cricket that digs up from underneath."
(trek fields, level 17; Earwig Pincer)
A long, low, velvety felt mole cricket built for digging: a soft fuzzy ginger abdomen with short folded wings and two thin tail cerci
(body), under a big glossy dark helmet of a neck shield that rises in a dome over the front (body), the silhouette's hump. A small
blunt head poking out low under the helmet (head) with a button eye (eyes) and two short stiff feelers (antL / antR). The front leg
(leg3) is the spade: a thick arm ending in a broad toothed shovel hand with soil crumbs on it, reaching forward to the ground;
two short hind legs (leg1, leg2)."""
import importlib, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from rigkit import *  # noqa
H = importlib.import_module('_insect_tallow-grub')

R = Rig('mole-cricket')
VELVET = ('#dcac78', '#b07c50', '#805434', '#523222')
HELM = ('#a87656', '#784a32', '#553222', '#361d12')
CLAW = ('#e0a060', '#b06c38', '#7c4624', '#4a2a14')
WING = ('#f0d8a8', '#ccac78', '#9e7c50', '#6e5232')
SOIL = '#4a2c1a'

H.leg(R, 'leg1', [(24, 25), (21.5, 31.6)], VELVET, (4.4, 3.4, 2.6), foot=-1, spur=((22, 28),))
H.leg(R, 'leg2', [(40, 26), (38.5, 31.6)], VELVET, (3.6, 3, 2.4), foot=-1)

# leg3: the shovel arm and its toothed spade hand
p = R.part('leg3')
x0, y0 = R.pv('leg3')
p.add(p.m(capsule([(x0, y0 - 1.2), (53, 24.5)], 5, 5.4)), CLAW, crescent=1)
palm = ell(55, 25.5, 3.6, 3.6)
tines = [capsule([(56, 25.5), t], 2.6, 1.1) for t in ((63, 22.8), (63.8, 26.6), (62.3, 30.4), (58, 31.6))]
p.add(p.m(palm, *tines), CLAW, local=True)
p.pxs([(55, 26), (54, 24), (57, 27)], SOIL)                                    # soil crumbs on the palm
p.pxs([(61, 23), (62, 27), (60, 30)], CLAW[3])                                 # the claw tips darken

# body: cerci, velvet abdomen, folded wings + long wing tips, the domed helmet
p = R.part('body')
for pts in ([(8, 15), (2.5, 12.5)], [(8, 19), (2.5, 21)]):
    p.add(p.m(capsule(pts, 1.8, 1.1)), VELVET, local=True, crescent=0)
abdo = union(ell(20, 16.5, 14, 7.4), ell(33, 18, 6, 5.5))
p.add(p.m(abdo), VELVET)
for x in (11, 16, 21, 26):
    p.line([(x - 1, 13.5), (x, 18), (x + .5, 23)], VELVET[2])                  # soft ring creases
for q in ((9, 14), (12, 17), (15, 15), (11, 20), (16, 19), (13, 12)):
    p.px(q[0], q[1], VELVET[0])                                                # velvet nap
wing = union(rell(24, 11.5, 10, 3, 4), capsule([(16, 11), (7.5, 12.5)], 2.6, 1.6))
p.add(p.m(wing), WING, local=True)
p.line([(33, 12.5), (15, 11), (8, 12.5)], WING[3])
H.stitch_line(p, [(30, 10), (20, 9.3)], WING[2], gap=1)
helm = union(ell(43, 13.6, 9.6, 9.2), ell(49.5, 18, 4.5, 4))
hm = p.add(p.m(inter(helm, lambda x, y: y < 22.5)), HELM)
H.stitch_line(p, [(35, 15), (37, 9), (42, 6), (48, 7), (51.5, 11)], HELM[0], gap=1)
p.add(p.m(rell(40, 8.5, 3.4, 1.6, -20)), ('#c89a78',) * 4, flat=True)         # glossy highlight on the dome
p.line([(44.5, 9), (45.5, 12), (44.5, 14)], HELM[3])                            # the heart-shaped dimple

# head: blunt, low, poking out under the helmet
p = R.part('head')
p.add(p.m(capsule([(62, 21), (65.5, 22.5)], 2, 1.4), capsule([(61, 22.5), (63, 24)], 1.8, 1.3)), CLAW, local=True, crescent=0)
p.add(p.m(ell(57.2, 16.8, 5.8, 6.2), capsule([R.pv("head"), (55, 18)], 5, 5)), VELVET)
p.px(60, 19, BLUSH)

p = R.part('eyes')
H.button_eye(p, 55.9, 15.9, 1.6)

for pid, pts in (('antL', [(53.5, 11.1), (52.5, 6.5), (51.5, 3)]), ('antR', [(57.7, 11.1), (61, 7.5), (65.5, 5)])):
    p = R.part(pid)
    p.add(p.m(capsule(pts, 1.8, 1.2)), VELVET, crescent=0)

R.save()
