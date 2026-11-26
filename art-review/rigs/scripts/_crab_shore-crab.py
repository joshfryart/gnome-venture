"""helpers shared by the crab batch (shore-crab, tide-crab-knight, mangrove-crab-king, hermit-crab-hoarder): front-view crab rig parts.
Import with: from importlib import import_module; CK = import_module('_crab_shore-crab')  (scripts/ is on sys.path when a script runs)."""
import math
from rigkit import *  # noqa


def mirror(R):
    """x mirror about the rig's centre line (leg1 <-> leg4 pivots are symmetric)"""
    a, b = R.pv('leg1')[0], R.pv('leg4')[0]
    return lambda x: a + b - x


def leg(R, pid, knee, foot, ramp, w=(3.8, 3.2, 1.6), bands=None, tip=None):
    """a jointed walking leg: hip pivot -> knee (raised, outward) -> pointed foot on the sand.
    bands: a colour for felt stripes across the leg (hermit legs); tip: colour of the dark toe."""
    p = R.part(pid)
    a = R.pv(pid)
    thigh = capsule([a, knee], w[0], w[1])
    shin = capsule([knee, foot], w[1], w[2])
    p.add(p.m(thigh), ramp, crescent=1)
    p.add(p.m(shin), ramp, local=True, crescent=1)
    p.px(int(knee[0]), int(knee[1]) + 1, ramp[3])
    if bands:
        for t in (.35, .7):
            cx, cy = knee[0] + (foot[0] - knee[0]) * t, knee[1] + (foot[1] - knee[1]) * t
            dx, dy = foot[0] - knee[0], foot[1] - knee[1]
            L = math.hypot(dx, dy)
            band = inter(shin, lambda x, y, cx=cx, cy=cy: abs((x - cx) * dx / L + (y - cy) * dy / L) < .9)
            p.fill(p.m(band), bands)
    if tip:
        p.px(int(foot[0]), int(foot[1]), tip)
        p.px(int(foot[0]), int(foot[1]) - 1, tip)
    return p


def stalk_eye(R, pid, top, ramp, knob=3.6, stalk=2.6, look=0, brow=None, lean=0.0):
    """an eye on a felt stalk: from the pivot (on the body) up to a round knob carrying a button eye. top = knob centre y."""
    p = R.part(pid)
    x, y = R.pv(pid)
    kx = x + lean
    p.add(p.m(capsule([(x, y), (kx, top + knob * .6)], stalk + .6, stalk)), ramp, crescent=1)
    p.add(p.m(ell(kx, top, knob, knob * 1.02)), ramp, local=True, crescent=1)
    p.eye(kx - .5 + look * .5, top, size=2, look=look)
    if brow:
        p.line([(kx - knob + .5, top - knob + 1 + (brow if brow > 0 else 0)), (kx + knob - 1, top - knob + 1 + (-brow if brow < 0 else 0))], INK)
    return p


def blush(p, x, y):
    p.add(p.m(ell(x, y, 2.1, 1.1)), (BLUSH,) * 4, flat=True)
