"""pl-wgor-5 Orange Offering: inner-BBBB keyhole. The piece IS a big purple gorilla hand held palm-up: four fat fingers make the
top edge (keyhole blank N between the middle fingers), the cupped mauve palm fills the body, a thumb curls in from the left, the furry wrist
is the bottom (keyhole blank S); keyhole blanks E and W bite into the hand's sides. In the palm sits a smiling glade orange with a leaf.
Fur purples from cell 6-6, palm mauve from the gorilla's face, orange + leaf from the glade's fruit trees."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, thick_path, knob

FUR = K.ramp('#4a3e5e')
FURD = K.ramp('#463a58')
PALM = K.ramp('#b08e9c')
ORANGE = ('#f0883a', '#c0601e', '#f7a667')
LEAF = K.ramp('#43826c')


def fn(c):
    Kk = 1.15 if c.small else 1.0
    r = 3.3 * Kk
    # body: square back-of-hand + wrist, with four rounded fingertips making the top edge
    core = lambda x, y: (rect(9, 13, 55, 55)(x, y) and not (x < 13 and y > 51 and (x - 13) ** 2 + (y - 51) ** 2 > 16)
                         and not (x > 51 and y > 51 and (x - 51) ** 2 + (y - 51) ** 2 > 16))
    FX = (14.8, 26.0, 38.0, 49.2)
    tips = [lambda x, y, fx=fx: (rect(fx - 5.8, 12, fx + 5.8, 20)(x, y) or ell(fx, 12, 5.8, 4.4)(x, y)) for fx in FX]
    bN = knob('B', 'keyhole', 32, 9, 0, -1, r=r, nw=2.0)
    bS = knob('B', 'keyhole', 32, 55, 0, 1, r=r, nw=2.0)
    bW = knob('B', 'keyhole', 9, 33, -1, 0, r=r, nw=2.0)
    bE = knob('B', 'keyhole', 55, 33, 1, 0, r=r, nw=2.0)
    blanks = (bN, bS, bW, bE)
    body = c.m(core, *tips, minus=blanks)
    c.add(body, FUR, stitch=None)
    # finger pads (palm side) with gaps of fur between them
    for fx in FX:
        f = c.m(lambda x, y, fx=fx: (rect(fx - 5.0, 12, fx + 5.0, 26)(x, y) or ell(fx, 12, 5.0, 3.8)(x, y)), minus=blanks) & body
        c.add(f, PALM)
        c.edge(f, PALM[1])
        if not c.small:
            c.line([(fx - 2.0, 18.0), (fx + 2.0, 18.0)], PALM[1])
    # cupped palm
    palm = c.m(ell(32, 38, 20, 12.5), minus=blanks) & body
    c.add(palm, PALM)
    c.edge(palm, PALM[1])
    # wrist fur strands
    if not c.small:
        for (x, y) in body:
            if y > c.P(0, 50)[1] and (x * 3 + y) % 5 == 0 and (x, y) not in palm:
                c.px(x, y, FUR[2])
    # orange in the palm
    orr = 9.6 if not c.small else 10.4
    oc = (34, 38)
    orange = c.m(ell(oc[0], oc[1], orr, orr * 0.95))
    c.add(orange, ORANGE)
    c.edge(orange, ORANGE[1])
    c.add(c.m(poly([(35, 29.5), (40, 25), (45, 26), (41, 29.5)])), LEAF)
    c.add(c.m(rect(33.0, 26.5, 35.6, 30.5)), ('#7a4a1f', '#5a3414', '#9a6a3a'))
    # thumb curling up over the orange's lower left
    thumb = c.m(thick_path([(11, 50), (16, 46.5), (21.5, 43.5), (24, 39.5)], 6.0 if not c.small else 7.0), ell(24.5, 39.5, 3.4, 3.4))
    thumb = thumb & body
    c.add(thumb, PALM)
    c.edge(thumb, PALM[1])
    c.add(c.m(ell(24.6, 38.6, 1.8, 1.6)), K.ramp('#d8bcc4'))
    if not c.small:
        for (dx, dy) in ((-6, 2), (5, 5), (-2, 7), (7, -1), (-4, -5)):
            c.px(*c.P(oc[0] + dx, oc[1] + dy), ORANGE[1])
    c.eye(oc[0] - 4.2, oc[1] - 0.5)
    c.eye(oc[0] + 4.2, oc[1] - 0.5)
    c.smile(oc[0], oc[1] + 3.5)
    c.blush(oc[0] - 7, oc[1] + 3)
    c.blush(oc[0] + 6.5, oc[1] + 3)


if __name__ == '__main__':
    print(K.render_pal(fn, 'pl-wgor-5', 'Orange Offering', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wgor-5-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wgor-5.png'))
