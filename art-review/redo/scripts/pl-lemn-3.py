import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
from pal_kit import rect, ell, poly, knob, ramp, UMBER, UMBER2

# Jar Jostle (inner-TBTB, round): a jar of lemon cordial that IS the piece. N tab = the cream cloth lid's tied knot,
# E + W blanks = the jar's pinched waist, S tab = the grass tuft it sits on. Cream wall, trunk brown, lemon yellow, meadow green (cell 8-7).
CLOTH = ramp('#ecd6a8')
TWINE = ramp('#9a6a44')
GLASS = ramp('#c4dce4')
CORD = ramp('#f0c030')
GRASS = ramp('#5aa03a')
PEEL = '#f8e070'


def fn(c):
    k = 1.15 if c.small else 1.0
    lid = rect(11, 12, 53, 20)
    jar = rect(13, 19, 51, 50)
    foot = poly([(13, 48), (51, 48), (48, 54), (16, 54)])
    tabN = knob('T', 'round', 32, 12, 0, -1, r=4.6 * k)
    tabS = knob('T', 'round', 32, 54, 0, 1, r=4.6 * k)
    blW = knob('B', 'round', 13, 35, -1, 0, r=3.6 * k)
    blE = knob('B', 'round', 51, 35, 1, 0, r=3.6 * k)
    bl = (blW, blE)
    c.add(c.m(jar, foot, minus=bl), GLASS)
    cord = c.add(c.m(rect(13, 29, 51, 50), foot, minus=bl), CORD, stitch=CORD[1])
    c.add(c.m(tabS, minus=(foot,)), GRASS)
    c.add(c.m(lid, tabN), CLOTH)
    c.add(c.m(rect(13, 19, 51, 22.5)), TWINE)
    c.edge(cord, CORD[1])
    # glass shine on the upper left
    x0, _ = c.P(16, 0)
    for y in range(c.P(0, 21)[1], c.P(0, 30)[1]):
        c.px(x0, y, '#ffffff')
    # lemon wheel floating in the cordial
    lc = c.m(ell(39, 29.5, 6, 5.5))
    c.add(lc, (PEEL, '#d8a020', '#fff0a0'))
    c.edge(lc, '#e8a020')
    cx, cy = c.P(39, 29.5)
    for dx, dy in ((0, -1), (0, 1), (-1, 0), (1, 0)) if c.small else ((0, -2), (0, 2), (-2, 0), (2, 0), (0, -1), (0, 1), (-1, 0), (1, 0)):
        c.px(cx + dx, cy + dy, '#fff6c8')
    # grass blades on the tab
    for gx in (28, 32, 36):
        x, y = c.P(gx, 60)
        c.px(x, y, GRASS[1])
    # face
    c.eye(26, 40.5)
    c.eye(38, 40.5)
    c.smile(32, 45)
    c.blush(22.5, 44.5)
    c.blush(41, 44.5)


K.render_pal(fn, 'pl-lemn-3', 'Jar Jostle', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-lemn-3-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-lemn-3.png')
