#!/usr/bin/env python3
"""run80_coats.py: recolour the 12-frame side run (80x64) for all 8 coats, with procedural pattern overlays,
folded ears, bobtail and eye-colour overlays.  Writes ONLY to aseprite-source/catfish/room2/out80/coats/ (+ _view/).

Run:  python3 -I aseprite-source/catfish/room2/run80_coats.py

Inputs: out80/cf-cat-grey-run01..12.png, cf-ears-mask-run*, cf-tail-mask-run*, out80/cf-run80-grey.aseprite (layers = part ownership),
        pose/leg tables parsed from cf_run80.lua (so the part positions are the Lua's), tones.json, tones_overlays.json.
Outputs (names mirror the 64x64 set, pose = run01..run12):
  cf-cat-<coat>-runNN.png            body, palette swap by tools/catfish_recolor.py build_map/recolor
  cf-pat-<pattern>-<coat>-runNN.png  tabby tuxedo calico pointed spotted (overlay, drawn over the body, hard alpha)
  cf-ears-folded-<coat>-runNN.png    replacement ears (folded) incl. their outline
  cf-tail-bobtail-<coat>-runNN.png   replacement tail stub incl. outline
  cf-ears-clear-runNN.png / cf-tail-clear-runNN.png  (coat independent) pixels to ERASE from body+pattern before drawing the part
        (the run masks cover the felt only; the sticker outline around a removed ear/tail also has to go, so these are the
        mask + changed outline pixels.  Compose: body, erase clear mask, part, pattern, eyes.)
  cf-eyes-<amber|green|blue|hazel>-runNN.png   the one visible eye's iris ring in the eye colour (as cf-eyes-* in the 64x64 set)
Patterns are generated in part-local coordinates (body: x-BX and y-spine; haunch/chest/head/paw: offset from the part
centre in cf_run80.lua; tail and legs: arc length along the bone chain), so they travel with the parts frame to frame.
"""
import os, re, sys, struct, zlib, math, json, collections
sys.dont_write_bytecode = True
import numpy as np
from PIL import Image
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '..', '..', '..'))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
import catfish_recolor as R

OUT80 = os.path.join(HERE, 'out80')
OUT = os.path.join(OUT80, 'coats')
VIEW = os.path.join(OUT, '_view')
NF = 12
H_, W_ = 64, 80
BX = 34
GREYS = {'57516f': 'shade', '8a859b': 'base', 'cdc9d3': 'light', 'f1ebe3': 'gloss'}
OLS = {(0x2a, 0x1a, 0x10), (0x4a, 0x2c, 0x1a), (0x74, 0x46, 0x2a), (0, 0, 0)}
def hx_(h): return tuple(int(h[i:i + 2], 16) for i in (0, 2, 4))
DEEP, SHADE, BASE, LIGHT, GLOSS = map(hx_, ('3d3654', '57516f', '8a859b', 'cdc9d3', 'f1ebe3'))
WG, WF, WS, WD, WE = map(hx_, ('fbf6ec', 'e6dfd2', 'bab0c0', '8d829a', '463e5e'))
EYECREAM = (0xf2, 0xe4, 0xc0)

# ---------------------------------------------------------------- inputs
def parse_ase(path):
    d = open(path, 'rb').read()
    nfr = struct.unpack_from('<H', d, 6)[0]
    pos = 128; layers = []; cels = collections.defaultdict(dict)
    for fi in range(nfr):
        size, magic, old, dur, _r, new = struct.unpack_from('<IHHH2sI', d, pos)
        cnt = new or old; p = pos + 16
        for _c in range(cnt):
            csz, ct = struct.unpack_from('<IH', d, p)
            body = p + 6
            if ct == 0x2004:
                nl = struct.unpack_from('<H', d, body + 16)[0]
                layers.append(d[body + 18:body + 18 + nl].decode())
            elif ct == 0x2005:
                li, x, y, op, typ = struct.unpack_from('<HhhBH', d, body)
                if typ in (0, 2):
                    w, h = struct.unpack_from('<HH', d, body + 16)
                    raw = d[body + 20:p + csz]
                    if typ == 2: raw = zlib.decompress(raw)
                    cels[li][fi] = (x, y, w, h, raw)
            p += csz
        pos += size
    return layers, cels

