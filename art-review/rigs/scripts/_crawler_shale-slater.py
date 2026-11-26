"""_crawler_shale-slater.py: small helpers for the many-legged / crawler batch (shale-slater, page-silverfish, crystal-weaver,
cave-glowworm). Import with importlib (the file name has dashes)."""
import math
from rigkit import capsule, ell, inter, INK, CREAM  # noqa


def stitch_line(p, pts, col, gap=2):
    """a dashed running stitch along a polyline"""
    k = 0
    for (ax, ay), (bx, by) in zip(pts, pts[1:]):
        n = int(max(abs(bx - ax), abs(by - ay), 1))
        for i in range(n):
            if (k // gap) % 2 == 0:
                p.px(math.floor(ax + (bx - ax) * i / n), math.floor(ay + (by - ay) * i / n), col)
            k += 1


def button_eye(p, ex, ey, r=2.2, lid=None, look=1):
    """felt button eye: ink disc, cream disc, ink pupil looking forward, white glint; optional lid colour over the top"""
    p.add(p.m(ell(ex, ey, r + .9, r + .9)), (INK,) * 4, flat=True)
    p.add(p.m(ell(ex, ey, r, r)), (CREAM,) * 4, flat=True)
    p.add(p.m(ell(ex + look * .7, ey + .2, r * .62, r * .75)), (INK,) * 4, flat=True)
    p.px(ex - .6, ey - 1.2, '#ffffff')
    if lid:
        p.add(p.m(inter(ell(ex, ey, r + .9, r + .9), lambda x, y: y < ey - r * .35)), (lid,) * 4, flat=True)


def blob(p, mask, ramp):
    """a felt patch painted ON a layer as overrides (keeps that layer's stitch ring): base, light top-left rim, shaded bottom-right rim"""
    for (x, y) in mask:
        c = ramp[1]
        if (x - 1, y) not in mask or (x, y - 1) not in mask:
            c = ramp[0]
        if (x + 1, y) not in mask or (x, y + 1) not in mask:
            c = ramp[2]
        p.over[(x, y)] = c


def thin_leg(p, pts, ramp, w0=2.4, w1=1.4, local=True):
    """a jointed thin leg along a polyline, tapering, with a darker dot at each joint"""
    p.add(p.m(capsule(pts, w0, w1)), ramp, local=local, crescent=0)
    for q in pts[1:-1]:
        p.px(int(q[0]), int(q[1]), ramp[3])
