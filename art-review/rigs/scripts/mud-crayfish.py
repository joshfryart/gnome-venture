#!/usr/bin/env python3
"""mud-crayfish "Mud Crayfish" (crab rig, front view, 81 x 63, 10 parts): "A crayfish the colour of a flowerpot, snapping at anything that
moves in its puddle." (trek ch2 claybound, medium, level 18; Wet Clay, Crayfish Claw)
A terracotta felt crayfish squaring up out of its puddle, seen from the front: a domed carapace with a pointed rostrum ridge between the
eyes, a stitched groove across the shell, smears of dark wet clay, cream little mouthparts and a blush, and two long whip feelers sweeping
up and out to both sides (body); two button eyes on short stalks either side of the rostrum (eyeL / eyeR, sprung); the jointed tail
rising behind the shell and opening into a wide five-lobed tail fan (tail, behind: not a sting); two big long-fingered claws raised high,
bumpy palms, dark fingertips and one claw gaping (clawL / clawR); four thin walking legs splayed to the mud (leg1..leg4, behind)."""
import math, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from rigkit import *  # noqa

R = Rig('mud-crayfish')
POT = ('#f8c090', '#dd7c42', '#ac522a', '#6e3020')
DEEP = ('#e88a5a', '#bf5a30', '#8a3a1e', '#5a2414')
PALE = ('#fde2c0', '#f0b888', '#c88a58', '#8a5530')
CLAY = '#74462a'
TIP = '#4a2c1a'
G = R.ground

for pid, knee, foot in (('leg1', (13, 43), (4, 56.5)), ('leg2', (21.5, 46.5), (14.5, 56.5)), ('leg3', (59.5, 46.5), (66.5, 56.5)), ('leg4', (68, 43), (77, 56.5))):
    p = R.part(pid)
    a = R.pv(pid)
    ramp = darker(POT) if pid in ('leg2', 'leg3') else POT
    p.add(p.m(capsule([a, knee], 3.6, 3), capsule([knee, foot], 3, 2)), ramp, crescent=0)
    p.px(int(knee[0]), int(knee[1]) + 1, POT[3])
    p.px(int(foot[0]), int(foot[1]), TIP)

p = R.part('tail')                                                                 # jointed tail rising behind, opening into a fan
tx = 30.5
plates = [((tx, 38), 9.6), ((tx - .3, 32), 9.2), ((tx - .6, 26.5), 8.8), ((tx - .9, 21.5), 8)]
for c, w in plates:
    p.add(p.m(rell(c[0], c[1], w / 2 + .4, 3.4, 0)), POT, local=True, crescent=1)
for c, w in plates[1:]:
    p.line([(c[0] - w / 2 + 1, c[1] + 2.6), (c[0] + w / 2 - 1, c[1] + 2.6)], POT[3])    # the seam under each tail plate
fc = (tx - 1.5, 14.5)
for ang, L, wd in ((-90, 9.4, 5.4), (-125, 8.8, 5), (-55, 8.8, 5), (-157, 8, 4.4), (-23, 8, 4.4)):
    r = math.radians(ang)
    tip = (fc[0] + math.cos(r) * L, fc[1] + math.sin(r) * L * .95)
    lobe = union(capsule([(fc[0], fc[1] + 4), tip], wd - 1, wd + .6), ell(tip[0], tip[1], wd / 2 + .3, wd / 2 + .3))
    p.add(p.m(lobe), DEEP if ang == -90 else POT, local=True, crescent=1)
    p.line([(fc[0] + math.cos(r) * 4, fc[1] + 4 + math.sin(r) * 3), (tip[0] - math.cos(r) * 1.5, tip[1] - math.sin(r) * 1.5)], POT[3])
p.add(p.m(ell(fc[0], fc[1] + 5, 4.4, 2.6)), POT, local=True)

p = R.part('body')
for s in (-1, 1):                                                                  # long whip feelers sweeping up and out
    pts = [(40.5 + s * 5, 36), (40.5 + s * 11.5, 29), (40.5 + s * 16.5, 19), (40.5 + s * 20.5, 9), (40.5 + s * 25.5, 3.5)]
    p.add(p.m(capsule(pts, 2.2, 1.2)), DEEP, flat=True)
    p.add(p.m(capsule([(40.5 + s * 4, 35), (40.5 + s * 8, 30.5), (40.5 + s * 9.5, 27)], 1.8, 1.2)), DEEP, flat=True)   # short feelers
