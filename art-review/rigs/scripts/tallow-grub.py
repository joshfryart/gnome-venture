#!/usr/bin/env python3
"""tallow-grub "Tallow Grub" (worm rig, 53 x 39, 6 parts): "A pale fat grub that glows faintly, like a candle stub. It wriggles at
you, mostly out of fright." (trek deep chambers, level 24; Tallow Wax)
A fat felt grub made of tallow-cream wax: four plump stitched rings humping up in the middle like a half-burnt candle, with a warm
gold glow along the belly and soft wax drips down the flanks. The big hump (s2) carries a short black wick with a little flame, so the
grub reads as a living candle stub. The front ring (s1) holds three tiny stub legs; the tail ring (s4) tapers into a drip.
A round amber head capsule (head) with dark little mandibles and a blush, and a worried button eye (eyes) looking up.
Segments are lit against the whole grub (ref=) and sewn together with a dark seam where each ring overlaps the next."""
import importlib, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from rigkit import *  # noqa
H = importlib.import_module('_insect_tallow-grub')

R = Rig('tallow-grub')
WAX = ('#fffbe8', '#fbecc0', '#e8c987', '#b88e52')
GLOW = ('#fff3c8', '#f8dc86', '#eebf52', '#c98f2c')
HEAD = ('#e8a866', '#c47a3c', '#8f4f24', '#5a2c14')
FLOOR = lambda x, y: y < 34.6                       # nothing below the ground row

SEG = {'s1': union(ell(40, 28.3, 6.6, 6.3), ell(35.5, 26.5, 4.5, 4.5)),
       's2': union(ell(31, 23, 9.2, 11.2), ell(33.5, 29, 6.5, 5.5)),
       's3': union(ell(21.5, 26.8, 7.8, 7.6), ell(20, 30.5, 6, 4)),
       's4': union(ell(12.5, 29.8, 6.2, 4.8), capsule([(9, 31.5), (3.5, 33)], 5, 2.4))}
REF = R.part('s1').m(*[inter(m, FLOOR) for m in SEG.values()])
UNDER = {'s2': 's1', 's3': 's2', 's4': 's3'}

GLOWC = {'s1': (41, 29.5, 3.5, 2.6), 's2': (31.5, 24, 5, 6.5), 's3': (21.5, 28, 4, 3.6), 's4': (12, 31, 3.2, 2)}
for pid in ('s1', 's2', 's3', 's4'):
    p = R.part(pid)
    mk = p.add(p.m(inter(SEG[pid], FLOOR)), WAX, ref=REF)
    cx, cy, rx, ry = GLOWC[pid]                      # the candle glow from inside each ring
    H.blob(p, p.m(ell(cx, cy, rx, ry)) & mk, GLOW)
    p.fill(p.m(ell(cx - rx * .2, cy - ry * .25, rx * .45, ry * .45)) & mk, GLOW[0])
    if pid in UNDER:
        H.seam_over(p, mk, R.part('s1').m(inter(SEG[UNDER[pid]], FLOOR)), WAX[3])

# s1: tiny grub legs under the front ring
p = R.part('s1')
for x in (39, 42):
    p.add(p.m(capsule([(x, 31.5), (x + .8, 34)], 1.8, 1.4)), HEAD, local=True, crescent=0)

# s2: the wick and its flame on top of the hump, a melted crater, wax drips running down over the seams
p = R.part('s2')
p.add(p.m(capsule([(30.5, 13), (30.5, 8.6)], 1.4, 1.2)), (INK, '#4a2c1a', INK, INK), flat=True)
flame = union(ell(30.5, 6, 2.3, 2.4), poly([(28.4, 5.5), (32.6, 5.5), (31.6, 2.6), (30.6, 1.2), (29.6, 3)]))
p.add(p.m(flame), ('#fff3c8', '#f5cf6a', '#e8a317', '#dd3a2a'), local=True, crescent=1)
p.add(p.m(ell(30.5, 6.4, .9, 1.3)), ('#fff3c8',) * 4, flat=True)
p.fill(p.m(ell(30.5, 13.4, 2.6, 1.1)) & p.m(SEG['s2']), WAX[2])
DRIP = ('#ffffff', '#fffbe8', '#f2dfa8', '#c9a96e')
for pts in ([(25.5, 14.5), (24.5, 19), (24.8, 21.5)], [(36, 15.5), (37.3, 19.5)]):
    p.add(p.m(capsule(pts, 2.6, 2.2)), DRIP, local=True, crescent=1)

# s3, s4: drips over the seams
p = R.part('s3')
p.add(p.m(capsule([(16.8, 20.8), (15.8, 24.6)], 2.4, 2.2)), DRIP, local=True, crescent=1)
p = R.part('s4')
p.add(p.m(capsule([(9.5, 26.5), (9, 29)], 2.2, 2)), DRIP, local=True, crescent=1)

# head: a small round amber head capsule poking out and down, a pale face plate, dark mandibles, a blush
p = R.part('head')
hd = p.add(p.m(ell(46.4, 27.6, 5.6, 5.4), capsule([R.pv('head'), (44, 27)], 5, 5)), HEAD)
p.add(p.m(inter(ell(49.4, 29.8, 3.2, 2.6), ell(46.4, 27.6, 5.6, 5.4))), ('#f2c890', '#e0a866', HEAD[1], HEAD[2]), local=True, crescent=0)
p.add(p.m(capsule([(50.5, 31.6), (51.6, 33), (50, 34)], 1.8, 1.3)), ('#8f4f24', '#5a2c14', '#3f1c10', '#3f1c10'), local=True, crescent=0)
p.line([(42.5, 23.5), (44, 22.8)], HEAD[0])
p.px(50, 28, BLUSH); p.px(49, 28, BLUSH)
p.line([(41.5, 31), (45, 32.4)], HEAD[3])

p = R.part('eyes')
H.button_eye(p, 46.2, 24.8, 1.5, look=1)

R.save()
