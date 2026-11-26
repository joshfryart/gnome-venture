#!/usr/bin/env python3
"""blight-mother "Blight Mother" (bug.moth rig, 101 x 81, 10 parts): "A swollen aphid queen, grey and glistening, who pours out blighted
young." (boss, trek chapter I, level 19; she spawns Withered Aphids every 4th round)
A huge felt aphid queen, side view, hovering: a swollen pear-shaped abdomen in glistening blue-grey felt (sewn ring seams, white gloss
glints, sickly plum blight blotches), two tail-pipe cornicles poking up at the rear, black blight oozing from the tail tip and one tiny
grey nymph spilling out of it (body); a humped thorax. Long clear aphid wings: membrane felt, a dark front vein with the plum
stigma spot, a few branching veins (wingF the near fore wing, wingB the far one behind the head, wingH the small hind wing).
head: a small grey head under a tarnished crooked crown, with a long sucking beak tucked down under the chest; eyes: one red
button eye under a heavy mean lid (the same red as her Withered Aphid young); long knobbly feelers sweep back and forward (antL, antR);
two pairs of thin knobbly legs hang below (leg1 the back pair, leg2 the front pair)."""
import importlib, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from rigkit import *  # noqa
H = importlib.import_module('_crawler_basalt-borer')

R = Rig('blight-mother')
GREY = ('#eef0f4', '#b9bccb', '#8a8ea2', '#5e6176')
HEADC = ('#d6d8e2', '#9fa2b4', '#74778c', '#4e5064')
LEG = ('#9a8e9e', '#6e6274', '#4e4454', '#342c3a')
MEMB = ('#fbfaff', '#e2deec', '#bcb6cc', '#8a84a0')
VEIN = '#6a5e80'
BLIGHT = ('#b08aa0', '#8a6a80', '#6a4a62', '#4a3046')
OOZE = ('#5a3a52', '#2e1d2c', '#1e121c', '#120a10')
CROWN = ('#e8d08a', '#c0a04a', '#8a7030', '#5a4620')
GLOSS = '#ffffff'


def wing(pid, shape, base, ramp, veins, stigma):
    p = R.part(pid)
    p.add(p.m(shape), ramp, stitch=ramp[3])
    for pts in veins:
        p.line(pts, VEIN if ramp is MEMB else ramp[3])
    p.add(p.m(stigma), BLIGHT, local=True, crescent=0)
    return p


# wings (all behind the body)
wing('wingB', union(rell(53, 19, 18, 6.5, 71), capsule([R.pv('wingB'), (56, 30)], 4, 7)), None, darker(MEMB),
     [[(59.5, 36), (55, 22), (49.5, 6)], [(55, 22), (54, 12)]], rell(51.5, 12, 3.2, 1.3, 71))
wing('wingF', union(rell(22, 20, 19.5, 9.5, 35), capsule([R.pv('wingF'), (32, 27)], 5, 12)), None, MEMB,
     [[(47.5, 37), (30, 22), (14, 9.5), (6, 7)], [(30, 22), (24, 25.5), (13, 22)], [(36, 30.5), (30, 33)], [(24, 16), (20, 19)]],
     rell(21, 13.5, 4.5, 1.6, 35))
wing('wingH', union(rell(22, 45, 16.5, 5.6, 14), capsule([R.pv('wingH'), (33, 46)], 4, 8)), None, MEMB,
     [[(43, 44.5), (24, 42), (8, 39)], [(26, 42.5), (20, 47.5)]], rell(16, 40, 3, 1.2, 14))

# legs: two thin knobbly pairs per part, the far one darker
for pid, legs in (('leg1', [((44.5, 60), (37, 67), (35, 75.5), (32.5, 76)), ((47, 59), (48.5, 67), (45.5, 75.5), (43, 76))]),
                  ('leg2', [((57, 59), (57.5, 67), (54.5, 75.5), (57, 76)), ((59.5, 58), (66, 65.5), (69, 75.5), (72, 76))])):
    p = R.part(pid)
    x, y = R.pv(pid)
    for k, (a, kn, ft, toe) in enumerate(legs):
        rp = darker(LEG) if k == 0 else LEG
        p.add(p.m(capsule([(x, y - 1), a, kn], 4, 3), capsule([kn, ft], 3, 2.4), capsule([ft, toe], 2.2, 1.8)), rp, local=True, crescent=1)
        p.add(p.m(ell(kn[0], kn[1], 2, 2)), rp, local=True, crescent=1)
        p.px(kn[0] + .5, kn[1] + .5, rp[3])

