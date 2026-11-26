# Knock Knock: the tearoom's golden arched door as an inner-TBTB piece.
# Top tab = round fanlight on the arch, bottom tab = doorstep stone, left/right blanks bite the door posts.
import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K

TIMBER = K.ramp('#7a4a2c')
GOLD = K.ramp('#f6c85a')
PANE = K.ramp('#fcdc84')
AMBER = K.ramp('#eea24a')
STONE = K.ramp('#a89aa8')
BRASS = '#b07a10'


def fn(c):
    s = 1.15 if c.small else 1.0
    r = 4.5 * s
    core = lambda x, y: (13 <= x < 51 and 22 <= y < 53) or (((x - 32) / 19) ** 2 + ((y - 23) / 13) ** 2 < 1 and y < 24)
    top = K.knob('T', 'round', 32, 10.5, 0, -1, r=r)
    bot = K.knob('T', 'round', 32, 53, 0, 1, r=r)
    lb = K.knob('B', 'round', 13, 36, -1, 0, r=r)
    rb = K.knob('B', 'round', 51, 36, 1, 0, r=r)
    blanks = (lb, rb)
    body = c.m(core, top, bot, minus=blanks)
    c.add(body, TIMBER)
    step = c.m(bot, minus=(K.rect(0, 0, 64, 53),))
    c.add(step, STONE)
    # inner door leaf (inset 3 from frame)
    inner = lambda x, y: (16 <= x < 48 and 23 <= y < 51) or (((x - 32) / 16) ** 2 + ((y - 23) / 10) ** 2 < 1 and y < 24)
    leaf = c.m(inner, minus=(K.knob('B', 'round', 13, 36, -1, 0, r=r + 1.5, nw=4), K.knob('B', 'round', 51, 36, 1, 0, r=r + 1.5, nw=4)))
    c.add(leaf, GOLD)
    # arched glass panes (upper part)
    glass = c.m(lambda x, y: inner(x, y) and y < 27)
    c.add(glass, PANE)
    c.edge(glass, TIMBER[0])
    # lower amber kick panel
    low = c.m(lambda x, y: 16 <= x < 48 and 45 <= y < 51)
    c.add(low, AMBER)
    c.edge(low, TIMBER[1])
    # fanlight in the top tab
    fan = c.m(K.ell(32, 5.5 if not c.small else 4.8, 2.4 * s, 2.4 * s))
    c.add(fan, PANE)
    # mullions: vertical centre bar + horizontal bar through glass
    w = 2.6 if c.small else 1.6
    c.add(c.m(K.thick_path([(32, 12), (32, 27)], w)), TIMBER)
    c.add(c.m(K.thick_path([(16, 20), (48, 20)], w)), TIMBER)
    # plank seams on the gold leaf (door, not lamp)
    if not c.small:
        c.line([(24, 28), (24, 44)], GOLD[1])
        c.line([(40, 28), (40, 44)], GOLD[1])
    # face on the gold leaf
    c.eye(26, 33)
    c.eye(38, 33)
    c.smile(32, 38)
    c.blush(23, 37)
    c.blush(40, 37)
    # brass door knob
    kx, ky = c.P(44, 41)
    for dx in range(0, 2) if c.small else range(-1, 2):
        for dy in range(0, 2) if c.small else range(-1, 2):
            c.px(kx + dx, ky + dy, BRASS)
    c.px(kx, ky, '#f5cf6a')


K.render_pal(fn, 'pl-thch-3', 'Knock Knock', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-thch-3-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-thch-3.png')
