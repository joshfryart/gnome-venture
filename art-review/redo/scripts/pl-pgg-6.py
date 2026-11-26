# Quartermaster Gull (pl-pgg-6, whimsy-gull, peg): a plump front-facing pirate gull that IS the piece.
# Square-ish white body core; N peg tab = crown of a black tricorn hat, E peg tab = grey wing tip,
# W peg blank cut into the belly side, S peg tab = a wave of the teal sea from cell 4-5 that the gull bobs on.
import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
from pal_kit import rect, ell, poly, thick_path, knob, UMBER, UMBER2, CREAM

SEA = K.ramp('#38a8c8')
SEA2 = ('#2c8cb8', '#22648a', '#4ac0d0')
FOAM = '#b8f0f0'
GULL = ('#f4f0e4', '#c4c6cc', '#ffffff')
WING = K.ramp('#9aa2b8')
HAT = K.ramp('#3a3a4e')
GOLD = ('#e8a317', '#b07a10', '#f5cf6a')
BEAK = ('#f0a020', '#c06a10', '#f8d060')


def fn(c):
    k = 1.15 if c.small else 1.0
    # head-and-body core with a rounded crown at the back; the beak breaks out of the W side as the gull's cue
    core = poly([(14, 19), (48, 19), (50, 23), (50, 57), (12, 57), (12, 23)])
    tabN = knob('T', 'peg', 31, 12, 0, -1, r=4.6 * k)
    tabE = knob('T', 'peg', 50, 42, 1, 0, r=4.4 * k)
    tabS = knob('T', 'peg', 31, 57, 0, 1, r=4.2 * k)
    blankW = knob('B', 'peg', 12, 45, -1, 0, r=4.0 * k)
    beak = poly([(14, 27), (3, 30), (2, 33), (5, 35), (7, 33.5), (14, 34)])
    hat = poly([(8, 21), (10, 13), (18, 15), (31, 11), (44, 15), (52, 13), (54, 21), (44, 19), (31, 21), (18, 19)])
    crown = ell(31, 13, 11, 6)
    body = c.m(core, minus=(blankW,))
    c.add(body, GULL, stitch=None if c.small else '#d8d4cc')
    c.add(c.m(beak, minus=(core,)) | (c.m(beak) & c.m(rect(0, 0, 15, 64))), BEAK)
    # red spot on the lower bill, like a real herring gull
    c.add(c.m(ell(5.2, 33.2, 1.6 * k, 1.4 * k)), ('#d8322b', '#a8301a', '#e0483a'))
    sea = c.m(rect(12, 50, 50, 57), tabS, minus=(blankW,))
    c.add(sea, SEA)
    c.add(c.m(rect(12, 54, 50, 57), tabS), SEA2)
    # folded grey wing on the back half, its dark primaries are the E tab
    wing = (c.m(poly([(30, 34), (40, 30), (50, 32), (50, 50), (36, 50), (29, 44)])) & body) - sea
    c.add(wing, WING)
    c.edge(wing, WING[1])
    c.add(c.m(tabE, minus=(rect(0, 0, 50.5, 64),)), HAT)
    if not c.small:
        c.line([(36, 38), (46, 36)], WING[1])
        c.line([(35, 43), (47, 42)], WING[1])
    # tricorn
    c.add(c.m(hat, crown, tabN), HAT)
    c.add(c.m(thick_path([(10, 19.5), (18, 17.6), (31, 19.6), (44, 17.6), (52, 19.5)], 1.6 if not c.small else 2.0)), GOLD)
    c.add(c.m(ell(31, 13.5, 2.4 * k, 2.2 * k)), (CREAM, '#c9c5bc', '#ffffff'))
    # face: one felt eye toward the beak, a squinty counting eye behind it
    c.eye(21, 27)
    if not c.small:
        c.line([(29, 27), (32, 27)], UMBER)
        c.blush(24, 32)
    else:
        c.line([(28, 27), (31, 27)], UMBER)
    # big gold doubloon tucked under the chin (the loot it counts twice)
    c.add(c.m(ell(27, 41, 4.6 * k, 4.6 * k), minus=(blankW,)), GOLD)
    c.edge(c.m(ell(27, 41, 4.6 * k, 4.6 * k), minus=(blankW,)), GOLD[1])
    c.px(*c.P(27, 41), GOLD[2])
    y = c.P(0, 50.5)[1]
    for x in range(c.P(12, 0)[0], c.P(50, 0)[0]):
        if (x // 2) % 3 != 2:
            c.px(x, y, FOAM)


rep = K.render_pal(fn, 'pl-pgg-6', 'Quartermaster Gull', '/home/user/gnome-venture/art-review/redo/out',
                   cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-pgg-6-cell.png',
                   oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-pgg-6.png')
print(rep)
