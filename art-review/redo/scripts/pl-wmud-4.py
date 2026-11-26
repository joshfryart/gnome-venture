# Concept: a mud-brick bookcase pal (inner-TTTT, double knobs): square mud-plaster case (cell ochre) with a dome-blue
# arched crown, two shelves of rainbow book spines (the doorway's red/yellow/green/blue stripes); N tab = two rolled
# scrolls, E/W tabs = scroll ends poking out sideways, S tab = two mud feet. Face on the crown board.
import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
from pal_kit import rect, ell, knob

MUD = K.ramp('#e0a86a')
MUDDK = K.ramp('#b27846')
BLUE = K.ramp('#2f6eae')
SCROLL = K.ramp('#f4e2b0')
SPINES = ['#d8483a', '#f0c030', '#4f9a48', '#3a78c0', '#e0702a', '#c8327a', '#2a9a9a']


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rect(13, 15, 51, 52)
    tN = knob('T', 'double', 32, 15, 0, -1, r=5.2 * k)
    tE = knob('T', 'double', 51, 33, 1, 0, r=4.8 * k)
    tW = knob('T', 'double', 13, 33, -1, 0, r=4.8 * k)
    tS = knob('T', 'double', 32, 52, 0, 1, r=5.0 * k)
    body = c.m(core)
    c.add(body, MUD, stitch=None)
    c.add(c.m(tN, minus=(core,)), SCROLL)
    c.add(c.m(tE, tW, minus=(core,)), SCROLL)
    c.add(c.m(tS, minus=(core,)), MUDDK)
    # blue crown band (like the doorway arch trim)
    c.add(c.m(rect(13, 15, 51, 18.5)), BLUE)
    # two shelf recesses filled with spines
    for (y0, y1) in ((29, 39), (41.5, 50)):
        x = 16.0
        i = int(y0)
        while x < 48:
            w = 3.6 if c.small else 3.2
            w2 = min(w, 48 - x)
            col = SPINES[i % len(SPINES)]
            top = y0 + (1.2 if (i % 3 == 0) else 0)
            c.add(c.m(rect(x, top, x + w2, y1)), K.ramp(col))
            x += w2
            i += 1
        sh = c.m(rect(16, y0, 48, y1))
        c.edge(sh, MUDDK[1])
    # scroll ties: a red ribbon around each scroll neck, curl dots on the rolled ends
    c.add(c.m(rect(30.6, 7, 33.4, 15)), K.ramp('#d8483a'))
    c.add(c.m(rect(51, 31.6, 56, 34.4), rect(8, 31.6, 13, 34.4)), K.ramp('#d8483a'))
    if not c.small:
        for (x, y) in ((27.5, 8.2), (36.5, 8.2), (58.4, 30.5), (58.4, 35.5), (5.6, 30.5), (5.6, 35.5)):
            cx, cy = c.P(x, y)
            c.px(cx, cy, SCROLL[1])
    # mud plaster speckle like the cell
    for (x, y) in ((17, 21), (47, 20.5), (20, 40.3), (44, 40.3), (16.5, 51), (46, 51), (33, 20)):
        cx, cy = c.P(x, y)
        c.px(cx, cy, MUDDK[0])
    # face on crown board
    c.eye(25, 23.5)
    c.eye(39, 23.5)
    c.smile(32, 25.5)
    c.blush(20.5, 26)
    c.blush(43, 26)


K.render_pal(fn, 'pl-wmud-4', 'Rainbow Spine Shelves', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wmud-4-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wmud-4.png')
