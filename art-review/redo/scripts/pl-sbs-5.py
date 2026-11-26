#!/usr/bin/env python3
"""pl-sbs-5 Dewweb Eye: inner-BBBB, hook. A square piece of dark cave web (silver spokes + rings), anchored to mauve stone at the
corners (cell 7-2 rock), four hook blanks cut in; in the centre the round gap of the web is a big lilac eye ringed by dew drops."""
import math
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

STONE = K.ramp('#8b706e')
CAVE = ('#3b3345', '#2b1c26', '#544a66')
SILK = '#c0bfd7'
DEW = '#f9f5fd'
IRIS = K.ramp('#9a8cc8')


def fn(c):
    k = 1.15 if c.small else 1.0
    x0, y0, x1, y1 = 8, 8, 56, 56
    core = K.rect(x0, y0, x1, y1)
    bl = [K.knob('B', 'hook', 32, y0, 0, -1, r=4.6 * k),
          K.knob('B', 'hook', x1, 32, 1, 0, r=4.6 * k),
          K.knob('B', 'hook', 32, y1, 0, 1, r=4.6 * k),
          K.knob('B', 'hook', x0, 32, -1, 0, r=4.6 * k)]
    body = c.m(core, minus=bl)
    c.add(body, CAVE)
    # mauve stone corner anchors
    cs = 9.5
    corners = c.m(K.poly([(x0, y0), (x0 + cs, y0), (x0, y0 + cs)]), K.poly([(x1, y0), (x1 - cs, y0), (x1, y0 + cs)]),
                  K.poly([(x0, y1), (x0 + cs, y1), (x0, y1 - cs)]), K.poly([(x1, y1), (x1 - cs, y1), (x1, y1 - cs)])) & body
    c.add(corners, STONE)
    cx, cy = 32, 32
    # web: spokes and rings (silver), drawn as overlays
    w = 1.6 if c.small else 1.1
    spokes = []
    for i in range(8):
        a = i * math.pi / 4 + math.pi / 8 * 0
        spokes.append(K.thick_path([(cx, cy), (cx + 30 * math.cos(a), cy + 30 * math.sin(a))], w))
    rings = []
    for R in ((19,) if c.small else (15, 21)):
        pts = []
        for i in range(9):
            a = i * math.pi / 4
            # octagonal web ring, sagging slightly between spokes
            pts.append((cx + R * math.cos(a), cy + R * math.sin(a)))
        rings.append(K.thick_path(pts, w))
    web = c.m(*spokes, *rings) & body
    web -= corners
    web -= c.m(K.ell(cx, cy, 11, 11))
    for p in web:
        c.over[p] = SILK
    # the round gap: big eye
    er = 11 if c.small else 9.5
    eye = c.m(K.ell(cx, cy, er, er * 0.85)) & body
    c.add(eye, ('#e8e2f2', '#b8b0cc', DEW))
    iris = c.m(K.ell(cx + 0.5, cy + 0.5, 6.4 if c.small else 5.8, 6.4 if c.small else 6.2))
    c.add(iris, IRIS)
    c.edge(eye, '#544a66')
    px, py = c.P(cx + 0.5, cy + 0.5)
    pr = 1 if c.small else 2
    for dx in range(-pr, pr):
        for dy in range(-pr, pr + 1):
            c.px(px + dx, py + dy, K.UMBER)
    c.px(px - pr, py - pr, DEW)
    if not c.small:
        c.px(px - pr + 1, py - pr, DEW)
    # upper lid with lashes: umber arc over the eye
    lid = []
    for i in range(13):
        a = math.pi + i * math.pi / 12
        lid.append((cx + (er + 0.6) * math.cos(a), cy + (er * 0.85 + 0.6) * math.sin(a)))
    c.line(lid, K.UMBER)
    for a in (-2.4, -1.57, -0.75):
        r0 = er + 0.6
        c.line([(cx + r0 * math.cos(a), cy + r0 * 0.88 * math.sin(a)), (cx + (r0 + 3) * math.cos(a), cy + (r0 + 3) * 0.9 * math.sin(a))], K.UMBER)
    # dew ring around the gap
    for i in range(8):
        a = i * math.pi / 4 + math.pi / 8
        if math.sin(a) < -0.5:
            continue
        dx, dy = c.P(cx + (14.5 if c.small else 13) * math.cos(a), cy + (14.5 if c.small else 13) * math.sin(a))
        c.px(dx, dy, DEW)
        c.px(dx + 1, dy, '#c8c8e0')
        c.px(dx, dy + 1, '#c8c8e0')
        if not c.small:
            c.px(dx + 1, dy + 1, '#9a8cc8')
            c.px(dx - 1, dy, '#c8c8e0')
            c.px(dx, dy - 1, DEW)
    # dew sparkle on outer ring at spokes
    if not c.small:
        for i in (0, 2, 4, 6):
            a = i * math.pi / 4
            sx, sy = c.P(cx + 21 * math.cos(a), cy + 21 * math.sin(a))
            c.px(sx, sy, DEW)


if __name__ == '__main__':
    print(K.render_pal(fn, 'pl-sbs-5', 'Dewweb Eye', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-sbs-5-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-sbs-5.png'))
