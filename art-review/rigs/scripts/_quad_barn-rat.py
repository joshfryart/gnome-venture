"""_quad_barn-rat.py: small helpers for the four-legged mammal batch (barn-rat, mischief-monkey, tunnel-mole, giant-anteater).
Private to that batch; the shared kit stays rigkit.py."""
from rigkit import *  # noqa


def tufts(pts, r=2.0, ry=None):
    """a row of small felt tufts (ellipses) along points: a shaggy edge"""
    ry = ry or r * .85
    return union(*[ell(x, y, r, ry) for x, y in pts])


def limb(R, pid, pts, w0, w1, ramp, foot=None, ref=None):
    """a felt leg: a tapered stroke from just above the hip pivot down through pts; foot = (cx, rx, ry) is a flat-bottomed paw
    whose bottom row is the ground row. Paint is clipped at the ground. Returns (part, mask)."""
    p = R.part(pid)
    g = R.ground + 1.0
    shape = capsule(pts, w0, w1)
    if foot:
        cx, rx, ry = foot
        shape = union(shape, ell(cx, g - ry, rx, ry))
    m = p.m(inter(shape, lambda x, y: y < g))
    p.add(m, ramp, ref=ref)
    return p, m


def toes(p, xs, y, col):
    """claw / toe ticks: one px per x on row y"""
    for x in xs:
        p.px(x, y, col)


def bead(p, x, y, r=1.4, glint=CREAM, iris=None):
    """a felt button eye centred on (x, y): ink disc, optional iris, cream glint top-left"""
    p.add(p.m(ell(x, y, r + .5, r + .4)), (INK,) * 4, flat=True)
    if iris:
        p.add(p.m(ell(x, y, r - .1, r - .2)), (iris,) * 4, flat=True)
        p.add(p.m(ell(x + .3, y + .2, r * .55, r * .6)), (INK,) * 4, flat=True)
    p.px(x - 1, y - 1, glint)
