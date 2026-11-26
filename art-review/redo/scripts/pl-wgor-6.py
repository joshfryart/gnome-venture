import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
# Frowny Silverback: whimsy-gorilla, keyhole knobs. A seated silverback whose squat square body IS the piece:
# head + crest break out N, keyhole TAB E = the orange fruit he holds out, keyhole BLANK W into his arm, keyhole BLANK S between his legs.
# Slate-violet fur, silver saddle, mauve face, orange fruit and bamboo-green leaf from the glade picture (cell 7-3 bamboo greens).
FUR = ('#5a4c68', '#3a2e49', '#8a7c9c')
FUR2 = K.ramp('#4a3d5a')
SILVER = ('#cfcade', '#9e98b4', '#ecebf4')
FACE = ('#8a7078', '#5e4a52', '#b0969c')
FRUIT = ('#f0883a', '#cb602b', '#f8b070')
LEAF = K.ramp('#5aa880')
D = K.UMBER


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(10, 31, 54, 58)
    shoulders = K.ell(32, 33, 22.5, 11)
    head = K.ell(32, 21, 9.5, 9)
    crest = K.ell(32, 13.5, 6, 5)
    tabE = K.knob('T', 'keyhole', 54, 43, 1, 0, r=4.6 * k)
    blankW = K.knob('B', 'keyhole', 10, 43, -1, 0, r=3.8 * k)
    blankS = K.knob('B', 'keyhole', 32, 58, 0, 1, r=3.8 * k)
    body = c.m(core, shoulders, minus=(blankW, blankS))
    c.add(body, FUR)
    # arms: darker long arms down both sides, knuckles on the ground
    armL = c.m(K.ell(15.5, 44, 6.2, 15), minus=(blankW, blankS)) & body
    armR = c.m(K.ell(48.5, 44, 6.2, 15)) & body
    c.add(armL, FUR2)
    c.add(armR, FUR2)
    c.edge(armL, FUR[1])
    c.edge(armR, FUR[1])
    # silver saddle across the shoulders
    sad = c.m(K.ell(32, 29.5, 15, 4.5)) & body
    c.add(sad, SILVER)
    # chest plate (the round chest in the picture)
    chest = c.m(K.ell(32, 46, 9, 8), minus=(blankS,))
    c.add(chest, K.ramp('#6e6088'))
    c.edge(chest, FUR[1])
    # head + crest
    c.add(c.m(K.ell(22.3, 21.5, 2.4, 2.8), K.ell(41.7, 21.5, 2.4, 2.8)), FACE)
    hd = c.m(head, crest)
    c.add(hd, FUR)
    face = c.m(K.ell(32, 22.5, 7, 6))
    c.add(face, FACE)
    # fruit tab
    fr = c.m(tabE, minus=(core, K.ell(48.5, 44, 6.2, 15)))
    c.add(fr, FUR2)
    fx = 54 + 4.6 * k + 2.1
    c.add(fr & c.m(K.ell(fx, 43, 4.0 * k, 4.0 * k)), FRUIT)
    lx, ly = c.P(fx, 38.2)
    if c.small:
        for p in ((lx, ly), (lx + 1, ly), (lx, ly + 1)):
            c.px(*p, LEAF[0])
    else:
        for p in ((lx, ly), (lx + 1, ly), (lx + 1, ly - 1), (lx, ly + 1), (lx - 1, ly + 1)):
            c.px(*p, LEAF[0])
    # face: stern heavy brow, eyes, nostrils, frown
    if c.small:
        bx, by = c.P(32, 19)
        for dx in range(-4, 5):
            c.px(bx + dx, by - (1 if abs(dx) <= 1 else 0), D)
        c.eye(29.5, 22)
        c.eye(34.5, 22)
        mx, my = c.P(32, 26.5)
        for dx in (-1, 0):
            c.px(mx + dx, my, D)
        c.px(mx - 2, my + 1, D)
        c.px(mx + 1, my + 1, D)
    else:
        bx, by = c.P(32, 18.5)
        for dx in range(-6, 7):
            c.px(bx + dx, by + (0 if abs(dx) > 1 else -1) + (1 if abs(dx) >= 5 else 0), D)
            c.px(bx + dx, by + 1 + (0 if abs(dx) > 1 else -1) + (1 if abs(dx) >= 5 else 0), FUR[1]) if abs(dx) < 6 else None
        c.eye(28.5, 22)
        c.eye(35.5, 22)
        nx, ny = c.P(32, 24.5)
        c.px(nx - 1, ny, FACE[1]); c.px(nx + 1, ny, FACE[1])
        mx, my = c.P(32, 27)
        for dx in range(-1, 2):
            c.px(mx + dx, my, D)
        c.px(mx - 2, my + 1, D)
        c.px(mx + 2, my + 1, D)
        # knuckles
        for ax in (12, 49):
            x0, y0 = c.P(ax, 56)
            for i in range(0, 5, 2):
                c.px(x0 + i, y0, FUR[1])


K.render_pal(fn, 'pl-wgor-6', 'Frowny Silverback', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wgor-6-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wgor-6.png')
