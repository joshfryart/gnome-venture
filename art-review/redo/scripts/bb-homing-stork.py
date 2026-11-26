#!/usr/bin/env python3
"""bb-homing-stork: whimsy-stork, tri knobs. A white stork in flight, side on, facing left. Its body/wing is the square piece core:
tri TAB north (raised wing tip, black-tipped), tri TAB south (black flight feathers), tri BLANK east (notched tail). The neck, head and
long red beak break out west; red legs trail out the lower right. A sky-blue bundle with a cloud-white knot hangs from the beak
(cell 6-0: sky #9ccbe5, cloud white, a far-off bird)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, thick_path, knob, ramp

WHITE = ('#f4f2ea', '#c4cdd6', '#ffffff')
INK = ramp('#3a3640')
RED = ramp('#d8402a')
SKY = ramp('#9ccbe5')
CLOUD = ('#ffffff', '#dce9f1', '#ffffff')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = poly([(20, 19), (50, 19), (52, 21), (52, 43), (50, 45), (20, 45), (18, 43), (18, 21)])
    tabN = knob('T', 'tri', 36, 19, 0, -1, r=5.0 * k)
    tabS = knob('T', 'tri', 34, 45, 0, 1, r=4.6 * k)
    blankE = knob('B', 'tri', 52, 32, 1, 0, r=4.4 * k)
    body = c.m(core, tabN, minus=(blankE,))
    # legs trailing behind (under the body, then out to the lower right)
    lw = 2.8 if not c.small else 3.2
    c.add(c.m(thick_path([(44, 43), (54, 50), (61, 53)], lw)), RED)
    c.add(c.m(thick_path([(40, 44), (50, 53), (57, 58)], lw)), RED)
    c.add(body, WHITE, stitch='#c4cdd6')
    # black flight feathers: lower band + south tab, and the tip of the north tab
    band = c.m(lambda x, y: y > 35 + (3 if (int(x) // 5) % 2 else 0) and 18 <= x < 53)
    c.add((band & body) | c.m(tabS, minus=(core,)) | (c.m(tabS) & c.m(rect(0, 44, 64, 46))), INK)
    c.add(c.m(tabN) & c.m(rect(0, 0, 64, 12)), INK)
    # neck and head
    nw = 7.0 if not c.small else 7.6
    c.add(c.m(thick_path([(22, 27), (16, 22), (12, 17)], nw), ell(12, 13, 6.2, 5.4)), WHITE)
    # beak: long red wedge pointing left and slightly down
    bk = [(8.5, 10.5), (8.5, 18), (0.3, 22)] if not c.small else [(9, 9.5), (9, 19), (0.2, 23)]
    c.add(c.m(poly(bk)), RED)
    # bundle hanging from the beak tip
    sw = 2.2 if not c.small else 2.8
    c.add(c.m(thick_path([(3.5, 21), (6, 27)], sw)), CLOUD)
    c.add(c.m(ell(7, 34, 6.6, 6.0), poly([(1.8, 31), (12.2, 31), (7, 26)])), SKY)
    c.add(c.m(ell(7, 28, 2.6, 2.0)), CLOUD)
    c.eye(13, 12)


K.render_pal(fn, 'bb-homing-stork', 'Homing Stork', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/bb-homing-stork-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/bb-homing-stork.png')
