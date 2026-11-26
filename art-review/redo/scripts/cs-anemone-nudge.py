"""cs-anemone-nudge "Anemone Nudge": inner-TBTB, double knobs.
A sea anemone that IS the square piece: N double tab = two fat pink-tipped tentacle bulbs rising out of a purple tentacle crown
(scalloped top edge), S double tab = the orange foot disc gripping the sand, double blanks bite into the orange column E + W.
Colours from cell 5-7 of Coral Scatter: coral orange #f37a2b, shell purple #8a59a8, starfish pink, sand #f2d19b, a little clownfish."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, knob

R = '/home/user/gnome-venture/'
ORANGE = K.ramp('#f37a2b')
PURPLE = K.ramp('#8a59a8')
PINK = K.ramp('#f08aa8')
SAND = K.ramp('#f2d19b')
FOOT = K.ramp('#d8601e')
WHITE = '#fff0c7'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rect(10, 22, 54, 52)
    tabN = knob('T', 'double', 32, 22, 0, -1, r=5.4 * k)
    tabS = knob('T', 'double', 32, 52, 0, 1, r=5.0 * k)
    blankW = knob('B', 'double', 10, 41, -1, 0, r=3.5 * k)
    blankE = knob('B', 'double', 54, 41, 1, 0, r=3.5 * k)
    fxs = (12.8, 18.3, 23.8, 40.2, 45.7, 51.2)
    fingers = [(fx, (lambda e, r: (lambda x, y: e(x, y) or r(x, y)))(ell(fx, 19.8, 2.6, 2.8), rect(fx - 2.6, 19.8, fx + 2.6, 24))) for fx in fxs]
    cut = (blankW, blankE)
    body = c.m(core, tabN, tabS, *[f for _, f in fingers], minus=cut)
    # orange column
    c.add(body, ORANGE, stitch=None if c.small else ORANGE[2])
    # tentacle crown: separate purple fingers with pink tips, hanging over the column top with rounded ends
    dark = PURPLE[1]
    allf = set()
    for fx, f in fingers + [(29.3, None), (34.7, None)]:
        top = rect(fx - 2.6, 13 if f is None else 17, fx + 2.6, 31)
        m = c.m(top, ell(fx, 31, 2.6, 2.2)) & body
        if f is not None:
            m |= c.m(f) & body
        else:
            m |= c.m(tabN, minus=(rect(0, 22, 64, 64),)) & c.m(rect(fx - 2.6, 0, fx + 2.6, 64))
        allf |= m
        c.add(m, PURPLE)
        c.add(m & c.m(lambda x, y: y < 21), PINK)
        c.edge(m, dark)
    # foot disc (S tab) in deeper orange with a sand fringe under it
    foot = c.m(tabS, minus=(rect(0, 0, 64, 52.5),))
    c.add(foot, FOOT)
    # column ridges
    for gx in (15, 49):
        x = c.P(gx, 0)[0]
        for y in range(c.P(0, 33)[1], c.P(0, 50)[1]):
            if (x, y) in body and (x, y) not in c.over:
                c.px(x, y, ORANGE[2] if gx < 30 else ORANGE[1])
    # little clownfish tucked in the crown (left)
    if not c.small:
        fx, fy = c.P(15, 26.5)
        fish = [(dx, dy) for dx in range(0, 6) for dy in range(-1, 2)] + [(-1, -1), (-1, 1), (-2, -2), (-2, 2), (-1, 0)]
        for dx, dy in fish:
            c.px(fx + dx, fy + dy, '#f37a2b')
        for dy in range(-1, 2):
            c.px(fx + 2, fy + dy, WHITE)
        c.px(fx + 4, fy - 1, '#2a1a10')
    else:
        fx, fy = c.P(15, 26.5)
        for dx in range(0, 4):
            for dy in range(0, 2):
                c.px(fx + dx, fy + dy, '#f37a2b')
        c.px(fx + 1, fy, WHITE)
        c.px(fx + 1, fy + 1, WHITE)
        c.px(fx - 1, fy, '#f37a2b')
        c.px(fx - 1, fy + 1, '#f37a2b')
        c.px(fx + 3, fy, '#2a1a10')
    # face on the column
    c.eye(26.5, 39)
    c.eye(37.5, 39)
    c.smile(32, 44.5)
    c.blush(23, 43.5)
    c.blush(40, 43.5)


K.render_pal(fn, 'cs-anemone-nudge', 'Anemone Nudge', R + 'art-review/redo/out',
             cellfile=R + 'art-review/redo/_src/cs-anemone-nudge-cell.png',
             oldfile=R + 'game/assets/img/puzzles/pals/cs-anemone-nudge.png')
print(K.check(K.draw(fn, 64))['colours'], K.check(K.draw(fn, 36))['colours'])
