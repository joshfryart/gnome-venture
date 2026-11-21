#!/usr/bin/env python3
"""q11 grid generator: draws each icon from primitives at its native size and
writes q11/grids/<slug>-32.txt / -20.txt (then hand-tweaked if needed)."""
import math
import os
import sys

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'grids')


class G:
    def __init__(s, S):
        s.S = S
        s.f = S / 32.0
        s.g = [['.'] * S for _ in range(S)]

    # coordinates are given in 32-space and scaled
    def sc(s, v):
        return v * s.f

    def mask_ell(s, cx, cy, rx, ry, rot=0):
        cx, cy, rx, ry = map(s.sc, (cx, cy, rx, ry))
        m = set()
        c, si = math.cos(rot), math.sin(rot)
        for y in range(s.S):
            for x in range(s.S):
                dx, dy = x + .5 - cx, y + .5 - cy
                u, v = dx * c + dy * si, -dx * si + dy * c
                if (u / rx) ** 2 + (v / ry) ** 2 <= 1:
                    m.add((x, y))
        return m

    def mask_poly(s, pts):
        pts = [(s.sc(a), s.sc(b)) for a, b in pts]
        m = set()
        n = len(pts)
        for y in range(s.S):
            for x in range(s.S):
                px, py = x + .5, y + .5
                ins = False
                j = n - 1
                for i in range(n):
                    xi, yi = pts[i]
                    xj, yj = pts[j]
                    if (yi > py) != (yj > py) and px < (xj - xi) * (py - yi) / (yj - yi) + xi:
                        ins = not ins
                    j = i
                if ins:
                    m.add((x, y))
        return m

    def mask_line(s, x0, y0, x1, y1, w):
        x0, y0, x1, y1, w = map(s.sc, (x0, y0, x1, y1, w))
        m = set()
        L2 = (x1 - x0) ** 2 + (y1 - y0) ** 2
        for y in range(s.S):
            for x in range(s.S):
                px, py = x + .5, y + .5
                t = 0 if L2 == 0 else max(0, min(1, ((px - x0) * (x1 - x0) + (py - y0) * (y1 - y0)) / L2))
                d = math.hypot(px - (x0 + t * (x1 - x0)), py - (y0 + t * (y1 - y0)))
                if d <= w / 2:
                    m.add((x, y))
        return m

    def put(s, m, ch):
        for x, y in m:
            if 0 <= x < s.S and 0 <= y < s.S:
                s.g[y][x] = ch

    def px(s, pts, ch):
        for x, y in pts:
            s.g[y][x] = ch

    def shade(s, m, B='B', L='L', D='D', E='E', rim=1, gloss=None):
        """fill mask with B, top-left rim L, bottom-right rim D (+E outermost)"""
        for x, y in m:
            ch = B
            tl = (x - 1, y) not in m or (x, y - 1) not in m
            br = (x + 1, y) not in m or (x, y + 1) not in m
            br2 = rim > 1 and ((x + 2, y) not in m or (x, y + 2) not in m or (x + 1, y + 1) not in m)
            if br:
                ch = E if E else D
            elif br2:
                ch = D
            elif tl:
                ch = L
            s.g[y][x] = ch
        if br_only := False:
            pass

    def write(s, slug):
        os.makedirs(OUT, exist_ok=True)
        with open(os.path.join(OUT, '%s-%d.txt' % (slug, s.S)), 'w') as fh:
            fh.write('\n'.join(''.join(r) for r in s.g) + '\n')


def ring(m):
    return {(x, y) for x, y in m if any((x + a, y + b) not in m for a, b in ((1, 0), (-1, 0), (0, 1), (0, -1)))}


# ---------------------------------------------------------------- icons
def hazelnut(S):
    g = G(S)
    big = S == 32
    body = g.mask_ell(16, 18.5, 11.5, 10.5) | g.mask_poly([(16, 3.2), (9, 12), (23, 12)])
    g.shade(body, rim=2 if big else 1)
    # shell stripes (D) curving down from tip
    for dx in ((-6, -2, 2, 6) if big else (-4, 3)):
        st = g.mask_line(16 + dx * .35, 8, 16 + dx, 24, 1.0 if big else 1.4)
        g.put(st & body - ring(body), 'D')
    # pale rough base (hilum) cap
    cap = g.mask_ell(15.5, 28, 7, 3.2) & body
    g.put(cap, 'c')
    g.put(g.mask_ell(14.5, 27.4, 5, 1.8) & cap, 'C')
    g.put(ring(body) & cap, 'k')
    # gloss
    if big:
        g.px([(10, 12), (9, 13), (9, 14), (8, 15), (8, 16), (14, 6), (13, 8)], 'H')
    else:
        g.px([(6, 8), (5, 9), (5, 10)], 'H')
    # hold: small gold clasp band hugging the nut belt? -> tiny gold padlock lower-right
    if big:
        lock = g.mask_poly([(21, 22), (29, 22), (29, 29), (21, 29)])
        shack = (g.mask_ell(25, 22, 3.6, 4.2) - g.mask_ell(25, 22, 1.7, 2.4)) - lock
        g.put({(x, y) for x, y in shack if y <= 22}, 'm')
        g.put({(x, y) for x, y in g.mask_ell(25, 22, 1.7, 2.4) if y <= 21}, 'k')
        g.put(lock, 'G')
        g.put(g.mask_poly([(21, 27), (29, 27), (29, 29), (21, 29)]), 'o')
        g.px([(24, 24), (25, 24), (24, 25), (25, 25), (24, 26)], 'k')
        g.px([(22, 23)], 'H')
    return g


