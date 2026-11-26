#!/usr/bin/env python3
"""rigkit.py: shared kit for redrawing fight-scene creature rigs (game/assets/img/fight/rig-<slug>.png) in the Stitched Toy style.

STAGING ONLY: reads game/assets/fightrigs.js and the shipped sheets, writes to art-review/rigs/out/. Nothing under game/ is written.
Format (see art-review/rigs/FORMAT.md): one column per part (fightrigs.js part order), each column a full frame fw x fh;
row 0 = the part's paint, row 1 = its 1 px 4-adjacent ink ring (none for the part named 'eyes'). Pivots come from the bones.

A rig script (art-review/rigs/scripts/<slug>.py) does:
    R = Rig('bog-pike')
    p = R.part('s1'); p.add(p.m(ell(...), capsule(...)), MOSS, stitch=True); p.edge(...); p.px(x, y, col) ...
    R.save()          # writes out/rig-<slug>.png, runs check(), writes out/_assembled/<slug>.png (rest pose, 4x, light + dark)
Coordinates are FRAME pixels (floats, the pixel (x, y) covers x..x+1); R.pv(id) gives a part's pivot as the engine computes it.
Pillow only, deterministic.
"""
import math
import os
import sys

from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from rigdata import rig as rigdef, ROOT  # noqa: E402

OUT = os.path.join(HERE, 'out')
SHIPPED = os.path.join(ROOT, 'game/assets/img/fight')

# ---------------------------------------------------------------- palette: DESIGN.md tokens first, Hearth Pop only where DESIGN has no hue
INK = '#2a1a10'          # DESIGN ink / 1 px umber outline (shipped rigs use Hearth Pop ink #2b1c26: visually the same)
UMBER2 = '#4a2c1a'       # ink-2
CREAM = '#fff3c8'        # surface
# ramps: (hi, base, shade, deep)
PAPER = ('#fff3c8', '#f2e4c0', '#c9a96e', '#9a6b3f')       # surface, surface-2, line, line-2
WOOD = ('#c9a96e', '#9a6b3f', '#74462a', '#4a2c1a')        # line, line-2, muted, ink-2
MOSS = ('#c8d09f', '#7ab55c', '#4f8a3e', '#2f5a2a')        # brand-soft, brand-line, (mid), brand
PINE = ('#7ab55c', '#4f8a3e', '#2f5a2a', '#1f3d1c')
OLIVE = ('#c8d09f', '#9aa860', '#6b7a3a', '#3f4a22')
GOLD = ('#f5cf6a', '#e8a317', '#b87a14', '#7a4a1f')        # accent, accent-ink
EMBER = ('#f08a4a', '#dd3a2a', '#a8241f', '#6e2038')       # danger
PETAL = ('#fde0ea', '#f6b8cf', '#e46a9b', '#a8346a')       # danger-soft
WATER = ('#e4f6ff', '#a9d6ea', '#3f8fb0', '#1f4a6a')       # info-soft, focus/info-ink
MINT = ('#e8fbf2', '#c8ecdc', '#7fc8b8', '#3f8fb0')
LILAC = ('#e4dcf6', '#c3b2ea', '#8a72c8', '#4e3a8a')       # purple
STONE = ('#f1ece0', '#c9c5bc', '#8b8f96', '#5b6470')       # bg + old mini greys
SOOT = ('#6a5648', '#4a2c1a', '#2a1a10', '#2a1a10')        # dark fur / bee black (umber, never pure black)
BLUSH = '#f6b8cf'


def darker(r):
    """the far side of a pair (far legs, back wing): one step down the ramp"""
    return (r[1], r[2], r[3], r[3])


# ---------------------------------------------------------------- shape predicates in frame px; evaluated at pixel centres
def rect(x0, y0, x1, y1):
    return lambda x, y: x0 <= x < x1 and y0 <= y < y1


def ell(cx, cy, rx, ry=None):
    ry = rx if ry is None else ry
    return lambda x, y: ((x - cx) / rx) ** 2 + ((y - cy) / ry) ** 2 <= 1.0


