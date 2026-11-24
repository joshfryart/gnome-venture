#!/usr/bin/env python3
"""Redraw of the weak stat icons (PIL, no Aseprite): Knot of Twine, Lucky Streak (32 + 20 px) and the
foot-based Nimble 20 px icons (Sidestep, Shadow Step, Phantom Footing, -s only).

Same finishing as the rest of the kit (../mockup-opus/pix.py): 1 px ink #2a1a10 edge, 1 px cream halo on
the 32 px size only, hard pixels, no partial alpha, type colours from gen_pfight.TYPES.
Overwrites game/assets/img/pfight/pieces/ico-<key>[-s].png.  The .aseprite sources of these icons are
not regenerated (no Aseprite needed); this script is the source of truth for the redrawn PNGs.

Run: python3 redraw_weak.py [key ...]        (default: all five)
"""
import math
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, '..', 'mockup-opus'))
import pix  # noqa: E402

ROOT = os.path.abspath(os.path.join(HERE, '..', '..', '..', '..'))
OUT = os.path.join(ROOT, 'game', 'assets', 'img', 'pfight', 'pieces')


def rgb(h):
    return tuple(int(h[i:i + 2], 16) for i in (0, 2, 4))


# ---------------------------------------------------------------- knot of twine
# a trefoil knot (three lobes, over / under at the three crossings), each lobe one strand colour
# (red body, blue mind, gold craft: the three families the knot links)
KNOT_PAL = {
    'r': rgb('c85454'), 'R': rgb('ec8c7c'), 'S': rgb('8c2828'),   # red   base / light / shade
    'b': rgb('3460a8'), 'N': rgb('749ede'), 'T': rgb('1e3062'),   # blue
    'y': rgb('f0e442'), 'Y': rgb('f6ed6c'), 'Z': rgb('918137'),   # gold
}
KNOT_COL = ['r', 'y', 'b']


def trefoil(S, scale, half, cx, cy, cols=None):
    """painter's order: strands under (z<=0) first, then over (z>0); each pass inks its own outline,
    except against the strand it is a part of (so there is a dark gap only where one strand crosses another)"""
    N = 1200
    pts = []
    for i in range(N):
        t = 2 * math.pi * i / N
        pts.append((cx + (math.sin(t) + 2 * math.sin(2 * t)) * scale,
                    cy + (math.cos(t) - 2 * math.cos(2 * t)) * scale, -math.sin(3 * t), t))

    def circ(a, b):
        d = abs(a - b) % (2 * math.pi)
        return min(d, 2 * math.pi - d)

    def cover(sel, r):
        m = {}
        for (x, y, z, t) in pts:
            if not sel(z):
                continue
            for py in range(max(0, int(y - r - 1)), min(S, int(y + r + 2))):
                for px in range(max(0, int(x - r - 1)), min(S, int(x + r + 2))):
                    d = math.hypot(px + .5 - x, py + .5 - y)
                    if d <= r and (px, py) not in m or (d <= r and d < m[(px, py)][0]):
                        m[(px, py)] = (d, t, x, y)
        return m
    cell = {}

    def paint(m, ink_m):
        for k, (d, t, x, y) in ink_m.items():
            if k in m:
                continue
            old = cell.get(k)
            if old is None or circ(old[1], t) > 0.9:
                cell[k] = ('k', t)
        for (px, py), (d, t, x, y) in m.items():
            ox, oy = px + .5 - x, py + .5 - y
            lit = (-ox - oy) / (half * 1.414)
            cell[(px, py)] = ('L' if lit > .5 else 'D' if lit < -.5 else 'B', t)
    for sel in (lambda z: z <= 0, lambda z: z > 0):
        paint(cover(sel, half), cover(sel, half + 1))
    cols = cols or [('R', 'r', 'S'), ('Y', 'y', 'Z'), ('N', 'b', 'T')]   # red, gold, blue strand (light, base, shade)
    g = [['.'] * S for _ in range(S)]
    for (px, py), (ch, t) in cell.items():
        # the strand colour changes in the middle of each over-run, so a colour change never sits on a crossing
        c = cols[int(((t + math.pi / 6) % (2 * math.pi)) / (2 * math.pi / 3)) % 3]
        g[py][px] = 'k' if ch == 'k' else c['LBD'.index(ch)]
    return [''.join(r) for r in g]


