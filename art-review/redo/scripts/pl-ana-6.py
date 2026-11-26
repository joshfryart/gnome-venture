import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K

G = K
SNAKE = K.ramp('#6cbf3a')
BELLY = K.ramp('#c8e06a')
SPOT = '#2f6a2a'
BARK = K.ramp('#c8925a')
BARKD = '#5a3a22'
MOUTH = '#8e1f2a'
R = '/home/user/gnome-venture/'


def rrect(x0, y0, x1, y1):
    h = (y1 - y0) / 2
    return lambda x, y: K.rect(x0 + h, y0, x1 - h, y1)(x, y) or K.ell(x0 + h, y0 + h, h, h)(x, y) or K.ell(x1 - h, y0 + h, h, h)(x, y)


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(12, 22, 52, 54)
    tabR = K.knob('T', 'round', 52, 38, 1, 0, r=4.5 * k)
    tabB = K.knob('T', 'round', 28, 54, 0, 1, r=4.5 * k)
    blkL = K.knob('B', 'round', 12, 38, -1, 0, r=4.5 * k)
    head = K.ell(32, 12, 15, 6.5)
    neck = K.ell(20, 19, 8, 6)
    body = c.m(core, tabR, tabB, head, neck, minus=(blkL,))
    # bark trunk behind the coils; right tab is a bark knot
    bark = c.add(c.m(core, tabR, minus=(blkL,)) & body, BARK)
    coils = [(10, 21, 50, 31.5), (13, 34, 53, 44), (10, 46.5, 50, 56)]
    for i, (x0, y0, x1, y1) in enumerate(coils):
        m = c.m(rrect(x0, y0, x1, y1), tabB if i == 2 else (lambda x, y: False), minus=(blkL,)) & body
        c.add(m, SNAKE)
        c.edge(m, SPOT)
    allc = set()
    for (x0, y0, x1, y1) in coils:
        allc |= c.m(rrect(x0, y0, x1, y1))
    for (x, y) in bark - allc:
        if x % max(3, int(7 * c.k)) == 1 or (c.small and x % 4 == 1):
            c.px(x, y, BARKD)
    tw = 3.0 if c.small else 2.2
    tongue = c.m(K.thick_path([(46, 14), (54, 14)], tw), K.thick_path([(53, 14), (57, 11)], tw), K.thick_path([(53, 14), (57, 17)], tw))
    c.add(tongue, K.ramp('#d8322a'))
    hm = c.m(head, neck) & body
    c.add(hm, SNAKE)
    # anaconda spots: dark ovals
    spots = [(18, 25), (30, 27), (42, 25), (24, 38), (36, 40), (47, 37), (17, 50), (40, 51), (28, 60)]
    for (sx, sy) in spots:
        px, py = c.P(sx, sy)
        if c.small:
            c.px(px, py, SPOT); c.px(px + 1, py, SPOT)
        else:
            for dx in (-1, 0, 1, 2):
                for dy in (0, 1):
                    c.px(px + dx, py + dy, SPOT)
    if not c.small:
        for (x0, y0, x1, y1) in coils:
            c.line([(x0 + 7, y0 + 2.5), (x1 - 9, y0 + 2.5)], SNAKE[2])
    # face: eyes high on the long head, nostrils on the snout, huge grin
    c.eye(27, 9, disc=not c.small, look=(1, 0))
    c.eye(37, 9, disc=not c.small, look=(1, 0))
    nx, ny = c.P(45, 10)
    c.px(nx, ny, SPOT)
    gx0, gy = c.P(20, 14)
    gx1, _ = c.P(46, 14)
    for x in range(gx0 + 1, gx1):
        c.px(x, gy, K.UMBER)
        if gx0 + 2 < x < gx1 - 2:
            c.px(x, gy + 1, MOUTH)
        if not c.small and gx0 + 3 < x < gx1 - 3:
            c.px(x, gy + 2, K.UMBER)
    c.px(gx0, gy - 1, K.UMBER)
    c.px(gx1, gy - 1, K.UMBER)
    c.blush(21, 11)


rep = K.render_pal(fn, 'pl-ana-6', 'Big Grin Anaconda', '/home/user/gnome-venture/art-review/redo/out',
                   cellfile=R + 'art-review/redo/_src/pl-ana-6-cell.png', oldfile=R + 'game/assets/img/puzzles/pals/pl-ana-6.png')
print(rep)
