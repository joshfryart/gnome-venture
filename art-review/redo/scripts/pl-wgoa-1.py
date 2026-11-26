import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
# Corner-BB keyhole: a farmhouse pal. Flat W wall + flat S ground; keyhole blank cut into the red tiled roof ridge (N, the "topknot"
# parted in two) and a keyhole blank in the E wall. Roof red, cream wall, brown door, from the farmhouse in the goat vineyard picture.
ROOF = K.ramp('#d0503c')
WALLC = K.ramp('#f4e4c4')
DOOR = K.ramp('#6a3c2c')
EAVE = K.ramp('#8a3a2c')

def fn(c):
    k = 1.15 if c.small else 1.0
    roof = K.poly([(10, 32), (10, 28), (20, 8), (44, 8), (54, 28), (54, 32)])
    wall = K.rect(10, 29, 54, 58)
    bN = K.knob('B', 'keyhole', 32, 8, 0, -1, r=4.6 * k)
    bE = K.knob('B', 'keyhole', 54, 45, 1, 0, r=4.4 * k)
    cut = (bN, bE)
    body = c.m(roof, wall, minus=cut)
    c.add(body & c.m(wall), WALLC, stitch='#d8c49c')
    rm = body & c.m(roof)
    c.add(rm, ROOF, stitch=None)
    # tile rows
    rows = (14, 20, 26) if not c.small else (16, 24)
    for ty in rows:
        y = c.P(0, ty)[1]
        for x in range(c.n):
            if (x, y) in rm and ((x, y - 1) in rm):
                c.px(x, y, ROOF[1])
    if not c.small:
        for (x, y) in rm:
            if y in [c.P(0, t)[1] + 2 for t in (8, 14, 20, 26)] and (x % 5 == 0):
                c.px(x, y, ROOF[1])
    # eave band under the roof
    c.add(body & c.m(K.rect(10, 29, 54, 32)), EAVE)
    # door (bottom left of centre)
    c.add(c.m(K.rect(17, 45, 27, 58), K.ell(22, 45, 5, 4)), DOOR)
    if not c.small:
        c.px(*c.P(25, 51), '#f0c030')
    # cypress tuft hugging the left wall bottom
    c.add(c.m(K.ell(13.5, 52, 3.6, 6.5)) & body, K.ramp('#3f7a3a'))
    # window-eyes with blue panes
    for ex in (24, 38):
        c.add(c.m(K.rect(ex - 4.5, 34, ex + 4.5, 42)), K.ramp('#9abfd5'))
        c.eye(ex, 38.5)
    c.blush(17.5, 42) if not c.small else None
    c.smile(33, 47, K.UMBER2)

K.render_pal(fn, 'pl-wgoa-1', 'Terracotta Topknot', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wgoa-1-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wgoa-1.png')
