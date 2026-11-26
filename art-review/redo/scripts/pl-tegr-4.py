#!/usr/bin/env python3
"""pl-tegr-4 "Conehat Cluster": inner-TTTT, keyhole. A round tea-bush pal under a big straw cone hat; the hat's peak knob is the N tab,
two buddy hats seen from above (the straw discs of cell 4-4) are the E and W tabs, a tea tuft is the S tab. Stone terrace band at the
bottom, straw / stone / tea greens sampled from the cell."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

STRAW = K.ramp('#e8cc90')
STRAWD = '#b8955e'
TEA = ('#5a9a44', '#3c6e32', '#8ccc48')
TEAL = ('#72ba51', '#4f8a3a', '#a8d86a')
STONE = ('#b49a7a', '#7c6a6a', '#d8c498')
MORTAR = '#7c6a6a'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(13, 24, 51, 51)
    tN = K.knob('T', 'keyhole', 32, 15, 0, -1, r=4.0 * k)
    tE = K.knob('T', 'keyhole', 51, 40, 1, 0, r=4.6 * k)
    tW = K.knob('T', 'keyhole', 13, 40, -1, 0, r=4.6 * k)
    tS = K.knob('T', 'keyhole', 32, 51, 0, 1, r=4.2 * k)
    # tea bush body fills the square
    body = c.m(core)
    c.add(body, TEA)
    # leafy corners above the hat: lighter tea
    c.add(c.m(K.rect(13, 24, 51, 32)), TEAL)
    # S tab: tea tuft
    c.add(c.m(tS, minus=(core,)) | (c.m(tS) & c.m(K.rect(0, 49, 64, 52))), TEAL)
    # stone terrace band at the bottom
    wall = c.m(K.rect(13, 44, 51, 51))
    c.add(wall, STONE)
    if True:
        y0 = c.P(0, 47.5)[1]
        for x in range(c.P(13, 0)[0], c.P(51, 0)[0]):
            c.px(x, y0, MORTAR)
        for bx, top in ((20, True), (29, True), (38, True), (47, True), (24, False), (33, False), (42, False)):
            ya, yb = (44, 47.5) if top else (47.5, 51)
            if c.small and not top:
                continue
            x = c.P(bx, 0)[0]
            for y in range(c.P(0, ya)[1], c.P(0, yb)[1]):
                c.px(x, y, MORTAR)
    # big cone hat: brim spans the full width, peak meets the N keyhole knob
    cone = K.poly([(13, 33), (51, 33), (34.5, 14), (29.5, 14)])
    hat = c.m(cone, tN)
    c.add(hat, STRAW, stitch=None)
    brim = c.m(K.ell(32, 34, 23.5, 2.6 if not c.small else 3.0))
    c.add(brim, (STRAW[1], '#8a6a40', STRAW[0]))
    # straw weave: rays from the peak
    rays = (22, 32, 42) if c.small else (19, 25.5, 32, 38.5, 45)
    for ex in rays:
        c.line([(32, 19), (ex, 31.5)], STRAWD)
    # brim shadow on the bush
    y = c.P(0, 37)[1]
    for x in range(c.P(13, 0)[0], c.P(51, 0)[0]):
        c.px(x, y, TEA[1])
    # E and W buddy hats from above (keyhole tabs), straw discs with a dark crown dot
    for t, cx in ((tE, 58.3), (tW, 5.7)):
        side = c.m(t, minus=(core,))
        c.add(side, STRAW)
        c.edge(c.m(K.ell(cx, 40.5, 2.2 * k, 2.2 * k)), STRAWD)
        px, py = c.P(cx, 40.5)
        c.px(px, py, STRAW[2])
    # face in the brim shade
    c.eye(25, 40.5)
    c.eye(39, 40.5)
    c.smile(32, 42.5)
    c.blush(21, 43)
    c.blush(42, 43)


if __name__ == '__main__':
    rep = K.render_pal(fn, 'pl-tegr-4', 'Conehat Cluster', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-tegr-4-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-tegr-4.png')
    print(rep)
