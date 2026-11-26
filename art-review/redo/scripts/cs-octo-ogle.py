# Octo Ogle: a pink lagoon octopus that IS an edge piece. Flat side = top of the rounded-square mantle,
# tabs = the two side tentacles reaching out (peg tips), blank = the peg gap between the legs at the bottom.
# Colours sampled from cell 11-6 of coralscatter (pink octopus #ee6f78 on sand #c9b07a).
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

PINK = ('#ee6f78', '#c04561', '#ffa5a0')
LEG = ('#e2606c', '#a8384f', '#f8968f')
SPOT = '#c85868'
SUCK = '#fbe4b0'
SAND = K.ramp('#c9b07a')


def rounded(x0, y0, x1, y1, r):
    def f(x, y):
        if not (x0 <= x < x1 and y0 <= y < y1):
            return False
        for cx, cy in ((x0 + r, y0 + r), (x1 - r, y0 + r)):
            if (x < x0 + r if cx == x0 + r else x > x1 - r) and y < y0 + r:
                return (x - cx) ** 2 + (y - cy) ** 2 < r * r
        return True
    return f


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rounded(12, 8, 52, 56, 11)
    flare = K.ell(11.5, 54, 3.4, 2.6)
    flare2 = K.ell(52.5, 54, 3.4, 2.6)
    tl = K.knob('T', 'peg', 12, 41, -1, 0, r=4.6 * k, nw=3.0)
    tr = K.knob('T', 'peg', 52, 41, 1, 0, r=4.6 * k, nw=3.0)
    bb = K.knob('B', 'peg', 32, 56, 0, 1, r=4.6 * k, nw=2.6)
    # small notches between the outer legs so the tentacles read
    n1 = K.poly([(20.5, 57), (23.5, 57), (22, 50.5)])
    n2 = K.poly([(40.5, 57), (43.5, 57), (42, 50.5)])
    n3 = K.poly([(15.8, 57), (18.2, 57), (17, 52)])
    n4 = K.poly([(45.8, 57), (48.2, 57), (47, 52)])
    body = c.m(core, tl, tr, flare, flare2, minus=(bb, n1, n2) + (() if c.small else (n3, n4)))
    legs = c.m(K.rect(0, 33, 64, 64)) & body
    head = body - legs
    c.add(head, PINK, stitch=None if c.small else '#ffb8b0')
    c.add(legs, LEG)
    # mantle/leg boundary as a scalloped skirt line
    skirt = c.m(K.rect(12, 33, 52, 34.6 if not c.small else 35.2))
    for (x, y) in skirt & body:
        c.px(x, y, '#a8384f')
    # leg separators
    for x0 in ((22, 42) if c.small else (17, 22, 42, 47)):
        c.line([(x0, 38), (x0, 51)], '#a8384f')
    # suckers along the legs and on the side tentacle tips
    pts = [(14, 45), (19, 49), (27, 44), (36, 44), (44, 49), (49, 45), (5, 41), (58, 41), (14, 51), (49, 51)]
    if c.small:
        pts = [(17, 48), (47, 48), (5, 41), (59, 41), (27, 46), (37, 46)]
    for (x, y) in pts:
        px, py = c.P(x, y)
        c.px(px, py, SUCK)
        if not c.small:
            c.px(px + 1, py, SUCK)
    # mantle spots (from the cell's darker pink)
    for (x, y) in ([(19, 16), (44, 14), (40, 18), (23, 12)] if not c.small else [(20, 15), (44, 15)]):
        px, py = c.P(x, y)
        c.px(px, py, SPOT)
        c.px(px + 1, py, SPOT)
        if not c.small:
            c.px(px, py + 1, SPOT)
            c.px(px + 1, py + 1, SPOT)
    # big ogling eyes looking up-right (at something shiny)
    c.eye(24, 24, disc=True, look=(1, -1))
    c.eye(40, 24, disc=True, look=(1, -1))
    # tiny 'o' mouth: ogling
    mx, my = c.P(32, 30)
    if c.small:
        c.px(mx, my, '#8e2a40')
    else:
        for d in ((0, 0), (1, 0), (0, 1), (1, 1)):
            c.px(mx + d[0], my + d[1], '#8e2a40')
    c.blush(17, 29)
    c.blush(46, 29)
    # a shiny pearl the octopus ogles, held on the right tentacle peg tip
    if not c.small:
        px, py = c.P(59, 36)
    else:
        px, py = c.P(59, 36)


if __name__ == '__main__':
    rep = K.render_pal(fn, 'cs-octo-ogle', 'Octo Ogle', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/cs-octo-ogle-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/cs-octo-ogle.png')
    print(rep)
