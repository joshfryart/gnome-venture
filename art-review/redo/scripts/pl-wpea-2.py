"""pl-wpea-2 Marmalade Minnow: edge-TTB keyhole. An orange minnow seen side-on, facing east, that IS the piece.
Flat S = the pearly belly line; N keyhole tab = dorsal fin; W keyhole tab = tail fin; E keyhole blank = the open, gulping mouth.
Colours: minnow orange from the picture's school of fish, shell peach + pearl cream from cell 4-4 for fins and belly, cove blue for bubble/fin rays."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

ORANGE = K.ramp('#ee8a24')
PEACH = K.ramp('#e8c4a4')
FIN = K.ramp('#d8601e')
PEARL = K.ramp('#f6ece0')
STRIPE = '#c8601a'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(15, 19, 54, 52)
    # round the head's top-east corner a little (fish forehead), keep sides straight between knobs
    head_cut = lambda x, y: x > 44 and (y < 29 and ((x - 44) / 10) ** 2 + ((y - 29) / 10) ** 2 > 1 or y > 45 and ((x - 44) / 10) ** 2 + ((y - 45) / 7) ** 2 > 1)
    tail_cut = lambda x, y: x < 19 and y < 23 and ((x - 19) / 4) ** 2 + ((y - 23) / 4) ** 2 > 1
    tabN = K.knob('T', 'keyhole', 31, 19, 0, -1, r=6.4 * k, nw=3.4)
    tabW = K.knob('T', 'keyhole', 15, 35, -1, 0, r=6.0 * k, nw=3.4)
    fan = K.poly([(11, 30), (0.5, 20), (5, 35), (0.5, 50), (11, 40)])
    mouthE = K.knob('B', 'keyhole', 54, 37, 1, 0, r=5.0 * k, nw=3.0)
    body = c.m(core, tabN, tabW, fan, minus=(mouthE, head_cut, tail_cut))
    c.add(body, ORANGE, stitch=None if c.small else '#f8c070')
    # fins (tabs) in shell peach with orange rays
    finN = body & c.m(tabN, minus=(core,))
    finN |= body & c.m(K.rect(22, 18, 40, 20.5)) & c.m(tabN)
    finW = body & c.m(tabW, fan, minus=(core,))
    finW |= body & c.m(K.rect(13, 26, 16.5, 44)) & c.m(tabW)
    c.add(finN, FIN)
    c.add(finW, FIN)
    # pearly belly band along the flat south side
    belly = body & c.m(lambda x, y: y > 45 + 2.5 * ((x - 34) / 20) ** 2 and x < 54)
    c.add(belly, PEARL)
    # fin rays
    if not c.small:
        for x0 in (29, 33):
            c.line([(x0, 19), (31 + (x0 - 31) * 1.5, 9)], PEACH[0])
        for y0 in (31, 35, 39):
            c.line([(14, y0), (3, 35 + (y0 - 35) * 2.2)], PEACH[0])
    else:
        c.line([(31, 18), (31, 9)], PEACH[0])
        c.line([(14, 35), (4, 35)], PEACH[0])
    # minnow stripe down the flank (tiger stripes of the school)
    if not c.small:
        for sx in (24, 30):
            c.line([(sx, 22), (sx - 1, 45)], STRIPE)
    else:
        c.line([(26, 22), (25, 44)], STRIPE)
    # gill arc
    gill = c.m(K.ell(45, 37, 8, 12)) - c.m(K.ell(46.4, 37, 8, 12))
    c.edge(gill & body & c.m(K.rect(0, 26, 64, 46)), ORANGE[1])
    c.eye(46, 30, disc=True)
    c.blush(47, 41) if not c.small else None
    # a little bubble from the mouth (cove blue), inside the body is not possible -> blue scale dots on the flank instead
    if not c.small:
        for (bx, by) in ((34, 28), (38, 33), (33, 37)):
            px, py = c.P(bx, by)
            c.px(px, py, ORANGE[2])


K.render_pal(fn, 'pl-wpea-2', 'Marmalade Minnow', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wpea-2-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wpea-2.png')
