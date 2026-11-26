import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K

WALL = K.ramp('#b48ca0')      # mauve wall of the cell
TRIM = K.ramp('#8a5a3a')      # timber trim
LEAF = K.ramp('#4f8f46')      # grass green
LEAF2 = K.ramp('#8cc45a')     # light grass
PINK = K.ramp('#ec8cb4')      # blossom
POT = K.ramp('#eeeaf2')       # white teapot


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(9, 18, 55, 57)
    top_blank = K.knob('B', 'peg', 32, 18, 0, -1, r=4.2 * k)
    lt = K.knob('T', 'peg', 9, 45, -1, 0, r=5.2 * k)
    rt = K.knob('T', 'peg', 55, 45, 1, 0, r=5.2 * k)
    # flower clumps puff above the top line, left and right of the blank
    blooms = [K.ell(16, 18, 6, 5), K.ell(25, 17, 5, 5), K.ell(40, 17, 5, 5), K.ell(48, 18, 6, 5)]
    body = c.m(core, lt, rt, *blooms, minus=(top_blank,))
    # foliage band
    c.add(c.m(lambda x, y: y < 34, minus=()) & body, LEAF)
    c.add(c.m(K.ell(14, 30, 4, 3), K.ell(50, 30, 4, 3), K.ell(22, 31, 3, 2.5), K.ell(43, 31, 3, 2.5)) & body, LEAF2)
    # flower heads (pink)
    fl = c.m(K.ell(15, 18, 4.2, 3.8), K.ell(25, 16, 3.8, 3.6), K.ell(40, 16, 3.8, 3.6), K.ell(49, 18, 4.2, 3.8),
             K.ell(19, 26, 3.4, 3), K.ell(45, 26, 3.4, 3)) & body
    c.add(fl, PINK)
    # box: mauve front with timber rim
    box = c.m(K.rect(9, 34, 55, 64)) & body
    c.add(box, WALL, stitch='#d8b8c8')
    rim = c.m(K.rect(5, 34, 59, 38)) & body
    c.add(rim, TRIM)
    c.add(c.m(K.rect(5, 53, 59, 64)) & body, TRIM)
    # side tabs = timber brackets; left one wears a little white teapot lid-knob
    c.add(c.m(K.rect(0, 34, 9, 64)) & body, POT)
    c.add(c.m(K.rect(55, 34, 64, 64)) & body, TRIM)
    if not c.small:
        c.px(*c.P(1, 43), '#7fd0e8'); c.px(*c.P(1, 47), '#7fd0e8')
    # flower centres
    for (x, y) in ((15, 18), (25, 16), (40, 16), (49, 18)):
        c.px(*c.P(x, y), '#f8d060')
    # water drops falling from the teapot spout
    c.eye(26, 44, disc=False)
    c.eye(38, 44, disc=False)
    c.smile(32, 49)
    c.blush(21, 48)
    c.blush(42, 48)


K.render_pal(fn, 'pl-thch-2', 'Sill Sprinkle', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-thch-2-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-thch-2.png')
