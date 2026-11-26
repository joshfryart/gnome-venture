"""pl-sll-2 Ledge Hop: edge-BTB peg. A snow leopard cub sitting face-on IS the piece: flat W side, N peg blank = the dip between its ears,
E peg tab = its thick ringed tail tip, S peg blank = the gap between its front paws, which sit on a purple ledge with the cell's checker top.
Fur white/lavender with purple rosettes, pink nose and ears (cell 1-6: pink sky, purple ridge)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

FUR = ('#ece8f2', '#aea2c6', '#ffffff')
LEDGE = ('#5c4a7e', '#3e3058', '#8a76aa')
PINK = ('#f2a6b0', '#c87888', '#f8ccd2')
ROS = '#6a5a8c'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.poly([(10, 14), (13, 9), (19, 11), (41, 11), (47, 9), (50, 14), (50, 58), (10, 58)])
    blankN = K.knob('B', 'peg', 30, 11, 0, -1, r=4.2 * k)
    blankS = K.knob('B', 'peg', 30, 58, 0, 1, r=3.8 * k)
    tabE = K.knob('T', 'peg', 50, 34, 1, 0, r=4.6 * k)
    cut = (blankN, blankS)
    body = c.m(core, tabE, minus=cut)
    c.add(body, FUR, stitch=None)
    # tail: band running down the right side, its tip the E peg tab, with purple rings
    tail = c.m(tabE, K.rect(44, 26, 50, 44), minus=cut)
    c.add(tail, FUR)
    c.edge(tail - c.m(K.rect(50, 0, 64, 64)), FUR[1])
    for tx in ((53, 56.5), (59.5, 62)):
        c.add(tail & c.m(K.rect(tx[0], 0, tx[1], 64)), LEDGE)
    c.add(tail & c.m(K.rect(44, 38.5, 50, 41)), LEDGE)
    # ledge band at the bottom with checker top (the cell's ridge)
    ck = 2.0 if not c.small else 1.8
    ledge = c.m(lambda x, y: y >= 53 or (y >= 50.5 and (int(x // ck) + int(y // ck)) % 2 == 0), minus=cut) & body
    c.add(ledge, LEDGE)
    # paws
    pawL = c.m(K.ell(20.5, 50, 6.5, 3.6), minus=cut)
    pawR = c.m(K.ell(39.5, 50, 6.5, 3.6), minus=cut)
    c.add(pawL, FUR)
    c.add(pawR, FUR)
    c.edge(pawL, FUR[1])
    c.edge(pawR, FUR[1])
    if not c.small:
        for x in (18, 23, 37, 42):
            c.line([(x, 48.5), (x, 51.5)], FUR[1])
    # inner ears
    c.add(c.m(K.poly([(13, 12), (14, 15.5), (18, 14)])), PINK)
    c.add(c.m(K.poly([(47, 12), (46, 15.5), (42, 14)])), PINK)
    # rosettes: open purple rings on the flanks, small spots on the brow (snow leopard)
    ring64 = [(-2, -1), (-2, 0), (-1, 1), (-1, -2), (0, -2), (1, -1), (1, 0), (0, 1)]
    ring36 = [(-1, 0), (0, -1), (1, 0), (0, 1)]
    for (x, y) in ((15.5, 25), (15, 36), (23, 42), (37, 42), (16, 45.5)):
        cx, cy = c.P(x, y)
        for dx, dy in (ring36 if c.small else ring64):
            c.px(cx + dx, cy + dy, ROS)
        if not c.small:
            for dx, dy in ((-1, -1), (0, -1), (-1, 0), (0, 0)):
                c.px(cx + dx, cy + dy, FUR[1])
    for (x, y) in ((24, 19), (36, 19), (21, 22), (39, 22)):
        cx, cy = c.P(x, y)
        c.px(cx, cy, ROS)
        if not c.small:
            c.px(cx + 1, cy, ROS)
    # muzzle + face
    c.add(c.m(K.ell(30, 33, 6, 3.8)), ('#f8f6fa', '#d8d0e4', '#ffffff'))
    nx, ny = c.P(30, 30.5)
    for dx in ((-1, 0, 1) if not c.small else (0, 1)):
        c.px(nx + dx, ny, PINK[0])
    if not c.small:
        c.px(nx, ny + 1, PINK[1])
    c.smile(30 if not c.small else 29.5, 33.5, K.UMBER2)
    c.eye(23, 26)
    c.eye(37, 26)
    c.blush(19, 31)
    c.blush(40, 31)


K.render_pal(fn, 'pl-sll-2', 'Ledge Hop', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-sll-2-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-sll-2.png')
