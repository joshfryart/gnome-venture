#!/usr/bin/env python3
"""giant-anteater "Giant Anteater" (quad.bear rig, 111 x 51, 8 parts): "Wears its tail like a cloak and its tongue like a whip."
(large, rainforest, L22; drops Digging Claw, Rubber Sap, Ant Chitin)
A long, deep-bodied felt anteater: oatmeal-grey body highest at the shoulders and sloping back to the hips, a shaggy hair fringe
along the belly, and the famous black shoulder wedge edged in cream running from the throat up over the shoulder to a point on
the back (body). A huge banner of a tail held out behind and up, long dark hair hanging from it like a cloak, combed into strands
with a ragged hem (tail). Pale front legs with the black wrist band, walking on the knuckles with hooked cream claws tucked up
(legFN/legFF); dark hind legs with flat feet (legBN/legBF), far pair one step darker. A small skull with a round ear and a very
long tapering tube snout, the pink whip of a tongue flicking from the tip (head); a small bead eye (eyes).
The longest silhouette of the batch: tail banner, deep body, needle snout."""
import importlib.util, os, sys
_s = importlib.util.spec_from_file_location('qb', os.path.join(os.path.dirname(os.path.abspath(__file__)), '_quad_bramble-wolf.py'))
Q = importlib.util.module_from_spec(_s); _s.loader.exec_module(Q)
from rigkit import *  # noqa

R = Rig('giant-anteater')
OAT = ('#ddd2bf', '#b3a691', '#877a6a', '#5e5249')
DARK = ('#857668', '#665850', '#4e423e', '#3a302e')
BAND = ('#3a302e', '#2a2224', '#2a2224', '#2a2224')
PALE = ('#fbf6ea', '#e8e0cf', '#c2b6a0', '#8c7e6c')
TAIL = ('#9a8a7a', '#6e6058', '#524640', '#3a302e')
CLAW = ('#fff3c8', '#f2e4c0', '#c9a96e', '#9a6b3f')
g = R.ground


def front(pid, x, ramp, top, against=()):
    p, m = Q.limb(R, pid, [(R.pv(pid)[0], 29.5), (x, 40)], 8, 6, ramp, paw=(x + 1.5, 4, 2.8))
    p.add({q for q in m if q[1] < 35}, top, ref=m)                                  # shoulder in body colour
    p.add({q for q in m if 37 <= q[1] <= 39}, BAND, flat=True)                      # the black wrist band
    for k in range(2):                                                             # hooked claws tucked up on the knuckles
        cx = x + 3.5 + k * 2
        cm = p.m(capsule([(cx, g - .5), (cx + 1.6, g - 2), (cx + 1, g - 3.8)], 1.3, 1))
        p.add(cm, CLAW, flat=True); m |= cm
        p.px(cx + .6, g - 4, CLAW[2])
    if against:
        Q.seam(p, R, m, against, ramp[3])
    return p, m


def hind(pid, x, ramp, against=()):
    px_, py_ = R.pv(pid)
    p, m = Q.limb(R, pid, [(px_, 29.5), (px_ + 1.5, 37), (x, 41)], 8, 6, ramp, paw=(x + 1.5, 5, 2.4),
                  extra=(ell(px_ + .5, 32, 5.5, 6.5),))
    p.line([(px_ - 2.5, 35), (px_ + .5, 38.5)], ramp[2])                          # knee seam on the haunch
    Q.claws(p, (int(x + 4), int(x + 6)), g, PALE[2])
    if against:
        Q.seam(p, R, m, against, ramp[3])
    return p, m


# far legs, one step darker
hind('legBF', 42, darker(DARK))
front('legFF', 71, darker(PALE), darker(OAT))

