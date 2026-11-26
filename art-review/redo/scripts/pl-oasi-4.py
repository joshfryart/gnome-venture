# pl-oasi-4 "Goldbead Dates": a hanging bunch of golden bead-dates that is an inner-TTTT keyhole piece.
# N tab = green palm stalk the bunch hangs from (palm fronds fan out above it), E/W/S tabs = single round dates.
# Body = a square cluster of bead dates in the shell's gold / peach / mauve ring colours (cell 3-3).
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

GOLD = K.ramp('#f2b570')
PALE = K.ramp('#f8d191')
PEACH = K.ramp('#eda05f')
MAUVE = K.ramp('#b37a87')
TAN = K.ramp('#d6a284')
LEAF = K.ramp('#4f9a48')
STALK = K.ramp('#8a6a3a')
AMBER = K.ramp('#a8683a')


def fn(c):
    k = 1.15 if c.small else 1.0
    r = 5.4 * k
    core = K.rect(14, 20, 50, 52)
    tN = K.knob('T', 'keyhole', 32, 20, 0, -1, r=4.2 * k)
    tE = K.knob('T', 'keyhole', 50, 37, 1, 0, r=r)
    tW = K.knob('T', 'keyhole', 14, 37, -1, 0, r=r)
    tS = K.knob('T', 'keyhole', 32, 52, 0, 1, r=r)
    corners = [K.ell(x, y, 4, 4) for x in (18, 46) for y in (24, 48)]
    body = c.m(K.rect(18, 20, 46, 52), K.rect(14, 24, 50, 48), *corners)
    c.add(body, AMBER)
    # tabs: single hanging dates
    for t, col in ((tE, PEACH), (tW, MAUVE), (tS, GOLD)):
        c.add(c.m(t, minus=(core,)), col)
    # oval dates packed in the bunch; the big central date carries the face
    small = [(19.5, 27, PALE), (44.5, 27, MAUVE), (19.5, 45.5, PEACH), (44.5, 45.5, PALE)]
    for x, y, col in small:
        m = c.m(K.ell(x, y, 3.9, 4.6)) & body
        c.add(m, col)
        c.edge(m, AMBER[1])
    big = c.m(K.ell(32, 35, 9.2, 11.5)) & body
    c.add(big, GOLD)
    c.edge(big, AMBER[1])
    # stalk tab on top + palm crown fanning out above
    c.add(c.m(tN, minus=(core,)), STALK)
    w = 4.2 if not c.small else 4.6
    fr = [[(32, 13), (24, 8), (15, 9), (9, 15)], [(32, 13), (40, 8), (49, 9), (55, 15)],
          [(32, 13), (26, 4), (19, 3)], [(32, 13), (38, 4), (45, 3)]]
    for pts in fr:
        c.add(c.m(K.thick_path(pts, w)), LEAF)
    if not c.small:
        for pts in fr:
            c.line(pts, LEAF[1])
        for x, y, _ in small:
            cx, cy = c.P(x - 1.5, y - 2.5)
            c.px(cx, cy, '#fff3d6')
            c.px(cx, cy + 1, '#fff3d6')
        cx, cy = c.P(25.5, 26)
        for d in range(3):
            c.px(cx + d, cy - (d > 0), '#fff3d6')
    c.eye(28, 33)
    c.eye(36, 33)
    c.smile(32, 37.5)
    c.blush(25, 37)
    c.blush(38.5, 37)


K.render_pal(fn, 'pl-oasi-4', 'Goldbead Dates', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-oasi-4-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-oasi-4.png')