def rell(cx, cy, rx, ry, deg):
    """rotated ellipse (deg clockwise on screen)"""
    c, s = math.cos(math.radians(deg)), math.sin(math.radians(deg))
    def f(x, y):
        dx, dy = x - cx, y - cy
        u, v = dx * c + dy * s, -dx * s + dy * c
        return (u / rx) ** 2 + (v / ry) ** 2 <= 1.0
    return f


def poly(pts):
    def f(x, y):
        ins = False
        n = len(pts)
        for i in range(n):
            (x0, y0), (x1, y1) = pts[i], pts[(i + 1) % n]
            if (y0 > y) != (y1 > y) and x < x0 + (y - y0) * (x1 - x0) / (y1 - y0):
                ins = not ins
        return ins
    return f


def _segd(px, py, ax, ay, bx, by):
    dx, dy = bx - ax, by - ay
    L2 = dx * dx + dy * dy or 1e-9
    t = max(0.0, min(1.0, ((px - ax) * dx + (py - ay) * dy) / L2))
    return math.hypot(px - ax - t * dx, py - ay - t * dy), t


def capsule(pts, w0, w1=None):
    """a tapered stroke along a polyline: width w0 at the start, w1 at the end (round ends)"""
    w1 = w0 if w1 is None else w1
    segs, tot = [], 0.0
    for a, b in zip(pts, pts[1:]):
        L = math.hypot(b[0] - a[0], b[1] - a[1]); segs.append((a, b, tot, L)); tot += L
    tot = tot or 1e-9
    def f(x, y):
        for a, b, s0, L in segs:
            d, t = _segd(x, y, a[0], a[1], b[0], b[1])
            w = w0 + (w1 - w0) * (s0 + t * L) / tot
            if d <= w / 2:
                return True
        return False
    return f


def union(*ps):
    return lambda x, y: any(p(x, y) for p in ps)


def minus(p, *qs):
    return lambda x, y: p(x, y) and not any(q(x, y) for q in qs)


def inter(p, *qs):
    return lambda x, y: p(x, y) and all(q(x, y) for q in qs)


def half(ax, ay, bx, by):
    """the half plane to the LEFT of a->b on screen (y down): e.g. half(0,10,10,10) = everything below y=10? no: left of a rightward line = above"""
    return lambda x, y: (bx - ax) * (y - ay) - (by - ay) * (x - ax) < 0


def below(a, b, off=0.0):
    """points on the down-normal side of the line a->b (for a rightward line: below it) by more than off px (negative off: also a band above)"""
    dx, dy = b[0] - a[0], b[1] - a[1]; L = math.hypot(dx, dy) or 1e-9
    nx, ny = -dy / L, dx / L
    return lambda x, y: (x - a[0]) * nx + (y - a[1]) * ny > off


def erode(m):
    return {(x, y) for (x, y) in m if all((x + dx, y + dy) in m for dx in (-1, 0, 1) for dy in (-1, 0, 1))}


def ring4(m):
    out = set()
    for (x, y) in m:
        for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            q = (x + dx, y + dy)
            if q not in m:
                out.add(q)
    return out


def hexrgb(c):
    return tuple(int(c[i:i + 2], 16) for i in (1, 3, 5))


