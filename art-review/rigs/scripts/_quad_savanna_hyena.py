"""_quad_savanna_hyena.py: small helpers shared by the four-legged mammal batch (savanna-hyena, tufted-lynx, jade-jaguar, jungle-tiger).
Private to that batch; the shared kit stays rigkit.py."""
from rigkit import *  # noqa


def leg(R, pid, foot_x, ramp, w0, w1, knee=None, paw=(4.0, 2.6), toes=True, top=3.0):
    """a felt leg: a tapered stroke from just above its hip pivot (top px up) down through an optional knee/hock to a round paw
    whose bottom row is the ground row. Returns (part, leg mask) so callers can print spots / stripes inside it."""
    p = R.part(pid)
    px_, py_ = R.pv(pid)
    g = R.ground + 1.0                  # paint reaches the ground row
    pts = [(px_, py_ - top)] + ([knee] if knee else []) + [(foot_x, g - paw[1] - 1)]
    shape = capsule(pts, w0, w1)
    pw = ell(foot_x + paw[0] * .3, g - paw[1], paw[0], paw[1])
    m = p.m(inter(union(shape, pw), lambda x, y: y < g))
    p.add(m, ramp)
    if toes:
        fx = int(foot_x + paw[0] * .3)
        for dx in (-1, 1):
            p.line([(fx + dx * 1.5 + .5 * (dx > 0), g - 2), (fx + dx * 1.5 + .5 * (dx > 0), g - 1)], ramp[3])
    return p, m


def eye_round(p, x, y, iris, r=2.2, ry=None, slit=False, lid=None):
    """a felt cat/dog eye: ink disc, coloured iris, ink pupil (round or slit), cream glint"""
    ry = ry or r * .9
    p.add(p.m(ell(x, y, r, ry)), (INK,) * 4, flat=True)
    p.add(p.m(ell(x, y, r - .8, ry - .8)), (iris,) * 4, flat=True)
    if slit:
        p.line([(x + .2, y - ry + 1), (x + .2, y + ry - 1)], INK)
    else:
        p.add(p.m(ell(x + .5, y + .2, max(.9, r * .42), max(.9, ry * .5))), (INK,) * 4, flat=True)
    p.px(x - 1, y - 1, CREAM)
    if lid:
        p.add(p.m(inter(ell(x, y, r, ry), lambda X, Y: Y < y - ry * .35)), (lid,) * 4, flat=True)
