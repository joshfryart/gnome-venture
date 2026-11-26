#!/usr/bin/env python3
"""rot-snail "Rot Snail" (snail rig, 61 x 43, 6 parts): "Its shell is soft and black, and the trail it leaves kills grass."
(medium, lv 16, the topsoil trek; a Blightling: a grey, sickly, washed-out copy of the garden snail, more lost than cruel)
A felt snail gone wrong: the shell (shell) is a soft black felt lump that has sagged, low and lopsided, its back lobe drooping
over the foot like a wet sock, with a faded grey spiral groove, a darned patch of cross stitches and pale mould spots; a slumped
sickly grey-green foot (body) with black ooze drips; a heavy, drooping face
(head) with a frown; eye stalks that wilt (antL hooks back, antR flops forward) with bruised knobs; tired button eyes with dark rings
(eyes). Silhouette: the low, slumped, droopy one of the batch, next to the round garden snail and the spiky quartz snail."""
import importlib, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from rigkit import *  # noqa
H = importlib.import_module('_mollusc_garden-snail')

R = Rig('rot-snail')
P = {k: R.pv(k) for k in R.ids}
SICK = ('#dfe4cc', '#aab49a', '#7e8a72', '#545e4e')
ROT = ('#6a6470', '#463f4c', '#2e2834', '#1a161e')
MOULD = '#b8c4a0'
OOZE = ('#4a4252', '#2e2834', '#1a161e', '#1a161e')
GROUND = R.ground + 1

# body: a slumped foot, grey blotches, black ooze drips
p = R.part('body')
foot = inter(union(ell(36, 34.2, 18, 5.4), capsule([(3.5, 37.8), (12, 36.8), (23, 34)], 2.4, 8.4), ell(24.5, 32.5, 9.5, 4)), lambda x, y: y < GROUND)
p.add(p.m(foot), SICK)
p.fill(p.m(inter(foot, lambda x, y: y >= GROUND - 1.6, lambda x, y: x > 9)), SICK[2])
H.stitch_line(p, [(10, 36.4), (22, 35.6), (34, 35.8), (47, 35.2)], SICK[3])
for x, y in ((31, 31), (36, 32), (44, 31), (16, 34)):                                      # grey blight blotches
    p.px(x, y, SICK[2]); p.px(x + 1, y, SICK[2])
p.add(p.m(capsule([(33.5, 31), (33.5, 34)], 1.6, 1.2), capsule([(13, 33.5), (13, 35.5)], 1.4, 1)), OOZE, local=True, crescent=0)

# shell: soft black lump, sagging back lobe, faded spiral, darned patch, mould spots
p = R.part('shell')
C = (23.5, 21.5)
lump = union(ell(C[0], C[1], 12, 10.6), ell(13.6, 26.5, 5.6, 5.4), ell(30, 27, 6.5, 4.5), ell(11, 31, 2, 2.2))
p.add(p.m(lump), ROT, stitch=None)
p.fill(p.m(inter(capsule(H.spiral(C[0] + 1.5, C[1] + .6, 1.2, 10.5, 1.85, start=3.3, sq=.9), 1.2), ell(C[0], C[1], 11, 9.8))), '#7a7480')
patch = rect(26, 14, 31, 19)
p.fill(p.m(patch), '#6e6676')
for x, y in ((26, 14), (28, 14), (30, 14), (26, 18), (28, 18), (30, 18)):                    # darning crosses around the patch
    p.px(x, y, '#c8c0ce')
p.pxs([(25, 16), (31, 16)], '#c8c0ce')
for x, y, r in ((17, 15, 1.3), (31.5, 23, 1.1), (14.6, 24.6, 1)):
    p.add(p.m(ell(x, y, r, r)), (MOULD,) * 4, flat=True)
p.px(19, 12, '#8a8490'); p.px(18, 13, '#8a8490')                                             # a dull sheen
p.line([(14, 30.5), (21, 31.6), (29, 31.4), (35, 29.5)], ROT[3])

# head: a heavy, drooping face with a frown
p = R.part('head')
head = union(capsule([P['head'], (46.5, 26)], 10, 9.5), ell(49.6, 24.2, 7.8, 5.6), ell(54, 27, 4.8, 4))
p.add(p.m(head), SICK)
p.line([(52, 29.5), (54, 28.6), (56.5, 29.6)], SICK[3])                                      # frown
p.line([(43, 25.5), (42.6, 30)], SICK[2])

# eye stalks: wilting, bruised knobs
p = R.part('antL')
H.stalk(p, P['antL'], (40.2, 13.2), SICK, w0=3, w1=2.2, knob=2.2, knob_ramp=ROT, mid=(43.4, 10.4))
p = R.part('antR')
H.stalk(p, P['antR'], (56.8, 13.6), SICK, w0=3, w1=2.2, knob=2.2, knob_ramp=ROT, mid=(53, 10.4))

# eyes: tired, ringed
p = R.part('eyes')
ex, ey = P['eyes']
p.add(p.m(ell(ex, ey + .9, 2.9, 2.6)), (SICK[2],) * 4, flat=True)
H.button_eye(p, ex, ey, 1.6, lid=SICK[1], lidcut=.05)

R.save()
