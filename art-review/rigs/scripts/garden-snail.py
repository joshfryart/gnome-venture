#!/usr/bin/env python3
"""garden-snail "Garden Snail" (snail rig, 53 x 44, 6 parts): "Slow, sticky and astonishingly stubborn about who owns the path."
(small, lv 1, forest / grassland / wetland / coast, rain and fog; Snail Slime, Spiral Shell; the very first fight a new gnome meets)
The classic felt garden snail, as a soft toy: a big round caramel shell (shell) sewn with a gold spiral band and a dark groove that
winds out to the aperture lip, a little clover sprout stitched on top; a long, low, putty-tan foot (body) tapering to a pointed tail,
with a darker sole band and a running stitch along the skirt, and a wet sheen on the back; a plump neck and face (head) with a
blush cheek and a stubborn little mouth; two tall soft eye stalks with dark knobs (antL / antR) and a heavy-lidded, unimpressed
button eye (eyes). Silhouette: the round-shell-on-a-foot every child draws; the round shell and warm colours set it apart from the
spiky quartz snail and the slumped rot snail."""
import importlib, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from rigkit import *  # noqa
H = importlib.import_module('_mollusc_garden-snail')

R = Rig('garden-snail')
P = {k: R.pv(k) for k in R.ids}
FOOT = ('#fbe6c8', '#f0c496', '#c9956a', '#9a6844')
SHELLC = ('#e8a86a', '#c47a3e', '#9a5a2c', '#6a3a1e')
BAND = ('#f5d98a', '#e8b84a', '#c89a3a', '#9a6a2a')
GROUND = R.ground + 1

# body: the long low foot, pointed tail behind, sole band and skirt stitch, wet sheen on the back
p = R.part('body')
foot = union(ell(31, 35, 15.5, 5.6), capsule([(4.5, 38.4), (12, 37), (20, 34.5)], 2.6, 8))
foot = inter(foot, lambda x, y: y < GROUND)
p.add(p.m(foot), FOOT)
p.fill(p.m(inter(foot, lambda x, y: y >= GROUND - 1.6, lambda x, y: x > 8)), FOOT[2])          # the sole
H.stitch_line(p, [(9, 37), (20, 36.4), (32, 36.6), (44, 36)], FOOT[3])                      # skirt stitch
for x, y in ((38, 31), (40, 31), (13, 35), (27, 31)):                                       # wet sheen
    p.px(x, y, '#fffaf0')

# shell: the round caramel shell, gold spiral band, dark groove, aperture lip, clover sprout
p = R.part('shell')
SC = (21, 18.6)
body = ell(SC[0], SC[1], 13, 13.2)
p.add(p.m(capsule([(19.5, 4.5), (20.5, 6.5)], 1.4)), MOSS, local=True, crescent=0)                # sprout stem
p.add(p.m(ell(17.6, 3.6, 2.2, 1.5), ell(22, 3.4, 2.2, 1.5)), MOSS, local=True, crescent=1)         # clover leaves
p.add(p.m(body), SHELLC, stitch=None)
sp = H.spiral(SC[0] + 1.6, SC[1] + 1.2, 1.0, 11.2, 2.15, start=3.4)
band = p.m(inter(capsule(sp, 2.6), body))
H.blob(p, band, BAND)
groove = p.m(inter(capsule(H.spiral(SC[0] + 1.6, SC[1] + 1.2, 2.2, 12.6, 2.15, start=3.4), 1.1), body))
p.fill(groove, SHELLC[3])
p.add(p.m(inter(ell(SC[0] + 1.6, SC[1] + 1.2, 1.6, 1.6), body)), (SHELLC[3],) * 4, flat=True)
p.line([(10.5, 28.5), (16, 31.4), (24, 31.6), (30.5, 28.5)], SHELLC[3])                       # the aperture lip seam
p.px(13, 9, '#fff3c8'); p.px(14, 8, '#fff3c8'); p.px(12, 10, BAND[0])                         # felt shine

# head: neck rising out of the foot, round face and snout
p = R.part('head')
head = union(capsule([P['head'], (40.5, 28)], 9, 9), ell(42.6, 26.4, 7.6, 5.6), ell(46.4, 28.2, 4.4, 3.8))
p.add(p.m(head), FOOT)
p.add(p.m(ell(45.6, 29.8, 1.4, 1)), (BLUSH,) * 4, flat=True)
p.line([(47.5, 30.5), (48.5, 31), (50, 30.5)], FOOT[3])                                                   # the stubborn little mouth
p.line([(37, 27.5), (36.8, 31)], FOOT[2])                                                   # neck crease

# eye stalks: soft putty tubes, dark knobs leaning a little apart
p = R.part('antL')
H.stalk(p, P['antL'], (35.4, 13.6), FOOT, w0=2.8, w1=2, knob=2.1, knob_ramp=WOOD, mid=(37, 18.5))
p = R.part('antR')
H.stalk(p, P['antR'], (46.6, 12.8), FOOT, w0=2.8, w1=2, knob=2.1, knob_ramp=WOOD, mid=(44.8, 18))

# eyes: one heavy-lidded, unimpressed button eye
p = R.part('eyes')
H.button_eye(p, P['eyes'][0], P['eyes'][1], 1.6, lid=FOOT[2], lidcut=.1)

R.save()
