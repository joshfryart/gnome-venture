"""pl-bvd-4 Damwall Logs: inner-TTTT, double. Three stubby dam logs piled crooked into a square piece; every double tab is a pair of
sawn log ends (end grain with rings). Bark browns, end-grain tan and the dark plum seams of the beaver-dam cell 1-5, river blue eyes."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

BARK = K.ramp('#b68050')
BARK2 = K.ramp('#946040')
GRAIN = ('#d8a060', '#c88c50', '#f0d098')
SEAM = '#482e34'
RING = '#946040'
WATER = ('#3c88b8', '#2e70a0', '#7cb4d8')


def fn(c):
    k = 1.15 if c.small else 1.0
    # three logs, piled crooked: (left end x, right end x, top y, bottom y)
    L = [(11, 49.5, 14, 26.5), (13.5, 52, 26.5, 38.5), (11.5, 48.5, 38.5, 51)]
    logs = []
    for x0, x1, y0, y1 in L:
        ry = (y1 - y0) / 2
        logs.append((K.rect(x0, y0, x1, y1), K.ell(x0, (y0 + y1) / 2, 3.2, ry), K.ell(x1, (y0 + y1) / 2, 4.4, ry)))
    tabs = [K.knob('T', 'double', 31, 14.5, 0, -1, r=5.4 * k), K.knob('T', 'double', 31, 50.5, 0, 1, r=5.4 * k),
            K.knob("T", "double", 56, 32.5, 1, 0, r=4.8 * k), K.knob('T', 'double', 11.5, 32.5, -1, 0, r=4.8 * k)]
    core = K.rect(12, 15, 52, 50)
    c.add(c.m(core), ('#482e34', '#2b1c26', '#5c3c3c'))      # dark gaps between logs
    for t in tabs:                                            # tabs = stubby sticks poking out of the pile, bark with cut ends
        c.add(c.m(t, minus=(core,)), BARK2)
    for i, (r_, a, b) in enumerate(logs):
        x0, x1, y0, y1 = L[i]
        m = c.m(r_, a)
        c.add(m, BARK if i != 1 else BARK2)
        # cylinder shading: light band at the top, dark band at the bottom
        c.add(m & c.m(K.rect(0, y0, 64, y0 + 2.2)), (BARK[2],) * 3)
        c.add(m & c.m(K.rect(0, y1 - 2.4, 64, y1)), (BARK[1],) * 3)
        c.edge(m, SEAM)
        # the sawn end showing (right end on logs 0 and 2, left on the crooked middle one... and right too)
        ends = [b] if i != 1 else [b]
        for e in ends:
            em = c.m(e)
            c.add(em, GRAIN)
            c.edge(em, RING)
            cx = x1
            cy = (y0 + y1) / 2
            px, py = c.P(cx, cy)
            c.px(px, py, '#f0d098')
            if not c.small:
                c.px(px - 1, py, RING); c.px(px + 1, py, RING)
    # cut ends on the tab sticks
    for (mx, my, nx, ny, r) in ((31, 14.5, 0, -1, 5.4), (31, 50.5, 0, 1, 5.4), (56, 32.5, 1, 0, 4.8), (11.5, 32.5, -1, 0, 4.8)):
        r *= k
        kk = r * 0.56
        cc = r + 1.6 - 0.3
        for sgn in (-1, 1):
            ax, ay = -ny, nx
            x = mx + ax * sgn * kk + nx * cc
            y = my + ay * sgn * kk + ny * cc
            px, py = c.P(x, y)
            c.px(px, py, GRAIN[2])
            if not c.small:
                c.px(px + 1, py, GRAIN[0]); c.px(px, py + 1, GRAIN[0]); c.px(px + 1, py + 1, RING)
    # bark grain lines (64 px)
    if not c.small:
        for (x0, x1, y) in ((20, 34, 20), (36, 44, 22), (22, 32, 45), (34, 46, 43)):
            c.line([(x0, y), (x1, y)], BARK[1])
    # river water lapping the bottom log
    wave = c.m(lambda x, y: y > 47.5 + (1.0 if (x // 4) % 2 else 0) and 12 <= x < 50 and y < 51)
    c.add(wave & c.m(*logs[2]), WATER)
    # face on the middle log
    c.eye(24, 31.5, disc=True)
    c.eye(35, 31.5, disc=True)
    c.smile(29.5, 35, SEAM)
    c.blush(20, 35)


K.render_pal(fn, 'pl-bvd-4', 'Damwall Logs', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-bvd-4-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-bvd-4.png')
