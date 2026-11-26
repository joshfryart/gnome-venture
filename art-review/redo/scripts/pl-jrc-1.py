import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
# Rosette Nub: a jaguar-cub rosette that is a corner-BB piece. Left + bottom flat (bottom = the grey stone plinth from cell 6-6),
# round blank on top (between the ears) and on the right flank. Orange fur with dark rosettes; plinth lavender-grey; cave purple spots.
FUR = K.ramp('#e8922a')
CREAMF = K.ramp('#f6dcaa')
STONE = K.ramp('#a49cbc')
SPOT = '#4a2e36'
SPOTIN = '#b8641c'
PINK = K.ramp('#e89aa0')
R = 'cave'

def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(8, 14, 56, 56)
    earL, earR = K.ell(17, 15, 8, 8), K.ell(47, 15, 8, 8)
    bT = K.knob('B', 'round', 32, 14, 0, -1, r=4.5 * k)
    bR = K.knob('B', 'round', 56, 33, 1, 0, r=4.5 * k)
    body = c.m(core, earL, earR, minus=(bT, bR))
    c.add(body, FUR)
    # inner ears
    c.add(c.m(K.ell(16, 15, 3.6, 3.6)) & body, PINK)
    c.add(c.m(K.ell(48, 15, 3.6, 3.6)) & body, PINK)
    # stone plinth (flat bottom side)
    pl = c.m(K.rect(8, 48, 56, 56)) & body
    c.add(pl, STONE)
    c.edge(pl, STONE[1])
    # muzzle
    mz = c.m(K.ell(30, 35, 8, 5.5)) & body
    c.add(mz, CREAMF)
    # rosettes: dark ring with a deeper-orange centre
    for (x, y, rr) in ((14, 40, 5.4), (45, 43, 4.8), (13, 26, 4.0), (29, 45, 3.4), (50, 25, 3.6)):
        ring = c.m(K.ell(x, y, rr, rr)) & body
        inner = c.m(K.ell(x, y, rr - 2.0, rr - 2.0)) & body
        inner -= pl; ring -= pl; ring -= mz
        for p in ring - inner:
            if ((p[0] * 7 + p[1] * 3) % 5) != 0 or c.small:
                c.px(p[0], p[1], SPOT)
        for p in inner:
            c.px(p[0], p[1], SPOTIN)
    c.eye(23, 28)
    c.eye(37, 28)
    nx, ny = c.P(30, 32)
    for dx in ((-1, 0, 1) if not c.small else (0, 1)):
        c.px(nx + dx, ny, PINK[1])
    c.smile(30, 35)
    c.blush(19, 33)
    c.blush(40, 33)

K.render_pal(fn, 'pl-jrc-1', 'Rosette Nub', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-jrc-1-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-jrc-1.png')
