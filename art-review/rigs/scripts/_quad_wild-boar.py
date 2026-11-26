"""_quad_wild-boar.py: small helpers private to the four-legged mammal batch (wild-boar, thunder-yak, cliff-ram, raccoon).
The shared kit stays rigkit.py; this file only adds a hoof/paw leg, tuft rows and a button eye."""
from rigkit import *  # noqa


def tufts(pts, r=2.0, ry=None):
    """a row of small felt tufts (ellipses) along points: a shaggy or bristly edge"""
    ry = ry or r * .85
    return union(*[ell(x, y, r, ry) for x, y in pts])


def spikes(base, h, w=2.4, lean=0.0):
    """a row of soft bristle spikes: base points (x, y), each a little triangle h px high leaning lean px forward"""
    return union(*[poly([(x - w, y + 1), (x + lean, y - h), (x + w, y + 1)]) for x, y in base])


def leg(R, pid, foot_x, ramp, w0, w1, knee=None, top=3.5, thigh=None, foot=None, foot_w=4.5, foot_h=3.0, cloven=True, toes=None):
    """a felt leg from just above its hip pivot down (through an optional knee) to a hoof or paw whose bottom row is the ground row.
    thigh: (rx, ry) round haunch pad around the pivot. foot: ramp of the hoof/paw (None: same felt). cloven: a notch in the hoof front.
    toes: colour of little toe ticks on a paw. Returns (part, mask)."""
    p = R.part(pid)
    px_, py_ = R.pv(pid)
    g = R.ground + 1.0
    pts = [(px_, py_ - top)] + ([knee] if knee else []) + [(foot_x, g - foot_h - 1)]
    shape = capsule(pts, w0, w1)
    if thigh:
        shape = union(shape, ell(px_, py_ - top * .2, thigh[0], thigh[1]))
    hoof = union(rect(foot_x - foot_w / 2, g - foot_h, foot_x + foot_w / 2 + 1, g), ell(foot_x + .5, g - foot_h + .3, foot_w / 2 + .3, 1.3))
    m = p.m(inter(union(shape, hoof), lambda x, y: y < g))
    p.add(m, ramp)
    if foot:
        p.add(p.m(inter(hoof, lambda x, y: y < g, lambda x, y: y > g - foot_h - .2)), foot, local=True)
    if cloven:
        p.px(int(foot_x + foot_w / 2), int(g - 1), INK)
        p.px(int(foot_x + foot_w / 2), int(g - 2), INK)
    if toes:
        for dx in (-1, 1, 3):
            p.px(int(foot_x + dx), int(g - 1), toes)
    return p, m


def eye_dot(p, x, y, r=1.4, glint=CREAM, iris=None):
    p.add(p.m(ell(x, y, r + .5, r + .4)), (INK,) * 4, flat=True)
    if iris:
        p.add(p.m(ell(x, y, r - .1, r - .2)), (iris,) * 4, flat=True)
        p.add(p.m(ell(x + .3, y + .2, r * .55, r * .6)), (INK,) * 4, flat=True)
    p.px(x - 1, y - 1, glint)
