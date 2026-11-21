"""Tiny helpers for hand-authored pixel grids.

A grid is a list of strings, one char per pixel ('.' = clear).  The palette maps
chars to RGB.  finish() adds the 1px INK edge around the coloured shape (ink
pixels drawn in the grid count as edge already, so thin ink legs stay thin) and,
for 32px icons, the 1px CREAM halo, matching gen_pfight.finish_icon.
"""
import os
import sys
from PIL import Image

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..'))
import gen_pfight as gp  # noqa: E402

INK, CREAM, WHITE, GOLD, TYPES = gp.INK, gp.CREAM, gp.WHITE, gp.GOLD, gp.TYPES
light_of, dark_of = gp.light_of, gp.dark_of

BASE = {'k': INK, 'C': CREAM, 'H': WHITE, 'G': GOLD}

N4 = ((1, 0), (-1, 0), (0, 1), (0, -1))
N8 = N4 + ((1, 1), (-1, -1), (1, -1), (-1, 1))


def type_pal(t):
    b = TYPES[t]
    return {'B': b, 'L': light_of(b), 'D': dark_of(b), 'E': dark_of(dark_of(b))}


def render(grid, pal, halo):
    S = len(grid)
    assert all(len(r) == S for r in grid), [(i, len(r)) for i, r in enumerate(grid) if len(r) != S]
    P = dict(BASE)
    P.update(pal)
    px = [[None] * S for _ in range(S)]
    for y, row in enumerate(grid):
        for x, ch in enumerate(row):
            if ch != '.':
                px[y][x] = P[ch]

    def at(x, y):
        return px[y][x] if 0 <= x < S and 0 <= y < S else None
    # ink edge: clear pixels touching a coloured (non-ink) pixel
    add = [(x, y) for y in range(S) for x in range(S)
           if px[y][x] is None and any(at(x + dx, y + dy) not in (None, INK) for dx, dy in N4)]
    for x, y in add:
        px[y][x] = INK
    if halo:
        add = [(x, y) for y in range(S) for x in range(S)
               if px[y][x] is None and any(at(x + dx, y + dy) is not None for dx, dy in N8)]
        for x, y in add:
            px[y][x] = CREAM
    im = Image.new('RGBA', (S, S), (0, 0, 0, 0))
    for y in range(S):
        for x in range(S):
            if px[y][x] is not None:
                im.putpixel((x, y), px[y][x] + (255,))
    return im


def check_edges(grid, margin):
    """coloured pixels must stay `margin` px off the canvas edge (room for ink + halo)"""
    S = len(grid)
    bad = [(x, y) for y, r in enumerate(grid) for x, c in enumerate(r)
           if c != '.' and (x < margin or y < margin or x >= S - margin or y >= S - margin)]
    return bad
