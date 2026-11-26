#!/usr/bin/env python3
"""carrion-crow "Carrion Crow" (bird rig, 51 x 40, 7 parts): "Clever, patient, and very interested in your hat." (grassland, forest, mountain; lv 9)
A sleek felt crow standing tall and leaning forward: a blue-black body with a glossy violet sheen on the back and a scruffy
throat ruff (body), a folded wing with long crossed primaries reaching past the rump (wing, +r lifts it), a square-cut fan tail (tail),
a flat-crowned head with the heavy grey crow bill holding a stolen gold trinket ring (head), a pale clever eye under a sly lid (eyes),
and slate legs with long toes (legB darker behind, legF in front). Dark felt is kept a step lighter than the ink so the outline reads."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from rigkit import *  # noqa

R = Rig('carrion-crow')
CROW = ('#7a7898', '#4c4864', '#363248', '#221e2e')      # blue-black felt, lifted off the ink
SHEEN = ('#9a8cc8', '#6e62a0', '#4e3a8a', '#3a2e66')
BILL = ('#a4a8b0', '#6e7480', '#4c525e', '#343842')
LEG = ('#8b8f96', '#5b6470', '#454b56', '#343842')
G = R.ground


def leg(pid, ramp):
    p = R.part(pid)
    x, y = R.pv(pid)
    p.add(p.m(rect(int(x) - 1, y, int(x) + 1, G)), ramp, flat=True)                     # 2 px shank
    p.add(p.m(rect(int(x) - 3, G - 1, int(x) + 5, G + 1)), ramp, flat=True)            # long toes on the ground
    p.cut |= {(int(x) - 1, G - 1), (int(x) + 2, G - 1), (int(x) + 3, G - 1), (int(x) + 4, G - 1), (int(x) - 3, G - 1)}
    p.px(int(x) + 1, G, ramp[3]); p.px(int(x) - 2, G, ramp[3])
    p.add(p.m(ell(x, y + 1, 2.4, 2.6)), darker(CROW) if pid == 'legB' else CROW, local=True)   # feathered thigh top


leg('legB', darker(LEG))
leg('legF', LEG)

# tail: a long square-cut fan behind the rump
p = R.part('tail')
fan = poly([(19, 18.5), (8, 21), (5, 22.5), (5.5, 26.5), (9, 26), (19, 24.5)])
p.add(p.m(fan), darker(CROW), local=True)
p.line([(16, 21.5), (7, 23.5)], CROW[3]); p.line([(16, 23.5), (8, 25.5)], CROW[3])

# body: leaning crow body, throat ruff, belly
p = R.part('body')
bod = union(rell(25.5, 20, 12.5, 7.8, -18), ell(33.5, 15, 5.2, 5.5), poly([(34, 11), (38.5, 16), (37, 21), (33, 22)]))
p.add(p.m(bod), CROW, stitch=CROW[3])
p.add(p.m(inter(rell(24, 17, 10, 4, -18), bod)), (SHEEN[0], SHEEN[1], SHEEN[1], SHEEN[2]), flat=True)   # glossy back
for q in ((37, 18), (36, 20), (38, 16), (35, 22)):                                    # shaggy throat ruff
    p.px(q[0], q[1], CROW[0])
p.pxs([(31, 25), (28, 26), (34, 23)], CROW[3])

# wing: folded, primaries crossing past the rump
p = R.part('wing')
w = poly([(20, 12.5), (27, 12), (32, 14.5), (32.5, 18), (28, 22), (20, 24.5), (11, 26), (9.5, 25), (15, 20)])
wm = p.add(p.m(w), CROW, stitch=None)
p.edge(wm, CROW[3], sides=((0, -1),))                                                  # a dark seam where the wing sits on the back
p.add(p.m(inter(w, poly([(20, 12), (28, 11.5), (33, 15), (24, 17.5), (17, 16.5)]))), (SHEEN[0], SHEEN[1], SHEEN[2], SHEEN[3]))   # covert shoulder
for a, b in (((28, 19), (12, 24.5)), ((26, 17.5), (14, 22)), ((30, 16.5), (19, 19.5))):
    p.line([a, b], CROW[3])

# head: flat crown, heavy bill with a gold ring
p = R.part('head')
hx, hy = 35.5, 8.5
skull = union(ell(hx, hy, 6, 5.6), capsule([R.pv('head'), (35, 10)], 6.5, 6), poly([(30, 5), (35, 2.8), (40, 4), (40, 8)]))
p.add(p.m(skull), CROW)
upper = poly([(39.5, 5), (44, 5.2), (48, 7.2), (49.5, 9.5), (45, 9), (39.5, 9.5)])
lower = poly([(39.5, 9.3), (45, 9), (48.5, 9.8), (44.5, 11.6), (39.5, 12)])
p.add(p.m(upper), BILL, local=True)
p.add(p.m(lower), (BILL[1], BILL[2], BILL[3], BILL[3]), local=True)
p.line([(40, 9), (48, 9)], BILL[3])
p.px(42, 6, BILL[3])                                                                   # nostril
ring = minus(ell(45.5, 12.5, 2.6, 2.4), ell(45.5, 12.5, 1.2, 1.1))                     # the shiny trinket dangling from the bill
p.add(p.m(ring), GOLD, local=True, crescent=1)
p.px(44, 11, '#fff3c8')
p.pxs([(33, 13), (31, 11), (34, 12)], CROW[0])                                        # scruffy cheek tufts

# eyes: a pale clever eye with a sly lid
p = R.part('eyes')
ex, ey = 37, 6
p.add(p.m(ell(ex + 1, ey + 1, 2.5, 2.4)), ("#d8d4e0",) * 4, flat=True)                # pale grey ring
p.add(p.m(rect(ex, ey, ex + 2, ey + 2)), (INK,) * 4, flat=True)
p.px(ex, ey, CREAM)
p.line([(ex - 2, ey - 2), (ex + 2, ey - 2)], CROW[3])                                 # a sly flat lid

R.save()
