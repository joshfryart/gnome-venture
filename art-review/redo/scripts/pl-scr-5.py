"""pl-scr-5 Sundisk Window: inner-BBBB hook. A sandstone tomb block (cell 9-4) holding a big golden sun disk with rays to the corners,
a dark peek-window slit at the top of the disk and a felt face. Hook blanks cut into all four sides."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

SAND = K.ramp('#d6a46c')
SAND2 = K.ramp('#b98552')
GOLD = K.ramp('#f0b828')
PLUM = '#5a2e3c'
DOOR = '#3a1e24'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.poly([(14, 9), (50, 9), (55, 14), (55, 50), (50, 55), (14, 55), (9, 50), (9, 14)])
    bl = [K.knob('B', 'hook', 32, 9, 0, -1, r=(4.2 * k if not c.small else 5.0)),
          K.knob('B', 'hook', 55, 32, 1, 0, r=(4.2 * k if not c.small else 5.0)),
          K.knob('B', 'hook', 32, 55, 0, 1, r=(4.2 * k if not c.small else 5.0), flip=True),
          K.knob('B', 'hook', 9, 32, -1, 0, r=(4.2 * k if not c.small else 5.0), flip=True)]
    body = c.m(core, minus=bl)
    c.add(body, SAND)
    # sandstone mortar lines in the frame corners
    if not c.small:
        for (a, b) in [((11, 20), (17, 20)), ((47, 20), (53, 20)), ((11, 44), (17, 44)), ((47, 44), (53, 44)),
                       ((20, 11), (20, 15)), ((44, 11), (44, 15)), ((20, 49), (20, 53)), ((44, 49), (44, 53))]:
            c.line([a, b], SAND2[1])
    # short wedge rays on the diagonals (between the blanks), not a full X
    import math
    rays = []
    for ang in (45, 135, 225, 315):
        a = math.radians(ang)
        ux, uy = math.cos(a), math.sin(a)
        px_, py_ = -uy, ux
        r0, r1, w = 14.0, 23.5, 4.6
        rays.append(K.poly([(32 + ux * r0 + px_ * w, 32 + uy * r0 + py_ * w), (32 + ux * r1, 32 + uy * r1),
                            (32 + ux * r0 - px_ * w, 32 + uy * r0 - py_ * w)]))
    rm = c.m(*rays) & body
    c.add(rm, GOLD)
    c.edge(rm, GOLD[1])
    disk = c.m(K.ell(32, 32, 15, 15)) & body
    c.add(disk, GOLD, stitch=None)
    c.edge(disk, PLUM)
    inner = c.m(K.ell(32, 32, 12.5, 12.5)) & body
    if not c.small:
        c.edge(inner, '#f8d870')
    # peek window: a dark slit near the top of the disk, cut clean through at 64 px
    win = c.m(K.ell(32, 24.5, 3.4, 2.4) if not c.small else K.ell(32, 24.5, 3.6, 2.6))
    for p in win:
        c.px(p[0], p[1], DOOR)
    # face
    c.eye(26.5, 32.5)
    c.eye(37.5, 32.5)
    c.blush(22.5, 37)
    c.blush(41, 37)
    c.smile(32, 38)


K.render_pal(fn, 'pl-scr-5', 'Sundisk Window', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-scr-5-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-scr-5.png')
