"""_insect_tallow-grub.py: small helpers for the insects-and-spiders batch (tallow-grub, earwig, drumming-cricket, mole-cricket).
Import with importlib (the file name has dashes). Own copy so other agents' helper edits cannot change these rigs."""
import math
from rigkit import capsule, ell, inter, INK, CREAM  # noqa


def leg(R, pid, pts, ramp, w, foot=1, hip_up=1.2, spur=()):
    """a stitched felt insect leg along pts (frame px, first = near the hip pivot): widths w per segment end (len(pts) values),
    a small hooked foot pointing `foot` (+1 forward / -1 back). The hip starts hip_up px above the pivot so the joint stays covered."""
    p = R.part(pid)
    x, y = R.pv(pid)
    pts = [(x, y - hip_up)] + list(pts)
    for i, (a, b) in enumerate(zip(pts, pts[1:])):
        p.add(p.m(capsule([a, b], w[i], w[i + 1])), ramp, local=(i > 0), crescent=1)
    fx, fy = pts[-1]
    p.add(p.m(capsule([(fx, fy), (fx + foot * 2.2, fy + .3)], 1.6, 1.2)), ramp, local=True, crescent=1)
    for i in range(1, len(pts) - 1):
        p.px(int(pts[i][0]), int(pts[i][1]), ramp[3])
    for (sx, sy) in spur:
        p.px(sx, sy, ramp[3])
    return p


def stitch_line(p, pts, col, gap=2):
    """a dashed running stitch along a polyline"""
    k = 0
    for (ax, ay), (bx, by) in zip(pts, pts[1:]):
        n = int(max(abs(bx - ax), abs(by - ay), 1))
        for i in range(n):
            if (k // gap) % 2 == 0:
                p.px(math.floor(ax + (bx - ax) * i / n), math.floor(ay + (by - ay) * i / n), col)
            k += 1


def button_eye(p, ex, ey, r=2.0, lid=None, look=1):
    """felt button eye: ink disc, cream ring, ink pupil looking forward, glint; optional lid colour over the top third"""
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


def seam_over(p, mask, under, col):
    """the sewn seam of a chained segment: pixels of `mask` on its edge that lie over the `under` mask (where it covers the next part)"""
    for (x, y) in mask:
        if (x, y) in under and any((x + dx, y + dy) not in mask for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))):
            p.px(x, y, col)
