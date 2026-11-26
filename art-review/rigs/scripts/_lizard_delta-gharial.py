"""_lizard_delta-gharial.py: helpers for the reptile batch on the snake rig (delta-gharial, desert-gila-dragon, sun-lizard, spice-monitor).
Private to that batch; the shared kit stays rigkit.py.
A lizard on the snake rig: s1 = tail tip lying on the ground, s2..s6 = tail root, hips, belly, shoulders, neck (chained pivot to pivot),
hind legs painted on s3, fore legs on s4/s5, head + eyes. Segments are lit against the whole animal (ref) so the joints read as seams."""
import math
from rigkit import *  # noqa

CHAIN = ('s2', 's3', 's4', 's5', 's6', 'head')


def unit(a, b):
    dx, dy = b[0] - a[0], b[1] - a[1]; L = math.hypot(dx, dy) or 1e-9
    return dx / L, dy / L, L


def lizard(R, tip, W, side, back, belly, legs=(), pattern=None, legramp=None, back_band=.45, belly_band=.35, extra=None, seam=True):
    """tip: tail tip (frame px); W: widths at (tip, s2, s3, s4, s5, s6, head pivot). legs: (pid, hip, knee, foot_x, w, near) ;
    near legs are painted over the body (with a seam), far ones under it (one ramp step darker).
    pattern(p, pid, cap, a, b, r) adds markings. extra: {pid: predicate} added to that segment's silhouette (ridges, frills)."""
    P = {k: R.pv(k) for k in R.ids}
    pts = [tip] + [P[k] for k in CHAIN]
    caps = [capsule([pts[i], pts[i + 1]], W[i], W[i + 1]) for i in range(6)]
    extra = extra or {}
    allp = union(*caps, *extra.values())
    REF = R.part('s1').m(allp)
    g = R.ground + 1.0
    out = {}
    for i, pid in enumerate(('s1',) + CHAIN[:-1]):
        p = R.part(pid)
        a, b = pts[i], pts[i + 1]
        cap = caps[i]
        shape = union(cap, extra[pid]) if pid in extra else cap
        shape = inter(shape, lambda x, y: y < g)
        r = (W[i] + W[i + 1]) / 4
        mine = [l for l in legs if l[0] == pid]
        legm = {}
        w = 9
        for (_, hip, knee, fx, w, near) in mine:
            fy = g - w * .45
            leg = union(capsule([hip, knee, (fx, fy)], w * 1.25, w), ell(fx + w * .6, fy + w * .05, w * 1.15, w * .45))
            legm[near] = p.m(inter(leg, lambda x, y: y < g))
        if False in legm:
            p.add(legm[False], darker(side), local=True)
        body = p.add(p.m(shape), side, ref=REF)
        p.add(p.m(inter(shape, below(a, b, r * belly_band))), belly, ref=REF)
        p.add(p.m(inter(shape, minus(lambda x, y: True, below(a, b, -r * back_band)))), back, ref=REF)
        p.REF = REF
        if pattern:
            pattern(p, pid, shape, a, b, r)
        if True in legm:
            lm = legm[True]
            p.add(lm, legramp or side, local=True, crescent=0 if w < 3 else None)
            for (x, y) in lm:
                if any((x + dx, y + dy) in body and (x + dx, y + dy) not in lm for dx, dy in ((1, 0), (-1, 0), (0, -1), (0, 1))):
                    p.px(x, y, side[3] if w >= 3 else side[2])
        for near, lm in legm.items():   # cream claws on the toe tips
            row = max(y for x, y in lm)
            xs = sorted(x for x, y in lm if y == row)
            for x in xs[-3::2] if len(xs) > 3 else xs[-1:]:
                if (x + 1, row) in lm:
                    p.px(x + 1, row, CREAM)
        if seam and pid not in ('s1', 's2'):
            dx, dy, L = unit(a, b)
            s = p.m(inter(cap, lambda x, y, a=a, w=W[i]: math.hypot(x - a[0], y - a[1]) > w / 2 - 1.2 and (x - a[0]) * dx + (y - a[1]) * dy < 0))
            s -= set().union(*legm.values()) if legm else set()
            p.fill({q for q in s if (q[0] + q[1]) % 2 == 0 or not below(a, b, -r * back_band)(q[0] + .5, q[1] + .5)}, seam if isinstance(seam, str) else side[2])
        out[pid] = (p, shape)
    return P, REF, out


def eyeball(p, x, y, r, iris, lid=None, lidcut=None, pupil='slit'):
    """a felt reptile eye centred on (x, y): ink disc, coloured iris, slit or round pupil, cream glint, optional heavy lid above lidcut"""
    p.add(p.m(ell(x, y, r + .9, r + .9)), (INK,) * 4, flat=True)
    p.add(p.m(ell(x, y, r, r)), (iris,) * 4, flat=True)
    if pupil == 'slit':
        p.add(p.m(rect(math.floor(x), y - r + .6, math.floor(x) + 1, y + r - .4)), (INK,) * 4, flat=True)
    else:
        p.add(p.m(ell(x + .4, y + .2, r * .55, r * .6)), (INK,) * 4, flat=True)
    p.px(x - r * .5, y - r * .5, '#ffffff')
    if lid:
        p.add(p.m(inter(ell(x, y, r + .9, r + .9), lambda X, Y: Y < lidcut)), (lid,) * 4, flat=True)
