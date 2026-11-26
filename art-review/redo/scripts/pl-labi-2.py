# pl-labi-2 "Creamsail Dawdle": a little sailboat that is an edge-TBT keyhole piece.
# Flat E = the straight leech of the sail and the boat's transom; keyhole tab N = the mast-top ball with a pennant;
# keyhole tab S = the keel bulb under the hull; keyhole blank W = the wind's bite in the sail's luff. Colours from cell 2-2 (cream sand path, tan rim, hedge greens, sea blue).
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

SAND = K.ramp('#fff0c0')
TAN = K.ramp('#c89a6a')
HEDGE = K.ramp('#62b050')
LIME = K.ramp('#bef06a')
SEA = K.ramp('#6ad0d8')
MAST = K.ramp('#8a5a34')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.poly([(13, 13), (51, 13), (51, 49), (21, 49), (13, 40)])   # bow raked at the lower left, flat transom E
    tabN = K.knob('T', 'keyhole', 30, 13, 0, -1, r=4.2 * k)
    tabS = K.knob('T', 'keyhole', 30, 49, 0, 1, r=4.2 * k)
    blankW = K.knob('B', 'keyhole', 13, 26, -1, 0, r=4.2 * k)
    body = c.m(core, tabN, tabS, minus=(blankW,))
    # big cream sail (the island's sand), a deeper belly on the lee side
    sail = body & c.m(K.rect(0, 0, 64, 36))
    c.add(sail, SAND, stitch=None if c.small else '#e0c890')
    c.add(sail & c.m(K.rect(44, 13, 51, 36)), K.ramp('#f0d8a0'))
    # mast-top ball (tab N) and mast
    c.add(c.m(tabN) - c.m(core), MAST)
    c.add(body & c.m(K.rect(28.6, 9, 31.4, 36)), MAST)
    # pennant flying from the mast top, hedge green
    c.add(c.m(K.poly([(31, 3.5), (41, 6.5), (31, 9.5)])), HEDGE)
    # boom
    c.add(body & c.m(K.rect(0, 35, 64, 38)), TAN)
    # hull: hedge green with a lime gunwale and maze-wall notches
    hull = body & c.m(K.rect(0, 38, 64, 49))
    c.add(hull, HEDGE)
    c.add(body & c.m(K.rect(0, 38, 64, 40.6)), LIME)
    dk = '#2e7a44'
    if not c.small:
        for x0, x1, y in ((16, 25, 43), (29, 47, 43), (20, 40, 46)):
            c.line([(x0, y), (x1, y)], dk)
        for x, y0, y1 in ((25, 43, 46), (40, 43, 46)):
            c.line([(x, y0), (x, y1)], dk)
    else:
        c.line([(17, 44), (47, 44)], dk)
    # keel bulb (tab S), deep hedge green
    c.add(c.m(tabS) - c.m(core), K.ramp('#2e7a44'))
    # sea-blue waterline stripe along the hull
    c.add(body & c.m(K.rect(0, 47, 64, 49)), SEA)
    # face on the sail, right of the mast where it is calm
    c.eye(36, 24)
    c.eye(46, 24)
    c.smile(41, 28.5)
    c.blush(34, 28)
    c.blush(48, 28)


K.render_pal(fn, 'pl-labi-2', 'Creamsail Dawdle', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-labi-2-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-labi-2.png')