shell = union(ell(40.5, 44.2, 15.8, 8.6), poly([(31, 40), (35, 34), (40.5, 30.5), (46, 34), (50, 40)]), ell(25.5, 40.5, 3.6, 3), ell(55.5, 40.5, 3.6, 3))
p.add(p.m(shell), POT, stitch=None)
belly = inter(ell(40.5, 47.6, 13.4, 5.4), lambda x, y: y > 47)
p.add(p.m(belly), PALE)
p.add(p.m(poly([(38.5, 39), (40.5, 31), (42.5, 39)])), DEEP, local=True)           # the rostrum ridge
p.line([(29, 41), (33, 43.5), (40.5, 44.5), (48, 43.5), (52, 41)], POT[3])          # the stitched groove across the shell
for x in (31, 35, 46, 50):
    p.px(x, 42 + (x in (35, 46)), POT[0])
for q in ((30, 46), (31, 46), (31, 47), (50, 45), (51, 45), (44, 39), (45, 39), (45, 40), (36, 48)):
    p.px(q[0], q[1], CLAY)                                                           # smears of wet clay
p.add(p.m(union(ell(38.8, 47.2, 1.5, 1.8), ell(42.2, 47.2, 1.5, 1.8))), PALE, local=True, crescent=0)   # mouthparts
p.px(39, 48, PALE[3]); p.px(42, 48, PALE[3])
p.add(p.m(ell(33.5, 46, 1.6, 1)), (BLUSH,) * 4, flat=True)
p.add(p.m(ell(47.5, 46, 1.6, 1)), (BLUSH,) * 4, flat=True)

for pid in ('eyeL', 'eyeR'):
    p = R.part(pid)
    x, y = R.pv(pid)
    s = -1 if pid == 'eyeL' else 1
    p.add(p.m(capsule([(x, y), (x + s * 1.2, y - 7)], 3.4, 3)), POT, local=True)
    p.add(p.m(ell(x + s * 1.2, y - 9.6, 3.6, 3.6)), (INK,) * 4, flat=True)
    p.add(p.m(ell(x + s * 1.2, y - 9.6, 2.5, 2.5)), (CREAM,) * 4, flat=True)
    p.add(p.m(rect(x + s * 1.2 - .5, y - 10.5, x + s * 1.2 + 1.5, y - 8)), (INK,) * 4, flat=True)
    p.px(x + s * 1.2 - 1.2, y - 11.4, '#ffffff')

for pid, s in (('clawL', -1), ('clawR', 1)):
    p = R.part(pid)
    a = R.pv(pid)
    X = lambda dx: a[0] + s * dx
    elbow, wrist = (X(11), 37.5), (X(14), 29)
    p.add(p.m(capsule([a, elbow], 4.6, 3.8), capsule([elbow, wrist], 3.8, 4.2)), POT, crescent=1)
    p.px(int(elbow[0]), int(elbow[1]), POT[3])
    gape = 1 if s < 0 else .4
    palm = rell(X(14.5), 21.5, 4.8, 7.4, s * -6)
    inner = capsule([(X(12.5), 16), (X(10.5 + 1.5 * gape), 9.5), (X(11.5 + 2 * gape), 4)], 3.4, 2)
    outer = capsule([(X(16.8), 15.5), (X(17.4), 9.5), (X(15.6), 4.5)], 3.6, 2.2)
    p.add(p.m(inner, outer), DEEP, local=True, crescent=1)
    p.add(p.m(palm), POT, local=True)
    p.pxs([(int(X(11.5 + 2 * gape)), 4), (int(X(11.5 + 2 * gape)), 5), (int(X(15.6)), 4), (int(X(15.6)), 5)], TIP)   # dark finger tips
    for q in ((X(13), 19), (X(15.5), 22), (X(13.5), 25), (X(16), 18)):
        p.px(q[0], q[1], POT[0])                                                     # felt bumps on the palm
    p.line([(X(14.5), 15.5), (X(14.5), 12)], DEEP[3])                                # the notch between the fingers

R.save()
