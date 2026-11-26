# pl-frt-5 "Barrow Peephole": a mossy barrow-door slab (inner-BBBB, hook blanks on all four sides) with a frost-rimmed
# round peephole in the middle; the frost toad's yellow eyes glow inside. Moss greens over snow, from cell 2-6.
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

MOSS = K.ramp('#5aa048')
MOSSD = K.ramp('#3f7a4a')
SNOW = K.ramp('#e8f0f4')
ICE = K.ramp('#b8d8e8')
HOLE = ('#1e3438', '#142428', '#2e4a4c')
GLOW, GLOWD = '#f0e040', '#b8a020'


def fn(c):
    k = 1.15 if c.small else 1.0
    r = 4.5 * k
    x0, y0, x1, y1 = 9, 9, 55, 55
    core = K.rect(x0, y0, x1, y1)
    blanks = (K.knob('B', 'hook', 32, y0, 0, -1, r=r),
              K.knob('B', 'hook', x1, 32, 1, 0, r=r),
              K.knob('B', 'hook', 32, y1, 0, 1, r=r, flip=True),
              K.knob('B', 'hook', x0, 32, -1, 0, r=r, flip=True))
    body = c.m(core, minus=blanks)
    c.add(body, MOSSD, stitch=None if c.small else '#7ab55c')
    # lighter moss mound top-left
    c.add(body & c.m(K.ell(24, 22, 20, 15)), MOSS)
    # snow cap along the top edge, wavy
    cap = K.poly([(9, 9), (55, 9), (55, 15), (48, 13), (42, 16), (36, 14), (30, 17), (22, 13), (15, 16), (9, 13)])
    c.add(body & c.m(cap), SNOW)
    # snow drift at the bottom
    drift = K.poly([(9, 47), (16, 45), (24, 48), (32, 46), (40, 48), (48, 45), (55, 47), (55, 55), (9, 55)])
    c.add(body & c.m(drift), SNOW)
    # barrow door frame from the picture: stone posts + snowy lintel round the peephole
    STONE = K.ramp('#9aa4a8')
    posts = c.m(K.rect(19, 19, 23.5, 46), K.rect(40.5, 19, 45, 46))
    c.add(posts, STONE)
    lint = c.m(K.rect(17, 16, 47, 21.5))
    c.add(lint, STONE)
    c.add(c.m(K.rect(17, 16, 47, 18)), SNOW)
    c.edge(posts | lint, '#5e686c')
    c.add(c.m(K.rect(23.5, 21.5, 40.5, 46)), K.ramp('#2a4038'))
    # frost ring + dark peephole
    ring = c.m(K.ell(32, 32, 8.5, 8.5))
    c.add(ring, ICE)
    hole = c.m(K.ell(32, 32, 6, 6))
    c.add(hole, HOLE)
    c.edge(ring, '#7aa8c0')
    # frost specks round the rim (icicle teeth hanging into the hole)
    for (ix, iy) in ((29.5, 26.5), (32, 26), (34.5, 26.5)):
        a, b = c.P(ix, iy)
        c.px(a, b, SNOW[2])
        if not c.small:
            c.px(a, b + 1, ICE[0])
    # glowing toad eyes
    for ex in (29, 35):
        a, b = c.P(ex, 32.5)
        if c.small:
            for dx in (0, 1):
                for dy in (0, 1):
                    c.px(a + dx, b + dy, GLOW)
            c.px(a + 1, b + 1, GLOWD)
        else:
            for dx in range(-1, 2):
                for dy in range(-1, 2):
                    c.px(a + dx, b + dy, GLOW)
            c.px(a, b - 1, '#4a2c1a'); c.px(a, b, '#4a2c1a'); c.px(a, b + 1, '#4a2c1a')
            c.px(a - 1, b - 1, '#fff8c0')
    # grass tufts / moss specks
    for (gx, gy) in ((13, 38), (50, 24), (50, 38), (13, 24)):
        a, b = c.P(gx, gy)
        c.px(a, b, '#a8d870')
        if not c.small:
            c.px(a + 1, b - 1, '#a8d870')


K.render_pal(fn, 'pl-frt-5', 'Barrow Peephole', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-frt-5-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-frt-5.png')
