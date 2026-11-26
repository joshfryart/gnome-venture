"""pl-cwy-6 "Last Forge Flame" (rare, whimsy-flame, tri).
Concept: a sleepy little forge flame that IS a jigsaw piece: square-ish lower core with a flame top whose tip curls over;
tri tab W (a flame lick), tri tab S (a stone point under the ember-rock hearth), tri blank E cut into the flame body.
Colours: the forge mouth's red / orange / amber / pale-yellow fire, and the mauve-brown cave-rock of cell 9-4 as the hearth stone."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, knob, thick_path, ramp, UMBER

RED = ramp('#c8402c')
ORA = ramp('#f26a2c')
AMB = ramp('#ffb43c')
YEL = ('#ffe66a', '#f0c050', '#fff4b8')
ROCK = ramp('#844c48')
ROCKD = '#5a3448'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rect(14, 26, 50, 52)
    top = poly([(14, 30), (16, 20), (22, 12), (28, 6), (34, 3), (40, 4), (43, 8), (42, 12), (38, 13), (35, 11), (37, 16), (44, 20), (48, 25), (50, 30)])
    tabW = knob('T', 'tri', 14, 36, -1, 0, r=5.6 * k, nw=3.6)
    tabS = knob('T', 'tri', 32, 52, 0, 1, r=5.4 * k, nw=3.6)
    blankE = knob('B', 'tri', 50, 34, 1, 0, r=5.0 * k, nw=3.4)
    body = c.m(core, top, tabW, minus=(blankE,))
    c.add(body, RED, stitch=None if c.small else '#f08a4a')
    # inner flame layers (teardrops)
    c.add(body & c.m(poly([(18, 44), (19, 30), (25, 20), (31, 13), (33, 18), (40, 22), (45, 29), (45, 44)]), minus=(blankE,)), ORA)
    c.add(body & c.m(poly([(22, 44), (23, 33), (28, 26), (32, 21), (35, 26), (40, 30), (41, 44)]), minus=(blankE,)), AMB)
    c.add(body & c.m(ell(32, 39, 7.5, 7)), YEL)
    # hearth stone base (cave-rock of the cell) + S tab
    rock = c.m(rect(14, 44, 50, 52), tabS, minus=(blankE,))
    c.add(rock, ROCK)
    c.edge(rock, ROCKD)
    # rock speckles
    for (x, y) in ((19, 48), (27, 49.5), (40, 48), (46, 49), (32, 55)):
        X, Y = c.P(x, y)
        c.px(X, Y, ROCKD)
    # ember glow on the rock top
    for (x, y) in ((23, 45), (36, 45.5), (43, 45)):
        X, Y = c.P(x, y)
        c.px(X, Y, '#ff8a3c')
    # sleepy closed eyes (curved lashes) + small smile
    for ex in (27, 37):
        X, Y = c.P(ex, 37)
        if c.small:
            c.px(X - 1, Y, UMBER); c.px(X, Y + 1, UMBER); c.px(X + 1, Y + 1, UMBER); c.px(X + 2, Y, UMBER)
        else:
            c.px(X - 2, Y, UMBER); c.px(X - 1, Y + 1, UMBER); c.px(X, Y + 1, UMBER); c.px(X + 1, Y + 1, UMBER); c.px(X + 2, Y, UMBER)
    c.blush(23, 40)
    c.blush(40, 40)
    X, Y = c.P(32, 41)
    c.px(X, Y, UMBER)
    if not c.small:
        c.px(X - 1, Y, UMBER); c.px(X + 1, Y, UMBER)
    # dreaming "z" spark near the curled tip
    if not c.small:
        X, Y = c.P(44, 9)
        for d in range(3):
            c.px(X + d, Y, YEL[2])
        c.px(X + 1, Y + 1, YEL[2])
        for d in range(3):
            c.px(X + d, Y + 2, YEL[2])


if __name__ == '__main__':
    R = '/home/user/gnome-venture/'
    print(K.render_pal(fn, 'pl-cwy-6', 'Last Forge Flame', R + 'art-review/redo/out',
                       cellfile=R + 'art-review/redo/_src/pl-cwy-6-cell.png',
                       oldfile=R + 'game/assets/img/puzzles/pals/pl-cwy-6.png'))
