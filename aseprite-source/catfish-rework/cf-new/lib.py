import numpy as np, math
from PIL import Image

INK = (0x2b, 0x1c, 0x26)
def hx(s): s = s.lstrip('#'); return tuple(int(s[i:i+2], 16) for i in (0, 2, 4))

class Cv:
    def __init__(s, w, h):
        s.w, s.h = w, h
        s.rgb = np.zeros((h, w, 3), np.uint8)
        s.a = np.zeros((h, w), bool)
        s.idx = np.full((h, w), -1, int)
        s.lock = np.zeros((h, w), bool)   # pixels protected from AO/outline recolour

    # ---- masks (bool arrays)
    def M(s): return np.zeros((s.h, s.w), bool)
    def ellipse(s, cx, cy, rx, ry):
        y, x = np.mgrid[0:s.h, 0:s.w]
        return ((x - cx) / rx) ** 2 + ((y - cy) / ry) ** 2 <= 1.0
    def poly(s, pts):
        im = Image.new('1', (s.w, s.h), 0)
        from PIL import ImageDraw
        ImageDraw.Draw(im).polygon([tuple(p) for p in pts], fill=1)
        return np.array(im, bool)
    def line(s, pts, w0, w1=None):
        """tapered thick polyline: union of discs along it"""
        w1 = w0 if w1 is None else w1
        m = s.M(); y, x = np.mgrid[0:s.h, 0:s.w]
        segs = []
        for i in range(len(pts) - 1):
            (x0, y0), (x1, y1) = pts[i], pts[i + 1]
            n = int(max(abs(x1 - x0), abs(y1 - y0)) * 2) + 1
            for k in range(n + 1): segs.append((x0 + (x1 - x0) * k / n, y0 + (y1 - y0) * k / n, (i + k / n) / (len(pts) - 1)))
        for px, py, t in segs:
            r = (w0 + (w1 - w0) * t) / 2.0
            m |= (x - px) ** 2 + (y - py) ** 2 <= r * r
        return m

    # ---- shading
    @staticmethod
    def depth(m):
        d = np.zeros(m.shape, int); cur = m.copy()
        while cur.any():
            d += cur
            e = cur.copy()
            e[1:] &= cur[:-1]; e[:-1] &= cur[1:]; e[:, 1:] &= cur[:, :-1]; e[:, :-1] &= cur[:, 1:]
            e[0] = False; e[-1] = False; e[:, 0] = False; e[:, -1] = False
            cur = e
        return d
    def normals(s, m, k=1.0):
        d = s.depth(m).astype(float)
        h = np.sqrt(d)
        p = np.pad(h, 1, mode='edge')
        hs = sum(p[1 + dy:1 + dy + s.h, 1 + dx:1 + dx + s.w] for dy in (-1, 0, 1) for dx in (-1, 0, 1)) / 9.0
        q = np.pad(hs, 1, mode='edge')
        gx = (q[1:-1, 2:] - q[1:-1, :-2]) / 2; gy = (q[2:, 1:-1] - q[:-2, 1:-1]) / 2
        n = np.stack([-gx * k * 2.2, -gy * k * 2.2, np.ones_like(gx)], -1)
        n /= np.linalg.norm(n, axis=-1, keepdims=True)
        return n, d
    def light(s, n, amb=0.0, bias=None):
        L = np.array([-0.5, -0.6, 0.62]); L /= np.linalg.norm(L)
        v = np.clip((n * L).sum(-1), 0, 1) + amb
        if bias is not None: v = v + bias
        return v
    def tone(s, m, ramp, cuts=(0.22, 0.38, 0.52, 0.76, 0.92), bias=None, amb=0.0, rim=True, k=0.7):
        """paint mask with ramp (list of hex, dark->light); returns nothing. rim: lower-right edge gets ramp[2] bounce"""
        n, d = s.normals(m, k)
        v = s.light(n, amb)
        ys, xs = np.nonzero(m)
        if bias is None:
            cy, cx = ys.mean(), xs.mean(); R = max(np.ptp(ys), np.ptp(xs), 1) / 2.0
            bias = -((np.arange(s.w)[None, :] - cx) + (np.arange(s.h)[:, None] - cy)) / (4.0 * R) * 0.35
        v = v + bias
        idx = np.zeros(m.shape, int)
        for c in cuts: idx += (v > c)
        if rim and len(ramp) >= 6:
            # reflected light on the lower-right rim
            lowr = ((np.arange(s.w)[None, :] - xs.mean()) + (np.arange(s.h)[:, None] - ys.mean())) > 0
            idx[(d == 1) & lowr & (idx <= 1)] = 2
        for y, x in zip(*np.nonzero(m)):
            s.rgb[y, x] = hx(ramp[idx[y, x]]); s.a[y, x] = True; s.idx[y, x] = idx[y, x]
        return idx
    def flat(s, m, col):
        s.rgb[m] = hx(col); s.a[m] = True
    def put(s, x, y, col, only=True, lock=False, idx=None):
        if 0 <= x < s.w and 0 <= y < s.h and (s.a[y, x] or not only):
            s.rgb[y, x] = hx(col); s.a[y, x] = True
            if lock: s.lock[y, x] = True
            if idx is not None: s.idx[y, x] = idx
    def ao(s, upper, lower_pix, ramp, steps=2):
        """ring around `upper` mask on pixels in lower_pix gets darker tone"""
        ring = s.grow(upper) & ~upper & lower_pix
        for y, x in zip(*np.nonzero(ring)):
            i = s.idx[y, x]
            if i >= 0 and not s.lock[y, x]:
                j = max(0, i - steps); s.rgb[y, x] = hx(ramp[j]); s.idx[y, x] = j
    @staticmethod
    def grow(m):
        e = m.copy(); e[1:] |= m[:-1]; e[:-1] |= m[1:]; e[:, 1:] |= m[:, :-1]; e[:, :-1] |= m[:, 1:]; return e
    def outline(s):
        ring = s.grow(s.a) & ~s.a
        s.rgb[ring] = INK; s.a[ring] = True
    def mirror_x(s, x, c=25): return 2 * c - x
    def save(s, path):
        im = np.zeros((s.h, s.w, 4), np.uint8); im[..., :3] = s.rgb; im[..., 3] = s.a * 255
        Image.fromarray(im, 'RGBA').save(path)
    def check(s):
        op = s.rgb[s.a]
        assert not (op == 0).all(-1).any(), 'pure black'
        assert not (op == 255).all(-1).any(), 'pure white'
        return len({tuple(c) for c in op})