# ---------------------------------------------------------------- lucky streak
# a four-leaf clover racing right with a trail of three gold streaks and a spark
CLOV_PAL = {'q': rgb('4eaa48'), 'Q': rgb('9cd668'), 'z': rgb('266c3a'),
            'y': rgb('f0e442'), 'Y': rgb('f6ed6c'), 'Z': rgb('918137')}


def clover(S, cx, cy, off, r, stem, streaks, spark):
    g = [['.'] * S for _ in range(S)]

    def put(x, y, ch):
        if 0 <= x < S and 0 <= y < S:
            g[y][x] = ch
    # the streak: gold sparkles trailing behind (x, y, arm): a plus with a light core
    for (x, y, arm) in streaks:
        for k in range(1, arm + 1):
            for dx, dy in ((k, 0), (-k, 0), (0, k), (0, -k)):
                put(x + dx, y + dy, 'y' if k < arm or arm == 1 else 'Z')
        put(x, y, 'Y')
        if arm >= 2:
            for dx, dy in ((1, 1), (-1, 1), (1, -1), (-1, -1)):
                put(x + dx, y + dy, 'Z' if dy > 0 else 'y')
    # four heart-ish leaves: a disc per leaf, flattened toward the centre
    for sx, sy in ((-1, -1), (1, -1), (-1, 1), (1, 1)):
        lx, ly = cx + sx * off, cy + sy * off
        for y in range(S):
            for x in range(S):
                if math.hypot(x + .5 - lx, y + .5 - ly) <= r:
                    put(x, y, 'q')
    for sx, sy in ((-1, -1), (1, -1), (-1, 1), (1, 1)):
        lx, ly = cx + sx * off, cy + sy * off
        for y in range(S):
            for x in range(S):
                d = math.hypot(x + .5 - lx, y + .5 - ly)
                if d <= r and g[y][x] in 'qQz':
                    if (x + .5 - lx) * -1 + (y + .5 - ly) * -1 > r * .85:
                        g[y][x] = 'Q'
                    elif (x + .5 - lx) + (y + .5 - ly) > r * 1.05:
                        g[y][x] = 'z'
    for yy in range(S):
        for xx in range(S):
            if math.hypot(xx + .5 - cx, yy + .5 - cy) <= (1.6 if S >= 32 else 1.2):
                put(xx, yy, 'z')
    # heart cleft at each outer tip and a dark vein (32 px only)
    if S >= 32:
        for sx, sy in ((-1, -1), (1, -1), (-1, 1), (1, 1)):
            lx, ly = cx + sx * off, cy + sy * off
            put(int(lx + sx * (r - .6)) - (1 if sx < 0 else 0), int(ly + sy * (r - .6)) - (1 if sy < 0 else 0), '.')
            for k in (1, 2, 3):
                put(int(cx + sx * k * 1.5) - (1 if sx < 0 else 0), int(cy + sy * k * 1.5) - (1 if sy < 0 else 0), 'z')
    for i in range(-int(off + r) + 1, int(off + r)):
        for (x, y) in ((int(cx) + i, int(cy) - 1), (int(cx) - 1, int(cy) + i)):
            if g[y][x] in 'qQ':
                pass
    # stem: a short curve down-left
    for (x, y) in stem:
        put(x, y, 'z')
    if spark:
        for (x, y) in spark:
            put(x, y, 'H')
    return [''.join(r) for r in g]


# ---------------------------------------------------------------- nimble 20 px feet
FOOT = [  # a right foot, big toe on the left: L light, B base, D shade; four toe dots float over the sole
    '.LL.LL.....',
    'LBD.BD.LL..',
    '.DD.DD.BD.L',
    '...........',
    '.LBBBBBBBD.',
    'LLBBBBBBBBD',
    'LBBBBBBBBBD',
    '.BBBBBBBBD.',
    '..BBBBBBD..',
    '...BBBBBD..',
    '..LBBBBBD..',
    '..LBBBBD...',
    '...DDDD....',
]
FOOT_PAL = {  # extra palette chars (see pix.BASE for k C H G)
    'a': rgb('e6da8c'), 'A': rgb('fcf6c4'), 'c': rgb('c8b868'),                    # pale ghost yellow: base light dark
    'f': rgb('de8c64'), 'F': rgb('b0583e'),                                        # speed bar
    'u': rgb('0072b2'), 'U': rgb('61a2c3'), 'v': rgb('06437c'),                    # blue
    'p': rgb('5c4274'), 'P': rgb('84649c'), 'o': rgb('3e2a54'), 'e': rgb('ffec96'),  # purple shadow, eyes
    'g': rgb('accee2'), 'G2': None, 'i': rgb('769ec0'), 'I': rgb('e0f0f8'),        # ghost blue
    'y': rgb('f0e442'), 'Y': rgb('f6ed6c'), 'Z': rgb('918137'),
}
FOOT_PAL.pop('G2')


