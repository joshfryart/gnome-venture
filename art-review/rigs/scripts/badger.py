#!/usr/bin/env python3
"""badger "Badger" (quad.bear rig, 79 x 46, 8 parts): "An armoured digger who does not like visitors."
(large, forest/grassland, L18; drops Badger Pelt, Badger Claw)
A low, wide European badger in grizzled silver felt: a flat wedge of a body, highest at the hips and sloping down to the shoulders,
its coat quilted in rows of silver guard-hair stitches like a padded jerkin (the 'armour'), the flanks going dark below and a
ragged fringe of pointed fur tufts hanging over the legs (body). Short, thick black legs; the front ones bowed, with big spade paws
and three long cream digging claws raking forward (legFN/legFF), the far pair one step darker. A short silver stub of a tail (tail).
A long, low, pointed head: white, with the bold black stripe running from the ear over the eye down to the snout, white crown and
cheek, small white-rimmed ears, a black button nose (head); a small eye glinting inside the stripe (eyes).
The lowest, widest, flattest silhouette of the batch."""
import importlib.util, os, sys
_s = importlib.util.spec_from_file_location('qb', os.path.join(os.path.dirname(os.path.abspath(__file__)), '_quad_bramble-wolf.py'))
Q = importlib.util.module_from_spec(_s); _s.loader.exec_module(Q)
from rigkit import *  # noqa

R = Rig('badger')
GREY = ('#e6e2da', '#b4b0aa', '#8a8890', '#5f5e68')
DARKF = ('#8a8890', '#6a6872', '#55535e', '#3e3c46')
LEGC = ('#5a5662', '#3a3742', '#2c2a33', '#222028')
FAR = darker(LEGC)
WHITE = ('#fffaf0', '#f2ede2', '#d6cfc0', '#a8a090')
STRIPE = ('#45424e', '#2e2c35', '#2e2c35', '#222028')
SILVER = '#e6e2da'
CLAW = ('#fff3c8', '#f2e4c0', '#c9a96e', '#9a6b3f')
g = R.ground


def dig_leg(pid, pts, w0, w1, paw, ramp, claws=False, against=()):
    p, m = Q.limb(R, pid, pts, w0, w1, ramp, paw=paw)
    if claws:                                                      # three long digging claws raking forward off the paw
        fx = int(paw[0] + paw[1] - 1)
        for k in range(3):
            cm = p.m(rect(fx + 2 * k, g - 1, fx + 2 * k + 2, g), rect(fx + 2 * k + 1, g, fx + 2 * k + 3, g + 1))
            p.add(cm, CLAW, flat=True); m |= cm
            p.px(fx + 2 * k, g - 1, CLAW[2])
    else:
        Q.claws(p, (int(paw[0] + paw[1] - 1), int(paw[0] + paw[1] - 3)), g, CLAW[2])
    if against:                                                    # a near leg: the fur skirt continues over its top
        ref = Q.sil(R, 'body') | m
        p.add({(x, y) for (x, y) in m if y < 32 + 2.5 - abs((x + 1) % 4 - 2) * 1.2}, DARKF, ref=ref)
        p.add({(x, y) for (x, y) in m if y + .5 < 27.5 - (x - 18) * .05}, GREY, ref=ref)
        for x in range(int(pts[0][0]) - 3, int(pts[0][0]) + 4, 4):
            p.line([(x, 31.5), (x - .6, 33.5)], DARKF[3])
        Q.seam(p, R, m, against, ramp[3])
    return p, m


# far legs (behind the body)
dig_leg('legBF', [(26.4, 28), (26.5, 37)], 9, 7, (27.8, 4.6, 2.6), FAR)
dig_leg('legFF', [(54.6, 28), (56, 37)], 8.5, 6.5, (57, 4.4, 2.6), FAR, claws=True)

# tail: a short silver stub, pale-tipped
p = R.part('tail')
t = union(capsule([(18, 19.5), (12.5, 17.5)], 6, 5), Q.fluff([(13, 15.5), (11, 17.5), (12, 20)], 1.9))
tm = p.add(p.m(t), GREY)
p.add(p.m(inter(t, lambda x, y: x < 12.5)), (WHITE[0], WHITE[1], GREY[1], GREY[2]), local=True)
p.line([(16, 18), (13, 17)], GREY[2])

