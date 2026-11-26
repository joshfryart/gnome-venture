#!/usr/bin/env python3
"""pl-mirr-3 "Saltcrack Smile" (inner-TBTB, keyhole).
Concept: a chunk of mirror-salt-flat crust: a white salt slab whose top face is the classic polygon crack pattern (pink-lilac ridges, cracks
curling up into little smiles), its front edge a lilac reflection layer. Tabs N (a salt lump) and S (the lilac reflection dripping down),
blanks W and E cut into the crust. Colours: cell 7-7 pink sky #c389c0 over lilac mirror #a786c6, salt white #f4f0fa / #e0ddff."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

SALT = ('#f6f2fb', '#d6d0f0', '#ffffff')
PINK = K.ramp('#c389c0')
LILAC = K.ramp('#a786c6')
CRACK = '#c389c0'
CRACK2 = '#9a6aa8'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(11, 15, 53, 51)
    tabN = K.knob('T', 'keyhole', 32, 15, 0, -1, r=4.2 * k)
    tabS = K.knob('T', 'keyhole', 32, 51, 0, 1, r=4.2 * k)
    blW = K.knob('B', 'keyhole', 11, 33, -1, 0, r=3.4 * k, nw=2.1)
    blE = K.knob('B', 'keyhole', 53, 33, 1, 0, r=3.4 * k, nw=2.1)
    body = c.m(core, tabN, tabS, minus=(blW, blE))
    c.add(body, SALT, stitch=None)
    # front edge of the slab: pink crust layer then the lilac mirror below
    c.add(body & c.m(K.rect(0, 43, 64, 47)), PINK)
    c.add(body & c.m(K.rect(0, 47, 64, 64)), LILAC)
    # strata line between pink and lilac
    for x in range(c.P(11, 0)[0], c.P(53, 0)[0]):
        if (x // (1 if c.small else 2)) % 3 == 0:
            c.px(x, c.P(0, 49.5)[1], LILAC[2])
    # top face: polygon crack ridges (salt-flat hexagons)
    if c.small:
        cracks = [
            [(11, 22), (17, 20), (20, 15)],
            [(44, 15), (47, 21), (53, 23)],
            [(17, 20), (19, 26)],
            [(47, 21), (45, 26)],
            [(11, 25), (15, 26), (17, 29)],
            [(53, 25), (49, 26), (47, 29)],
        ]
    else:
        cracks = [
            [(11, 22), (17, 20), (20, 15)],
            [(44, 15), (47, 21), (53, 23)],
            [(17, 20), (19, 26)],
            [(47, 21), (45, 26)],
            [(27, 15), (29, 19), (35, 19), (37, 15)],
            [(11, 25), (15, 26), (17, 29)],
            [(53, 25), (49, 26), (47, 29)],
            [(29, 19), (26, 22)],
            [(35, 19), (38, 22)],
        ]
    for pts in cracks:
        c.line(pts, CRACK)
    # little curling crack-smiles on the crust
    for sx, sy in ((17, 41), (46, 41)) if c.small else ((16, 41), (48, 41), (25, 39.5), (39, 39.5)):
        x, y = c.P(sx, sy)
        c.px(x - 1, y, CRACK2)
        c.px(x, y + 1, CRACK2)
        c.px(x + 1, y + 1, CRACK2)
        c.px(x + 2, y, CRACK2)
    # face: felt eyes and a big crack-smile that curls up at both ends
    c.eye(25.5, 23)
    c.eye(38.5, 23)
    if c.small:
        c.line([(23, 27.5), (25, 30.5), (32, 32), (39, 30.5), (41, 27.5)], UMBER2)
        c.px(*c.P(22, 26.5), UMBER2)
        c.px(*c.P(42, 26.5), UMBER2)
    else:
        c.line([(23, 28), (25, 31), (29, 32.5), (35, 32.5), (39, 31), (41, 28)], K.UMBER2)
        c.line([(24, 28), (26, 30.5), (29, 31.5), (35, 31.5), (38, 30.5), (40, 28)], K.UMBER2)
        c.line([(26, 30.1), (29, 30.7), (35, 30.7), (38, 30.1)], '#f6b8cf')
        c.line([(23, 28), (22, 26.5), (20.5, 26.5)], K.UMBER2)
        c.line([(41, 28), (42, 26.5), (43.5, 26.5)], K.UMBER2)
    c.blush(20.5, 29)
    c.blush(42.5, 29)


UMBER2 = K.UMBER2

if __name__ == '__main__':
    rep = K.render_pal(fn, 'pl-mirr-3', 'Saltcrack Smile', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-mirr-3-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-mirr-3.png')
    print(rep)
