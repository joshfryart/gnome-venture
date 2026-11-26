#!/usr/bin/env python3
"""outback-dingo "Outback Dingo" (quad.canid rig, 83 x 48, 8 parts): "Pale as the dust and twice as patient."
(medium; desert, grassland; L35; Fox Pelt, Fox Fang)
A lean, short-coated wild dog in pale dusty-ginger felt: a slim body with a tucked waist, a cream throat and belly and a
darker saddle seam along the back (body); straight neat legs in cream socks with small round paws (far legs a step down);
a medium sickle tail carried up over the back with a cream tip (tail, sprung); a wedge head with big upright triangular ears,
a cream muzzle and cheeks, an ink nose and a calm closed-mouth line (head), and a patient narrow amber eye (eyes).
The smoothest, most upright-eared of the batch: no fluff, no stockings, no thorns."""
import importlib.util, os, sys
_s = importlib.util.spec_from_file_location('qk', os.path.join(os.path.dirname(os.path.abspath(__file__)), '_quad_arctic-fox.py'))
qk = importlib.util.module_from_spec(_s); _s.loader.exec_module(qk)
from rigkit import *  # noqa

R = Rig('outback-dingo')
SAND = ('#f5dca0', '#e2b274', '#bb8a50', '#8a5a2e')
FARS = ('#d4a46a', '#bb8a50', '#9a6b3f', '#74462a')
CRM = ('#fff3c8', '#fff3c8', '#f2e4c0', '#c9a96e')
FCRM = ('#f2e4c0', '#e0d0a8', '#c9a96e', '#9a6b3f')
SADDLE = '#c99558'

qk.hind(R, 'legBF', FARS, 5, 3.8, back=2.5, sock=FCRM, sock_y=39)
qk.leg(R, 'legFF', 53, FARS, 4.5, 3.8, sock=FCRM, sock_y=38.5)

# tail: a sickle carried up over the back, cream tip
p = R.part('tail')
qk.brush(p, [(26, 23.5), (19.5, 21), (15, 15.5), (14.5, 9.5), (17.5, 5.5)], 4.5, 5.5, SAND, tip=CRM, tip_from=.8)
p.line([(17, 17), (19, 18.5)], SAND[3]); p.line([(14.5, 12), (16.5, 12.5)], SAND[3])

# body: lean, tucked waist, deep chest, cream throat and belly, darker saddle along the back
p = R.part('body')
torso = union(ell(30.5, 24.5, 7, 6), ell(39, 24.5, 11, 4.8), ell(48.5, 23.5, 7, 7))
p.add(p.m(torso), SAND, stitch=SAND[2])
p.add(p.m(inter(torso, lambda x, y: y < 21.5 and 27 < x < 49)), (SAND[1], SADDLE, SAND[2], SAND[3]))
p.add(p.m(inter(torso, union(ell(53, 25, 4.5, 5.5), lambda x, y: y > 27.2 and x > 34))), CRM)

qk.hind(R, 'legBN', SAND, 5.5, 3.8, back=2.5, sock=CRM, sock_y=39.5, against=('legBF', 'body'), seamcol=SAND[3])
qk.leg(R, 'legFN', 48.5, SAND, 4.5, 3.8, sock=CRM, sock_y=38.5, against=('legFF', 'body'), seamcol=SAND[3])

# head: wedge skull, big upright ears, cream muzzle and cheeks
p = R.part('head')
skull = ell(57, 14.5, 6.5, 5.5)
snout = poly([(59, 11.5), (66, 13.5), (72.5, 15.5), (72.5, 17.5), (66, 19.5), (57, 19.5)])
neck = capsule([R.pv('head'), (55, 16)], 8, 8)
ears = union(poly([(51.5, 12), (52, 2.5), (57, 9.5)]), poly([(55.5, 10), (59, 2), (61, 11)]))
p.add(p.m(ears), SAND, local=True)
p.add(p.m(union(poly([(53, 10.5), (53.2, 5), (55.5, 9.5)]), poly([(57, 9.5), (58.8, 4.5), (59.8, 10)]))), (BLUSH, BLUSH, PETAL[2], PETAL[2]), flat=True)
p.add(p.m(skull, snout, neck), SAND)
p.add(p.m(inter(union(snout, skull, neck), below((50, 18.5), (73, 16.5), 0))), CRM)
p.add(p.m(ell(58.5, 17, 2.2, 1.6)), CRM, flat=True)                                     # cheek patch
qk.nose(p, 71, 15)
p.line([(71, 17.5), (67, 18), (64, 17.5)], SAND[3])                                  # closed patient mouth

p = R.part('eyes')
p.add(p.m(rell(60.6, 14.6, 1.8, 1.1, -10)), (INK,) * 4, flat=True)                   # narrow patient eye
p.px(60, 14, '#e8a317'); p.px(59, 13, SAND[3]); p.px(60, 13, SAND[3]); p.px(61, 13, SAND[3])

R.save()
