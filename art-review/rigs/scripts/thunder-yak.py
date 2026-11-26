#!/usr/bin/env python3
"""thunder-yak "Thunder Yak" (quad.ungulate rig, 85 x 65, 9 parts; large; mountain; drops Frost Fur, Antler Shard; attack: charge)
"Its hooves on the pass sound like the sky clearing its throat."
A huge storm-slate felt yak: a tall shoulder hump falling to a low rump, the whole body a heavy wool coat with a long ragged
skirt of fringe tufts that hangs almost to the ground, and a gold lightning-bolt patch sewn on the flank. Near legs are wool
trousers with fringe ends over short dark shanks and black hooves; far legs show only their shanks under the skirt.
A long hairy tail hanging off the rump (tail). A low, heavy head with a dark shaggy forelock, a pale muzzle and wide cream
horns that sweep out and up (head); a long chest beard swinging under the jaw (mane). A small dark button eye (eyes)."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from rigkit import *  # noqa
import importlib
K = importlib.import_module('_quad_wild-boar')

R = Rig('thunder-yak')
FUR = ('#9aa6bc', '#6e7a94', '#515a74', '#363e54')
FAR = darker(FUR)
DEEP = ('#5e6680', '#454c64', '#343a4e', '#262a3a')
HOOF = ('#6a5648', '#4a3a32', '#2e221c', '#2a1a10')
SHANK = ('#5e6680', '#454c64', '#343a4e', '#262a3a')
HORN = ('#fffbe6', '#fff3c8', '#e8d6a8', '#b8946a')
G = R.ground + 1


def fringe(x0, x1, y, n, long=3.5):
    """a ragged row of long wool tufts hanging down to about y"""
    xs = [x0 + (x1 - x0) * i / (n - 1) for i in range(n)]
    return union(*[capsule([(x, y - 6), (x - .6, y + (i % 3 == 1) * 1.5 - (i % 3 == 2))], 3.2, 1.8) for i, x in enumerate(xs)])


# far legs: dark shanks under the skirt
K.leg(R, 'legBF', 31, DEEP, 5, 4, top=2, foot=HOOF, foot_w=5, foot_h=3)
K.leg(R, 'legFF', 58.5, DEEP, 5, 4, top=2, foot=HOOF, foot_w=5, foot_h=3)

# tail: a long hairy rope with a tufted end, hanging off the rump
p = R.part('tail')
p.add(p.m(capsule([(21.5, 31), (16.5, 33.5), (14.5, 39)], 3.2, 2.6), K.tufts([(14, 41), (15.5, 43), (13, 43.5)], 1.8)), DEEP, local=True)

# body: hump, low rump, ragged wool skirt; bolt patch on the flank
p = R.part('body')
torso = union(ell(29, 30, 11, 10), ell(47, 27, 15, 13), poly([(20, 26), (34, 19), (46, 13), (55, 15), (66, 30), (64, 46), (20, 44)]))
skirt = fringe(21, 64, 52, 12)
coat = p.m(torso, skirt, K.tufts([(40, 15.5), (45, 13.2), (50, 12.6), (55, 14), (35, 18)], 2.6))
p.add(coat, FUR, stitch=FUR[3])
p.add(p.m(inter(skirt, lambda x, y: y > 46)), DEEP, local=True)
for x in range(24, 64, 4):                                                              # long wool strands
    p.line([(x, 37 + (x % 8) / 2), (x - .5, 44 + (x % 3))], FUR[3])
bolt = poly([(39.5, 24), (46, 24), (43, 29), (47.5, 29), (37.5, 39), (40.5, 32), (36.5, 32)])
p.add(p.m(bolt), GOLD, local=True)

# near legs: wool trousers ending in fringe, short shank, black hoof
for pid, fx in (('legBN', 25.5), ('legFN', 53)):
    p = R.part(pid)
    px_, py_ = R.pv(pid)
    wool = union(capsule([(px_, py_ - 4), (fx, 48)], 9, 8), fringe(fx - 4, fx + 4, 53, 4))
    p.add(p.m(inter(capsule([(fx, 50), (fx, G - 3.5)], 4.6, 4.2), lambda x, y: y < G)), SHANK)
    p.add(p.m(inter(union(rect(fx - 2.6, G - 3, fx + 3.6, G), ell(fx + .5, G - 2.6, 3.0, 1.3)), lambda x, y: y < G)), HOOF, local=True)
    p.px(int(fx + 3), int(G - 1), INK); p.px(int(fx + 3), int(G - 2), INK)
    wm = p.add(p.m(wool), FUR, local=True)
    p.edge({q for q in wm if q[1] < py_ + 1}, FUR[3], sides=((0, -1),))
    p.line([(fx - 1, py_ + 2), (fx - 1.5, 50)], FUR[3])

# mane: the long chest beard under the jaw (behind the head)
p = R.part('mane')
beard = union(poly([(53, 25), (68, 30), (70, 40), (58, 42), (52, 34)]), fringe(55, 69, 47, 5, 4))
p.add(p.m(beard), DEEP, stitch=DEEP[3])

# head: low heavy face, pale muzzle, dark forelock, wide upswept horns
p = R.part('head')
p.add(p.m(capsule([(62, 16), (57.5, 11), (56.5, 5), (58.5, 2.6)], 3.8, 1.6)), darker(HORN), local=True)    # far horn
face = union(ell(64, 25, 8.5, 9), capsule([(66, 25), (75.5, 29.5)], 11, 9), capsule([R.pv('head'), (62, 26)], 10, 10))
p.add(p.m(face), FUR)
p.edge({q for q in p.m(face) if q[0] < 58}, INK, sides=((-1, 0), (0, -1)))             # seam where the head lies on the coat
p.add(p.m(ell(77, 30, 5, 4.2)), STONE, local=True)                                       # pale muzzle
p.px(80, 28, INK); p.px(80, 29, INK)                                                     # nostril
p.line([(80, 32.5), (75, 33)], INK)                                                      # mouth
p.add(p.m(K.tufts([(60, 17.5), (63.5, 16.5), (67, 17), (70, 18.5), (65, 19.5)], 2.6, 2.2)), DEEP, local=True)   # forelock
horn = p.m(capsule([(66, 17), (72.5, 13.5), (75.5, 7), (73.5, 2.6)], 4.4, 1.6))
p.add(horn, HORN, local=True)
p.edge({q for q in horn if q[1] > 13}, HORN[3], sides=((0, 1), (-1, 0)))
for q in ((72, 12), (74, 9)):
    p.px(q[0], q[1], HORN[2])

p = R.part('eyes')
K.eye_dot(p, 67, 23, r=1.3)

R.save()
