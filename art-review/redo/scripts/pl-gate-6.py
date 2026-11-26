import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, thick_path, knob

R = '/home/user/gnome-venture/'
FUR = K.ramp('#f2ece0')
RED = K.ramp('#c8321e')
PINK = K.ramp('#f4a6c0')
GRASS = K.ramp('#6a9a48')
GOLD = K.GOLD
TAILTIP = K.ramp('#e07a3a')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rect(13, 20, 49, 55)
    earL = poly([(13, 26), (14, 8), (27, 20)])
    earR = poly([(49, 26), (48, 8), (35, 20)])
    tabE = knob('T', 'keyhole', 49, 42, 1, 0, r=5.0 * k)
    blankW = knob('B', 'keyhole', 13, 42, -1, 0, r=4.6 * k)
    body = c.m(core, earL, earR, minus=(blankW,))
    c.add(body, FUR, stitch='#d8ccb8')
    # inner ears in sakura pink
    c.add(c.m(poly([(16.5, 22), (17, 13), (24, 20.5)]), poly([(45.5, 22), (45, 13), (38, 20.5)])), PINK)
    # tail = east keyhole tab, white with a torii-red tip
    tail = c.m(tabE, minus=(core,))
    c.add(tail, FUR)
    c.edge(tail | c.m(rect(47, 38, 50, 46)), '#b8ac98')
    c.add(tail & c.m(rect(55.5, 0, 64, 64)), RED)
    # grass the cat sits on (bottom band, cell green)
    c.add(body & c.m(rect(0, 50, 64, 64)), GRASS)
    # front paws on the grass
    paws = c.m(ell(25, 50, 4.4, 3.4), ell(37.5, 50, 4.4, 3.4))
    c.add(paws, FUR)
    c.edge(paws, '#b8ac98')
    # red collar + gold bell
    c.add(body & c.m(rect(0, 35, 64, 38.5 if not c.small else 39)), RED)
    c.add(c.m(ell(31, 40.5, 2.6 * k, 2.6 * k)), GOLD)
    bx, by = c.P(31, 41.5)
    c.px(bx, by, K.UMBER2)
    # a fallen sakura petal on the head (from the picture's cherry trees)
    px_, py_ = c.P(33, 22)
    for dx, dy in ((0, 0), (1, 0), (0, 1), (1, 1), (2, 0)) if not c.small else ((0, 0), (1, 0)):
        c.px(px_ + dx, py_ + dy, PINK[0])
    c.eye(24.5, 27.5)
    c.eye(37.5, 27.5)
    nx, ny = c.P(31, 30.5)
    c.px(nx, ny, PINK[1])
    if not c.small:
        c.px(nx - 1, ny, PINK[1])
        c.smile(31, 31.5, K.UMBER2)
        for wy in (30, 32):
            c.line([(15, wy - 1), (19, wy)], '#b8ac98')
            c.line([(47, wy - 1), (43, wy)], '#b8ac98')
    c.blush(20, 31)
    c.blush(41, 31)


K.render_pal(fn, 'pl-gate-6', 'Whisker Sentinel', R + 'art-review/redo/out',
             cellfile=R + 'art-review/redo/_src/pl-gate-6-cell.png',
             oldfile=R + 'game/assets/img/puzzles/pals/pl-gate-6.png')
