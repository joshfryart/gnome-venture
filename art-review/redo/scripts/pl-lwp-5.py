import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K

RED = K.ramp('#d0402c')      # watchtower red
TEAL = K.ramp('#2f9a8c')     # pagoda roof teal
GOLD = K.ramp('#f0c040')     # tower windows
BRICK = '#a8505a'            # wall brick, for ribs
CELL = '/home/user/gnome-venture/art-review/redo/_src/pl-lwp-5-cell.png'
OLD = '/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-lwp-5.png'


def fn(c):
    k = 1.15 if c.small else 1.0
    blanks = (K.knob('B', 'peg', 32, 7, 0, -1, r=3.2 * k),
              K.knob('B', 'peg', 32, 55, 0, 1, r=3.2 * k),
              K.knob('B', 'peg', 7, 32, -1, 0, r=3.2 * k),
              K.knob('B', 'peg', 57, 32, 1, 0, r=3.2 * k))
    # lantern body: bulging paper drum
    body = K.ell(32, 32, 26, 21)
    drum = K.rect(15, 13, 49, 51)
    # pagoda cap with upturned eaves, and base band
    cap = K.poly([(5, 15), (9, 9), (16, 6), (48, 6), (55, 9), (59, 15), (52, 14), (12, 14)])
    base = K.poly([(12, 51), (52, 51), (49, 55), (15, 55)])
    sil = c.m(body, drum, cap, base, minus=blanks)
    c.add(sil, RED)
    capm = c.m(cap, minus=blanks)
    c.add(capm, TEAL)
    basem = c.m(base, minus=blanks)
    c.add(basem, TEAL)
    # gold trims under cap / over base
    c.add(c.m(K.rect(12, 14, 52, 16.5), minus=blanks), GOLD)
    c.add(c.m(K.rect(13, 49, 51, 51), minus=blanks), GOLD)
    # ribs (curved vertical lines of the paper lantern)
    if not c.small:
        for xs in ((24, 19, 24), (40, 45, 40), (17, 10, 17), (47, 54, 47)):
            c.line([(xs[0], 17), (xs[1], 32), (xs[2], 47)], RED[1])
    else:
        c.line([(19, 18), (17, 32), (19, 46)], RED[1])
        c.line([(45, 18), (47, 32), (45, 46)], RED[1])
    # glowing heart behind face
    glow = c.m(K.ell(32, 34, 8, 8), K.poly([(26, 31), (32, 20), (38, 31)]))
    c.edge(glow, GOLD[0])
    for p in glow:
        if p not in c.over:
            pass
    c.add(glow, ('#f4a040', '#e07a30', '#f8d070'))
    c.eye(28, 31)
    c.eye(36.5, 31)
    c.smile(32, 36)
    c.blush(25, 36)
    c.blush(38.5, 36)


K.render_pal(fn, 'pl-lwp-5', 'Galeswing Lantern', '/home/user/gnome-venture/art-review/redo/out', cellfile=CELL, oldfile=OLD)
