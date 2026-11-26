"""pl-silk-2 Doorlamp Dozer: edge-TTB keyhole. A golden caravan lantern that IS an edge piece: flat S = lantern base,
keyhole tab N = brass finial ring, keyhole tab E = wall bracket, keyhole blank W bites the frame. Teal dome roof (the picture's domes),
the cell's arched dark window with its orange glow as the glass pane, sleepy closed eyes in the glow. Sandstone brick base (cell 1-5)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, knob, thick_path, UMBER, UMBER2, CREAM

GOLD = K.ramp('#e0a830')
BRASS = K.ramp('#c88a28')
TEAL = K.ramp('#2a8a84')
NIGHT = ('#3a2238', '#2e1a2e', '#4e3048')
GLOW = K.ramp('#f0a048')
BRICK = K.ramp('#dcb27c')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = c_core = lambda x, y: rect(13, 24, 51, 57)(x, y) or ell(32, 25, 19, 11)(x, y) and 13 <= x < 51
    tabN = knob('T', 'keyhole', 32, 14.5, 0, -1, r=4.2 * k)
    tabE = knob('T', 'keyhole', 51, 38, 1, 0, r=4.2 * k)
    blankW = knob('B', 'keyhole', 13, 39, -1, 0, r=4.4 * k)
    body = c.m(core, tabN, tabE, minus=(blankW,))
    c.add(body, GOLD, stitch=None)
    # finial ring + bracket (brass)
    c.add(c.m(tabN, minus=(ell(32, 25, 19, 11),)), BRASS)
    c.add(c.m(tabE, minus=(rect(0, 0, 51.5, 64),)), BRASS)
    # teal dome roof band
    roof = c.m(ell(32, 25, 19, 11), rect(13, 24, 51, 26), minus=(blankW, tabN)) & c.m(rect(0, 0, 64, 26))
    c.add(roof, TEAL)
    if not c.small:
        for gx in (22, 27, 37, 42):
            x, _ = c.P(gx, 0)
            for y in range(c.P(0, 19 + abs(gx - 32) * 0.25)[1], c.P(0, 25)[1]):
                c.px(x, y, TEAL[1])
    # gold trim under the roof
    c.add(c.m(rect(13, 25.5, 51, 28), minus=(blankW,)), BRASS)
    # arched pane: dark top, orange glow bottom (the cell's window)
    pane = c.m(rect(23, 35, 45, 50), ell(34, 35, 11, 6))
    c.add(pane, NIGHT)
    glow = c.m(rect(23, 41, 45, 50))
    c.add(glow, GLOW)
    c.edge(pane, UMBER2)
    # sandstone brick base (flat side)
    base = c.m(rect(13, 51, 51, 57), minus=(blankW,))
    c.add(base, BRICK)
    if not c.small:
        y = c.P(0, 54)[1]
        for x in range(c.P(13, 0)[0], c.P(51, 0)[0]):
            c.px(x, y, BRICK[1])
        for bx in (22, 32, 42):
            x, _ = c.P(bx, 0)
            for yy in range(c.P(0, 51.5)[1], c.P(0, 54)[1]):
                c.px(x, yy, BRICK[1])
        for bx in (17, 27, 37, 47):
            x, _ = c.P(bx, 0)
            for yy in range(c.P(0, 54.5)[1], c.P(0, 57)[1]):
                c.px(x, yy, BRICK[1])
    # sleepy closed eyes + tiny mouth in the glow
    for ex in (30, 38):
        cx, cy = c.P(ex, 43.5)
        if not c.small:
            c.px(cx - 1, cy - 1, UMBER); c.px(cx, cy, UMBER); c.px(cx + 1, cy, UMBER); c.px(cx + 2, cy - 1, UMBER)
        else:
            c.px(cx - 1, cy, UMBER); c.px(cx, cy, UMBER)
    mx, my = c.P(34, 47)
    c.px(mx, my, UMBER2)
    if not c.small:
        c.px(mx - 1, my, UMBER2)
        c.blush(27.5, 46)
        c.blush(40, 46)
    # little flame dozing low on the wick, in the dark arch
    fl = c.m(ell(34, 37.5, 2.8, 3.6), poly([(31.6, 37), (36.4, 37), (34, 31)]))
    c.add(fl, K.ramp('#f8c048'))
    c.add(c.m(ell(34, 38.5, 1.3, 1.8)), K.ramp('#fff0b0'))
    # glass bars of the lantern either side of the arch
    for bx in (47.5,):
        c.add(c.m(rect(bx - 1.6, 30, bx + 1.6, 50)) & body, BRASS)


if __name__ == '__main__':
    print(K.render_pal(fn, 'pl-silk-2', 'Doorlamp Dozer', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-silk-2-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-silk-2.png'))
