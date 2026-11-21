#!/usr/bin/env python3
"""q02 private helper: builds the character grids from simple shapes, with 1px
top-left light / bottom-right shade per layer, then the grids get hand-touched.
Writes into mockup-opus/q02/grids/."""
import math
import os
import sys

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'grids')

# material -> (light, base, dark)
M = {
    'T': ('L', 'B', 'D'),       # type colour
    'W': ('w', 'W', 'x'),       # wood
    'V': ('v', 'V', 'u'),       # leaf green
    'G': ('g', 'G', 'o'),       # gold
    'C': ('H', 'C', 'c'),       # cream / stone
    'F': ('y', 'f', 'r'),       # flame
    'P': ('q', 'p', 'n'),       # poison green
    'A': ('a', 'A', 'j'),       # teal
    'K': ('k', 'k', 'k'),       # ink
    'X': ('D', 'D', 'E'),       # dark type (interiors)
    'I': ('L', 'L', 'B'),       # light type
}


class Cv:
    def __init__(s, n):
        s.n = n
        s.g = [['.'] * n for _ in range(n)]

    def layer(s, pts, mat, outline=False, flat=False):
        pts = set((x, y) for x, y in pts if 0 <= x < s.n and 0 <= y < s.n)
        l, b, d = M[mat]
        if outline:
            ring = set()
            for x, y in pts:
                for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    q = (x + dx, y + dy)
                    if q not in pts and 0 <= q[0] < s.n and 0 <= q[1] < s.n and s.g[q[1]][q[0]] != '.':
                        ring.add(q)
            for x, y in ring:
                s.g[y][x] = 'k'
        for x, y in pts:
            if flat:
                c = b
            elif (x - 1, y) not in pts or (x, y - 1) not in pts:
                c = l
            elif (x + 1, y) not in pts or (x, y + 1) not in pts:
                c = d
            else:
                c = b
            s.g[y][x] = c

    def put(s, x, y, c):
        if 0 <= x < s.n and 0 <= y < s.n:
            s.g[y][x] = c

    def text(s):
        return '\n'.join(''.join(r) for r in s.g) + '\n'


def ell(cx, cy, rx, ry):
    return [(x, y) for y in range(64) for x in range(64)
            if ((x + .5 - cx) / rx) ** 2 + ((y + .5 - cy) / ry) ** 2 <= 1]


def rect(x0, y0, x1, y1):
    return [(x, y) for y in range(y0, y1 + 1) for x in range(x0, x1 + 1)]


def cap(x0, y0, x1, y1, r):
    out = []
    for y in range(64):
        for x in range(64):
            px, py = x + .5, y + .5
            vx, vy = x1 - x0, y1 - y0
            L = vx * vx + vy * vy or 1
            t = max(0, min(1, ((px - x0) * vx + (py - y0) * vy) / L))
            if (px - x0 - t * vx) ** 2 + (py - y0 - t * vy) ** 2 <= r * r:
                out.append((x, y))
    return out


def poly(P):
    out = []
    for y in range(64):
        for x in range(64):
            px, py = x + .5, y + .5
            ins = False
            j = len(P) - 1
            for i in range(len(P)):
                xi, yi = P[i]
                xj, yj = P[j]
                if (yi > py) != (yj > py) and px < (xj - xi) * (py - yi) / (yj - yi) + xi:
                    ins = not ins
                j = i
            if ins:
                out.append((x, y))
    return out


def arc(cx, cy, r0, r1, a0, a1):
    """ring sector, angles in degrees (0 = right, 90 = down)"""
    out = []
    for y in range(64):
        for x in range(64):
            dx, dy = x + .5 - cx, y + .5 - cy
            d = math.hypot(dx, dy)
            a = math.degrees(math.atan2(dy, dx)) % 360
            lo, hi = a0 % 360, a1 % 360
            ina = (lo <= a <= hi) if lo <= hi else (a >= lo or a <= hi)
            if r0 <= d <= r1 and ina:
                out.append((x, y))
    return out


def minus(a, b):
    b = set(b)
    return [p for p in a if p not in b]


def S(v, s):
    return v * s / 32.0


