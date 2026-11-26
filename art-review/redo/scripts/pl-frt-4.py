#!/usr/bin/env python3
"""pl-frt-4 "Frostwart Bumps": inner-TTTT, double. A frost toad, face on, that IS the piece.
N double tab = the toad's two bulging eye-bumps, E/W double tabs = splayed two-toed hands, S double tab = two feet in snow.
Green mound ramps + snow white from cell 10-6 (green barrow over snow); frosty warts on the back."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

ROOT = '/home/user/gnome-venture'
LEAF = K.ramp('#5fa860')      # mound mid green
MOSS = K.ramp('#397a62')      # teal-green shadow of the mound
SNOW = ('#ecf6f8', '#b8d4dc', '#ffffff')
ICE = ('#d8ecf0', '#9cc0cc', '#f6fbfc')
WART = '#d8ecf0'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(14, 18, 50, 50)
    tabN = K.knob('T', 'double', 32, 18, 0, -1, r=5.4 * k)
    tabW = K.knob('T', 'double', 14, 36, -1, 0, r=4.4 * k)
    tabE = K.knob('T', 'double', 50, 36, 1, 0, r=4.4 * k)
    tabS = K.knob('T', 'double', 32, 50, 0, 1, r=4.6 * k)
    body = c.m(core, tabN, tabW, tabE, tabS)
    c.add(body, LEAF, stitch=None if c.small else LEAF[2])
    # lower back in the deep teal-green of the mound
    c.add(body & c.m(K.rect(0, 38, 64, 64)), MOSS)
    # pale frosty belly + snowy feet (the snow band under the barrow)
    belly = c.m(K.ell(32, 41, 10, 5.5)) & body
    c.add(belly, SNOW)
    c.edge(belly, SNOW[1])
    # feet: the S tab in deep green, toes dipped in snow
    c.add(c.m(tabS, minus=(core,)), MOSS)
    c.add(c.m(tabS) & c.m(K.rect(0, 56.5, 64, 64)), ICE)
    c.line([(32, 52.5), (32, 62)], MOSS[1])   # split the two feet
    # hands: green arms with snowy fingertips
    c.add(c.m(tabW, minus=(core,)), LEAF)
    c.add(c.m(tabE, minus=(core,)), LEAF)
    c.add(c.m(tabW) & c.m(K.rect(0, 0, 7.5, 64)), ICE)
    c.add(c.m(tabE) & c.m(K.rect(56.5, 0, 64, 64)), ICE)
    # eyes in the two bumps of the N tab
    kk = 5.4 * k * 0.56
    ey = 18 - (5.4 * k + 1.6 - 0.3)
    c.eye(32 - kk, ey + 0.8, disc=True)
    c.eye(32 + kk, ey + 0.8, disc=True, look=(1, 0) if not c.small else (0, 0))
    # wide toad mouth
    if not c.small:
        c.line([(19, 30), (23, 32), (41, 32), (45, 30)], K.UMBER)
    else:
        c.line([(19, 30), (23, 32.5), (41, 32.5), (45, 30)], K.UMBER)
    c.blush(23, 27.5)
    c.blush(40, 27.5)
    # four frosty warts (snow-capped bumps)
    warts = [(20, 21.5), (44, 21.5), (24, 41), (40, 41)] if not c.small else [(20, 22), (44, 22), (22.5, 41), (41, 41)]
    warts = [(19.5, 22), (44.5, 22), (19, 45), (45, 45)]
    for wx, wy in warts:
        w = c.m(K.ell(wx, wy, 3.4 * k, 3.0 * k))
        c.add(w, ICE)
        c.edge(w, SNOW[1])
        x, y = c.P(wx - 1, wy - 1)
        c.px(x, y, '#ffffff')


if __name__ == '__main__':
    rep = K.render_pal(fn, 'pl-frt-4', 'Frostwart Bumps', ROOT + '/art-review/redo/out',
                       cellfile=ROOT + '/art-review/redo/_src/pl-frt-4-cell.png',
                       oldfile=ROOT + '/game/assets/img/puzzles/pals/pl-frt-4.png')
    print(rep)
