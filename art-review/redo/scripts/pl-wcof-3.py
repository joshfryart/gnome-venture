import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
from pal_kit import rect, ell, poly, thick_path, knob

CLAY = K.ramp('#8a5a44')
CLAYD = K.ramp('#6a4038')
COAL = ('#4a2c22', '#2f1c16', '#6a3a2a')
RUGR = K.ramp('#d8402a')
RUGY = K.ramp('#f0c030')
TEAL = K.ramp('#2a9a9a')
EMBER = '#f08a2a'
HOT = '#f8d060'
RED = '#d8402a'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = lambda x, y: (11 <= x < 53 and 30 <= y < 57) or ell(32, 35, 21, 15)(x, y) or (28.5 <= x < 35.5 and 15 <= y < 24)
    tabN = knob('T', 'keyhole', 32, 16, 0, -1, r=4.4 * k, nw=2.4)
    blankW = knob('B', 'keyhole', 11, 40, -1, 0, r=3.0 * k, nw=2.0)
    blankE = knob('B', 'keyhole', 53, 40, 1, 0, r=3.0 * k, nw=2.0)
    blankS = knob('B', 'keyhole', 32, 57, 0, 1, r=3.2 * k, nw=2.0)
    spout = thick_path([(47, 24), (53, 19), (57, 13)], 4.2 if c.small else 3.6)
    cut = (blankW, blankE, blankS)
    body = c.m(core, tabN, spout, minus=cut)
    c.add(body, CLAY, stitch=None)
    # neck + lid: darker clay, round lid knob yellow-ish rim
    neck = c.m(tabN, rect(28.5, 15, 35.5, 22.5)) & body
    c.add(neck, CLAYD)
    # warm glow from the coals on the pot's base
    c.add(body & c.m(rect(0, 41.5, 64, 46)), K.ramp('#b06a44'))
    # brazier band of coals, glowing
    coal = body & c.m(rect(0, 46, 64, 64))
    c.add(coal, COAL)
    # rug stripe rim of brazier (red/yellow/teal blocks) at top of the coals
    rim = body & c.m(rect(0, 45, 64, 48.5))
    c.add(rim & c.m(lambda x, y: (x // 6) % 3 == 0), RUGR)
    c.add(rim & c.m(lambda x, y: (x // 6) % 3 == 1), RUGY)
    c.add(rim & c.m(lambda x, y: (x // 6) % 3 == 2), TEAL)
    # glowing coal lumps
    for (cx_, cy_, rx_) in ((16, 52, 4.2), (25, 53.5, 3.6), (39, 53.5, 3.6), (48, 52, 4.2)):
        lump = coal & c.m(ell(cx_, cy_, rx_, 3.0))
        c.add(lump, ('#e0702a', '#a8301a', '#f8d060'))
    # sheen on the pot belly (upper left)
    if not c.small:
        c.line([(17, 31), (19, 27), (23, 24)], '#c89a7a')
    else:
        c.line([(17, 30), (21, 25)], '#c89a7a')
    # face
    c.eye(24, 34, disc=True)
    c.eye(40, 34, disc=True)
    # grumbling wavy mouth
    cx, cy = c.P(32, 40)
    if not c.small:
        for i, dx in enumerate(range(-3, 4)):
            c.px(cx + dx, cy + (i % 2), K.UMBER)
    else:
        for i, dx in enumerate(range(-2, 2)):
            c.px(cx + dx, cy + (i % 2), K.UMBER)
    c.blush(19.5, 38)
    c.blush(43.5, 38)


K.render_pal(fn, 'pl-wcof-3', 'Grumbling Coals', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wcof-3-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wcof-3.png')
