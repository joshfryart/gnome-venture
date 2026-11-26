# Rail Lean: a pampas fence panel that is an edge piece. Flat side = ground (bottom); top peg tab = fence post top,
# left peg tab = the upper rail's end poking out, right peg blank = the mortise slot the rail runs into.
# Motif/colours from cell 6-5: yellow-green pampas grass (two greens) and the brown fence post.
import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K

GRASS = K.ramp('#d0cc64')
GRASS2 = K.ramp('#b0b04c')
WOOD = ('#c88858', '#8a5634', '#e0a878')
POST = ('#a96d48', '#6e4030', '#c88858')


def fn(c):
    s = 1.15 if c.small else 1.0
    core = K.rect(10, 12, 54, 56)
    top = K.knob('T', 'peg', 32, 12, 0, -1, r=5.0 * s)
    left = K.knob('T', 'peg', 10, 30, -1, 0, r=4.6 * s)
    right = K.knob('B', 'peg', 54, 44, 1, 0, r=4.6 * s)
    body = c.m(core, top, left, minus=(right,))
    c.add(body, GRASS)
    # pampas tufts (darker grass blades) behind the fence
    tufts = c.m(K.poly([(10, 56), (13, 40), (17, 50), (20, 38), (24, 56)]), K.poly([(38, 56), (42, 40), (46, 50), (50, 36), (54, 56)]),
                K.thick_path([(46, 34), (46, 22)], 2.6), K.thick_path([(18, 34), (18, 22)], 2.6))
    c.add(tufts & body, GRASS2)
    plumes = c.m(K.ell(46, 18, 4, 6.5), K.ell(17, 18.5, 3.6, 5.5), minus=(K.rect(0, 0, 64, 12.5),))
    c.add(plumes & body, ('#f0e6b0', '#c8b878', '#fff8dc'))
    # post (vertical, rising into the top tab)
    post = c.m(K.rect(32 - 5.0 * s, 0, 32 + 5.0 * s, 56))
    c.add(post & body, POST)
    # upper rail (out through the left tab), lower rail
    rail = c.m(K.rect(0, 30 - 4.6 * s, 54, 30 + 4.6 * s))
    c.add(rail & body, WOOD, stitch='#8a5634')
    low = c.m(K.rect(10, 41, 54, 47))
    c.add(low & body, WOOD)
    # wood grain on the post top
    c.line([(30, 6), (30, 20)], '#6e4030')
    if not c.small:
        c.line([(34, 48), (34, 54)], '#6e4030')
        for (x, y) in ((29, 28), (35, 32), (29, 44), (35, 44)):
            c.px(*c.P(x, y), '#4a2c1a')
    # face on the upper rail, left of the post
    c.eye(14, 29)
    c.eye(22, 29)
    c.smile(18, 32)
    c.blush(11.5, 32)
    c.blush(24.5, 32)


K.render_pal(fn, 'pl-gaun-2', 'Rail Lean', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-gaun-2-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-gaun-2.png')
