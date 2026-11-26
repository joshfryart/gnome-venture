#!/usr/bin/env python3
"""pl-gwk-4 "Crown Points": inner-TTTT, tri knobs.
A little living crown of the grey wolf king: the square piece body is a gold crown band with a white snow-ermine trim and a
slate-blue velvet cap below. N tri tab = the tall centre crown point (moon-pearl tip), E + W tri tabs = the side crown points,
S tri tab = a slate wolf-spine point like the jagged spines in cell 6-2. Colours: crown gold, the cell's slate/periwinkle blues,
moon cream, wolf-eye yellow and the wolf's red tongue for jewels."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, knob

GOLD = ('#e8a317', '#b07a10', '#f5cf6a')
SLATE = K.ramp('#4c5894')
PERI = K.ramp('#8c9ad0')
ERM = ('#eef0f8', '#b8c0dc', '#ffffff')
MOON = K.ramp('#f4ecc8')
RUBY = '#d0384a'
SAPH = '#2c3670'
EYEY = '#f0d020'


def fn(c):
    S = 1.15 if c.small else 1.0
    core = rect(13, 17, 51, 51)
    tabN = knob('T', 'tri', 32, 17, 0, -1, r=6.0 * S)
    tabE = knob('T', 'tri', 51, 27, 1, 0, r=5.2 * S)
    tabW = knob('T', 'tri', 13, 27, -1, 0, r=5.2 * S)
    tabS = knob('T', 'tri', 32, 51, 0, 1, r=4.8 * S)
    # small rounded corner points finishing the crown rim
    cornL = poly([(13, 18), (13, 11.5), (19, 18)])
    cornR = poly([(51, 18), (51, 11.5), (45, 18)])
    # velvet cap (lower) + S spine point
    c.add(c.m(core, tabS), SLATE)
    # gold crown band + N/E/W points
    gold = c.m(rect(13, 17, 51, 37), tabN, tabE, tabW, cornL, cornR)
    c.add(gold, GOLD, stitch=None if c.small else '#f5cf6a')
    # snow-ermine trim between gold and velvet
    erm = c.m(rect(13, 37, 51, 42.5))
    c.add(erm, ERM)
    c.edge(erm, ERM[1])
    for ex in (17, 25, 39, 47):
        x, y = c.P(ex, 39.2)
        c.px(x, y, SAPH)
        if not c.small:
            c.px(x, y + 1, SAPH)
    # periwinkle velvet folds on the cap (the cell's light blue streaks)
    c.add(c.m(poly([(13, 46), (22, 42.5), (30, 42.5), (13, 51)]), poly([(38, 51), (51, 44.5), (51, 48), (44, 51)])), PERI)
    # moon pearl on the N point, jewels on side points
    c.add(c.m(ell(32, 7.5 if not c.small else 7.2, 2.6 * S, 2.6 * S)), MOON)
    for jx in (6.5, 57.5):
        x, y = c.P(jx, 27)
        c.px(x, y, RUBY)
        if not c.small:
            c.px(x, y - 1, RUBY)
    # jewels on the band: sapphire left, ruby right
    for (jx, col) in ((18.5, SAPH), (45.5, RUBY)):
        x, y = c.P(jx, 27)
        for dx, dy in ((0, 0), (1, 0), (0, 1), (1, 1)) if c.small else ((0, -1), (-1, 0), (0, 0), (1, 0), (0, 1), (1, 1), (-1, 1), (0, 2)):
            c.px(x + dx, y + dy, col)
    # band engraving lines
    if not c.small:
        c.line([(14, 21), (50, 21)], GOLD[1])
        c.line([(14, 34.5), (50, 34.5)], GOLD[1])
    # face on the gold band
    c.eye(27, 28)
    c.eye(37, 28)
    c.smile(32, 31.5)
    c.blush(23.5, 31)
    c.blush(40, 31)


if __name__ == '__main__':
    rep = K.render_pal(fn, 'pl-gwk-4', 'Crown Points', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-gwk-4-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-gwk-4.png')
    print(rep)
