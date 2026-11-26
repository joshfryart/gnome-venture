# Scarab Glint: a top-down teal scarab that is an edge piece. Flat S (shell rests on a sandstone plinth from cell 3-5),
# peg tab N = the beetle's head, peg blanks W and E cut between the leg pairs. Teal shell, gold seam and lines, mauve slots.
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, thick_path, knob

SHELL = K.ramp('#2daea2')
PRO = K.ramp('#1d7a8a')
HEAD = K.ramp('#24425c')
LEG = K.ramp('#2c3a52')
GOLDL = '#f7d173'
GOLDD = '#c89a3a'
SAND = K.ramp('#eab380')
SLOT = '#5a3448'


def fn(c):
    k = 1.15 if c.small else 1.0
    # body: rounded pronotum dome on top, straight-sided elytra, flat plinth floor (the edge side)
    core = lambda x, y: (13 <= x < 51 and 27 <= y < 57) or ell(32, 28, 19.5, 10.5)(x, y)
    tabN = knob('T', 'peg', 32, 17.6, 0, -1, r=6.4 * k, nw=4.0)
    blW = knob('B', 'peg', 13, 32, -1, 0, r=3.8 * k)
    blE = knob('B', 'peg', 51, 32, 1, 0, r=3.8 * k)
    lw = 3.2 if not c.small else 3.9
    legs = []
    for sd in (-1, 1):
        X = lambda v: 32 + sd * v
        legs += [thick_path([(X(16), 23), (X(23), 20), (X(25), 14)], lw),
                 thick_path([(X(17), 42), (X(24), 41), (X(27), 45)], lw),
                 thick_path([(X(17), 50), (X(23), 53), (X(25), 59)], lw)]
    c.add(c.m(*legs, minus=(core,)), LEG)
    body = c.m(core, minus=(blW, blE))
    c.add(c.m(tabN, minus=(core,)) | (c.m(tabN) & c.m(rect(0, 16, 64, 19))), HEAD)
    pron = body & c.m(rect(0, 0, 64, 32))
    elytra = body & c.m(rect(0, 32, 64, 51))
    plinth = body & c.m(rect(0, 51, 64, 60))
    c.add(pron, PRO)
    c.add(elytra, SHELL)
    c.add(plinth, SAND)
    c.edge(elytra, GOLDD)
    # head: gold clypeus prongs (the scarab's toothed head)
    if not c.small:
        for x in (27.5, 32, 36.5):
            c.px(*c.P(x, 8), GOLDL)
    else:
        c.px(*c.P(28.5, 7), GOLDL); c.px(*c.P(35, 7), GOLDL)
    # gold seam and dotted lines on the wing cases
    sx = c.P(32, 0)[0]
    for yy in range(c.P(0, 32)[1], c.P(0, 51)[1]):
        c.px(sx - 1, yy, GOLDL)
        if not c.small:
            c.px(sx, yy, GOLDD)
    rows = (37, 42, 47) if not c.small else (39, 46)
    for side in (-1, 1):
        for row in rows:
            yy = c.P(0, row)[1]
            for x in range(sx + side * 4, sx + side * 16, side * 2):
                xx = x - (1 if side < 0 else 0)
                if (xx, yy) in elytra and (xx + side, yy) in elytra:
                    c.px(xx, yy, GOLDL)
    # sandstone plinth slots (the obelisk windows in cell 3-5)
    for gx in (20, 32, 44):
        x0, y0 = c.P(gx - 2, 53)
        x1, y1 = c.P(gx + 2, 56)
        for x in range(x0, max(x1, x0 + 2)):
            for yy in range(y0, max(y1, y0 + 1)):
                c.px(x, yy, SLOT)
    # face on the pronotum
    c.eye(26, 25, disc=True)
    c.eye(38, 25, disc=True)
    if not c.small:
        c.smile(32, 28)


if __name__ == '__main__':
    G = '/home/user/gnome-venture/'
    print(K.render_pal(fn, 'pl-scr-2', 'Scarab Glint', G + 'art-review/redo/out',
                       cellfile=G + 'art-review/redo/_src/pl-scr-2-cell.png', oldfile=G + 'game/assets/img/puzzles/pals/pl-scr-2.png'))
