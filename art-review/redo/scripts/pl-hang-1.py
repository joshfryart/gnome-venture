import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
"""pl-hang-1 Fruit Tray Tumble. Corner-TB keyhole: flat W and S (tray base), keyhole tab N = a green grape on its stem,
keyhole blank E = the bite out of the red apple. Sandstone tray with the cell's purple arches and dripping green vine."""
ROOT = '/home/user/gnome-venture'
SAND = K.ramp('#dcc29a')
ARCH = ('#4a3858', '#3a2c48', '#6a5878')
PLUM = K.ramp('#8a4a9a')
APPLE = K.ramp('#cc3a32')
GRAPE = K.ramp('#6cbc44')
VINE = K.ramp('#3fa84a')
SHADOW = ('#5a3a4a', '#4a2e3c', '#6a4858')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(9, 21, 53, 57)
    tabN = K.knob('T', 'keyhole', 31, 21, 0, -1, r=5.0 * k)
    blankE = K.knob('B', 'keyhole', 53, 30, 1, 0, r=4.6 * k)
    plum = K.ell(21.5, 30, 12.5, 12)
    apple = K.ell(42, 31, 11.5, 11)
    body = c.m(core, tabN, plum, apple, minus=(blankE,))
    c.add(body, SHADOW)
    # fruits
    c.add(c.m(apple, minus=(blankE,)) & body, APPLE)
    c.add(c.m(plum) & body, PLUM)
    grapes = [(29, 38), (34, 38), (31.5, 42), (26.5, 42), (36.5, 42)]
    gr = 3.0 if not c.small else 3.4
    for (gx, gy) in grapes:
        g = c.m(K.ell(gx, gy, gr, gr))
        c.add(g, GRAPE)
    for (gx, gy) in grapes:
        c.edge(c.m(K.ell(gx, gy, gr, gr)), '#3f7a2a')
        if not c.small:
            c.px(*c.P(gx - 1, gy - 1), '#c4ec9a')
    # tab grape on its stem
    c.add(c.m(tabN, minus=(core, plum, apple)) | (c.m(tabN) & c.m(K.rect(0, 19, 64, 22))), GRAPE)
    # tray
    tray = c.m(K.rect(9, 44, 53, 57))
    c.add(tray, SAND)
    lip = c.m(K.rect(9, 44, 53, 47.5))
    c.add(lip, (SAND[2], SAND[0], '#f4e6c8'))
    # purple arches carved in the tray (from the ruin wall)
    for ax in (17, 31, 45):
        c.add(c.m(K.rect(ax - 3.2, 50.5, ax + 3.2, 57), K.ell(ax, 50.5, 3.2, 3.0)) & tray, ARCH)
    # dripping vine over the lip
    vw = 2.6 if not c.small else 3.0
    c.add(c.m(K.thick_path([(24, 45), (24, 53)], vw)), VINE)
    c.add(c.m(K.thick_path([(38, 45), (38, 51)], vw)), VINE)
    c.add(c.m(K.thick_path([(9.5, 45.5), (52.5, 45.5)], 1.8 if not c.small else 2.4)) & c.m(core), VINE)
    # stem + leaf on the apple, stem on the plum
    c.add(c.m(K.thick_path([(42, 21), (43.5, 17.5)], 2.2 if not c.small else 2.8)), K.ramp('#7a4a1f'))
    c.add(c.m(K.ell(47, 18.5, 3.2, 1.8)), VINE)
    # highlights
    if not c.small:
        for (x, y) in ((36, 25), (37, 26), (36, 26)):
            c.px(*c.P(x, y), '#f08a7a')
    c.edge(c.m(plum) & body, PLUM[1])
    # face on the plum
    c.eye(17, 29, look=(0, 0))
    c.eye(25.5, 29)
    c.smile(21.5, 34)
    c.blush(14.5, 33)
    c.blush(28, 33)


if __name__ == '__main__':
    print(K.render_pal(fn, 'pl-hang-1', 'Fruit Tray Tumble', ROOT + '/art-review/redo/out',
                       cellfile=ROOT + '/art-review/redo/_src/pl-hang-1-cell.png',
                       oldfile=ROOT + '/game/assets/img/puzzles/pals/pl-hang-1.png'))
