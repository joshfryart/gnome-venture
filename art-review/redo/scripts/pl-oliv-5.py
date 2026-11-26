# Millstone Turn: a round millstone that is an inner-BBBB piece (four round blanks), grooved grey stone, wooden axle hub, olive-oil drip.
import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import math
import pal_kit as K

STONE = K.ramp('#b4b2c8')     # millstone grey-lavender from the picture
GROOVE = '#8a88a0'
WOOD = K.ramp('#a86a3a')      # beam / axle
TERRA = K.ramp('#e0925a')     # cell peach-terracotta (sunlit wall / jars)
OIL = K.ramp('#e8b020')
OLIVE = K.ramp('#6a8a2a')

def fn(c):
    k = 1.15 if c.small else 1.0
    a, b, R = 6, 58, 17
    core = [K.rect(a + R, a, b - R, b), K.rect(a, a + R, b, b - R)] + \
           [K.ell(x, y, R, R) for x in (a + R, b - R) for y in (a + R, b - R)]
    blanks = (K.knob('B', 'round', 32, a, 0, -1, r=3.6 * k), K.knob('B', 'round', 32, b, 0, 1, r=3.6 * k),
              K.knob('B', 'round', a, 32, -1, 0, r=3.6 * k), K.knob('B', 'round', b, 32, 1, 0, r=3.6 * k))
    body = c.m(*core, minus=blanks)
    c.add(body, K.ramp('#8e8ca6'))
    disc = c.m(K.ell(32, 30, 22, 22), minus=blanks) & body
    c.add(disc, STONE, stitch=None if c.small else '#d8d6e6')
    # terracotta oil-trough band at the base corners (warm cell colour)
    trough = c.m(K.rect(0, 46, 64, 64), minus=blanks) & body
    c.add(trough, TERRA)
    c.edge(trough, TERRA[1])
    # oil pooling in the trough + a drip
    oil = c.m(K.ell(17, 50, 6, 1.8), K.ell(47, 50, 6, 1.8)) & trough
    c.add(oil, OIL)
    # radial grooves of the millstone (from hub outward, stopping before the blanks)
    hx, hy = 32, 24
    if True:
        for ang in range(0, 360, 20 if not c.small else 30):
            t = math.radians(ang + 10)
            p0 = (32 + 17 * math.cos(t), 30 + 17 * math.sin(t))
            p1 = (32 + 21.5 * math.cos(t), 30 + 21.5 * math.sin(t))
            if p1[1] < 46:
                c.line([p0, p1], GROOVE)
    # stone ring contour
    c.edge(disc, '#6e6c88')
    # wooden axle hub with olive-wood beam stub
    beam = c.m(K.rect(30, 4, 34, hy))
    c.add(beam, WOOD)
    hub = c.m(K.ell(hx, hy, 6.2 * k, 6.2 * k))
    c.add(hub, WOOD)
    hole = c.m(K.ell(hx, hy, 2.2 * k, 2.2 * k))
    c.add(hole, (K.UMBER2, K.UMBER2, K.UMBER2))
    # olive sprig on top-left corner
    leaf = c.m(K.ell(14, 14, 4.5, 2.2), K.ell(20, 11, 2.2, 4.0))
    c.add(leaf, OLIVE)
    # face
    c.eye(25, 36, disc=False)
    c.eye(39, 36, disc=False)
    c.smile(32, 40)
    c.blush(21, 41); c.blush(42, 41)

r = K.render_pal(fn, 'pl-oliv-5', 'Millstone Turn', '/home/user/gnome-venture/art-review/redo/out',
                 cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-oliv-5-cell.png',
                 oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-oliv-5.png')
print(r)