def kola(S):
    g = G(S)
    big = S == 32
    a = g.mask_ell(12, 17, 8.5, 11, -0.35)
    b = g.mask_ell(20.5, 17.5, 8.5, 11, 0.35)
    g.shade(a, rim=2 if big else 1)
    g.shade(b, rim=2 if big else 1)
    seam = g.mask_line(16.2, 6, 16.2, 29, 1.2 if big else 1.6) & (a | b)
    g.put(seam, 'E')
    # bolt
    bolt = g.mask_poly([(19, 1.5), (9, 16), (15, 16), (10.5, 30.5), (24, 13), (17.5, 13), (23, 1.5)] if big else
                       [(19.5, 1.5), (9, 16.5), (15.5, 16.5), (10.5, 30.5), (24.5, 13), (18, 13), (24, 1.5)])
    g.put(bolt, 'G')
    for x, y in bolt:
        if (x + 1, y) not in bolt or (x, y + 1) not in bolt:
            g.g[y][x] = 'o'
    g.put(ring(bolt) - {(x, y) for x, y in bolt if (x + 1, y) not in bolt or (x, y + 1) not in bolt} if False else set(), 'k')
    # ink outline around bolt where it sits on nut
    out = {(x + a_, y + b_) for x, y in bolt for a_, b_ in ((1, 0), (-1, 0), (0, 1), (0, -1))} - bolt
    for x, y in out:
        if 0 <= x < S and 0 <= y < S and g.g[y][x] != '.':
            g.g[y][x] = 'k'
    if big:
        g.px([(20, 3), (19, 4), (18, 6)], 'H')
        g.px([(6, 11), (6, 12), (7, 10)], 'H')
    else:
        g.px([(12, 2)], 'H')
        g.px([(4, 7)], 'H')
    return g


def macadamia(S):
    g = G(S)
    big = S == 32
    # impact burst behind
    pts = []
    n = 10
    cx, cy = 16, 16
    for i in range(n * 2):
        ang = -math.pi / 2 + i * math.pi / n
        r = 14.5 if i % 2 == 0 else 9.5
        pts.append((cx + r * math.cos(ang), cy + r * math.sin(ang)))
    burst = g.mask_poly(pts)
    g.put(burst, 'G')
    for x, y in ring(burst):
        g.g[y][x] = 'o'
    ball = g.mask_ell(16, 16.5, 9.8, 9.8)
    out = {(x + a, y + b) for x, y in ball for a, b in ((1, 0), (-1, 0), (0, 1), (0, -1))} - ball
    g.put(out, 'k')
    g.shade(ball, rim=2 if big else 1)
    # cracks radiating from impact point top-right
    if big:
        g.px([(20, 9), (19, 10), (19, 11), (18, 12), (17, 13), (17, 14), (16, 15), (20, 12), (21, 13), (22, 14),
              (16, 11), (15, 11), (14, 10)], 'E')
        g.px([(9, 12), (9, 13), (10, 11), (11, 10), (10, 14)], 'H')
        g.px([(11, 10)], 'H')
    else:
        g.px([(12, 6), (12, 7), (11, 8), (11, 9), (13, 8), (14, 9)], 'E')
        g.px([(6, 7), (6, 8), (7, 6)], 'H')
    return g


