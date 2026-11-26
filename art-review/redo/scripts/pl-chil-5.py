# pl-chil-5 "Cocoa Cauldron": inner-BBBB, round. A clay cocoa pot that is a square piece: the top side is the bubbling cocoa
# surface with a round blank dipped into it, a warm clay rim band, a clay belly wearing the face and a red/green/yellow chilli
# garland (the hanging chilli strings of cell 9-5), side blanks cut into the belly, bottom blank between two stubby pot feet.
import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K

COCOA = K.ramp('#4a2420')
POT = K.ramp('#a85e48')
RIM = K.ramp('#d8905c')
RED = K.ramp('#e83828')
GRN = K.ramp('#58a838')
YEL = K.ramp('#f0c040')
PURP = '#a878a8'


def fn(c):
    k = 1.15 if c.small else 1.0
    lip = K.poly([(8, 9), (56, 9), (56, 19), (8, 19)])
    belly = K.poly([(12, 19), (52, 19), (55, 30), (56, 42), (50, 53), (14, 53), (8, 42), (9, 30)])
    feet = (K.rect(16, 50, 25, 57), K.rect(39, 50, 48, 57))
    bN = K.knob('B', 'round', 32, 9, 0, -1, r=3.7 * k)
    bE = K.knob('B', 'round', 53.5, 27, 1, 0, r=3.4 * k)
    bW = K.knob('B', 'round', 10.5, 27, -1, 0, r=3.4 * k)
    bS = K.knob('B', 'round', 32, 58, 0, 1, r=4.2 * k)
    blanks = (bN, bE, bW, bS)
    body = c.m(belly, minus=blanks)
    c.add(body, POT, stitch=None if c.small else '#c88468')
    c.add(c.m(*feet, minus=blanks + (belly,)), K.ramp('#64384a'))
    lipm = c.m(lip, minus=blanks)
    c.add(lipm, RIM)
    cocoa = c.m(K.ell(32, 14, 21, 3.6), minus=blanks)
    c.add(cocoa, COCOA)
    c.edge(c.m(lip), RIM[1])
    # bubbles on the cocoa
    for (bx, by) in ((19, 13.5), (44, 13.5), (39, 15)):
        x, y = c.P(bx, by)
        c.px(x, y, '#c89a80')
        if not c.small:
            c.px(x + 1, y, '#9a6a54'); c.px(x, y + 1, '#9a6a54')
    # purple steam puffs sitting on the lip corners
    for hx in (11.5, 52.5):
        x, y = c.P(hx, 11.5)
        c.px(x, y, PURP)
        if not c.small:
            c.px(x, y + 1, PURP)
    # chilli garland swag across the belly
    sw = [(9, 38), (18, 44), (32, 46), (46, 44), (55, 38)]
    c.line(sw, '#245b40')
    chil = [(13, 40, GRN), (19, 43.5, RED), (25.5, 45, YEL), (32, 45.5, GRN), (38.5, 45, RED), (45, 43.5, YEL), (51, 40, RED)]
    for (cx, cy, rr) in chil:
        x, y = c.P(cx, cy)
        h = 3 if c.small else 5
        w0 = 2 if c.small else 3
        for dy in range(h):
            w = max(1, w0 - (dy * w0) // h)
            for dx in range(w):
                col = rr[2] if (dx == 0 and dy < 2) else rr[0]
                if dy == h - 1 or dx == w - 1 and w > 1:
                    col = rr[1] if dy >= 2 else rr[0]
                c.px(x + dx, y + dy, col)
    # face on the belly
    c.eye(25, 31)
    c.eye(39, 31)
    c.smile(32, 35.5, wide=True)
    c.blush(19.5, 35)
    c.blush(43.5, 35)


K.render_pal(fn, 'pl-chil-5', 'Cocoa Cauldron', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-chil-5-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-chil-5.png')
