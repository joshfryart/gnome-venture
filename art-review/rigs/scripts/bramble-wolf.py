#!/usr/bin/env python3
"""bramble-wolf "Bramble Wolf" (quad.canid rig, 95 x 58, 8 parts): "Woven from thorny vines, it hunts by the smell of fresh soil."
(large, forest, L22; Bramble Pelt, Thorn Fang; Howl)
A big wolf sewn from twisted bramble: a heavy body with high hunched shoulders, wrapped in braided vine strands (diagonal felt
seams in two greens), a crest of hooked bark-cream thorns along the back and bigger hackle thorns on the shoulders, two red
rose hips (body); legs as twisted vine bundles ending in clawed paws (far legs a dark step down); a vine-whip tail with thorns
and a leaf at the tip (tail, sprung); a long heavy wolf head with leaf-shaped ears, a thorn ruff, a sniffing nose, a jaw of
cream thorn fangs (head), and a glowing amber eye under a heavy brow (eyes). The biggest, darkest, spikiest of the batch."""
import importlib.util, os, sys
_s = importlib.util.spec_from_file_location('qk', os.path.join(os.path.dirname(os.path.abspath(__file__)), '_quad_arctic-fox.py'))
qk = importlib.util.module_from_spec(_s); _s.loader.exec_module(qk)
from rigkit import *  # noqa

R = Rig('bramble-wolf')
VINE = ('#6a9f4e', '#3f7436', '#2f5a2a', '#1a3318')
FARV = ('#3f7436', '#2f5a2a', '#244a22', '#1a3318')
THORN = ('#fff3c8', '#e0c690', '#c9a96e', '#9a6b3f')
LEAF = ('#c8d09f', '#9aa860', '#6b7a3a', '#3f4a22')
PALE = ('#f2f2d0', '#d8dca8', '#a8b070', '#6b7a3a')
HIP = ('#f08a4a', '#dd3a2a', '#a8241f', '#6e2038')


