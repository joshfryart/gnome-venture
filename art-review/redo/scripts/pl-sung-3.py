"""pl-sung-3 Bubble Bop: an air bubble that is an inner-TBTB keyhole piece. Rounded-square bubble body with a mint ring and a
white shine crescent (upper left); keyhole tabs N (a little bubble budding off the top) and S, keyhole blanks W and E.
Colours from cell 9-1: teal water #3fb8c8, aqua #58d0d0, mint bubble ring #d8fff0."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

TEAL = K.ramp('#3fb8c8')
AQUA = K.ramp('#58d0d0')
MINT = ('#d8fff0', '#8fd8d0', '#ffffff')
SHINE = '#ffffff'


def rrect(x0, y0, x1, y1, r):
    return lambda x, y: (x0 <= x < x1 and y0 <= y < y1) and not (
        (x < x0 + r and y < y0 + r and (x - x0 - r) ** 2 + (y - y0 - r) ** 2 > r * r) or
        (x >= x1 - r and y < y0 + r and (x - x1 + r) ** 2 + (y - y0 - r) ** 2 > r * r) or
        (x < x0 + r and y >= y1 - r and (x - x0 - r) ** 2 + (y - y1 + r) ** 2 > r * r) or
        (x >= x1 - r and y >= y1 - r and (x - x1 + r) ** 2 + (y - y1 + r) ** 2 > r * r))


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rrect(8, 12, 56, 52, 10)
    tabN = K.knob('T', 'keyhole', 32, 12, 0, -1, r=4.6 * k, nw=2.2)
    tabS = K.knob('T', 'keyhole', 32, 52, 0, 1, r=4.4 * k, nw=2.2)
    blW = K.knob('B', 'keyhole', 8, 29, -1, 0, r=3.8 * k)
    blE = K.knob('B', 'keyhole', 56, 29, 1, 0, r=3.8 * k)
    body = c.m(core, tabN, tabS, minus=(blW, blE))
    # mint ring = the whole body, then the water fill eroded one or two px in
    c.add(body, MINT)
    inner = K.erode(body)
    if not c.small:
        inner = K.erode(inner)
    c.add(inner, AQUA)
    # deeper teal toward the lower right inside the bubble
    c.add(inner & c.m(lambda x, y: x + y > 70), TEAL)
    # the tab bulbs are little bubbles budding off: mint ring, clear centre, own glint
    for (cy, r) in ((12 - (4.6 * k + 2.1), 4.6 * k * 0.8), (52 + (4.4 * k + 2.1), 4.4 * k * 0.8)):
        ring = 1.7 if c.small else 1.5
        c.add(c.m(K.ell(32, cy, r - ring, r - ring)), K.ramp('#8ce4e0'))
        if not c.small:
            c.px(*c.P(30.5, cy - 1.2), SHINE)
    # shine crescent, upper left, and a glint upper right
    w = 3.4 if c.small else 3.0
    c.add(c.m(K.thick_path([(14.5, 24), (16, 19), (20, 16), (26, 15)], w)), (SHINE, SHINE, SHINE))
    c.add(c.m(K.ell(47, 19, 2.0 * k, 2.0 * k)), (SHINE, SHINE, SHINE))
    # face
    c.eye(25, 36)
    c.eye(39, 36)
    c.smile(32, 42, wide=True)
    c.blush(20, 41)
    c.blush(43, 41)


rep = K.render_pal(fn, 'pl-sung-3', 'Bubble Bop', '/home/user/gnome-venture/art-review/redo/out',
                   cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-sung-3-cell.png',
                   oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-sung-3.png')
print(rep)