# ---------------------------------------------------------------- icons
def wayfind(cv, n):
    if n == 32:
        cv.layer(rect(14, 2, 17, 28), 'W')
        cv.layer(poly([(4, 5), (21, 5), (27, 9.5), (21, 14), (4, 14)]), 'T', outline=True)
        cv.layer(poly([(27, 18), (11, 18), (5, 22), (11, 26), (27, 26)]), 'T', outline=True)
        cv.layer(poly([(9, 30), (11, 26.5), (13, 28), (16, 25.5), (19, 28), (21, 26.5), (23, 30)]), 'V', outline=True)
        cv.layer(rect(14, 15, 17, 16), 'W')
        for x, y in ((6, 7), (7, 7), (13, 20), (14, 20)):
            cv.put(x, y, 'H')
        for x in range(7, 19):
            cv.put(x, 9, 'D' if x % 3 else 'B')
        for x in range(12, 24):
            cv.put(x, 22, 'D' if x % 3 else 'B')
    else:
        cv.layer(rect(9, 1, 10, 17), 'W')
        cv.layer(poly([(2, 3), (13, 3), (17, 6), (13, 9), (2, 9)]), 'T', outline=True)
        cv.layer(poly([(17, 11), (7, 11), (3, 13.5), (7, 16), (17, 16)]), 'T', outline=True)
        cv.layer(rect(9, 10, 10, 10), 'W')
        cv.layer(rect(6, 18, 13, 18), 'V')
        cv.put(4, 4, 'H')
        cv.put(8, 12, 'H')


def brew(cv, n):
    if n == 32:
        # handle (ring)
        cv.layer(arc(8, 18, 3.5, 6.5, 90, 270), 'T')
        # spout
        cv.layer(cap(21, 21, 29, 12, 2.3), 'T')
        # body
        cv.layer(ell(15.5, 19.5, 10.5, 9), 'T', outline=True)
        cv.layer(rect(7, 27, 24, 28), 'X')
        # lid
        cv.layer(ell(15.5, 11, 6, 2.5), 'I', outline=True)
        cv.layer(ell(15.5, 8, 2, 2), 'G')
        for x, y in ((9, 15), (10, 14), (11, 14), (9, 16)):
            cv.put(x, y, 'H')
        # steam
        cv.layer(cap(28, 9, 26, 6, 1) + cap(26, 6, 28, 3, 1), 'C', flat=True)
    else:
        cv.layer(arc(5, 11, 2, 4.2, 90, 270), 'T')
        cv.layer(cap(13, 13, 18, 7, 1.5), 'T')
        cv.layer(ell(10, 12, 7, 6), 'T', outline=True)
        cv.layer(ell(10, 6.5, 4, 1.8), 'I', outline=True)
        cv.layer(rect(9, 3, 10, 4), 'G')


def roots(cv, n):
    if n == 32:
        cv.layer(poly([(10, 18), (2, 28), (7, 29), (12, 23)]), 'T')
        cv.layer(poly([(13, 21), (11, 30), (17, 30), (17, 21)]), 'T')
        cv.layer(poly([(20, 18), (29, 27), (24, 29), (19, 23)]), 'T')
        cv.layer(poly([(8, 6), (24, 6), (24, 18), (27, 24), (21, 22), (16, 25), (11, 22), (5, 24), (8, 18)]), 'T', outline=True)
        for x, y0, y1 in ((12, 10, 20), (17, 11, 22), (21, 9, 18)):
            for y in range(y0, y1):
                cv.put(x, y, 'D')
        cv.layer(ell(16, 6.5, 8, 3.2), 'C', outline=True)
        for x in range(12, 21):
            if x not in (16,):
                cv.put(x, 6 if x in (12, 20) else (5 if 13 <= x <= 19 else 6), 'c' if x in (12, 20) or x in (13, 19) else 'C')
        for x in range(14, 19):
            cv.put(x, 7, 'c')
        cv.put(10, 8, 'H'); cv.put(10, 9, 'H')
    else:
        cv.layer(poly([(6, 11), (1, 18), (4.5, 18.5), (8, 14)]), 'T')
        cv.layer(poly([(9, 14), (8, 19), (12, 19), (11, 14)]), 'T')
        cv.layer(poly([(13, 11), (19, 17), (15.5, 18.5), (12, 14)]), 'T')
        cv.layer(poly([(4, 4), (16, 4), (16, 11), (18, 15), (13, 14), (10, 16), (7, 14), (2, 15), (4, 11)]), 'T', outline=True)
        for y in range(7, 13):
            cv.put(8, y, 'D')
        for y in range(8, 13):
            cv.put(13, y, 'D')
        cv.layer(ell(10, 4.5, 6, 2.2), 'C', outline=True)
        for x in range(8, 12):
            cv.put(x, 4, 'c')
        cv.put(6, 7, 'H')


