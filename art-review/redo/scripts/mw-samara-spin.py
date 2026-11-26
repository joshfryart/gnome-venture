import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

R = '/home/user/gnome-venture/art-review/redo'
ROOF = K.ramp('#b8412d')
ROOFDK = '#8a2c20'
DAB = '#f0a020'
SEED = K.ramp('#8a5430')
STONE = K.ramp('#8a8474')


def fn(c):
    """whimsy-leaf, hook: a maple samara. Broad wing = piece core (hook tabs N and S, hook blanks E and W),
    round seed bulging from the lower-left corner with the face. Wing in the roof-tile reds of cell 5-3."""
    k = 1.15 if c.small else 1.0
    wing = K.poly([(20, 8), (42, 7), (50, 9), (55, 15), (57, 24), (55, 40), (51, 44), (18, 44), (16, 30)])
    tabN = K.knob('T', 'hook', 34, 8, 0, -1, r=5.0 * k)
    tabS = K.knob('T', 'hook', 43, 44, 0, 1, r=4.6 * k, flip=True)
    blankE = K.knob('B', 'hook', 55, 31, 1, 0, r=4.4 * k)
    blankW = K.knob('B', 'hook', 18, 22, -1, 0, r=4.0 * k, flip=True)
    seed = K.ell(18, 47, 11.5, 10.5)
    stem = K.thick_path([(9, 55), (5, 60)], 3.4 if c.small else 3.0)
    body = c.m(wing, tabN, tabS, minus=(blankE, blankW, seed))
    c.add(body, ROOF, stitch=None)
    # tile-row veins sweeping from the seed up to the right edge, with orange tile dabs (the roof motif)
    lead = K.thick_path([(17, 36), (19, 12), (30, 8), (44, 8), (52, 11)], 5.0 if c.small else 4.0)
    c.add(c.m(lead) & body, ('#7e2a1c', '#5e1e14', '#a8442c'))
    for i, (ex, ey) in enumerate([(33, 11), (46, 13), (54, 22), (54, 33), (50, 42)]):
        pts = [(22, 40), ((22 + ex) / 2 + 2, (40 + ey) / 2 + 3), (ex, ey)]
        if c.small and i % 2:
            continue
        c.add(c.m(K.thick_path(pts, 2.2 if c.small else 1.6)) & body, (ROOFDK, ROOFDK, ROOFDK))
    if not c.small:
        for (x, y) in [(36, 22), (46, 28), (31, 30), (42, 18), (48, 37), (38, 38)]:
            c.px(*c.P(x, y), DAB)
            c.px(c.P(x, y)[0] + 1, c.P(x, y)[1], DAB)
    else:
        for (x, y) in [(38, 21), (45, 33), (32, 29), (48, 26)]:
            c.px(*c.P(x, y), DAB)
    c.add(c.m(stem), STONE)
    sm = c.add(c.m(seed), SEED, stitch=None)
    c.edge(sm, SEED[1])
    c.eye(13.5, 46, disc=True)
    c.eye(22, 46, disc=True)
    c.smile(18, 51)
    c.blush(10, 50)
    c.blush(25, 50)


if __name__ == '__main__':
    print(K.render_pal(fn, 'mw-samara-spin', 'Samara Spin', R + '/out',
                       cellfile=R + '/_src/mw-samara-spin-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/mw-samara-spin.png'))
