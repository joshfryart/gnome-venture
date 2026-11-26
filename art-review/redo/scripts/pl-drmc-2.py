import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K

# Moon Croon: an edge piece whose bottom-left corner is the moon's round limb. Cream-to-butter crescent (cell 0-1)
# hugs left + bottom over the dusky violet dark side; flat right side, peg tabs left + bottom, peg blank on top.
DUSK = K.ramp('#55486c')
CREAM = K.ramp('#fff2cc')
BUTTER = K.ramp('#f6d47a')
STAR = '#fff6d8'

def fn(c):
    k = 1.15 if c.small else 1.0
    core = lambda x, y: (12 <= x < 52 and 10 <= y < 52) and not (x < 32 and y > 32 and (x - 32) ** 2 + (y - 32) ** 2 >= 20 ** 2)
    tl = K.knob('T', 'peg', 12, 24, -1, 0, r=5.2 * k)
    tb = K.knob('T', 'peg', 40, 52, 0, 1, r=5.2 * k)
    bt = K.knob('B', 'peg', 36, 10, 0, -1, r=5.2 * k)
    body = c.m(core, tl, tb, minus=(bt,))
    c.add(body, DUSK)
    inner = K.ell(42, 22, 19, 19)
    lit = c.m(core, tl, tb, minus=(bt, inner))
    c.add(lit, CREAM)
    lowlit = lit & c.m(lambda x, y: y > 45 or (x > 30 and y > 40))
    c.add(lowlit, BUTTER)
    # stars on the dark side
    for sx, sy in ((46, 16), (48, 28), (36, 26)):
        x, y = c.P(sx, sy)
        c.px(x, y, STAR)
        if not c.small:
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                c.px(x + dx, y + dy, '#b8a8d0')
    # sleepy humming face on the crescent (closed eyes as little arcs, round 'o' mouth)
    for ex, ey in ((16, 33), (24, 33)):
        x, y = c.P(ex, ey)
        if c.small:
            c.px(x - 1, y, K.UMBER); c.px(x, y + 1, K.UMBER); c.px(x + 1, y, K.UMBER)
        else:
            for dx, dy in ((-2, 0), (-1, 1), (0, 1), (1, 1), (2, 0)):
                c.px(x + dx, y + dy, K.UMBER)
    mx, my = c.P(19.5, 39)
    if c.small:
        c.px(mx, my, K.UMBER); c.px(mx + 1, my, K.UMBER); c.px(mx, my + 1, K.UMBER); c.px(mx + 1, my + 1, K.UMBER)
    else:
        for dx, dy in ((0, -1), (1, -1), (-1, 0), (2, 0), (-1, 1), (2, 1), (0, 2), (1, 2)):
            c.px(mx + dx, my + dy, K.UMBER)
        c.px(mx, my, '#a8505a'); c.px(mx + 1, my, '#a8505a'); c.px(mx, my + 1, '#a8505a'); c.px(mx + 1, my + 1, '#a8505a')
    c.blush(13.5, 37); c.blush(26, 37)
    # tiny hummed note on the dark side
    nx, ny = c.P(41, 38)
    pts = [(0, 0), (1, 0), (2, 0), (0, 1), (1, 1), (2, 1), (2, -1), (2, -2), (2, -3), (2, -4), (3, -4), (4, -3), (4, -2)] if not c.small else [(0, 0), (1, 0), (1, -1), (1, -2), (2, -2)]
    for dx, dy in pts:
        c.px(nx + dx, ny + dy, STAR)

K.render_pal(fn, 'pl-drmc-2', 'Moon Croon', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-drmc-2-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-drmc-2.png')
