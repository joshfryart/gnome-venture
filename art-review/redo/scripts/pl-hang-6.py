"""pl-hang-6 Swallow Swoop (whimsy-swallow, keyhole): a chibi swallow facing right; the body is a squarish piece.
Forked tail flicks out of the upper-left corner; keyhole tabs E (cream chest) and S (green seed sprig in its feet);
keyhole blanks N (a notch in the back) and W. Sky periwinkle blues + garden greens from cell 2-1."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, thick_path, knob, ramp

BACK = ramp('#4a64b0')      # deep swallow blue, darker sky
WING = ramp('#34478a')
SKY = ramp('#88a4d8')       # sky periwinkle (cell)
BELLY = ramp('#f2ead6')
THROAT = ramp('#d0482e')
LEAF = ramp('#5db555')      # cell foliage
LEAF2 = ramp('#7ad060')
SEED = ramp('#c89a52')
BEAK = ramp('#5a4634')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = lambda x, y: (rect(14, 18, 50, 50)(x, y) and not (
        (x < 18 and y < 22 and (x - 18) ** 2 + (y - 22) ** 2 > 16) or
        (x > 46 and y < 22 and (x - 46) ** 2 + (y - 22) ** 2 > 16) or
        (x < 18 and y > 46 and (x - 18) ** 2 + (y - 46) ** 2 > 16) or
        (x > 46 and y > 46 and (x - 46) ** 2 + (y - 46) ** 2 > 16)))
    tabE = knob('T', 'keyhole', 50, 39, 1, 0, r=5.0 * k, nw=3.0)
    tabS = knob('T', 'keyhole', 31, 50, 0, 1, r=5.0 * k, nw=3.0)
    blankN = knob('B', 'keyhole', 29, 18, 0, -1, r=4.0 * k)
    blankW = knob('B', 'keyhole', 14, 36, -1, 0, r=5.2 * k, nw=3.0)
    tw = 4.2 if c.small else 3.6
    tail1 = thick_path([(18, 22), (11, 15), (4, 5)], tw)
    tail2 = thick_path([(18, 24), (9, 21), (2, 20)], tw)
    beak = poly([(49, 22.5), (58, 26.5), (49, 30)])
    body = c.m(core, tabE, minus=(blankN, blankW))
    # back (upper) blue, belly cream
    c.add(body, BACK)
    c.add(c.m(tail1, tail2, minus=(core,)), BACK)
    c.add(body & c.m(lambda x, y: y > 33 + (x - 30) * -0.25 and x > 20), BELLY, stitch='#d8ccb0')
    c.add(c.m(tabE, minus=(core,)) | (body & c.m(rect(44, 32, 64, 64), minus=(lambda x, y: y < 30,))), BELLY)
    # red throat patch under the beak
    c.add(body & c.m(ell(46, 30, 6, 4.2)), THROAT)
    # tucked wing: dark blue teardrop on the side, pointed tip toward the tail
    wing = c.m(poly([(20, 30), (30, 26), (38, 30), (38, 38), (30, 42), (22, 40), (16, 44)]), minus=(blankW,)) & body
    c.add(wing, WING)
    c.edge(wing, WING[1])
    if not c.small:
        c.line([(23, 36), (33, 33)], SKY[0])
        c.line([(24, 39), (34, 37)], SKY[0])
    else:
        c.line([(24, 37), (33, 34)], SKY[0])
    # beak
    c.add(c.m(beak, minus=(core,)) | (c.m(beak) & body), BEAK)
    # seed sprig in the feet (S tab): green leaves with seed dots, little orange feet on top
    sprig = c.m(tabS, minus=(core,))
    c.add(sprig, LEAF)
    if not c.small:
        for (x, y) in [(29, 55), (32, 57), (30, 59), (33, 54)]:
            c.px(*c.P(x, y), SEED[0])
        c.line([(31, 51), (31, 60)], LEAF[1])
    else:
        c.px(*c.P(30, 56), SEED[0])
        c.px(*c.P(33, 58), SEED[0])
    c.add(c.m(rect(26, 49, 29, 52.5), rect(34, 49, 37, 52.5)), ramp('#e08a3a'))
    # face: big eye near the front of the head, blush on the cheek
    c.eye(41, 25, disc=True)
    c.blush(38, 31)
    # sky-blue sheen on the crown
    if not c.small:
        c.line([(32, 20.5), (44, 20.5)], SKY[2])


K.render_pal(fn, 'pl-hang-6', 'Swallow Swoop', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-hang-6-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-hang-6.png')