def pecan(S):
    g = G(S)
    big = S == 32
    T, B1, F = (2.5, 19), (19, 7.5), (29.5, 14)
    side = g.mask_poly([T, F, (29.5, 24.5), (2.5, 28)])
    g.put(side, 'D')
    # bottom crust strip of the side face
    g.put(side - g.mask_poly([T, F, (29.5, 21.5), (2.5, 25)]), 'L')
    for x, y in side:
        if (x + 1, y) not in side or (x, y + 1) not in side:
            g.g[y][x] = 'E'
    top = g.mask_poly([T, B1, F])
    g.shade(top, B='B', L='B', D='D', E='D')
    crust = g.mask_line(B1[0], B1[1], F[0], F[1], 3.8 if big else 4.6)
    crust = (crust - side) | (crust & side & g.mask_poly([(24, 0), (32, 0), (32, 32), (27, 32)]))
    g.put(crust, 'L')
    for x, y in crust:
        if (x + 1, y) not in crust or (x, y + 1) not in crust:
            g.g[y][x] = 'D'
    if big:
        for t in (0.15, 0.45, 0.75):
            x, y = int(B1[0] + t * (F[0] - B1[0]) + 1.5), int(B1[1] + t * (F[1] - B1[1]) - 1)
            g.g[y][x] = 'D'
    nuts = [(10.5, 17.5, -0.45), (18, 12.5, -0.45), (20, 17, -0.45)] if big else [(11, 17.5, -0.45), (19, 14, -0.45)]
    for nx, ny, r in nuts:
        m = g.mask_ell(nx, ny, 3.2, 1.9, r)
        g.put(m, 'n')
        for x, y in m:
            if (x - 1, y) not in m or (x, y - 1) not in m:
                g.g[y][x] = 'N'
        if big:
            g.px([(int(nx), int(ny))], 'v')
    if big:
        g.px([(7, 18), (8, 17)], 'H')
        g.px([(21, 7), (22, 8)], 'H')
    else:
        g.px([(12, 5)], 'H')
    # steam (simmer): smooth 2px wisps
    wisps = [((5, 14), (3.5, 10.5), (5.5, 7), (4, 3.5)), ((13, 10.5), (11.5, 7.5), (13.5, 4.5), (12, 1.5))] if big else \
        [((6.5, 13), (4.5, 9), (6.5, 5), (5, 1.5))]
    for w in wisps:
        m = set()
        for p, q in zip(w, w[1:]):
            m |= g.mask_line(p[0], p[1], q[0], q[1], 1.8 if big else 2.6)
        m = {(x, y) for x, y in m if g.g[y][x] == '.'}
        g.put(m, 'C')
        for x, y in m:
            if (x + 1, y) not in m:
                g.g[y][x] = 'c'
    return g


def pistachio(S):
    g = G(S)
    big = S == 32
    shell = g.mask_ell(16, 19.5, 10, 11.5)
    gap = g.mask_poly([(16, 21), (5, 3), (27, 3)])
    shell -= gap
    kern = g.mask_ell(16, 12.5, 5.3, 7.2) - shell
    g.shade(kern, B='g', L='J', D='j', E='j')
    if big:
        g.px([(13, 8), (13, 9), (14, 7)], 'J')
        g.px([(18, 13), (19, 14), (17, 15)], 'p')
    else:
        g.px([(11, 9)], 'p')
    out = {(x + a, y + b) for x, y in shell for a, b in ((1, 0), (-1, 0), (0, 1), (0, -1))} - shell
    g.put(out & kern, 'k')
    g.shade(shell, rim=2 if big else 1)
    # inner lip of shell halves (cream inside of shell)
    for x, y in shell:
        if (x, y - 1) not in shell and (x, y - 1) in (kern | out) and y > 8:
            pass
    # center seam at bottom
    g.put(g.mask_line(16, 23, 16, 29, 1.0 if big else 1.4) & shell, 'D')
    if big:
        g.px([(8, 16), (8, 17), (8, 18), (9, 15), (8, 19)], 'H')
    else:
        g.px([(5, 11), (5, 12)], 'H')
    # pop lines (pluck)
    if big:
        pass
    else:
        pass
    return g


def shea(S):
    g = G(S)
    big = S == 32
    sh = g.mask_poly([(3.5, 6), (28.5, 6), (28.5, 17), (23, 25), (16, 30), (9, 25), (3.5, 17)])
    g.shade(sh, rim=2 if big else 1)
    # butter coat: thick slab on top + drips
    but = g.mask_ell(16, 6.5, 13.4, 4.4)
    but |= g.mask_poly([(3, 6), (29, 6), (29, 10), (3, 10)])
    for dx, ln in ((7, 15), (14, 12.5), (20.5, 17), (26, 12.5)):
        but |= g.mask_line(dx, 9, dx, ln, 3.0 if big else 3.6)
    but -= g.mask_poly([(0, 0), (32, 0), (32, 2.6), (0, 2.6)])
    g.put(but, 'y')
    for x, y in but:
        if (x - 1, y) not in but or (x, y - 1) not in but:
            g.g[y][x] = 'Y'
        elif (x + 1, y) not in but or (x, y + 1) not in but:
            g.g[y][x] = 'u'
    if big:
        g.px([(7, 4), (8, 4), (9, 3), (10, 3)], 'H')
        g.px([(6, 18), (6, 19), (7, 20), (8, 21)], 'H')
    else:
        g.px([(4, 3), (5, 2)], 'H')
    return g