# body: swollen abdomen, humped thorax, cornicles, ooze and a nymph spilling out
p = R.part('body')
abdo = union(ell(36, 49.6, 19.4, 15), ell(53.5, 47, 8.5, 8.5), ell(56.5, 42.5, 6.5, 5.6), ell(55, 53, 6, 5.5))
pipes = union(capsule([(25, 41), (19.5, 33.5)], 4.4, 3.6), capsule([(21, 46), (13.5, 42.5)], 4.4, 3.6))
p.add(p.m(pipes), darker(GREY), local=True, crescent=1)
for q in ((19.5, 33.5), (13.5, 42.5)):
    p.add(p.m(ell(q[0], q[1], 1.8, 1.8)), OOZE, local=True, crescent=0)
ooze = union(capsule([(19.5, 56), (18, 61.5)], 6, 4), ell(17.5, 64.5, 3.4, 3.6))
p.add(p.m(ooze), OOZE, local=True, crescent=1)
p.px(17, 63, '#7a5a72'); p.px(18, 57, '#7a5a72')
am = p.add(p.m(abdo), GREY, stitch=GREY[3])
p.fill(p.m(inter(abdo, lambda x, y: y > 59 - (x - 36) * .08)), GREY[2])          # dusky underside (override: keeps the stitch ring whole)
for x0 in (29, 37, 45):                                                            # ring seams, curved round the swell
    p.line([(x0 + 2, 38), (x0, 44), (x0 - .5, 52), (x0 + 1.5, 60)], GREY[3])
p.line([(50, 39), (49, 46), (50, 55)], GREY[3])                                   # waist seam
for q, r in (((32, 55), 2.6), ((42, 45), 2), ((25, 50), 2.2), ((53, 51), 1.6)):     # blight blotches
    H.blob(p, p.m(inter(ell(q[0], q[1], r * 1.3, r), abdo)), BLIGHT)
for pts in ([(29, 39), (33, 37.5), (38, 37.5)], [(43, 38), (44, 38)], [(54, 39), (57, 38)], [(20, 46), (20, 49)]):    # glistening glints
    p.line(pts, GLOSS)
p.px(34, 40, GREY[0]); p.px(55, 41, GREY[0])
p.fill(p.m(inter(ell(33, 41.5, 7, 3.2), minus(lambda x, y: True, ell(33, 42.6, 6.4, 2.6)))) & p.m(abdo), GLOSS)   # a wet gloss crescent
nym = union(ell(23.5, 62, 4, 3), ell(27, 61, 2.2, 2))                            # a tiny nymph spilling out with the ooze
NYM = ('#e8e4cc', '#bab59a', '#8c8770', '#5e5a4a')
p.add(p.m(nym), NYM, local=True, crescent=1)
p.px(27, 60, '#e0503a'); p.px(28, 60, INK); p.line([(22, 64), (21, 65.5)], NYM[3]); p.line([(25, 64), (25, 65.5)], NYM[3])

# head: small grey head, crooked crown, sucking beak tucked down under the chest
p = R.part('head')
hx, hy = R.pv('head')
p.add(p.m(capsule([(66, 44.5), (63.5, 51), (60.5, 58)], 3.4, 2.2)), LEG, local=True, crescent=1)            # beak
crown = poly([(57.5, 33.5), (56.5, 27), (59, 29.5), (60.5, 25), (62.5, 29), (65.5, 26.5), (65, 32)])
p.add(p.m(crown), CROWN, local=True, crescent=1)
p.px(60, 28, '#dd3a2a')
hd = union(ell(66, 38, 7.6, 8.2), capsule([(hx, hy), (62, 41)], 8, 8), ell(65.5, 31, 2.4, 2.2), ell(70.5, 31, 2.4, 2.2))
hm = p.add(p.m(hd), HEADC)
H.seam_over(p, hm, R.part('body').m(abdo), HEADC[3])
p.add(p.m(inter(ell(66, 38, 7.6, 8.2), lambda x, y: y > 43)), (HEADC[1], HEADC[2], HEADC[3], HEADC[3]), flat=True)
p.add(p.m(ell(62, 37, 1.6, 1.2)), BLIGHT, local=True, crescent=0)
p.line([(68, 43), (71.5, 42)], HEADC[3])
p.pxs(((72, 44), (73, 44)), BLUSH)

p = R.part('eyes')
ex, ey = R.pv('eyes')
H.button_eye(p, ex, ey, 2.6, iris='#e0503a', lid=HEADC[3], brow=[(66, 34), (73, 36.5)])

# feelers: long and knobbly, one swept back, one forward
for pid, pts in (('antL', [R.pv('antL'), (65, 21), (59, 12.5), (52, 8.5)]), ('antR', [R.pv('antR'), (75, 20), (80, 13), (86, 10)])):
    p = R.part(pid)
    p.add(p.m(capsule(pts, 2.8, 1.8)), LEG, crescent=0)
    for q in pts[1:-1]:
        p.add(p.m(ell(q[0], q[1], 1.6, 1.6)), LEG, local=True, crescent=0)

R.save()
