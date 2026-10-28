"""palib: shared kit for the Puzzle Pals stickers (64 x 64 hard-pixel PNG, transparent, Stitched Toy / Hearthlight, claude/art-style-guide.md Part D).

A pal is a living jigsaw piece (claude/plan-puzzle-pals.md section 6): its silhouette is its shape (4 sides: T tab, B blank, F flat, + a knob style),
its body is FILLED with the pixels of its own cell of its picture's 12 x 8 Advanced grid (snapped to the picture's own house palette), and it gets
the house finish: one crescent lower right + bounce, 1 px rim upper left, dashed gold edge stitch, locked eyes, 2 px three-tone umber outline
(light from the upper left) and last a 1 px #000000 border, 4-adjacent. Rarity: common = plain, uncommon = + accent colour, rare = glow ring + sparkles.

Usage from a picture script (aseprite-source/pals/pals_<slug>.py):
    from palib import *
    pic = Pic('maplewold')
    st = Sticker(); body = piece((x0, y0, x1, y1), n=('T', 'round'), e=('B', 'peg'), s='F', w='F')
    st.part(body, tex=pic.fill(col, row, body, x0, y0, size)); st.eye(...); st.mouth(...); st.stitch(body)
    st.save(path, glow=False)       # outline, glow, border, checks
Everything is deterministic (no random), so a re-run gives the same bytes.
"""
import colorsys
import os
import re

import numpy as np
from PIL import Image, ImageDraw

N = 64
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, '..', '..'))
OUT = os.path.join(ROOT, 'game', 'assets', 'img', 'puzzles', 'pals')
OL = ('#74462a', '#4a2c1a', '#2a1a10')          # umber outline: light side, middle, dark side
CREAM, UMBER, UMBER2 = '#f2e4c0', '#2a1a10', '#4a2c1a'
GOLD, GOLD_D, GOLD_L = '#f5cf6a', '#c98a14', '#fff3c8'
MOUTH_RED = '#a8241f'
SHOE = ('#5c3420', '#3a2216', '#7a4a1f')         # base, shade, rim (felt boots)
YY, XX = np.mgrid[0:N, 0:N]
CX, CY = XX + 0.5, YY + 0.5                       # pixel centres


# ---------------------------------------------------------------- colour
def hx(c):
    return np.array([int(c[i:i + 2], 16) for i in (1, 3, 5)], np.uint8)


def hexs(rgb):
    return '#%02x%02x%02x' % tuple(int(v) for v in rgb)


def _toward(h, target, amt):
    d = (target - h + 0.5) % 1.0 - 0.5
    return (h + max(-amt, min(amt, d))) % 1.0


def tone(c, kind):
    """Part D ramp recipe from a base colour: shade (toward red-violet, ~22% darker), deep, bounce, rim (lit edge), gloss."""
    r, g, b = [v / 255.0 for v in (c if not isinstance(c, str) else hx(c))]
    h, s, v = colorsys.rgb_to_hsv(r, g, b)
    pale = v > 0.82 and s < 0.25
    if kind == 'shade':
        h, s, v = _toward(h, 0.93, 0.035), min(1, s * 1.1 + 0.06), v * 0.76
    elif kind == 'deep':
        h, s, v = _toward(h, 0.85, 0.06), min(1, s * 1.15 + 0.08), v * 0.55
    elif kind == 'bounce':
        h, s, v = _toward(h, 0.06, 0.03), min(1, s * 1.05 + 0.04), v * 0.86
    elif kind in ('rim', 'gloss'):
        if pale:
            return hx('#fff3c8')
        h, s, v = _toward(h, 0.11, 0.035), s * 0.82, min(1.0, v * 1.22 + 0.04)
        if kind == 'rim':
            v *= 0.97
    r, g, b = colorsys.hsv_to_rgb(h, s, v)
    return np.array([round(r * 255), round(g * 255), round(b * 255)], np.uint8)


