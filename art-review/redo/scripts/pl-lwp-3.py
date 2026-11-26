import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
"""pl-lwp-3 Autumn Flutter: inner-TBTB, tri. An orange autumn leaf that IS the piece: N tri tab = the leaf's pointed tip,
S tri tab = the stalk, tri blanks E + W bite into the leaf's sides like lobe notches. A sky-blue/mist gust ribbon (cell 1-2 sky and
hill haze) curls across it. Orange from the picture's autumn bushes."""
LEAF = K.ramp('#ea9b4c')
VEIN = '#b8602a'
STALK = K.ramp('#8a5a30')
GUST = K.ramp('#a8d0e4')
MIST = K.ramp('#c8dcd8')


def fn(c):
    k = 1.15 if c.small else 1.0
    # broad rounded leaf core, eased corners, slightly narrowing to the top
    core = K.poly([(15, 18), (23, 12), (41, 12), (49, 18), (52, 30), (51, 45), (45, 51), (19, 51), (13, 45), (12, 30)])
    tabN = K.knob('T', 'tri', 32, 12.5, 0, -1, r=5.0 * k)
    tabS = K.knob('T', 'tri', 32, 50.5, 0, 1, r=4.0 * k, nw=2.2)
    blankE = K.knob('B', 'tri', 51.8, 27, 1, 0, r=3.6 * k)
    blankW = K.knob('B', 'tri', 12.2, 27, -1, 0, r=3.6 * k)
    leaf = c.m(core, tabN, minus=(blankE, blankW))
    c.add(leaf, LEAF, stitch=None if c.small else '#f5c88a')
    c.add(c.m(tabS, minus=(core,)), STALK)
    # veins: midrib (stops above the face) + upper side veins
    w = 2.0 if not c.small else 2.6
    V = (VEIN, VEIN, VEIN)
    c.add(c.m(K.thick_path([(32, 30), (32, 6)], w)) & leaf, V)
    c.add(c.m(K.thick_path([(32, 46), (32, 56)], w)) & leaf, V)
    for side in (-1, 1):
        c.add(c.m(K.thick_path([(32, 26), (32 + side * 12, 17)], w * 0.8)) & leaf, V)
    # gust ribbon: a thin sky-blue wind band along the lower body, curling out past the W edge
    gw = 3.2 if not c.small else 3.8
    gust = c.m(K.thick_path([(4, 36), (7, 41), (14, 44), (24, 45), (34, 46.5), (44, 45), (53, 41)], gw))
    c.add(gust, GUST)
    c.add(c.m(K.thick_path([(3, 51), (9, 50), (15, 51)], 2.8 if not c.small else 3.0)), MIST)
    # face in the calm middle, between the two blanks' depth and the gust
    c.eye(25.5, 35, disc=False)
    c.eye(38.5, 35, disc=False)
    c.smile(32, 39.5)
    c.blush(21, 39)
    c.blush(42, 39)


K.render_pal(fn, 'pl-lwp-3', 'Autumn Flutter', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-lwp-3-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-lwp-3.png')
