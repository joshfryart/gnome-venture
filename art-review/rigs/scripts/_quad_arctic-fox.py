"""_quad_arctic-fox.py: small shared helpers for the four-legged canid batch (arctic-fox, red-fox, bramble-wolf, outback-dingo).
Loaded by those scripts with importlib (hyphenated name). Builds on rigkit; writes nothing itself."""
import math
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from rigkit import *  # noqa


def fluff(pts, r, rr=None, gap=1.9):
    """a scalloped edge: circles of radius r (to rr) along a polyline, one every ~r px (felt tufts)"""
    rr = r if rr is None else rr
    cs = []
    segs = list(zip(pts, pts[1:]))
    tot = sum(math.hypot(b[0] - a[0], b[1] - a[1]) for a, b in segs) or 1
    s = 0.0
    for a, b in segs:
        L = math.hypot(b[0] - a[0], b[1] - a[1]); n = max(1, round(L / (r * gap)))
        for i in range(n + (1 if (a, b) == segs[-1] else 0)):
            t = i / n
            k = (s + t * L) / tot
            cs.append(ell(a[0] + (b[0] - a[0]) * t, a[1] + (b[1] - a[1]) * t, r + (rr - r) * k))
        s += L
    return union(*cs)


def leg(R, pid, foot_x, ramp, w0=7, w1=5.5, paw=None, sock=None, sock_y=None, toes=True, knee=None, top=3, seam=None, seamcol=None, against=()):
    """a leg hanging from its pivot to the ground row: tapered felt stroke + a round paw on the ground.
    knee: optional (dx, y) bend point (hind hock). sock: a ramp painted below sock_y (stockings / white feet).
    seam: y above which the leg's side edges get a deep seam (a near leg painted over the body has no ink there)."""
    p = R.part(pid)
    px_, py_ = R.pv(pid)
    g = R.ground
    path = [(px_, py_ - top)]
    if knee:
        path.append((px_ + knee[0], knee[1]))
    path.append((foot_x, g - 3))
    shape = capsule(path, w0, w1)
    pw = ell(foot_x + 1.4, g - 1.1, w1 / 2 + 1.6, 2.4)
    p.add(p.m(shape, pw), ramp)
    if sock is not None:
        p.add(p.m(inter(union(shape, pw), lambda x, y: y > sock_y)), sock)
    if paw is not None:
        p.add(p.m(pw), paw)
    if toes:
        tr = (sock or paw or ramp)[3]
        p.px(foot_x + 1, g, tr); p.px(foot_x + 3, g, tr)
    if against:   # seam where this (near) leg lies on a far leg or the body: those have no ink in front of it
        m = p.m(shape, pw)
        behind = set().union(*[sil(R, q) for q in against])
        p.fill({(x, y) for (x, y) in m if any((x + dx, y + dy) not in m and (x + dx, y + dy) in behind
                                               for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)))}, seamcol or ramp[3])
    if seam is not None:
        m = p.m(shape)
        p.fill({(x, y) for (x, y) in m if y < seam and y > py_ - top + 1 and ((x - 1, y) not in m or (x + 1, y) not in m)}, seamcol or ramp[3])
    return p


def sil(R, pid):
    """the current silhouette of a part (union of its layers so far)"""
    q = R.part(pid)
    return set().union(*[m for m, _, _ in q.layers]) - q.cut if q.layers else set()


def hind(R, pid, ramp, w0=8, w1=5, back=2.5, fwd=1.0, thigh=None, **kw):
    """a hind leg: a thigh round the hip, the shank angling back to the hock, then down and a touch forward to the paw"""
    px_, py_ = R.pv(pid)
    g = R.ground
    p = leg(R, pid, px_ + fwd - back * .2, ramp, w0, w1, knee=(-back, g - 9), **kw)
    if thigh:
        p.add(p.m(rell(px_ + .5, py_ + thigh[1] * .3, thigh[0], thigh[1], -15)), ramp)
    return p


def brush(p, path, w0, w1, ramp, tip=None, tip_from=0.7, fl=None):
    """a bushy tail along path; tip ramp on the last part; fl = radius of scalloped fur tufts along it"""
    shape = capsule(path, w0, w1)
    parts = [shape]
    if fl:
        parts.append(fluff(path[1:], fl * w0 / 2 / 2.2, fl * w1 / 2 / 2.2))
    m = p.m(*parts)
    p.add(m, ramp)
    if tip is not None:
        a = path[0]; b = path[-1]
        dx, dy = b[0] - a[0], b[1] - a[1]; L2 = dx * dx + dy * dy
        p.add({q for q in m if ((q[0] + .5 - a[0]) * dx + (q[1] + .5 - a[1]) * dy) / L2 > tip_from}, tip)
    return m


def nose(p, x, y, col=INK):
    p.px(x, y, col); p.px(x + 1, y, col); p.px(x, y + 1, col); p.px(x + 1, y + 1, col)
    p.px(x, y, '#6a5648')


def eye(p, x, y, iris=None):
    """a small felt button eye: 3x3 ink with a cream glint (iris: a coloured ring pixel set)"""
    p.add(p.m(ell(int(x) + 1, int(y) + .5, 1.6, 2.1)), (INK,) * 4, flat=True)
    if iris:
        p.px(x - 1, y, iris); p.px(x, y + 1, iris)
    p.px(x, y - 1, CREAM)
