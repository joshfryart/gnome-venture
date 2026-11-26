import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
# Fang Chip: an ivory wolf fang as a corner piece. Flat top (grey-blue fur gum from cell 6-4) and flat left side,
# hook tab on the right side, the fang tip curls into a hook tab at the bottom; a chip bitten out of the lower left.
FUR = K.ramp('#7078a8')
FURD = K.ramp('#3c3c6c')
IVORY = ('#ece6d4', '#b4aec4', '#fbf8ee')

def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.poly([(9, 8), (54, 8), (54, 28), (33, 54), (29, 54), (9, 30)])
    tab_r = K.knob('T', 'hook', 54, 22, 1, 0, r=4.8 * k)
    tab_b = K.knob('T', 'hook', 31, 52, 0, 1, r=4.8 * k, nw=2.8, flip=True)
    chip = K.poly([(12, 30), (19, 36), (14, 42), (6, 36)])
    body = c.m(core, tab_r, tab_b, minus=(chip,))
    c.add(body, IVORY, stitch=None if c.small else '#c9c3d8')
    gum = c.m(K.rect(0, 0, 70, 19), K.ell(20, 19, 7, 3.5), K.ell(43, 19, 7, 3.5))
    gum &= body
    c.add(gum, FUR)
    # fur flecks from the cell
    for (x, y) in [(14, 12), (24, 10), (33, 14), (44, 11), (50, 15), (19, 16), (38, 17)]:
        px = c.P(x, y)
        c.px(px[0], px[1], FURD[0])
        if not c.small:
            c.px(px[0] + 1, px[1], FURD[0])
    c.edge(gum, FURD[0])
    # chip crack line
    c.line([(20, 37), (24, 35)], '#b4aec4')
    # enamel shine streak (tooth cue)
    c.add(c.m(thin_shine := K.thick_path([(14, 22), (14, 27)], 2.8)) & body, ('#fbf8ee', '#fbf8ee', '#ffffff'))
    # face: grumpy moon-growl
    c.eye(25, 29)
    c.eye(39, 29)
    cx, cy = c.P(32, 36)
    zig = [(-4, 0), (-3, 1), (-2, 0), (-1, 1), (0, 0), (1, 1), (2, 0), (3, 1), (4, 0)] if not c.small else [(-2, 0), (-1, 1), (0, 0), (1, 1), (2, 0)]
    for dx, dy in zig:
        c.px(cx + dx, cy + dy, K.UMBER)
    # angry brows
    for ex, s_ in ((25, 1), (39, -1)):
        bx, by = c.P(ex, 25)
        rng = (-2, -1, 0, 1) if not c.small else (-1, 0)
        for i, dx in enumerate(rng):
            c.px(bx + dx, by + (i if s_ > 0 else len(rng) - 1 - i) // (2 if c.small else 1) - (0 if c.small else 1), K.UMBER)
    # little crescent moon on the fur
    mx, my = c.P(46, 12)
    for (dx, dy) in ([(0, 0), (0, 1), (1, 2), (1, -1)] if c.small else [(0, 0), (0, 1), (0, 2), (1, 3), (1, -1), (2, 3), (2, -1)]):
        c.px(mx + dx, my + dy, '#f4f0c8')

K.render_pal(fn, 'pl-gwk-1', 'Fang Chip', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-gwk-1-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-gwk-1.png')
