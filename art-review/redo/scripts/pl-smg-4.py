import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K

# Railtrack Rattle: a salt mine cart that is an inner-TTTT piece with double knobs.
# top tab = salt heap (two lumps), bottom tab = two slate wheels, side tabs = iron rail-end buffers.
RUST = K.ramp('#a85a2c')
RUSTD = K.ramp('#7a3c22')
SALT = ('#f0eaf2', '#b8a8c8', '#ffffff')
IRON = K.ramp('#7c8aa4')
WHEEL = K.ramp('#5c6a88')
PINK = '#e89aa8'
R = 'https://example.invalid'

def fn(c):
    k = 1.15 if c.small else 1.0
    x0, y0, x1, y1 = 13, 17, 51, 47
    core = K.rect(x0, y0, x1, y1)
    top = K.knob('T', 'double', 32, y0, 0, -1, r=5.0 * k)
    wr = 5.0 if not c.small else 5.4
    wy = y1 + 4.2
    bot = lambda x, y: (abs(x - 32) < 8 and y1 - 2 < y < wy) or K.ell(26.2, wy, wr, wr)(x, y) or K.ell(37.8, wy, wr, wr)(x, y)
    lef = K.knob('T', 'double', x0, 33, -1, 0, r=4.2 * k)
    rig = K.knob('T', 'double', x1, 33, 1, 0, r=4.2 * k)
    # wheels first (behind)
    c.add(c.m(bot, minus=(core,)), WHEEL)
    for wx in (26.2, 37.8):
        hub = c.m(K.ell(wx, wy, 2.0 if not c.small else 2.2, 2.0 if not c.small else 2.2))
        c.add(hub, IRON)
    c.add(c.m(lef, rig, minus=(core,)), IRON)
    body = c.add(c.m(core), RUST, stitch=None if c.small else '#d88a52')
    mound = K.ell(32, y0 + 3, 15, 8)
    salt = c.add(c.m(top, mound, K.rect(x0 + 3, y0 + 1, x1 - 3, 23)), SALT)
    # rim band under the salt
    band = c.add(c.m(K.rect(x0, 23, x1, 27)), RUSTD)
    c.edge(band, RUSTD[1])
    # wheel hubs
    for hx in (29.5, 34.5) if False else ():
        pass
    for wx in (26.2, 37.8):
        hx, hy = c.P(wx, wy)
        c.px(hx, hy, '#3a3048')
    # salt sparkles / lumps
    if not c.small:
        for (sx, sy) in ((20, 19), (40, 20), (31, 12), (27, 20), (45, 18)):
            p = c.P(sx, sy); c.px(p[0], p[1], SALT[1])
    else:
        p = c.P(22, 20); c.px(p[0], p[1], SALT[1])
        p = c.P(42, 20); c.px(p[0], p[1], SALT[1])
    # rivets on the band
    for rx in (17, 47):
        p = c.P(rx, 25); c.px(p[0], p[1], IRON[2])
    # face
    c.eye(25, 34)
    c.eye(39, 34)
    c.smile(32, 39, wide=True)
    c.blush(21, 38) if True else None
    p = c.P(21, 38); c.px(p[0], p[1], PINK)
    p = c.P(42, 38); c.px(p[0], p[1], PINK)
    if not c.small:
        c.px(p[0] + 1, p[1], PINK)
    # vertical plank seams
    if not c.small:
        c.line([(17, 29), (17, 44)], RUST[1])
        c.line([(47, 29), (47, 44)], RUST[1])

K.render_pal(fn, 'pl-smg-4', 'Railtrack Rattle', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-smg-4-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-smg-4.png')
