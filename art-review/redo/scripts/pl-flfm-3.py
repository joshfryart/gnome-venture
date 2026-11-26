"""pl-flfm-3 Sunrise Snowcap: inner-TBTB round. A snowy mountain that is an inner piece: top tab = the rounded snowy summit,
bottom tab = a green foothill, blanks cut into the left and right flanks. Lavender-blue rock, white snow lit peach by the sunrise,
sky-blue from the cell (2-0) and the picture's distant range."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, knob, thick_path, ramp

ROCK = ramp('#7f8cc0')
ROCKD = ramp('#6470a8')
SNOW = ('#f4f0ec', '#c4cce4', '#ffe6cc')    # light edge peach: the sunrise
HILL = ramp('#5aa848')
SKY = ramp('#8ec8ec')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = poly([(12, 50), (12, 31), (32, 17), (52, 31), (52, 50)])
    tabN = knob('T', 'round', 32, 19, 0, -1, r=5.0 * k, nw=4.2)
    tabS = knob('T', 'round', 32, 50, 0, 1, r=4.6 * k)
    blW = knob('B', 'round', 12, 39, -1, 0, r=4.2 * k)
    blE = knob('B', 'round', 52, 39, 1, 0, r=4.2 * k)
    body = c.m(core, tabN, minus=(blW, blE))
    c.add(body, ROCK)
    # shadow face on the right of the ridge
    shade = c.m(poly([(32, 8), (60, 30), (60, 50), (44, 50), (38, 36), (34, 22)])) & body
    c.add(shade, ROCKD)
    # snowcap with a jagged snowline
    def snow(x, y):
        zig = 30 + (3 if int(x // 5) % 2 else 0) - 0.3 * abs(x - 32)
        return y < zig
    sn = c.m(snow) & body
    c.add(sn, SNOW)
    c.edge(sn, '#b8c0dc')
    glow = sn & c.m(poly([(0, 0), (31, 0), (31, 64), (0, 64)]))
    c.add(glow, ('#fbe2cc', '#e8c4b0', '#fff0e0'))   # sunrise blush on the lit flank
    # green foothill as the bottom tab
    hill = c.m(tabS, ell(32, 53, 26, 8)) & c.m(tabS, core)
    hill = hill - c.m(blW, blE)
    c.add(hill, HILL)
    c.edge(hill, HILL[1])
    # small sunrise sun peeking off the summit's left
    c.eye(27.5, 36)
    c.eye(36.5, 36)
    c.smile(32, 40, K.UMBER2)
    c.blush(24.5, 39.5)
    c.blush(38.5, 39.5)


K.render_pal(fn, 'pl-flfm-3', 'Sunrise Snowcap', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-flfm-3-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-flfm-3.png')
