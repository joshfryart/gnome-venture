#!/usr/bin/env python3
"""crew-zinnia "Zinnia Fuzzbottom" (folk rig, 41 x 60, 10 parts, front view): the Trek crew's healer, Bloomcaller mentor who runs
the Marigold Stall in Maizehollow: "A round, busy bumblebee who has never met a flower she did not like" (Cheerful; villagers.lua:
bee, face #f5cf6a, red pointed hat #dd3a2a, grey clothes #8b8f96; "Zinnia tends the party").
A round fuzzy yellow bee head with a tufted felt edge, rosy cheeks, a happy mouth and two curly antennae with pom-pom tips poking
out under the hat brim (head); two button eyes (eyes); a tall red pointed bloomcaller's hat with a wide brim, a gold band, a cream
daisy pinned on and a drooping tip (hat); a round striped bee body, gold and umber bands, under a grey apron bib with a pocket
(body); fuzzy yellow sleeves with dark mitts, the left holding up a red zinnia, the right resting (armL / armR); dark little boots
(footL / footR); and behind her shoulders two pale-blue veined wings (wingL / wingR). Widest at the hat brim and wings."""
import math, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from rigkit import *  # noqa

R = Rig('crew-zinnia')
FUZZ = ('#fde69a', '#f5cf6a', '#e0a83a', '#b87a14')
BAND = ('#6a5648', '#4a2c1a', '#3a2214', '#2a1a10')
HAT = EMBER
APR = STONE
WING = ('#ffffff', '#d4ecf6', '#a9d6ea', '#6aaed0')

for pid, sx in (('wingL', -1), ('wingR', 1)):                                         # wings rising behind the shoulders
    p = R.part(pid)
    x, y = R.pv(pid)
    w = inter(union(rell(x + sx * 6.5, y - 9, 4.6, 9.8, sx * 36), ell(x + sx * 1.5, y - 1.5, 3, 3)), rect(2, 1, 39, 59))
    p.add(p.m(w), WING, local=True, stitch=WING[3])
    p.line([(x + sx * 1, y - 2), (x + sx * 6, y - 9), (x + sx * 10, y - 14)], WING[3])   # vein

for pid in ('footL', 'footR'):
    p = R.part(pid)
    x, y = R.pv(pid)
    sx = -1 if pid == 'footL' else 1
    p.add(p.m(capsule([(x, y - 1.5), (x, y + 1.5)], 4.4), ell(x + sx * 1, 53.4, 4.4, 2.3)), BAND)
    p.px(x + sx * 2, 52, BAND[0])

p = R.part('body')
belly = union(ell(20.5, 44.5, 10.5, 7.8), rect(13, 47, 28, 51.5))
p.add(p.m(belly), FUZZ, stitch=None)
for y0 in (40, 45.5):                                                                 # umber stripes
    p.add(p.m(inter(belly, rect(0, y0, 41, y0 + 2.5))), BAND, flat=True)
bib = inter(belly, union(ell(20.5, 48, 7.5, 5.5), rect(16, 43, 25, 48)), lambda x, y: y > 43)
p.add(p.m(bib), APR, local=True, crescent=1)
p.edge(p.m(bib), APR[3])
p.line([(16.5, 43), (13.5, 38)], APR[1]); p.line([(24.5, 43), (27.5, 38)], APR[1])       # apron straps
p.pxs([(20, 46), (21, 46), (19, 47), (22, 47), (20, 48), (21, 48)], HAT[1]); p.px(20, 47, GOLD[1]); p.px(21, 47, GOLD[1])   # stitched flower

for pid in ('armL', 'armR'):
    p = R.part(pid)
    x, y = R.pv(pid)
    sx = -1 if pid == 'armL' else 1
    if pid == 'armL':                                                                # arm bent up, holding a red zinnia
        hand = (x - 4.5, 41)
        p.add(p.m(capsule([(x, y + .5), (x - 3, 44), hand], 4.6, 4)), FUZZ)
        p.add(p.m(capsule([(hand[0], hand[1]), (hand[0] - 1, 33)], 1.4)), MOSS, flat=True)
        p.add(p.m(rell(hand[0] - 2.5, 36.5, 1.8, 1, 30)), MOSS, local=True, crescent=0)   # leaf
        bloom = union(*[ell(hand[0] - 1 + math.cos(a) * 2.2, 31 + math.sin(a) * 2.2, 1.7, 1.7) for a in [k * math.pi / 3.5 for k in range(7)]])
        p.add(p.m(bloom), HAT, local=True, crescent=0)
        p.add(p.m(ell(hand[0] - 1, 31, 1.2, 1.2)), GOLD, flat=True)
    else:
        hand = (x + 1.8, 45)
        p.add(p.m(capsule([(x, y + .5), hand], 4.6, 4)), FUZZ)
    p.add(p.m(ell(hand[0], hand[1] + 1, 2.3, 2.1)), BAND, local=True)

p = R.part('head')
hx, hy = 20.5, 27.5
fuzz = [ell(hx, hy, 11, 10.2)]
for k in range(14):                                                                   # tufted felt edge
    a = k * 2 * math.pi / 14
    fuzz.append(ell(hx + math.cos(a) * 10.6, hy + math.sin(a) * 9.8, 1.6, 1.6))
for sx in (-1, 1):                                                                    # curly antennae with pom-poms
    p.add(p.m(capsule([(hx + sx * 6, 19), (hx + sx * 10, 15), (hx + sx * 12.5, 11.5)], 1.6, 1.4)), BAND, local=True, crescent=0)
    p.add(p.m(ell(hx + sx * 13, 11, 1.9, 1.9)), BAND, local=True, crescent=0)
    p.px(hx + sx * 13 - (sx < 0), 10, BAND[0])
p.add(p.m(union(*fuzz)), FUZZ)
p.line([(18, 32), (19, 33), (22, 33), (23, 32)], BAND[1])                               # happy mouth
p.pxs([(13, 30), (14, 30), (27, 30), (28, 30)], EMBER[0])                              # rosy cheeks
p.pxs([(12, 22), (14, 20), (28, 23), (11, 27)], FUZZ[0])                               # fuzz highlights

p = R.part('eyes')
for ex in (16, 25):
    p.add(p.m(ell(ex + .5, 26.8, 1.6, 2)), (INK,) * 4, flat=True)
    p.px(ex, 26, CREAM)

p = R.part('hat')
cone = union(poly([(11, 19.5), (30, 19.5), (25, 6), (19, 5)]), capsule([(22, 6), (26, 3.5), (29.5, 5)], 3.4, 2))
p.add(p.m(cone), HAT)
p.line([(22, 8), (24.5, 4.5)], HAT[2])                                                   # the fold of the drooping tip
p.add(p.m(ell(hx, 19.8, 15.5, 2.3)), HAT, local=True)                                   # wide brim
p.add(p.m(inter(cone, rect(0, 15, 41, 17))), GOLD, flat=True)                           # gold band
daisy = union(*[ell(14.5 + math.cos(a) * 1.6, 15.5 + math.sin(a) * 1.6, 1.2, 1.2) for a in [k * math.pi / 2.5 for k in range(5)]])
p.add(p.m(daisy), ('#ffffff', '#fff3c8', '#f2e4c0', '#c9a96e'), local=True, crescent=0)
p.px(14, 15, GOLD[1])

R.save()
