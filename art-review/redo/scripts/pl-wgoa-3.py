# pl-wgoa-3 "Squishy Grape Crate": inner-TBTB keyhole. A wooden vineyard crate heaped with purple grapes.
# N tab = the top grape of the heap (keyhole head = one fat grape) with a green stem leaf, S tab = a wooden crate foot,
# E + W keyhole blanks cut into the crate boards. Colours from cell 1-7: grape purple, crate tan/umber wood, vine green.
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

GRAPE = K.ramp('#7a4a9a')
GRAPE_LT = '#c090d8'
WOODR = K.ramp('#b88a50')
WOODD = '#7a5a34'
LEAF = K.ramp('#58a048')


def fn(c):
    S = 1.15 if c.small else 1.0
    crate = K.rect(10, 31, 54, 55)
    heapband = K.rect(10, 22, 54, 32)
    grapes_row = [(16.5, 23.5), (26, 21.5), (38, 21.5), (47.5, 23.5)]
    gr = 6.2
    grape_preds = [K.ell(x, y, gr, gr) for x, y in grapes_row]
    tabN = K.knob('T', 'keyhole', 32, 17.5, 0, -1, r=5.2 * S)
    tabS = K.knob('T', 'keyhole', 32, 55, 0, 1, r=4.0 * S)
    blE = K.knob('B', 'keyhole', 54, 44, 1, 0, r=3.2 * S, nw=2.0)
    blW = K.knob('B', 'keyhole', 10, 44, -1, 0, r=3.2 * S, nw=2.0)
    blanks = (blE, blW)
    # crate wood
    wood = c.add(c.m(crate, tabS, minus=blanks), WOODR, stitch=None)
    # grape heap: band + individual grapes + top grape tab
    heap = c.add(c.m(heapband, *grape_preds, tabN, minus=(K.rect(0, 33, 64, 64),)), GRAPE)
    # inner grape contours (each grape outlined dark) for the heaped look
    for i, (x, y) in enumerate(grapes_row):
        g = c.m(grape_preds[i]) & heap
        c.edge(g, GRAPE[1])
    top = c.m(K.ell(32, 11.5, 4.6 * S, 4.6 * S)) & heap
    c.edge(top, GRAPE[1])
    # second row grapes peeking (dark seams between)
    for x in (21, 32, 43):
        g = c.m(K.ell(x, 29, 5.5, 4)) & heap
        c.edge(g, GRAPE[1])
    # grape glints
    for x, y in grapes_row + [(32, 11.5)]:
        px, py = c.P(x - 2.2, y - 2.2)
        c.px(px, py, GRAPE_LT)
        if not c.small:
            c.px(px + 1, py, GRAPE_LT)
            c.px(px, py + 1, GRAPE_LT)
    # leaf + stem on top grape
    leaf = c.add(c.m(K.poly([(34, 7.5), (40, 3.5), (44, 5), (40, 9.5), (35.5, 9.5)])), LEAF)
    # crate rim (dark top board edge) and board seams
    for x in range(c.P(10, 0)[0], c.P(54, 0)[0]):
        c.px(x, c.P(0, 32.5)[1], WOODD)
    yb = c.P(0, 49)[1]
    for x in range(c.P(10, 0)[0], c.P(54, 0)[0]):
        if (x, yb) in wood:
            c.px(x, yb, WOODD)
    # corner posts
    for xx in (13.5, 50):
        x0 = c.P(xx, 0)[0]
        for y in range(c.P(0, 33)[1], c.P(0, 55)[1]):
            if (x0, y) in wood:
                c.px(x0, y, WOODD)
    # upper board seam + nails on the corner posts
    ys = c.P(0, 45.5)[1]
    for x in range(c.P(10, 0)[0], c.P(54, 0)[0]):
        if (x, ys) in wood:
            c.px(x, ys, WOODD)
    for xx in (12, 51.5):
        for yy in (35, 52):
            c.px(*c.P(xx, yy), WOODR[2])
    # vine leaf tucked into the heap (cell's green band)
    c.add(c.m(K.poly([(10.5, 27), (5.5, 23.5), (6.5, 20), (11.5, 22)])) - wood, LEAF)
    # face on the crate front
    c.eye(26.5, 39)
    c.eye(37.5, 39)
    c.smile(32, 42.5)
    c.blush(22.5, 42.5)
    c.blush(41, 42.5)


K.render_pal(fn, 'pl-wgoa-3', 'Squishy Grape Crate', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wgoa-3-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wgoa-3.png')