# ---------------------------------------------------------------- one part = one column of the sheet
class Part:
    def __init__(self, rig, pid):
        self.rig, self.id = rig, pid
        self.fw, self.fh = rig.fw, rig.fh
        self.layers = []      # (mask, ramp, opts)
        self.over = {}        # pixel -> colour, painted last (inside the silhouette only)
        self.edges = {}
        self.cut = set()

    def m(self, *preds, minus=()):
        out = set()
        for y in range(self.fh):
            for x in range(self.fw):
                X, Y = x + .5, y + .5
                if any(p(X, Y) for p in preds) and not any(q(X, Y) for q in minus):
                    out.add((x, y))
        return out

    def add(self, mask, ramp, stitch=None, flat=False, local=False, crescent=None, ref=None):
        """paint a layer. ramp (hi, base, shade, deep). stitch: True (= ramp deep) or a hex for a dashed felt thread 2 px inside the layer's
        visible edge. flat: no rim light / no shade. local: rim + shade from the layer's own edge instead of the part silhouette.
        ref: a mask to light against instead (e.g. the whole fish, so chained segments shade as one body)."""
        self.layers.append((set(mask), ramp, dict(stitch=stitch, flat=flat, local=local, crescent=crescent, ref=ref)))
        return mask

    def px(self, x, y, col):
        self.over[(int(x), int(y))] = col

    def pxs(self, pts, col):
        for p in pts:
            self.px(p[0], p[1], col)

    def fill(self, mask, col):
        for p in mask:
            self.over[p] = col

    def line(self, pts, col):
        """1 px pixel-stepped line through frame points"""
        for (ax, ay), (bx, by) in zip(pts, pts[1:]):
            steps = int(max(abs(bx - ax), abs(by - ay), 1))
            for i in range(steps + 1):
                self.px(math.floor(ax + (bx - ax) * i / steps), math.floor(ay + (by - ay) * i / steps), col)

    def edge(self, mask, col, sides='all'):
        """inner contour where this mask meets the rest of the part (the outside silhouette edge stays ink)"""
        for (x, y) in mask:
            nb = ((1, 0), (-1, 0), (0, 1), (0, -1)) if sides == 'all' else sides
            if any((x + dx, y + dy) not in mask for dx, dy in nb):
                self.edges[(x, y)] = col

    def eye(self, x, y, size=2, look=1, white=True, iris=None, lid=None):
        """Stitched Toy button eye at frame px (x, y) (its centre). size 1: 2x2 pupil + glint; 2: 3x3 pupil on a cream disc; 3: big round eye."""
        x, y = int(x), int(y)
        if size >= 3:
            for dx in range(-3, 4):
                for dy in range(-3, 4):
                    if dx * dx + dy * dy <= 10:
                        self.px(x + dx, y + dy, INK)
            for dx in range(-2, 3):
                for dy in range(-2, 3):
                    if dx * dx + dy * dy <= 5:
                        self.px(x + dx, y + dy, iris or CREAM)
            for dx in range(0, 2):
                for dy in range(-1, 2):
                    self.px(x + dx + (look > 0) - 1 + (1 if look > 0 else 0), y + dy, INK)
            self.px(x - 1, y - 2, '#ffffff' if iris else CREAM)
        elif size == 2:
            if white:
                for dx in range(-2, 3):
                    for dy in range(-2, 3):
                        if abs(dx) + abs(dy) <= 3:
                            self.px(x + dx, y + dy, CREAM)
            for dx in range(-1, 1):
                for dy in range(-1, 2):
                    self.px(x + dx + look, y + dy, INK)
            self.px(x + look - 1, y - 1, CREAM)
        else:
            self.px(x, y, INK); self.px(x + 1, y, INK); self.px(x, y + 1, INK); self.px(x + 1, y + 1, INK)
            self.px(x, y, CREAM)
        if lid:
            for dx in range(-2, 3):
                self.px(x + dx, y - 3 + (1 if abs(dx) == 2 else 0), lid)

    # -------------------------------------------------------- render one part: paint (row 0) and ink (row 1)
    def render(self):
        own = {}
        for i, (mask, _, _) in enumerate(self.layers):
            for p in mask:
                own[p] = i
        for p in self.cut:
            own.pop(p, None)
        sil = set(own)
        big = len(sil) > 260
        cols = {}
        lmask = [{p for p in m if own.get(p) == i} for i, (m, _, _) in enumerate(self.layers)]
        for (x, y), i in own.items():
            _, r, o = self.layers[i]
            c = r[1]
            if not o['flat']:
                ref = o['ref'] if o['ref'] is not None else (lmask[i] if o['local'] else sil)
                cr = o['crescent'] if o['crescent'] is not None else (2 if big else 1)
                if (x - 1, y) not in ref or (x, y - 1) not in ref:
                    c = r[0]
                if any((x + d, y) not in ref or (x, y + d) not in ref or (x + d, y + d) not in ref for d in range(1, cr + 1)):
                    c = r[2]
            cols[(x, y)] = c
        for i, (mask, r, o) in enumerate(self.layers):
            st = o['stitch']
            if not st:
                continue
            st = r[3] if st is True else st
            e2 = erode(erode(lmask[i])); e3 = erode(e2)
            for (x, y) in sorted(e2 - e3):
                if ((x + y) // 2) % 2 == 0:
                    cols[(x, y)] = st
        for p, c in self.edges.items():
            if p in sil:
                cols[p] = c
        for p, c in self.over.items():
            if p in sil:
                cols[p] = c
        ink = set() if self.id == 'eyes' else ring4(sil)
        return sil, cols, ink


# ---------------------------------------------------------------- a rig
class Rig:
    def __init__(self, slug):
        self.slug = slug
        d = rigdef(slug)
        self.d = d
        self.fw, self.fh, self.u, self.ids = d['fw'], d['fh'], d['u'], d['parts']
        self.ground = d['by']        # ground row (figure b = 0)
        self.parts = {p: Part(self, p) for p in self.ids}

    def part(self, pid):
        return self.parts[pid]

    def pv(self, pid):
        return self.d['piv'][pid]

    def F(self, a, b):
        """figure units (a right of centre, b up from the ground) -> frame px"""
        return (self.d['cx'] + a * self.u + .5, self.d['by'] - b * self.u + .5)

    def sheet(self):
        fw, fh = self.fw, self.fh
        img = Image.new('RGBA', (fw * len(self.ids), fh * 2), (0, 0, 0, 0))
        self.rendered = {}
        for i, pid in enumerate(self.ids):
            sil, cols, ink = self.parts[pid].render()
            self.rendered[pid] = (sil, cols, ink)
            for (x, y) in ink:
                if 0 <= x < fw and 0 <= y < fh:
                    img.putpixel((i * fw + x, fh + y), hexrgb(INK) + (255,))
            for (x, y), c in cols.items():
                if 0 <= x < fw and 0 <= y < fh:
                    img.putpixel((i * fw + x, y), hexrgb(c) + (255,))
        return img

    def save(self, out=OUT):
        os.makedirs(out, exist_ok=True)
        img = self.sheet()
        path = os.path.join(out, 'rig-%s.png' % self.slug)
        img.save(path, optimize=True)
        bad = check(self.slug, path, self)
        rest = assemble(self.slug, img)
        old = assemble(self.slug, Image.open(os.path.join(SHIPPED, 'rig-%s.png' % self.slug)).convert('RGBA'))
        os.makedirs(os.path.join(out, '_assembled'), exist_ok=True)
        pair(old, rest).save(os.path.join(out, '_assembled', self.slug + '.png'))
        print('%-18s %s  %s' % (self.slug, path, 'OK' if not bad else 'PROBLEMS: ' + '; '.join(bad)))
        return bad


# ---------------------------------------------------------------- checks (also used by check_all.py)
def check(slug, path, R=None):
    """size/mode same as the shipped sheet; alpha only 0/255; every part inside its own column with a free 1 px border (so its ink ring fits);
    row 1 = exactly the 4-adjacent ring of row 0 (eyes: empty); pivots: every part touches its own pivot and every child's pivot lies on its parent."""
    bad = []
    d = rigdef(slug); fw, fh, ids = d['fw'], d['fh'], d['parts']
    new = Image.open(path)
    old = Image.open(os.path.join(SHIPPED, 'rig-%s.png' % slug))
    if new.size != old.size:
        bad.append('size %s != shipped %s' % (new.size, old.size))
    if new.mode != old.mode:
        bad.append('mode %s != shipped %s' % (new.mode, old.mode))
    im = new.convert('RGBA')
    A = im.getchannel('A')
    if set(A.getdata()) - {0, 255}:
        bad.append('alpha not 0/255')
    sils = {}
    for i, pid in enumerate(ids):
        paint = {(x, y) for y in range(fh) for x in range(fw) if A.getpixel((i * fw + x, y))}
        inkp = {(x, y) for y in range(fh) for x in range(fw) if A.getpixel((i * fw + x, fh + y))}
        sils[pid] = paint
        if not paint:
            bad.append(pid + ': empty'); continue
        if any(x < 1 or y < 1 or x > fw - 2 or y > fh - 2 for x, y in paint):
            bad.append(pid + ': paint touches its frame border (ink ring would be clipped / part leaves its rect)')
        want = set() if pid == 'eyes' else {p for p in ring4(paint) if 0 <= p[0] < fw and 0 <= p[1] < fh}
        if inkp != want:
            bad.append(pid + ': ink row is not the 1 px ring of the paint (%d vs %d px)' % (len(inkp), len(want)))
        inkcols = {im.getpixel((i * fw + x, fh + y))[:3] for x, y in inkp}
        if inkcols - {hexrgb(INK)}:
            bad.append(pid + ': ink row has other colours')
    for pid in ids:
        px, py = d['piv'][pid]
        q = (int(px), int(py))
        near = lambda s, r: any(abs(x + .5 - px) <= r and abs(y + .5 - py) <= r for x, y in s)
        bb = (min(x for x, y in sils[pid]), min(y for x, y in sils[pid]), max(x for x, y in sils[pid]) + 1, max(y for x, y in sils[pid]) + 1) if sils[pid] else (0, 0, 0, 0)
        inbox = bb[0] <= px <= bb[2] and bb[1] <= py <= bb[3]
        if not near(sils[pid], 1.6) and not (pid.startswith('eye') and inbox):   # a pair of eyes may straddle its pivot
            bad.append(pid + ': its pivot (%.1f, %.1f) is not on the part' % (px, py))
        par = d['bones'][pid][0]
        if par and not near(sils[par], 1.6):
            bad.append(pid + ': its pivot is not on its parent ' + par)
    ncol = len(set(im.getdata())) - 1
    if ncol > 64:
        bad.append('%d colours (keep under 64)' % ncol)
    if R is not None:
        R.ncol = ncol
    return bad


# ---------------------------------------------------------------- static rest-pose assembly in the engine's draw order (quick look only;
# the real check is preview.js, which runs fightengine.js / fightscene.js in Chromium)
def draw_order(slug):
    d = rigdef(slug); ids = d['parts']; bones = d['bones']
    kids = {p: [c for c in ids if bones[c][0] == p] for p in ids}
    out = []
    def walk(p):
        for c in kids[p]:
            if bones[c][3]:
                walk(c)
        out.append(p)
        for c in kids[p]:
            if not bones[c][3]:
                walk(c)
    for p in ids:
        if not bones[p][0]:
            walk(p)
    return out


def assemble(slug, sheet):
    d = rigdef(slug); fw, fh, ids = d['fw'], d['fh'], d['parts']
    order = draw_order(slug)
    img = Image.new('RGBA', (fw, fh), (0, 0, 0, 0))
    for row in (1, 0):
        for pid in order:
            if row and pid == 'eyes':
                continue
            i = ids.index(pid)
            fr = sheet.crop((i * fw, row * fh, (i + 1) * fw, (row + 1) * fh))
            img.alpha_composite(fr)
    return img


def pair(a, b, S=4):
    """old | new at S x, on light #f1ece0 and dark #2a1a10"""
    w, h = a.width * S, a.height * S
    o = Image.new('RGBA', (w * 2 + 12, h * 2 + 12), (255, 255, 255, 255))
    for j, bg in enumerate(((241, 236, 224, 255), (42, 26, 16, 255))):
        for i, im in enumerate((a, b)):
            t = Image.new('RGBA', a.size, bg); t.alpha_composite(im)
            o.paste(t.resize((w, h), Image.NEAREST), (i * (w + 12), j * (h + 12)))
    return o
