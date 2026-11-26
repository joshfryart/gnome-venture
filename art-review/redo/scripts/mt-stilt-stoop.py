#!/usr/bin/env python3
"""mt-stilt-stoop "Stilt Stoop": corner-TB, round. A little stilt house that is a corner piece.
Flat W (straight bamboo wall) and flat S (the plank landing the stilts stand on). Round tab N = the thatch topknot of the roof,
round blank E bitten into the green bamboo wall. Two glowing yellow windows are its eyes, the door its smile, a terracotta pot
with a pink flower on the stoop (cell 0-3: olive bamboo wall, yellow window, terracotta pot, pink bloom, brown wood)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

THATCH = K.ramp('#c9a051')
WALLG = K.ramp('#b8b65a')
WOODR = K.ramp('#9a5a2a')
POST = K.ramp('#b08a48')
WIN = K.ramp('#efc43a')
POT = K.ramp('#b8603a')
PINK = K.ramp('#e8407a')
LEAF = K.ramp('#3f9a4a')
WALLDK = '#86862e'


def fn(c):
    k = 1.15 if c.small else 1.0
    X0, X1, Y0, Y1 = 9, 55, 15, 57
    core = K.rect(X0, Y0, X1, Y1)
    tabN = K.knob('T', 'round', 32, Y0, 0, -1, r=5.4 * k)
    blankE = K.knob('B', 'round', X1, 33, 1, 0, r=4.8 * k)
    # water gaps between the stilts (holes, the plank below keeps the S side flat)
    gaps = [K.rect(14, 43.5, 22.5, 52), K.rect(26.5, 43.5, 37.5, 52), K.rect(41.5, 43.5, 50, 52)]
    body = c.m(core, tabN, minus=[blankE] + gaps)
    c.add(body, POST)
    # thatch roof band + topknot
    roof = body & c.m(K.rect(0, 0, 64, 25.5), tabN)
    c.add(roof, THATCH)
    # bamboo wall
    wall = body & c.m(K.rect(0, 25.5, 64, 41))
    c.add(wall, WALLG, stitch=None)
    # floor beam under the house
    c.add(body & c.m(K.rect(0, 41, 64, 43.5)), WOODR)
    # landing plank (flat S)
    c.add(body & c.m(K.rect(0, 52, 64, 64)), WOODR)
    # thatch texture: drooping straw strokes, and the eave fringe
    if not c.small:
        for (x, y) in roof:
            if (x * 3 + y * 2) % 7 == 0 and y < c.P(0, 25)[1]:
                c.px(x, y, THATCH[1])
        ey = c.P(0, 24.5)[1]
        for x in range(c.P(X0, 0)[0], c.P(X1, 0)[0]):
            if x % 3 == 0:
                c.px(x, ey + 1, THATCH[1])
    else:
        ey = c.P(0, 26)[1]
        for x in range(c.P(X0, 0)[0], c.P(X1, 0)[0], 2):
            c.px(x, ey, THATCH[1])
    # topknot binding
    bx, by = c.P(32, 11)
    for dx in range(-2 if not c.small else -1, 3 if not c.small else 2):
        c.px(bx + dx, by, WOODR[1])
    # bamboo wall slats
    step = 4 if not c.small else 5
    for gx in range(X0 + 3, X1, step):
        x = c.P(gx, 0)[0]
        for y in range(c.P(0, 26.5)[1], c.P(0, 41)[1]):
            if (x, y) in wall:
                c.px(x, y, WALLDK)
    # stilt shading
    for sx in (10.5, 23, 39.5, 52):
        pass
    # windows = eyes (yellow panes, brown frames, umber pupils)
    for wx in (18.5, 33.5):
        frame = c.m(K.rect(wx - 5, 27, wx + 5, 37))
        pane = c.m(K.rect(wx - 3.8, 28.2, wx + 3.8, 35.8))
        for p in frame:
            c.px(p[0], p[1], WOODR[1])
        for p in pane:
            c.px(p[0], p[1], WIN[0])
        cx, cy = c.P(wx, 32)
        if not c.small:
            for dx in range(-1, 2):
                for dy in range(-1, 3):
                    c.px(cx + dx, cy + dy, K.UMBER)
            c.px(cx - 1, cy - 1, K.CREAM)
            for dy in range(c.P(0, 28.2)[1], c.P(0, 35.8)[1]):
                if dy < cy - 1:
                    c.px(cx, dy, WIN[1])
        else:
            for dx in range(0, 2):
                for dy in range(0, 2):
                    c.px(cx + dx - 1, cy + dy, K.UMBER)
            c.px(cx - 1, cy, K.CREAM)
    # little door smile under the windows
    c.smile(26, 38.5, K.UMBER2)
    c.blush(12.5, 38.5)
    c.blush(39.5, 38.5)
    # potted flower on the stoop (left stilt top) -> on the landing between the stilts
    pot = c.m(K.poly([(28, 52), (36, 52), (35, 46.5), (29, 46.5)]))
    c.add(pot, POT)
    c.add(c.m(K.rect(31.2, 43.5, 33, 46.5)), LEAF)
    c.add(c.m(K.ell(32, 44.2, 2.7 * k, 2.3 * k)), PINK)
    # pink lantern hanging in the E blank? no: keep the blank clean; lantern on the topknot side


K.render_pal(fn, 'mt-stilt-stoop', 'Stilt Stoop', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/mt-stilt-stoop-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/mt-stilt-stoop.png')
