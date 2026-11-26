#!/usr/bin/env python3
"""basalt-borer "Basalt Borer" (worm rig, 81 x 49, 8 parts): "A mole-cricket as long as a wheelbarrow, with spade hands. It digs toward
the knock and gets cross when you are in the way." (large, trek ch3 deep stone, level 27; Borer Plate)
A felt mole-cricket built like a little digging engine, side view, hugging the ground. s1 is the tall domed pronotum shield, the Borer
Plate: dark basalt felt sewn as hexagonal basalt columns with glowing ember seams, the highest point of the body. s2..s6 are the soft
abdomen rings stepping down toward the tail, basalt-grey on the back and brown velvet underneath; folded tan wings lie along the back of
s2..s3 and the rolled hind-wing tips run on over s4; s2 carries the small middle leg, s3 the stout hind leg, s6 the two tail cerci.
head: a blunt dark head tucked under the shield's lip (the neck is painted as the shield so the joint is seamless), two short
antennae, and the huge brown spade hand (a darker far one behind it), rake claws tipped in cream, flat on the ground ready to dig
(the head's strike swings it). eyes: a small amber button eye under a heavy cross brow.
Segments are lit against the whole body (ref=) and joined by dark sewn seams."""
import importlib, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from rigkit import *  # noqa
H = importlib.import_module('_crawler_basalt-borer')

R = Rig('basalt-borer')
BAS = ('#a0a6b6', '#737889', '#545866', '#363944')        # basalt felt
VEL = ('#c9a070', '#9a6b3f', '#74462a', '#4a2c1a')        # brown velvet belly and limbs
WING = ('#e8d2a0', '#c9a96e', '#9a7a48', '#6a5030')       # folded wing felt
SPADE = ('#e0a060', '#b8743a', '#86522a', '#5a3418')
EMBER = '#f08a4a'
FLOOR = lambda x, y: y < 44.6

SHIELD = ell(58, 26, 10.6, 11.4)
SEG = {'s1': union(SHIELD, ell(56, 34, 7, 5)),
       's2': ell(48.5, 32, 7.6, 8.6),
       's3': ell(40.5, 33, 8, 8.2),
       's4': ell(32.5, 34, 7.8, 7.4),
       's5': ell(24.8, 35.5, 7, 6.2),
       's6': union(ell(17.5, 37.5, 5.6, 4.6), ell(13.5, 38.5, 3.4, 2.8))}
REF = R.part('s1').m(*[inter(m, FLOOR) for m in SEG.values()])
UNDER = {'s2': 's1', 's3': 's2', 's4': 's3', 's5': 's4', 's6': 's5'}
BELLY = {'s1': 34.5, 's2': 36, 's3': 37, 's4': 37.5, 's5': 38.5, 's6': 39.5}

for pid in SEG:
    p = R.part(pid)
    if pid == 's2':      # the small middle leg
        p.add(p.m(capsule([(51, 38), (54, 42), (56.5, 43.5)], 3, 2.2)), VEL, local=True, crescent=1)
    if pid == 's3':      # the stout hind leg: a fat thigh on the flank, a spiny shin back to the ground
        p.add(p.m(capsule([(38.5, 39), (33, 43.4), (30, 43.6)], 3, 2.2)), VEL, local=True, crescent=1)
    if pid == 's6':      # two tail cerci
        p.add(p.m(capsule([(12, 37), (7, 34), (4, 33)], 2.2, 1.4)), darker(VEL), local=True, crescent=0)
        p.add(p.m(capsule([(12, 40), (7.5, 41.5), (4.5, 42.5)], 2.2, 1.4)), VEL, local=True, crescent=0)
    mk = p.add(p.m(inter(SEG[pid], FLOOR)), BAS, ref=REF)
    p.add(p.m(inter(SEG[pid], FLOOR, lambda x, y, b=BELLY[pid]: y > b)), VEL, ref=REF)
    if pid in UNDER:
        H.seam_over(p, mk, R.part('s1').m(SEG[UNDER[pid]]), BAS[3])
    if pid == 's3':
        H.blob(p, p.m(rell(42, 37, 5.4, 2.6, -15)) & mk, VEL)
        for q in ((35, 42), (32, 42)):
            p.px(q[0], q[1], VEL[3])

