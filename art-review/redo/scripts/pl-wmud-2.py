import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
# Wobbly Bookpile: edge-TTB keyhole. A leaning pile of four books IS the piece: flat S (bottom book on the sand),
# keyhole tab N = the string knot that ties the pile, keyhole tab E = a book sliding out of the pile, keyhole blank W bites the stack.
# Book colours from the book pile by the gate (green / gold / blue / red, cream pages), string tan, cell sand + bush green.
RED = K.ramp('#b8444a'); BLUE = K.ramp('#3a80a8'); GOLD = K.ramp('#f0b440'); GREEN = K.ramp('#5fa64a')
PAGE = K.ramp('#f6e2b0'); STRING = K.ramp('#c8964a')
SRC = '/home/user/gnome-venture/'

def fn(c):
    k = 1.15 if c.small else 1.0
    # books, top to bottom, each nudged sideways (the wobble)
    books = [(13, 16, 50, 26.5, RED, 'edge'), (11, 26.5, 48.5, 37, BLUE, 'spine'),
             (12, 37, 52, 47.5, GOLD, 'edge'), (11, 47.5, 51, 58, GREEN, 'spine')]
    tabN = K.knob('T', 'keyhole', 24, 16, 0, -1, r=5.0 * k)
    tabE = K.knob('T', 'keyhole', 52, 42, 1, 0, r=4.6 * k)
    blankW = K.knob('B', 'keyhole', 11, 37.5, -1, 0, r=5.0 * k)
    for (x0, y0, x1, y1, rp, kind) in books:
        m = c.m(K.rect(x0, y0, x1, y1), minus=(blankW,))
        c.add(m, rp)
        if kind == 'edge':
            # fore-edge: cream page block between thin covers, on the right part
            pg = c.m(K.rect(x0 + 8, y0 + 2.6, x1 - 0.5, y1 - 2.6), minus=(blankW,)) & m
            c.add(pg, PAGE)
            if not c.small:
                for yy in range(c.P(0, y0 + 4)[1], c.P(0, y1 - 3)[1], 2):
                    for xx in range(c.P(x0 + 9, 0)[0], c.P(x1 - 1, 0)[0]):
                        if (xx, yy) in pg:
                            c.px(xx, yy, PAGE[1])
        else:
            # spine: gold bands near each end
            for bx in ((x0 + 4,) if rp is BLUE else (x0 + 4, x1 - 6)):
                band = c.m(K.rect(bx, y0, bx + (2.2 if not c.small else 2.8), y1)) & m
                c.add(band, K.ramp('#f5cf6a'))
        c.edge(m, rp[1])
    # tab E: a loose page poking out of the gold book
    te = c.m(tabE, minus=(K.rect(0, 0, 51.5, 64),))
    c.add(te, PAGE)
    c.edge(te, PAGE[1])
    # string: vertical band from the knot down to the bottom, knot = N tab
    sw = 2.0 if not c.small else 2.8
    c.add(c.m(K.rect(24 - sw / 2, 16, 24 + sw / 2, 58)), STRING)
    c.add(c.m(tabN, minus=(K.rect(0, 16, 64, 64),)) | (c.m(tabN) & c.m(K.rect(0, 14, 64, 17))), STRING)
    if not c.small:
        # bow loops lines on the knot
        cx, cy = c.P(24, 8)
        c.px(cx, cy, STRING[1]); c.px(cx - 1, cy + 1, STRING[1]); c.px(cx + 1, cy + 1, STRING[1])
    # face on the blue spine book (left of the string)
    c.eye(34, 30.5, disc=True)
    c.eye(42, 30.5, disc=True)
    c.smile(38, 33.5, K.CREAM)
    c.blush(31, 33.5); c.blush(44.5, 33.5)

K.render_pal(fn, 'pl-wmud-2', 'Wobbly Bookpile', '/home/user/gnome-venture/art-review/redo/out',
             cellfile=SRC + 'art-review/redo/_src/pl-wmud-2-cell.png', oldfile=SRC + 'game/assets/img/puzzles/pals/pl-wmud-2.png')
