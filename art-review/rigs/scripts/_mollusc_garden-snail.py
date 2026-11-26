"""helpers for the mollusc batch (garden-snail, quartz-snail, rot-snail, leopard-slug): felt button eyes, eye stalks, shell spirals,
running stitches and felt patches. Pure drawing helpers on rigkit Parts; no rig data of their own."""
import math
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from rigkit import INK, CREAM, ell, inter, capsule  # noqa: E402


def stitch_line(p, pts, col, gap=2):
    """a dashed running stitch along a polyline"""
    k = 0
    for (ax, ay), (bx, by) in zip(pts, pts[1:]):
        n = int(max(abs(bx - ax), abs(by - ay), 1))
        for i in range(n):
            if (k // gap) % 2 == 0:
                p.px(math.floor(ax + (bx - ax) * i / n), math.floor(ay + (by - ay) * i / n), col)
            k += 1


def button_eye(p, ex, ey, r=1.8, lid=None, look=1, lidcut=.2):
    """felt button eye: ink disc, cream disc, ink pupil looking forward, white glint; optional heavy lid colour over the top"""
    p.add(p.m(ell(ex, ey, r + .9, r + .9)), (INK,) * 4, flat=True)
    p.add(p.m(ell(ex, ey, r, r)), (CREAM,) * 4, flat=True)
    p.add(p.m(ell(ex + look * .6, ey + .3, r * .6, r * .75)), (INK,) * 4, flat=True)
    p.px(ex - .6, ey - .9, '#ffffff')
    if lid:
        p.add(p.m(inter(ell(ex, ey, r + .9, r + .9), lambda x, y: y < ey - r * lidcut)), (lid,) * 4, flat=True)


def blob(p, mask, ramp):
    """a felt patch painted ON a layer as overrides: base, light top-left rim, shaded bottom-right rim"""
    for (x, y) in mask:
        c = ramp[1]
        if (x - 1, y) not in mask or (x, y - 1) not in mask:
            c = ramp[0]
        if (x + 1, y) not in mask or (x, y + 1) not in mask:
            c = ramp[2]
        p.over[(x, y)] = c


def spiral(cx, cy, r0, r1, turns, start=0.0, n=90, sq=1.0):
    """points of an archimedean spiral from radius r0 (inner) to r1 (outer), clockwise on screen; sq squashes it vertically"""
    pts = []
    for i in range(n + 1):
        t = i / n
        a = start + t * turns * 2 * math.pi
        r = r0 + (r1 - r0) * t
        pts.append((cx + math.cos(a) * r, cy + math.sin(a) * r * sq))
    return pts


def stalk(p, base, tip, ramp, w0=2.6, w1=2.0, knob=2.1, knob_ramp=None, mid=None):
    """an eye stalk: a soft tapered felt tube from the pivot to a round knob"""
    pts = [base, mid, tip] if mid else [base, tip]
    p.add(p.m(capsule(pts, w0, w1)), ramp, local=True, crescent=1)
    p.add(p.m(ell(tip[0], tip[1], knob, knob)), knob_ramp or ramp, local=True, crescent=1)
