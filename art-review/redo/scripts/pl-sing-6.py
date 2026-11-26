# Concept: a chibi bluebird that is a rare whimsy piece; keyhole tab out the left (chest) and bottom (feet),
# keyhole blank cut into its back under the tail; waterfall blue feathers, lavender stone-brick belly, yellow note beak/song from cell 4-4.
import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K

BLUE = K.ramp('#3f7fc8')
DEEP = K.ramp('#2c5a9c')
LAVS = K.ramp('#a49cc8')
NOTE = K.ramp('#f0c838')


def fn(c):
    s = 1.15 if c.small else 1.0
    core = K.poly([(13, 26), (16, 21), (50, 21), (52, 24), (52, 53), (13, 53)])
    head = K.ell(27, 20, 14, 12)
    tail = K.poly([(44, 22), (60, 9), (63, 15), (52, 32)])
    beak = K.poly([(15, 15), (4, 19), (15, 23)])
    tL = K.knob('T', 'keyhole', 13, 41, -1, 0, r=5.6 * s, nw=2.2)
    tB = K.knob('T', 'keyhole', 30, 53, 0, 1, r=5.6 * s, nw=2.2)
    bR = K.knob('B', 'keyhole', 52, 43, 1, 0, r=6.0 * s, nw=2.6)
    body = c.m(core, head, tail, tL, tB, minus=(bR,))
    c.add(body, BLUE, stitch=None)
    # belly: lavender stone with brick lines
    belly = c.m(K.ell(28, 42, 13, 11), tL, minus=(bR,))
    belly &= body
    c.add(belly, LAVS)
    c.edge(belly, LAVS[1])
    if not c.small:
        for yy in (38, 44):
            c.line([(18, yy), (38, yy)], LAVS[1])
        c.line([(28, 38), (28, 44)], LAVS[1])
        c.line([(22, 44), (22, 50)], LAVS[1])
        c.line([(34, 44), (34, 50)], LAVS[1])
    # wing (deep blue) on back
    wing = c.m(K.ell(41, 30, 9, 8), minus=(bR,)) & body
    c.add(wing, DEEP)
    c.edge(wing, DEEP[1])
    # yellow feet tab and beak
    feet = c.m(tB) & body - c.m(K.rect(0, 0, 64, 53))
    c.add(c.m(beak), NOTE)
    c.add(feet, NOTE)
    # face
    c.eye(24, 17)
    c.blush(19, 23) if not c.small else c.blush(19, 23)
    # tail tip feathers deep blue
    c.add(c.m(K.poly([(54, 16), (60, 9), (63, 15), (57, 22)])) & body, DEEP)
    # yellow singing note on the wing (the cell's note)
    if c.small:
        c.add(c.m(K.ell(39.5, 33, 3.6, 3.0), K.rect(41, 22, 43.5, 33), K.poly([(41, 22), (47, 25), (47, 28), (43, 26)])), NOTE)
    else:
        c.add(c.m(K.ell(39.5, 33, 3.4, 2.6), K.rect(41.4, 22, 43.2, 33), K.poly([(41.4, 22), (47, 25), (47, 28), (43, 25.6)])), NOTE)

K.render_pal(fn, 'pl-sing-6', 'Hollowhome Bluebird', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-sing-6-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-sing-6.png')
