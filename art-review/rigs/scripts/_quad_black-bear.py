"""_quad_black-bear.py: small helpers shared by the quad.bear mustelid/bear batch (black-bear, wolverine, honey-badger-brute, badger).
Private to that batch; the shared kit stays rigkit.py."""
from rigkit import *  # noqa


def fur(cx_pts, r=2.0, ry=None):
    """a row of small felt tufts (ellipses) along points: a shaggy top edge"""
    ry = ry or r * .85
    return union(*[ell(x, y, r, ry) for x, y in cx_pts])


def leg(R, pid, foot_x, ramp, w0, w1, knee=None, paw=(4.6, 2.6), top=3.5, thigh=None, claws=None, pad=None):
    """a thick felt leg: a tapered stroke from just above its hip pivot down (through an optional knee) to a broad paw whose
    bottom row is the ground row. thigh: (rx, ry) of a round haunch/shoulder pad around the pivot. claws: colour of 3 claw ticks
    at the toe front. pad: colour of the paw (a darker or lighter boot). Returns (part, mask)."""
    p = R.part(pid)
    px_, py_ = R.pv(pid)
    g = R.ground + 1.0
    pts = [(px_, py_ - top)] + ([knee] if knee else []) + [(foot_x, g - paw[1] - 1.5)]
    shape = capsule(pts, w0, w1)
    if thigh:
        shape = union(shape, ell(px_, py_ - top * .3, thigh[0], thigh[1]))
    pw = ell(foot_x + paw[0] * .25, g - paw[1], paw[0], paw[1])
    m = p.m(inter(union(shape, pw), lambda x, y: y < g))
    p.add(m, ramp)
    if pad:
        pm = p.m(inter(pw, lambda x, y: y < g, lambda x, y: y > g - paw[1] - .4))
        p.add(pm, pad, local=True)
    if claws:
        tx = foot_x + paw[0] * 1.25
        for i, dx in enumerate((-2.2, -.6, 1.0)):
            x = int(tx + dx - 1)
            p.px(x, int(g - 1), claws)
    return p, m


def eye_dot(p, x, y, glint=CREAM, r=1.4, iris=None):
    """a small felt button eye centred on (x, y): ink disc, optional iris ring, cream glint"""
    p.add(p.m(ell(x, y, r + .5, r + .4)), (INK,) * 4, flat=True)
    if iris:
        p.add(p.m(ell(x, y, r - .1, r - .2)), (iris,) * 4, flat=True)
        p.add(p.m(ell(x + .3, y + .2, r * .55, r * .6)), (INK,) * 4, flat=True)
    p.px(x - 1, y - 1, glint)
