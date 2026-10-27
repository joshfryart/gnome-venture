"""Tiny hard-pixel scene kit for the shop interiors (PIL + numpy, no Aseprite here).

Draw on a 240 x 135 grid, export at 2x nearest-neighbour (480 x 270), like every other scene.
Rules it follows (claude/art-style-guide.md Part D + E):
- hard pixels only, no blends, no dither, no gradients; scenes are fully opaque, no black border;
- raised objects get the three-tone umber outline (light side #74462a, #4a2c1a, dark side #2a1a10),
  one crescent at the lower right with a bounce line, a 1 px rim on the upper left;
- light from the upper left everywhere.
"""
import numpy as np
from PIL import Image, ImageDraw

W, H = 240, 135
OL = ('#74462a', '#4a2c1a', '#2a1a10')


def hx(c):
    return tuple(int(c[i:i + 2], 16) for i in (1, 3, 5))


def blank():
    return np.zeros((H, W), bool)


def _pil(fn):
    im = Image.new('1', (W, H), 0)
    fn(ImageDraw.Draw(im))
    return np.array(im, bool)


def rect(x0, y0, x1, y1):
    """Inclusive box."""
    m = blank()
    m[max(0, y0):max(0, y1 + 1), max(0, x0):max(0, x1 + 1)] = True
    return m


def rrect(x0, y0, x1, y1, c=1):
    """Box with its corners cut by c pixels (stepped)."""
    m = rect(x0, y0, x1, y1)
    for i in range(c):
        k = c - i
        for (x, y, dx) in ((x0, y0 + i, 1), (x1, y0 + i, -1), (x0, y1 - i, 1), (x1, y1 - i, -1)):
            for j in range(k):
                xx = x + dx * j
                if 0 <= y < H and 0 <= xx < W:
                    m[y, xx] = False
    return m


def ell(x0, y0, x1, y1):
    return _pil(lambda d: d.ellipse([x0, y0, x1, y1], fill=1))


def poly(pts):
    return _pil(lambda d: d.polygon(pts, fill=1))


def line(pts, w=1):
    return _pil(lambda d: d.line(pts, fill=1, width=w))


def shift(m, dx, dy):
    """out[y, x] = m[y - dy, x - dx] (zero filled)."""
    o = blank()
    ys = slice(max(0, dy), H + min(0, dy))
    xs = slice(max(0, dx), W + min(0, dx))
    ys2 = slice(max(0, -dy), H + min(0, -dy))
    xs2 = slice(max(0, -dx), W + min(0, -dx))
    o[ys, xs] = m[ys2, xs2]
    return o


def dil4(m):
    return m | shift(m, 1, 0) | shift(m, -1, 0) | shift(m, 0, 1) | shift(m, 0, -1)


def ramp(b, s, r=None, bo=None, d=None, g=None):
    """base, shade, rim (lit edge), bounce, deep, gloss."""
    return {'b': b, 's': s, 'r': r, 'bo': bo, 'd': d, 'g': g}


class Canvas:
    def __init__(self, bg='#000000'):
        self.px = np.zeros((H, W, 3), np.uint8)
        self.px[:, :] = hx(bg)

    def fill(self, m, col):
        if col:
            self.px[m] = hx(col)

    def dots(self, pts, col):
        for x, y in pts:
            if 0 <= x < W and 0 <= y < H:
                self.px[y, x] = hx(col)

    def obj(self, outline=True, cx=None, cy=None):
        return Obj(self, outline, cx, cy)

    def remap(self, pairs):
        """Fold a few colours into others to stay under the scene colour cap."""
        for a, b in pairs.items():
            m = np.all(self.px == hx(a), axis=2)
            self.px[m] = hx(b)

    def colours(self):
        return len({tuple(p) for p in self.px.reshape(-1, 3)})

    def save(self, path, scale=2):
        im = Image.fromarray(self.px, 'RGB').convert('RGBA')
        im.resize((W * scale, H * scale), Image.NEAREST).save(path, optimize=True)


class Obj:
    """A raised object: parts painted back to front, one shared umber outline."""

    def __init__(self, cv, outline, cx, cy):
        self.cv, self.outline, self.cx, self.cy = cv, outline, cx, cy
        self.parts = []

    def part(self, m, rp, d=2, rim=True, contour=False, flat=False):
        self.parts.append((m, rp, d, rim, contour, flat))
        return self

    def union(self):
        u = blank()
        for p in self.parts:
            u |= p[0]
        return u

    def draw(self):
        cv = self.cv
        u = self.union()
        if not u.any():
            return u
        if self.outline:
            ring = dil4(u) & ~u
            ys, xs = np.nonzero(u)
            cx = self.cx if self.cx is not None else (xs.min() + xs.max()) / 2
            cy = self.cy if self.cy is not None else (ys.min() + ys.max()) / 2
            hw = max(4, (xs.max() - xs.min()) / 2)
            hh = max(4, (ys.max() - ys.min()) / 2)
            yy, xx = np.mgrid[0:H, 0:W]
            s = (xx - cx) / hw + (yy - cy) / hh
            cv.fill(ring & (s < -0.7), OL[0])
            cv.fill(ring & (s >= -0.7) & (s < 0.1), OL[1])
            cv.fill(ring & (s >= 0.1), OL[2])
        owner = np.full((H, W), -1, int)
        for i, (m, rp, d, rim, contour, flat) in enumerate(self.parts):
            cv.fill(m, rp['b'])
            owner[m] = i
            if flat:
                continue
            if d and rp.get('s'):
                cres = m & ~shift(m, -d, -d)
                cv.fill(cres, rp['s'])
                if d >= 3 and rp.get('bo'):
                    cv.fill(m & ~shift(m, -1, -1), rp['bo'])
            if rim and rp.get('r'):
                cv.fill(m & ~shift(m, 1, 1) & shift(m, -d, -d), rp['r'])
        for i, (m, rp, d, rim, contour, flat) in enumerate(self.parts):
            if not contour:
                continue
            mine = owner == i
            other = (owner >= 0) & (owner != i)
            edge = mine & (shift(other, 1, 0) | shift(other, -1, 0) | shift(other, 0, 1) | shift(other, 0, -1))
            cv.fill(edge, OL[2])
        return u