# ---------------------------------------------------------------- masks
def blank():
    return np.zeros((N, N), bool)


def rect(x0, y0, x1, y1):
    m = blank()
    m[max(0, y0):max(0, y1 + 1), max(0, x0):max(0, x1 + 1)] = True
    return m


def disc(cx, cy, r):
    return (CX - cx) ** 2 + (CY - cy) ** 2 <= r * r


def ellipse(cx, cy, rx, ry):
    return ((CX - cx) / rx) ** 2 + ((CY - cy) / ry) ** 2 <= 1.0


def poly(pts):
    im = Image.new('1', (N, N), 0)
    ImageDraw.Draw(im).polygon(pts, fill=1)
    return np.array(im, bool)


def line(pts, w=1):
    im = Image.new('1', (N, N), 0)
    ImageDraw.Draw(im).line(pts, fill=1, width=w)
    return np.array(im, bool)


def shift(m, dx, dy):
    """out[y, x] = m[y - dy, x - dx] (zero filled)."""
    o = np.zeros_like(m)
    H, W = m.shape[:2]
    o[max(0, dy):H + min(0, dy), max(0, dx):W + min(0, dx)] = m[max(0, -dy):H + min(0, -dy), max(0, -dx):W + min(0, -dx)]
    return o


def dil4(m):
    return m | shift(m, 1, 0) | shift(m, -1, 0) | shift(m, 0, 1) | shift(m, 0, -1)


def ero4(m):
    return m & shift(m, 1, 0) & shift(m, -1, 0) & shift(m, 0, 1) & shift(m, 0, -1)


def grow(m, n):
    for _ in range(n):
        m = dil4(m)
    return m


def shrink(m, n):
    for _ in range(n):
        m = ero4(m)
    return m


# ---------------------------------------------------------------- jigsaw knobs (tabs and blanks)
def _local(side, at, edge):
    """(u, v) per pixel: u along the side from `at`, v > 0 outward from the core edge line."""
    if side == 'n':
        return CX - at, edge - CY
    if side == 's':
        return CX - at, CY - edge
    if side == 'e':
        return CY - at, CX - edge
    return CY - at, edge - CX


def knob_shape(style, u, v, r=4.0, nw=2.6, flip=False):
    """Knob predicate in local coords. Styles: round keyhole peg tri double hook. Extent outward is about 2r + 2."""
    if flip:
        u = -u
    neck = (np.abs(u) < nw) & (v > -2.5) & (v < r * 0.6 + 1)
    c = r + 1.6
    if style == 'round':
        return neck | ((u ** 2 + (v - c) ** 2) < r * r)
    if style == 'keyhole':
        flare = (v > -2.5) & (v < c) & (np.abs(u) < nw + 2.2 * np.clip(1 - v / c, 0, 1))
        return flare | ((u ** 2 + (v - c - 0.5) ** 2) < (r * 0.8) ** 2)
    if style == 'peg':
        top = 1.5 + 1.75 * r
        head = (np.abs(u) < r) & (v > 1.2) & (v < top)
        cut = (np.abs(u) > r - 1.1) & ((v > top - 1.1) | (v < 2.2))
        return (np.abs(u) < nw) & (v > -2.5) & (v < 2) | (head & ~cut)
    if style == 'tri':
        h = 2.1 * r
        arrow = (v >= 1.2) & (v < 1.2 + h) & (np.abs(u) < (r + 1.4) * (1 - (v - 1.2) / h))
        return (np.abs(u) < nw) & (v > -2.5) & (v < 2) | arrow
    if style == 'double':
        k = r * 0.62
        return ((np.abs(u) < nw + 1.4) & (v > -2.5) & (v < c - 1)) | (((u - k) ** 2 + (v - c + 0.4) ** 2) < k * k) | \
               (((u + k) ** 2 + (v - c + 0.4) ** 2) < k * k)
    if style == 'hook':
        d2 = u ** 2 + (v - c) ** 2
        ring = (d2 < r * r) & (d2 > (r - 2.6) ** 2) & ~((u > 0.2) & (v < c + 0.5))
        tip = ((u - (r - 1.3)) ** 2 + (v - c - 0.3) ** 2) < 2.0
        return neck & (u < nw) | ring | tip
    raise ValueError(style)


