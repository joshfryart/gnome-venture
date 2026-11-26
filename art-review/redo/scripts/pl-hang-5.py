import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
# Vine Curtain Gateway: inner-BBBB double knobs. A tan stone arch gateway (hanging-garden ruins) capped by two green bush humps
# (cell 5-1 bush), the top blank splitting the canopy; a dark arched doorway with a pair of vines dangling either side and a face
# peeking out; the bottom blank opens under the doorway like the gate's way through.
STONE = K.ramp('#d4c094')
ARCH = K.ramp('#5c4a5e')
BUSH = K.ramp('#4f9e3c')
VINE = K.ramp('#7cc850')
FLOWER = '#f8eec0'

def fn(c):
    s = 1.15 if c.small else 1.0
    r = 4.6 * s
    core = K.rect(8, 9, 56, 56)
    blanks = (K.knob('B', 'double', 32, 9, 0, -1, r=r), K.knob('B', 'double', 32, 56, 0, 1, r=r),
              K.knob('B', 'double', 8, 33, -1, 0, r=r), K.knob('B', 'double', 56, 33, 1, 0, r=r))
    body = c.m(core, minus=blanks)
    c.add(body, STONE, stitch=None)
    # brick courses
    brick = '#b09c74'
    if not c.small:
        for y in (30, 38, 46):
            c.line([(9, y), (22, y)], brick); c.line([(42, y), (55, y)], brick)
        for (x, y0, y1) in ((14, 30, 38), (50, 38, 46), (18, 38, 46), (46, 30, 38), (14, 46, 55), (50, 46, 55)):
            c.line([(x, y0), (x, y1)], brick)
    else:
        for y in (34, 45):
            c.line([(9, y), (21, y)], brick); c.line([(43, y), (55, y)], brick)
    # canopy: two leafy humps split by the top blank
    can = c.m(K.rect(8, 9, 56, 17), K.ell(16, 15, 9, 6), K.ell(48, 15, 9, 6), K.ell(28, 16, 4, 3), K.ell(36, 16, 4, 3), minus=blanks)
    can &= body
    c.add(can, BUSH)
    if not c.small:
        for (x, y) in ((12, 13), (16, 18), (22, 14), (43, 13), (49, 18), (53, 14), (11, 21), (27, 20), (38, 20)):
            px, py = c.P(x, y)
            c.px(px, py, BUSH[2]); c.px(px + 1, py, BUSH[2])
        for (x, y) in ((19, 21), (46, 21), (14, 16), (51, 16)):
            px, py = c.P(x, y); c.px(px, py, BUSH[1])
    # dark arched doorway
    ring = c.m(K.rect(19, 31, 45, 57), K.ell(32, 31, 13, 11), minus=blanks) & body
    ring -= can
    c.add(ring, K.ramp('#e6d6ae'))
    door = c.m(K.rect(23, 31, 41, 57), K.ell(32, 31, 9, 8), minus=blanks) & body
    c.add(door, ARCH)
    c.edge(ring, '#a8946c')
    kx, ky = c.P(32, 21)
    for dy in range(0, 2 if c.small else 3):
        c.px(kx, ky + dy, '#a8946c')
    # vine curtain: a pair of vines hanging from the canopy, either side of the doorway
    w = 3.2 if c.small else 2.8
    v1 = c.m(K.thick_path([(21, 16), (22, 26), (20, 36), (22, 46)], w))
    v2 = c.m(K.thick_path([(43, 16), (42, 26), (44, 36), (42, 46)], w))
    lv = c.m(K.ell(23.5, 31, 2.2, 1.6), K.ell(18.5, 40, 2.2, 1.6), K.ell(40.5, 31, 2.2, 1.6), K.ell(45.5, 40, 2.2, 1.6))
    vines = (v1 | v2 | lv) & body
    c.add(vines, VINE)
    # flowers on the vines (cell's cream flower)
    for (x, y) in ((22, 46), (42, 46)):
        px, py = c.P(x, y)
        for d in ((0, 0), (1, 0), (-1, 0), (0, 1), (0, -1)) if not c.small else ((0, 0),):
            c.px(px + d[0], py + d[1], FLOWER)
        if not c.small:
            c.px(px, py, '#f0b030')
    # face peeking out of the doorway
    ey = 34.5 if c.small else 37
    c.eye(27.5 if c.small else 28.5, ey, disc=True)
    c.eye(34.5 if c.small else 35.5, ey, disc=True)
    c.smile(31 if c.small else 32, 44 if c.small else 42, col=K.CREAM)
    c.blush(26, 41); c.blush(38, 41)

K.render_pal(fn, 'pl-hang-5', 'Vine Curtain Gateway', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-hang-5-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-hang-5.png')