# folded fore wings over s2 and s3, rolled hind-wing tips over s4 and s5
for pid, band in (('s2', capsule([(55, 25.5), (42, 27)], 4.6, 4.4)), ('s3', capsule([(46, 27), (34.5, 28.5)], 4.4, 3.6)),
                  ('s4', capsule([(38, 28.5), (27.5, 30)], 2.6, 2)), ('s5', capsule([(30, 30.5), (21, 32)], 2, 1.4))):
    p = R.part(pid)
    mk = p.m(inter(SEG[pid], FLOOR))
    w = p.m(band) & mk
    H.blob(p, w, WING)
    if pid in ('s2', 's3'):
        H.stitch_line(p, [(min(x for x, y in w) + 1, 27 + (pid == 's3')), (max(x for x, y in w) - 1, 26 + (pid == 's3'))], WING[2], gap=1)

# s1: the Borer Plate, sewn as basalt columns with ember seams
p = R.part('s1')
SH = p.m(inter(SHIELD, lambda x, y: y < 33.5))
H.blob(p, p.m(ell(58, 26, 10.6, 11.4)) & SH, BAS)
for c in (((52, 18.5), (51.5, 24), (53, 31)), ((58, 15.5), (57.5, 22.5), (58, 31)), ((63.5, 17.5), (64.5, 23.5), (63.5, 30))):
    p.line(list(c), BAS[3])
p.line([(48.5, 24.5), (51.5, 24), (57.5, 22.5), (64.5, 23.5), (68, 24)], BAS[3])
for q in ((55, 19), (61, 19.5), (55, 27.5), (61, 27.5), (50, 28)):
    H.blob(p, p.m(ell(q[0], q[1], 1.8, 1.6)) & SH, (BAS[0], BAS[0], BAS[1], BAS[1]))
for run in ([(52, 23.5), (55, 23)], [(57.5, 22.5), (57.5, 26.5)], [(64.5, 23.5), (64, 27)], [(51.5, 25), (52, 27.5)]):
    p.line(run, EMBER)
p.px(57, 23, '#f5cf6a'); p.px(64, 24, '#f5cf6a')
H.stitch_line(p, [(48.5, 33.5), (56, 34.5), (66, 34)], BAS[3])                   # the shield's lower lip

# head: a blunt dark head under the shield's lip, antennae, and the spade hands flat on the ground
p = R.part('head')
hx, hy = R.pv('head')
far = poly([(63, 37.5), (68.5, 37), (72, 40), (73, 43.6), (65, 43.6), (62.5, 40.5)])
p.add(p.m(capsule([(61, 35), (65, 39)], 4.6, 4.2), far), darker(SPADE), local=True, crescent=1)
p.add(p.m(capsule([(69, 25), (70, 19), (68, 14.5)], 1.8, 1.4)), darker(VEL), local=True, crescent=0)        # far antenna
p.add(p.m(capsule([(hx, hy), (65, 31)], 8, 8)), BAS, ref=REF)                                            # neck, as the shield
head = ell(70.5, 29.2, 6.2, 6.4)
hm = p.add(p.m(head), VEL)
p.add(p.m(inter(head, lambda x, y: y < 25.5 - (x - 70) * .3)), (BAS[0], BAS[1], BAS[2], BAS[2]), local=True)   # dark crown
H.seam_over(p, hm, R.part('s1').m(SHIELD), VEL[3])                                    # where the head tucks under the shield
p.add(p.m(ell(73.5, 31.5, 1.2, 1)), (BLUSH,) * 4, flat=True)
p.add(p.m(capsule([(72.5, 25.5), (75.5, 19.5), (78, 15.5)], 2, 1.5)), VEL, local=True, crescent=0)       # near antenna
p.add(p.m(capsule([(75.5, 33), (78, 35)], 2, 1.4)), VEL, local=True, crescent=0)                        # palp
arm = capsule([(64, 35), (69.5, 38.5)], 5.2, 4.6)
spade = poly([(66.5, 37), (73.5, 35.3), (77.5, 37), (79.2, 40.5), (78.5, 43.6), (69, 43.6), (65.5, 41)])
p.add(p.m(arm, spade), SPADE, local=True, crescent=1)
for x in (70, 73, 76):                                                           # gaps between the rake claws
    p.line([(x + .5, 41), (x + 1, 44)], SPADE[3])
for x in (69, 72, 75, 78):
    p.px(x, 43, CREAM); p.px(x, 42, SPADE[0])
p.line([(67.5, 37.5), (73, 36.3)], SPADE[0])
p.line([(73.5, 32.5), (76.5, 32)], VEL[3])                                        # cross mouth

p = R.part('eyes')
ex, ey = R.pv('eyes')
H.button_eye(p, ex + .3, ey + .4, 2.1, iris='#f5cf6a', brow=[(66, 23), (71.5, 24.5)])

R.save()
