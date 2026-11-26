#!/usr/bin/env python3
"""stoptiers_felt.py: widen a thin felt band (files 45-48, workshop-*) so it matches the 4 px felt band of the rest of the set.

The shipped workshop stickers have a 1 px black edge and a 2 px felt band; spring / tower / the other sets have a 4 px felt band
inside a 2 px black outline. widen_band(): the old 1 px black edge becomes felt, one more px of felt is added outside it, and
stoptiers_kit.finish() then grows the single 2 px black outline and lights the band (upper-left rim / lower-right deeper).
"""
from stoptiers_kit import depths, hexof, hexrgba, N4, sil

FELT = '#74462a'


def outside(im):
    """Transparent pixels reachable from the canvas border (enclosed holes are left to finish())."""
    W, H = im.size
    s = sil(im)
    stack = [(x, y) for x in range(W) for y in (0, H - 1)] + [(x, y) for y in range(H) for x in (0, W - 1)]
    seen = {p for p in stack if p not in s}
    stack = list(seen)
    while stack:
        x, y = stack.pop()
        for dx, dy in N4:
            q = (x + dx, y + dy)
            if 0 <= q[0] < W and 0 <= q[1] < H and q not in s and q not in seen:
                seen.add(q)
                stack.append(q)
    return seen


def widen_band(im, grow=1):
    out = outside(im)
    s = sil(im)
    edge = [p for p in s if any((p[0] + dx, p[1] + dy) in out or not (0 <= p[0] + dx < im.width and 0 <= p[1] + dy < im.height)
                                for dx, dy in N4)]
    for p in edge:
        if hexof(im.getpixel(p)) == '000000':
            im.putpixel(p, hexrgba(FELT))
    for _ in range(grow):
        out = outside(im)
        s = sil(im)
        for q in {(x + dx, y + dy) for (x, y) in s for dx, dy in N4} & out:
            im.putpixel(q, hexrgba(FELT))
