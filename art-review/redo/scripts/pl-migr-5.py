# pl-migr-5 Honeysun Disc: a low honey sun that IS an inner-BBBB piece (double blanks on all four sides),
# short rounded rays at the four corners, peach halo -> cream disc (cell 8-3), dusky herd strip along the bottom.
import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K

HALO = K.ramp('#f6a05a')
RING = K.ramp('#ffcf80')
DISC = ('#fdeec0', '#f4cf8a', '#fffbe8')
HERD = K.ramp('#7a5068')
GRASS = K.ramp('#c88a3a')

def sq(cx, cy, r, p=4):
    return lambda x, y: (abs(x - cx) / r) ** p + (abs(y - cy) / r) ** p < 1

def fn(c):
    k = 1.15 if c.small else 1.0
    R = 3.7 * k
    core = sq(32, 32, 23.5, 6)
    blanks = [K.knob('B', 'double', 32, 9, 0, -1, r=R), K.knob('B', 'double', 32, 55, 0, 1, r=R),
              K.knob('B', 'double', 9, 32, -1, 0, r=R), K.knob('B', 'double', 55, 32, 1, 0, r=R)]
    rays = []
    import math
    for base in (45, 135, 225, 315):
        for off in (-17, 17):
            t = math.radians(base + off)
            dx, dy = math.cos(t), math.sin(t)
            rays.append(K.thick_path([(32 + dx * 20, 32 + dy * 20), (32 + dx * 29, 32 + dy * 29)], 5.0 if c.small else 4.6))
    body = c.m(core, *rays, minus=blanks)
    c.add(body, HALO)
    ring = c.m(K.ell(32, 30, 17, 17)) & body
    c.add(ring, RING)
    disc = c.m(K.ell(32, 30, 12.5, 12.5)) & body
    c.add(disc, DISC, stitch='#f0c070')
    # herd strip along the horizon (bottom), humped backs and little horns
    herd = c.m(K.rect(0, 50, 64, 54.5), K.ell(17, 50, 4, 1.8), K.ell(46, 50, 4, 1.8)) & c.m(core, minus=blanks)
    c.add(herd, HERD)
    ground = c.m(K.rect(0, 55, 64, 64)) & c.m(core, minus=blanks)
    c.add(ground, GRASS)
    if not c.small:
        for hx in (14.5, 19.5, 43.5, 48.5):
            c.px(*c.P(hx, 47.6), HERD[0])
    # face on the cream disc
    c.eye(27, 29)
    c.eye(37, 29)
    c.smile(32, 34.5)
    c.blush(23.5, 33)
    c.blush(39.5, 33)

K.render_pal(fn, 'pl-migr-5', 'Honeysun Disc', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-migr-5-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-migr-5.png')
