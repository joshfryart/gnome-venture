import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, thick_path, knob

STONE = K.ramp('#a3a68c')
MOSS = K.ramp('#5f9e34')
MOSSL = K.ramp('#9acb4a')
ROOT = K.ramp('#9a6a42')
SEAM = '#6f7360'
FROGY = '#f2e08a'


def fn(c):
    """Corner-BB, keyhole: the mossy capstone of the root temple. Flat top + left, keyhole blanks E and S cut into the stone.
    Moss cap with drips over the top, a brown root wrapping across the block, a carved stone face (cell 5-0: root, moss frog)."""
    k = 1.15 if c.small else 1.0
    core = rect(8, 8, 55, 55)
    bE = knob('B', 'keyhole', 55, 34, 1, 0, r=5.0 * k)
    bS = knob('B', 'keyhole', 30, 55, 0, 1, r=5.0 * k)
    body = c.m(core, minus=(bE, bS))
    c.add(body, STONE)
    # moss cap: top band with rounded drips
    moss = c.m(rect(8, 8, 55, 20), ell(14, 20, 5, 5), ell(27, 21, 4, 4.5), ell(44, 20.5, 6, 5), ell(53, 19, 3, 6)) & body
    c.add(moss, MOSS)
    c.edge(moss, MOSS[1])
    hi = c.m(ell(20, 12, 7, 2.6), ell(31, 13, 3.5, 2)) & body
    c.add(hi, MOSSL)
    # root wrapping diagonally across the lower block
    root = c.m(thick_path([(8, 50), (20, 46), (34, 47.5), (46, 43), (55, 44)], 5.2 if c.small else 4.6)) & body
    c.add(root, ROOT)
    c.edge(root, ROOT[1])
    # stone block seams (64 px only lines; 36 keeps one)
    if not c.small:
        c.line([(9, 29), (20, 29)], SEAM)
        c.line([(46, 29), (54, 29)], SEAM)
        c.line([(20, 29), (20, 23)], SEAM)
        c.line([(46, 29), (46, 26)], SEAM)
        c.line([(9, 40), (14, 40)], SEAM)
        c.line([(14, 40), (14, 45)], SEAM)
        c.line([(48, 39), (52, 39)], SEAM)
    # moss frog curled on the cap (cell motif): bright green mound with a big cream eye
    frog = c.m(ell(46, 14, 7.5, 5.5)) & body
    c.add(frog, K.ramp('#a8d84e'))
    c.edge(frog, MOSS[1])
    fx, fy = c.P(45, 12.5)
    rng = range(-1, 2) if not c.small else range(0, 2)
    for dx in rng:
        for dy in rng:
            c.px(fx + dx, fy + dy, FROGY)
    c.px(fx + (0 if not c.small else 1), fy + (0 if not c.small else 1), K.UMBER)
    # carved face
    c.eye(26, 33)
    c.eye(39, 33)
    c.smile(32.5, 38.5)
    c.blush(21.5, 37)
    c.blush(43.5, 37)


if __name__ == '__main__':
    rep = K.render_pal(fn, 'pl-wroo-1', 'Mossy Topslab', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wroo-1-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wroo-1.png')
    print(rep)
