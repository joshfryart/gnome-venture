#!/usr/bin/env python3
"""crew-bracken "Captain Bracken Spurwing" (folk rig, 35 x 55, 10 parts, front view): the Trek crew's Thornblade captain,
"a gleaming stag beetle who keeps watch over Mistmoor from the Old Watchtower and trains Thornblades" (Proud; villagers.lua:
beetle, face #7a4a1f, purple cap #7a5cc0, red clothes #dd3a2a; "Bracken scouts ahead").
A broad glossy brown beetle head with a cream shine, two great antler mandibles curving out and up from the jaw like a proud
moustache, elbowed antennae poking out under the cap (head); two small bright button eyes under stern brows (eyes); a purple
officer's cap with a dark peak and a gold badge (hat); a red officer's coat with gold epaulettes, a double row of gold buttons and
a dark belt (body); red sleeves with brown claw hands, the right one gripping a green thorn sword (armL / armR); polished dark
boots (footL / footR); and behind the shoulders the two glossy wing cases split open like a cape (wingL / wingR)."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from rigkit import *  # noqa

R = Rig('crew-bracken')
SHELL = ('#c08048', '#7a4a1f', '#58331a', '#3a2210')
COAT = ('#f08a4a', '#dd3a2a', '#a8241f', '#6e2038')
CAP = ('#b8a4ea', '#7a5cc0', '#5a4096', '#3a2a66')
BOOT = ('#6a5648', '#4a2c1a', '#3a2214', '#2a1a10')

for pid, sx in (('wingL', -1), ('wingR', 1)):              # elytra split open behind the shoulders
    p = R.part(pid)
    x, y = R.pv(pid)
    p.add(p.m(rell(x + sx * 4.5, y + 6, 4.6, 10, -sx * 22)), SHELL, local=True)
    p.line([(x + sx * 2, y + 1), (x + sx * 6.5, y + 13)], SHELL[3])
    p.px(x + sx * 4 - (sx < 0), y + 1, SHELL[0])

for pid in ('footL', 'footR'):
    p = R.part(pid)
    x, y = R.pv(pid)
    sx = -1 if pid == 'footL' else 1
    p.add(p.m(capsule([(x, y - 1.5), (x, y + 2)], 4.6), ell(x + sx * 1.2, 48.5, 4.4, 2.4)), BOOT)
    p.px(x + sx * 2, 47, BOOT[0])

p = R.part('body')
coat = union(poly([(10, 33.5), (25, 33.5), (27.5, 46), (17.5, 47.2), (7.5, 46)]), ell(17.5, 34.5, 8, 2.6))
p.add(p.m(coat), COAT, stitch=COAT[3])
p.add(p.m(inter(coat, rect(8, 40, 27, 42))), BOOT, flat=True)                     # belt
p.add(p.m(rect(16, 39.5, 19, 42.5)), GOLD, local=True, crescent=0)               # buckle
p.px(17, 40.5, GOLD[3])
for y in (35, 37):
    p.px(14, y, GOLD[0]); p.px(20, y, GOLD[0])                                     # double row of buttons
p.line([(17, 34), (17, 39)], COAT[3])
p.line([(17, 43), (17, 46)], COAT[3])                                                # coat tails split
for sx in (-1, 1):                                                                   # gold epaulettes
    p.add(p.m(ell(17.5 + sx * 6.5, 34, 3, 1.6)), GOLD, local=True, crescent=0)

for pid in ('armL', 'armR'):
    p = R.part(pid)
    x, y = R.pv(pid)
    sx = -1 if pid == 'armL' else 1
    hand = (x + sx * 1.8, 41.5)
    if pid == 'armR':                                                                 # the thorn sword, held up along the arm
        p.add(p.m(poly([(hand[0] + 1, 40), (hand[0] + 4.2, 40), (hand[0] + 5.3, 20)])), ('#e8fbf2', '#c8d09f', '#7ab55c', '#4f8a3e'), local=True, crescent=0)
        p.line([(hand[0] + 2.5, 39), (hand[0] + 4, 26)], '#7ab55c')
        p.add(p.m(rect(hand[0] - 1, 39.5, hand[0] + 5.5, 41)), GOLD, flat=True)
    p.add(p.m(capsule([(x, y + .5), hand], 5, 4.4)), COAT)
    p.add(p.m(ell(hand[0], 42.5, 2.4, 2.4)), SHELL, local=True)
    p.line([(hand[0] - 2, 40), (hand[0] + 2, 40)], GOLD[2])                          # gold cuff

p = R.part('head')
hx, hy = 17.5, 23
skull = union(ell(hx, hy + .5, 8.6, 9), ell(hx, 30, 5.5, 3.6))
for sx in (-1, 1):                                                                   # elbowed antennae poking out under the cap
    p.add(p.m(capsule([(hx + sx * 7, 16), (hx + sx * 12, 13), (hx + sx * 14, 8.5)], 1.8, 1.4)), SHELL, local=True, crescent=0)
    p.add(p.m(ell(hx + sx * 14, 8, 1.7, 1.7)), SHELL, local=True, crescent=0)
    mand = capsule([(hx + sx * 5, 30), (hx + sx * 11, 29), (hx + sx * 13.5, 24), (hx + sx * 13, 19.5), (hx + sx * 11.2, 18)], 3.6, 1.5)
    p.add(p.m(mand), SHELL, local=True)
    p.px(hx + sx * 12 - (sx < 0), 27, SHELL[0])
    p.px(hx + sx * 12 - (sx < 0), 23, SHELL[3]); p.px(hx + sx * 11 - (sx < 0), 23, SHELL[3])   # inner tooth
p.add(p.m(skull), SHELL)
p.add(p.m(ell(hx - 4, hy - 3, 2.2, 1.2)), (SHELL[0],) * 4, flat=True)               # gloss
p.line([(hx - 2, 28), (hx + 2, 28)], SHELL[3])
p.pxs([(11, 26), (12, 26), (23, 26), (24, 26)], BLUSH)

p = R.part('eyes')
for ex in (13, 21):
    p.add(p.m(ell(ex + .5, 22.3, 1.6, 1.9)), (INK,) * 4, flat=True)
    p.px(ex, 21, CREAM)
p.line([(11, 19), (15, 20)], INK); p.line([(20, 20), (24, 19)], INK)                  # stern captain's brows

p = R.part('hat')
crown = inter(ell(17.5, 15, 11.5, 8.5), lambda x, y: y < 15.2)
p.add(p.m(crown, rect(6.5, 13, 28.5, 16)), CAP, stitch=CAP[3])
p.add(p.m(ell(17.5, 16.3, 10.5, 1.6)), BOOT, local=True)                            # dark peak
p.add(p.m(ell(17.5, 10.5, 2.2, 2.2)), GOLD, local=True, crescent=0)                 # badge
p.px(17, 10, GOLD[3])
p.line([(7, 14), (28, 14)], GOLD[1])                                                  # gold band

R.save()
