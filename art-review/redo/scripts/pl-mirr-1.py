"""pl-mirr-1 Nugget Nap. Corner-TB, keyhole: a dozing heap of golden nuggets on a pink-lit salt crust.
Flat W and S (the salt band is the S edge), keyhole tab N = the top nugget of the pile, keyhole blank E bitten into the heap.
Colours from cell 9-6 of the Mirror Salt Flat: sunset gold nuggets with pink sky glints, pink + lavender salt crust."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

GOLDA = K.ramp('#f0b030')
GOLDB = K.ramp('#e89a28')
GOLDC = K.ramp('#f6c848')
PINK = K.ramp('#e08cb4')
LAVS = K.ramp('#b888c8')
SALT = ('#f4e8ee', '#d8b8cc', '#ffffff')
GLINT = '#fff6d8'
ZPINK = '#c8508a'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(10, 17, 53, 57)
    tabN = K.knob('T', 'keyhole', 30, 17, 0, -1, r=5.4 * k)
    blankE = K.knob('B', 'keyhole', 53, 33, 1, 0, r=4.4 * k)
    bumps = [K.ell(18, 18, 7, 4.6), K.ell(43, 18, 7.5, 4.6)]
    body = c.m(core, tabN, *bumps, minus=(blankE,))
    c.add(body, GOLDB)
    # nuggets: back row, side lumps, big front sleeper
    nug = [
        (K.ell(19, 23, 9, 7), GOLDC),
        (K.ell(43, 23, 9, 7), GOLDA),
        (K.ell(15, 38, 7, 9), GOLDA),
        (K.ell(47, 45, 7, 6), GOLDC),
        (K.ell(31, 38, 14, 11), GOLDA),
    ]
    top = c.m(tabN, minus=(core,)) | (c.m(tabN) & c.m(K.rect(0, 15, 64, 19)))
    c.add(top, GOLDC)
    if not c.small:
        c.edge(top, GOLDB[1])
    for (pr, rp), (hx, hy, hr) in zip(nug, [(15, 20, 3), (39, 20, 3), (12, 33, 2.5), (44, 42.5, 2.5), (24, 31, 4)]):
        mk = c.m(pr) & body
        c.add(mk, rp)
        c.edge(mk, GOLDB[1])
        # facet: light patch upper left, dark crescent lower right inside each nugget
        for (x, y) in mk:
            if (x + 1, y + 1) not in mk and (x - 1, y - 1) in mk and (x, y) in body:
                c.px(x, y, K.ramp(rp[0])[1])
        if not c.small or hr >= 3:
            for (x, y) in c.m(K.ell(hx, hy, hr, hr * 0.7)) & mk:
                c.px(x, y, rp[2])
    # salt crust band (S flat side): pink sky reflected, lavender below
    c.add(body & c.m(K.rect(0, 49, 64, 57)), PINK)
    c.add(body & c.m(K.rect(0, 54, 64, 57)), LAVS)
    for sx in (14, 24, 40, 49):
        x, y = c.P(sx, 51)
        c.px(x, y, SALT[2])
        if not c.small:
            c.px(x + 1, y, SALT[0])
    # sparkles (pink sky glints + cream)
    for gx, gy, col in ((19, 21, GLINT), (13, 35, GLINT), (30, 9.5, GLINT), (46, 43, '#f6c0d8')):
        x, y = c.P(gx, gy)
        c.px(x, y, col)
        if not c.small:
            c.px(x - 1, y, col); c.px(x + 1, y, col); c.px(x, y - 1, col); c.px(x, y + 1, col)
    # sleeping face on the big nugget: closed arcs, small o-mouth, blush
    for ex in (25, 37):
        x, y = c.P(ex, 37)
        if c.small:
            c.px(x - 1, y, K.UMBER); c.px(x, y + 1, K.UMBER); c.px(x + 1, y, K.UMBER)
        else:
            c.px(x - 2, y, K.UMBER); c.px(x - 1, y + 1, K.UMBER); c.px(x, y + 1, K.UMBER); c.px(x + 1, y + 1, K.UMBER); c.px(x + 2, y, K.UMBER)
    mx, my = c.P(31, 42)
    c.px(mx, my, K.UMBER2)
    if not c.small:
        c.px(mx + 1, my, K.UMBER2); c.px(mx, my + 1, K.UMBER2); c.px(mx + 1, my + 1, K.UMBER2)
    c.blush(21, 40.5)
    c.blush(40, 40.5)
    # z on the right upper nugget
    if not c.small:
        zx, zy = c.P(44, 19.5)
        for dx, dy in ((0, 0), (1, 0), (2, 0), (3, 0), (4, 0), (3, 1), (2, 2), (1, 3), (0, 4), (1, 4), (2, 4), (3, 4), (4, 4)):
            c.px(zx + dx, zy + dy, ZPINK)


K.render_pal(fn, 'pl-mirr-1', 'Nugget Nap', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-mirr-1-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-mirr-1.png')