# body: a flat wedge, high at the hips; quilted silver coat; dark lower flanks; ragged pointed fringe over the legs
p = R.part('body')
torso = union(ell(25, 20.5, 10, 10), ell(39, 21.5, 13.5, 8.8), poly([(22, 11), (32, 11.5), (44, 13.5), (52, 17), (55, 26), (52, 29.5), (18, 29.5)]), ell(52.5, 28.5, 4, 4))
fringe = union(rect(17, 28, 55, 32), *[poly([(x - 3.2, 31), (x + 3.2, 31), (x - .8, 35.6 - (k % 2))]) for k, x in enumerate((19, 23, 27, 31, 35, 39, 43, 47, 51, 54.5))])
whole = union(torso, fringe)
bm = p.add(p.m(whole), GREY, stitch=GREY[3])
p.add(p.m(inter(whole, lambda x, y: y > 27.5 - (x - 18) * .05)), DARKF, local=True)        # the dark underside and fringe
for row, (y0, xs) in enumerate(((14, range(22, 48, 5)), (18.5, range(19, 52, 5)), (23, range(21, 53, 5)))):
    for x in xs:                                                                              # quilted guard-hair stitches
        x = x + (2 if row % 2 else 0)
        yy = y0 + (x - 18) * .06
        if (int(x), int(yy)) in bm:
            p.line([(x, yy), (x + 2, yy + 1)], GREY[3]); p.px(x, yy - 1, SILVER)
for x in (21, 25, 29, 33, 37, 41, 45, 49, 53):
    p.line([(x, 31.5), (x - .6, 34)], DARKF[3])                                             # fringe partings

# near legs (over the body), tops hidden under the fringe
dig_leg('legBN', [(21, 28), (20.5, 37)], 9.5, 7.5, (22.2, 5, 2.8), LEGC, against=('legBF', 'body'))
dig_leg('legFN', [(49.5, 28), (51, 37)], 9, 7, (52, 4.8, 2.8), LEGC, claws=True, against=('legFF', 'body'))

# head: long, low and pointed; white with the black stripe from the ear over the eye to the snout
p = R.part('head')
ears = union(ell(53, 15.3, 2.6, 2.4), ell(57.8, 14.2, 2.4, 2.2))
skull = union(ell(56.5, 20.5, 7, 6), capsule([R.pv('head'), (53, 21.5)], 10, 9))
snout = poly([(58, 15), (66, 17.8), (72.5, 21), (73, 23.5), (66, 25.5), (57, 26.5)])
p.add(p.m(ears), STRIPE, local=True)
p.add(p.m(union(ell(52.6, 14, 1.7, 1.1), ell(57.4, 13, 1.6, 1.1))), (WHITE[0],) * 4, flat=True)   # white ear rims
head = union(skull, snout)
hm = p.add(p.m(head), WHITE)
p.add(p.m(inter(head, lambda x, y: x < 52.5)), GREY, local=True)                       # the grey neck back to the body
p.add(p.m(inter(head, lambda x, y: y > 25 - max(0, x - 58) * .15)), DARKF, local=True)   # dark throat
stripe = capsule([(52.5, 17), (57, 17.6), (63, 19.2), (70.5, 21.6)], 5, 2)
p.add(p.m(inter(stripe, head)), STRIPE, flat=True)
p.add(p.m(ell(72.5, 22, 1.6, 1.5)), (INK,) * 4, flat=True); p.px(72, 21, '#6a5648')       # nose
p.line([(71, 24.5), (66, 25)], DARKF[2])                                                   # mouth
Q.seam(p, R, hm, ('body',), GREY[3])

p = R.part('eyes')
p.add(p.m(rect(60, 17, 62, 19)), (INK,) * 4, flat=True)
p.px(60, 17, CREAM); p.px(61, 19, '#6a6672')

R.save()
