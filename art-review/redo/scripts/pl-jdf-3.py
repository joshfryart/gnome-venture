"""pl-jdf-3 Jade Shimmer. Inner-TBBB, peg: a faceted jade gem. S peg tab = the gem's pointed culet tip, peg blanks N, E, W bite into the
crown and girdle; a gold girdle band like the dragonfly tail's gold rings (cell 6-5). Chamfered corners + facet lines make it a cut stone; sparkle glints.
Colours from the cell: tail jade/mint, gold bands, pond teal."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, poly, knob, ell

JADE = K.ramp('#46b494')
MINT = K.ramp('#5ad8a0')
PALE = K.ramp('#99ecb8')
TEAL = K.ramp('#1c8478')
GOLD = K.ramp('#f2b84a')
SPARK = '#f4fff0'


def fn(c):
    k = 1.15 if c.small else 1.0
    ch = 8
    core = poly([(10 + ch, 16), (54 - ch, 16), (54, 16 + ch), (54, 46), (40, 57), (24, 57), (10, 46), (10, 16 + ch)])
    tabS = knob('T', 'peg', 32, 56, 0, 1, r=3.6 * k)
    blN = knob('B', 'peg', 32, 16, 0, -1, r=2.8 if c.small else 3.2)
    blE = knob('B', 'peg', 54, 37, 1, 0, r=3.4 * k)
    blW = knob('B', 'peg', 10, 37, -1, 0, r=3.4 * k)
    blS = knob('B', 'peg', 32, 58, 0, 1, r=3.0 * k)
    cut = (blE, blW, blN)
    body = c.m(core, tabS, minus=cut)
    c.add(body, JADE, stitch=None if c.small else JADE[1])
    # pavilion (lower facets) darker teal-jade: triangles from the girdle down to the culet
    pav = c.m(poly([(10, 44), (54, 44), (54, 46), (40, 57), (24, 57), (10, 46)]), tabS, minus=cut)
    c.add(pav, TEAL)
    # crown facets: upper-left lighter, table in the middle mint
    c.add(c.m(poly([(18, 16), (28, 16), (22, 26), (10, 26), (10, 24)]), minus=cut), PALE)
    table = c.m(poly([(22, 25), (42, 25), (46, 29), (46, 40), (42, 44), (22, 44), (18, 40), (18, 29)]))
    c.add(table, MINT)
    c.edge(table, JADE[1])
    # culet tip: a darker point
    c.add(c.m(tabS, minus=(core,)), TEAL)
    if not c.small:
        c.line([(24, 45), (30, 56)], TEAL[1])
        c.line([(40, 45), (34, 56)], TEAL[1])
        c.line([(32, 45), (32, 60)], TEAL[2])
    # gold girdle band (the tail's gold ring) at the pavilion edge
    gy = c.P(0, 44)[1]
    for (x, y) in body:
        if y == gy and (x, y) not in table:
            c.px(x, y, GOLD[0])
    # facet lines from table corners to stone corners
    if not c.small:
        c.line([(22, 25), (18, 16)], JADE[1])
        c.line([(42, 25), (46, 16)], JADE[1])
        c.line([(18, 27), (10, 24)], JADE[1])
        c.line([(46, 27), (54, 24)], JADE[1])

    # sparkle glints (four-point stars)
    def star(x, y, big):
        cx, cy = c.P(x, y)
        c.px(cx, cy, SPARK)
        rr = 2 if big else 1
        for d in range(1, rr + 1):
            for dx, dy in ((d, 0), (-d, 0), (0, d), (0, -d)):
                c.px(cx + dx, cy + dy, SPARK)
    star(16, 30, not c.small)
    star(49, 20, False)
    if not c.small:
        star(47, 48, False)
    # face on the table
    c.eye(26.5, 33)
    c.eye(37.5, 33)
    c.smile(32, 38)
    c.blush(22.5, 37)
    c.blush(41, 37)


K.render_pal(fn, 'pl-jdf-3', 'Jade Shimmer', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-jdf-3-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-jdf-3.png')
