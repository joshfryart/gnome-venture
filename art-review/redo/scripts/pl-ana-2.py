#!/usr/bin/env python3
"""pl-ana-2 "Tongue Taster": edge-TBT, tri. A green anaconda coiled into a square edge piece, lying on a bark branch.
Flat S = the bark branch it rests on (tan bark + moss from cell 3-5). W tri tab = the pointed tail tip. N tri blank bites the top coil.
E tri tab = the snake's triangular head, eye + red forked tongue tasting the breeze. Lime/leaf greens with dark spots from the snake in the picture."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

ROOT = '/home/user/gnome-venture/art-review/redo'
SNAKE = K.ramp('#8fc55e')
SNAKEL = ('#c4ea78', '#8fc55e', '#e2f6b0')
SNDK = '#2e6a46'
BARK = K.ramp('#c8985c')
BARKD = '#8c5c3c'
MOSS = ('#4e9a4c', '#255739', '#7ec06a')
TONGUE = '#d8323a'


def fn(c):
    k = 1.15 if c.small else 1.0
    x0, x1, y0, y1 = 10, 44, 15, 57
    def stad(t, bt):
        h = (bt - t) / 2
        return lambda x, y: (x0 + 5 <= x < x1 - 5 and t <= y < bt) or ((x - x0 - 5) / 5.4) ** 2 + ((y - t - h) / h) ** 2 < 1 \
            or ((x - x1 + 5) / 5.4) ** 2 + ((y - t - h) / h) ** 2 < 1
    coils = [stad(y0, 29.6), stad(28.4, 43.6), stad(42.4, 52)]
    core = lambda x, y: any(f(x, y) for f in coils) or (x0 <= x < x1 and 50 <= y < y1)
    tail = K.knob('T', 'tri', x0, 36, -1, 0, r=4.3 * k)
    head = K.knob('T', 'tri', x1, 30, 1, 0, r=6.6 * k, nw=4.2)
    blank = K.knob('B', 'tri', 29, y0, 0, -1, r=4.4 * k)
    body = c.m(core, tail, head, minus=(blank,))
    c.add(body, SNAKE)
    # three stacked coils (cylinders): side notches between coils, lit top, dark underside, dark groove
    gy = (29, 43)
    bands = ((y0, gy[0]), (gy[0], gy[1]), (gy[1], 50))
    for (t, bt) in bands:
        band = c.m(K.rect(x0, t, x1, bt)) & body
        for (px, py) in band:
            Y = (py + 0.5) / c.k
            if Y > bt - 4.2:
                c.px(px, py, '#5e9a4a')
            if Y > bt - 1.4:
                c.px(px, py, K.UMBER2 if bt < 50 else SNDK)
            elif Y < t + 1.8:
                c.px(px, py, '#c4ea78')
    # dark spot pattern (the picture's anaconda dots)
    spots = [(17, 21), (24, 24), (38, 21), (42, 25), (15, 34), (22, 37), (30, 33), (37, 37), (43, 34),
             (18, 46), (27, 46), (35, 47)]
    for (sx, sy) in spots:
        px, py = c.P(sx, sy)
        if (px, py) in body:
            c.px(px, py, SNDK)
            if not c.small:
                for d in ((1, 0), (0, 1), (1, 1)):
                    c.px(px + d[0], py + d[1], SNDK)
    # bark branch: the flat south side
    branch = c.m(K.rect(x0, 50, x1, y1)) & body
    c.add(branch, BARK)
    for gx in (16, 27, 39):
        X, _ = c.P(gx, 0)
        for Y in range(c.P(0, 51.5)[1], c.P(0, 56)[1]):
            c.px(X, Y, BARKD)
    c.add(c.m(K.ell(33, 50.8, 4.2, 1.8), K.ell(19.5, 50.8, 2.6, 1.6)), MOSS)
    # tail tip a touch paler
    c.add(c.m(tail, minus=(K.rect(x0 - 1, 0, 64, 64),)), SNAKE)
    # head: tri tab, darker cap, eye, forked tongue
    hd = c.m(head, minus=(K.rect(0, 0, x1 + 0.5, 64),))
    c.add(hd, ('#7ab84e', '#4e8a36', '#c4ea78'))
    c.edge(c.m(K.rect(x1 - 0.5, 20, x1 + 1, 40)) & body, SNDK)
    c.eye(x1 + 4.2, 27.4 if not c.small else 26.5, disc=True)
    # forked tongue out of the tip
    tip = x1 + 1 + 2.2 * 6.6 * k
    w = 2.0 if not c.small else 2.8
    c.add(c.m(K.thick_path([(tip - 1.5, 30), (tip + 1.2, 30)], w),
              K.thick_path([(tip + 0.8, 30), (63.2, 26.4)], w),
              K.thick_path([(tip + 0.8, 30), (63.2, 33.6)], w)), (TONGUE, '#a8202a', '#f06a5a'))
    # tiny smile line on the head
    if not c.small:
        hx, hy = c.P(x1 + 4, 31.5)
        for dx in range(0, 4):
            c.px(hx + dx, hy, SNDK)
    c.blush(x1 + 1.5, 32.5)


if __name__ == '__main__':
    print(K.render_pal(fn, 'pl-ana-2', 'Tongue Taster', ROOT + '/out',
                       cellfile=ROOT + '/_src/pl-ana-2-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-ana-2.png'))
