"""_quad_bramble-wolf.py: private helpers for the four-legged mammal batch (bramble-wolf, badger, giant-anteater).
Loaded by those scripts with importlib (hyphenated name). Builds on rigkit; writes nothing itself. Other batches keep their own."""
import math
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from rigkit import *  # noqa

N4 = ((1, 0), (-1, 0), (0, 1), (0, -1))


def sil(R, pid):
    """the current silhouette of a part (union of its layers so far)"""
    q = R.part(pid)
    return set().union(*[m for m, _, _ in q.layers]) - q.cut if q.layers else set()


def fluff(pts, r, rr=None, gap=1.8):
    """a scalloped edge: felt tufts (circles r .. rr) spaced along a polyline"""
    rr = r if rr is None else rr
    segs = list(zip(pts, pts[1:]))
    tot = sum(math.hypot(b[0] - a[0], b[1] - a[1]) for a, b in segs) or 1
    cs, s = [], 0.0
    for j, (a, b) in enumerate(segs):
        L = math.hypot(b[0] - a[0], b[1] - a[1]); n = max(1, round(L / (r * gap)))
        for i in range(n + (1 if j == len(segs) - 1 else 0)):
            t = i / n
            cs.append(ell(a[0] + (b[0] - a[0]) * t, a[1] + (b[1] - a[1]) * t, r + (rr - r) * (s + t * L) / tot))
        s += L
    return union(*cs)


def limb(R, pid, pts, w0, w1, ramp, paw=None, extra=(), ref=None):
    """a felt leg along pts (from just above its pivot down to the ankle), paw = (cx, rx, ry) a flat-bottomed foot whose
    bottom row is the ground row. Clipped at the ground. Returns (part, mask)."""
    p = R.part(pid)
    g = R.ground + 1.0
    sh = [capsule(pts, w0, w1)] + list(extra)
    if paw:
        sh.append(ell(paw[0], g - paw[2], paw[1], paw[2]))
    m = p.m(inter(union(*sh), lambda x, y: y < g))
    p.add(m, ramp, ref=ref)
    return p, m


def seam(p, R, mask, against, col):
    """inner contour where a part painted over others meets them (no ink shows there)"""
    behind = set().union(*[sil(R, q) for q in against])
    p.fill({(x, y) for (x, y) in mask if any((x + dx, y + dy) not in mask and (x + dx, y + dy) in behind for dx, dy in N4)}, col)


def claws(p, xs, y, col, tip=None):
    for x in xs:
        p.px(x, y, col)
        if tip:
            p.px(x + 1, y, tip)


def bead(p, x, y, r=1.4, iris=None, glint=CREAM):
    """a felt button eye centred on (x, y): ink disc, optional iris ring, glint top-left"""
    p.add(p.m(ell(x, y, r + .5, r + .4)), (INK,) * 4, flat=True)
    if iris:
        p.add(p.m(ell(x, y, r - .1, r - .2)), (iris,) * 4, flat=True)
        p.add(p.m(ell(x + .4, y + .1, r * .5, r * .65)), (INK,) * 4, flat=True)
    p.px(x - 1, y - 1, glint)


def strand(p, mask, pts, col, w=1.2, hi=None, side=(0, -1)):
    """a stitched strand (vine, hair lock) drawn as a thin line clipped to mask; hi: a light thread one px to `side`"""
    s = p.m(capsule(pts, w)) & mask
    if hi:
        p.fill({(x + side[0], y + side[1]) for (x, y) in s if (x + side[0], y + side[1]) in mask} - s, hi)
    p.fill(s, col)