def knob(side, style, at, edge, r=4.0, nw=2.6, flip=False, blank_=False):
    u, v = _local(side, at, edge)
    if blank_:
        return knob_shape(style, u, -v, r + 0.6, nw + 0.6, flip)
    return knob_shape(style, u, v, r, nw, flip)


def piece(core, r=4.0, nw=2.6, **sides):
    return piece_blanks(core, r, nw, **sides)[0]


def piece_blanks(core, r=4.0, nw=2.6, **sides):
    """Like piece() but returns (mask, blanks): blanks = the cut-away knob holes, for Sticker.blank_shade()."""
    """A jigsaw piece mask. core = (x0, y0, x1, y1) inclusive. sides n/e/s/w = 'F' or (kind, style[, offset[, r[, flip]]]) with kind T or B.
    offset moves the knob along the side (pixels, from the side's centre)."""
    x0, y0, x1, y1 = core
    m = rect(x0, y0, x1, y1)
    edges = {'n': y0, 's': y1 + 1, 'w': x0, 'e': x1 + 1}
    mids = {'n': (x0 + x1 + 1) / 2, 's': (x0 + x1 + 1) / 2, 'w': (y0 + y1 + 1) / 2, 'e': (y0 + y1 + 1) / 2}
    tabs, blanks = blank(), blank()
    for sd in 'nesw':
        spec = sides.get(sd, 'F')
        if spec == 'F':
            continue
        kind, style = spec[0], spec[1]
        off = spec[2] if len(spec) > 2 else 0
        rr = spec[3] if len(spec) > 3 else r
        flip = spec[4] if len(spec) > 4 else False
        k = knob(sd, style, mids[sd] + off, edges[sd], rr, nw, flip, blank_=(kind == 'B'))
        if kind == 'T':
            tabs |= k
        else:
            blanks |= k
    return (m & ~blanks) | tabs, blanks & ~tabs


# ---------------------------------------------------------------- the picture (fill source)
class Pic:
    """A finished jigsaw picture: game/assets/img/jigsaw/<slug>.jpg, cut 12 x 8. Palette = the hex colours of its own script (the house ramps
    it was drawn with) when aseprite-source/scenes-pil/jigsaw_<slug>.py exists, else a 40-colour median cut of the image."""

    def __init__(self, slug, cols=12, rows=8):
        self.slug = slug
        self.img = np.array(Image.open(os.path.join(ROOT, 'game', 'assets', 'img', 'jigsaw', slug + '.jpg')).convert('RGB')).astype(np.int32)
        self.h, self.w = self.img.shape[:2]
        self.cw, self.ch = self.w / cols, self.h / rows
        src = os.path.join(ROOT, 'aseprite-source', 'scenes-pil', 'jigsaw_%s.py' % slug)
        if os.path.exists(src):
            hexes = sorted(set(re.findall(r"#[0-9a-fA-F]{6}\b", open(src, encoding='utf-8').read().lower())))
            self.pal = np.array([hx(h) for h in hexes if h not in ('#000000', '#ffffff')], np.int32)
        else:
            q = Image.fromarray(self.img.astype(np.uint8)).quantize(40, method=Image.Quantize.MEDIANCUT)
            self.pal = np.array(q.getpalette()[:120], np.int32).reshape(-1, 3)

    def snap(self, rgb):
        d = ((rgb[..., None, :] - self.pal[None, None, :, :]) ** 2).sum(-1)
        return self.pal[d.argmin(-1)].astype(np.uint8)

    def sample(self, col, row, x0, y0, size, dx=0.0, dy=0.0):
        """Canvas-sized RGB: canvas px (x, y) shows the picture where the cell (col, row) spans size x size canvas px from (x0, y0).
        Pixels outside the cell show the neighbouring cells, the way a real tab does. dx, dy nudge the crop in cell units."""
        sx = ((col + dx) + (CX - x0) / size) * self.cw
        sy = ((row + dy) + (CY - y0) / size) * self.ch
        sx = np.clip(sx, 0, self.w - 1).astype(int)
        sy = np.clip(sy, 0, self.h - 1).astype(int)
        return self.snap(self.img[sy, sx])

    def dominant(self, n=4):
        small = self.snap(self.img[3::6, 3::6])
        cols, cnt = np.unique(small.reshape(-1, 3), axis=0, return_counts=True)
        return [hexs(c) for c in cols[np.argsort(-cnt)][:n]]


