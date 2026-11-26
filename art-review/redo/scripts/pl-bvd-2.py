import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, knob, thick_path, ramp, UMBER, UMBER2, CREAM

FUR = ramp('#a8683a')      # beaver brown (dam shade)
BELLY = ramp('#e0a868')    # cell mud-orange
TAIL = ramp('#5e3c2a')
STICK = ramp('#c89050')
WATER = ramp('#3a84c0')    # cell pond blue
EARS = ramp('#7a4a28')


def fn(c):
    """Edge-TTB, peg: a beaver sitting in the pond. Flat S = water line, E peg tab = the flat paddle tail (cross-hatched),
    N peg tab = a gnawed stick held up, W peg blank = a bite chewed out of the side. Dam orange + pond blue from cell 2-5."""
    k = 1.15 if c.small else 1.0
    core = rect(12, 20, 50, 60)
    tabN = knob('T', 'peg', 31, 20, 0, -1, r=4.6 * k)
    blankW = knob('B', 'peg', 12, 41, -1, 0, r=4.8 * k)
    tail = poly([(49, 37), (58, 34.5), (62.5, 37), (62.5, 47), (58, 49.5), (49, 47)])
    earL = ell(15.5, 21, 4.2, 4.2)
    earR = ell(46.5, 21, 4.2, 4.2)
    body = c.m(core, minus=(blankW,))
    c.add(c.m(earL, earR), EARS)
    c.add(c.m(tabN, minus=(core,)) | (c.m(tabN) & c.m(rect(0, 19, 64, 21))), STICK)
    c.add(c.m(tail), TAIL)
    c.add(body, FUR)
    # tail cross-hatch
    for (x, y) in c.m(tail):
        X, Y = (x + .5) / c.k, (y + .5) / c.k
        if X > 51 and ((int(X + Y) % 4 == 0) or (int(X - Y) % 4 == 0)):
            c.px(x, y, TAIL[1])
    # stick end grain / bark stripes
    sx, _ = c.P(31, 0)
    for y in range(c.P(0, 10)[1], c.P(0, 20)[1]):
        if y % 3 == 0:
            for dx in (-1, 0, 1):
                c.px(sx + dx, y, STICK[1])
    # belly
    c.add(c.m(ell(31, 50, 10, 8.5)) & body, BELLY)
    # water band at the bottom (flat side)
    wat = body & c.m(rect(0, 53, 64, 64))
    c.add(wat, WATER)
    y0 = c.P(0, 55.5)[1]
    for x in range(c.n):
        if (x, y0) in wat and (x // 2) % 3 != 2:
            c.px(x, y0, WATER[2])
    # inner ear
    for ex in (15.5, 46.5):
        c.px(*c.P(ex, 21), '#d89070')
    # face: eyes, nose, buck teeth
    c.eye(23.5, 29)
    c.eye(38.5, 29)
    c.add(c.m(ell(31, 35.5, 5.5, 3.6)), BELLY)
    nx, ny = c.P(31, 33.5)
    for dx in ((-1, 0) if c.small else (-2, -1, 0, 1)):
        c.px(nx + dx, ny, UMBER)
    tx, ty = c.P(29, 37.5)
    tw = 2 if c.small else 3
    th = 2 if c.small else 4
    for dx in range(tw * 2 + (0 if c.small else 1)):
        for dy in range(th):
            col = UMBER2 if (not c.small and dx == tw) else CREAM
            c.px(tx + dx, ty + dy, col)
    c.blush(19, 34)
    c.blush(42, 34)


K.render_pal(fn, 'pl-bvd-2', 'Paddletail Slap', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-bvd-2-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-bvd-2.png')