def weave(p, mask, step=5, slope=1.0, col=VINE[3], hi=VINE[0]):
    """braided vine strands: broken diagonal seams with a light thread beside them"""
    for (x, y) in mask:
        k = (x + y * slope) % step
        if k < 1 and (y // 4 + x // 9) % 3 == 0:
            p.px(x, y, col)
        elif 1 <= k < 2 and (y // 4 + x // 9) % 3 == 0:
            p.px(x, y, hi)


def thorns(p, pts, h, ramp=THORN, lean=-1.2):
    """hooked bramble thorns: a narrow base on the skin, the tip leaning back"""
    for (x, y), hh in zip(pts, h):
        tip = (x + lean * hh * .45, y - hh)
        p.add(p.m(poly([(x - 2, y + 1.5), (x - 1, y - hh * .4), tip, (x + 2, y + 1.5)])), ramp, local=True)
        p.px(tip[0] + .5, tip[1] + .5, ramp[1]); p.px(tip[0] + 1, tip[1] + 1.2, ramp[1])


def tufts(p, pts, ramp, d=(-1, 1.2), L=4):
    """shaggy ruff tufts: little pointed flaps hanging back and down from each point"""
    for (x, y) in pts:
        p.add(p.m(poly([(x - 1.8, y - 1.5), (x + d[0] * L, y + d[1] * L), (x + 2, y + 1.2)])), ramp)


for pid, ramp, back in (('legBF', FARV, True), ('legFF', FARV, False)):
    g = qk.hind(R, pid, ramp, 6.5, 4.5, back=3.5) if back else qk.leg(R, pid, R.pv(pid)[0] + 1, ramp, 5.5, 4.5)
    weave(g, qk.sil(R, pid), 5, -1.0, ramp[3], ramp[0])

# tail: a bushy tangle of vine held back and up, tapering to a point, thorns along it and a leaf caught in it
p = R.part('tail')
path = [(29, 28), (22.5, 25.5), (16.5, 20.5), (12.5, 14.5), (11, 9)]
tl = p.m(capsule(path, 6, 3), capsule(path[:4], 6, 9), qk.fluff([(23, 29.5), (17, 26), (11.5, 21), (8.5, 15.5)], 2, 2.6))
p.add(tl, VINE)
weave(p, tl, 4, -1.0)
thorns(p, [(23, 22.5), (18.5, 18), (15, 13)], [3, 3, 3], lean=-1.2)
p.add(p.m(rell(19.5, 26.5, 1.8, 3.2, 60)), LEAF, local=True)                          # one leaf caught in the tangle

# body: hunched shoulders, deep chest, tucked waist, braided vine wrap, thorn crest and hackles, rose hips
p = R.part('body')
torso = union(ell(57.5, 26, 9.5, 9.5), ell(45, 28, 14, 6.5), ell(33, 28.5, 8, 7))
thorns(p, [(29, 21.5), (35, 21.5), (41, 22), (47, 21), (52, 18), (57, 16), (62, 16)], [4, 4, 4, 4.5, 5.5, 6.5, 6.5])
mt = p.m(torso)
p.add(mt, VINE, stitch=None)
weave(p, mt, 5, 1.0)
p.add(p.m(inter(torso, lambda x, y: y > 31.5 and 44 < x < 66)), (VINE[1], VINE[2], VINE[3], VINE[3]))   # dark under-belly
tufts(p, [(66.5, 26), (67, 30), (65, 33), (61.5, 34.5), (57.5, 34.5)], PALE, d=(-.2, 1), L=5)                         # pale chest ruff
for cx, cy in ((51, 26.5), (40, 31)):
    p.add(p.m(ell(cx, cy, 2.1, 2.1)), HIP, local=True); p.px(cx - 1, cy - 1, HIP[0]); p.px(cx, cy - 2, VINE[3])
p.add(p.m(rell(46.5, 25, 1.6, 3, 50)), LEAF, local=True)

for pid, ramp, back, ag in (('legBN', VINE, True, ('legBF', 'body')), ('legFN', VINE, False, ('legFF', 'body'))):
    g = (qk.hind(R, pid, ramp, 7.5, 5, back=3.5, against=ag, seamcol=VINE[3]) if back
         else qk.leg(R, pid, R.pv(pid)[0] + 1, ramp, 6, 5, against=ag, seamcol=VINE[3]))
    weave(g, qk.sil(R, pid), 5, -1.0, ramp[3], ramp[0])
    fx = R.pv(pid)[0] + (0 if back else 1)
    for dx in (0, 2.5, 5):
        g.px(fx + dx - .5, R.ground, THORN[2])                                         # claws

# head: long heavy wolf head, leaf ears, thorn ruff, cream thorn fangs
p = R.part('head')
skull = ell(68, 17.5, 8.5, 7)
snout = poly([(71, 12), (77, 14), (83.5, 16), (86, 17.5), (86, 22), (79, 24), (70, 25)])
jaw = poly([(70, 22), (82, 22), (81, 25), (76, 27), (69, 27)])
neck = capsule([R.pv('head'), (66, 20)], 11, 11)
thorns(p, [(64, 10.5)], [4], lean=-2.5)
ears = union(poly([(61, 13), (61.5, 2.5), (67, 11)]), poly([(65.5, 11), (69.5, 2), (72.5, 12)]))
p.add(p.m(ears), VINE, local=True)
p.add(p.m(union(poly([(62.5, 11.5), (62.5, 5.5), (65.5, 10.5)]), poly([(67.5, 10.5), (69.5, 5), (71, 11)]))), LEAF, flat=True)
p.add(p.m(skull, snout, neck, jaw), VINE)
p.add(p.m(inter(union(snout, jaw, skull), below((64, 23), (87, 20.5), 0))), PALE)          # pale muzzle and jaw
tufts(p, [(62, 18), (61.5, 22), (63, 25.5)], PALE, d=(-1, .7), L=4.5)                         # pale cheek ruff
weave(p, p.m(minus(union(skull, neck), below((64, 23), (87, 20.5), 0))), 5, 1.0)
qk.nose(p, 84.5, 17)
p.line([(85.5, 21.5), (80, 22.5), (77, 23.5)], INK)                                       # mouth
for x, y in ((80, 23), (83, 22)):
    p.px(x, y, THORN[0]); p.px(x, y + 1, THORN[1])              # thorn fangs hanging from the lip
p.line([(67, 13), (74, 14.5)], VINE[3])                                             # heavy brow

p = R.part('eyes')
qk.eye(p, 70.8, 17.1, iris='#f5cf6a')

R.save()
