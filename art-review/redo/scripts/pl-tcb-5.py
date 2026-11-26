# Treetop Porch: inner-BBBB round. A leafy treetop crown over a round plank porch on a trunk; one square piece with
# four round blanks (N into the crown, E + W into the porch rim, S between the roots). Canopy greens + bridge wood from cell 11-4.
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, knob

LEAF = ('#73bd82', '#3e8a6c', '#a6dca0')
LEAF2 = K.ramp('#5aaa78')
DECK = ('#d8985a', '#b97b4c', '#ecc28a')
RIM = ('#b97b4c', '#9a5e3e', '#d8985a')
BARK = ('#9a5e3e', '#64363c', '#b97b4c')


def fn(c):
    k = 1.15 if c.small else 1.0
    crown = poly([(9, 27), (9, 15), (13, 9), (22, 7), (42, 7), (51, 9), (55, 15), (55, 27)])
    rim = rect(8, 27, 56, 41)
    root = poly([(19, 41), (45, 41), (46, 47), (56, 50), (56, 57), (8, 57), (8, 50), (18, 47)])
    bN = knob('B', 'round', 32, 7, 0, -1, r=4.6 * k)
    bE = knob('B', 'round', 56, 35, 1, 0, r=4.4 * k)
    bW = knob('B', 'round', 8, 35, -1, 0, r=4.4 * k)
    bS = knob('B', 'round', 32, 57, 0, 1, r=4.6 * k)
    blanks = (bN, bE, bW, bS)
    c.add(c.m(crown, minus=blanks), LEAF, stitch=None if c.small else '#a6dca0')
    # leaf clumps: darker tufts in the crown, like the canopy in the picture
    for (x, y, rx, ry) in ((17, 20, 6, 5), (46, 21, 6, 5), (30, 23, 7, 3.5)):
        c.add(c.m(ell(x, y, rx, ry), minus=blanks) & c.m(crown), LEAF2)
    trunk = c.add(c.m(root, minus=blanks), BARK)
    c.add(c.m(rim, minus=blanks), RIM)
    deck = c.add(c.m(ell(32, 28.5, 24, 3.6), rect(8, 27, 56, 30.5), minus=blanks), DECK)
    c.edge(deck, '#9a5e3e')
    # railing: dark top rail and balusters standing on the deck, under the crown
    c.add(c.m(rect(9, 20.6, 55, 22.6 if not c.small else 23.4)), BARK)
    step = 4.0 if not c.small else 5.4
    xx = 10.0
    while xx < 55:
        c.add(c.m(rect(xx - 0.9, 21, xx + 0.9 if not c.small else xx + 1.0, 28)), BARK)
        xx += step
    # leaf highlights in the crown
    for (x, y) in ((14, 13), (22, 11), (43, 11), (50, 14), (37, 16)):
        hx, hy = c.P(x, y)
        c.px(hx, hy, '#c4e49c')
        if not c.small:
            c.px(hx + 1, hy, '#c4e49c')
    # plank seams on the deck top (64 px only)
    if not c.small:
        y = c.P(0, 28.5)[1]
        for xx in (14, 20, 26, 38, 44, 50):
            c.px(c.P(xx, 0)[0], y, '#b97b4c')
    # bark grain on the trunk
    for (a, b) in (((27, 43), (26, 50)), ((37, 43), (38, 50))):
        if not c.small:
            c.line([a, b], '#64363c')
    # plank ends along the porch rim
    for xx in (12, 17, 47, 52):
        x0, y0 = c.P(xx, 32)
        for yy in range(y0, c.P(0, 40)[1]):
            c.px(x0, yy, '#9a5e3e')
    # face on the porch rim
    c.eye(25.5, 35, disc=False)
    c.eye(38.5, 35, disc=False)
    c.smile(32, 37.5)
    c.blush(21, 38)
    c.blush(43, 38)


if __name__ == '__main__':
    rep = K.render_pal(fn, 'pl-tcb-5', 'Treetop Porch', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-tcb-5-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-tcb-5.png')
    print(rep)
