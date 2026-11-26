# pl-fyn-6 "Trail Dassie" (whimsy-dassie, double): a chubby rock dassie sitting front-on IS the piece.
# Flat top with two round ears; double tab S = two hind paws; double tab E = the pink protea it sniffs; double blank W.
# Fur in the ash-trail cell browns (#a8643c / #c07f4b), plum flecks (#6c3c3c), cream ash belly/muzzle.
import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K

FUR = K.ramp('#a8643c')
FURL = K.ramp('#c07f4b')
PLUM = K.ramp('#6c3c3c')
ASH = K.ramp('#f0cc94')
PROT = K.ramp('#e0607e')
LEAF = K.ramp('#4f8a3c')
PAW = K.ramp('#7a4a30')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(11, 15, 49, 54)
    corners = K.poly([(11, 15), (15, 15), (11, 19)])
    corners2 = K.poly([(49, 15), (45, 15), (49, 19)])
    tabS = K.knob('T', 'double', 30, 54, 0, 1, r=5.2 * k)
    tabE = K.knob('T', 'double', 49, 36, 1, 0, r=5.2 * k)
    blankW = K.knob('B', 'double', 11, 37, -1, 0, r=4.6 * k)
    earL = K.ell(15, 15.5, 4.0, 3.6)
    earR = K.ell(45, 15.5, 4.0, 3.6)
    body = c.m(core, earL, earR, minus=(blankW, corners, corners2))
    c.add(body, FUR)
    # inner ears
    c.add(c.m(K.ell(15, 15, 2.0, 1.8)), PLUM)
    c.add(c.m(K.ell(45, 15, 2.0, 1.8)), PLUM)
    # cream belly / ash
    belly = c.m(K.ell(29, 48, 10, 7)) & body
    c.add(belly, ASH)
    # paws (double tab S)
    c.add(c.m(tabS, minus=(core,)), FUR)
    c.add(c.m(tabS) & c.m(lambda x, y: y > 57.5), PAW)
    tx, ty = c.P(30, 60)
    for yy in range(ty, c.n):
        if (tx, yy + 1) in c.m(tabS):
            c.px(tx, yy, K.UMBER2)
    # protea (double tab E): pink bract cup with cream centre and a leaf stem
    pro = c.m(tabE, minus=(core,)) | (c.m(tabE) & c.m(K.rect(47, 0, 50, 64)))
    c.add(pro, PROT)
    cx, cy = 49 + 1.6 + 5.2 * k - 1, 36
    if not c.small:
        for (x, y) in pro:
            X, Y = (x + .5) / c.k, (y + .5) / c.k
            if X > cx + 0.5 and abs(Y - cy) < 2.0:
                c.px(x, y, '#f8d8a0')
    else:
        x0, y0 = c.P(cx + 1.5, cy)
        c.px(x0, y0, '#f8d8a0'); c.px(x0, y0 - 1, '#f8d8a0')
    # little front paws holding the stem
    c.add(c.m(K.ell(40, 41, 4.2, 3.0)), FURL)
    c.add(c.m(K.thick_path([(41, 41), (49, 38)], 2.8 if not c.small else 3.2)), LEAF)
    # face: big muzzle, dark dassie nose
    c.add(c.m(K.ell(30, 31, 7.5, 5.2)), K.ramp('#d89a62'))
    # pale dassie eyebrow patches
    c.add(c.m(K.ell(21.5, 22, 3.4, 2.0), K.ell(38.5, 22, 3.4, 2.0)), ASH)
    c.eye(21.5, 26)
    c.eye(38.5, 26)
    nx, ny = c.P(30, 28.5)
    for dx in (-2, -1, 0, 1, 2):
        c.px(nx + dx, ny, K.UMBER)
    for dx in (-1, 0, 1):
        c.px(nx + dx, ny + 1, K.UMBER)
    c.px(nx, ny + 2, K.UMBER2)
    if not c.small:
        c.px(nx, ny + 3, K.UMBER2)
        for w in ((23, 30), (37, 30), (23.5, 32), (36.5, 32)):
            c.px(*c.P(*w), K.UMBER2)
    if not c.small:
        c.smile(30, 33.5, K.UMBER2)
        c.blush(18, 30); c.blush(41, 30)
        # plum trail flecks on the fur (cell motif)
        for (fx, fy) in ((14, 24), (15, 25), (45, 22), (46, 23), (13, 44), (14, 44)):
            p = c.P(fx, fy)
            if p in body:
                c.px(*p, PLUM[0])
    else:
        c.blush(17, 31); c.blush(41, 31)


K.render_pal(fn, 'pl-fyn-6', 'Trail Dassie', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-fyn-6-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-fyn-6.png')
