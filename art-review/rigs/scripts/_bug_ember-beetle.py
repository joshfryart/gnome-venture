"""_bug_ember-beetle.py: small helpers shared by the ground-beetle rigs of the insects batch
(ember-beetle, grub-beetle, stag-beetle-patrol, root-weevil). Import with importlib (the file name has dashes)."""
import math
from rigkit import capsule, ell, rell, inter, minus, poly, INK, CREAM  # noqa


def leg(R, pid, knee, foot, ramp, w=(3.4, 2.8, 2.2), spur=True):
    """a stitched felt beetle leg: a thick femur from the hip pivot to the knee, a thinner tibia to the ground, a little hooked foot.
    knee / foot in frame px. The hip end starts a bit above the pivot so the joint stays covered when it swings."""
    p = R.part(pid)
    x, y = R.pv(pid)
    hip = (x, y - 1.2)
    femur = capsule([hip, knee], w[0], w[1])
    tibia = capsule([knee, foot], w[1], w[2])
    toe = 1 if foot[0] >= knee[0] else -1
    claw = capsule([foot, (foot[0] + toe * 2.2, foot[1] + .3)], 1.6, 1.2)
    p.add(p.m(femur), ramp, crescent=1)
    p.add(p.m(tibia, claw), ramp, local=True, crescent=1)
    if spur:   # a tiny spine on the tibia, felt-pointy
        mx, my = (knee[0] + foot[0]) / 2, (knee[1] + foot[1]) / 2
        p.px(mx - toe * 1.5, my, ramp[2])
    p.px(int(knee[0]), int(knee[1]), ramp[3])
    return p


def stitch_line(p, pts, col, gap=2):
    """a dashed running stitch along a polyline (every other pair of px)"""
    k = 0
    for (ax, ay), (bx, by) in zip(pts, pts[1:]):
        n = int(max(abs(bx - ax), abs(by - ay), 1))
        for i in range(n):
            if (k // gap) % 2 == 0:
                p.px(math.floor(ax + (bx - ax) * i / n), math.floor(ay + (by - ay) * i / n), col)
            k += 1


def button_eye(p, ex, ey, r=2.2, lid=None, look=1):
    """felt button eye: ink disc, cream ring, ink pupil looking forward, glint; optional lid colour over the top third"""
    p.add(p.m(ell(ex, ey, r + .9, r + .9)), (INK,) * 4, flat=True)
    p.add(p.m(ell(ex, ey, r, r)), (CREAM,) * 4, flat=True)
    p.add(p.m(ell(ex + look * .7, ey + .2, r * .62, r * .75)), (INK,) * 4, flat=True)
    p.px(ex - .6, ey - 1.2, '#ffffff')
    if lid:
        p.add(p.m(inter(ell(ex, ey, r + .9, r + .9), lambda x, y: y < ey - r * .35)), (lid,) * 4, flat=True)


def blob(p, mask, ramp):
    """paint a felt patch ON a stitched layer without making it its own layer (a layer would punch a hole in that layer's stitch
    ring): base fill, a light top-left rim and a shaded bottom-right rim, as p.fill overrides."""
    for (x, y) in mask:
        c = ramp[1]
        if (x - 1, y) not in mask or (x, y - 1) not in mask:
            c = ramp[0]
        if (x + 1, y) not in mask or (x, y + 1) not in mask:
            c = ramp[2]
        p.over[(x, y)] = c