def load_layers():
    """name -> list of 12 (64,80) bool opaque masks"""
    layers, cels = parse_ase(os.path.join(OUT80, 'cf-run80-grey.aseprite'))
    out = {}
    for li, name in enumerate(layers):
        fr = [cels[li][k] for k in sorted(cels[li])]
        lst = []
        for (x, y, w, h, raw) in fr[:NF]:
            a = np.frombuffer(raw, np.uint8).reshape(h, w, 4)
            m = np.zeros((H_, W_), bool); m[y:y + h, x:x + w] = a[..., 3] > 0
            lst.append(m)
        out[name] = lst
    return out

def parse_lua():
    s = open(os.path.join(HERE, 'cf_run80.lua')).read()
    pose = []
    for m in re.finditer(r'\{ BY=(\d+), L=(\d+), arch=(-?\d+), tilt=(-?\d+), S=\{(\d+),(\d+)\}, H=\{(\d+),(\d+)\}, head=\{(\d+),(\d+)\}, ear=\{(-?\d+),(-?\d+)\}', s):
        v = list(map(int, m.groups())); pose.append(dict(BY=v[0], L=v[1], arch=v[2], tilt=v[3], Sy=v[5], Hy=v[7], hy=v[9]))
    legs = []
    for m in re.finditer(r'\{ nf=\{(\d+),(\d+)\}, ff=\{(\d+),(\d+)\}, nh=\{\{(\d+),(\d+)\},\{(\d+),(\d+)\}\}, fh=\{\{(\d+),(\d+)\},\{(\d+),(\d+)\}\} \}', s):
        v = list(map(int, m.groups()))
        legs.append(dict(nf=(v[0], v[1]), ff=(v[2], v[3]), nh=[(v[4], v[5]), (v[6], v[7])], fh=[(v[8], v[9]), (v[10], v[11])]))
    tdy = [list(map(int, m.groups())) for m in re.finditer(r'tdy=\{(-?\d+),(-?\d+),(-?\d+)\}', s)]
    assert len(pose) == NF and len(legs) == NF and len(tdy) == NF, (len(pose), len(legs), len(tdy))
    for p, t in zip(pose, tdy): p['tdy'] = t
    return pose, legs

def rnd(v): return int(math.floor(v + 0.5))
def ik(r, t, l1, l2, d):
    dx, dy = t[0] - r[0], t[1] - r[1]; dist = math.hypot(dx, dy)
    if dist >= l1 + l2 - 0.01 or dist < 0.01:
        return (rnd(r[0] + dx * l1 / (l1 + l2)), rnd(r[1] + dy * l1 / (l1 + l2)))
    a = (l1 * l1 - l2 * l2 + dist * dist) / (2 * dist); h = math.sqrt(max(0, l1 * l1 - a * a))
    ux, uy = dx / dist, dy / dist; mx, my = r[0] + ux * a, r[1] + uy * a
    p1 = (mx - uy * h, my + ux * h); p2 = (mx + uy * h, my - ux * h)
    pk = p1 if (p1[0] - p2[0]) * d >= 0 else p2
    return (rnd(pk[0]), rnd(pk[1]))

def geometry(f, P, Lg):
    BY, L = P['BY'], P['L']; rear, front = BX - L // 2, BX + L // 2
    ts = 1 if P['tilt'] >= 3 else (-1 if P['tilt'] <= -3 else 0)
    S = (front - 5, P['Sy']); H = (rear + 5, P['Hy']); Sf = (S[0] - 1, S[1] - 1); Hf = (H[0] + 1, H[1] - 1)
    g = dict(BY=BY, L=L, rear=rear, front=front, ts=ts, S=S, H=H, hx=S[0] + 9, hy=P['hy'], arch=P['arch'])
    nfE = ik(S, Lg['nf'], 7, 7, -1); ffE = ik(Sf, Lg['ff'], 7, 7, -1)
    nhK = ik(H, Lg['nh'][0], 7, 7, 1); fhK = ik(Hf, Lg['fh'][0], 7, 7, 1)
    g['chains'] = {'fn': [S, nfE, Lg['nf']], 'ff': [Sf, ffE, Lg['ff']],
                   'hn': [H, nhK, Lg['nh'][0], Lg['nh'][1]], 'hf': [Hf, fhK, Lg['fh'][0], Lg['fh'][1]]}
    g['paws'] = {'fn': Lg['nf'], 'ff': Lg['ff'], 'hn': Lg['nh'][1], 'hf': Lg['fh'][1]}
    R0 = (rear + 6, BY - 6); off = [(0, 0), (-4, -2), (-8, -2), (-11, -1), (-13, -4)]
    tp = []
    for i, o in enumerate(off):
        dy = P['tdy'][i - 2] if i >= 2 else 0
        tp.append((R0[0] + o[0], R0[1] + o[1] + dy))
    g['tail'] = tp
    return g

