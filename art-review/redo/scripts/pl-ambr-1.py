"""pl-ambr-1 Sapdrop Bead: corner-BB, keyhole. A glossy amber sap bead whose pointed tip is the piece's flat top-left corner
(flat top + flat left), swelling round at the lower right; keyhole blanks on the right and bottom sides. A dark plum birch-trunk
strip runs down the flat left side (cell 8-2: the dark trunk) with a golden leaf tuft at the top; colours are the cell's honey/orange."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, knob, ramp, thick_path

AMBER = ramp('#f4a43c')
HONEY = ramp('#ffd060')
DEEP = ramp('#d8843a')
BARK = ramp('#54303a')
LEAF = ramp('#f8b547')


def fn(c):
    k = 1.15 if c.small else 1.0
    R = 22
    drop = ell(56 - R, 56 - R, R, R)
    tip = (rect(8, 8, 56, 56 - R), rect(8, 8, 56 - R, 56))
    trunk_r = rect(8, 8, 15, 56)
    bR = knob('B', 'keyhole', 56, 23, 1, 0, r=3.9 * k)
    bB = knob('B', 'keyhole', 23, 56, 0, 1, r=3.9 * k)
    body = c.m(drop, *tip, trunk_r, minus=(bR, bB))
    bead = c.m(drop, *tip, minus=(bR, bB, trunk_r))
    c.add(bead, DEEP)
    c.add(c.m(ell(34, 34, 18.5, 18.5), poly([(15, 9.5), (38, 16), (17, 38)]), minus=(bR, bB, trunk_r)) & bead, AMBER)
    c.add(c.m(ell(34, 34, 11, 11), poly([(20, 16), (36, 23.5), (26, 33)]), minus=(bR, bB)), HONEY)
    trunk = c.m(trunk_r)
    c.add(trunk, BARK)
    c.edge(trunk, BARK[1])
    # bark notches
    for yy in (20, 33, 47):
        x0, y0 = c.P(10, yy)
        c.px(x0, y0, BARK[2]); c.px(x0 + 1, y0, BARK[2])
        if not c.small:
            c.px(x0 + 2, y0, BARK[2]); c.px(x0 + 3, y0 + 1, BARK[2])
    # gloss: a crescent highlight on the upper left of the bead + a spark
    if c.small:
        for (x, y) in ((24, 26), (23, 30), (23, 34)):
            X, Y = c.P(x, y); c.px(X, Y, '#fff4cc'); c.px(X, Y + 1, '#fff4cc')
        X, Y = c.P(29, 18); c.px(X, Y, '#fff4cc')
    else:
        c.line([(25, 22), (22.5, 27), (21.5, 33), (22, 38)], '#fff4cc')
        c.line([(26, 22), (23.5, 27), (22.5, 33)], '#fff4cc')
        X, Y = c.P(30, 17); c.px(X, Y, '#fff4cc'); c.px(X + 1, Y, '#fff4cc'); c.px(X, Y + 1, '#fff4cc')
    c.eye(31, 36)
    c.eye(41, 36)
    c.smile(36, 41)
    c.blush(27, 41)
    c.blush(45, 41)


K.render_pal(fn, 'pl-ambr-1', 'Sapdrop Bead', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-ambr-1-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-ambr-1.png')
