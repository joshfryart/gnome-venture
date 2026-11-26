#!/usr/bin/env python3
"""cs-keel-drift "Keel Drift" (rare, whimsy-turtle, hook): a sea turtle seen from above, swimming west.
The squarish domed shell IS the piece body: hook tab N (a shell bump), hook tab E (the tail), hook blank S cut into the shell;
the head pokes out W and four swept flippers break the corners. Reef-brown shell with tan rim scutes, sea-green skin (cell 9-4)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

SHELL = K.ramp('#6b4828')
RIM = K.ramp('#9a7040')
SKIN = K.ramp('#4b9a49')
SPOT = '#2f6a3a'


def sup(cx, cy, a, b, p=4):
    return lambda x, y: abs((x - cx) / a) ** p + abs((y - cy) / b) ** p < 1


def fn(c):
    k = 1.15 if c.small else 1.0
    cx, cy = 35, 32
    shell = sup(cx, cy, 16, 15.5, 3)
    tabN = K.knob('T', 'hook', cx - 1, cy - 15.5, 0, -1, r=5.2 * k)
    tabE = K.knob('T', 'hook', cx + 16, cy + 1, 1, 0, r=4.4 * k, flip=True)
    blankS = K.knob('B', 'hook', cx + 1, cy + 15.5, 0, 1, r=4.6 * k)
    # flippers (front big, swept back; rear small)
    fl1 = K.poly([(28, 19), (20, 10), (12, 6), (8, 7), (9, 11), (14, 18), (21, 26)])
    fl2 = K.poly([(28, 45), (20, 54), (12, 58), (8, 57), (9, 53), (14, 46), (21, 38)])
    rf1 = K.poly([(44, 20), (50, 13), (55, 12), (57, 15), (53, 21), (49, 25)])
    rf2 = K.poly([(44, 44), (50, 51), (55, 52), (57, 49), (53, 43), (49, 39)])
    head = K.ell(11.5, 32, 7, 5.6)
    neck = K.rect(14, 28.5, 22, 35.5)
    skin = c.m(fl1, fl2, rf1, rf2, head, neck, minus=(blankS,))
    c.add(skin, SKIN)
    tail = c.m(tabE, minus=(shell,))
    c.add(tail, SKIN)
    body = c.m(shell, tabN, minus=(blankS,))
    c.add(body, SHELL, stitch=None if c.small else RIM[2])
    inner = c.m(sup(cx, cy, 11.5, 11, 3), minus=(blankS,))
    rim = body - inner
    c.add(rim, RIM)
    c.edge(inner, SHELL[1])
    # central scutes: a hex in the middle + spokes to the rim
    hexm = c.m(K.poly([(cx - 5, cy - 6), (cx + 5, cy - 6), (cx + 8, cy), (cx + 5, cy + 6), (cx - 5, cy + 6), (cx - 8, cy)]))
    c.edge(hexm & inner, SHELL[1])
    for a, b in (((cx - 5, cy - 6), (cx - 9, cy - 10)), ((cx + 5, cy - 6), (cx + 9, cy - 10)),
                 ((cx - 5, cy + 6), (cx - 9, cy + 10)), ((cx + 5, cy + 6), (cx + 9, cy + 10)),
                 ((cx, cy - 6), (cx, cy - 11))):
        c.line([a, b], SHELL[1])
    if not c.small:
        c.px(*c.P(cx - 2, cy - 3), SHELL[2]); c.px(*c.P(cx - 1, cy - 3), SHELL[2])
        # rim scute dividers
        for t in range(12):
            import math
            ang = t * math.pi / 6 + 0.26
            x0, y0 = cx + 12.5 * math.cos(ang), cy + 12 * math.sin(ang)
            x1, y1 = cx + 15 * math.cos(ang), cy + 14.6 * math.sin(ang)
            c.line([(x0, y0), (x1, y1)], RIM[1])
        # flipper spots
        for sx, sy in ((14, 12), (17, 17), (14, 52), (17, 47), (52, 17), (52, 47)):
            c.px(*c.P(sx, sy), SPOT)
    # face: half-closed winking eye + slow smile
    c.eye(10, 30, disc=True)
    c.smile(8, 34) if not c.small else c.px(*c.P(7, 35), K.UMBER)
    if not c.small:
        c.px(*c.P(6, 29), SKIN[2])


K.render_pal(fn, 'cs-keel-drift', 'Keel Drift', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/cs-keel-drift-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/cs-keel-drift.png')
print('ok')
