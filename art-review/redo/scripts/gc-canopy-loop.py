# Canopy Loop: a monkey that IS an inner piece (4 keyhole blanks); arms up gripping canopy leaves, feet below,
# tail curled into a loop, rainbow scarf; bridge-wood browns + rainbow from cell 5-1.
import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K

FUR = K.ramp('#8a5a2e')
FACE = K.ramp('#e0b88a')
LEAF = K.ramp('#3f9a4a')
RB = ['#d8402a', '#ee8a2a', '#f0d040', '#4aa040', '#3a78c8']


def fn(c):
    s = 1.15 if c.small else 1.0
    r = 4.5 * s
    blanks = (K.knob('B', 'keyhole', 32, 12, 0, -1, r=r), K.knob('B', 'keyhole', 10, 34, -1, 0, r=r),
              K.knob('B', 'keyhole', 54, 34, 1, 0, r=r), K.knob('B', 'keyhole', 32, 55, 0, 1, r=r))
    core = K.poly([(13, 12), (51, 12), (54, 15), (54, 52), (51, 55), (13, 55), (10, 52), (10, 15)])
    tail = K.thick_path([(50, 50), (56, 50), (60, 46), (60, 41), (57, 38), (53, 39), (52, 43), (55, 45)], 3.4 if c.small else 2.8)
    c.add(c.m(core, tail, minus=blanks), FUR, stitch='#b07a40')
    # leaf tufts gripped by the raised hands (top corners), canopy green
    lv = c.add(c.m(K.ell(14, 9, 6, 4), K.ell(9, 13, 3.5, 4.5), K.ell(50, 9, 6, 4), K.ell(55, 13, 3.5, 4.5)), LEAF)
    # hands (tan) over the leaves
    c.add(c.m(K.ell(16, 15, 4, 3.4), K.ell(48, 15, 4, 3.4), minus=blanks), FACE)
    # feet (tan) at the bottom corners
    feet = c.add(c.m(K.ell(17, 53, 5, 3.2), K.ell(47, 53, 5, 3.2), minus=blanks), FACE)
    # face mask: heart of two eye discs + muzzle
    face = c.add(c.m(K.ell(28, 29.5, 5.6, 5.4), K.ell(36, 29.5, 5.6, 5.4), K.ell(32, 35.5, 7.6, 4.8)), FACE)
    c.edge(face, FUR[1])
    # rainbow scarf across the chest
    for i, col in enumerate(RB):
        y0 = 39.5 + i * (1.6 if not c.small else 1.8)
        band = c.m(K.rect(18, y0, 46, y0 + (1.6 if not c.small else 1.8)), minus=blanks)
        for p in band:
            c.px(p[0], p[1], col)
    c.eye(28, 29.5)
    c.eye(36, 29.5)
    nx, ny = c.P(32, 34.5)
    c.px(nx - 1, ny, FUR[1]); c.px(nx + 1, ny, FUR[1])
    c.smile(32, 36.5)
    if not c.small:
        c.blush(24.5, 35); c.blush(38.5, 35)


K.render_pal(fn, 'gc-canopy-loop', 'Canopy Loop', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/gc-canopy-loop-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/gc-canopy-loop.png')