# tail: a banner held back and up, long dark hair hanging from it like a cloak, combed strands, ragged hem
p = R.part('tail')
spine = [(35, 23.5), (27, 17), (19, 10.5), (12, 5.5)]
hem = [(10, 8), (10.5, 13.5), (13, 19), (17, 23.5), (22.5, 26.5), (29, 27.5)]
banner = union(capsule(spine, 7, 4.5), poly([(35, 21), (27, 14), (19, 7.5), (12, 3.5), (9, 7), (10.5, 15), (14, 21.5), (21, 26.5), (30, 28), (36, 26)]),
               *[poly([(x - 1.5, y - 3), (x + 2.5, y - 1.5), (x - 1.8, y + 2.6)]) for x, y in hem])   # ragged hem of hanging locks
tm = p.add(p.m(banner), TAIL)
for a, b in (((30, 20), (26, 27)), ((22, 13.5), (15.5, 22)), ((15, 8.5), (10.5, 14))):
    Q.strand(p, tm, [a, b], TAIL[3], 1)                                            # long hair combed down from the tail
Q.strand(p, tm, spine[:3], TAIL[0], 1)                                             # pale tail ridge
for a, b in (((28.5, 20), (25, 25)), ((18, 12.5), (13.5, 18.5))):
    Q.strand(p, tm, [a, b], TAIL[2], 1)

# body: deep, highest at the shoulders, belly fringe, the black shoulder wedge edged in cream
p = R.part('body')
torso = union(ell(52, 26.5, 19, 11), ell(63, 24.5, 10.5, 12), ell(39.5, 27, 9, 9.5),
              Q.fluff([(36, 34.5), (42, 36), (48, 37), (54, 37.5), (60, 37), (66, 35.5)], 2.6, 2.4))
bm = p.add(p.m(torso), OAT, stitch=OAT[3])
p.add(p.m(inter(torso, lambda x, y: y > 34)), darker(OAT), local=True)
wedge = [(65.5, 37.5), (60, 28), (53, 20), (43, 15.5)]
p.add(p.m(inter(capsule(wedge, 10.5, 4.5), torso)), PALE, flat=True)
p.add(p.m(inter(capsule(wedge, 6.5, 1.5), torso)), BAND, flat=True)
for x, y in ((36, 21), (42, 18), (47, 25), (41, 26), (47, 30), (62, 22), (35, 28), (52, 33)):
    p.line([(x, y), (x - 1, y + 2)], OAT[2])                                       # shaggy guard hairs

# near legs
hind('legBN', 36.5, DARK, against=('legBF', 'body'))
front('legFN', 66, PALE, OAT, against=('legFF', 'body'))

# head: small skull on the shoulder, little round ear, a long tube snout, pink whip tongue
p = R.part('head')
skull = union(ell(74.5, 25, 7, 6.2), capsule([R.pv('head'), (72, 27)], 8.5, 8))
snout = capsule([(76, 25.5), (90, 28.5), (104.5, 31)], 8, 3.4)
hm = p.add(p.m(skull, snout), OAT)
p.add(p.m(inter(union(skull, snout), below((74, 29.5), (105, 32.6), 0))), (OAT[0], OAT[0], OAT[1], OAT[2]), local=True)   # paler chin
em = p.add(p.m(ell(70.5, 20, 2.3, 2.2)), OAT, local=True)                          # little round ear
p.edge(em, OAT[3]); p.px(70, 20, OAT[3])
p.add(p.m(capsule([(105, 32), (107.5, 34.5), (106, 37.5), (103.5, 38)], 1.6, 1.2)), PETAL, flat=True)   # the whip of a tongue
p.add(p.m(ell(105.3, 30.8, 1.3, 1.2)), (INK,) * 4, flat=True)                      # nose tip
for x in (84, 90, 96):
    p.px(x, 27 + (x - 84) * .17, OAT[2])                                            # snout wrinkles
Q.seam(p, R, hm, ('body', 'legFN'), OAT[3])

p = R.part('eyes')
Q.bead(p, 76.6, 22.7, r=1.1)

R.save()
