#!/usr/bin/env python3
"""pl-owl-3 "Aurora Thread": a thread spool that is an inner-TBTB piece (tri knobs).
N + S tri tabs = the spool's axle ends poking out of the birch-white flanges; W + E tri blanks cut into the wound thread.
The thread is wound in aurora bands (green into purple) on the owl den's night-indigo core (cell 2-2: #343a74 / #4a4e8a / #26285a);
flanges are the snowy birch trunk lavender-white (#d4d0ec), with a loose thread end trailing over the front."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

BIRCH = K.ramp('#d4d0ec')
AXLE = K.ramp('#6c68a0')
NIGHT = K.ramp('#4a4e8a')
GREEN = K.ramp('#5ac88a')
MINT = K.ramp('#8ae0a8')
VIOLET = K.ramp('#9a7ad8')
PURPLE = K.ramp('#7a52b8')
STAR = '#f8f4fc'


def fn(c):
    k = 1.15 if c.small else 1.0
    top = K.rect(8, 11, 56, 18.5)
    bot = K.rect(8, 45.5, 56, 53)
    wound = K.rect(10.5, 18, 53.5, 46)
    tabN = K.knob('T', 'tri', 32, 11, 0, -1, r=3.6 * k)
    tabS = K.knob('T', 'tri', 32, 53, 0, 1, r=3.6 * k)
    blW = K.knob('B', 'tri', 10.5, 32, -1, 0, r=2.9 * k)
    blE = K.knob('B', 'tri', 53.5, 32, 1, 0, r=2.9 * k)
    blanks = (blW, blE)
    # thread: aurora bands top to bottom
    bands = [(18, 23, MINT), (23, 28, GREEN), (28, 33, GREEN), (33, 38, VIOLET), (38, 46, PURPLE)]
    for y0, y1, rp in bands:
        c.add(c.m(K.rect(10.5, y0, 53.5, y1), minus=blanks), rp)
    c.add(c.m(top, minus=blanks), NIGHT)
    c.add(c.m(bot, minus=blanks), NIGHT)
    c.add(c.m(tabN, minus=(top,)), BIRCH)
    c.add(c.m(tabS, minus=(bot,)), BIRCH)
    # flange rims: a night-indigo inner edge where flange meets thread
    for yy in (18.5, 45):
        y = c.P(0, yy)[1]
        for x in range(c.P(10.5, 0)[0], c.P(53.5, 0)[0]):
            c.px(x, y, NIGHT[1])
    # winding lines (64 px): thin darker threads every 3 units
    for yy in ((21, 24.5, 39.5, 43) if not c.small else (22, 42)):
        y = c.P(0, yy)[1]
        for x in range(c.P(11, 0)[0], c.P(53, 0)[0]):
            if (x // 3) % 2 == 0 or c.small:
                col = GREEN[1] if yy < 33 else PURPLE[1]
                c.px(x, y + (x // 3) % 2 if not c.small else y, col)
    # loose thread end: trails from the right of the winding down over the bottom flange and curls
    tail = K.thick_path([(44, 37), (47, 42), (46, 48), (42, 51), (39, 49)], 2.6 if c.small else 2.2)
    for p in c.m(tail):
        c.px(p[0], p[1], GREEN[0] if not c.small else GREEN[0])
    # stars on the flanges (night sky motif)
    for sx, sy in ((14, 14.5), (44, 14.5), (21, 49.5), (51, 49.5)):
        x, y = c.P(sx, sy)
        c.px(x, y, STAR)
        if not c.small:
            for d in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                c.px(x + d[0], y + d[1], BIRCH[0])
    # face on the calm middle of the winding
    c.eye(26, 30, disc=True)
    c.eye(38, 30, disc=True)
    c.smile(32, 35)
    c.blush(22, 34)
    c.blush(41, 34)


K.render_pal(fn, 'pl-owl-3', 'Aurora Thread', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-owl-3-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-owl-3.png')