def chain_proj(chain, x, y):
    """-> (distance to chain, arc length from root of the nearest point, signed side, total length)"""
    best = None; acc = 0.0; tot = sum(math.hypot(chain[i + 1][0] - chain[i][0], chain[i + 1][1] - chain[i][1]) for i in range(len(chain) - 1))
    for i in range(len(chain) - 1):
        ax, ay = chain[i]; bx, by = chain[i + 1]; dx, dy = bx - ax, by - ay; l2 = dx * dx + dy * dy
        sl = math.sqrt(l2)
        t = 0 if l2 == 0 else max(0, min(1, ((x - ax) * dx + (y - ay) * dy) / l2))
        px, py = ax + t * dx, ay + t * dy
        d = math.hypot(x - px, y - py)
        if best is None or d < best[0]:
            side = ((x - ax) * dy - (y - ay) * dx)
            best = (d, acc + t * sl, 1 if side > 0 else -1)
        acc += sl
    return best[0], best[1], best[2], tot

def spine_y(g, x):
    A = (g['rear'] + 7, g['BY'] - 2 * g['ts']); M = (BX, g['BY'] + g['arch']); B = (g['front'] - 7, g['BY'] + 2 * g['ts'])
    if x <= A[0]: return A[1]
    if x >= B[0]: return B[1]
    if x <= M[0]: return A[1] + (M[1] - A[1]) * (x - A[0]) / (M[0] - A[0])
    return M[1] + (B[1] - M[1]) * (x - M[0]) / (B[0] - M[0])

# ---------------------------------------------------------------- per-pixel part info
def classify(f, g, layers, grey):
    """dict (x,y) -> info for every pattern-eligible felt pixel"""
    hx, hy = g['hx'], g['hy']; BY = g['BY']
    S, H = g['S'], g['H']
    info = {}
    eye = (hx + 3, hx + 9, hy - 4, hy + 2)
    for y in range(H_):
        for x in range(W_):
            if grey[y, x, 3] == 0: continue
            hexs = '%02x%02x%02x' % tuple(grey[y, x, :3])
            if hexs not in GREYS: continue
            if eye[0] <= x <= eye[1] and eye[2] <= y <= eye[3]: continue
            lay = None
            for n in ('head+face', 'ears', 'tail', 'legs-near', 'legs-far', 'body'):
                if layers[n][f][y, x]: lay = n; break
            if lay is None: continue
            d = dict(x=x, y=y, tone=GREYS[hexs], lay=lay)
            if lay == 'head+face':
                d.update(part='head', lx=x - hx, ly=y - hy)
            elif lay == 'ears':
                d.update(part='ear', lx=x - hx, ly=y - hy)
            elif lay == 'tail':
                dist, arc, side, tot = chain_proj(g['tail'], x, y)
                d.update(part='tail', arc=arc, side=side, tot=tot)
            elif lay == 'body':
                if ((x - (H[0] - 1)) / 7.5) ** 2 + ((y - (H[1] - 4)) / 7.0) ** 2 <= 1.15:
                    d.update(part='haunch', lx=x - (H[0] - 1), ly=y - (H[1] - 4))
                elif ((x - (S[0] + 1)) / 6.0) ** 2 + ((y - (S[1] - 5)) / 6.5) ** 2 <= 1.15 and x >= S[0] - 3:
                    d.update(part='chest', lx=x - (S[0] + 1), ly=y - (S[1] - 5))
                else:
                    d.update(part='body', u=x - BX, v=y - spine_y(g, x))
            else:
                keys = ('fn', 'hn') if lay == 'legs-near' else ('ff', 'hf')
                # paw?
                paw = None
                for k in keys:
                    cx, cy = g['paws'][k]
                    if ((x - (cx + .5)) / 4.6) ** 2 + ((y - cy) / 3.0) ** 2 <= 1.0 and y >= cy - 1: paw = (k, cx, cy)
                if paw:
                    d.update(part='paw', lx=x - paw[1], ly=y - paw[2], leg=paw[0])
                else:
                    bd = min(((chain_proj(g['chains'][k], x, y), k) for k in keys), key=lambda t: t[0][0])
                    (dist, arc, side, tot), k = bd
                    d.update(part='leg', leg=k, arc=arc, side=side, tot=tot)
                d['far'] = lay == 'legs-far'
            info[(x, y)] = d
    return info

