"""pl-pgg-5 Pinched Pearls: inner-BBBB, tri. A stolen pearl necklace coiled round and round into one square piece:
an outer square loop of pearls scallops the outline, an inner ring loops round a big pearl that wears the face, all on
the cell's sand-brown grotto velvet; tri blanks cut into all four sides, the strand parts around each one; gold clasp."""
import math
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

SAND = K.ramp('#c89c68')
ROCK = ('#8c6450', '#6e4c40', '#b48464')
PEARL = ('#f2ece0', '#c4b8b0', '#ffffff')
PEARLSH = '#e8d4dc'   # pink nacre sheen
GOLD = K.GOLD


def fn(c):
    k = 1.15 if c.small else 1.0
    x0, y0, x1, y1 = 8, 8, 56, 56
    core = K.rect(x0, y0, x1, y1)
    r = 3.5 * (1.1 if c.small else 1.0)
    blanks = (K.knob('B', 'tri', 32, y0, 0, -1, r=r), K.knob('B', 'tri', 32, y1, 0, 1, r=r),
              K.knob('B', 'tri', x0, 32, -1, 0, r=r), K.knob('B', 'tri', x1, 32, 1, 0, r=r))
    br = 3.8 if not c.small else 4.0
    # outer loop of pearls on a square path, centred near the edge so they scallop it
    e = 10.5
    outer = []
    n = 5
    for i in range(n + 1):
        t = e + (64 - 2 * e) * i / n
        for p in ((t, e), (t, 64 - e), (e, t), (64 - e, t)):
            if p not in outer:
                outer.append(p)
    outer = [p for p in outer if not (abs(p[0] - 32) < 6 and p[1] in (e, 64 - e)) and not (abs(p[1] - 32) < 6 and p[0] in (e, 64 - e))]
    ring = []
    for i in range(12):
        a = 2 * math.pi * i / 12 + math.pi / 12
        ring.append((32 + 15 * math.cos(a), 32 + 15 * math.sin(a)))
    ring = [p for p in ring if min(abs(p[0] - 32), abs(p[1] - 32)) > 3]
    beads = [K.ell(px, py, br, br) for (px, py) in outer]
    body = c.m(core, *beads, minus=blanks)
    c.add(body, ROCK)
    # sand velvet in the middle (the cell's light sand)
    c.add(body & c.m(K.ell(32, 32, 19, 19)), SAND)
    sq = [(e, e), (64 - e, e), (64 - e, 64 - e), (e, 64 - e), (e, e)]
    pts = [(32 + 15 * math.cos(2 * math.pi * i / 24), 32 + 15 * math.sin(2 * math.pi * i / 24)) for i in range(25)]
    c.add(body & c.m(K.thick_path(sq, 1.6 if not c.small else 2.0), K.thick_path(pts, 1.6 if not c.small else 2.0)), ('#d8b878', '#b89858', '#e8d098'))
    allb = []
    for (px, py) in outer + ring:
        bm = body & c.m(K.ell(px, py, br * (0.9 if (px, py) in ring else 1), br * (0.9 if (px, py) in ring else 1)))
        c.add(bm, PEARL)
        allb.append((px, py, bm))
    # gold clasp replaces top-left corner pearl
    cm = body & c.m(K.ell(e, e, br + 0.6, br + 0.6))
    c.add(cm, GOLD)
    big = body & c.m(K.ell(32, 33, 8.6, 8.2))
    c.add(big, PEARL)
    for (px, py, bm) in allb:
        c.edge(bm, '#b0a098')
        hx, hy = c.P(px - 1.3, py - 1.3)
        c.px(hx, hy, PEARL[2])
        sx, sy = c.P(px + 1.2, py + 1.3)
        c.px(sx, sy, PEARLSH)
    c.edge(cm, GOLD[1])
    hx, hy = c.P(e - 1, e - 1)
    c.px(hx, hy, GOLD[2])
    c.edge(big, '#b0a098')
    # sheen on big pearl
    for (ax, ay) in ((26.5, 27.5), (27.5, 26.5)):
        hx, hy = c.P(ax, ay)
        c.px(hx, hy, PEARL[2])
    sx, sy = c.P(36.5, 38.5)
    c.px(sx, sy, PEARLSH)
    c.px(sx + 1, sy, PEARLSH)
    c.eye(28.5, 32)
    c.eye(35.5, 32)
    c.smile(32, 36)
    c.blush(26, 35.5)
    c.blush(38, 35.5)


K.render_pal(fn, 'pl-pgg-5', 'Pinched Pearls', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-pgg-5-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-pgg-5.png')
