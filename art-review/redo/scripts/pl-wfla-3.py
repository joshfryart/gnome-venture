#!/usr/bin/env python3
"""pl-wfla-3 "Faraway Pink Fuzz": inner-TBTB, keyhole. A fluffy pink flamingo whose square fuzzy body IS the piece:
N keyhole tab = the long neck and round head (hooked dark-tipped beak breaks out right), S keyhole tab = the lavender shallows
with its pink legs standing in the ripple, keyhole blanks bite E and W into the fuzz. Pinks, lavender water and cream from cell 8-3."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

PINK = ('#f8a9bb', '#d87894', '#ffd2dc')
DEEP = ('#f08aa4', '#c8587c', '#f8b4c4')
NECK = ('#f08aa4', '#c8587c', '#ffc8d2')
WATER = ('#b08aa8', '#6a4a68', '#c8a0b8')
BEAK = ('#fdecc8', '#d8b898', '#fff4d8')
TIP = ('#4a2c3a', '#3a2030', '#6a4a68')
FACE = ('#f6d8c8', '#e0b0a8', '#fff0e4')
FUZZ = '#ffd2dc'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(11, 25, 53, 51)
    tabN = K.knob('T', 'keyhole', 27, 25, 0, -1, r=6.0 * k)
    tabS = K.knob('T', 'keyhole', 32, 51, 0, 1, r=5.6 * k)
    blankE = K.knob('B', 'keyhole', 53, 41, 1, 0, r=3.6 * k)
    blankW = K.knob('B', 'keyhole', 11, 39, -1, 0, r=3.6 * k)
    cut = (blankE, blankW)
    body = c.m(core, minus=cut)
    c.add(body, PINK, stitch=None)
    # fuzz: small feather 'v' marks in rows
    if not c.small:
        for (x, y) in body:
            if y % 4 == 0 and (x + (y // 4) * 3) % 6 == 0:
                c.px(x, y, FUZZ)
                c.px(x + 1, y + 1, FUZZ)
                c.px(x + 2, y, FUZZ)
    # folded wing: deep pink, scalloped lower edge, dark flight feathers at the tail end (right)
    wpoly = K.poly([(22, 34), (32, 29), (46, 28), (53, 29), (53, 34), (46, 41), (34, 44), (25, 41)])
    scal = lambda x, y: ((x % 6) - 3) ** 2 + (y - 42.5 + (x - 28) * 0.35) ** 2 < 6 and 26 < x < 46
    wing = c.m(wpoly, scal, minus=cut)
    c.add(wing, DEEP)
    c.edge(wing, '#c8587c')
    tips = c.m(K.poly([(44, 30), (51, 25), (57, 22), (58, 25), (53, 32), (48, 37)]), minus=cut)
    c.add(tips, TIP)
    if not c.small:
        c.line([(47, 32), (55, 25)], '#6a4a68')
    # neck (N tab) + head
    neck = c.m(tabN, minus=(core,)) | (c.m(tabN) & c.m(K.rect(0, 24, 64, 28)))
    c.add(neck, NECK)
    hr = 5.2 * (1.1 if c.small else 1.0)
    head = c.m(K.ell(27, 13, hr * 1.05, hr * 0.9))
    c.add(head, FACE)
    # beak: cream, bending down hard, dark tip
    bw = 3.8 if not c.small else 4.4
    beak = c.m(K.thick_path([(30, 11.5), (37, 11), (40, 14), (40, 18.5)], bw))
    c.add(beak, BEAK)
    c.add(c.m(K.thick_path([(39.6, 14.5), (40, 19)], bw)) & beak, TIP)
    # S tab: lavender shallows, legs standing in it
    water = c.m(tabS, minus=(core,))
    c.add(water, WATER)
    for gx in (29.5, 34.5):  # legs
        x, _ = c.P(gx, 0)
        for y in range(c.P(0, 51)[1], c.P(0, 58)[1]):
            c.px(x, y, '#c8587c')
            if not c.small:
                c.px(x + 1, y, '#f08aa4')
    for yy in (58.5, 61):
        ry = c.P(0, yy)[1]
        for x in range(c.P(24, 0)[0], c.P(40.5, 0)[0]):
            if (x, ry) in water and (x + ry) % 3:
                c.px(x, ry, '#e0c4d4')
    c.eye(26, 12.5, disc=False)
    c.blush(23.5, 15.5)


if __name__ == '__main__':
    R = '/home/user/gnome-venture/'
    print(K.render_pal(fn, 'pl-wfla-3', 'Faraway Pink Fuzz', R + 'art-review/redo/out',
                       cellfile=R + 'art-review/redo/_src/pl-wfla-3-cell.png',
                       oldfile=R + 'game/assets/img/puzzles/pals/pl-wfla-3.png'))
