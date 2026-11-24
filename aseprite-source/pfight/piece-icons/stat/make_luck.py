#!/usr/bin/env python3
"""Luck piece icons (Opus drawing pass).

Source of truth: the hand-placed pixel grids in grids/<key>-32.txt and grids/<key>-20.txt
(one char per pixel, '.' clear; palette below). Each size is drawn on its own, the 20 px
is NOT a downscale.

For every grid this script resolves the palette, adds the 1 px ink outline and (32 px only)
the 1 px cream halo exactly like ../mockup-opus/pix.py, then hands the pixels to Aseprite
(make_luck.lua), which builds the layered source <key>.aseprite / <key>-s.aseprite
(layers halo / ink / art) and exports the game PNG from that same sprite:
  game/assets/img/pfight/pieces/ico-<key>.png  (32x32)
  game/assets/img/pfight/pieces/ico-<key>-s.png (20x20)

Run: python3 make_luck.py            (all six)
     python3 make_luck.py stat-long-shot   (one key)
Checks printed: pixels too near the edge, unknown chars, lone stray pixels.
"""
import os
import sys
import subprocess
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, '..', 'mockup-opus'))
import pix  # noqa: E402

ROOT = os.path.abspath(os.path.join(HERE, '..', '..', '..', '..'))
OUT = os.path.join(ROOT, 'game', 'assets', 'img', 'pfight', 'pieces')
ASE = os.environ.get('ASEPRITE', '/tmp/aseq/squashfs-root/AppRun')

# Luck family accent: one green four-leaf clover in every icon (q base, Q light, z dark)
PAL_EXTRA = {
    'q': (78, 170, 72), 'Q': (156, 214, 104), 'z': (38, 108, 58),
    'h': (96, 138, 64), 'j': (134, 172, 82), 'i': (60, 96, 52),      # hedge leaves (olive, apart from clover)
    'n': (46, 44, 70), 'N': (78, 76, 110), 'm': (52, 142, 156), 'M': (110, 196, 196),  # magpie black / teal sheen
    's': (150, 146, 140), 'S': (204, 198, 184), 'x': (100, 96, 98),  # metal / unlit glass
    'w': (124, 80, 46), 'W': (170, 114, 64),                         # wood
}
KEYS = [  # key, type
    ('stat-loaded-die', 'item'), ('stat-hedge-rummage', 'trick'),
    ('stat-long-shot', 'hurt'), ('stat-magpie-s-pinch', 'item'),
    ('stat-turn-of-the-coin', 'trick'), ('stat-lucky-streak', 'trick')]


def layers(grid, pal, halo):
    """-> list of (layer, x, y, rgb), same result as pix.render"""
    S = len(grid)
    assert all(len(r) == S for r in grid), [(i, len(r)) for i, r in enumerate(grid) if len(r) != S]
    P = dict(pix.BASE)
    P.update(pal)
    px = [[None] * S for _ in range(S)]
    lay = {}
    for y, row in enumerate(grid):
        for x, ch in enumerate(row):
            if ch != '.':
                if ch not in P:
                    raise SystemExit('unknown char %r at %d,%d' % (ch, x, y))
                px[y][x] = P[ch]
                lay[(x, y)] = 'ink' if ch == 'k' else 'art'

    def at(x, y):
        return px[y][x] if 0 <= x < S and 0 <= y < S else None
    add = [(x, y) for y in range(S) for x in range(S)
           if px[y][x] is None and any(at(x + dx, y + dy) not in (None, pix.INK) for dx, dy in pix.N4)]
    for x, y in add:
        px[y][x] = pix.INK
        lay[(x, y)] = 'ink'
    if halo:
        add = [(x, y) for y in range(S) for x in range(S)
               if px[y][x] is None and any(at(x + dx, y + dy) is not None for dx, dy in pix.N8)]
        for x, y in add:
            px[y][x] = pix.CREAM
            lay[(x, y)] = 'halo'
    return S, [(lay[(x, y)], x, y, px[y][x]) for y in range(S) for x in range(S) if px[y][x] is not None]


def strays(grid):
    S = len(grid)
    out = []
    for y in range(S):
        for x in range(S):
            if grid[y][x] != '.' and not any(0 <= x + dx < S and 0 <= y + dy < S and grid[y + dy][x + dx] != '.'
                                             for dx, dy in pix.N8):
                out.append((x, y))
    return out


def main():
    only = [a for a in sys.argv[1:] if not a.startswith('-')]
    tmp = tempfile.mkdtemp(prefix='luck-')
    for key, t in KEYS:
        if only and key not in only:
            continue
        pal = pix.type_pal(t)
        pal.update(PAL_EXTRA)
        for S, suf in ((32, ''), (20, '-s')):
            g = [l.rstrip('\n') for l in open(os.path.join(HERE, 'grids', '%s-%d.txt' % (key, S))) if l.strip()]
            bad = pix.check_edges(g, 2 if S == 32 else 1)
            if bad:
                print('EDGE', key, S, bad[:5])
            st = strays(g)
            if st:
                print('STRAY', key, S, st)
            n, pxs = layers(g, pal, halo=(S == 32))
            spec = os.path.join(tmp, '%s%s.txt' % (key, suf))
            with open(spec, 'w') as f:
                f.write('%d\n' % n)
                for ln, x, y, c in pxs:
                    f.write('%s %d %d %02x%02x%02x\n' % ((ln, x, y) + tuple(c)))
            subprocess.run([ASE, '-b',
                            '--script-param', 'spec=' + spec,
                            '--script-param', 'dest=' + os.path.join(HERE, key + suf + '.aseprite'),
                            '--script-param', 'png=' + os.path.join(OUT, 'ico-%s%s.png' % (key, suf)),
                            '--script', os.path.join(HERE, 'make_luck.lua')], check=True, capture_output=True)
        print('ok', key)


if __name__ == '__main__':
    main()
