"""pl-sll-1 Cairn Stack: corner-TT, round. A cairn of mauve stones as one corner piece: flat W + S sides, N tab = round snow-capped
capstone, E tab = a wedged pebble. Prayer-flag pennants strung across; colours from cell 6-6 (mauve rock, lavender snow, peach sky)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

ROCK = K.ramp('#a585a2')
ROCK2 = K.ramp('#c0a0b8')
ROCK3 = K.ramp('#8a6a8c')
SNOW = ('#d8c8e8', '#a8a0c8', '#fff4f4')
LINE = '#5e4660'
FLAGS = ('#3f7fc8', '#f6b8b0', '#d6322b', '#3f9a4a', '#f0c030')


def fn(c):
    k = 1.15 if c.small else 1.0
    x0, y0, x1, y1 = 9, 17, 53, 57
    core = K.rect(x0, y0, x1, y1)
    tabN = K.knob('T', 'round', 30, y0, 0, -1, r=6.0 * k, nw=4.4)
    tabE = K.knob('T', 'round', x1, 39, 1, 0, r=5.0 * k, nw=3.0)
    # stones: rounded on the right (stacked pebbles), flush on the flat W side
    def stone(a_, b_, xr, rr):
        h = (b_ - a_) / 2
        return c.m(K.rect(x0, a_, xr - rr, b_), K.ell(xr - rr, a_ + h, rr, h + 0.01))
    slab = stone(44, y1, 55, 5)
    mid = stone(30, 44.6, 53, 7)
    top = stone(y0, 30.6, 50, 7)
    body = c.m(K.rect(x0, y0 + 4, x0 + 20, y1), tabN, tabE) | slab | mid | top
    body = body - c.m(K.rect(x1 + 2.5, 0, 64, 64), minus=(tabE,))
    c.add(body, ROCK)
    c.add(slab, ROCK3)
    c.add(mid, ROCK)
    c.add(top, ROCK2)
    cap = c.m(tabN, minus=(core,))
    c.add(cap, ROCK2)
    c.add(c.m(K.ell(30, 6.5 + (0.5 if c.small else 0), 5.2 * k, 3.2 * k), minus=(core,)) & cap, SNOW)
    c.add(c.m(K.ell(28, y0 + 0.5, 15, 2.2)) & top, SNOW)
    peb = c.m(tabE) - mid
    c.add(peb, ROCK3)
    c.edge(mid, LINE)
    # mottled rock blotches, as in the cell
    for (bx, by, rx, ry, st, rp) in ((44, 51, 5, 3, slab, ROCK3[1]), (18, 52, 4, 2.4, slab, ROCK3[1]),
                                     (46, 36, 3.5, 2.6, mid, ROCK3[0]), (14, 33, 3, 2, mid, ROCK3[0]),
                                     (40, 21, 3, 2, top, ROCK[0]), (13, 26, 2.6, 2, top, ROCK[0])):
        c.add(c.m(K.ell(bx, by, rx, ry)) & st, (rp, rp, rp))
    c.edge(top, LINE)
    # speckles on rock
    for (sx, sy) in ((14, 50), (33, 52), (48, 49), (16, 28), (44, 28), (13, 36)):
        x, y = c.P(sx, sy)
        c.px(x, y, ROCK3[1])
        if not c.small:
            c.px(x + 1, y, ROCK3[1])
    # pennant string across the top stone
    pts = [(9, 21), (20, 25), (31, 26.5), (41, 25), (50, 21.5)]
    c.line(pts, '#6a4a3a')
    for i, (fx, fy) in enumerate([(14, 23), (22.5, 25.5), (31, 26.6), (39, 25.5), (46, 23)]):
        x, y = c.P(fx, fy)
        col = FLAGS[i]
        if c.small:
            for dx, dy in ((0, 1), (1, 1), (0, 2)):
                c.px(x + dx, y + dy, col)
        else:
            for dx, dy in ((-1, 1), (0, 1), (1, 1), (-1, 2), (0, 2), (1, 2), (-1, 3), (0, 3), (-1, 4)):
                c.px(x + dx, y + dy, col)
    # face on the middle stone
    c.eye(24, 36.5)
    c.eye(36, 36.5)
    c.smile(30, 39.5)
    c.blush(19.5, 40)
    c.blush(40.5, 40)


K.render_pal(fn, 'pl-sll-1', 'Cairn Stack', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-sll-1-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-sll-1.png')
