import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K

ROSE = K.ramp('#e09a8c')
PALE = K.ramp('#f2c8a4')
PLUM = K.ramp('#8e4466')
FLUTE = '#c87a78'
GOLD = K.ramp('#f0c030')
FLAG = ('#3f9a9a', '#f0c030', '#d6322b', '#3f9a4a')


def fn(c):
    k = 1.15 if c.small else 1.0
    top = K.knob('T', 'tri', 32, 12, 0, -1, r=4.6 * k)
    bot = K.knob('T', 'tri', 32, 53, 0, 1, r=3.8 * k)
    lb = K.knob('B', 'tri', 17, 32, -1, 0, r=3.4 * k, nw=2.2)
    rb = K.knob('B', 'tri', 47, 32, 1, 0, r=3.4 * k, nw=2.2)
    shaft = K.rect(17, 18, 47, 47)
    capr = K.rect(11, 12, 53, 17)
    ech = K.rect(14, 16, 50, 20)
    baser = K.rect(12, 46, 52, 53)
    body = c.m(shaft, minus=(lb, rb))
    c.add(body, ROSE)
    cap = c.m(capr, ech, top)
    c.add(cap, PALE)
    base = c.m(baser, bot)
    c.add(base, PLUM)
    c.edge(cap, PLUM[1])
    c.edge(base, PLUM[1])
    # flutes on the shaft
    for fx in ((21, 26, 38, 43) if not c.small else (21, 42)):
        c.line([(fx, 21), (fx, 44)], FLUTE)
    if not c.small:
        for fx in (22, 27, 39, 44):
            c.line([(fx, 21), (fx, 44)], ROSE[2])
    # bunting on the capital
    for i, fx in enumerate(range(14, 51, 6)):
        x, y = c.P(fx, 14.5)
        col = FLAG[i % 4]
        c.px(x, y, col); c.px(x + 1, y, col)
        if not c.small:
            c.px(x + 2, y, col); c.px(x + 1, y + 1, col)
    # lantern in the pediment
    lx, ly = c.P(32, 7)
    for dx in range(-1, 1 if c.small else 2):
        for dy in range(-1, 1 if c.small else 2):
            c.px(lx + dx, ly + dy, GOLD[0])
    c.px(lx - 1, ly - 1, GOLD[2])
    # face on the shaft
    c.eye(28.5, 28)
    c.eye(35.5, 28)
    c.smile(32, 34)
    c.blush(25.5, 32)
    c.blush(37.5, 32)


print(K.render_pal(fn, 'pl-rrc-3', 'Rosestone Pillar', '/home/user/gnome-venture/art-review/redo/out',
                   cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-rrc-3-cell.png',
                   oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-rrc-3.png'))
