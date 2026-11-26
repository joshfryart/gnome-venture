#!/usr/bin/env python3
"""crew-sorrel "Sorrel Inkcap" (folk rig, 43 x 56, 9 parts, front view): the Trek crew's map-maker, Seedkeeper mentor who keeps the
Seed Library at Olivewhistle Shore: "A quiet snail librarian with ink-stained eyestalks" (Shy; villagers.lua: snail, face #d9a660,
cream clothes #f2e4c0, shell #9a6b3f; "Sorrel inks a little map").
A soft tan snail head, a smooth rounded dome with a small shy smile and little round spectacles (head); two button eyes behind the
lenses (eyes); the two tall eyestalks with ink-blue stained tips, which wobble as one piece like a hat (hat); a cream librarian's
cardigan with brown buttons, a belt and a little ink pot (body); cream sleeves with tan hands, the left hugging a green seed-catalogue
book, the right holding up a quill (armL / armR); soft tan foot-slippers (footL / footR); and behind the left shoulder the big brown
spiral shell she carries (back). The shell lump and stalks make her silhouette lopsided and tall, unlike the round hedgehog."""
import math, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from rigkit import *  # noqa

R = Rig('crew-sorrel')
SKIN = ('#f0c890', '#d9a660', '#b5824a', '#8a5a2e')
SHELL = ('#c9935a', '#9a6b3f', '#74462a', '#4a2c1a')
KNIT = ('#fff8e0', '#f2e4c0', '#d8c495', '#b09a68')
INKB = ('#8a72c8', '#4e3a8a', '#3a2a66', '#2a1a4a')
BOOK = PINE

p = R.part('back')                                                                    # the spiral shell behind the left shoulder
shell = union(ell(11.5, 27, 9.5, 10.2), ell(15.5, 34.5, 4.5, 4))
p.add(p.m(shell), SHELL, stitch=None)
pts = []
for k in range(40):                                                                   # the spiral groove
    t = k / 39 * 2.3 * math.pi
    r = 8.2 - t * 1.0
    pts.append((11 + math.cos(t + 2.4) * r, 26.5 + math.sin(t + 2.4) * r * 1.05))
p.line(pts, SHELL[3])
p.add(p.m(ell(10.5, 25.5, 2, 2)), SHELL, local=True, crescent=0)
p.px(6, 21, SHELL[0]); p.px(7, 20, SHELL[0])

for pid in ('footL', 'footR'):
    p = R.part(pid)
    x, y = R.pv(pid)
    sx = -1 if pid == 'footL' else 1
    p.add(p.m(capsule([(x, y - 1.5), (x, y + 1.5)], 4.6), ell(x + sx * .8, 49.4, 4.8, 2.4)), SKIN)
    p.line([(x - 2, 47), (x + 2, 47)], SKIN[2])

p = R.part('body')
cardi = union(poly([(13.5, 34), (29.5, 34), (31.5, 46), (21.5, 47.5), (11.5, 46)]), ell(21.5, 35.5, 8.5, 2.8))
p.add(p.m(cardi), KNIT, stitch=KNIT[3])
p.line([(21, 35), (21, 46)], KNIT[3])                                                  # cardigan opening
for y in (37, 40, 44):
    p.px(22, y, WOOD[2])                                                               # buttons
p.add(p.m(inter(cardi, rect(11, 41, 32, 42.6))), WOOD, flat=True)                      # belt
p.add(p.m(rect(26, 43, 30, 46.5)), INKB, local=True, crescent=0)                       # ink pot on the belt
p.edge(p.m(rect(26, 43, 30, 46.5)), INKB[3]); p.px(27, 44, INKB[0])

for pid in ('armL', 'armR'):
    p = R.part(pid)
    x, y = R.pv(pid)
    sx = -1 if pid == 'armL' else 1
    hand = (x + sx * 1.8, 42)
    if pid == 'armL':                                                                  # the seed catalogue hugged to her side
        pass
    else:                                                                              # the quill held up
        p.add(p.m(capsule([(hand[0] + .5, hand[1] + 1), (hand[0] + 3.5, 31)], 1.2)), INKB, flat=True)
        p.add(p.m(rell(hand[0] + 4.5, 29, 1.8, 4.8, 20)), ('#ffffff', '#fff3c8', '#e0d6c0', '#c9c5bc'), local=True)
        p.line([(hand[0] + 3.7, 32), (hand[0] + 5.5, 25)], STONE[2])
    p.add(p.m(capsule([(x, y + .5), hand], 5, 4.4)), KNIT)
    p.add(p.m(ell(hand[0], 43, 2.3, 2.2)), SKIN, local=True)
    p.line([(hand[0] - 2, 41), (hand[0] + 2, 41)], KNIT[3])
    if pid == 'armL':                                                                  # the book in front of the paw
        bk = poly([(6, 38.5), (12.5, 37.5), (13, 46), (6.5, 47)])
        p.add(p.m(bk), BOOK, local=True)
        p.line([(7, 39.5), (7.5, 46)], KNIT[1])                                        # page edges
        p.pxs([(10, 41), (10, 42), (11, 41), (11, 42)], GOLD[1])                       # a gold seed on the cover

p = R.part('head')
hx = 21.5
skull = union(ell(hx, 23.5, 9.8, 10.5), ell(hx, 31, 7.5, 3.6))
p.add(p.m(skull), SKIN)
for ex in (17.5, 25.5):                                                                # round wire spectacles
    p.edge(p.m(minus(ell(ex + .5, 23, 3.4, 3.4), ell(ex + .5, 23, 2.4, 2.4))), GOLD[3])
p.line([(20.5, 22), (22.5, 22)], GOLD[3])
p.line([(19, 28), (20, 29), (23, 29), (24, 28)], SKIN[3])                              # shy smile
p.pxs([(14, 27), (15, 27), (28, 27), (29, 27)], BLUSH)
p.px(16, 16, SKIN[0]); p.px(17, 15, SKIN[0])

p = R.part('eyes')
for ex in (17.5, 25.5):
    p.add(p.m(ell(ex + .5, 23, 1.5, 1.8)), (INK,) * 4, flat=True)
    p.px(int(ex), 22, CREAM)

p = R.part('hat')                                                                      # the eyestalks, ink-stained at the tips
p.add(p.m(ell(hx, 15.2, 5.5, 2)), SKIN)                                                # the root of the stalks on the crown
for sx in (-1, 1):
    base, mid, tip = (hx + sx * 3.5, 15.5), (hx + sx * 5, 9), (hx + sx * 7.5, 4.5)
    p.add(p.m(capsule([base, mid, tip], 3.4, 2.2)), SKIN, local=True)
    p.add(p.m(ell(tip[0], tip[1], 2.9, 2.9)), INKB, local=True, crescent=1)
    p.px(tip[0] - 1, tip[1] - 1, INKB[0])
    p.px(mid[0], mid[1] + 1, INKB[2]); p.px(mid[0] + sx, mid[1] - 1, INKB[2])          # ink drips down the stalk

R.save()
