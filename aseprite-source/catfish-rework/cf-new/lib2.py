import sys, os, numpy as np, math
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lib import *

class Cv2(Cv):
    def __init__(s, w, h, ramp, cuts, rimcol=None):
        super().__init__(w, h)
        s.R = ramp; s.cuts = cuts; s.rimcol = rimcol
        s.own = np.full((h, w), '', dtype='<U8')
        s.v = np.zeros((h, w))
    def ix(s, col):
        return s.R.index(col) if col in s.R else -1
    def tone2(s, m, label, bias=None, k=0.7, amb=0.0):
        prev = s.a.copy()
        n, d = s.normals(m, k)
        v = s.light(n, amb)
        ys, xs = np.nonzero(m)
        cy, cx = ys.mean(), xs.mean(); R = max(np.ptp(ys), np.ptp(xs), 1) / 2.0
        if bias is None:
            bias = -((np.arange(s.w)[None, :] - cx) + (np.arange(s.h)[:, None] - cy)) / (4.0 * R) * 0.35
        v = v + bias
        idx = np.zeros(m.shape, int)
        for c in s.cuts: idx += (v > c)
        lowr = ((np.arange(s.w)[None, :] - cx) + (np.arange(s.h)[:, None] - cy)) > 0
        rimm = (d == 1) & lowr & (idx <= 2)
        for y, x in zip(*np.nonzero(m)):
            i = idx[y, x]
            s.rgb[y, x] = hx(s.R[i]); s.a[y, x] = True; s.idx[y, x] = i; s.v[y, x] = v[y, x]; s.own[y, x] = label
            s.lock[y, x] = False
        for y, x in zip(*np.nonzero(rimm)):
            if s.rimcol: s.rgb[y, x] = hx(s.rimcol)
            else: s.rgb[y, x] = hx(s.R[2]); s.idx[y, x] = 2
            if s.rimcol: s.idx[y, x] = 1
        return prev
    def pt(s, m, label, ao=1, **kw):
        prev = s.tone2(m, label, **kw)
        if ao:
            ring = s.grow(m) & ~m & prev
            for y, x in zip(*np.nonzero(ring)):
                i = s.idx[y, x]
                if i >= 0 and not s.lock[y, x]:
                    j = max(0, i - ao); s.rgb[y, x] = hx(s.R[j]); s.idx[y, x] = j
    def set(s, x, y, name_or_col, lock=True, only=True):
        col = name_or_col
        if 0 <= x < s.w and 0 <= y < s.h and (s.a[y, x] or not only):
            s.rgb[y, x] = hx(col); s.a[y, x] = True; s.lock[y, x] = lock
            if col in s.R: s.idx[y, x] = s.R.index(col)
    def outline2(s):
        ring = s.grow(s.a) & ~s.a
        s.rgb[ring] = INK; s.a[ring] = True; s.own[ring] = 'ink'
