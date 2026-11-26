#!/usr/bin/env python3
"""br-petal-pinch "Petal Pinch": corner-TT, round. A little cherry-blossom tree that IS a corner piece: a square pink canopy
(blossom puffs as the two round tabs, N and E), flat W and S sides, a dark bark trunk band along the flat bottom with a pocket
holding one pinched petal. Colours from cell 1-1 of Blossomreach (pink canopy, white five-petal blossoms, umber bark)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

PINK = ('#f7c4d3', '#e08aa7', '#fbe0e8')
PINKD = K.ramp('#e08aa7')
BARK = ('#6a4a3b', '#4b3029', '#8a6650')
POCK = K.ramp('#b8516f')
SKY = ('#cfe3ec', '#c3bedc', '#e4f0f5')
GRASS = K.ramp('#6fb04a')
WH = '#fff8f8'
CTR = '#f0b030'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(9, 15, 51, 57)
    tabN = K.knob('T', 'round', 28, 15, 0, -1, r=5.4 * k, nw=3.2)
    tabE = K.knob('T', 'round', 51, 32, 1, 0, r=5.4 * k, nw=3.2)
    puffs = [K.ell(x, 15, 3.4, 2.2) for x in (14, 40, 47)] + [K.ell(51, y, 2.2, 3.4) for y in (20, 43)]
    body = c.m(core, tabN, tabE, *puffs)
    c.add(body, PINK, stitch=None if c.small else '#e08aa7')
    # lower third: pale sky (cell's sky blue), a bark trunk with a root flare, a grass strip on the flat bottom
    low = c.m(K.rect(0, 40, 64, 64)) & body
    c.add(low, SKY)
    trunk = K.poly([(20, 57), (24.5, 49), (24, 40), (37, 40), (36.5, 49), (41, 57)])
    c.add(c.m(trunk, K.thick_path([(35, 46), (42, 42.5), (46, 40)], 3.0 * k)), BARK)
    c.add(c.m(K.rect(9, 53.5, 51, 57), minus=(K.rect(24, 0, 37.5, 64),)), GRASS)
    # canopy hem: blossom puffs hanging over the sky
    hem = c.m(*[K.ell(sx, 41, 5.6, 4.2 + (0.6 if i % 2 else 0)) for i, sx in enumerate((13.5, 23, 32.5, 42, 49))]) & body
    c.add(hem, PINK)
    c.add(hem & c.m(K.rect(0, 41.5, 64, 64)), PINKD)
    # pocket on the trunk with a pinched petal peeking out
    pk = c.add(c.m(K.rect(27.5, 49, 34.5, 54)), POCK)
    c.edge(pk, POCK[1])
    px, py = c.P(31, 48.5)
    for dx, dy in ((0, 0), (1, 0), (-1, 0), (0, -1), (1, -1)) if not c.small else ((0, 0), (1, 0), (0, -1)):
        c.px(px + dx, py + dy, PINKD[0])
    c.px(px, py - (2 if not c.small else 1), PINK[2])
    # white five-petal blossoms on the canopy
    spots = [(15, 21), (40, 19), (27, 10.5), (56, 30), (45, 39), (14, 37)]
    for bx, by in spots:
        x, y = c.P(bx, by)
        if c.small:
            for dx, dy in ((0, -1), (-1, 0), (1, 0), (0, 1)):
                c.px(x + dx, y + dy, WH)
            c.px(x, y, CTR)
        else:
            for dx, dy in ((0, -2), (-2, -1), (2, -1), (-1, 1), (1, 1), (0, -1), (-1, -1), (1, -1), (-1, 0), (1, 0), (0, 1)):
                c.px(x + dx, y + dy, WH)
            c.px(x, y, CTR)
    # pink darker petal flecks
    if not c.small:
        for bx, by in [(21, 18), (35, 13), (47, 26), (20, 41), (40, 43)]:
            c.px(*c.P(bx, by), PINKD[0])
    # face on the calm canopy middle
    c.eye(24, 29)
    c.eye(36, 29)
    c.smile(30, 34, '#8e2f4c')
    c.blush(19.5, 33)
    c.blush(40, 33)


if __name__ == '__main__':
    G = '/home/user/gnome-venture/'
    print(K.render_pal(fn, 'br-petal-pinch', 'Petal Pinch', G + 'art-review/redo/out',
                       cellfile=G + 'art-review/redo/_src/br-petal-pinch-cell.png',
                       oldfile=G + 'game/assets/img/puzzles/pals/br-petal-pinch.png'))
