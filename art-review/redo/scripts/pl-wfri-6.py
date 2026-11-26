"""pl-wfri-6 Dancing Pinkcap (whimsy-toadstool, keyhole).
A plump pink toadstool that IS the piece: the wide domed cap is the top, the stem the body. Keyhole tab N = the cap's nub,
keyhole tab W = the stem's arm holding out a little gold gift, keyhole blank E bites the stem; flat grass foot (the fairy ring).
Fairy-ring pink #d8486a cap with cream spots, cream stem, ring-grass greens (cell 8-6)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

PINK = K.ramp('#d8486a')
STEM = K.ramp('#f0dcc0')
GRASS = K.ramp('#68b868')
GIFT = K.ramp('#f0c030')
SPOT = '#f8e8d8'


def fn(c):
    k = 1.15 if c.small else 1.0
    cap = K.poly([(5, 31), (6, 24), (10, 16), (18, 10), (32, 7.5), (46, 10), (54, 16), (58, 24), (59, 31)])
    capR = K.ell(32, 30, 27, 3.2)
    stem = K.rect(17, 30, 47, 57)
    foot = K.rect(13, 52, 51, 59)
    tabN = K.knob('T', 'keyhole', 32, 8.5, 0, -1, r=5.4 * k, nw=3.0)
    tabW = K.knob('T', 'keyhole', 17, 43, -1, 0, r=5.4 * k, nw=3.0)
    blankE = K.knob('B', 'keyhole', 47, 43, 1, 0, r=4.8 * k)
    body = c.m(cap, capR, stem, foot, tabN, tabW, minus=(blankE,))
    # stem
    c.add(body & c.m(stem, tabW), STEM, stitch=None if c.small else '#d8c0a0')
    # gift in the W tab
    gift = c.m(tabW, minus=(K.rect(14.5, 0, 64, 64),))
    c.add(gift & body, GIFT)
    gx, gy = c.P(7.5, 43)
    for d in range(-3 if not c.small else -2, 4 if not c.small else 3):
        c.px(gx + (0 if not c.small else 0), gy + d, PINK[0])
        c.px(gx + d, gy, PINK[0])
    # grass foot
    c.add(body & c.m(foot, lambda x, y: y > 55 - (1.5 if (int(x) // 3) % 2 else 0) and 13 <= x < 51), GRASS)
    # cap
    capm = c.m(cap, capR, tabN) & body
    c.add(capm, PINK)
    c.edge(capm, PINK[1])
    # gills band under the cap
    gy0 = c.P(0, 32.8)[1]
    for x in range(c.P(18, 0)[0], c.P(46, 0)[0]):
        if (x, gy0) in body:
            c.px(x, gy0, STEM[1])
    # cream spots
    spots = [(20, 17, 3.6, 3.0), (40, 15, 3.2, 2.6), (12, 26, 2.4, 2.4), (52, 25, 2.4, 2.4), (31, 23, 2.6, 2.2), (32, 1.5, 2.6, 2.4)]
    c.add(c.m(*[K.ell(*s) for s in spots]) & capm, (SPOT, '#e0c8b8', '#ffffff'))
    # face on the stem
    c.eye(26.5, 40)
    c.eye(36.5, 40)
    c.smile(31.5, 46, wide=True)
    c.blush(22, 44)
    c.blush(40, 44)


if __name__ == '__main__':
    R = '/home/user/gnome-venture/'
    print(K.render_pal(fn, 'pl-wfri-6', 'Dancing Pinkcap', R + 'art-review/redo/out',
                       cellfile=R + 'art-review/redo/_src/pl-wfri-6-cell.png',
                       oldfile=R + 'game/assets/img/puzzles/pals/pl-wfri-6.png'))
