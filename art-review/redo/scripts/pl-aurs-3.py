import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
"""Dock Creak: inner-TBTB peg. A lake-dock section of three planks: peg tabs W/E are plank ends poking out, the S blank sits
between two dock pilings, the N blank bites into a snow cap. Log-pile tans + plum gaps + snow from cell 6-6."""

WOOD = K.ramp('#d08852')
WOODL = K.ramp('#e8a868')
WOODD = K.ramp('#b8683c')
POST = K.ramp('#84403c')
SNOW = ('#e0eaf8', '#a8b8d8', '#f8fcff')
GAP = '#5a2c3a'


def fn(c):
    s = 1.15 if c.small else 1.0
    core = K.rect(11, 13, 53, 51)
    tabW = K.knob('T', 'peg', 11, 32, -1, 0, r=4.0 * s)
    tabE = K.knob('T', 'peg', 53, 32, 1, 0, r=4.0 * s)
    blankN = K.knob('B', 'peg', 32, 13, 0, -1, r=3.4 * s)
    # pilings below the deck; the S blank is the gap between them
    posts = (K.rect(13, 50, 20, 56), K.rect(44, 50, 51, 56))
    blankS = K.knob('B', 'peg', 32, 51, 0, 1, r=3.4 * s)
    body = c.m(core, tabW, tabE, *posts, minus=(blankN, blankS))
    # planks: three bands, each a different tan
    bands = [(13, 26, WOODL), (26, 39, WOOD), (39, 51, WOODD)]
    for y0, y1, rp in bands:
        m = body & c.m(K.rect(0, y0, 64, y1))
        c.add(m, rp)
        c.edge(m, GAP)
    for p in posts:
        m = body & c.m(K.rect(0, 51, 64, 64), p)
        c.add(m, POST)
    # snow cap on the top plank, drifting over the N blank
    snow = body & c.m(lambda x, y: y < 17 + (1.4 if (x // 5) % 2 else 0) and 9 <= x <= 55)
    c.add(snow, SNOW)
    # butt joints: each plank row is made of boards, staggered like a real dock
    for y0, y1, xs in ((17, 26, (44,)), (26, 39, ()), (39, 51, (26,))):
        for xj in xs:
            c.line([(xj, y0 + 0.5), (xj, y1 - 1)], GAP)
            px, py = c.P(xj - 2, (y0 + y1) / 2)
            c.px(px, py, K.UMBER2)
            px, py = c.P(xj + 2.2, (y0 + y1) / 2)
            c.px(px, py, K.UMBER2)
    # nails at the plank ends
    for ny in (21, 32, 45):
        for nx in (14.5, 49.5):
            px, py = c.P(nx, ny)
            c.px(px, py, K.UMBER2)
    # wood grain (64 only)
    if not c.small:
        for y0, x0, x1 in ((22, 20, 30), (36, 36, 46), (47, 22, 34)):
            c.line([(x0, y0), (x1, y0)], '#b8683c' if y0 != 44 else '#8e4c2a')
        # piling rings
        for px0 in ():
            pass
    c.eye(24, 30, look=(0, 0))
    c.eye(40, 30, look=(0, 0))
    c.smile(32, 35, wide=not c.small)
    c.blush(19, 34)
    c.blush(44, 34)


K.render_pal(fn, 'pl-aurs-3', 'Dock Creak', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-aurs-3-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-aurs-3.png')