# ---------------------------------------------------------------- patterns  (return a role or None)
def in_rect(lx, ly, x0, y0, x1, y1): return x0 <= lx <= x1 and y0 <= ly <= y1

def tabby(d):
    p = d['part']
    if p == 'body':
        u, v = d['u'], d['v']
        if -8 <= v <= 3:
            for i, u0 in enumerate((-4, 1, 6)):
                xs = u0 + rnd(v * 0.3)
                if u - xs in (0, 1):
                    hi = 3 if i % 2 == 0 else 0
                    if v >= hi - 1: return 'S'
                    return 'D'
        return None
    if p == 'haunch':
        dd = math.hypot(d['lx'] + 5, d['ly'] + 1)
        if d['ly'] <= 3 and (4.5 <= dd < 6.0 or 8.5 <= dd < 10.0): return 'D' if d['ly'] < 2 else 'S'
        return None
    if p == 'chest':
        if d['ly'] in (-2, 2) and -5 <= d['lx'] <= 1: return 'D'
        return None
    if p == 'head':
        lx, ly = d['lx'], d['ly']
        if lx in (-6, -2, 2) and -9 <= ly <= -5: return 'S' if ly >= -5 else 'D'
        if ly in (2, 5) and -12 <= lx <= -6: return 'D' if lx >= -10 else 'S'
        if ly == -1 and -10 <= lx <= 1: return 'D' if lx >= -8 else 'S'
        return None
    if p == 'tail':
        a = d['arc']
        if a >= 3 and (a - 3) % 4 < 2: return 'D' if a < d['tot'] - 2 else 'S'
        return None
    if p == 'leg':
        a = d['arc']
        if 5 <= a < 6.6 or 9.5 <= a < 11: return 'D'
        return None
    return None

