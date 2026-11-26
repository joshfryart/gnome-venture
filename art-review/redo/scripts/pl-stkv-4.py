"""pl-stkv-4 Bowtie Bundle. Inner-TTTT, keyhole: a cream gift parcel (the cottage wall cream, cell 4-6) IS the square piece.
A red ribbon (roof-tile red) crosses it; N keyhole tab = the bow knot with two loops either side, E + W keyhole tabs = ribbon ends,
S keyhole tab = a window-gold gift tag. Felt face in the parcel's upper quadrants."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

CREAM = K.ramp('#f2e2b8')
RED = K.ramp('#c8463a')
GOLD = K.ramp('#f4c85a')
SAND = K.ramp('#c8925a')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(13, 22, 51, 54)
    tN = K.knob('T', 'keyhole', 32, 22, 0, -1, r=5.4 * k)
    tE = K.knob('T', 'keyhole', 51, 38, 1, 0, r=4.4 * k)
    tW = K.knob('T', 'keyhole', 13, 38, -1, 0, r=4.4 * k)
    tS = K.knob('T', 'keyhole', 32, 54, 0, 1, r=5.0 * k)
    loopL = K.ell(23, 20, 6.5, 3.6)
    loopR = K.ell(41, 20, 6.5, 3.6)
    body = c.m(core)
    c.add(body, CREAM, stitch=None if c.small else '#d8c08a')
    # sandy bottom band (the ground under the wall)
    c.add(body & c.m(K.rect(0, 50, 64, 64)), SAND)
    # ribbon cross + E/W ends
    rib = c.m(K.rect(28.5, 22, 35.5, 54), K.rect(13, 35, 51, 41.5), tE, tW, minus=(K.ell(32, 22, 0.1, 0.1),))
    c.add(rib, RED)
    # bow loops and knot
    loops = c.m(loopL, loopR)
    c.add(loops, RED)
    hw = 1.2 if c.small else 1.0
    inner = c.m(K.ell(23, 20, 3.4, hw * 1.6), K.ell(41, 20, 3.4, hw * 1.6))
    c.edge(loops, RED[1])
    for p in inner:
        c.px(p[0], p[1], RED[1])
    c.add(c.m(tN, minus=(core,)) | (c.m(tN) & c.m(K.rect(0, 20, 64, 23))), K.ramp('#d85a48'))
    # gift tag
    c.add(c.m(tS, minus=(core,)), GOLD)
    hx, hy = c.P(32, 62)
    c.px(hx, hy, K.UMBER2)
    # little window-gold sparkle dots on the paper
    if not c.small:
        for (x, y) in [(17, 27), (46, 46), (18, 46), (46, 27)]:
            c.px(*c.P(x, y), GOLD[0])
    c.eye(22, 30)
    c.eye(42, 30)
    c.blush(18, 33.5)
    c.blush(45.5, 33.5)
    c.smile(32, 45, K.CREAM)


K.render_pal(fn, 'pl-stkv-4', 'Bowtie Bundle', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-stkv-4-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-stkv-4.png')
