"""av.py: wear-avatar toolkit. One wearable = one small design (shape params + 6-tone ramps + detail painters) on a
category template; the template places it on the gnome25 rig for 3 views x 8 frames (frames 1-2 idle, 3-8 walk).

Geometry comes from two places, both read-only:
  * the rig's own frame tables and shape calls (aseprite-source/v3/gnome-dir/gnome-dir.lua: IDLE/FB/SD, clog(), tunic
    ellipse + hip poly, sleeve/hand ellipses, scarf, beard) -> FRAMES / geo() below;
  * the rig PNG layers (game/assets/img/gnome25/<view>-<layer>.png) -> exact tunic mask + tone map (coats are a remap of
    the tunic, so sleeves follow the arm swing pixel-exactly), body silhouette and the head zone for the clip check.

Output per item: <out>/<slug>/<front|back|side>.png, 512x80 RGBA, hard pixels, ink #2b1c26, no #000/#fff.
Stack (rig.AFTER): footwear/coat after 'tunic'; backpack/cloak first (behind the gnome) in front view, after 'tunic' in back/side.
"""
import math
from PIL import Image
import rig

INK = '#2b1c26'
W, H, NF = 64, 80, 8
VIEWS = ('front', 'back', 'side')

# ---------------------------------------------------------------- frame tables (gnome-dir.lua; bob<0 = body 1 px down)
_IDLE = [dict(bob=0), dict(bob=1, pdy=1)]
_FB = [dict(bob=0, ly=0, ry=-1, arm=-2, tail=0, pdy=0, hem=0), dict(bob=-1, ly=0, ry=-2, arm=-1, tail=-1, pdy=0, hem=-1),
       dict(bob=0, ly=0, ry=-3, arm=0, tail=-1, pdy=1, hem=0), dict(bob=0, ly=-1, ry=0, arm=2, tail=0, pdy=0, hem=0),
       dict(bob=-1, ly=-2, ry=0, arm=1, tail=1, pdy=0, hem=1), dict(bob=0, ly=-3, ry=0, arm=0, tail=1, pdy=1, hem=0)]
_SD = [dict(bob=0, nx=4, nl=0, fx=-4, fl=0, arm=-3, tail=0, pdy=0, hem=0), dict(bob=-1, nx=2, nl=0, fx=-3, fl=-2, arm=-2, tail=-1, pdy=0, hem=-1),
       dict(bob=0, nx=-1, nl=0, fx=1, fl=-3, arm=0, tail=-1, pdy=1, hem=0), dict(bob=0, nx=-4, nl=0, fx=4, fl=0, arm=3, tail=0, pdy=0, hem=0),
       dict(bob=-1, nx=-3, nl=-2, fx=2, fl=0, arm=2, tail=-1, pdy=0, hem=-1), dict(bob=0, nx=1, nl=-3, fx=-1, fl=0, arm=0, tail=-1, pdy=1, hem=0)]
_D = dict(bob=0, ly=0, ry=0, arm=0, tail=0, pdy=0, hem=0, nx=2, nl=0, fx=-2, fl=0)
FRAMES = {v: [{**_D, **p} for p in _IDLE + (_SD if v == 'side' else _FB)] for v in VIEWS}   # idle side stance: fx -2, nx 2


# ---------------------------------------------------------------- masks (same rasterisation as lib/hp.lua)
class M(set):
    def __or__(self, o): return M(set.__or__(self, o))
    def __and__(self, o): return M(set.__and__(self, o))
    def __sub__(self, o): return M(set.__sub__(self, o))
    def __xor__(self, o): return M(set.__xor__(self, o))
    def add_(self, o): self |= o; return self
    def cut(self, o): self -= o; return self
    def clip(self, o): self &= o; return self
    def sh(self, dx, dy): return M((x + dx, y + dy) for x, y in self)
    def has(self, x, y): return (x, y) in self
    def bbox(self):
        xs = [p[0] for p in self]; ys = [p[1] for p in self]
        return (min(xs), min(ys), max(xs), max(ys)) if self else (0, 0, -1, -1)
    def edge(self):   # outer ring (4-neighbour)
        return M((x + dx, y + dy) for x, y in self for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)) if (x + dx, y + dy) not in self)
    def inner_edge(self):
        return M(p for p in self if any((p[0] + dx, p[1] + dy) not in self for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))))
    def rows(self, y0, y1): return M(p for p in self if y0 <= p[1] <= y1)
    def cols(self, x0, x1): return M(p for p in self if x0 <= p[0] <= x1)
    def bottom(self): return M(p for p in self if (p[0], p[1] + 1) not in self)
    def top(self): return M(p for p in self if (p[0], p[1] - 1) not in self)
    def mirror(self): return M((63 - x + 1, y) for x, y in self)   # 65 - x as gnome-dir MIR, -1 for 0-based pixel centres
    def copy(self): return M(self)


