import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
from pal_kit import rect, ell, poly, knob, ramp

ROOF = ramp('#3a3040')
RED = ramp('#d0402a')
PINK = ramp('#eaa0bc')
SUN = ramp('#f0a050')
STONE = ramp('#8a8490')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rect(10, 16, 54, 54)
    top = knob('T', 'keyhole', 32, 10, 0, -1, r=4.6 * k)
    bot = knob('T', 'keyhole', 32, 54, 0, 1, r=4.2 * k)
    lb = knob('B', 'keyhole', 10, 42, -1, 0, r=3.6 * k)
    rb = knob('B', 'keyhole', 54, 42, 1, 0, r=3.6 * k)
    roof = poly([(2, 7), (10, 10), (54, 10), (62, 7), (60, 12), (54, 16), (10, 16), (4, 12)])
    body = c.m(core, roof, top, bot, minus=(lb, rb))
    c.add(body, PINK, stitch='#f6c8d8')
    # sunset glow through the gate
    c.add(c.m(rect(25, 27, 39, 54)) & body, SUN)
    # pillars and beams
    pil = c.m(rect(19, 18, 25, 54), rect(39, 18, 45, 54)) & body
    c.add(pil, RED)
    lintel = c.m(rect(17, 16, 47, 27)) & body
    c.add(lintel, RED)
    nuki = c.m(rect(10, 30, 54, 34)) & body
    c.add(nuki, RED)
    c.edge(nuki, RED[1])
    # path stone tab
    c.add(c.m(bot, minus=(core,)) | c.m(rect(27, 50, 37, 54)), STONE)
    # dark roof hat
    hat = c.m(roof, top)
    c.add(hat, ROOF)
    c.edge(c.m(rect(0, 14, 64, 17)) & hat, ROOF[2])
    # blossom speckles
    for (x, y) in [(13, 36), (15, 46), (50, 36), (48, 48), (12, 50), (52, 51), (14, 22), (50, 22)]:
        if not c.small or (x + y) % 2 == 0:
            p = c.P(x, y)
            c.px(*p, '#fbe0ea')
            if not c.small:
                c.px(p[0] + 1, p[1], PINK[1])
    # face on the lintel
    c.eye(26, 22)
    c.eye(38, 22)
    c.smile(32, 25.5)
    c.blush(22.5, 26)
    c.blush(41, 26)


K.render_pal(fn, 'pl-gate-3', 'Torii Tophat', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-gate-3-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-gate-3.png')
