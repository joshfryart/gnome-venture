"""pl-wpry-3 Pilgrim Pebble. inner-TBTB keyhole: a round sandy pass pebble that IS the piece. Keyhole tabs N (a small cairn pebble
stacked on top) and S (its sitting nub), keyhole blanks E and W bite into its flanks. Mottled with the cell's sand ochres (cell 3-6),
a little string of five prayer flags (blue white red green yellow, from the picture) slung across its shoulders like a pilgrim's sash."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

SAND = K.ramp('#d2b284')
SAND2 = K.ramp('#bc9468')
CAIRN = K.ramp('#e8d0a0')
FLAGC = ['#3f7fc8', '#f4f0e4', '#d6322b', '#3f9a4a', '#f0c030']


def superell(cx, cy, rx, ry, p=3.2):
    return lambda x, y: abs((x - cx) / rx) ** p + abs((y - cy) / ry) ** p < 1


def fn(c):
    k = 1.15 if c.small else 1.0
    core = superell(32, 35, 22.5, 19.5, 3.0)
    tabN = K.knob('T', 'keyhole', 32, 16.0, 0, -1, r=5.4 * k, nw=2.4)
    tabS = K.knob('T', 'keyhole', 32, 54.0, 0, 1, r=4.2 * k, nw=2.4)
    blE = K.knob('B', 'keyhole', 54.5, 37, 1, 0, r=3.2 * k, nw=2.2)
    blW = K.knob('B', 'keyhole', 9.5, 37, -1, 0, r=3.2 * k, nw=2.2)
    body = c.m(core, tabS, minus=(blE, blW))
    c.add(body, SAND, stitch=None if c.small else '#bc9468')
    # mottled darker patches (like the cell's ground) on the lower right
    patch = c.m(ell2(42, 48, 9, 5), ell2(19, 50, 6, 3.5)) & body
    c.add(patch, SAND2)
    # small cairn pebble on top = N keyhole tab
    cairn = c.m(tabN, minus=(core,)) | (c.m(tabN) & c.m(K.rect(0, 14, 64, 17.0)))
    c.add(cairn, CAIRN)
    c.edge(cairn, SAND[1])
    if not c.small:
        c.line([(29.5, 7.5), (32.5, 6.5)], '#ffffff')
        c.line([(44, 36), (47, 40), (46, 44)], SAND2[1])
    # speckles
    for (gx, gy) in ((19, 26), (45, 25), (24, 40), (42, 40), (36, 47), (16, 37), (48, 44)):
        x, y = c.P(gx, gy)
        if (x, y) in body:
            c.px(x, y, '#a88460')
            if not c.small:
                c.px(x + 1, y, '#a88460')
    # prayer-flag sash: a cord sagging across the shoulders with five flags
    cord = [(12, 22), (22, 27.5), (32, 29.5), (42, 27.5), (52, 22)]
    c.line(cord, K.UMBER2)
    for i, (fx, t) in enumerate(((16.5, 0.5), (24, 0), (32, 0), (40, 0), (47.5, 0.5))):
        # y on cord
        fy = 24.5 if i in (0, 4) else (28.3 if i in (1, 3) else 29.5)
        x, y = c.P(fx, fy)
        w, h = (2, 3) if c.small else (4, 5)
        col = FLAGC[i]
        for dx in range(w):
            for dy in range(1, h + 1):
                if c.small or not (dy == h and dx in (0, w - 1)):
                    c.px(x - w // 2 + dx, y + dy, col)
    # face low and calm
    c.eye(25.5, 40)
    c.eye(38.5, 40)
    c.blush(20.5, 44)
    c.blush(42.5, 44)
    c.smile(32, 44.5)


def ell2(cx, cy, rx, ry):
    return K.ell(cx, cy, rx, ry)


K.render_pal(fn, 'pl-wpry-3', 'Pilgrim Pebble', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wpry-3-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wpry-3.png')