def ellipse(cx, cy, rx, ry):
    m = M()
    for y in range(math.floor(cy - ry - 1), math.ceil(cy + ry + 1) + 1):
        for x in range(math.floor(cx - rx - 1), math.ceil(cx + rx + 1) + 1):
            if ((x - cx) / (rx + .5)) ** 2 + ((y - cy) / (ry + .5)) ** 2 <= 1: m.add((x, y))
    return m


def poly(pts):
    m = M()
    xs = [p[0] for p in pts]; ys = [p[1] for p in pts]
    for y in range(math.floor(min(ys)), math.ceil(max(ys)) + 1):
        for x in range(math.floor(min(xs)), math.ceil(max(xs)) + 1):
            px, py, inside, j = x + .5, y + .5, False, len(pts) - 1
            for i in range(len(pts)):
                a, b = pts[i], pts[j]
                if (a[1] > py) != (b[1] > py) and px < (b[0] - a[0]) * (py - a[1]) / (b[1] - a[1]) + a[0]: inside = not inside
                j = i
            if inside: m.add((x, y))
    return m


def rect(x0, y0, x1, y1): return M((x, y) for y in range(int(y0), int(y1) + 1) for x in range(int(x0), int(x1) + 1))


def line(pts, w=1):
    m, lo = M(), (w - 1) // 2
    def stamp(x, y):
        for dy in range(w):
            for dx in range(w):
                if not (w >= 4 and dx in (0, w - 1) and dy in (0, w - 1)): m.add((x - lo + dx, y - lo + dy))
    if len(pts) == 1: stamp(math.floor(pts[0][0] + .5), math.floor(pts[0][1] + .5))
    for a, b in zip(pts, pts[1:]):
        n = max(abs(b[0] - a[0]), abs(b[1] - a[1]), 1)
        for s in range(int(n) + 1): stamp(math.floor(a[0] + (b[0] - a[0]) * s / n + .5), math.floor(a[1] + (b[1] - a[1]) * s / n + .5))
    return m


# ---------------------------------------------------------------- rig-derived geometry per view/frame
def _layer_mask(view, name, f):
    im = rig.layer(view, name, False).crop(((f - 1) * W, 0, f * W, H)).load()
    return M((x, y) for y in range(H) for x in range(W) if im[x, y][3])


def _tones(view, name, f):
    im = rig.layer(view, name, False).crop(((f - 1) * W, 0, f * W, H)).load()
    return {(x, y): rig.MARK.get(im[x, y][:3], 1) for y in range(H) for x in range(W) if im[x, y][3]}


_geo = {}


