import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
import math
# Pennant Wave: a red/cream awning-striped pennant on a wooden pole. Edge-BTB peg: flat hoist side on the pole,
# peg blanks bite the tapering top and bottom edges, the peg tab is the fluttering fly tip. Colours from cell 4-3 (awning stripe).
RED = K.ramp('#e8524a')
CRM = K.ramp('#f6e6c4')
POLE = K.ramp('#8a5a32')
GOLDR = K.ramp('#f0b430')

def fn(c):
    k = 1.15 if c.small else 1.0
    x0, x1 = 12, 50
    top = lambda x: 7 + (x - x0) * 0.17 + 1.6 * math.sin((x - x0) / 38 * math.pi * 2)
    bot = lambda x: 58 - (x - x0) * 0.17 + 1.6 * math.sin((x - x0) / 38 * math.pi * 2)
    core = lambda x, y: x0 <= x < x1 and top(x) <= y < bot(x)
    n = (0.17, -0.985)
    blankN = K.knob('B', 'peg', 31, top(31), n[0], n[1], r=3.3 * k, nw=2.2)
    blankS = K.knob('B', 'peg', 31, bot(31), n[0], -n[1], r=3.3 * k, nw=2.2)
    tabE = K.knob('T', 'peg', x1, 32, 1, 0, r=4.6 * k)
    flag = c.m(core, tabE, minus=(blankN, blankS))
    # pole + finial
    c.add(c.m(K.rect(6, 6, 12.5, 63)), POLE)
    c.add(c.m(K.ell(9.2, 4.6, 4.2, 4.2)), GOLDR)
    # stripes: vertical awning stripes, 7.6 units wide
    sw = 7.6
    reds = c.m(lambda x, y: int((x - x0) // sw) % 2 == 0) & flag
    crms = flag - reds
    c.add(crms, CRM)
    c.add(reds, RED)
    c.add(c.m(tabE, minus=(core,)) | (c.m(tabE) & c.m(K.rect(x1 - 2, 0, x1, 64))), RED)
    c.edge(flag, RED[1])
    # gold cord ties to the pole
    for ty in (13, 51):
        c.add(c.m(K.rect(5.5, ty - 1.4, 14, ty + 1.4)), GOLDR)
    # face on the middle
    c.eye(25, 29, disc=True)
    c.eye(37, 30.5, disc=True)
    c.smile(31, 36.5, K.UMBER)
    c.blush(21.5, 35)
    c.blush(40.5, 36.5)

K.render_pal(fn, 'pl-chil-2', 'Pennant Wave', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-chil-2-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-chil-2.png')
