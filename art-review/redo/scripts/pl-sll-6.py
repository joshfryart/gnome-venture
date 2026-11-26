import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
# Fluffytail Snow Leopard: whimsy-fluffytail, peg. A snow-leopard loaf is the piece body: N peg blank = the dip between the ears,
# W peg blank in the flank, S peg tab = the two front paws, E side = a fat ringed fluffy tail curling up to a round tip.
# Cell 9-5: lavender ledge rock (#8e74a8 / #745c98) under pink sky (#f0b0b8); fur from the leopard (#ddd7d7).
FUR = ('#e4dee0', '#ab9fbb', '#f8f6f4')
LAVR = K.ramp('#745c98')
SPOT = '#5e4a82'
PINK = K.ramp('#f0b0b8')
PAW = ('#f4f0ec', '#b8acc4', '#ffffff')

def fn(c):
    k = 1.15 if c.small else 1.0
    core = lambda x, y: K.rect(8, 15, 46, 51)(x, y) and not (x < 11 and y > 48) 
    blankN = K.knob('B', 'peg', 27, 15, 0, -1, r=3.4 * k, nw=2.2)
    blankW = K.knob('B', 'peg', 8, 37, -1, 0, r=3.4 * k, nw=2.2)
    tabS = K.knob('T', 'peg', 25, 51, 0, 1, r=4.6 * k, nw=3.2)
    earL = K.poly([(8, 17), (10, 7), (20, 15)])
    earR = K.poly([(46, 17), (44, 7), (34, 15)])
    body = c.m(core, earL, earR, minus=(blankN, blankW))
    c.add(body, FUR, stitch=None)
    # tail: from bottom-right under the body, up the east side to a fluffy round tip
    tw = 9.5 if not c.small else 10.5
    tail = c.m(K.thick_path([(36, 51), (47, 51.5), (53.5, 46), (54.5, 36), (53, 27)], tw), K.ell(51.5, 21, 7.5, 7.5))
    c.add(tail, FUR)
    # tail rings in the ledge lavender
    for (x0, y0, x1, y1) in ((40, 44, 43.5, 62), (49, 39, 62, 42.5), (47, 30, 62, 33), (44, 20, 62, 22.5)):
        c.add(tail & c.m(K.rect(x0, y0, x1, y1)), LAVR)
    c.edge(tail, FUR[1])
    # paws (peg tab)
    paws = c.m(tabS, minus=(core,)) | (c.m(tabS) & c.m(K.rect(0, 49, 64, 52)))
    c.add(paws, PAW)
    if True:
        x = c.P(25, 0)[0]
        for y in range(c.P(0, 52)[1], c.P(0, 60)[1]):
            c.px(x, y, FUR[1])
    # inner ears pink
    c.add(c.m(K.poly([(11, 15), (12, 10.5), (17, 15)])), PINK)
    c.add(c.m(K.poly([(43, 15), (42, 10.5), (37, 15)])), PINK)
    # rosette spots on the flank (lavender ledge colour)
    for (sx, sy) in ((13, 43), (21, 46), (36, 45), (41, 39), (13, 22), (40, 21), (31, 24)):
        cx, cy = c.P(sx, sy)
        if c.small:
            c.px(cx, cy, SPOT); c.px(cx + 1, cy, SPOT)
        else:
            for d in ((0, 0), (1, 0), (-1, 1), (2, 1), (-1, 2), (2, 2), (0, 3)):
                c.px(cx + d[0], cy + d[1], SPOT)
    # face
    c.eye(19, 31, disc=False)
    c.eye(35, 31, disc=False)
    nx, ny = c.P(27, 36)
    for dx in ((-1, 0, 1, 2) if not c.small else (0, 1)):
        c.px(nx + dx, ny, '#d8788a')
    if not c.small:
        c.px(nx, ny + 1, '#d8788a'); c.px(nx + 1, ny + 1, '#d8788a')
    c.smile(27.5, 38.5, UMBER2 := '#4a2c1a')
    c.blush(15, 36)
    c.blush(38, 36)

K.render_pal(fn, 'pl-sll-6', 'Fluffytail Snow Leopard', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-sll-6-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-sll-6.png')
