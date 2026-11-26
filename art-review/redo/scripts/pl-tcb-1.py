import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K

# Dawnleaf Drift: an orange walnut leaf that IS a corner piece (flat left + bottom, stem at the bottom-left corner),
# round tabs on the top and right sides, leaf tip at the top-right; it rests on a bridge plank (cell 6-4 planks + canopy green).
LEAF = K.ramp('#e07a2a')
LEAFDK = K.ramp('#b85420')
PLANK = K.ramp('#9a5a30')
PLANKDK = '#5a2e20'
GREEN = K.ramp('#6cc070')
RIB = '#8a3a18'


def fn(c):
    s = 1.15 if c.small else 1.0
    # leaf blade: square core with big rounded top-left and bottom-right corners -> lens along the diagonal
    sq = K.rect(7, 9, 53, 50)
    def blade(x, y):
        if not sq(x, y):
            return False
        if x < 25 and y < 27 and (x - 25) ** 2 + (y - 27) ** 2 > 18 ** 2:
            return False
        if x > 39 and y > 38 and (x - 39) ** 2 + (y - 38) ** 2 > 14 ** 2:
            return False
        return True
    top = K.knob('T', 'round', 29, 9, 0, -1, r=4.5 * s)
    tip = K.poly([(36, 9.5), (59, 3), (52.5, 26)])
    right = K.knob('T', 'round', 53, 33, 1, 0, r=4.5 * s)
    plank = K.rect(5, 46, 59, 57)
    leaf = c.m(blade, top, right, tip)
    c.add(c.m(plank), PLANK)
    c.add(leaf, LEAF, stitch='#f6b070')
    # green canopy sprig on the plank, right end
    c.add(c.m(K.ell(53, 46, 5, 3.6), K.ell(48, 47.5, 3.5, 2.6)), GREEN)
    # plank grain
    for y in (51, 54):
        if not c.small or y == 51:
            c.line([(7, y), (57, y)], PLANKDK)
    if not c.small:
        c.line([(9, 48), (20, 48)], '#d8964e')
        c.line([(30, 52), (44, 52)], '#d8964e')
    c.edge(c.m(plank), PLANKDK)
    # midrib from stem (bottom-left) to tip (top-right) and veins
    w = 2.6 if c.small else 1.8
    rib = c.m(K.thick_path([(5, 52), (13, 44), (55, 6)], w))
    c.add(rib & (leaf | c.m(K.rect(3, 40, 16, 57))), (RIB, RIB, RIB))
    if not c.small:
        for a, b in (((22, 36), (16, 28)), ((32, 27), (27, 17)), ((42, 18), (40, 11)), ((42, 18), (50, 21)),
                     ((22, 36), (32, 41)), ((32, 27), (43, 31))):
            c.line([a, b], LEAFDK[0])
    # face below the midrib, on the calm lower-right lobe
    c.eye(30, 37)
    c.eye(40, 32 if not c.small else 31)
    c.smile(36, 40 if not c.small else 39)
    c.blush(26, 41)


K.render_pal(fn, 'pl-tcb-1', 'Dawnleaf Drift', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-tcb-1-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-tcb-1.png')
