import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, thick_path, knob, ramp

R = '/home/user/gnome-venture/'
BROWN = ramp('#5a3020')
CREAMW = ramp('#ecd8b0')
RED = ramp('#d8402a')
ORANGE = ramp('#e8782a')
BLUE = ramp('#4a90d8')
GOLD = ramp('#f0a830')
STONE = ramp('#c8a878')
SLATE = ramp('#4a4a5a')


def fn(c):
    k = 1.15 if c.small else 1.0
    # wings: forewings with rounded tips rising at the top corners, hindwings as round lobes
    foreL = poly([(31, 16), (16, 8), (11, 10), (11, 33), (31, 33)])
    foreR = poly([(64 - x, y) for x, y in [(31, 16), (16, 8), (11, 10), (11, 33), (31, 33)]])
    tipL, tipR = ell(14.5, 11.5, 4.5, 4.2), ell(49.5, 11.5, 4.5, 4.2)
    hindL = poly([(31, 32), (11, 32), (11, 47), (16, 55), (25, 57), (32, 57)])
    hindR = poly([(64 - x, y) for x, y in [(31, 32), (11, 32), (11, 47), (16, 55), (25, 57), (32, 57)]])
    tabW = knob('T', 'hook', 11, 22, -1, 0, r=5.0 * k, nw=3.0)
    blankE = knob('B', 'hook', 53, 42, 1, 0, r=3.8 * k)
    blankS = knob('B', 'hook', 32, 55, 0, 1, r=3.8 * k, flip=True)
    antL = knob('T', 'hook', 25.5, 12.5, -0.45, -0.89, r=3.6 * k, nw=1.5, flip=True)
    antR = knob('T', 'hook', 38.5, 12.5, 0.45, -0.89, r=3.6 * k, nw=1.5)
    blanks = (blankE, blankS)
    fore = c.m(foreL, foreR, tipL, tipR, tabW, minus=blanks + (poly([(0, 33), (64, 33), (64, 64), (0, 64)]),))
    hind = c.m(hindL, hindR, minus=blanks)
    c.add(fore, BROWN)
    # cream tiger stripes on the forewings (diagonal bands)
    st = c.m(lambda x, y: ((x - 32) if x > 32 else (32 - x)) * 0.8 + y * 1.0 > 0 and
             int((abs(x - 32) * 0.55 + y) / 5.5) % 3 == 1 and y < 32 and abs(x - 32) > 6)
    c.add(fore & st, CREAMW)
    c.add(hind, RED)
    c.add(hind & c.m(lambda x, y: y < 38), ORANGE)
    c.edge(hind, RED[1])
    # eyespot lockets: gold rim, blue spot (left big locket, right smaller)
    c.add(c.m(ell(21, 45, 5.5, 5.5)), GOLD)
    c.add(c.m(ell(21, 45, 3.5, 3.5)), BLUE)
    c.add(c.m(ell(42.5, 48, 3.6, 3.6)) - c.m(blankE), GOLD)
    c.add(c.m(ell(42.5, 48, 2.0, 2.0)) - c.m(blankE), BLUE)
    if not c.small:
        c.px(*c.P(19.5, 43.5), '#d8ecff')
        c.px(*c.P(20.5, 43.5), '#d8ecff')
    else:
        c.px(*c.P(20, 44), '#d8ecff')
    # antennae (hook tabs) in slate
    c.add(c.m(antL, antR, minus=(rect(0, 12, 64, 64),)) | (c.m(antL, antR) & c.m(rect(0, 10, 64, 14))), SLATE)
    # body: stone tan head + fuzzy thorax + striped abdomen
    c.add(c.m(ell(32, 32, 4.6, 16), minus=blanks), STONE)
    c.add(c.m(ell(32, 18, 6.5, 6)), STONE)
    for yy in (37, 41, 45):
        c.line([(29, yy), (35, yy)], STONE[1])
    c.eye(29.5, 18)
    c.eye(35, 18)
    if not c.small:
        c.smile(32, 21.5)
    c.blush(27.5, 21)
    c.blush(37, 21)


K.render_pal(fn, 'pl-tgm-6', 'Tiger Moth Locket', R + 'art-review/redo/out',
             cellfile=R + 'art-review/redo/_src/pl-tgm-6-cell.png', oldfile=R + 'game/assets/img/puzzles/pals/pl-tgm-6.png')
