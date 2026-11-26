"""pl-gaun-1 Redroof Rest: corner-TB, round. A ranch house that is a corner piece: flat W + S (wall and ground), round tab N = the
grey chimney, round blank E cut into the red tiled roof. Roof tiles in the cell's terracotta-to-plum ramp; cream wall with two lit windows as eyes."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, knob

ROOF = K.ramp('#e2683e')
ROOF2 = K.ramp('#c2443a')
EAVE = K.ramp('#8a3448')
WALLC = ('#efdcb4', '#c4a882', '#fbf0d8')
CHIM = K.ramp('#a2aabc')
DOOR = K.ramp('#8a5a30')
WIN = '#f8c250'
TILE_LT = '#f6a070'
TILE_DK = '#a8383a'


def fn(c):
    k = 1.15 if c.small else 1.0
    x0, y0, x1, y1 = 8, 16, 55, 58
    core = rect(x0, y0, x1, y1)
    tabN = knob('T', 'round', 39, y0, 0, -1, r=5.0 * k)
    blankE = knob('B', 'round', x1, 29, 1, 0, r=4.6 * k)
    body = c.m(core, tabN, minus=(blankE,))
    # chimney (tab N): grey stone with a darker cap
    c.add(c.m(tabN, minus=(core,)) | (c.m(tabN) & c.m(rect(0, y0, 64, y0 + 1))), CHIM)
    # roof: top part of the core, a slightly peaked lower edge (eave)
    roof = c.m(core, minus=(blankE,)) & c.m(rect(0, 0, 64, 39))
    c.add(roof, ROOF)
    # lower roof rows deeper red
    c.add(roof & c.m(rect(0, 30, 64, 39)), ROOF2)
    # wall
    wall = c.m(core) & c.m(rect(0, 39, 64, 64))
    c.add(wall, WALLC, stitch=None if c.small else '#d8c49c')
    # eave band
    c.add(c.m(core) & c.m(rect(0, 37, 64, 40.5)), EAVE)
    # tile rows: scalloped dark lines + light highlights
    step = 5.5
    yy = y0 + 4.5
    row = 0
    while yy < 37:
        py = c.P(0, yy)[1]
        for px in range(c.P(x0, 0)[0], c.P(x1, 0)[0]):
            if (px, py) in body:
                c.px(px, py, TILE_DK)
        # vertical tile seams, offset per row
        seam = 3 if c.small else 5
        for px in range(c.P(x0, 0)[0] + (row % 2) * (seam // 2 + 1), c.P(x1, 0)[0], seam):
            for d in range(1, 3 if c.small else 4):
                if (px, py - d) in body and py - d > c.P(0, y0)[1]:
                    c.px(px, py - d, TILE_DK)
            if (px + 1, py - (2 if c.small else 3)) in body and not c.small:
                c.px(px + 1, py - 3, TILE_LT)
        yy += step if not c.small else 6
        row += 1
    # chimney: dark cap band across the knob head, a mortar line lower down
    top = y0 - (2 * 5.0 * k + 2.1)
    for (x, y) in c.m(tabN, minus=(core,)):
        Y = (y + 0.5) / c.k
        if Y < top + (2.2 if not c.small else 2.6):
            c.px(x, y, '#5e6478')
        elif abs(Y - (top + 6.0)) < 0.5 / c.k + 0.01 and not c.small:
            c.px(x, y, CHIM[1])
    # sunlit upper tiles (the cell's light top)
    for (x, y) in roof:
        Y = (y + 0.5) / c.k
        if Y < y0 + 4 and (x + y) % 3 == 0:
            c.px(x, y, TILE_LT)
    # windows as eyes
    for wx in (18.5, 45.5):
        X0, Y0 = c.P(wx - 5, 43)
        X1, Y1 = c.P(wx + 5, 53)
        for x in range(X0, X1):
            for y in range(Y0, Y1):
                c.px(x, y, WIN)
        for x in range(X0 - 1, X1 + 1):
            c.px(x, Y0 - 1, DOOR[1])
            c.px(x, Y1, DOOR[1])
        for y in range(Y0, Y1):
            c.px(X0 - 1, y, DOOR[1])
            c.px(X1, y, DOOR[1])
        c.eye(wx, 48.5)
    # door (mouth area) centre
    DX0, DY0 = c.P(28, 45)
    DX1, DY1 = c.P(36, 58)
    for x in range(DX0, DX1):
        for y in range(DY0, DY1):
            c.px(x, y, DOOR[0] if x > DX0 else DOOR[2])
    c.px(DX1 - 2, (DY0 + DY1) // 2, WIN)
    c.blush(11.5, 54)
    c.blush(51.5, 54)


K.render_pal(fn, 'pl-gaun-1', 'Redroof Rest', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-gaun-1-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-gaun-1.png')
