import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K

MOON = K.ramp('#f6e8b8')
SHADE = ('#b8b4d8', '#8a86b8', '#d4d0ec')
CRATER = '#d8c48e'
NAVY = K.ramp('#3a3f7a')
STAR = '#fff4c8'


def fn(c):
    s = 1.15 if c.small else 1.0
    R = 16
    x0, y0, x1, y1 = 10, 14, 54, 56
    core = [K.rect(x0 + R, y0, x1 - R, y1), K.rect(x0, y0 + R, x1, y1 - 6),
            K.ell(x0 + R, y0 + R, R, R), K.ell(x1 - R, y0 + R, R, R),
            K.rect(x0 + 6, y0 + R, x1 - 6, y1), K.ell(x0 + 6, y1 - 6, 6, 6), K.ell(x1 - 6, y1 - 6, 6, 6)]
    tab = K.knob('T', 'hook', 30, y0 + 0.5, 0, -1, r=5.6 * s, nw=3.0 * s)
    bl = K.knob('B', 'hook', x0, 37, -1, 0, r=4.3 * s, nw=2.4 * s)
    br = K.knob('B', 'hook', x1, 37, 1, 0, r=4.3 * s, nw=2.4 * s, flip=True)
    body = c.m(*core, tab, minus=(bl, br))
    c.add(body, MOON)
    # moon phase: navy night side on the right (the picture's sky), cream lit side left
    lit = K.ell(22, 35, 22, 34)
    sh = c.m(*core, minus=(bl, br, lit))
    c.add(sh, NAVY)
    # craters: round pits, dark rim lower right
    for (cx, cy, r) in ((19, 49, 3.4), (34, 50, 2.4), (16, 22, 2.6)):
        k = 1.25 if c.small else 1
        m = c.m(K.ell(cx, cy, r * k, r * k)) & body
        m -= sh
        for p in m:
            c.px(p[0], p[1], CRATER)
        if not c.small:
            for (x, y) in m:
                if (x + 1, y + 1) not in m:
                    c.px(x, y, '#b8a070')
    # star flecks on the night side (the cell's star)
    for (sx, sy, big) in ((46, 24, True), (48, 49, False)):
        X, Y = c.P(sx, sy)
        c.px(X, Y, STAR)
        if big and not c.small:
            for d in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                c.px(X + d[0], Y + d[1], STAR)
    # face on the lit side, away from the terminator
    c.eye(24, 29)
    c.eye(34, 29)
    c.smile(29, 35)
    c.blush(21, 34)
    c.blush(37, 34)
    sx, sy = c.P(22, 19)
    c.px(sx, sy, '#ffffff')

K.render_pal(fn, 'pl-owl-2', 'Nightglow Fleck', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-owl-2-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-owl-2.png')
