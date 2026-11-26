# Hummed Quaver: a cream eighth note whose head is a corner piece (left + bottom flat), keyhole tab on the head's right side,
# keyhole blank cut into the head's top; the note's flag is the cell's rainbow arc (red / orange / yellow) over sky-blue picture.
import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K

CREAM = K.ramp('#f4e6c4')
RED, ORANGE, YELLOW = K.ramp('#e8493b'), K.ramp('#f5a03c'), K.ramp('#ffe05a')
LAV = K.ramp('#b8aec8')


def flag(o, w):
    return K.thick_path([(38, 6 + o), (46, 9 + o), (52, 14 + o), (54.5, 21 + o), (52, 28 + o)], w)


def fn(c):
    k = 1.15 if c.small else 1.0
    head = (K.rect(5, 35, 41, 60), K.rect(15, 26, 41, 36), K.ell(15, 36, 10, 10))
    stem = K.rect(34, 4, 41, 30)
    tab = K.knob('T', 'keyhole', 41, 47, 1, 0, r=5.2 * k, nw=3.0)
    blank = K.knob('B', 'keyhole', 21, 26, 0, -1, r=4.6 * k, nw=2.8)
    c.add(c.m(*head, stem, tab, minus=(blank,)), CREAM, stitch='#d8c49a')
    c.add(c.m(flag(0, 4.6), flag(3.4, 4.6), flag(6.8, 4.6)), RED)
    c.add(c.m(flag(3.6, 3.6), flag(6.8, 4.6)), ORANGE)
    c.add(c.m(flag(7.2, 3.6)), YELLOW)
    # lavender rock band along the flat bottom (the cliff the note drifts off)
    band = c.add(c.m(K.rect(5, 55, 41, 60)), LAV)
    c.edge(band, LAV[1])
    # sky-blue spray at the stem foot
    c.eye(13, 45)
    c.eye(28, 45)
    c.smile(20.5, 49.5)
    c.blush(9, 49)
    c.blush(32, 49)


K.render_pal(fn, 'pl-sing-1', 'Hummed Quaver', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-sing-1-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-sing-1.png')
