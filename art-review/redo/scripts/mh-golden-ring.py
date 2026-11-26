# mh-golden-ring "Golden Ring": a maize harvest wreath = inner-BBBB piece (round blanks on all four sides),
# the wreath's hole in the middle; gold kernels (window glow), cream husk leaves (plaster wall), wood brown, red flower, teal bead.
import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K

GOLD = K.ramp('#f0c040')
KERN_D = '#c8901c'
KERN_L = '#fbe48a'
HUSK = K.ramp('#e8dbb8')
HUSK_E = '#b8a887'
WOOD = K.ramp('#b07a3a')
RED = K.ramp('#d8402a')
TEAL = '#5cc8c8'


def fn(c):
    s = 1.15 if c.small else 1.0
    R = 9
    core = [K.rect(9, 9 + R, 55, 55 - R), K.rect(9 + R, 9, 55 - R, 55)] + \
        [K.ell(x, y, R, R) for x in (9 + R, 55 - R) for y in (9 + R, 55 - R)]
    r = 3.6 * s
    blanks = [K.knob('B', 'round', 32, 9, 0, -1, r=r), K.knob('B', 'round', 32, 55, 0, 1, r=r),
              K.knob('B', 'round', 9, 32, -1, 0, r=r), K.knob('B', 'round', 55, 32, 1, 0, r=r)]
    hole = K.ell(32, 33, 6.2, 6.2)
    body = c.m(*core, minus=blanks + [hole])
    c.add(body, GOLD, stitch=WOOD[0])
    # inner wooden lip around the hole: makes it read as a ring
    lip = c.add(c.m(K.ell(32, 33, 8.6, 8.6), minus=[hole]) & body, WOOD)
    face = c.m(K.ell(32, 25, 13, 6))
    deco = c.m(K.thick_path([(10, 25), (14, 17), (19, 13)], 8.5), K.thick_path([(13, 19), (19, 13), (26, 10)], 8.5),
               K.ell(17, 17, 4.8 * s, 4.8 * s))
    # kernel rows: plump 2x2 kernels with a soft darker seam, staggered every other row
    for (x, y) in body:
        if (x, y) in lip or (x, y) in face or (x, y) in deco:
            continue
        if c.small:
            if (x + (y // 2) % 2) % 2 == 0 and y % 2 == 0:
                c.px(x, y, KERN_D)
        else:
            sx = (x + ((y // 3) % 2) * 1) % 3
            sy = y % 3
            if sx == 2 or sy == 2:
                c.px(x, y, '#dca62c')
            elif sx == 0 and sy == 0:
                c.px(x, y, KERN_L)
    # cream husk leaves + red flower tied on the upper-left of the wreath
    lv = [K.thick_path([(10, 25), (14, 17), (19, 13)], 6.5), K.thick_path([(13, 19), (19, 13), (26, 10)], 6.5)]
    m = c.add(c.m(*lv, minus=blanks) & body, HUSK)
    c.edge(m, HUSK_E)
    c.line([(11, 24), (15, 17)], HUSK_E)
    c.line([(19, 13), (25, 11)], HUSK_E)
    c.add(c.m(K.ell(17, 17, 3.8 * s, 3.8 * s)) & body, RED)
    cx, cy = c.P(17, 17)
    c.px(cx, cy, '#f8dc79')
    # face above the hole; the ring's hole is its happy open "O"
    c.eye(25, 24)
    c.eye(39, 24)
    c.blush(21, 29)
    c.blush(43, 29)


K.render_pal(fn, 'mh-golden-ring', 'Golden Ring', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/mh-golden-ring-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/mh-golden-ring.png')
