"""pl-mgr-4 Stiltroot Prance: inner-TTTT, double knobs.
A little mangrove tree that is the piece: green canopy on top (N double tab = two leaf clumps), a stout trunk with the face,
two arching stilt roots sweeping out into the W and E double tabs (root knees), and two root toes as the S double tab,
standing in teal tide water. Root orange-brown, teal water, canopy greens from the cell 9-5 and the mangrove picture."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

ROOT = K.ramp('#c88a5c')
ROOTD = ('#aa6b4c', '#8c4c3c', '#c88a5c')
WATER = K.ramp('#3a9494')
LEAF = K.ramp('#5cae84')
LEAFD = K.ramp('#3c8a70')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(13, 15, 51, 50)
    tN = K.knob('T', 'double', 32, 15, 0, -1, r=5.2 * k)
    tW = K.knob('T', 'double', 13, 38, -1, 0, r=4.8 * k)
    tE = K.knob('T', 'double', 51, 38, 1, 0, r=4.8 * k)
    tS = K.knob('T', 'double', 32, 50, 0, 1, r=5.0 * k)
    body = c.m(core, tN, tW, tE, tS)
    # water fills the piece
    c.add(body, WATER)
    # ripple lines in the water
    rip = '#4ab0a4'
    for (x0, x1, y) in ((15, 22, 44), (42, 49, 44), (17, 23, 34)):
        if not c.small or y == 44:
            c.line([(x0, y), (x1, y)], rip)
    # arching stilt roots: loop out of the trunk, over the side tabs (root knees), down into the water at the corners
    rw = 4.6 if not c.small else 5.4
    arches = [
        [(27, 27), (20, 27), (15, 31), (13, 38), (14, 45), (16, 50)],
        [(37, 27), (44, 27), (49, 31), (51, 38), (50, 45), (48, 50)],
        [(26, 35), (22, 38), (21, 44), (22, 50)],
        [(38, 35), (42, 38), (43, 44), (42, 50)],
    ]
    roots = c.m(*[K.thick_path(a, rw) for a in arches]) & body
    c.add(roots | (c.m(tW, tE) - c.m(core)), ROOTD)
    c.edge(roots, ROOTD[1])
    # trunk + S toes
    trunk = c.m(K.rect(25, 22, 39, 50), tS)
    c.add(trunk & body, ROOT, stitch=None if c.small else '#e0a878')
    for y in range(c.P(0, 50)[1], c.n):
        p = (c.P(32, 0)[0], y)
        if p in body:
            c.px(p[0], p[1], ROOTD[1])
    c.edge(trunk & body, ROOTD[1])
    # canopy: leafy band with a scalloped hem, N double tab = two leaf clumps
    hem = [K.ell(x, 23.5, 3.6, 4.2) for x in (16.5, 24.5, 32, 39.5, 47.5)]
    can = c.m(K.rect(13, 15, 51, 22), tN, *hem) & body
    c.add(can, LEAFD)
    # lighter leaf clumps on the darker canopy (upper-left lit)
    clumps = [K.ell(x, y, 3.4, 2.6) for (x, y) in ((17, 18), (25, 20), (33, 17.5), (41, 20), (48, 18), (29, 9), (35, 9))]
    c.add(c.m(*clumps) & can, LEAF)
    c.edge(can, LEAFD[1])
    # face on the trunk
    c.eye(28.5, 33, disc=True)
    c.eye(35.5, 33, disc=True)
    c.smile(32, 39)
    c.blush(26.5, 37)
    c.blush(36.5, 37)


K.render_pal(fn, 'pl-mgr-4', 'Stiltroot Prance', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-mgr-4-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-mgr-4.png')
