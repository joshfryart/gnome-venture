# Hummed Note: a gold eighth-note whose round head is an inner piece; tri tabs top+bottom, tri blanks left+right;
# stem and flag rise from the top-right in red-rock orange/plum; a teal-and-cream dotted songline crosses the head (sand/rock palette of cell 7-5).
import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K

GOLDS = K.ramp('#eea24e')
SUN = K.ramp('#fcc880')
ROCK = K.ramp('#e8784a')
PLUM = K.ramp('#7a2c44')
TEAL = '#5ec8c0'


def fn(c):
    k = 1.15 if c.small else 1.0
    # note head: rounded square core
    core = lambda x, y: (K.rect(7, 28, 54, 58)(x, y) and not
                         any(((x - cx) ** 2 + (y - cy) ** 2 > 36 and abs(x - cx) < 6 and abs(y - cy) < 6 and (x - cx) * sx > 0 and (y - cy) * sy > 0)
                             for cx, cy, sx, sy in ((13, 34, -1, -1), (48, 34, 1, -1), (13, 52, -1, 1), (48, 52, 1, 1))))
    tt = K.knob('T', 'tri', 22, 28, 0, -1, r=4.2 * k)
    tb = K.knob('T', 'tri', 31, 58, 0, 1, r=4.2 * k)
    bl = K.knob('B', 'tri', 7, 43, -1, 0, r=3.2 * k)
    br = K.knob('B', 'tri', 54, 43, 1, 0, r=3.2 * k)
    head = c.m(core, tt, tb, minus=(bl, br))
    # stem + flag
    stem = c.m(K.rect(40, 5, 47, 31))
    flag = c.m(K.thick_path([(44, 7), (52, 10), (57, 16), (57, 22), (54, 26)], 6.0))
    c.add(stem, PLUM)
    c.add(flag, ROCK)
    c.add(head, GOLDS, stitch=None)
    c.edge(head, GOLDS[1])
    # sun-gold highlight band on head (upper)
    # songline: dotted teal/cream line across lower head
    y = 51
    for i, x in enumerate(range(9, 54, 4 if not c.small else 5)):
        X, Y = c.P(x, y + (1 if i % 2 else 0))
        col = TEAL if i % 2 == 0 else '#fbede5'
        c.px(X, Y, col)
        if not c.small:
            c.px(X + 1, Y, col)
    # face
    c.eye(23, 39)
    c.eye(37, 39)
    c.blush(19, 45)
    c.blush(40, 45)
    c.smile(30, 44)
    # hum marks floating off the flag (tiny, part of flag silhouette? keep inside)


K.render_pal(fn, 'pl-rrs-3', 'Hummed Note', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-rrs-3-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-rrs-3.png')
