# Concept: a round of tree-stump end grain (a wood "cookie") that is an inner-BBBB piece: double-knob blanks bite into all
# four sides, bark wraps the whole cut outline, concentric rings from the stump picture, and the velvet-dark hollow in the
# middle is the face (felt eyes + gold glints). A little green sprout grows from the top-left corner.
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

BARK = K.ramp('#6a4028')
WOOD_L = K.ramp('#c8925c')
WOOD_M = K.ramp('#a26a40')
HOLLOW = K.ramp('#3c2428')
LEAF = K.ramp('#5f9e3e')
RING = '#6a3c22'
GLINT = '#f5cf6a'
CX, CY = 32, 33


def sd(x, y, p=2.6):
    return (abs(x - CX) ** p + abs(y - CY) ** p) ** (1 / p)


def fn(c):
    k = 1.15 if c.small else 1.0
    r = 3.7 * k
    core = lambda x, y: sd(x, y, 5) < 27
    blanks = [K.knob('B', 'double', CX, CY - 27, 0, -1, r=r),
              K.knob('B', 'double', CX, CY + 27, 0, 1, r=r),
              K.knob('B', 'double', CX - 27, CY, -1, 0, r=r),
              K.knob('B', 'double', CX + 27, CY, 1, 0, r=r)]
    body = c.m(core, minus=blanks)
    # sprout from the top-left corner
    stem = K.thick_path([(11, 11), (9, 7), (9, 4)], 2.8 if not c.small else 3.4)
    leaf1 = K.ell(5, 4, 3.8, 2.4)
    leaf2 = K.ell(13, 3.2, 3.6, 2.2)
    sprout = c.m(stem, leaf1, leaf2, minus=[core])
    c.add(sprout, LEAF)
    c.add(body, BARK)
    inner = set(body)
    for _ in range(2 if c.small else 3):
        inner = K.erode(inner)
    wood = c.add(inner, WOOD_M)
    rings = [22.5, 19, 15.5, 12, 8.5] if not c.small else [21, 15.5, 10]
    for i, rad in enumerate(rings):
        m = c.m(lambda x, y, rad=rad: sd(x, y, 2.3) < rad) & inner
        c.add(m, WOOD_L if i % 2 == 0 else WOOD_M)
        c.edge(m, RING)
    hol = c.m(K.ell(CX, CY + 0.5, 7.2, 6.2)) & inner
    c.add(hol, HOLLOW)
    c.edge(hol, '#24161a')
    # bark grain ticks
    if not c.small:
        for (x0, y0, x1, y1) in ((5.5, 18, 5.5, 22), (58.5, 44, 58.5, 48), (18, 60, 21, 60), (44, 6, 47, 6)):
            c.line([(x0, y0), (x1, y1)], BARK[1])
    # face in the hollow
    c.eye(29.2, 33.2, disc=True)
    c.eye(35.2, 33.2, disc=True)
    for gx, gy in ((27, 37.5), (37.5, 29.5), (33, 37.8)):
        px, py = c.P(gx, gy)
        c.px(px, py, GLINT)
    c.blush(24.5, 37) if not c.small else None


K.render_pal(fn, 'pl-trng-5', 'Velvet Hollow', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-trng-5-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-trng-5.png')
