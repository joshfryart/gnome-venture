#!/usr/bin/env python3
"""herring-gull "Herring Gull" (bird rig, 57 x 40, 7 parts): "Screams, swoops and steals." (medium, coast and island, level 10)
A felt seaside gull standing side-on, chest out like it owns the chip shop: a long white body (body), a long folded silver-grey
wing reaching past the tail with sooty black primaries and white mirror dots (wing, +r lifts it), a short white tail tucked under
the wing tips (tail), a flat-browed white head with a big yellow hooked bill and the red gonys spot (head), a pale mean eye under a
grey brow line (eyes), and pink webbed legs (legB darker behind, legF in front)."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from rigkit import *  # noqa

R = Rig('herring-gull')
WHITE = ('#ffffff', '#f1ece0', '#c9c5bc', '#8b8f96')
GREY = ('#e4e8ee', '#b9c0cc', '#8b8f96', '#5b6470')
BLACK = ('#5b5560', '#2b2630', '#1a161c', '#000000')
LEG = PETAL
BILL = ('#fff3c8', '#f5cf6a', '#e8a317', '#b87a14')
G = R.ground + 1          # bottom edge of the ground row


def leg(pid, ramp):
    p = R.part(pid)
    x, y = R.pv(pid)
    p.add(p.m(capsule([(x, y - 1.5), (x + .3, G - 1.5)], 2.6, 2.2)), ramp)
    web = poly([(x - 1.5, G - 2), (x + .5, G - 2.6), (x + 5, G - 1.2), (x + 5, G), (x - 1.8, G)])
    p.add(p.m(web), ramp, local=True, crescent=0)
    p.px(int(x) + 2, G - 1, ramp[3]); p.px(int(x) + 4, G - 1, ramp[3])


p = R.part('tail')
tail = poly([(21, 18.5), (9.5, 20), (8.5, 22.5), (10, 24.5), (21, 24)])
p.add(p.m(tail), WHITE)
p.line([(11, 22), (17, 21.5)], WHITE[2])

leg('legB', darker(LEG))

p = R.part('body')
bod = union(rell(29, 20, 12.5, 7.2, -8), ell(36, 17, 6, 6))
p.add(p.m(bod), WHITE, stitch=WHITE[2])
p.add(p.m(inter(bod, lambda x, y: y < 15.5 - (x - 28) * .15)), GREY)      # grey mantle on the back
p.pxs([(33, 24), (28, 25), (37, 22)], WHITE[2])                            # belly feather ticks

leg('legF', LEG)

p = R.part('wing')
wing = union(rell(26, 17, 10, 4.4, -6), capsule([(20, 18), (13, 21), (6.5, 23.5)], 6.5, 2.6))
p.add(p.m(wing), GREY, local=True)
tips = inter(wing, lambda x, y: x < 15.5)
p.add(p.m(tips), BLACK, local=True)
p.edge(p.m(wing), GREY[3], sides=((1, 0), (0, 1), (-1, 0)))               # its own seam over the body
p.px(11, 21, '#ffffff'); p.px(8, 23, '#ffffff')                            # white mirror dots in the black tips
p.line([(16, 20.5), (24, 19)], WHITE[0])                                   # white tertial edge
p.line([(21, 16), (31, 15.5)], GREY[2])                                    # covert seam

p = R.part('head')
hx, hy = 39.5, 8.8
head = union(ell(hx, hy, 6.2, 5.6), capsule([R.pv('head'), (38, 10)], 7.5, 7))
p.add(p.m(head), WHITE)
bill = union(poly([(44, 7.2), (52, 7.6), (54.6, 9), (54.2, 11.5), (52.5, 10.2), (44.5, 11.2)]),
             poly([(45, 10.4), (51, 10.6), (52, 12.6), (45.5, 12)]))
p.add(p.m(bill), BILL, local=True, crescent=0)
p.line([(45, 10), (52, 10)], BILL[3])                                      # gape line
p.add(p.m(ell(51.2, 11.6, 1, 1)), (EMBER[1],) * 4, flat=True)              # the red gonys spot
p.pxs([(34, 5), (36, 4)], WHITE[2])                                        # faint streaks on the nape
p.px(42, 12, BLUSH)

p = R.part('eyes')
ex, ey = 40, 6
p.add(p.m(rect(ex - 1, ey, ex + 2, ey + 2)), ('#f5cf6a',) * 4, flat=True)  # pale yellow eye
p.px(ex + 1, ey, INK); p.px(ex + 1, ey + 1, INK)
p.line([(ex - 2, ey - 1), (ex + 3, ey)], GREY[3])                          # the mean flat brow

R.save()
