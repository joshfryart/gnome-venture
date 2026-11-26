import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, thick_path, knob

STRAW = K.ramp('#f0a040')
BAND = K.ramp('#b86a40')
NOODLE = K.ramp('#ffcda8')
BOWL = K.ramp('#3a9cb4')
RIM = K.ramp('#f8acb6')
FISH = K.ramp('#f0586c')
STICK = K.ramp('#915240')


def fn(c):
    k = 1.15 if c.small else 1.0
    # core square 11..53 x 14..52: straw hat on a heap of noodles in a wide teal bowl
    hat = poly([(17, 24), (47, 24), (36, 15), (32, 13), (28, 15)])
    tabN = knob('T', 'round', 32, 14, 0, -1, r=3.6 * k)
    heap = c.m(ell(32, 32, 20, 9.5), rect(12, 28, 52, 34))
    bowl = c.m(rect(11, 33, 53, 40), ell(32, 39, 21, 14), minus=(rect(0, 0, 64, 33),))
    tabW = knob('T', 'round', 11, 41, -1, 0, r=4.2 * k)
    blankE = knob('B', 'round', 53, 41, 1, 0, r=4.2 * k)
    tabS = knob('T', 'round', 32, 52.5, 0, 1, r=4.2 * k)
    sticks = thick_path([(42, 28), (55, 8)], 2.8), thick_path([(46, 29), (59, 11)], 2.8)
    cut = c.m(blankE)
    bowlm = (bowl | c.m(tabW)) - cut
    c.add(c.m(*sticks), STICK)
    c.add(heap - cut, NOODLE)
    c.add(bowlm, BOWL, stitch=None if c.small else '#2a7a90')
    c.add(c.m(tabS) - bowlm, K.ramp('#2e84a4'))
    c.add(c.m(rect(11, 33, 53, 35.5)) - cut, RIM)
    hm = c.m(hat, tabN)
    c.add(hm, STRAW)
    c.edge(hm, BAND[1])
    c.edge(bowlm, BOWL[1])
    _, y = c.P(0, 20.5)
    for x in range(c.n):
        if (x, y) in hm and (x // (1 if c.small else 2)) % 2 == 0:
            c.px(x, y, BAND[0])
    # noodle curls: wavy strands across the heap
    for row in ((26.5, 0), (29.5, 1), (32, 0)):
        _, y = c.P(0, row[0])
        for x in range(c.n):
            if (x, y) in heap and (x, y) not in hm:
                w = (x // (2 if c.small else 3) + row[1]) % 2
                c.px(x, y - w, '#e08a40' if w else NOODLE[2])
    # a pink fishcake on the noodles
    fx, fy = c.P(22, 28)
    for dx in range(-1, 2):
        for dy in range(-1, 1 if c.small else 2):
            c.px(fx + dx, fy + dy, FISH[0])
    c.px(fx, fy, '#ffffff')
    # face on the bowl
    c.eye(25, 41, disc=True)
    c.eye(39, 41, disc=True)
    c.smile(32, 45)
    c.blush(20, 45)
    c.blush(44, 45)
    _, y = c.P(0, 49.5)
    for x in range(c.n):
        if (x, y) in bowl and (x, y - 1) in bowl:
            c.px(x, y - ((x // (2 if c.small else 3)) % 2), '#ffffff' if not c.small else BOWL[2])


K.render_pal(fn, 'pl-flmk-6', 'Noodle Skipper', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-flmk-6-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-flmk-6.png')
