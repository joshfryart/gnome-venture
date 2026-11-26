#!/usr/bin/env python3
"""pl-gwk-2 Pawprint Cuff: edge-TTB double. A snowy wolf paw that IS the piece: N double tab = two middle toes (lilac beans),
E double tab = the dewclaw, W double blank, flat S = a night-purple fur cuff with star flecks. Snow white + drift lilac + night sky (cell 5-7)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

SNOW = K.ramp('#d8dcf2')
PAD = K.ramp('#8088c8')
NIGHT = K.ramp('#3a2a4a')
STAR = '#f4f0ff'


def fn(c):
    k = 1.25 if c.small else 1.0
    core = K.poly([(10, 24), (14, 18), (50, 18), (54, 24), (54, 58), (10, 58)])
    tabN = K.knob('T', 'double', 32, 18, 0, -1, r=6.2 * k)
    tabE = K.knob('T', 'double', 54, 36, 1, 0, r=4.6 * k)
    blankW = K.knob('B', 'double', 10, 37, -1, 0, r=4.6 * k)
    body = c.m(core, tabN, tabE, minus=(blankW,))
    c.add(body, SNOW, stitch=None)
    # cuff
    cuff = body & c.m(K.rect(0, 47, 64, 64))
    c.add(cuff, NIGHT)
    for (sx, sy) in ((16, 51), (27, 54), (38, 50), (48, 54)):
        x, y = c.P(sx, sy)
        c.px(x, y, STAR)
        if not c.small:
            c.px(x + 1, y, STAR)
            c.px(x, y + 1, STAR)
    # fluffy scallop edge on top of the cuff
    sc = c.m(lambda x, y: 45 <= y < 48 and ((x - 10) % 8 - 4) ** 2 + (y - 47.5) ** 2 < 9 and 10 <= x < 54)
    c.add(sc & body, NIGHT)
    # toe beans: two in the N tab, two at upper corners, one in dewclaw
    for (bx, by, rx, ry) in ((27.4, 10.8, 3.6, 3.9), (36.6, 10.8, 3.6, 3.9), (18.5, 23, 4.0, 4.2), (45.5, 23, 4.0, 4.2)):
        c.add(c.m(K.ell(bx, by, rx * (1.1 if c.small else 1), ry * (1.1 if c.small else 1))), PAD)
    c.add(c.m(K.ell(59.5, 36, 2.4, 3.6)) & body, PAD)
    # main palm pad (with the face)
    pad = c.m(K.ell(32, 35, 10.5, 7.5), K.ell(24.5, 40.5, 4.8, 4), K.ell(32, 41.5, 5, 3.8), K.ell(39.5, 40.5, 4.8, 4))
    c.add(pad, PAD)
    c.eye(27.5, 36)
    c.eye(36.5, 36)
    c.smile(32, 39.5, K.UMBER2)


if __name__ == '__main__':
    rep = K.render_pal(fn, 'pl-gwk-2', 'Pawprint Cuff', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-gwk-2-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-gwk-2.png')
    print(rep)
