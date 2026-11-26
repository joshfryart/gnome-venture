# Spark Hop: a campfire flame sprite that is an edge piece. Flat bottom = log seat (the edge), peg tabs left and right
# (flicker-arms), peg blank top centre (the fork between two flame tongues). Tent-canvas oranges from cell 7-6, mint aurora glints.
import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K

OUT = K.ramp('#f07a30')
MID = K.ramp('#f99f49')
CORE = ('#ffc540', '#f2a242', '#fff0a0')
EMBER = K.ramp('#c1573b')
LOG = K.ramp('#8a5230')
MINT = K.ramp('#acf9a5')
VIO = K.ramp('#b870d0')


def fn(c):
    s = 1.15 if c.small else 1.0
    r = 4.2 * s
    core = K.rect(13, 24, 51, 52)
    # crown of flame tongues along the top edge, tallest in the middle
    tongues = K.poly([(13, 26), (13, 18), (16, 10), (19, 18), (23, 12), (26, 21), (29, 23),
                      (35, 23), (38, 21), (41, 12), (45, 18), (48, 10), (51, 18), (51, 26)])
    # top tab: a peg whose square head is the flame's leaping tip (a spark hopping off)
    centre = K.poly([(28.5, 10), (32, 3), (35.5, 10)])
    tabL = K.knob('T', 'peg', 13, 36, -1, 0, r=r)
    tabT = K.knob('T', 'peg', 32, 23, 0, -1, r=r * 1.15, nw=2.4)
    blank = K.knob('B', 'peg', 51, 36, 1, 0, r=r)
    logm = K.rect(9, 50, 55, 58)
    body = c.m(core, tongues, centre, tabL, tabT, minus=(blank,))
    c.add(body, OUT)
    # inner flame: a teardrop of lighter orange, then a yellow heart
    mid = c.m(K.ell(30, 40, 13, 12), K.poly([(19, 36), (24, 14), (30, 28)]), K.poly([(29, 30), (32, 18), (35, 30)]),
              K.poly([(34, 30), (40, 16), (43, 36)]))
    c.add(mid & body, MID)
    corem = c.m(K.ell(30, 43, 9, 8), K.poly([(23, 40), (32, 20), (38, 40)]))
    c.add(corem & body, CORE)
    # the hopping spark: the peg's square head glows yellow, with a violet aurora glint
    c.add(c.m(K.rect(26, 3, 38, 18), centre) & body, CORE)
    c.add(c.m(K.rect(30, 9, 33, 12)) & body, VIO) if not c.small else None
    # left tab tip: an aurora-mint spark; violet glint inside the right blank's lip
    c.add(c.m(K.rect(2, 30, 8, 42)) & body, MINT)
    # log seat (flat edge)
    lg = c.add(c.m(logm), LOG)
    c.edge(lg, '#5a3420')
    for x in (16, 32, 48):
        X, Y = c.P(x, 54)
        c.px(X, Y, '#5a3420')
        if not c.small:
            c.px(X, Y + 1, '#5a3420')
    # face on the bright heart
    c.eye(26, 41)
    c.eye(35, 41)
    c.smile(30.5, 46)
    c.blush(22, 45)
    c.blush(39, 45)


if __name__ == '__main__':
    rep = K.render_pal(fn, 'pl-aurc-2', 'Spark Hop', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-aurc-2-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-aurc-2.png')
    print(rep)