def walnut(S):
    g = G(S)
    big = S == 32
    nut = g.mask_ell(15, 17.5, 11.5, 11)
    g.shade(nut, rim=2 if big else 1)
    # seam
    g.put(g.mask_line(15, 7, 15, 28.5, 1.0 if big else 1.4) & nut, 'E')
    # wrinkles
    if big:
        w = [(9, 11), (10, 11), (8, 14), (9, 15), (11, 14), (7, 19), (8, 19), (10, 18), (11, 22), (9, 23), (12, 25),
             (19, 11), (20, 11), (21, 14), (19, 16), (22, 18), (20, 20), (18, 23), (21, 23)]
        g.px(w, 'D')
        g.px([(7, 10), (8, 9), (6, 12), (6, 13), (10, 8)], 'H')
    else:
        g.px([(6, 8), (6, 11), (7, 13), (12, 8), (13, 11), (11, 14)], 'D')
        g.px([(4, 7), (5, 6)], 'H')
    # crack (zig) where spike enters
    # spike: steel nail from top-right, tip out bottom-left
    if big:
        spike = g.mask_poly([(30, 2), (28, 2), (8, 24), (7.5, 26.5), (10, 26), (30, 4)])
        head = g.mask_ell(27.5, 4.5, 3.6, 2.2, -0.79)
    else:
        spike = g.mask_poly([(30.5, 1.5), (28, 1.5), (7, 24), (6, 28), (10, 27), (30.5, 4)])
        head = g.mask_ell(27.5, 4.5, 4.2, 2.6, -0.79)
    allsp = spike | head
    out = {(x + a, y + b) for x, y in allsp for a, b in ((1, 0), (-1, 0), (0, 1), (0, -1))} - allsp
    for x, y in out:
        if 0 <= x < S and 0 <= y < S and g.g[y][x] != '.':
            g.g[y][x] = 'k'
    g.put(allsp, 'm')
    for x, y in allsp:
        if (x - 1, y) not in allsp or (x, y - 1) not in allsp:
            g.g[y][x] = 'M'
        elif (x + 1, y) not in allsp or (x, y + 1) not in allsp:
            g.g[y][x] = 'n'
    return g


def saffron(S):
    g = G(S)
    big = S == 32
    # spool on the left
    body = g.mask_poly([(5, 9), (17, 9), (17, 25), (5, 25)])
    g.shade(body, rim=1)
    if big:
        for y in range(10, 25, 3):
            g.put(g.mask_line(6, y + 2, 16, y, 0.9) & body, 'D')
    else:
        for y in (11, 16, 21):
            g.put(g.mask_line(6, y + 2.5, 16, y, 1.3) & body, 'D')
    for yy in (5.5, 26):
        fl = g.mask_poly([(2.5, yy), (19.5, yy), (19.5, yy + 3.8), (2.5, yy + 3.8)])
        g.put(fl, 'w')
        for x, y in fl:
            if (x, y - 1) not in fl or (x - 1, y) not in fl:
                g.g[y][x] = 'W'
            elif (x, y + 1) not in fl or (x + 1, y) not in fl:
                g.g[y][x] = 'v'
    # thread trailing to a heart on the right
    hx, hy = 23.5, 12.5
    heart = g.mask_ell(hx - 3, hy - 2.2, 3.6, 3.6) | g.mask_ell(hx + 3, hy - 2.2, 3.6, 3.6) | \
        g.mask_poly([(hx - 6.6, hy - 1.5), (hx + 6.6, hy - 1.5), (hx, hy + 7)])
    g.shade(heart, rim=1, E='D')
    if big:
        g.px([(19, 8), (18, 9)], 'H')
    else:
        g.px([(12, 5)], 'H')
    thr = g.mask_line(17, 18, 21, 20.5, 1.6 if big else 1.9) | g.mask_line(21, 20.5, 23.5, 19, 1.6 if big else 1.9)
    g.put(thr - heart, 'B')
    if big:
        g.px([(8, 11), (7, 12), (7, 13)], 'H')
    else:
        g.px([(4, 7)], 'H')
    return g


ICONS = {
    'pl-g-hazelnut': hazelnut, 'pl-g-kola': kola, 'pl-g-macadamia': macadamia, 'pl-g-pecan': pecan,
    'pl-g-pistachio': pistachio, 'pl-g-shea': shea, 'pl-g-walnut': walnut, 'pl-g-saffron': saffron,
}

if __name__ == '__main__':
    only = sys.argv[1:]
    for slug, fn in ICONS.items():
        if only and slug not in only:
            continue
        for S in (32, 20):
            fn(S).write(slug)
    print('grids ok')
