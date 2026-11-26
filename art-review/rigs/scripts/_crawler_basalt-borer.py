"""_crawler_basalt-borer.py: small helpers for the many-legged-and-crawlers batch (basalt-borer, clay-crawler, blight-mother).
Import with importlib (the file name has dashes). Own copy so other agents' helper edits cannot change these rigs."""
import math
from rigkit import capsule, ell, inter, INK, CREAM  # noqa

N4 = ((1, 0), (-1, 0), (0, 1), (0, -1))


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
        if (x, y) in under and any((x + dx, y + dy) not in mask for dx, dy in N4):
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


def button_eye(p, ex, ey, r=2.0, iris=CREAM, lid=None, look=1, brow=None):
    """felt button eye: ink disc, iris ring, ink pupil looking forward, glint; optional lid colour over the top; optional brow line pts"""
    p.add(p.m(ell(ex, ey, r + .9, r + .9)), (INK,) * 4, flat=True)
    p.add(p.m(ell(ex, ey, r, r)), (iris,) * 4, flat=True)
    p.add(p.m(ell(ex + look * .7, ey + .2, r * .6, r * .72)), (INK,) * 4, flat=True)
    p.px(ex - .6, ey - 1.2, '#ffffff')
    if lid:
        p.add(p.m(inter(ell(ex, ey, r + .9, r + .9), lambda x, y: y < ey - r * .3 + (x - ex) * .35)), (lid,) * 4, flat=True)
    if brow:
        p.line(brow, INK)
