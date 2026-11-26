# Sentry Straw: a straw boater hat (corner-BB, round): flat left + bottom sides; the top blank is the crown's pinch dent,
# the right blank bites the crown; red cord hatband ties under the brim; misty blue-green shadow under the brim (cell 3-3 haze + green hills).
import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K

STRAW = K.ramp('#e2b862')
STRAW2 = K.ramp('#c8964a')
RED = K.ramp('#d04c50')
MIST = K.ramp('#b1cece')
HILL = K.ramp('#74b896')
WEAVE = '#b8863e'


def fn(c):
    s = 1.15 if c.small else 1.0
    crown = c.m(K.rect(15, 15, 49, 34), K.ell(32, 16, 17, 9),
                minus=(K.knob('B', 'round', 32, 7.5, 0, -1, r=4.2 * s),))
    brim = c.m(K.rect(5, 33, 59, 40), K.ell(5, 36.5, 3, 3.5), K.ell(59, 36.5, 3, 3.5))
    under = c.m(K.rect(9, 39, 55, 58), minus=(K.knob('B', 'round', 55, 49, 1, 0, r=3.6 * s),))
    c.add(under, MIST)
    hills = c.m(K.ell(18, 59, 12, 6), K.ell(40, 60, 14, 6.5))
    c.add(hills & under, HILL)
    c.add(crown, STRAW)
    band = c.m(K.rect(9, 28, 52, 33))
    c.add(band & crown, RED)
    c.add(brim, STRAW2)
    if not c.small:
        for y in (19, 24):
            for x in range(17, 48, 4):
                c.line([(x, y), (x + 2, y + 2)], WEAVE)
        for x in range(6, 58, 4):
            c.line([(x, 35), (x + 2, 37)], '#9a7038')
    else:
        for x in range(8, 58, 6):
            c.line([(x, 36), (x + 2, 36)], '#9a7038')
    c.edge(brim, '#9a7038')
    w = 2.8 if c.small else 2.2
    cord = c.m(K.thick_path([(13, 39), (13, 48), (20, 52)], w), K.thick_path([(40, 39), (40, 47), (32, 52)], w))
    c.add(cord & under, RED)
    c.add(c.m(K.ell(22, 52, 3.2, 2.6), K.ell(30, 52, 3.2, 2.6), K.ell(26, 52, 1.8, 2)), RED)
    c.eye(20, 45, disc=True)
    c.eye(33, 45, disc=True)
    c.add(c.m(K.ell(19, 26, 2.2, 4)), HILL)


K.render_pal(fn, 'pl-lwp-1', 'Sentry Straw', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-lwp-1-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-lwp-1.png')
