import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
# Frond Nod: a palm frond that is an edge piece. Flat left side, brown stem = peg tab at the bottom,
# leaflet tip = peg tab on the right, peg blank at the top. Frond green + lime rib (the frond in the cell),
# sunset orange / pink-cloud tints from the picture on the tips and stitch.
R = '/home/user/gnome-venture/'
LEAF = ('#3f8a3a', '#2a6030', '#f0b860')   # frond green, rim light in sunset gold
DARK = '#24502a'
RIB = ('#a8cc4a', '#7a9a36', '#e8e890')
STEM = K.ramp('#9a6a34')


def ribx(y):
    # rib x at height y: straight from the stem, nodding to the top-right
    if y > 40:
        return 31 + (52 - y) / 12
    return 32 + (40 - y) * 0.55 + max(0, 28 - y) * 0.35


def fn(c):
    S = 1.15 if c.small else 1.0
    x0, y0, x1, y1 = 10, 10, 52, 50
    core = K.rect(x0, y0, x1, y1)
    t_r = K.knob('T', 'peg', x1, 31, 1, 0, r=4.5 * S)
    t_b = K.knob('T', 'peg', 31, y1, 0, 1, r=4.5 * S)
    b_t = K.knob('B', 'peg', 26, y0, 0, -1, r=5.0 * S)
    # leaflet tips: V notches on the top edge and the upper right edge
    notches = []
    for nx in (44,):
        notches.append(K.poly([(nx - 3, y0 - 1), (nx + 3, y0 - 1), (nx, y0 + 5)]))
    for ny in (18, 44):
        notches.append(K.poly([(x1 + 1, ny - 3), (x1 + 1, ny + 3), (x1 - 5, ny)]))
    body = c.m(core, t_r, minus=[b_t] + notches)
    c.add(body, LEAF)
    c.add(c.m(t_b), STEM)
    # sunset glow on the frond's nodding tip (the orange / pink sky behind it in the picture)
    c.add(c.m(lambda x, y: x - y > 32) & body, ('#e88a4a', '#b85a3a', '#f8c080'))
    c.add(c.m(lambda x, y: 24 < x - y <= 32) & body, ('#9a9a40', '#6a7030', '#e0c070'))
    calm = K.ell(21, 31, 9, 7)
    w = 2.4 if c.small else 1.6

    def gap(x, y):
        if calm(x, y):
            return False
        rx = ribx(y)
        if abs(x - rx) < 2:
            return False
        s = (y + 0.7 * x) if x < rx else (y - 0.7 * x)
        return (s % 7) < w
    c.edge(set(), DARK)
    for p in c.m(gap) & body:
        c.px(p[0], p[1], DARK)
    rib = [(ribx(y), y) for y in (52, 46, 40, 34, 28, 22, 16, 12)]
    c.add(c.m(K.thick_path(rib, 3.0 if c.small else 2.4)), RIB)
    c.eye(17, 30)
    c.eye(25, 30)
    c.smile(21, 35)
    c.blush(14, 34)
    c.blush(28, 34)


K.render_pal(fn, 'pl-drft-2', 'Frond Nod', R + 'art-review/redo/out',
             cellfile=R + 'art-review/redo/_src/pl-drft-2-cell.png',
             oldfile=R + 'game/assets/img/puzzles/pals/pl-drft-2.png')
