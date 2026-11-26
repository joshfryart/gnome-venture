"""pl-wlig-1 Brass Bonnet: corner-TT keyhole. A lighthouse lamp room: brass dome cap (squat dome shoulders), keyhole tab N = gold finial ball,
keyhole tab E = the lamp's glow spilling out. Flat W and S (the red-and-white tower top). Glass panes show the cell's purple night sky + cream stars."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

GOLDR = K.ramp('#e0a020')
BRASS = K.ramp('#b8781c')
GLOW = ('#f8d870', '#e0a040', '#fff2c0')
NIGHT = K.ramp('#5a3a8e')
RED = K.ramp('#c8343c')
WHITE = K.ramp('#f2e4d0')
STAR = '#fff0c0'


def fn(c):
    k = 1.15 if c.small else 1.0
    dome = K.ell(32, 29, 23.5, 16)
    core = K.rect(9, 29, 55, 59)
    tabN = K.knob('T', 'keyhole', 32, 13.4, 0, -1, r=5.4 * k, nw=2.0)
    tabE = K.knob('T', 'keyhole', 55, 40, 1, 0, r=5.2 * k)
    body = c.m(dome, core)
    c.add(body, NIGHT)
    # brass cap
    cap = c.m(dome, minus=(K.rect(0, 28, 64, 64),))
    c.add(cap, GOLDR, stitch=None if c.small else '#f5cf6a')
    c.add(c.m(tabN, minus=(dome,)), GOLDR)
    # gallery rim
    c.add(c.m(K.rect(9, 27, 55, 31)), BRASS)
    # glass: centre glowing pane, side panes = night sky
    c.add(c.m(K.rect(21, 31, 43, 49)), GLOW)
    c.add(c.m(tabE, minus=(core,)), GLOW)
    # mullions
    for x0 in (19.5, 43):
        c.add(c.m(K.rect(x0, 31, x0 + 1.6 if not c.small else x0 + 2, 49)), BRASS)
    # tower top: red band with white stripe
    c.add(c.m(K.rect(9, 49, 55, 59)), RED)
    c.add(c.m(K.rect(9, 52.5, 55, 55.5)), WHITE)
    c.add(c.m(K.rect(9, 48, 55, 50.5)), BRASS)
    # stars in the side panes (cell motif)
    for sx, sy in ((13, 35), (16, 44), (48, 38), (51, 45)) if not c.small else ((14, 36), (49, 43)):
        c.px(*c.P(sx, sy), STAR)
    # glow from glass into east tab: connect (paint the core edge under the tab)
    c.add(c.m(tabE) & c.m(K.rect(44.6, 0, 64, 64)) & c.m(K.rect(0, 31, 64, 49)), GLOW)
    # bright core of the spilled glow
    gx, gy = c.P(61, 40)
    for dx, dy in ((0, 0), (-1, 0), (0, -1)) if not c.small else ((0, 0),):
        c.px(gx + dx, gy + dy, '#fff8e0')
    # rivets on the cap
    if not c.small:
        for rx in (16, 24, 32, 40, 48):
            c.px(*c.P(rx, 25.5), '#f5cf6a')
    c.eye(27, 38)
    c.eye(37, 38)
    c.smile(32, 43.5)
    c.blush(23.5, 42.5)
    c.blush(40, 42.5)


if __name__ == '__main__':
    print(K.render_pal(fn, 'pl-wlig-1', 'Brass Bonnet', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wlig-1-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wlig-1.png'))
