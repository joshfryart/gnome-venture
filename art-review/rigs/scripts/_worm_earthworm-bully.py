"""helpers for the worm5 batch (earthworm-bully, bog-leech, dew-leech): a body spine through the segment pivots, one felt capsule per
segment (lit against the whole body so the joints read as sewn seams), ring stitches across the body, a seam at each joint.
Pure drawing helpers on rigkit Parts; no rig data of their own."""
import math
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from rigkit import capsule, union, inter, ell  # noqa: E402

SEGS = ['s5', 's4', 's3', 's2', 's1']


class Worm:
    """spine = tail tip, s5, s4, s3, s2, s1 pivots, then the neck point; W = full widths at each of those 7 points"""
    def __init__(self, R, tail, neck, W, lift=None):
        self.R = R
        lift = lift or [0] * 7
        pts = [tail] + [R.pv(s) for s in SEGS] + [neck]
        self.S = [(x, y + l) for (x, y), l in zip(pts, lift)]
        self.W = W

    def span(self, i):
        """the capsule of segment i (0 = s5 .. 4 = s1): from spine point i to i+1 (s1 also reaches the neck)"""
        S, W = self.S, self.W
        c = capsule([S[i], S[i + 1]], W[i], W[i + 1])
        if i == 4:
            c = union(c, capsule([S[5], S[6]], W[5], W[6]))
        return c

    def all(self):
        return union(*[self.span(i) for i in range(5)])

    def frame(self, i, t):
        """point at fraction t along the spine segment i -> i+1, its unit tangent and down-normal and half width"""
        (ax, ay), (bx, by) = self.S[i], self.S[i + 1]
        dx, dy = bx - ax, by - ay; L = math.hypot(dx, dy) or 1e-9
        ux, uy = dx / L, dy / L
        w = (self.W[i] + (self.W[i + 1] - self.W[i]) * t) / 2
        return (ax + dx * t, ay + dy * t), (ux, uy), (-uy, ux), w

    def ring(self, p, i, t, col, inset=1.2, bend=.6):
        """a stitched ring across the body at t along segment i, slightly bowed toward the tail (reads as round)"""
        (cx, cy), (ux, uy), (nx, ny), w = self.frame(i, t)
        pts = []
        for k in range(-4, 5):
            f = k / 4.0
            off = (w - inset) * f
            bow = -bend * (1 - f * f) * 2
            pts.append((cx + nx * off + ux * bow, cy + ny * off + uy * bow))
        p.line(pts, col)

    def side(self, i, off):
        """predicate: points below (off > 0) the spine line of segment i by more than off px"""
        (ax, ay), (bx, by) = self.S[i], self.S[i + 1]
        dx, dy = bx - ax, by - ay; L = math.hypot(dx, dy) or 1e-9
        nx, ny = -dy / L, dx / L
        return lambda x, y: (x - ax) * nx + (y - ay) * ny > off


def dashes(p, pts, col, on=2, off=1):
    k = 0
    for (ax, ay), (bx, by) in zip(pts, pts[1:]):
        n = int(max(abs(bx - ax), abs(by - ay), 1))
        for j in range(n):
            if k % (on + off) < on:
                p.px(math.floor(ax + (bx - ax) * j / n), math.floor(ay + (by - ay) * j / n), col)
            k += 1
