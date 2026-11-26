"""pl-pgg-2 Squawk Shanty: edge-TTB, tri. A singing pirate gull afloat. Flat S = the waterline (teal sea from cell 5-5),
tri blank N = the dip of its tricorn hat, tri tab E = the open orange beak mid-squawk, tri tab W = its grey tail."""
import math
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

R = '/home/user/gnome-venture/'
GULL = K.WHITE
WING = K.ramp('#a8b0bc')
SEA = K.ramp('#3aa6c8')
SEA2 = '#2a88b4'
FOAM = '#cdeef4'
BEAK = K.ramp('#f0a020')
HAT = K.ramp('#34405a')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(12, 10, 50, 58)
    blankN = K.knob('B', 'tri', 31, 10, 0, -1, r=3.4 * k)
    tabE = K.knob('T', 'tri', 50, 32, 1, 0, r=5.0 * k)
    tabW = K.knob('T', 'tri', 12, 41, -1, 0, r=4.6 * k)
    body = c.m(core, tabE, tabW, minus=(blankN,))
    c.add(body, GULL)
    # tail: the W tab, grey with a dark tip
    tail = c.m(tabW, minus=(core,)) | (c.m(tabW) & c.m(K.rect(0, 0, 14, 64)))
    c.add(tail & body, WING)
    # grey wing folded on the side
    wing = c.m(K.ell(28, 42, 13, 7)) & body
    c.add(wing, WING)
    if not c.small:
        for dx in (0, 4, 8):
            c.line([(24 + dx, 43), (28 + dx, 46)], WING[1])
    # tricorn hat: the N blank is the dip between its two raised corners
    hat = c.m(K.rect(0, 0, 64, 21 if not c.small else 21.5)) & body
    c.add(hat, HAT)
    c.add(c.m(K.rect(12, 19, 50, 21.5 if not c.small else 22.5)) & body, K.GOLD)
    # beak: the E tab, open at the base (singing)
    beak = c.m(tabE, minus=(core,)) | (c.m(tabE) & c.m(K.rect(47, 0, 64, 64)))
    c.add(beak & body, BEAK)
    c.line([(47, 32), (54, 32)], K.UMBER2)
    # sea at the bottom, wavy top, flat waterline edge
    sea = c.m(lambda x, y: y > 49 + 1.8 * math.sin(x / 2.6) and 0 <= y < 58) & body
    c.add(sea, SEA)
    for (x, y) in sea:
        X, Y = (x + 0.5) / c.k, (y + 0.5) / c.k
        if 53 < Y < 54.5 and (x // (3 if c.small else 4)) % 2 == 0:
            c.px(x, y, SEA2)
    for (x, y) in sea:
        if (x, y - 1) not in sea and (x, y - 1) in body:
            c.px(x, y, FOAM)
    c.eye(40, 28)
    c.blush(44, 35)


K.render_pal(fn, 'pl-pgg-2', 'Squawk Shanty', R + 'art-review/redo/out',
             cellfile=R + 'art-review/redo/_src/pl-pgg-2-cell.png',
             oldfile=R + 'game/assets/img/puzzles/pals/pl-pgg-2.png')
