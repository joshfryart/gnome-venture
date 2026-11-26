# Acacia Parasol (pl-drmc-4), inner-TTTT, peg knobs.
# Concept: a flat-topped acacia tree. The wide umbrella crown is the top half of the piece (peg tabs N, W, E poke out of the
# crown as twig tufts), the forked trunk stands on a purple night hill that is the bottom half (peg tab S under the hill).
# Motif from cell 4-1: navy night sky + stepped purple hill; the market's warm lantern string hangs along the crown's rim.
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, thick_path, knob, ramp

LEAF = ramp('#4f7a3e')
LEAF2 = ramp('#3a5c34')
BARK = ramp('#a96d48')
HILL = ramp('#4a3290')
NIGHT = ramp('#221448')
LAMPS = ('#ffd26b', '#f28435', '#ec74ac', '#7fd0c8')


def fn(c):
    k = 1.15 if c.small else 1.0
    # crown: a flat slab, rounded ends, slightly domed top
    crown = (rect(9, 13, 55, 26), ell(9.5, 19.5, 4.5, 6.5), ell(54.5, 19.5, 4.5, 6.5)) + tuple(ell(x, 13.5, 5.2, 4) for x in (14, 23, 32, 41, 50))
    tabN = knob('T', 'peg', 32, 10, 0, -1, r=4.2 * k)
    tabW = knob('T', 'peg', 5.5, 19.5, -1, 0, r=4.2 * k)
    tabE = knob('T', 'peg', 58.5, 19.5, 1, 0, r=4.2 * k)
    # trunk: forked Y
    tw = 5.0 if not c.small else 5.6
    trunk = (thick_path([(32, 44), (32, 35), (22, 25)], tw), thick_path([(32, 35), (43, 25)], tw * 0.8), thick_path([(32, 38), (32, 25)], tw * 0.6))
    # hill: the cell's stepped purple hill, filling the lower half of the piece (steps rise toward the trunk)
    hill = (rect(11, 45, 53, 56), rect(16, 43, 48, 56), rect(22, 41, 42, 56))
    tabS = knob('T', 'peg', 32, 56, 0, 1, r=4.2 * k)

    hm = c.m(*hill) | c.m(tabS)
    c.add(hm, HILL)
    c.add(c.m(rect(11, 51, 53, 56)) | c.m(tabS, minus=(rect(0, 0, 64, 51),)), NIGHT)
    c.add(c.m(*trunk, minus=(rect(0, 43, 64, 64),)), BARK)
    cm = c.m(*crown, tabW, tabE, tabN)
    c.add(cm, LEAF, stitch=None if c.small else LEAF[2])
    # darker underside layer of the crown (acacia's flat layered look)
    under = c.m(*crown) & c.m(rect(0, 22.5, 64, 64))
    c.add(under, LEAF2)
    c.edge(under, LEAF2[1])
    # night-sky glimpses in the hill: little stars
    for sx, sy in ((16, 53), (45, 54), (27, 53.5), (37, 52.5)):
        x, y = c.P(sx, sy)
        c.px(x, y, '#fffcdf')
    # step on the hill (stepped skyline from the cell)
    # lantern string along the underside rim
    xs = (13, 21, 29, 37, 45, 53) if not c.small else (14, 26, 38, 50)
    for i, lx in enumerate(xs):
        x, y = c.P(lx, 26.5)
        col = LAMPS[i % len(LAMPS)]
        c.px(x, y, col)
        c.px(x, y - 1, col)
        if not c.small:
            c.px(x + 1, y, col)
            c.px(x + 1, y - 1, col)
            c.px(x, y + 1, col)
            c.px(x + 1, y + 1, col)
    # face on the crown
    c.eye(25, 16.5)
    c.eye(39, 16.5)
    c.smile(32, 19)
    c.blush(20.5, 19)
    c.blush(43, 19)


if __name__ == '__main__':
    print(K.render_pal(fn, 'pl-drmc-4', 'Acacia Parasol', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-drmc-4-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-drmc-4.png'))
