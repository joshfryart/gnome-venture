#!/usr/bin/env python3
"""red-fox "Red Fox" (quad.canid rig, 89 x 61, 8 parts): "To a gnome, a fox is a dragon with a smile." (large; forest, grassland,
mountain, tundra; L16; Fox Pelt, Fox Fang, Bushy Tuft; out at dawn and dusk)
A slim, long-legged fox in bright orange felt: a lean body with a cream throat and chest bib (body), long legs in black felt
stockings on neat black paws (far legs a step darker), a long heavy brush tail swept back with a cream tip (tail, sprung), and
a narrow head with tall pointed black-backed ears, a long pointed snout with a cream lower jaw and cheeks, an ink nose and a sly
smile line (head), an amber eye (eyes). Leggier and sharper than the round arctic fox, brighter than the sandy dingo."""
import importlib.util, os, sys
_s = importlib.util.spec_from_file_location('qk', os.path.join(os.path.dirname(os.path.abspath(__file__)), '_quad_arctic-fox.py'))
qk = importlib.util.module_from_spec(_s); _s.loader.exec_module(qk)
from rigkit import *  # noqa

R = Rig('red-fox')
FUR = ('#f5b06a', '#e8762a', '#b8521c', '#7a3414')
FARF = ('#d8763a', '#c45a20', '#953f16', '#6a2c10')
BIB = ('#fff3c8', '#fff3c8', '#f2e4c0', '#c9a96e')
SOCK = ('#6a5648', '#4a2c1a', '#33201a', '#2a1a10')
FSOCK = ('#4a2c1a', '#3a2418', '#2a1a10', '#2a1a10')

# far legs, a step darker, black stockings
qk.hind(R, 'legBF', FARF, 6, 4.5, back=3, sock=FSOCK, sock_y=46)
qk.leg(R, 'legFF', 59, FARF, 5, 4.5, sock=FSOCK, sock_y=45)

# tail: long, heavy brush swept back and up, cream tip, a few fur seams
p = R.part('tail')
qk.brush(p, [(25, 31.5), (18, 32.5), (11.5, 29.5), (7.5, 23), (7.5, 15)], 6, 11, FUR, tip=BIB, tip_from=.78)
p.add(p.m(qk.fluff([(15, 34.5), (9.5, 31), (5.5, 24)], 2, 2.4)), FUR)
for a, b in (((15, 29.5), (18, 31)), ((10.5, 24), (13.5, 26)), ((8, 18.5), (11, 19.5))):
    p.line([a, b], FUR[3])

# body: lean and long, deep chest, cream bib down the throat and chest
p = R.part('body')
torso = union(ell(40, 33, 15.5, 7), ell(53, 32, 7.5, 8.5), ell(29, 34, 6.5, 6.5))
p.add(p.m(torso), FUR, stitch=FUR[2])
p.add(p.m(inter(torso, union(ell(57, 33, 5, 6.5), lambda x, y: y > 38.2 and x > 44))), BIB)
p.line([(31, 30), (34, 31.5)], FUR[3]); p.line([(42, 29), (45, 30)], FUR[3])     # fur seams

qk.hind(R, 'legBN', FUR, 7, 4.5, back=3, sock=SOCK, sock_y=46.5, against=('legBF', 'body'), seamcol=FUR[3])
qk.leg(R, 'legFN', 53.5, FUR, 5.5, 4.5, sock=SOCK, sock_y=45.5, against=('legFF', 'body'), seamcol=FUR[3])

# head: narrow skull, long pointed snout, tall pointed ears with black backs, cream cheeks and lower jaw
p = R.part('head')
skull = ell(63, 19.5, 7.5, 6.5)
snout = poly([(66, 16.5), (75, 19.5), (82.5, 21.5), (82, 23.5), (74, 25.5), (64, 26)])
neck = capsule([R.pv('head'), (61, 21)], 9, 9)
earF = poly([(56.5, 16), (57.5, 4), (63, 13.5)])
earN = poly([(61.5, 14), (66, 2.5), (69, 14.5)])
p.add(p.m(earF), (SOCK[0], SOCK[1], SOCK[1], SOCK[2]), local=True)
p.add(p.m(earN), FUR, local=True)
p.add(p.m(inter(earN, lambda x, y: y < 8.5)), (SOCK[0], SOCK[1], SOCK[1], SOCK[2]))   # black ear tip
p.add(p.m(poly([(63.5, 13), (66, 5.5), (67.5, 13.5)])), BIB, flat=True)           # cream inner ear
p.add(p.m(skull, snout, neck), FUR)
p.add(p.m(inter(union(snout, skull, neck), below((56, 25), (83, 22.5), 0))), BIB)
p.add(p.m(inter(skull, lambda x, y: x < 61 and y > 20)), BIB)                      # cheek ruff
qk.nose(p, 81, 21)
p.line([(80, 23.5), (76, 24), (73, 23)], FUR[3])                                    # sly smile
p.px(72, 22, FUR[3])
p.line([(58, 19), (60, 21)], FUR[2])

p = R.part('eyes')
qk.eye(p, 67.8, 20.1, iris='#e8a317')

R.save()
