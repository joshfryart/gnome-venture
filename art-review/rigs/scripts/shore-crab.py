#!/usr/bin/env python3
"""shore-crab "Shore Crab" (crab rig, front view, 79 x 48, 9 parts): "Sidesteps, then pinches." (medium, lv 7, coast and island;
Crab Claw, Crab Shell)
A plain green shore crab in olive felt, the everyday crab of the batch: a wide, low carapace seen a little from above, four little
felt teeth on each shoulder, a darker domed back with the crab's H groove and pale freckles, and a warm orange underside with a small
stitched smile and blush (body); two button eyes on short stalks (eyeL / eyeR, sprung); two equal mitten claws raised and open, olive
with pale gold finger tips and umber points (clawL / clawR); four jointed olive legs splayed to the sand, the inner pair a step darker
(leg1..leg4, behind). Silhouette: low and wide, all teeth and raised mittens; no shell, crown or armour (its siblings have those)."""
import math, os, sys
from importlib import import_module
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from rigkit import *  # noqa
CK = import_module('_crab_shore-crab')

R = Rig('shore-crab')
X = CK.mirror(R)
SHELL = ('#d4dc98', '#9aae58', '#6b7f34', '#3f4a22')
BACK = ('#b8c47a', '#7f9440', '#5a6a2a', '#3f4a22')
BELLY = ('#fbd890', '#f0a050', '#c87430', '#7a4a1f')
TIP = '#4a2c1a'

for pid, knee, foot in (('leg1', (11.5, 29), (3.5, 42.5)), ('leg2', (20, 32.5), (13, 42.5))):
    CK.leg(R, pid, knee, foot, SHELL if pid == 'leg1' else darker(SHELL), tip=TIP)
    CK.leg(R, 'leg4' if pid == 'leg1' else 'leg3', (X(knee[0]), knee[1]), (X(foot[0]), foot[1]), SHELL if pid == 'leg1' else darker(SHELL), tip=TIP)

p = R.part('body')
cx = R.pv('body')[0]
teeth = [ell(cx + s * 24.5 * math.cos(math.radians(a)), 29 - 12.5 * math.sin(math.radians(a)), 2.2, 2.2) for s in (-1, 1) for a in (12, 27, 42, 57)]
cara = union(ell(cx, 29, 23, 11.5), *teeth)
p.add(p.m(cara), SHELL, stitch=None)
dome = inter(ell(cx, 27, 20, 9.5), lambda x, y: y < 31.5)
p.add(p.m(dome), BACK, stitch=None)                                                          # the domed back, a stitched felt panel
p.add(p.m(inter(ell(cx, 31, 21, 9.5), lambda x, y: y > 33)), BELLY)                    # the orange underside under the rim
p.line([(cx - 3, 20), (cx - 1, 22), (cx + 1, 22), (cx + 3, 20)], BACK[3])                # the H groove of a real shore crab
p.line([(cx - 6, 26), (cx - 2, 27.5), (cx + 2, 27.5), (cx + 6, 26)], BACK[3])
for x, y in ((cx - 9, 23), (cx + 8, 23), (cx - 13, 28), (cx + 12, 28), (cx - 4, 30), (cx + 5, 30)):   # pale freckles
    p.px(x, y, SHELL[0])
p.line([(cx - 2.5, 36.5), (cx - 1, 37.5), (cx + 1, 37.5), (cx + 2.5, 36.5)], INK)           # small smile
CK.blush(p, cx - 7, 36); CK.blush(p, cx + 7, 36)

for pid, look in (('eyeL', 0), ('eyeR', 0)):
    CK.stalk_eye(R, pid, 9.5, SHELL, knob=3.5, stalk=2.4, look=look, lean=-.5 if pid == 'eyeL' else .5)

for pid, s in (('clawL', -1), ('clawR', 1)):
    p = R.part(pid)
    a = R.pv(pid)
    D = lambda dx: a[0] + s * dx
    elbow, wrist = (D(8), 25.5), (D(10.5), 19)
    p.add(p.m(capsule([a, elbow], 4.6, 4), capsule([elbow, wrist], 4, 4.4)), SHELL, crescent=1)
    p.px(int(elbow[0]), 26, SHELL[3])
    palm = ell(D(11), 14, 6.8, 6.2)
    outer = capsule([(D(14.5), 11), (D(16), 6.5), (D(14.5), 3)], 5, 2.4)                 # the fixed finger (outside)
    inner = capsule([(D(8), 11), (D(6.5), 7), (D(8.5), 4)], 4.2, 2.2)                     # the moving finger (inside)
    p.add(p.m(outer, inner), SHELL, local=True, crescent=1)
    p.add(p.m(palm), SHELL, local=True)
    p.add(p.m(inter(union(outer, inner), lambda x, y: y < 6.5)), ('#fff0b8', '#f5cf6a', '#e8a317', '#b87a14'), flat=True)   # pale gold finger tips
    p.pxs([(int(D(14.5)), 3), (int(D(8.5)), 4)], TIP)                                    # umber points
    p.line([(D(7.5), 15.5), (D(11), 10.5)], SHELL[2])                                    # the seam between palm and finger
    p.px(int(D(12.5)), 16, SHELL[0]); p.px(int(D(13.5)), 17, SHELL[0])

R.save()