def stamp(grid, pat, x0, y0, m, ring=False):
    """draw pattern pat (chars L B D, '.' clear) at x0,y0 mapping L B D through m; ring = ink outline round it"""
    S = len(grid)
    cells = {(x0 + x, y0 + y): m[ch] for y, row in enumerate(pat) for x, ch in enumerate(row) if ch != '.'}
    if ring:
        for (x, y) in list(cells):
            for dx, dy in pix.N4:
                q = (x + dx, y + dy)
                if q not in cells and 0 <= q[0] < S and 0 <= q[1] < S:
                    grid[q[1]][q[0]] = 'k'
    for (x, y), ch in cells.items():
        if 0 <= x < S and 0 <= y < S:
            grid[y][x] = ch


def foot_grid(kind):
    S = 20
    g = [['.'] * S for _ in range(S)]
    if kind == 'sidestep':
        for y, x0, x1 in ((1, 2, 6), (3, 1, 7), (5, 2, 6)):           # speed bars, top left
            for x in range(x0, x1 + 1):
                g[y][x] = 'f' if x < x1 else 'F'
        stamp(g, FOOT, 1, 6, {'L': 'A', 'B': 'a', 'D': 'c'})            # the foot it left behind (ghost)
        stamp(g, FOOT, 8, 1, {'L': 'Y', 'B': 'y', 'D': 'Z'}, ring=True)  # the foot that stepped aside
    elif kind == 'shadow':
        stamp(g, FOOT, 8, 6, {'L': 'P', 'B': 'p', 'D': 'o'})            # the shadow, with eyes
        g[12][12] = g[12][15] = 'e'
        stamp(g, FOOT, 1, 1, {'L': 'U', 'B': 'u', 'D': 'v'}, ring=True)  # the gnome's foot
    elif kind == 'phantom':
        stamp(g, FOOT[:11], 3, 1, {'L': 'I', 'B': 'g', 'D': 'i'})
        for y, x0, x1 in ((12, 5, 10), (13, 7, 13), (14, 11, 16)):
            for x in range(x0, x1 + 1):
                g[y][x] = 'i' if x == x1 or y == 14 else 'g'
        g[13][17] = g[12][17] = 'i'
        g[11][18] = 'I'
        g[14][17] = 'i'
        g[11][17] = 'i'
        g[12][16] = 'g'
    return [''.join(r) for r in g]


def save(key, suf, grid, halo):
    im = pix.render(grid, {**KNOT_PAL, **CLOV_PAL, **FOOT_PAL}, halo)
    im.save(os.path.join(OUT, 'ico-%s%s.png' % (key, suf)))


def main():
    only = [a for a in sys.argv[1:] if not a.startswith('-')]
    jobs = {}
    jobs['stat-knot-of-twine'] = [('', trefoil(32, 4.1, 1.7, 15.9, 16.7), True),
                                  ('-s', trefoil(20, 2.9, 1.0, 9.9, 10.3), False)]
    jobs['stat-lucky-streak'] = [
        ('', clover(32, 20.5, 14.0, 4.5, 4.7, [(19, 24), (19, 25), (18, 26), (17, 27), (16, 27)], [(8, 14, 3), (5, 8, 2), (6, 21, 1)], None), True),
        ('-s', clover(20, 13.0, 8.5, 3.0, 2.9, [(12, 15), (11, 16), (10, 16)], [(5, 10, 2), (3, 15, 1)], None), False)]
    for k, f in (('stat-sidestep', 'sidestep'), ('stat-shadow-step', 'shadow'), ('stat-phantom-footing', 'phantom')):
        jobs[k] = [('-s', foot_grid(f), False)]
    for key, items in jobs.items():
        if only and key not in only:
            continue
        for suf, grid, halo in items:
            bad = [(x, y) for y, r in enumerate(grid) for x, c in enumerate(r) if c not in '.k'
                   and (x < 1 or y < 1 or x >= len(grid) - 1 or y >= len(grid) - 1)]   # art must leave room for its ink
            if bad:
                print('EDGE', key, suf, bad[:5])
            save(key, suf, grid, halo)
        print('ok', key)


if __name__ == '__main__':
    main()
