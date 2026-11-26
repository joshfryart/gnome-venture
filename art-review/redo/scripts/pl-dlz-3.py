#!/usr/bin/env python3
# Tail Tick: side-view lizard = inner-TBTB piece. Right double tab = head (upper/lower jaw lobes), left double tab = tail tip,
# top blank between purple back spines, bottom blank between stubby legs. Green dragon scales, pale-yellow cobble belly (cell 10-6), cave purple.
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

GREEN = K.ramp('#5a9a32')
BELLY = K.ramp('#e6d68a')
PURP = K.ramp('#5a3a6a')
HORN = K.ramp('#e8c890')
GROUT = '#9a8a52'
MOUTH = '#a8304a'


def fn(c):
    s = 1.15 if c.small else 1.0
    x0, y0, x1, y1 = 13, 18, 51, 50
    cy = (y0 + y1) / 2
    head = K.knob('T', 'double', x1, cy, 1, 0, r=6.2 * s, nw=3.4)
    tail = K.knob('T', 'double', x0, cy + 2, -1, 0, r=5.0 * s, nw=2.6)
    top_b = K.knob('B', 'double', 32, y0, 0, -1, r=4.6 * s, nw=2.4)
    bot_b = K.knob('B', 'double', 32, y1, 0, 1, r=4.6 * s, nw=2.4)
    core = K.rect(x0, y0, x1, y1)
    body = c.m(core, minus=(top_b, bot_b))
    c.add(body, GREEN, stitch=None if c.small else '#3c6e22')
    # belly band (lower part of core), pale cobbles
    belly = c.m(K.rect(x0, 37, x1, y1), minus=(bot_b,))
    c.add(belly, BELLY)
    c.edge(belly, GROUT)
    # tail tip in purple-ringed green
    t = c.m(tail, minus=(core,))
    c.add(t, GREEN)
    # curled tail tip rising from the tail tab (it ticks)
    curl = K.thick_path([(5, 30), (3.5, 25), (5, 20), (9, 18.5), (11, 21)], 3.6 if c.small else 3.4)
    c.add(c.m(curl, minus=(core,)), GREEN)
    
    # head: upper jaw green, lower jaw belly colour
    h = c.m(head, minus=(core,))
    hu = {p for p in h if (p[1] + 0.5) / c.k < cy}
    hl = h - hu
    c.add(hu, GREEN)
    c.add(hl, BELLY)
    # spines on top edge, either side of blank
    sp = []
    for sx in (17, 23, 41, 47):
        sp.append(K.poly([(sx - 2.6, y0 + 0.5), (sx, y0 - 4.2), (sx + 2.6, y0 + 0.5)]))
    c.add(c.m(*sp), PURP)
    # horn on head
    c.add(c.m(K.poly([(52, cy - 7), (55, cy - 13), (57, cy - 6)])), HORN)
    # cobble grout lines on belly
    if not c.small:
        for gx in (19, 27, 38, 45):
            c.line([(gx, 38), (gx, 49)], GROUT)
        c.line([(x0 + 1, 43.5), (x1, 43.5)], GROUT)
    # mouth line between jaws
    mx0, my = c.P(x1, cy)
    for i in range(int(10 * c.k) + 1):
        c.px(mx0 + i, my, MOUTH if i < int(9 * c.k) else K.UMBER)
    # eye + scales dots
    c.eye(45, 26, disc=True)
    c.px(*c.P(60, cy - 4), K.UMBER)  # nostril
    # brow ridge like the dragon's
    c.line([(41, 21.5), (49, 21.5)], GREEN[1])
    if not c.small:
        for (dx, dy) in ((20, 26), (28, 30), (36, 25), (44, 30), (24, 33), (40, 33)):
            c.px(*c.P(dx, dy), GREEN[1])
    c.blush(47, 32)


if __name__ == '__main__':
    print(K.render_pal(fn, 'pl-dlz-3', 'Tail Tick', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-dlz-3-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-dlz-3.png'))
