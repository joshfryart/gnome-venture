# Lantern Lark: a plump crested lark whose round-cornered body IS an inner piece. Right side = peg TAB (the orange beak),
# top / left / bottom = peg BLANKS (tucked toes at the front corner keep the bottom edge flat). Colours and motif from Dunewhisper cell 5-2:
# indigo minaret, violet and rose sunset bands, orange glow, and the picture's string of yellow lanterns across the breast.
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

R = '/home/user/gnome-venture/'
INDIGO = K.ramp('#4a3367')
VIOLET = K.ramp('#7b4581')
ROSE = K.ramp('#e88a8a')
PINK = K.ramp('#d06a78')
ORANGE = K.ramp('#e88b62')
LAMP = '#ffd859'
LAMPDK = '#e8a030'
STRING = '#2a1a10'


def fn(c):
    s = 1.15 if c.small else 1.0
    x0, y0, x1, y1, rr = 8, 12, 50, 50, 7
    core = [K.rect(x0 + rr, y0, x1 - rr, y1), K.rect(x0, y0 + rr, x1, y1 - rr)]
    core += [K.ell(x, y, rr, rr) for x in (x0 + rr, x1 - rr) for y in (y0 + rr, y1 - rr)]
    beak = K.knob('T', 'peg', x1, 25, 1, 0, r=4.2 * s)
    blanks = [K.knob('B', 'peg', 25, y0, 0, -1, r=3.1 * s),
              K.knob('B', 'peg', x0, 29, -1, 0, r=3.1 * s),
              K.knob('B', 'peg', 33, y1, 0, 1, r=3.1 * s)]
    crest = [K.thick_path([(38, 15), (40, 6)], 4.2), K.thick_path([(43, 15), (47, 8)], 3.8)]
    tail = K.poly([(11, 40), (2, 49), (4, 55), (10, 54), (18, 47)])
    feet = [K.rect(39, 48, 42, 53.5), K.rect(44, 48, 47, 53.5), K.rect(37, 52, 49, 54.5)]  # tucked toes at the front corner

    c.add(c.m(*feet), ORANGE)
    c.add(c.m(tail, minus=blanks), VIOLET)
    c.add(c.m(*crest), INDIGO)
    body = c.add(c.m(*core, minus=blanks), INDIGO, stitch=VIOLET[2])
    # rose breast on the front (right / lower), pink sunset band near the bottom
    breast = c.add(c.m(K.ell(40, 39, 15, 15), minus=blanks) & body, ROSE)
    band = c.add(c.m(K.rect(0, 45, 64, 64), minus=blanks) & breast, PINK)
    # folded violet wing on the side
    wing = c.add(c.m(K.ell(24, 38, 9, 6), K.poly([(16, 38), (25, 42), (17, 46)]), minus=blanks) & body, VIOLET)
    c.edge(wing, INDIGO[1])
    c.add(c.m(beak), ORANGE)
    # the beak's mouth line
    c.line([(51, 25.6), (57, 25.6)], ORANGE[1])
    # string of lanterns across the breast (picture motif)
    c.add(c.m(K.thick_path([(13, 24), (24, 29), (36, 32), (50, 28)], 1.6 if not c.small else 2.2)) & body, (STRING, STRING, STRING))
    for (lx, ly) in ((22, 29), (35, 32)):
        c.add(c.m(K.rect(lx - 1.2, ly, lx + 1.2, ly + 1.6)), (STRING, STRING, STRING))
        c.add(c.m(K.ell(lx, ly + 4.6, 3.0, 3.4)), (LAMP, LAMPDK, '#fff2b0'))
        c.add(c.m(K.rect(lx - 1.6, ly + 7.6, lx + 1.6, ly + 9)), (PINK[1], PINK[1], PINK[1]))
    if not c.small:
        c.line([(21, 38), (28, 40)], INDIGO[1])
        c.line([(20, 41), (26, 43)], INDIGO[1])
    c.eye(40, 20, disc=True, look=(1, 0))
    c.blush(45, 24) if not c.small else None


K.render_pal(fn, 'dw-lantern-lark', 'Lantern Lark', R + 'art-review/redo/out',
             cellfile=R + 'art-review/redo/_src/dw-lantern-lark-cell.png',
             oldfile=R + 'game/assets/img/puzzles/pals/dw-lantern-lark.png')
print(K.check(K.draw(fn, 64))['colours'], K.check(K.draw(fn, 36))['colours'])