def majority(tex, mask, passes=1):
    """3 x 3 mode filter inside the mask: removes 1 px speckle so a face reads on top of the fill."""
    t = tex.copy()
    for _ in range(passes):
        key = (t[..., 0].astype(np.int64) << 16) | (t[..., 1].astype(np.int64) << 8) | t[..., 2]
        out = t.copy()
        for y, x in zip(*np.nonzero(mask)):
            ys, xs = slice(max(0, y - 1), y + 2), slice(max(0, x - 1), x + 2)
            mm = mask[ys, xs]
            vals, cnt = np.unique(key[ys, xs][mm], return_counts=True)
            if cnt.max() >= 5:
                v = vals[cnt.argmax()]
                out[y, x] = ((v >> 16) & 255, (v >> 8) & 255, v & 255)
        t = out
    return t


def reduce(tex, mask, k):
    """Keep the k commonest colours inside the mask; everything else goes to its nearest kept colour."""
    cols, cnt = np.unique(tex[mask].reshape(-1, 3), axis=0, return_counts=True)
    keep = cols[np.argsort(-cnt)][:k].astype(np.int32)
    d = ((tex[..., None, :].astype(np.int32) - keep[None, None]) ** 2).sum(-1)
    out = keep[d.argmin(-1)].astype(np.uint8)
    return np.where(mask[..., None], out, tex)


def remap(tex, mask, pairs):
    """Swap whole colours in the fill (recolour toward the umber/cream house look): pairs = {'#from': '#to'}."""
    t = tex.copy()
    for a, b in pairs.items():
        m = mask & np.all(t == hx(a), axis=2)
        t[m] = hx(b)
    return t


