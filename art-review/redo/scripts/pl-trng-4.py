# Looking Glass Sparkle: a golden magnifying glass whose squircle rim IS an inner piece, keyhole tabs on all 4 sides (TTTT),
# a bark-brown handle out of the lower-right corner, and the lens showing the stump's magnified growth rings (cell 1-5 browns).
import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K

GOLD = K.ramp('#e8a317')
WOOD = K.ramp('#c48e5a')
BARK = K.ramp('#a46e44')
GLASS = K.ramp('#d8a474')
RING = '#a46e44'
RING2 = '#704838'
GROOVE = '#4e3230'
CX, CY, H = 29, 29, 15.5


def squircle(cx, cy, h, p=6):
    return lambda x, y: abs((x - cx) / h) ** p + abs((y - cy) / h) ** p < 1


def fn(c):
    s = 1.15 if c.small else 1.0
    r = 4.6 * s
    tabs = [K.knob('T', 'keyhole', CX, CY - H + 0.5, 0, -1, r=r),
            K.knob('T', 'keyhole', CX - H + 0.5, CY, -1, 0, r=r),
            K.knob('T', 'keyhole', CX + H - 0.5, CY - 2, 1, 0, r=r),
            K.knob('T', 'keyhole', CX - 2, CY + H - 0.5, 0, 1, r=r)]
    rim = squircle(CX, CY, H)
    # handle: diagonal from the lower-right corner
    hw = 8.5 if c.small else 7.5
    handle = K.thick_path([(41, 41), (57.5, 57.5)], hw)
    collar = K.thick_path([(39.5, 39.5), (44.5, 44.5)], hw + 2.5)
    c.add(c.m(handle), WOOD)
    c.add(c.m(collar), GOLD)
    c.add(c.m(rim, *tabs), GOLD)
    lens_r = 12.0 if not c.small else 11.5
    lens = c.m(K.ell(CX, CY, lens_r, lens_r))
    c.add(lens, GLASS)
    c.edge(lens, GOLD[1])
    # growth rings inside the lens (magnified stump)
    rings = (5.0, 9.0) if not c.small else (8.0,)
    for i, rr in enumerate(rings):
        ring = c.m(K.ell(CX + 0.8, CY + 1.5, rr + 0.6, rr * 0.8 + 0.6), minus=(K.ell(CX + 0.8, CY + 1.5, rr - 0.6, rr * 0.8 - 0.6),))
        for p in ring:
            if p in lens:
                c.px(p[0], p[1], RING)
    # handle grooves (bark lines from the cell)
    if not c.small:
        c.line([(47, 50), (55, 58)], GROOVE)
        c.line([(50, 47), (57, 54)], WOOD[1])
    else:
        c.line([(48, 49), (56, 57)], GROOVE)
    # glass glint, upper left
    if not c.small:
        c.line([(21, 26), (24, 22), (27, 20)], '#fff4dc')
        c.line([(22, 27), (25, 23)], '#fff4dc')
    else:
        c.line([(21, 25), (25, 21)], '#fff4dc')
    # face on the lens centre, ring pith between the eyes
    c.eye(CX - 4, CY + 1)
    c.eye(CX + 5, CY + 1)
    c.smile(CX + 0.5, CY + 5)
    c.blush(CX - 6.5, CY + 4.5)
    c.blush(CX + 6.5, CY + 4.5)
    # sparkle by the upper right of the rim
    sx, sy = c.P(42, 15)
    for d in ((0, 0), (1, 0), (-1, 0), (0, 1), (0, -1)):
        c.px(sx + d[0], sy + d[1], '#fff4dc')


if __name__ == '__main__':
    print(K.render_pal(fn, 'pl-trng-4', 'Looking Glass Sparkle', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-trng-4-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-trng-4.png'))
