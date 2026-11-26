#!/usr/bin/env python3
"""pl-rrc-6 Rose Canyon Camel: whimsy-camel, round knobs. A resting (kushed) camel in side view whose body is the piece core:
hump = round tab N, round blank E (behind the rump), round blank S (gap between folded knees), neck + head rising from the W corner.
Striped saddle blanket in the cell's rose #e8a898 / mauve #c47e86 with cream and the bunting teal; fur is the canyon sand."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, thick_path, knob, ramp

FUR = ramp('#e5b289')
FUR2 = ramp('#c9925f')
ROSE = ramp('#e8a898')
MAUVE = ramp('#c47e86')
CREAMR = ramp('#fbdeb6')
TEAL = ramp('#2a9a9a')
SNOUT = ramp('#f2cd98')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rect(17, 31, 56, 56)
    hump = knob('T', 'round', 37, 31, 0, -1, r=7.6 * k, nw=6.2)
    blankE = knob('B', 'round', 56, 43, 1, 0, r=4.4 * k)
    blankS = knob('B', 'round', 36, 56, 0, 1, r=4.0 * k)
    body = c.m(core, hump, minus=(blankE, blankS))
    c.add(body, FUR, stitch=None)
    # neck + head (front, W corner)
    nw = 9 if not c.small else 10
    neck = c.m(thick_path([(22, 40), (17, 28), (14, 18)], nw))
    c.add(neck, FUR)
    head = c.m(ell(14, 14, 7.5, 5.5), ell(7.5, 17, 4.6, 3.6))
    c.add(head, FUR)
    c.add(c.m(ell(7.5, 17.5, 4.4, 3.2)), SNOUT)
    ear = c.m(ell(19.5, 9.5, 2.2, 2.6))
    c.add(ear, FUR2)
    # folded knees (darker pads at the bottom corners)
    c.add(body & c.m(ell(25, 54, 6.5, 3.2), ell(48, 54, 6, 3.2)), FUR2)
    # striped saddle blanket draped over the hump and flanks
    blanket = body & c.m(lambda x, y: 24 <= x < 50 and y < 46)
    bands = [MAUVE, ROSE, CREAMR, TEAL, ROSE, CREAMR, MAUVE, ROSE, TEAL]
    bw = 3.0 if not c.small else 3.4
    y0 = 19.0
    for rp in bands:
        c.add(blanket & c.m(rect(0, y0, 64, y0 + bw)), rp)
        y0 += bw
    c.add(blanket & c.m(rect(0, y0, 64, 64)), ROSE)
    # tassel hem
    hem = body & c.m(rect(24, 46, 50, 48.5 if not c.small else 49))
    c.add(hem, MAUVE)
    if not c.small:
        for gx in range(25, 50, 4):
            c.px(*c.P(gx, 49), MAUVE[1])
            c.px(c.P(gx, 49)[0], c.P(gx, 49)[1] + 1, MAUVE[1])
    c.edge(blanket, MAUVE[1])
    # face
    c.eye(15, 13.5, look=(-1, 0))
    nx, ny = c.P(4.8, 16.2)
    c.px(nx, ny, K.UMBER2)
    c.smile(8, 19.5, K.UMBER2)
    c.blush(12.5, 17.5)


if __name__ == '__main__':
    rep = K.render_pal(fn, 'pl-rrc-6', 'Rose Canyon Camel', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-rrc-6-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-rrc-6.png')
    print(rep)