def geo(view, f):
    """Everything a template needs for one frame. f = 1..8."""
    k = (view, f)
    if k in _geo: return _geo[k]
    p = FRAMES[view][f - 1]
    b = -p['bob']
    g = dict(view=view, f=f, p=p, b=b, tail=p['tail'], hem=p['hem'], pdy=p['pdy'])
    g['tunic'] = _layer_mask(view, 'tunic', f)
    g['tunic_tone'] = _tones(view, 'tunic', f)          # 0 hi, 1 base, 2 shade, 3 deep
    g['boots'] = _layer_mask(view, 'boots', f)
    g['body'] = _union(view, f)
    head = M()
    for n in ('hat', 'face'): head |= _layer_mask(view, n, f)
    head |= M(q for q in _layer_mask(view, 'skin', f) if q[1] <= 44 + b)          # face/ears skin, not the hands
    head |= M(q for q in _layer_mask(view, 'beard', f) if q[1] <= 47 + b or view == 'front')
    g['head'] = head
    # protected = head layers + their ink outline (outline pixels touching the head)
    ol = _layer_mask(view, 'outline', f)
    g['head_ink'] = M(q for q in ol if any((q[0] + dx, q[1] + dy) in head for dx in (-1, 0, 1) for dy in (-1, 0, 1)))
    if view in ('front', 'back'):
        la, ra = p['arm'], -p['arm']
        g['feet'] = [dict(cx=27, cy=67.5 + p['ly'], lift=p['ly'], side='L'), dict(cx=37.5, cy=67.5 + p['ry'], lift=p['ry'], side='R')]
        g['sleeves'] = [ellipse(20, 52 + b + la, 3, 4.5), ellipse(45, 52 + b + ra, 3, 4.5)]
        g['hands'] = [(20, 57 + b + la), (45, 57 + b + ra)]
        g['torso'] = ellipse(32.5, 55 + b, 12, 9).add_(poly([(22, 58 + b), (43, 58 + b), (44 + p['hem'], 64 + b), (21 + p['hem'], 64 + b)]))
    else:
        ad = p['arm']
        # far first (drawn first), near second
        g['feet'] = [dict(cx=31 + p['fx'], cy=67.5 + p['fl'], lift=p['fl'], side='far'), dict(cx=33 + p['nx'], cy=67.5 + p['nl'], lift=p['nl'], side='near')]
        g['sleeves'] = [line([(31, 48 + b), (31 + ad // 2, 52 + b), (31 + ad, 55 + b)], 5)]
        g['hands'] = [(31 + ad, 57.5 + b)]
        g['torso'] = ellipse(32.5, 55 + b, 10, 9).add_(ellipse(34, 56 + b, 9, 7.5)).add_(poly([(24, 58 + b), (41, 58 + b), (42 + p['hem'], 64 + b), (23 + p['hem'], 64 + b)]))
    _geo[k] = g
    return g


def _union(view, f):
    m = M()
    for n, _ in rig.ORDER:
        if n != 'shadow': m |= _layer_mask(view, n, f)
    return m


# ---------------------------------------------------------------- canvas + painting
class C(dict):
    """One frame: (x, y) -> '#rrggbb'. Later puts win."""
    def put(self, x, y, col):
        if 0 <= x < W and 0 <= y < H and col: self[(x, y)] = col
    def fill(self, m, col):
        for x, y in m: self.put(x, y, col)
        return self
    def mask(self): return M(self.keys())


def form(c, m, r, frac=0.3, rim=True, under=True, hi=None):
    """Hearth Pop forming on a 6-tone ramp r (dark..light): base r[3], lit top/left rim r[4], shade band on the right
    `frac` of the width r[2], underside row r[1]. Light from upper left. hi: list of (x,y) specular pops in r[5]."""
    if not m: return c
    x0, y0, x1, y1 = m.bbox()
    for x, y in m:
        col = r[3]
        if x > x1 - (x1 - x0 + 1) * frac: col = r[2]
        if rim and ((x, y - 1) not in m or (x - 1, y) not in m) and x <= x1 - (x1 - x0 + 1) * frac: col = r[4]
        if under and (x, y + 1) not in m: col = r[1]
        c.put(x, y, col)
    for q in hi or []:
        if q in m: c.put(q[0], q[1], r[5])
    return c


def remap(c, tones, mask, r, shift=0):
    """Paint mask using a rig tone map (0 hi..3 deep) onto ramp r: hi->r[4], base->r[3], shade->r[2], deep->r[1]."""
    for q in mask:
        t = tones.get(q, 1)
        c.put(q[0], q[1], r[max(0, min(5, 4 - t + shift))])
    return c


def ring(c, g, into='all', keep=()):
    """1 px ink ring round the frame's wear pixels. into='all' or 'empty' (only where the rig has nothing); never on the
    head zone or its outline; `keep` = extra pixels to leave alone."""
    for q in list(c.keys()):   # head-safe: wear never covers the head's own ink outline (it reads as passing behind the head)
        if q in g['head_ink']: del c[q]
    m = c.mask()
    for q in m.edge():
        if not (0 <= q[0] < W and 0 <= q[1] < H): continue
        if q in g['head'] or q in g['head_ink'] or q in keep: continue
        if into == 'empty' and q in g['body']: continue
        c.put(q[0], q[1], INK)
    return c


def checker(m, a, b, size=2, ox=0, oy=0):
    """returns dict pixel->colour for a 2-colour check (plaid helper)"""
    return {q: (a if ((q[0] + ox) // size + (q[1] + oy) // size) % 2 == 0 else b) for q in m}


def lerp_ramp(r, i):
    return r[max(0, min(5, i))]


# ---------------------------------------------------------------- output + checks
def strip(frames):
    im = Image.new('RGBA', (W * NF, H), (0, 0, 0, 0))
    px = im.load()
    for i, c in enumerate(frames):
        for (x, y), col in c.items():
            if 0 <= x < W and 0 <= y < H: px[i * W + x, y] = (*rig.hx(col), 255)
    return im


def check(im, view, cat):
    """returns list of problems: semi-transparent, pure black/white, head-zone changes after compositing."""
    probs = []
    d = im.getdata() if not hasattr(im, 'get_flattened_data') else im.get_flattened_data()
    semi = sum(1 for p in d if 0 < p[3] < 255)
    bw = sum(1 for p in d if p[3] and p[:3] in ((0, 0, 0), (255, 255, 255)))
    if semi: probs.append(f'{semi} semi-transparent px')
    if bw: probs.append(f'{bw} pure black/white px')
    base = rig.compose(view).load(); wear = rig.compose(view, [(cat, im)]).load()
    for f in range(1, NF + 1):
        g = geo(view, f)
        bad = [q for q in (g['head'] | g['head_ink']) if base[(f - 1) * W + q[0], q[1]] != wear[(f - 1) * W + q[0], q[1]]]
        if bad: probs.append(f'f{f}: {len(bad)} head-zone px changed')
    return probs
