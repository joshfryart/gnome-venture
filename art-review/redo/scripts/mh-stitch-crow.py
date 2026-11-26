import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K

R = '/home/user/gnome-venture/'
CROW = K.ramp('#3e3a5c')      # violet-navy (mountain shade) crow felt
STRAW = K.ramp('#e8b83a')     # corn straw
BAND = K.ramp('#c8602a')      # terracotta tile
TEALP = K.ramp('#2a9a9a')     # teal tile patch
BEAK = K.ramp('#f0a020')
WING = K.ramp('#2e2a48')


def fn(c):
    k = 1.15 if c.small else 1.0
    x0, y0, x1, y1 = 14, 16, 50, 52
    core = K.rect(x0, y0, x1, y1)
    top = K.knob('T', 'hook', 32, y0, 0, -1, r=4.5 * k)
    left = K.knob('T', 'hook', x0, 33, -1, 0, r=4.5 * k, flip=True)
    right = K.knob('B', 'hook', x1, 36, 1, 0, r=4.5 * k)
    bot = K.knob('B', 'hook', 32, y1, 0, 1, r=4.5 * k)
    body = c.m(core, top, left, minus=(right, bot))
    c.add(body, CROW, stitch='#6a6490')
    # wing on the right, folded
    wing = c.m(K.ell(40, 42, 8, 9), minus=(right, bot, K.rect(0, 0, 64, 31)))
    c.add(wing & body, WING)
    c.edge(wing & body, '#1e1a34')
    # patches
    c.add(c.m(K.rect(18, 40, 26, 47)) & body, TEALP)
    # straw hat: domed crown (top tab = its straw curl), terracotta band, brim with drooping ends
    crown = c.m(K.ell(32, 22, 10, 7.5), top, minus=(K.rect(0, 23, 64, 64),)) & body
    c.add(crown, STRAW)
    c.edge(crown, STRAW[1])
    c.add(c.m(K.rect(22, 19.5, 42, 23)) & crown, BAND)
    brim = c.m(K.ell(32, 25, 19, 3.4), K.rect(x0, 24, x0 + 4, 29), K.rect(x1 - 4, 24, x1, 29)) & body
    c.add(brim, STRAW)
    c.edge(brim, STRAW[1])
    # crow head feathers poking up in the top corners
    # beak = left tab plus a big wedge
    c.add(c.m(left, K.poly([(x0 - 1, 30), (x0 + 8, 33.5), (x0 - 1, 38)])) & body, BEAK)
    c.line([(x0, 34), (x0 + 6, 34)], BEAK[1])
    # straw tufts poking from the cuffs at the bottom corners
    for sx in (17, 45):
        c.add(c.m(K.rect(sx - 3, 48, sx + 3, y1)) & body, STRAW)
    # face
    c.eye(27, 32, disc=True, look=(-1, 0))
    c.eye(37, 32, disc=True, look=(-1, 0))
    if not c.small:
        # stitch crosses on the teal patch
        for (a, b) in ((19, 41), (23, 44)):
            p = c.P(a, b)
            c.px(p[0], p[1], K.CREAM); c.px(p[0] + 1, p[1] + 1, K.CREAM)
            c.px(p[0] + 1, p[1], K.CREAM); c.px(p[0], p[1] + 1, K.CREAM)


K.render_pal(fn, 'mh-stitch-crow', 'Stitch Crow', R + 'art-review/redo/out',
             cellfile=R + 'art-review/redo/_src/mh-stitch-crow-cell.png',
             oldfile=R + 'game/assets/img/puzzles/pals/mh-stitch-crow.png')
