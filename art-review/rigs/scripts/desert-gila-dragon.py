#!/usr/bin/env python3
"""desert-gila-dragon "Gila Dragon" (snake rig, 87 x 40, 8 parts, large lv 20, desert):
"Pink and black and slow, until it isn't. Its bite stays with you."
A heavy felt gila monster: a fat sausage-short tail lying on the sand (s1, s2) ringed pink and charcoal, a low broad body
(s3..s5) of charcoal felt with blotchy coral-pink saddles, the whole hide sewn with little round bead knots; four stubby legs with
fat clawed feet (hind on s3, fore on s5, far ones darker). head = a big blunt charcoal head with a pink cheek blotch, a heavy jaw
held slightly open on a pink gum line with a drop of venom in the jaw groove. eyes = a small mean beady eye under a heavy brow."""
import importlib, math, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from rigkit import *  # noqa
L = importlib.import_module('_lizard_delta-gharial')

R = Rig('desert-gila-dragon')
SIDE = ('#6a5660', '#463640', '#33262e', '#1e1519')      # charcoal felt, lightened so it holds on the dark theme
BACK = ('#5a4852', '#3d2e37', '#2c2028', '#1e1519')
BELLY = ('#e8b0a0', '#c98a86', '#9c5e66', '#6e3a48')
PINK = ('#ffd0c0', '#f6927e', '#d8606a', '#9c3a4e')
BEAD = '#2a1e24'
TIP = (5.5, 32.3)
W = (6, 10.5, 14, 16, 16, 14, 13)


def saddle(x, y):
    """coral saddles across the back and rings on the tail; wobbly edges so they read as blotches, not stripes"""
    return math.sin(x * .42 + y * .25 + math.sin(y * .9) * .8) > .15


def marks(p, pid, cap, a, b, r):
    p.add(p.m(inter(cap, saddle, lambda x, y: not below(a, b, r * .55)(x, y))), PINK, ref=p.REF)
    for (x, y) in p.m(cap):                       # bead knots sewn over the whole hide
        if x % 3 == (y // 2) % 3 and y % 2 == 0 and not below(a, b, r * .45)(x + .5, y + .5):
            p.px(x, y, PINK[2] if saddle(x + .5, y + .5) else SIDE[0])


legs = [('s3', (32, 30), (30, 33), 31, 4.2, False), ('s3', (27, 31), (22.5, 33.5), 24.5, 4.6, True),
        ('s5', (48, 28), (46, 32), 47.5, 4.2, False), ('s5', (53, 28), (49.5, 32.5), 52, 4.6, True)]
P, REF, segs = L.lizard(R, TIP, W, SIDE, BACK, BELLY, legs=legs, pattern=marks, seam=PINK[3], legramp=('#8a7480', '#5e4a56', '#3d2e37', '#1e1519'))
for pid, (x, y) in (('s3', (25, 32)), ('s5', (51.5, 30.5))):     # coral spot on each near leg
    R.part(pid).fill(R.part(pid).m(ell(x, y, 1.3, 1.1)), PINK[1])

# head: big blunt charcoal head, pink cheek, jaw a little open on a pink gum line
p = R.part('head')
skull = union(ell(66, 13.5, 7.5, 6.2), ell(72.5, 10.5, 8.5, 6), ell(78.5, 11.5, 4, 3.6))
jaw = union(ell(70, 16.5, 7.5, 3), ell(77.5, 15.2, 4, 2.2))
p.add(p.m(skull, jaw), SIDE)
p.add(p.m(inter(skull, ell(67, 12.5, 4.2, 3.4))), PINK, local=True)            # the coral cheek blotch
p.add(p.m(jaw), BELLY, local=True)
p.line([(81, 13.5), (76, 14), (70, 14.5), (66.5, 15.5)], INK)                    # the clamped mouth
p.line([(80, 14.5), (75, 15)], PINK[1])                                          # pink gum showing
p.px(73, 15, '#f2f7d8'); p.px(73, 16, '#c8e0a0')                                 # a bead of venom in the groove
for (x, y) in p.m(skull):
    if x % 3 == (y // 2) % 3 and y % 2 == 0 and y < 13:
        p.px(x, y, PINK[2] if ell(67, 12.5, 4.2, 3.4)(x + .5, y + .5) else SIDE[0])
p.px(81, 10, BEAD); p.px(80, 11, BEAD)                                           # nostril
p.line([(62, 9), (62, 18)], SIDE[3])                                             # neck seam

# eyes: a small beady eye with a pale ring under a heavy charcoal brow
p = R.part('eyes')
L.eyeball(p, 73.5, 7.7, 1.4, '#f0c890', pupil='round')
p.line([(71, 6), (76, 5.5)], INK)
p.line([(71, 5), (75, 4.5)], BACK[0])

R.save()
