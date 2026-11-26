"""_snake_grass-snake.py: helpers for the snake batch (grass-snake, dust-sidewinder, sand-viper-matriarch, dune-wyrm). Private to that batch.
A snake on the snake rig: s1 = tail tip lying on the ground, s2..s6 = body chained pivot to pivot (s6 = neck), head (+ hood under it), eyes.
One felt body: every segment is lit against the whole snake (ref), the belly is a cream band under a dashed belly seam, and each
segment's front-of-parent end gets a sewn seam arc so the joints read as stitched felt panels, not sausages."""
import math
from rigkit import *  # noqa

CHAIN = ('s2', 's3', 's4', 's5', 's6', 'head')
ALL = lambda x, y: True


def unit(a, b):
    dx, dy = b[0] - a[0], b[1] - a[1]; L = math.hypot(dx, dy) or 1e-9
    return dx / L, dy / L, L


def along(a, b, t0, t1):
    """points whose projection on a->b lies between t0 and t1 px from a"""
    dx, dy, L = unit(a, b)
    return lambda x, y: t0 <= (x - a[0]) * dx + (y - a[1]) * dy <= t1


def snake(R, tip, W, side, back, belly, mid=None, pattern=None, back_band=.4, belly_band=.35, seam=None, belly_stitch=None, back_stitch=None, extra=None, flat_ground=True):
    """tip: tail tip (frame px); W: full widths at (tip, s2, s3, s4, s5, s6, head pivot); mid: optional bend points per segment {pid: (x, y)}.
    pattern(p, pid, shape, a, b, r) adds markings. extra: {pid: predicate} added to that segment (ridges, rattles)."""
    P = {k: R.pv(k) for k in R.ids}
    pts = [tip] + [P[k] for k in CHAIN]
    mid = mid or {}
    ids = ('s1',) + CHAIN[:-1]
    caps = []
    for i, pid in enumerate(ids):
        path = [pts[i]] + ([mid[pid]] if pid in mid else []) + [pts[i + 1]]
        caps.append(capsule(path, W[i], W[i + 1]))
    extra = extra or {}
    g = R.ground + 1.0
    allp = inter(union(*caps, *extra.values()), lambda x, y: y < g)
    REF = R.part('s1').m(allp)
    out = {}
    for i, pid in enumerate(ids):
        p = R.part(pid)
        a, b = pts[i], pts[i + 1]
        shape = union(caps[i], extra[pid]) if pid in extra else caps[i]
        shape = inter(shape, lambda x, y: y < g)
        r = (W[i] + W[i + 1]) / 4
        p.add(p.m(shape), side, ref=REF)
        bl = inter(shape, below(a, b, r * belly_band))
        p.add(p.m(bl), belly, ref=REF)
        bk = p.m(inter(shape, minus(ALL, below(a, b, -r * back_band))))
        p.add(bk, back, ref=REF)
        if back_stitch:
            sil = p.m(shape)
            e = {q for q in bk if (q[0], q[1] + 1) not in bk and (q[0], q[1] + 1) in sil and (q[0], q[1] - 1) in bk}
            p.fill({q for q in e if q[0] % 3 != 2}, back_stitch)
        if belly_stitch:
            bm = p.m(bl)
            edge = {q for q in bm if (q[0], q[1] - 1) not in bm and (q[0] - 1, q[1] - 1) not in bm or (q[0], q[1] - 1) not in bm}
            p.fill({q for q in edge if q[0] % 3 != 2}, belly_stitch)
        p.REF = REF
        if pattern:
            pattern(p, pid, shape, a, b, r)
        if seam and pid not in ('s1', 's2'):
            dx, dy, L = unit(a, b)
            s = p.m(inter(caps[i], lambda x, y, a=a, w=W[i]: w / 2 - 1.3 < math.hypot(x - a[0], y - a[1]) and (x - a[0]) * dx + (y - a[1]) * dy < 0))
            p.fill(s, seam)
        out[pid] = (p, shape, a, b, r)
    return P, REF, out


def diamond(cx, cy, ra, rb, deg=0):
    """a rhombus centred on (cx, cy): half-diagonals ra (along deg, clockwise on screen) and rb"""
    c, s = math.cos(math.radians(deg)), math.sin(math.radians(deg))
    return lambda x, y: abs(((x - cx) * c + (y - cy) * s) / ra) + abs((-(x - cx) * s + (y - cy) * c) / rb) <= 1.0


def eyeball(p, x, y, r, iris, lid=None, lidcut=None, pupil='slit', glint='#ffffff'):
    """a felt eye centred on (x, y): ink disc, iris, slit or round pupil, glint, optional heavy lid above lidcut"""
    p.add(p.m(ell(x, y, r + .9, r + .9)), (INK,) * 4, flat=True)
    p.add(p.m(ell(x, y, r, r)), (iris,) * 4, flat=True)
    if pupil == 'slit':
        p.add(p.m(rect(math.floor(x), y - r + .6, math.floor(x) + 1, y + r - .4)), (INK,) * 4, flat=True)
    else:
        p.add(p.m(ell(x + .5, y + .2, r * .6, r * .65)), (INK,) * 4, flat=True)
    p.px(x - r * .5, y - r * .5, glint)
    if lid:
        p.add(p.m(inter(ell(x, y, r + .9, r + .9), lambda X, Y: Y < lidcut)), (lid,) * 4, flat=True)


def tongue(p, root, length, col='#dd3a2a', up=0):
    """a forked felt tongue flicking forward from root"""
    x, y = int(root[0]), int(root[1])
    m = {(x + i, y + round(up * i / max(length, 1))) for i in range(length + 1)}
    ex, ey = x + length, y + up
    m |= {(ex + 1, ey - 1), (ex + 2, ey - 1), (ex + 1, ey + 1), (ex + 2, ey + 1)}
    p.add(m, (col,) * 4, flat=True)