SPOTS = {  # part -> list of (x0, y0, w, h) rect spots in local coords; lower-right pixel becomes shade
    'body': [(-5, -5, 3, 2), (0, -6, 2, 2), (3, -2, 3, 2), (-3, 0, 2, 2), (7, -5, 2, 2)],
    'haunch': [(-6, -3, 3, 2), (-1, 0, 2, 2), (-2, -7, 2, 2)],
    'chest': [(-2, 0, 2, 2)],
    'head': [(-4, -8, 2, 2), (-9, 1, 3, 2), (-3, 4, 2, 2)],
}
def spotted(d):
    p = d['part']
    if p in SPOTS:
        lx, ly = (d['u'], d['v']) if p == 'body' else (d['lx'], d['ly'])
        for (x0, y0, w, h) in SPOTS[p]:
            if x0 <= lx < x0 + w and y0 <= ly < y0 + h:
                if (lx, ly) in ((x0, y0), (x0 + w - 1, y0 + h - 1)) and w * h >= 6: return 'S'
                return 'D'
        return None
    if p == 'tail':
        a = d['arc']
        if (a % 6) in (2, 3) and d['side'] >= 0 and a >= 2: return 'D'
        if (a % 6) in (2, 3) and d['side'] < 0 and a >= 2 and (a // 6) % 2: return 'S'
        return None
    if p == 'leg':
        if 5 <= d['arc'] < 7 and d['side'] > 0: return 'D'
        return None
    return None

def white_mask(d, calico=False):
    p = d['part']
    if p == 'head':
        lx, ly = d['lx'], d['ly']
        return (ly >= 1 and lx >= 6) or (ly >= 4 and lx >= 0)
    if p == 'chest': return d['ly'] >= -2 and d['lx'] >= -3
    if p == 'body': return d['v'] >= 4
    if p == 'paw': return True
    if p == 'leg': return d['arc'] >= d['tot'] - 4
    if p == 'tail': return d['arc'] >= d['tot'] - 5
    return False

def dark_patch(d):
    """calico: 'D' deep / 'S' shade patches, part-local"""
    p = d['part']
    if p == 'head':
        lx, ly = d['lx'], d['ly']
        if ly <= -1 and lx <= -2 and not (lx >= -3 and ly >= -3): return 'D'
        if lx <= -2 and ly <= -1: return 'D'
        if in_rect(lx, ly, -12, 1, -8, 5): return 'S'
        return None
    if p == 'ear': return 'D'
    if p == 'body':
        u, v = d['u'], d['v']
        if -4 <= u <= 3 and v <= -1 + (1 if u in (-1, 0, 1) else 0) and v >= -8: return 'D'
        if 3 < u <= 8 and -7 <= v <= 1: return 'S'
        return None
    if p == 'haunch':
        lx, ly = d['lx'], d['ly']
        if -9 <= lx <= 0 and -9 <= ly <= -1 and lx * lx + (ly + 4) ** 2 <= 30: return 'D'
        return None
    if p == 'tail':
        if d['arc'] <= 5: return 'S'
        if 6 <= d['arc'] < 9: return 'D'
        return None
    if p == 'chest':
        if d['ly'] <= -4: return 'S'
        return None
    return None
def hx_dummy(): return 99

def pointed_pts(d):
    p = d['part']
    if p == 'ear': return True
    if p == 'head': return d['lx'] >= 2 and d['ly'] >= -4
    if p == 'paw': return True
    if p == 'leg': return d['arc'] >= d['tot'] - 6
    if p == 'tail': return d['arc'] >= 3
    return False

TONE_DOWN = {'gloss': LIGHT, 'light': BASE, 'base': SHADE, 'shade': DEEP}
TONE_UP = {'gloss': GLOSS, 'light': GLOSS, 'base': LIGHT, 'shade': BASE}
def white_col(d):
    if d.get('far') and d['tone'] == 'shade': return WD
    return {'gloss': WG, 'light': WG, 'base': WF, 'shade': WS}[d['tone']]

def make_pattern(name, info):
    img = np.zeros((H_, W_, 4), np.uint8)
    def put(k, col): img[k[1], k[0], :3] = col; img[k[1], k[0], 3] = 255
    if name in ('tabby', 'spotted'):
        fn = tabby if name == 'tabby' else spotted
        for k, d in info.items():
            r = fn(d)
            if r: put(k, DEEP if r == 'D' else SHADE)
        return img
    if name in ('tuxedo', 'calico'):
        wm = {k for k, d in info.items() if white_mask(d)}
        cal = {}
        if name == 'calico':
            for k, d in info.items():
                if k in wm: continue
                r = dark_patch(d)
                if r: cal[k] = r
        for k, d in info.items():
            if k in wm:
                nb = [(k[0] + 1, k[1]), (k[0] - 1, k[1]), (k[0], k[1] + 1), (k[0], k[1] - 1)]
                if any(n in info and n not in wm for n in nb): put(k, WE)
                else: put(k, white_col(d))
            elif k in cal: put(k, DEEP if cal[k] == 'D' else SHADE)
        return img
    if name == 'pointed':
        for k, d in info.items():
            if pointed_pts(d): put(k, TONE_DOWN[d['tone']])
            elif d['part'] in ('body', 'haunch', 'chest', 'leg'): put(k, TONE_UP[d['tone']])
        return img
    raise ValueError(name)

# ---------------------------------------------------------------- outline patching (folded ears, bobtail)
def dist_to(mask, shape=(H_, W_)):
    ys, xs = np.nonzero(mask)
    gy, gx = np.mgrid[0:shape[0], 0:shape[1]]
    out = np.full(shape, 99.0); nn = np.zeros(shape + (2,), int)
    for py, px in zip(ys, xs):
        d = np.hypot(gy - py, gx - px); m = d < out
        out[m] = d[m]; nn[m] = (py, px)
    return out, nn

def band_of(a):
    op = a[..., 3] > 0
    isol = np.zeros(op.shape, bool)
    for y, x in zip(*np.nonzero(op)): isol[y, x] = tuple(a[y, x, :3]) in OLS
    seen = np.zeros(op.shape, bool); st = [(y, x) for y, x in zip(*np.nonzero(~op))]
    while st:
        y, x = st.pop()
        for dy in (-1, 0, 1):
            for dx in (-1, 0, 1):
                yy, xx = y + dy, x + dx
                if 0 <= yy < H_ and 0 <= xx < W_ and not seen[yy, xx] and isol[yy, xx]: seen[yy, xx] = True; st.append((yy, xx))
    return seen

def reoutline(grey, remove, add=None):
    """grey: RGBA frame; remove: bool mask of felt pixels to delete; add: dict (x,y)->rgb of new felt pixels.
    Returns the new RGBA frame, with the sticker outline redrawn locally."""
    band = band_of(grey); felt_old = (grey[..., 3] > 0) & ~band
    new = grey.copy()
    new[remove] = 0
    felt_new = felt_old & ~remove
    if add:
        for (x, y), c in add.items(): new[y, x, :3] = c; new[y, x, 3] = 255; felt_new[y, x] = True
    d_old, _ = dist_to(felt_old); d_new, nn = dist_to(felt_new)
    ys, xs = np.nonzero(remove | (np.abs(d_old - d_new) > 1e-6) & (d_old <= 4.13))
    y0, y1, x0, x1 = ys.min() - 1, ys.max() + 1, xs.min() - 1, xs.max() + 1
    for y in range(max(0, y0), min(H_, y1 + 1)):
        for x in range(max(0, x0), min(W_, x1 + 1)):
            if felt_new[y, x]: continue
            if d_new[y, x] > 4.13: new[y, x] = 0; continue
            if band[y, x] and abs(d_old[y, x] - d_new[y, x]) < 1e-6: continue
            ny, nx = nn[y, x]; dd = d_new[y, x]
            if dd <= 1.01: col = (0x4a, 0x2c, 0x1a) if (y <= ny and x <= nx) else (0x2a, 0x1a, 0x10)
            elif dd <= 2.25: col = (0x2a, 0x1a, 0x10)
            else: col = (0, 0, 0)
            new[y, x, :3] = col; new[y, x, 3] = 255
    return new

def components(mask):
    seen = np.zeros(mask.shape, bool); comps = []
    for y, x in zip(*np.nonzero(mask)):
        if seen[y, x]: continue
        st = [(y, x)]; seen[y, x] = True; c = []
        while st:
            a, b = st.pop(); c.append((a, b))
            for dy in (-1, 0, 1):
                for dx in (-1, 0, 1):
                    yy, xx = a + dy, b + dx
                    if 0 <= yy < H_ and 0 <= xx < W_ and mask[yy, xx] and not seen[yy, xx]: seen[yy, xx] = True; st.append((yy, xx))
        comps.append(c)
    return comps

def folded_ears(grey, emask):
    remove = np.zeros((H_, W_), bool); add = {}
    for c in components(emask):
        ys = [p[0] for p in c]; ymin, ymax = min(ys), max(ys); h = ymax - ymin + 1
        cut = ymin + int(math.ceil(h * 0.5))
        for (y, x) in c:
            if y < cut: remove[y, x] = True
        top = [(y, x) for (y, x) in c if y >= cut]
        if top:
            ty = min(p[0] for p in top)
            for (y, x) in top:                         # fold crease along the new top edge
                if y == ty: add[(x, y)] = SHADE
    return reoutline(grey, remove, add)

def bobtail(grey, tmask, g):
    pts = np.argwhere(tmask)
    mx = pts[:, 1].max(); sel = pts[pts[:, 1] >= mx - 2]
    cy, cx = sel[:, 0].mean(), sel[:, 1].mean()
    remove = np.zeros((H_, W_), bool)
    for y, x in pts:
        if math.hypot(x - (cx - 1.5), y - cy) > 5.2: remove[y, x] = True
    return reoutline(grey, remove, None)

# ---------------------------------------------------------------- io helpers
def rd(p): return np.array(Image.open(p).convert('RGBA'))
def save(a, p): Image.fromarray(a, 'RGBA').save(p, optimize=False)

def diff_layers(old, new):
    """-> (part image = new pixels that differ from old, clear mask = old opaque pixels that differ)"""
    d = (old != new).any(-1) | ((old[..., 3] > 0) != (new[..., 3] > 0))
    part = np.zeros_like(old); part[d & (new[..., 3] > 0)] = new[d & (new[..., 3] > 0)]
    clear = d & (old[..., 3] > 0)
    return part, clear

def recolor_arr(a, cmap):
    out, unm = R.recolor(Image.fromarray(a, 'RGBA'), cmap)
    return out, unm

def over(dst, src):
    o = src[..., 3] > 0; dst[o] = src[o]

def compose(body, parts, pat, eye, clears):
    img = body.copy(); p = pat.copy() if pat is not None else None
    for cl in clears:
        img[cl] = 0
        if p is not None: p[cl] = 0
    for pt in parts: over(img, pt)
    if p is not None: over(img, p)
    if eye is not None: over(img, eye)
    return img

def main():
    os.makedirs(VIEW, exist_ok=True)
    layers = load_layers(); pose, legs = parse_lua()
    base_tones = {k: v[0] for k, v in R.load(os.path.join(R.CF, 'tones.json'), True).items()}
    overlays = R.load(os.path.join(R.CF, 'tones_overlays.json'))
    greys = [rd(os.path.join(OUT80, 'cf-cat-grey-run%02d.png' % (f + 1))) for f in range(NF)]
    emasks = [rd(os.path.join(OUT80, 'cf-ears-mask-run%02d.png' % (f + 1)))[..., 3] > 0 for f in range(NF)]
    tmasks = [rd(os.path.join(OUT80, 'cf-tail-mask-run%02d.png' % (f + 1)))[..., 3] > 0 for f in range(NF)]
    geo = [geometry(f, pose[f], legs[f]) for f in range(NF)]
    # grey-space layers
    pats = {n: [] for n in R.PATTERNS}; ears = []; tails = []; eyes = []; eclear = []; tclear = []
    for f in range(NF):
        info = classify(f, geo[f], layers, greys[f])
        for n in R.PATTERNS: pats[n].append(make_pattern(n, info))
        fe = folded_ears(greys[f], emasks[f]); bt = bobtail(greys[f], tmasks[f], geo[f])
        p, c = diff_layers(greys[f], fe); ears.append(p); eclear.append(c)
        p, c = diff_layers(greys[f], bt); tails.append(p); tclear.append(c)
        hx, hy = geo[f]['hx'], geo[f]['hy']
        e = np.zeros((H_, W_, 4), np.uint8)
        for y in range(hy - 4, hy + 3):
            for x in range(hx + 3, hx + 10):
                if tuple(greys[f][y, x, :3]) == EYECREAM and greys[f][y, x, 3]: e[y, x] = (*EYECREAM, 255)
        eyes.append(e)
    n = 0
    for f in range(NF):
        for nm, cl in (('ears', eclear[f]), ('tail', tclear[f])):
            a = np.zeros((H_, W_, 4), np.uint8); a[cl] = (255, 255, 255, 255)
            save(a, os.path.join(OUT, 'cf-%s-clear-run%02d.png' % (nm, f + 1))); n += 1
        for ey, col in R.EYES.items():
            a = eyes[f].copy(); a[a[..., 3] > 0, :3] = R.h2rgb(col)
            save(a, os.path.join(OUT, 'cf-eyes-%s-run%02d.png' % (ey, f + 1))); n += 1
    problems = []; allowed_sets = {}; cmaps = {}
    for coat in R.COATS:
        cmap = R.build_map(coat, base_tones, overlays, None); cmaps[coat] = cmap
        allowed = set(cmap.values()) | set(R.FIXED) | set(R.EYES.values())
        allowed_sets[coat] = allowed
        for f in range(NF):
            tag = 'run%02d' % (f + 1)
            outs = [('cf-cat-%s-%s.png' % (coat, tag), greys[f]),
                    ('cf-ears-folded-%s-%s.png' % (coat, tag), ears[f]), ('cf-tail-bobtail-%s-%s.png' % (coat, tag), tails[f])]
            outs += [('cf-pat-%s-%s-%s.png' % (p, coat, tag), pats[p][f]) for p in R.PATTERNS]
            for name, arr in outs:
                o, unm = recolor_arr(arr, cmap)
                if unm: problems.append('%s unmapped %s' % (name, unm))
                al = np.unique(o[..., 3])
                if any(v not in (0, 255) for v in al): problems.append(name + ' semi alpha')
                op = o[o[..., 3] > 0][:, :3]
                for c in np.unique(op, axis=0) if len(op) else []:
                    if R.hex_(c) not in allowed: problems.append('%s colour %s outside ramp' % (name, R.hex_(c)))
                if o.shape != (64, 80, 4): problems.append(name + ' size')
                save(o, os.path.join(OUT, name)); n += 1
    # pattern containment: every overlay pixel lies on opaque felt of the body (not outline)
    for f in range(NF):
        band = band_of(greys[f])
        for p in R.PATTERNS:
            m = pats[p][f][..., 3] > 0
            if (m & ((greys[f][..., 3] == 0) | band)).any(): problems.append('pattern %s run%02d bleeds outside silhouette' % (p, f + 1))
    # views
    def tile(arrs, scale=2):
        im = Image.new('RGBA', (W_ * len(arrs), H_), (245, 236, 215, 255))
        for i, a in enumerate(arrs): im.alpha_composite(Image.fromarray(a, 'RGBA'), (i * W_, 0))
        return im.resize((im.width * scale, im.height * scale), Image.NEAREST) if scale != 1 else im
    def loadc(coat, kind, f): return rd(os.path.join(OUT, kind % (coat, 'run%02d' % (f + 1))))
    eyeamber = lambda f: rd(os.path.join(OUT, 'cf-eyes-amber-run%02d.png' % (f + 1)))
    def row(coat, pat=None, fold=False, bob=False):
        r = []
        for f in range(NF):
            body = loadc(coat, 'cf-cat-%s-%s.png', f); parts = []; clears = []
            if fold: parts.append(loadc(coat, 'cf-ears-folded-%s-%s.png', f)); clears.append(eclear[f])
            if bob: parts.append(loadc(coat, 'cf-tail-bobtail-%s-%s.png', f)); clears.append(tclear[f])
            pt = rd(os.path.join(OUT, 'cf-pat-%s-%s-run%02d.png' % (pat, coat, f + 1))) if pat else None
            r.append(compose(body, parts, pt, eyeamber(f), clears))
        return r
    for coat in R.COATS:
        rows = [row(coat)] + [row(coat, p) for p in R.PATTERNS] + [row(coat, 'tabby', True, True)]
        sheets = [tile(r, 2) for r in rows]
        big = Image.new('RGBA', (sheets[0].width, sum(s.height for s in sheets)))
        yy = 0
        for s in sheets: big.paste(s, (0, yy)); yy += s.height
        big.save(os.path.join(VIEW, 'coat-%s.png' % coat))
        tile([loadc(coat, 'cf-cat-%s-%s.png', f) for f in range(NF)], 2).save(os.path.join(VIEW, 'strip-%s.png' % coat))
    rows = []
    for coat in R.COATS:
        rows.append(tile(row(coat, 'tabby'), 1)); rows.append(tile(row(coat, 'calico'), 1))
    big = Image.new('RGBA', (rows[0].width, H_ * len(rows)))
    for i, r_ in enumerate(rows): big.paste(r_, (0, i * H_))
    big.save(os.path.join(VIEW, 'all-coats-tabby-calico.png'))
    # parse-check of the frame-to-frame behaviour is visual; report
    print('wrote %d PNG files to %s' % (n, OUT))
    for p in problems[:40]: print('PROBLEM', p)
    print('checks:', 'FAILED (%d)' % len(problems) if problems else 'ok (alpha 0/255, colours in coat ramps + fixed accents, patterns inside silhouette)')
    return 1 if problems else 0

if __name__ == '__main__':
    sys.exit(main())
