import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
"""Redsaddle Yak, whimsy-yak, keyhole: a side-on shaggy yak whose square body is the piece. Keyhole tab N = red saddle carrying a
bundle of prayer flags, keyhole tab E = the tail tuft, keyhole blank S = the gap between the legs, head + horns break out W.
Yak mauve and saddle red from the picture's yak, sand/wood from cell 9-6, flag stripes from the pass."""
YAKC = K.ramp('#644a54')
SHAG = K.ramp('#7e6070')
RED = K.ramp('#e74a50')
SAND = K.ramp('#d2b284')
WOODC = K.ramp('#b07a3a')
HORNC = K.ramp('#e8d0a0')
HOOF = K.ramp('#3e2c30')
FL = ['#3f7fc8', '#f4f0e4', '#e74a50', '#3f9a4a', '#f0c030']


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(16, 22, 56, 57)
    tabN = K.knob('T', 'keyhole', 37, 22, 0, -1, r=6.6 * k)
    tabE = K.knob('T', 'keyhole', 56, 32, 1, 0, r=5.0 * k)
    blankS = K.knob('B', 'keyhole', 36, 57, 0, 1, r=5.0 * k)
    hump = K.ell(25, 23, 9, 5)
    body = c.m(core, hump, minus=(blankS,))
    c.add(body, YAKC)
    # shaggy fringe: long hair hanging from the belly to the fetlocks, ragged hem, hooves peek below
    skirt = c.m(lambda x, y: y >= 39 + (2 if (int(x) // 3) % 2 else 0) and y < 53.5 + (1.5 if (int(x) // 2) % 2 else 0)) & body
    c.add(skirt, SHAG)
    c.add(body & c.m(K.rect(0, 53.5, 64, 57), minus=(lambda x, y: y < 55 and (int(x) // 2) % 2,)), HOOF)
    if not c.small:
        for (x, y) in skirt:
            if x % 3 == 0 and (x, y - 1) in skirt:
                c.px(x, y, YAKC[1])
    # tail tab
    c.add(c.m(tabE, minus=(core,)) | (c.m(tabE) & c.m(K.rect(54, 0, 57, 64))), SHAG)
    # saddle blanket over the back + the flag bundle tab
    blanket = c.m(K.rect(29, 21, 46, 36)) & body
    c.add(blanket, RED)
    c.add(c.m(K.rect(29, 33.5, 46, 36)) & body, SAND)
    bundle = c.m(tabN, minus=(core,))
    c.add(bundle, RED)
    # prayer flag bands across the bundle (horizontal, top to bottom)
    ys = [p[1] for p in bundle]
    if ys:
        y0, y1 = min(ys), max(ys)
        h = (y1 - y0 + 1) / 5
        for (x, y) in bundle:
            c.px(x, y, FL[min(4, int((y - y0) / h))])
    c.add(c.m(K.rect(29, 21, 46, 23.4)) & body, K.ramp('#c8a040'))
    # head, facing the viewer, breaks out W
    head = c.m(K.ell(13, 37, 9.5, 10))
    c.add(head, YAKC)
    hw = 3.4 if not c.small else 4.0
    c.add(c.m(K.thick_path([(8, 29), (4, 26), (3, 20), (5, 16.5)], hw)), HORNC)
    c.add(c.m(K.thick_path([(18, 29), (22, 26), (23, 20), (21, 16.5)], hw)), HORNC)
    c.add(c.m(K.ell(13, 30, 6, 3)), SHAG)   # forelock between horns
    c.add(c.m(K.ell(13, 43.5, 6.5, 4.2)), SAND)
    c.edge(head, YAKC[1])
    c.px(*c.P(10.5, 43), K.UMBER2)
    c.px(*c.P(15.5, 43), K.UMBER2)
    c.eye(9.5, 36, disc=True)
    c.eye(16.5, 36, disc=True)


K.render_pal(fn, 'pl-wpry-6', 'Redsaddle Yak', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wpry-6-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wpry-6.png')
