#!/usr/bin/env python3
"""pl-lemn-6 "Abbot Lemon" (rare, whimsy-lemon, round knobs).
Concept: a plump lemon IS the piece: its right nub is a round tab, a round blank bites its left end, and its stem cap on top is a
round tab sprouting the grove's leaves; the lemon wears a brown monk's cowl over its lower half with a gold rope, a white abbot
beard and wise brows. Colours from cell 8-5: lemon yellows, grove greens, robe umber-brown, the window's orange glow."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

LEMON = ('#fcd84a', '#d8a428', '#fffaa0')
LEAF = K.ramp('#5ea848')
LEAF2 = ('#b8dc68', '#8bc258', '#e0f0a8')
ROBE = K.ramp('#7a4a38')
ROPE = ('#f5a548', '#c87a30', '#f8e0b4')
BEARD = ('#f8f0dc', '#d8c8a8', '#ffffff')


def supell(cx, cy, rx, ry, p=2.6):
    return lambda x, y: abs((x - cx) / rx) ** p + abs((y - cy) / ry) ** p < 1


def fn(c):
    k = 1.15 if c.small else 1.0
    core = supell(31, 38, 21, 18)
    tipE = K.knob('T', 'round', 51.5, 38, 1, 0, r=4.6 * k)
    tabN = K.knob('T', 'round', 31, 21, 0, -1, r=5.2 * k, nw=3.0)
    blankW = K.knob('B', 'round', 10.5, 37, -1, 0, r=4.4 * k)
    body = c.m(core, tipE, tabN, minus=(blankW,))
    c.add(body, LEMON, stitch=None if c.small else '#f8d038')
    # stem cap on the top tab, leaves out of it
    cap = c.m(tabN, minus=(core,)) & body
    c.add(cap, LEAF)
    c.add(c.m(K.poly([(34, 10.5), (40, 4), (49, 3), (45, 9), (36, 12)])), LEAF2)
    c.add(c.m(K.thick_path([(31, 11), (32, 7)], 2.8)), LEAF)
    if not c.small:
        c.line([(36, 10), (46, 5)], LEAF[1])
    # monk's cowl over the lower half (follows the lemon outline)
    robe = body & c.m(lambda x, y: y > 42 + 0.018 * (x - 31) ** 2)
    c.add(robe, ROBE)
    # hood rim / collar V and rope belt
    rope = body & c.m(lambda x, y: 42 + 0.018 * (x - 31) ** 2 <= y < 44.8 + 0.018 * (x - 31) ** 2 + (0.6 if c.small else 0))
    c.add(rope, ROPE)
    # white beard
    beard = c.m(K.poly([(25, 41), (37, 41), (35.5, 48), (31, 52), (26.5, 48)]))
    c.add(beard, BEARD)
    c.edge(beard, BEARD[1])
    # brows and eyes
    c.add(c.m(K.thick_path([(21, 30.5), (27, 29)], 2.6 if c.small else 2.2)), BEARD)
    c.add(c.m(K.thick_path([(35, 29), (41, 30.5)], 2.6 if c.small else 2.2)), BEARD)
    c.eye(24.5, 34)
    c.eye(37.5, 34)
    c.blush(20, 38)
    c.blush(42, 38)
    c.smile(31, 39.5, K.UMBER)
    # pip highlights on the lemon peel
    if not c.small:
        for (x, y) in ((18, 26), (45, 28), (49, 34)):
            c.px(*c.P(x, y), LEMON[2])


K.render_pal(fn, 'pl-lemn-6', 'Abbot Lemon', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-lemn-6-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-lemn-6.png')
