"""_quad_sea-otter-bandit.py: small helpers shared by the four-legged mammal batch (sea-otter-bandit, beaver-foreman, frost-hare,
grumpy-lemming). Private to that batch; the shared kit stays rigkit.py."""
from rigkit import *  # noqa


def tufts(pts, r=2.0, ry=None):
    """a row of small felt tufts (ellipses) along points: a fluffy edge"""
    ry = ry or r * .85
    return union(*[ell(x, y, r, ry) for x, y in pts])


def leg(R, pid, foot_x, ramp, w0, w1, paw=(3.5, 2.2), top=3.0, knee=None, haunch=None, pad=None, toes=None, hide=None):
    """a stubby felt leg: a tapered stroke from just above its hip pivot down (through an optional knee) to a paw whose bottom row is
    the ground row. haunch: (cx, cy, rx, ry) round pad sewn on top. pad: ramp of the paw. toes: colour of toe seams.
    hide: predicate removed from the shape (to keep a part off something). Returns (part, mask)."""
    p = R.part(pid)
    px_, py_ = R.pv(pid)
    g = R.ground + 1.0
    pts = [(px_, py_ - top)] + ([knee] if knee else []) + [(foot_x, g - paw[1] - 1.0)]
    shape = capsule(pts, w0, w1)
    if haunch:
        shape = union(shape, ell(*haunch))
    pw = ell(foot_x + paw[0] * .3, g - paw[1], paw[0], paw[1])
    m = p.m(inter(union(shape, pw), lambda x, y: y < g), minus=(hide,) if hide else ())
    p.add(m, ramp)
    if pad:
        pm = p.m(inter(pw, lambda x, y: y < g, lambda x, y: y > g - paw[1] - .2))
        p.add(pm & m, pad, local=True)
    if toes:
        tx = foot_x + paw[0] * 1.1
        for dx in (-1.5, .5):
            p.px(int(tx + dx), int(g - 1), toes)
    return p, m


def eye_dot(p, x, y, r=1.3, glint=CREAM):
    """a small felt button eye centred on (x, y): ink disc and a cream glint"""
    p.add(p.m(ell(x, y, r + .5, r + .4)), (INK,) * 4, flat=True)
    p.px(x - 1, y - 1, glint)


def solid(c):
    return (c, c, c, c)