def bloomb(cv, n):
    if n == 32:
        cv.layer(cap(16, 18, 16, 29, 1.3), 'V')
        cv.layer(poly([(16, 27), (9, 22), (6, 24), (10, 28)]), 'V', outline=True)
        cv.layer(poly([(16, 26), (23, 21), (26, 23), (22, 27)]), 'V', outline=True)
        heart = ell(11, 9.5, 7, 6.5) + ell(21, 9.5, 7, 6.5) + poly([(4.3, 11), (27.7, 11), (16, 23)])
        cv.layer(heart, 'T', outline=True)
        cv.layer(ell(16, 12, 3, 3), 'G', outline=True)
        for x, y in ((7, 6), (8, 5), (6, 7)):
            cv.put(x, y, 'H')
    else:
        cv.layer(cap(10, 12, 10, 18.5, 1), 'V')
        cv.layer(poly([(10, 17), (5, 14), (3, 15.5), (6, 18)]), 'V', outline=True)
        heart = ell(6.8, 6.5, 4.6, 4.4) + ell(13.2, 6.5, 4.6, 4.4) + poly([(2.3, 7.5), (17.7, 7.5), (10, 15.5)])
        cv.layer(heart, 'T', outline=True)
        cv.layer(ell(10, 8, 2, 2), 'G', outline=True)


def barb(cv, n):
    if n == 32:
        shape = cap(22, 5, 22, 15, 2.2) + arc(14, 15, 5.5, 10, 0, 180) \
            + cap(6.2, 15, 6.2, 10, 2.1) + poly([(4, 13), (5.3, 2.5), (12.5, 12), (8.3, 13)])
        cv.layer(shape, 'T')
        cv.layer(minus(ell(22, 4, 3.6, 3.2), ell(22, 4, 1.4, 1.2)), 'T', outline=True)
        cv.layer(ell(14, 28, 2.4, 2.4) + poly([(11.8, 28), (14, 24), (16.2, 28)]), 'P', outline=True)
        cv.put(13, 27, 'H')
        cv.put(5, 6, 'H'); cv.put(5, 7, 'H')
    else:
        shape = cap(14, 4, 14, 9, 1.6) + arc(9, 9, 3, 6.3, 0, 180) \
            + cap(4, 9, 4, 6, 1.5) + poly([(2.5, 8), (3.3, 1.5), (8.3, 7.5), (5.5, 8)])
        cv.layer(shape, 'T')
        cv.layer(minus(ell(14, 3, 2.4, 2.2), ell(14, 3, .8, .8)), 'T', outline=True)
        cv.layer(ell(9, 17.6, 1.6, 1.6) + poly([(7.4, 17.6), (9, 15.2), (10.6, 17.6)]), 'P', outline=True)


def seedswap(cv, n):
    if n == 32:
        # swap arrows (two curved arrows around the seed)
        cv.layer(arc(16, 16, 11, 14, 200, 290) + poly([(24, 1), (24, 10), (30, 5.5)]), 'A')
        cv.layer(arc(16, 16, 11, 14, 20, 110) + poly([(8, 31), (8, 22), (2, 26.5)]), 'A')
        # seed (almond, tilted)
        pts = [(x, y) for y in range(32) for x in range(32)
               if (((x + .5 - 16) * .707 + (y + .5 - 16) * .707) / 9.5) ** 2 + (((x + .5 - 16) * -.707 + (y + .5 - 16) * .707) / (6.4 - .25 * ((x - 16) + (y - 16)) * .707)) ** 2 <= 1]
        cv.layer(pts, 'T', outline=True)
        for i in range(-5, 7):
            cv.put(16 + i, 16 + i, 'D')
        for i in range(-3, 5):
            cv.put(19 + i, 13 + i, 'B' if i < 4 else 'D')
            cv.put(13 + i, 19 + i, 'B')
        cv.put(11, 13, 'H'); cv.put(12, 12, 'H'); cv.put(13, 11, 'H')
    else:
        cv.layer(arc(10, 10, 7, 9.2, 200, 285) + poly([(14.5, 0.8), (14.5, 6.6), (18.5, 3.7)]), 'A')
        cv.layer(arc(10, 10, 7, 9.2, 20, 105) + poly([(5.5, 19.2), (5.5, 13.4), (1.5, 16.3)]), 'A')
        pts = [(x, y) for y in range(20) for x in range(20)
               if (((x + .5 - 10) * .707 + (y + .5 - 10) * .707) / 6.2) ** 2 + (((x + .5 - 10) * -.707 + (y + .5 - 10) * .707) / (4.2 - .25 * ((x - 10) + (y - 10)) * .707)) ** 2 <= 1]
        cv.layer(pts, 'T', outline=True)
        for i in range(-3, 4):
            cv.put(10 + i, 10 + i, 'D')
        cv.put(7, 8, 'H'); cv.put(8, 7, 'H')


