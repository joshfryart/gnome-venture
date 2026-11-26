#!/usr/bin/env python3
"""dust-sidewinder "Dust Sidewinder" (snake rig, 87 x 46, 8 parts, medium lv 15, desert, heat/sun): "Travels sideways, which is somehow more alarming."
A pale dusty felt sidewinder lying low and slanted in a flat S across the sand: the thin tail tip with a dark button end (s1),
a short stout pale-sand body (s2..s5) carrying a row of cocoa saddle blotches down the back and a cream belly, a low neck (s6)
barely lifted. head = a broad flat arrowhead head, with the two little horns standing up over the eyes that give the sidewinder
its look, a pink forked tongue. eyes = a squinting amber eye with a slit pupil under the horn's heavy brow."""
import importlib, math, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from rigkit import *  # noqa
S = importlib.import_module('_snake_grass-snake')
ALL = S.ALL

R = Rig('dust-sidewinder')
SIDE = ('#fff3c8', '#eed6a2', '#d0ac78', '#a8875a')    # pale sand felt
BACK = ('#fbe8bc', '#e6c992', '#c9a26c', '#9a7a4a')
BELLY = ('#fffbe8', '#fff3c8', '#eadcb2', '#c9a96e')
BLOT = ('#a87048', '#8a5634', '#5e3820', '#4a2c1a')     # cocoa saddles
TIP = (5, 38.4)
W = (1.4, 4.6, 7.4, 8.6, 9, 8.2, 7)                     # thin tail, short stout body
MID = {'s2': (26.5, 37.6), 's4': (43.5, 36), 's5': (52.5, 29.5)}
BUTTON = ell(TIP[0] - .2, TIP[1] - .1, 1.9, 1.6)          # the dark button at the tail tip
SADDLES = {'s1': (.5, .8)}                                 # body segments: one saddle centred on the stretch the next segment leaves showing


def marks(p, pid, shape, a, b, r):
    dx, dy, L = S.unit(a, b)
    nx, ny = -dy, dx                                      # n points down to the belly, -n up to the back
    if pid == 's1':
        btn = p.m(inter(shape, BUTTON))
        p.fill(btn, BLOT[2]); p.fill({q for q in btn if (q[0], q[1] - 1) not in btn}, BLOT[0])   # a cocoa button, lit on top so it reads on dark
        p.fill(p.m(inter(shape, lambda x, y: abs(x - TIP[0] - 2.4) < .5)), BLOT[2])   # a sewn ring behind it
    ang = math.degrees(math.atan2(dy, dx))
    for t in SADDLES.get(pid, ((L - r * .8) / 2 / L + .08,)):
        cx, cy = a[0] + dx * L * t - nx * r * .55, a[1] + dy * L * t - ny * r * .55
        rw = 1.7 if pid == 's1' else (2.8 if pid == 's6' else 3.3)
        sad = p.m(inter(shape, rell(cx, cy, rw, r * 1.15, ang), minus(ALL, S.below(a, b, r * .3))))
        p.add(sad, (BLOT[0], BLOT[1], BLOT[1], BLOT[2]), flat=True)
        p.edge(sad, BLOT[2])


P, REF, out = S.snake(R, TIP, W, SIDE, BACK, BELLY, mid=MID, pattern=marks, back_band=.25, belly_band=.45, seam=SIDE[2],
                      belly_stitch=BELLY[3], extra={'s1': BUTTON})

# head: broad, flat arrowhead (wide jaw corners behind, pointed snout), two little horns over the eye, pink forked tongue
p = R.part('head')
hp = P['head']
neck = capsule([hp, (62.5, 14.5)], 7, 7.5)
skull = poly([(58.2, 11.2), (61.5, 8.4), (66, 7.8), (73, 8.6), (78.6, 11.2), (78.4, 12.6), (72, 15), (64.5, 17), (60.5, 18.6), (57.6, 16.4)])
hornF = poly([(68.2, 8.6), (69.4, 4.6), (70.4, 4.4), (71.2, 8.8)])   # far horn, a step darker
hornN = poly([(64.6, 8.4), (65.6, 3.4), (66.8, 3.2), (68.0, 8.4)])   # near horn
p.add(p.m(union(neck, skull)), SIDE)
p.add(p.m(inter(skull, lambda x, y: y < 10.6)), BACK)
p.add(p.m(hornF), darker(BACK), local=True)
p.add(p.m(hornN), BACK, local=True)
p.fill(p.m(inter(hornF, lambda x, y: y < 6)), BLOT[3])
p.fill(p.m(inter(hornN, lambda x, y: y < 5)), BLOT[3])
p.add(p.m(inter(skull, lambda x, y: y > 13.6 and x > 61)), BELLY, local=True)
p.line([(77.5, 12.4), (71, 14.2), (64, 15.8)], BLOT[2])               # the wide mouth seam
p.add(p.m(inter(skull, rell(62.6, 12.4, 3.4, .75, 22))), (BLOT[1],) * 4, flat=True)   # dark stripe behind the eye, down to the jaw corner
p.px(76, 10, BLOT[3])                                                  # nostril
S.tongue(p, (79, 12), 2, col=PETAL[2])

# eyes: squinting amber slit eye under a heavy brow, between the horns
p = R.part('eyes')
S.eyeball(p, 67, 10.5, 1.3, '#f5cf6a', lid=BACK[2], lidcut=10.0)

R.save()