# ---------------------------------------------------------------- the sticker
class Sticker:
    def __init__(self):
        self.px = np.zeros((N, N, 3), np.uint8)
        self.sil = blank()          # silhouette (gets the outline)
        self.extra = blank()        # sparkles: border only
        self.cx = self.cy = None

    def _put(self, m, col):
        if isinstance(col, str):
            self.px[m] = hx(col)
        else:
            self.px[m] = col[m] if col.ndim == 3 else col

    def part(self, m, col=None, tex=None, d=3, rim=True, contour=False, shade=True):
        """Paint a raised part (back to front): base, crescent lower right (+ bounce line if d >= 3), rim upper left, optional umber contour
        where it overlaps earlier parts. col = a hex base, or tex = a canvas-sized RGB fill (each pixel gets its own ramp)."""
        base = tex if tex is not None else np.broadcast_to(hx(col), (N, N, 3)).copy()
        prev = self.sil.copy()
        self.px[m] = base[m]
        if shade and d:
            cres = m & ~shift(m, -d, -d)
            bounce = (m & ~shift(m, -1, -1)) if d >= 3 else blank()
            self._ramp(cres & ~bounce, base, 'shade')
            self._ramp(bounce, base, 'bounce')
            if rim:
                self._ramp(m & ~shift(m, 1, 1) & shift(m, -d, -d), base, 'rim')
        if contour:
            self.px[m & dil4(prev & ~m)] = hx(UMBER)
        self.sil |= m
        return m

    def _ramp(self, m, base, kind):
        cache = {}
        for y, x in zip(*np.nonzero(m)):
            key = tuple(base[y, x])
            if key not in cache:
                cache[key] = tone(np.array(key, np.uint8), kind)
            self.px[y, x] = cache[key]

    def blank_shade(self, m, blanks, width=2):
        """Inner shadow round a blank (the hole a neighbour's tab fits in): the body pixels lining the hole get the deep tone of their own
        fill (1st px) and shade (2nd px), so a blank reads as a cut even on a pale fill."""
        near = m & dil4(blanks)
        base = self.px.copy()
        self._ramp(near, base, 'deep')
        if width > 1:
            self._ramp(m & dil4(near) & ~near, base, 'shade')

    def paint(self, m, col, solid=False):
        self._put(m, col)
        if solid:
            self.sil |= m

    def dots(self, pts, col):
        for x, y in pts:
            self.px[y, x] = hx(col)

    def sprite(self, rows, x, y, cmap, solid=True):
        """Hand-drawn pixel overlay: rows of chars, '.' = leave, other chars -> cmap colours."""
        for j, row in enumerate(rows):
            for i, ch in enumerate(row):
                if ch == '.' or ch == ' ':
                    continue
                self.px[y + j, x + i] = hx(cmap[ch])
                if solid:
                    self.sil[y + j, x + i] = True

    def eye(self, x, y, look=(0, 0), lid=0, socket=UMBER2):
        """Locked eye (Part D): 5 x 5 cut-corner cream disc, 3 x 3 umber pupil, 1 px cream glint top-left. look moves the pupil 1 px;
        lid = rows of heavy umber lid from the top (0 = open, 1 = calm, 2 = sleepy)."""
        if socket:   # a 1 px felt socket so the locked eye reads on any picture fill
            so = rect(x - 1, y - 1, x + 5, y + 5)
            for cx, cy in ((x - 1, y - 1), (x + 5, y - 1), (x - 1, y + 5), (x + 5, y + 5)):
                so[cy, cx] = False
            self.px[so] = hx(socket)
        e = rect(x, y, x + 4, y + 4)
        for cx, cy in ((x, y), (x + 4, y), (x, y + 4), (x + 4, y + 4)):
            e[cy, cx] = False
        self.px[e] = hx(CREAM)
        px, py = x + 1 + look[0], y + 1 + look[1]
        self.px[py:py + 3, px:px + 3] = hx(UMBER)
        self.px[py, px] = hx(CREAM)
        if lid:
            lm = e & (YY < y + lid)
            self.px[lm] = hx(UMBER2)
            self.px[(YY == y + lid - 1) & (XX >= x) & (XX <= x + 4)] = hx(UMBER)

    MOUTHS = {
        'smile': ['U...U', '.UUU.'],
        'grin': ['UUUUU', 'URRRU', '.UUU.'],
        'o': ['.U.', 'URU', '.U.'],
        'cat': ['U.U.U', '.U.U.'],
        'flat': ['UUU'],
        'smirk': ['....U', 'UUUU.'],
        'tooth': ['UUUUU', 'UCRCU', '.UUU.'],
    }

    def mouth(self, kind, x, y):
        self.sprite(self.MOUTHS[kind], x, y, {'U': UMBER, 'R': MOUTH_RED, 'C': CREAM}, solid=False)

    def stitch(self, m, col=GOLD, depth=2, phase=0, skip=blank()):
        """Dashed edge stitch, 1 px, `depth` px inside the part's edge: 2 on, 1 off along each run."""
        ring = shrink(m, depth) & ~shrink(m, depth + 1) & ~skip
        horiz = ring & (shift(ring, 1, 0) | shift(ring, -1, 0))
        on = np.where(horiz, (XX + phase) % 3 != 2, (YY + phase) % 3 != 2)
        self.px[ring & on] = hx(col)

    def button(self, x, y, col=GOLD, dark=GOLD_D):
        """4 x 4 cut-corner disc, darker lower right, two thread holes."""
        self.sprite(['.GG.', 'GhGD', 'GDhD', '.DD.'], x, y, {'G': col, 'D': dark, 'h': UMBER}, solid=False)

    def sparkle(self, x, y, big=True):
        """4-point sparkle mark (rare): cream core, gold arms, gets the black border only."""
        rows = ['..g..', '..g..', 'ggWgg', '..g..', '..g..'] if big else ['.g.', 'gWg', '.g.']
        for j, row in enumerate(rows):
            for i, ch in enumerate(row):
                if ch != '.':
                    self.px[y + j, x + i] = hx(GOLD if ch == 'g' else GOLD_L)
                    self.extra[y + j, x + i] = True

    # ------------------------------------------------------------ finish
    def finish(self, glow=False, glow_cols=('#fff3c8', '#f8dc6a')):
        u = self.sil.copy()
        ys, xs = np.nonzero(u)
        cx = self.cx if self.cx is not None else (xs.min() + xs.max()) / 2
        cy = self.cy if self.cy is not None else (ys.min() + ys.max()) / 2
        s = (XX - cx) + (YY - cy)
        ring = (grow(u, 2) | (grow(u, 3) & (s > 12))) & ~u
        px = self.px.copy()
        px[ring & (s < -18)] = hx(OL[0])
        px[ring & (s >= -18) & (s < -2)] = hx(OL[1])
        px[ring & (s >= -2)] = hx(OL[2])
        solid = u | ring
        if glow:
            g1 = dil4(solid) & ~solid
            px[g1] = hx(glow_cols[0])
            g2 = dil4(solid | g1) & ~(solid | g1)
            dash = ((XX + YY) % 4) < 2
            px[g2 & dash] = hx(glow_cols[1])
            solid = solid | g1 | (g2 & dash)
        extra = self.extra & ~solid
        px[extra] = self.px[extra]
        solid = solid | self.extra
        border = dil4(solid) & ~solid
        px[border] = 0
        alpha = (solid | border).astype(np.uint8) * 255
        return np.dstack([px, alpha]), border

    def save(self, path, glow=False):
        rgba, border = self.finish(glow)
        ys, xs = np.nonzero(border)
        sides = (int(xs.min()), int(ys.min()), int(N - 1 - xs.max()), int(N - 1 - ys.max()))   # left top right bottom
        margin = min(sides)
        cols = len({tuple(p) for p in rgba[rgba[..., 3] > 0][:, :3]})
        os.makedirs(os.path.dirname(path), exist_ok=True)
        Image.fromarray(rgba, 'RGBA').save(path, optimize=True)
        return {'colours': cols, 'margin': int(margin), 'sides': sides}


def contact_sheet(paths, out, labels=None):
    """All pals at 1x, 4x and 32 px (box-filtered, like a browser), on a dark and a cream band."""
    ims = [Image.open(p).convert('RGBA') for p in paths]
    n = len(ims)
    cw = 64 * 4 + 16
    band_h = 64 * 4 + 16 + 72
    sheet = Image.new('RGBA', (n * cw + 16, band_h * 2 + 16), (0, 0, 0, 255))
    for b, bg in enumerate(((30, 22, 16, 255), (242, 228, 192, 255))):
        y0 = 8 + b * band_h
        sheet.paste(Image.new('RGBA', (n * cw, band_h - 8), bg), (8, y0))
        for i, im in enumerate(ims):
            x0 = 8 + i * cw + 8
            sheet.alpha_composite(im.resize((256, 256), Image.NEAREST), (x0, y0 + 8))
            sheet.alpha_composite(im, (x0, y0 + 272))
            sheet.alpha_composite(im.resize((32, 32), Image.BOX), (x0 + 80, y0 + 272 + 16))
            sheet.alpha_composite(im.resize((32, 32), Image.BOX).resize((64, 64), Image.NEAREST), (x0 + 128, y0 + 272))
    sheet.save(out)
    return out
