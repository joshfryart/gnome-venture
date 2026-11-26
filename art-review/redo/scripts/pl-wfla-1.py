#!/usr/bin/env python3
# Peppermint Awning (pl-wfla-1): a striped market awning that is a corner piece.
# Flat left and bottom sides (bottom = scalloped valance hem), keyhole TAB on top (the awning's finial),
# keyhole BLANK cut into the right side. Red/cream peppermint stripes in flamingo-shallows pinks and plum.
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

RED = K.ramp('#d8466a')     # peppermint red, pushed toward the flamingo pink
CRM = K.ramp('#ffe6e0')     # cream from the shallows glints
PINK = K.ramp('#f08aa4')    # flamingo body pink
PLUM = K.ramp('#a9496f')    # flamingo shadow plum
STRIPE = 6.0


def fn(c):
    s = 1.15 if c.small else 1.0
    x0, x1, y0, y1 = 8, 54, 17, 50
    core = K.rect(x0, y0, x1, y1)
    scal = [K.ell(x0 + 4.6 + i * 9.2, y1, 4.6, 5.2) for i in range(5)]
    tab = K.knob('T', 'keyhole', 31, y0, 0, -1, r=4.6 * s)
    blank = K.knob('B', 'keyhole', x1, 32, 1, 0, r=4.4 * s)
    beak = K.poly([(32.5, 8.2), (38.6, 9.6), (38.2, 14.6), (36.4, 12.4), (33.0, 12.2)])
    body = c.m(core, tab, beak, *scal, minus=(blank,))
    # stripes (canopy), y0+4 .. 40
    c.add(body, CRM)
    # stripes fan out from the roof bar to the hem (awning slant)
    def strip(i):
        a0, a1 = x0 + 1 + i * 4.4, x0 + 1 + (i + 1) * 4.4       # at the roof
        b0, b1 = x0 + i * 4.6, x0 + (i + 1) * 4.6               # at the hem
        return K.poly([(a0, y0), (a1, y0), (b1, 41), (b0, 41)])
    reds = c.m(*[strip(i) for i in range(1, 10, 2)])
    c.add(reds & body, RED)
    # valance band with scallops, alternating colours per scallop
    band = c.m(K.rect(x0, 40, x1, y1)) & body
    c.add(band, PINK, stitch=PLUM[2])
    for i, sp in enumerate(scal):
        m = c.m(sp, minus=(K.rect(0, 0, 64, y1),)) & body
        c.add(m, RED if i % 2 == 0 else CRM)
    # roof bar + finial
    c.add(c.m(K.rect(x0, y0, x1, y0 + 4)) & body, PLUM)
    c.add(c.m(tab, minus=(K.rect(0, y0, 64, 64),)) & body, PINK)
    # finial = little flamingo head with a bent, black-tipped beak (the cell's flamingo)
    c.add(c.m(beak) & body, CRM)
    c.add(c.m(K.poly([(37.4, 11.6), (39, 11.6), (38.4, 15), (36.6, 12.8)])) & body, K.ramp('#3a2630'))
    ex, ey = c.P(30.4, 9.6)
    c.px(ex, ey, K.UMBER)
    if not c.small:
        c.px(ex + 1, ey, K.UMBER)
        c.px(ex, ey + 1, K.UMBER)
        c.px(ex + 1, ey + 1, K.UMBER)
        c.px(ex, ey, CRM[0])
    c.edge(band, PLUM[1])
    # face on the valance
    c.eye(24, 45 if not c.small else 44.5)
    c.eye(38, 45 if not c.small else 44.5)
    c.smile(31, 46.5)
    c.blush(19, 47)
    c.blush(43, 47)


K.render_pal(fn, 'pl-wfla-1', 'Peppermint Awning', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wfla-1-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wfla-1.png')
