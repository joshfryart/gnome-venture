import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
# Windmill Whirl: inner-TTTT peg. Slate-blue stone windmill cap is the square core; four cream sail blades run
# from the brown hub out to all four sides and each blade ends in a peg tab (the sail tip). Colours from cell 11-2.
STONE = K.ramp('#8a9cc4')
STONE2 = K.ramp('#6c7ea8')
SAIL = K.ramp('#f2d27a')
HUB = K.ramp('#a8703a')
SPAR = '#7a4a1f'

def fn(c):
    k = 1.15 if c.small else 1.0
    r = 6.0 * k
    nw = 2.4 * k      # narrow neck so each sail tip pops out as a clear peg tab
    L, T, R, B = 13, 13, 51, 51
    core = K.rect(L, T, R, B)
    corner_round = [K.rect(L, T, L + 2, T + 2), K.rect(R - 2, T, R, T + 2), K.rect(L, B - 2, L + 2, B), K.rect(R - 2, B - 2, R, B)]
    tabs = [K.knob('T', 'peg', 32, T, 0, -1, r=r, nw=nw), K.knob('T', 'peg', 32, B, 0, 1, r=r, nw=nw),
            K.knob('T', 'peg', L, 32, -1, 0, r=r, nw=nw), K.knob('T', 'peg', R, 32, 1, 0, r=r, nw=nw)]
    body = c.m(core, minus=corner_round)
    c.add(body, STONE)
    # stone courses: darker lower band
    c.add(c.m(K.rect(L, 40, R, B), minus=corner_round), STONE2)
    hw = 4.6
    # pegs are the stone tabs; the four sails are an X like the cell, lattice blades from hub to the corners
    c.add(c.m(*tabs), STONE)
    sw = 9.0
    sails = c.m(K.thick_path([(L + 1.5, T + 1.5), (R - 1.5, B - 1.5)], sw), K.thick_path([(R - 1.5, T + 1.5), (L + 1.5, B - 1.5)], sw), minus=corner_round)
    c.add(sails, SAIL)
    c.edge(sails, SPAR)
    hub = c.m(K.ell(32, 32, 8.5, 8.5))
    c.add(hub, HUB)
    c.edge(hub, K.UMBER2)
    for (ax, ay, bx, by) in ((L + 2, T + 2, 26, 26), (R - 2, T + 2, 38, 26), (L + 2, B - 2, 26, 38), (R - 2, B - 2, 38, 38)):
        c.line([(ax, ay), (bx, by)], SPAR)
    if not c.small:
        for t in (0.3, 0.55, 0.8):
            for (sx, sy) in ((-1, -1), (1, -1), (-1, 1), (1, 1)):
                d = 8.5 + t * 16
                mx, my = 32 + sx * d / 1.414, 32 + sy * d / 1.414
                c.line([(mx - sx * 2.8, my + sy * 2.8), (mx + sx * 2.8, my - sy * 2.8)], SPAR)
    # windows on the stone quadrants
    for (wx, wy) in ((32, 46), (32, 18)):
        x0, y0 = c.P(wx - 2, wy - 2)
        x1, y1 = c.P(wx + 2, wy + 3)
        for x in range(x0, x1):
            for y in range(y0, y1):
                c.px(x, y, '#f0c060' if (x + y) % 3 else '#c88a2a')
    # face on hub
    c.eye(28.5, 31, disc=True)
    c.eye(35.5, 31, disc=True)
    c.smile(32, 35.5, col=K.CREAM)
    c.blush(25.5, 35)
    c.blush(37.5, 35)

print(K.render_pal(fn, 'pl-gaun-4', 'Windmill Whirl', '/home/user/gnome-venture/art-review/redo/out',
                   cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-gaun-4-cell.png',
                   oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-gaun-4.png'))