def sidepath(cv, n):
    # detour arrow: steps aside past the stone where the straight path was
    if n == 32:
        cv.layer(ell(8, 12.5, 4.4, 3.8), 'C')
        pts = cap(10.5, 28.5, 10.5, 21, 2.9) + cap(10.5, 21, 20, 15, 2.9) + cap(20, 15, 20, 10, 2.9)
        cv.layer(pts + poly([(12.5, 11), (27.5, 11), (20, 2.5)]), 'T', outline=True)
        for x, y in ((9, 26), (9, 25), (9, 24), (14, 6), (15, 5)):
            cv.put(x, y, 'H')
        cv.put(6, 10, 'H'); cv.put(5, 11, 'H')
    else:
        cv.layer(ell(4.6, 7.8, 2.8, 2.5), 'C')
        pts = cap(6, 18, 6, 13, 1.9) + cap(6, 13, 12.5, 9, 1.9) + cap(12.5, 9, 12.5, 6.5, 1.9)
        cv.layer(pts + poly([(7.5, 7.2), (17.5, 7.2), (12.5, 1.2)]), 'T', outline=True)
        cv.put(5, 16, 'H'); cv.put(5, 15, 'H')
        cv.put(3, 7, 'H')


def slowbrew(cv, n):
    if n == 32:
        # flames
        cv.layer(poly([(8, 30), (10, 24), (12, 27), (14, 22), (16, 26), (18, 22), (20, 27), (22, 24), (24, 30)]), 'F')
        # legs
        cv.layer(rect(7, 24, 9, 27) + rect(22, 24, 24, 27), 'X')
        cv.layer(ell(16, 17, 12, 9) + rect(5, 11, 26, 15), 'T', outline=True)
        cv.layer(ell(16, 11, 13, 3.2), 'X', outline=True)
        cv.layer(ell(16, 11.5, 10.5, 2), 'I', flat=True)
        cv.layer(ell(12, 7, 2, 2), 'I', outline=True)
        cv.layer(ell(19, 4, 1.5, 1.5), 'I', outline=True)
        for x, y in ((7, 16), (7, 17), (8, 16)):
            cv.put(x, y, 'H')
        cv.put(11, 6, 'H')
    else:
        cv.layer(poly([(5, 19), (6.5, 15), (8, 17), (10, 14), (12, 17), (13.5, 15), (15, 19)]), 'F')
        cv.layer(ell(10, 10.5, 7.5, 6) + rect(3, 6, 16, 9), 'T', outline=True)
        cv.layer(ell(10, 6.5, 8, 2.3), 'X', outline=True)
        cv.layer(ell(10, 7, 6, 1.2), 'I', flat=True)
        cv.layer(ell(8, 3, 1.3, 1.3), 'I', outline=True)


ICONS = dict(wayfind=wayfind, brew=brew, roots=roots, bloomb=bloomb, barb=barb,
             seedswap=seedswap, sidepath=sidepath, slowbrew=slowbrew)

if __name__ == '__main__':
    os.makedirs(OUT, exist_ok=True)
    names = sys.argv[1:] or list(ICONS)
    for k in names:
        for n in (32, 20):
            cv = Cv(n)
            ICONS[k](cv, n)
            open(os.path.join(OUT, 'pl-%s-%d.txt' % (k, n)), 'w').write(cv.text())
    print('grids ok')
