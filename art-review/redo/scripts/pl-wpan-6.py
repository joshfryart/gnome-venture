"""pl-wpan-6 Splinter Paw Panda: whimsy-panda, keyhole. A seated panda face-on IS the piece: square cream body, dark round ears break the
top corners, keyhole tab E = the raised dark paw (pink pad, splinter), keyhole blank W bites the left dark arm, keyhole tab S = the green
bamboo stalk it nibbles (runs from the mouth down out of the body, as in the picture). Cream fur, plum-black patches, pink blush (cell 6-4)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, knob, thick_path

FUR = K.ramp('#f2e8d6')
INK = K.ramp('#3c2e44')
PINK = K.ramp('#f5a0a0')
BAM = K.ramp('#4fae4a')
SRC = '/home/user/gnome-venture/art-review/redo/_src/'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rect(11, 17, 49, 57)
    tabE = knob('T', 'keyhole', 49, 27, 1, 0, r=5.2 * k)
    tabS = knob('T', 'keyhole', 30, 57, 0, 1, r=5.0 * k)
    blankW = knob('B', 'keyhole', 11, 43, -1, 0, r=4.8 * k)
    earL, earR = ell(15.5, 17, 6.5, 6.5), ell(44.5, 17, 6.5, 6.5)
    body = c.m(core, minus=(blankW,))
    c.add(c.m(earL, earR), INK)
    c.add(body, FUR, stitch=None)
    # arms: left arm wraps the blank, right arm rises into the paw tab
    c.add(c.m(ell(13, 46, 7, 11), minus=(blankW,)) & body, INK)
    c.add(c.m(ell(48, 40, 6.5, 13)) & body | c.m(tabE, minus=(core,)) | (c.m(tabE) & c.m(rect(46, 0, 50, 64))), INK)
    # pink paw pad + splinter
    if c.small:
        c.add(c.m(ell(57.5, 27.5, 2.6, 2.6)), PINK)
    else:
        c.add(c.m(ell(57.5, 27.5, 2.6, 2.6)), PINK)
        c.line([(56, 22), (59.5, 25)], '#b07a3a')
    # feet
    c.add(c.m(ell(18, 57, 6, 3.6), ell(42, 57, 6, 3.6)) & c.m(rect(0, 0, 64, 64)), INK)
    # eye patches
    pr = 1.25 if c.small else 1.0
    c.add(c.m(ell(21.5, 30.5, 6.2 * pr, 5.4 * pr), ell(38.5, 30.5, 6.2 * pr, 5.4 * pr)), INK)
    # bamboo stalk from the mouth out through the S tab
    stalk = c.m(rect(27, 39, 33, 58), tabS)
    c.add(stalk, BAM)
    for ny in (45, 52, 59):
        y = c.P(0, ny)[1]
        for x in range(c.n):
            if (x, y) in stalk:
                c.px(x, y, BAM[1])
    if not c.small:
        c.add(c.m(ell(35.5, 46, 2.5, 1.2)), BAM)   # a leaf
    c.add(c.m(ell(30, 36, 2.4, 1.6)), INK)        # nose
    if c.small:
        c.eye(21.5, 30, disc=True)
        c.eye(37, 30, disc=True)
    else:
        c.eye(22.5, 31, disc=False, look=(1, 0))
        c.eye(37.5, 31, disc=False, look=(-1, 0))
        for ex in (22.5, 37.5):
            x, y = c.P(ex, 31)
            c.px(x, y - 2, K.CREAM); c.px(x + 1, y - 2, K.CREAM)
    c.blush(16.5, 37)
    c.blush(42.5, 37)


rep = K.render_pal(fn, 'pl-wpan-6', 'Splinter Paw Panda', '/home/user/gnome-venture/art-review/redo/out',
                   cellfile=SRC + 'pl-wpan-6-cell.png', oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wpan-6.png')
print(rep)
