"""_crawler_giant-centipede.py: helpers for the many-legged/crawler batch (giant-centipede, gravel-centipede, claybound-millipede,
pill-bug-brute). Import with importlib (the file name has dashes). Own copy so other agents' helper edits cannot change these rigs."""
import math
from rigkit import capsule, ell, inter, INK, CREAM  # noqa


def seg_mask(R, a, b, back, front, h_top, h_bot, lift=0.0, n=3.0):
    """a soft felt pillow for one chained body segment: from `front` px ahead of the line a->b start to `back` px past its end.
    a, b: (x, y) centre line points; h_top / h_bot: half heights above / below that line (rounded ends)."""
    ax, ay = a; bx, by = b
    dx, dy = bx - ax, by - ay; L = math.hypot(dx, dy) or 1e-9; ux, uy = dx / L, dy / L
    x0, y0 = ax - ux * front, ay - uy * front
    x1, y1 = bx + ux * back, by + uy * back
    cx, cy = (x0 + x1) / 2, (y0 + y1) / 2 - lift
    rx = math.hypot(x1 - x0, y1 - y0) / 2
    ang = math.atan2(y1 - y0, x1 - x0)
    c, s = math.cos(ang), math.sin(ang)
    def f(x, y):
        u, v = (x - cx) * c + (y - cy) * s, -(x - cx) * s + (y - cy) * c
        ry = h_top if v < 0 else h_bot
        # a squarish ellipse (superellipse, n = 3): reads as a felt pillow, not a tube
        return abs(u / rx) ** n + abs(v / ry) ** n <= 1.0
    return f


def leg(p, pts, w, ramp, local=True, knee=True):
    """a felt leg stroke along pts with widths w per point; knee dots in ramp[3]"""
    for i, (a, b) in enumerate(zip(pts, pts[1:])):
        p.add(p.m(capsule([a, b], w[i], w[i + 1])), ramp, local=local, crescent=1)
    if knee:
        for q in pts[1:-1]:
            p.px(int(q[0]), int(q[1]), ramp[3])


def button_eye(p, ex, ey, r=2.0, lid=None, look=1, glint=True):
    """felt button eye: ink disc, cream ring, ink pupil looking forward, glint; optional lid colour over the top part"""
    p.add(p.m(ell(ex, ey, r + .9, r + .9)), (INK,) * 4, flat=True)
    p.add(p.m(ell(ex, ey, r, r)), (CREAM,) * 4, flat=True)
    p.add(p.m(ell(ex + look * .6, ey + .25, r * .6, r * .72)), (INK,) * 4, flat=True)
    if glint:
        p.px(ex - .5, ey - 1.1, '#ffffff')
    if lid:
        p.add(p.m(inter(ell(ex, ey, r + .9, r + .9), lambda x, y: y < ey - r * .3)), (lid,) * 4, flat=True)


def blob(p, mask, ramp):
    """a felt patch painted ON a layer as overrides (keeps that layer's stitch ring): base, light top-left rim, shaded bottom-right rim"""
    for (x, y) in mask:
        c = ramp[1]
        if (x - 1, y) not in mask or (x, y - 1) not in mask:
            c = ramp[0]
        if (x + 1, y) not in mask or (x, y + 1) not in mask:
            c = ramp[2]
        p.over[(x, y)] = c


def seam_over(p, mask, under, col):
    """the sewn seam of a chained segment: pixels of `mask` on its edge that lie over the `under` mask"""
    for (x, y) in mask:
        if (x, y) in under and any((x + dx, y + dy) not in mask for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))):
            p.px(x, y, col)


def stitch_line(p, pts, col, gap=2):
    """a dashed running stitch along a polyline"""
    k = 0
    for (ax, ay), (bx, by) in zip(pts, pts[1:]):
        n = int(max(abs(bx - ax), abs(by - ay), 1))
        for i in range(n):
            if (k // gap) % 2 == 0:
                p.px(math.floor(ax + (bx - ax) * i / n), math.floor(ay + (by - ay) * i / n), col)
            k += 1
