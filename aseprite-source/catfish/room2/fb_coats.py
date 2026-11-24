#!/usr/bin/env python3
"""fb_coats.py: recolour the RUN-TOWARD / RUN-AWAY cycles (64x64, 8 frames each) for all 8 coats, with procedural pattern
overlays (face markings toward, back markings away), folded ears, bobtail and eye-colour overlays (toward only).
Adapted from run80_coats.py / zoom_coats.py (copied, not imported).  Writes ONLY to out_fb/coats/ (+ _view/).
Run:  python3 -I aseprite-source/catfish/room2/fb_coats.py
Inputs: out_fb/cf-cat-grey-run{toward,away}01..08.png, cf-ears-mask-*, cf-tail-mask-*, cf-run{toward,away}-grey.aseprite (layers),
        pose tables parsed from cf_run_fb.lua.
Outputs (pose = run<view>NN, view = toward|away):
  cf-cat-<coat>-run<view>NN.png               body (palette swap by tools/catfish_recolor.py)
  cf-pat-<pattern>-<coat>-run<view>NN[-fold].png   tabby tuxedo calico pointed spotted (overlay, hard alpha); -fold = for folded ears
  cf-ears-folded-<coat>-run<view>NN.png / cf-tail-bobtail-<coat>-run<view>NN.png   replacement parts incl. outline
  cf-ears-clear-run<view>NN.png / cf-tail-clear-run<view>NN.png   pixels to ERASE from body+pattern before drawing the part
  cf-eyes-<amber|green|blue|hazel>-runtowardNN.png   iris overlay (toward only; the back view shows no eyes)
Compose: body, erase clear mask(s), part(s), pattern, eyes.
"""
import os, re, sys, struct, zlib, math, collections
sys.dont_write_bytecode = True
import numpy as np
from PIL import Image
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '..', '..', '..'))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
import catfish_recolor as R

SRC = os.path.join(HERE, 'out_fb')
OUT = os.path.join(SRC, 'coats')
VIEW = os.path.join(OUT, '_view')
NF = 8
H_, W_ = 64, 64
VIEWS = ('toward', 'away')
GREYS = {'57516f': 'shade', '8a859b': 'base', 'cdc9d3': 'light', 'f1ebe3': 'gloss'}
OLS = {(0x2a, 0x1a, 0x10), (0x4a, 0x2c, 0x1a), (0x74, 0x46, 0x2a), (0, 0, 0)}
def hx_(h): return tuple(int(h[i:i + 2], 16) for i in (0, 2, 4))
DEEP, SHADE, BASE, LIGHT, GLOSS = map(hx_, ('3d3654', '57516f', '8a859b', 'cdc9d3', 'f1ebe3'))
WG, WF, WS, WD, WE = map(hx_, ('fbf6ec', 'e6dfd2', 'bab0c0', '8d829a', '463e5e'))
EYECREAM = (0xf2, 0xe4, 0xc0)
KT, KA = 0.85, 0.72
HAU = ["....#####....", "..#########..", ".###########.", ".###########.", "#############", "#############", "#############",
       "#############", "#############", ".###########.", ".###########.", "..#########..", "...#######..."]
PAWM = {'S': (9, 5), 'M': (11, 6), 'L': (13, 7)}        # width, height of the fore-paw masks

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

def load_layers(view):
    layers, cels = parse_ase(os.path.join(SRC, 'cf-run%s-grey.aseprite' % view))
    out = {}
    for li, name in enumerate(layers):
        lst = []
        for (x, y, w, h, raw) in [cels[li][k] for k in sorted(cels[li])][:NF]:
            a = np.frombuffer(raw, np.uint8).reshape(h, w, 4)
            m = np.zeros((H_, W_), bool)
            y0, x0 = max(0, y), max(0, x); m[y0:y + h, x0:x + w] = (a[..., 3] > 0)[y0 - y:, x0 - x:][:H_ - y0, :W_ - x0]
            lst.append(m)
        out[name] = lst
    return out

def ints(s): return list(map(int, re.findall(r'-?\d+', s)))
def parse_lua():
    s = open(os.path.join(HERE, 'cf_run_fb.lua')).read()
    TW = [dict(fore=(int(m.group(1)), int(m.group(2))), size=m.group(3), hind=(int(m.group(4)), int(m.group(5))), tx=int(m.group(6)), ty=int(m.group(7)))
          for m in re.finditer(r'\{ fore=\{(\d+),(\d+),"(\w)"\}, hind=\{(\d+),(\d+)\}, tx=\s*(-?\d+), ty=\s*(-?\d+) \}', s)]
    AW = [dict(hind=(int(m.group(1)), int(m.group(2)), float(m.group(3)), float(m.group(4)), m.group(5)), fore=(int(m.group(6)), int(m.group(7))),
               s=(int(m.group(8)), int(m.group(9))), ty=int(m.group(10)))
          for m in re.finditer(r'\{ hind=\{(\d+),(\d+),([\d.]+),([\d.]+),"(\w)"\},\s*fore=\{(\d+),(\d+)\}, s=\{(-?\d+),(-?\d+)\}, ty=\s*(-?\d+) \}', s)]
    SH = []
    for m in re.finditer(r'\{ BY=(\d+), sq=\s*(-?\d+), hd=\{\s*(-?\d+),\s*(-?\d+)\}, eL=\{\s*(-?\d+),\s*(-?\d+)\}, eR=\{\s*(-?\d+),\s*(-?\d+)\} \}', s):
        v = list(map(int, m.groups())); SH.append(dict(BY=v[0], sq=v[1], hd=(v[2], v[3]), eL=(v[4], v[5]), eR=(v[6], v[7])))
    assert len(SH) == NF and len(TW) == NF and len(AW) == NF, (len(SH), len(TW), len(AW))
    return SH, TW, AW

def rnd(v): return int(math.floor(v + 0.5))
def mirq(q): return (64 - q[0],) + tuple(q[1:])

# ---------------------------------------------------------------- geometry
def chain_proj(chain, x, y):
    """-> (dist to chain, arc length from root of the nearest point, side, total length)"""
    best = None; acc = 0.0
    tot = sum(math.hypot(chain[i + 1][0] - chain[i][0], chain[i + 1][1] - chain[i][1]) for i in range(len(chain) - 1))
    for i in range(len(chain) - 1):
        ax, ay = chain[i]; bx, by = chain[i + 1]; dx, dy = bx - ax, by - ay; l2 = dx * dx + dy * dy
        sl = math.sqrt(l2)
        t = 0 if l2 == 0 else max(0, min(1, ((x - ax) * dx + (y - ay) * dy) / l2))
        px, py = ax + t * dx, ay + t * dy
        d = math.hypot(x - px, y - py)
        if best is None or d < best[0]:
            best = (d, acc + t * sl, 1 if ((x - ax) * dy - (y - ay) * dx) > 0 else -1)
        acc += sl
    return best[0], best[1], best[2], tot

def chain_pt(chain, arc):
    acc = 0.0
    for i in range(len(chain) - 1):
        sl = math.hypot(chain[i + 1][0] - chain[i][0], chain[i + 1][1] - chain[i][1])
        if acc + sl >= arc or i == len(chain) - 2:
            t = min(1, max(0, (arc - acc) / sl)); return (chain[i][0] + t * (chain[i + 1][0] - chain[i][0]), chain[i][1] + t * (chain[i + 1][1] - chain[i][1]))
        acc += sl

def geom_toward(S, T, Tprev):
    BY = S['BY']; hx = 32 + S['hd'][0]; hcy = 28 + S['hd'][1]
    Tx, Ty = 51 + T['tx'], BY - 14 + T['ty']
    foreL = T['fore']; foreR = mirq(Tprev['fore']); hindL = T['hind']; hindR = mirq(Tprev['hind'])
    sizeL, sizeR = T['size'], Tprev['size']
    return dict(BY=BY, hx=hx, hcy=hcy, ear=(S['eL'], S['eR']), tail=[(41, BY - 7), (46, BY - 10), (Tx, Ty)],
                fore=[(foreL, sizeL, 'L'), (foreR, sizeR, 'R')], hind=[hindL, hindR], sq=S['sq'],
                chains={'fl': [(26, BY - 1), (foreL[0], foreL[1] - 1)], 'fr': [(38, BY - 1), (foreR[0], foreR[1] - 1)]})

def geom_away(S, T, Tprev):
    BY = S['BY']; hx = 32 + S['hd'][0]; hcy = 23 + S['hd'][1]
    hindL = T['hind']; hindR = mirq(Tprev['hind']); foreL = T['fore']; foreR = (64 - Tprev['fore'][0], Tprev['fore'][1])
    tp = [(32, BY - 4), (32, BY - 10), (35, BY - 14), (42 + T['s'][0], BY - 18 + T['ty']), (46 + T['s'][1], BY - 23 + T['ty'])]
    return dict(BY=BY, hx=hx, hcy=hcy, sq=S['sq'], ear=(S['eL'], S['eR']), tail=tp, hind=[hindL, hindR], fore=[foreL, foreR],
                chains={'hl': [(24, BY + 4), (hindL[0], hindL[1])], 'hr': [(40, BY + 4), (hindR[0], hindR[1])],
                        'fl': [(23, BY - 6), foreL], 'fr': [(41, BY - 6), foreR]})

def in_ell(x, y, cx, cy, rx, ry): return ((x - cx) / rx) ** 2 + ((y - cy) / ry) ** 2 <= 1.0

# ---------------------------------------------------------------- per-pixel part info
def classify(view, f, g, layers, grey):
    BY, hx, hcy = g['BY'], g['hx'], g['hcy']
    pts = np.argwhere(layers['head+face'][f])
    info = {}
    for y in range(H_):
        for x in range(W_):
            if grey[y, x, 3] == 0: continue
            hexs = '%02x%02x%02x' % tuple(grey[y, x, :3])
            if hexs not in GREYS: continue
            lay = None
            for n in ('head+face', 'ears', 'tail', 'legs-near', 'legs-far', 'body'):
                if layers[n][f][y, x]: lay = n; break
            if lay is None: continue
            d = dict(x=x, y=y, tone=GREYS[hexs], lay=lay)
            if lay == 'head+face':
                d.update(part='head', lx=x - hx, ly=y - hcy)
                if view == 'toward' and (abs(abs(x - hx) - 9.9) <= 4.4 and -5.5 <= (y - hcy) <= 3.5 or (abs(x - hx) <= 3 and 2 <= y - hcy <= 7)):
                    d['face'] = True                      # eye rings / nose: keep dark patterns off
            elif lay == 'ears':
                d.update(part='ear', lx=x - hx, ly=y - hcy)
            elif lay == 'tail':
                dist, arc, side, tot = chain_proj(g['tail'], x, y)
                d.update(part='tail', arc=arc, side=side, tot=tot)
            elif view == 'toward':
                if lay == 'body':
                    if in_ell(x, y, 21, BY - 3, 4.6, 4.6) and not in_ell(x, y, 32, BY - 3, 10 + g['sq'], 7 - g['sq']): d.update(part='flank', lx=x - 21, ly=y - (BY - 3), side=-1)
                    elif in_ell(x, y, 43, BY - 3, 4.6, 4.6) and not in_ell(x, y, 32, BY - 3, 10 + g['sq'], 7 - g['sq']): d.update(part='flank', lx=x - 43, ly=y - (BY - 3), side=1)
                    else: d.update(part='chest', lx=x - 32, ly=y - (hcy + 9))
                elif lay == 'legs-near':
                    paw = None
                    for (q, sz, sd) in g['fore']:
                        w, h = PAWM[sz]
                        if abs(x - q[0]) <= w // 2 and y >= q[1] + 2 - (h - 1): paw = (q, sd)
                    if paw: d.update(part='paw', lx=x - paw[0][0], ly=y - paw[0][1], near=True)
                    else:
                        bd = min((chain_proj(g['chains'][k], x, y), k) for k in ('fl', 'fr'))
                        (dist, arc, side, tot), k = bd; d.update(part='leg', arc=arc, side=side, tot=tot, k=k)
                else:                                     # legs-far: belly + hind paws
                    hp = [q for q in g['hind'] if abs(x - q[0]) <= 4.5 and abs(y - q[1]) <= 3]
                    if hp: d.update(part='paw', lx=x - hp[0][0], ly=y - hp[0][1], far=True)
                    else: d.update(part='belly', lx=x - 32, ly=y - (BY + 5), far=True)
            else:                                         # away
                if lay == 'body':
                    hau = None
                    for side, cx in (('L', 25), ('R', 39)):
                        cy = BY + 1 + g['hd'][side]
                        r, c = y - (cy - 6), x - (cx - 6)
                        if 0 <= r < 13 and 0 <= c < 13 and HAU[r][c] == '#': hau = (side, cx, cy)
                    if hau:
                        sg = 1 if hau[0] == 'L' else -1
                        d.update(part='haunch', lx=(x - hau[1]) * sg, ly=y - hau[2], side=hau[0])
                    else:
                        d.update(part='body', lx=x - 32, ly=y - BY)
                elif lay == 'legs-near':
                    paw = None
                    for key, q in (('hl', g['hind'][0]), ('hr', g['hind'][1])):
                        if q[4] != 'u' and in_ell(x, y, q[0], q[1], q[2] + 1.0, q[3] + 1.2): paw = q
                    if paw: d.update(part='paw', lx=x - paw[0], ly=y - paw[1], near=True)
                    else:
                        cand = [(chain_proj(g['chains'][k], x, y), k) for k, q in (('hl', g['hind'][0]), ('hr', g['hind'][1])) if q[4] != 'u']
                        (dist, arc, side, tot), k = min(cand) if cand else ((0, 0, 1, 1), 'hl')
                        d.update(part='leg', arc=arc, side=side, tot=tot, k=k)
                else:
                    pu = [q for q in g['hind'] if q[4] == 'u' and in_ell(x, y, q[0], q[1], q[2] + 1.0, q[3] + 1.2)]
                    if pu: d.update(part='paw', lx=x - pu[0][0], ly=y - pu[0][1], far=True)
                    else:
                        (dist, arc, side, tot), k = min((chain_proj(g['chains'][k], x, y), k) for k in ('fl', 'fr'))
                        if tot - arc <= 2.6: d.update(part='paw', lx=0, ly=0, far=True)
                        else: d.update(part='leg', arc=arc, side=side, tot=tot, k=k, far=True)
            if 'part' not in d: continue
            info[(x, y)] = d
    return info

# ---------------------------------------------------------------- patterns  (return a role D / S or None)
def grid(lx0, rows):
    out = {}
    for ly, s in rows.items():
        for i, ch in enumerate(s):
            if ch != '.': out[(lx0 + i, ly)] = ch
    return out
def shp(sh, x0, y0, lx, ly):
    r, c = ly - y0, lx - x0
    if 0 <= r < len(sh) and 0 <= c < len(sh[0]): return {'D': 'D', 'S': 'S'}.get(sh[r][c])
    return None
SA = ('.DD', 'DDS'); SB = ('DD.', 'DSD', '.D.'); SC = ('DD', 'DS')
def ell(lx, ly, cx, cy, rx, ry): return ((lx - cx) / rx) ** 2 + ((ly - cy) / ry) ** 2

def tab_arc(d, a0=3, per=4, w=2, tip=True):
    a = d['arc']
    if a >= a0 and (a - a0) % per < w: return 'D' if (not tip or a < d['tot'] - 2) else 'S'
    return None

def tabby_t(d):
    p = d['part']; lx, ly = d['lx'] if 'lx' in d else 0, d['ly'] if 'ly' in d else 0
    if p == 'head':
        if d.get('face'): return None
        for l0, top in ((-4, -7), (0, -8), (4, -7)):
            if lx == l0 and top <= ly <= -5: return 'D' if ly <= top + 1 else 'S'
        if abs(lx) in (-0, 1): pass
        if ly in (4, 6) and 10 <= abs(lx) <= 13 - (ly == 6): return 'S'
        return None
    if p == 'chest':
        for by_, x0, x1 in ((2, 3, 8),):
            if ly == by_ and x0 <= abs(lx) <= x1: return 'D'
        return None
    if p == 'flank': return 'D' if ly in (-1, 2) and -1 <= lx <= 2 else None
    if p == 'tail': return tab_arc(d, 3, 4, 2)
    if p == 'leg': return 'D' if (3 <= d['arc'] < 4.6 or 7 <= d['arc'] < 8.6) else None
    return None

def tabby_a(d):
    p = d['part']; lx, ly = d.get('lx', 0), d.get('ly', 0)
    if p == 'head':
        for l0, top, bot in ((-5, -6, -2), (0, -6, 0), (5, -6, -2)):
            if lx == l0 and top <= ly <= bot: return 'D' if ly <= top + 1 else 'S'
        if abs(lx) == 8 and -4 <= ly <= -1: return 'S'
        if abs(lx) in (3, 7) and ly == 1: return 'S'
        return None
    if p == 'body':
        for by_, x0, x1 in ((-15, 2, 5), (-12, 2, 6)):
            if ly == by_ and x0 <= abs(lx) <= x1: return 'D'
            if ly == by_ + 1 and x0 + 1 <= abs(lx) <= x1 - 1: return 'S'
        return None
    if p == 'haunch':
        if ly in (-4, -2) and -5 <= lx <= -1: return 'D' if ly == -4 else 'S'
        return None
    if p == 'tail': return tab_arc(d, 3, 4, 2)
    if p == 'leg': return 'D' if (3 <= d['arc'] < 4.6 or 7 <= d['arc'] < 8.6) else None
    return None

SPOT_HEAD_T = [(SC, -2, -8), (SC, -9, -6), (SC, 7, -7), (SC, -12, 5), (SC, 10, 6), (SC, -5, -6), (SC, 4, -5), (SC, -12, 0), (SC, 11, 1), (SC, -8, 7), (SC, 7, 7)]
SPOT_CHEST = [(('DD',), -7, 2), (('DD',), 5, 2)]
def spotted_t(d):
    p = d['part']; lx, ly = d.get('lx', 0), d.get('ly', 0)
    if p == 'head':
        if d.get('face'): return None
        for sh, x0, y0 in SPOT_HEAD_T:
            r = shp(sh, x0, y0, lx, ly)
            if r: return r
        return None
    if p == 'chest':
        for sh, x0, y0 in SPOT_CHEST:
            r = shp(sh, x0, y0, lx, ly)
            if r: return r
        return None
    if p == 'flank': return shp(SC, -1, -2, lx, ly)
    if p == 'tail':
        a = d['arc']
        if (a % 6) in (2, 3) and d['side'] >= 0 and a >= 2: return 'D'
        return None
    if p == 'leg': return 'D' if (4 <= d['arc'] < 6 and d['side'] > 0) else None
    return None

SPOT_HEAD_A = [(SC, -7, -6), (SC, 3, -5), (SC, -2, -2), (SC, 7, -1)]
SPOT_BODY_A = [(SA, -6, -15), (SB, 3, -14), (SA, -9, -11), (SA, 5, -11)]
def spotted_a(d):
    p = d['part']; lx, ly = d.get('lx', 0), d.get('ly', 0)
    if p == 'head':
        for sh, x0, y0 in SPOT_HEAD_A:
            r = shp(sh, x0, y0, lx, ly)
            if r: return r
        return None
    if p == 'body':
        for sh, x0, y0 in SPOT_BODY_A:
            r = shp(sh, x0, y0, lx, ly)
            if r: return r
        return None
    if p == 'haunch': return shp(SC, -5, -4, lx, ly)
    if p == 'tail':
        a = d['arc']
        if (a % 6) in (2, 3) and d['side'] >= 0 and a >= 2: return 'D'
        return None
    if p == 'leg': return 'D' if (4 <= d['arc'] < 6 and d['side'] > 0) else None
    return None

def white_t(d, calico=False):
    p = d['part']; lx, ly = d.get('lx', 0), d.get('ly', 0)
    if p == 'head': return ell(lx, ly, 0, 6.5, 7.5, 4.5) <= 1 or (abs(lx) <= 1 and -8 <= ly <= 3 and not calico) or (calico and abs(lx) <= 0 and -6 <= ly <= 4)
    if p == 'chest': return abs(lx) <= 3 and 0 <= ly <= 3
    if p == 'paw': return True
    if p == 'leg': return d['arc'] >= d['tot'] - 4
    if p == 'tail': return d['arc'] >= d['tot'] - 5
    return False
def white_a(d, calico=False):
    p = d['part']; lx, ly = d.get('lx', 0), d.get('ly', 0)
    if p == 'paw': return True
    if p == 'leg': return d['arc'] >= d['tot'] - 4
    if p == 'tail': return d['arc'] >= d['tot'] - 5
    return False

def cal_t(d):
    p = d['part']; lx, ly = d.get('lx', 0), d.get('ly', 0)
    if p == 'head':
        if d.get('face'): return None
        if ell(lx, ly, -6, -5, 6.5, 3.6) <= 1: return 'D'
        if ell(lx, ly, 9, 4.5, 3.6, 3) <= 1: return 'S'
        return None
    if p == 'ear': return 'D' if lx < 0 else None
    if p == 'chest':
        if ell(lx, ly, -5, 2.5, 4.5, 2) <= 1: return 'D'
        if ell(lx, ly, 6, 2, 3, 1.5) <= 1: return 'S'
        return None
    if p == 'flank': return 'S' if d['side'] > 0 else 'D'
    if p == 'tail': return 'S' if d['arc'] <= 5 else ('D' if d['arc'] < 9 else None)
    return None
def cal_a(d):
    p = d['part']; lx, ly = d.get('lx', 0), d.get('ly', 0)
    if p == 'head':
        if ell(lx, ly, -4, -4, 6.5, 3.8) <= 1: return 'D'
        return None
    if p == 'ear': return 'D' if lx < 0 else None
    if p == 'body':
        if ell(lx, ly, -8, -12, 5.5, 3.6) <= 1: return 'D'
        if ell(lx, ly, 8, -11, 3.4, 2.6) <= 1: return 'S'
        return None
    if p == 'haunch': return 'D' if (d['side'] == 'L' and ell(lx, ly, -2, -3, 3.5, 2) <= 1) else None
    if p == 'tail': return 'S' if d['arc'] <= 5 else ('D' if d['arc'] < 9 else None)
    return None

def point_t(d):
    p = d['part']; lx, ly = d.get('lx', 0), d.get('ly', 0)
    if p == 'ear': return True
    if p == 'head': return ell(lx, ly, 0, 4, 8.5, 5.5) <= 1
    if p == 'paw': return True
    if p == 'leg': return d['arc'] >= d['tot'] - 5
    if p == 'tail': return d['arc'] >= 3
    return False
def point_a(d):
    p = d['part']
    if p == 'ear': return True
    if p == 'head': return d['ly'] <= -2 and abs(d['lx']) <= 8
    if p == 'paw': return True
    if p == 'leg': return d['arc'] >= d['tot'] - 5
    if p == 'tail': return d['arc'] >= 3
    return False

TONE_DOWN = {'gloss': LIGHT, 'light': BASE, 'base': SHADE, 'shade': DEEP, 'deep': DEEP}
TONE_UP = {'gloss': GLOSS, 'light': GLOSS, 'base': LIGHT, 'shade': BASE, 'deep': SHADE}
def white_col(d):
    if d.get('far') and d['tone'] == 'shade': return WD
    return {'gloss': WG, 'light': WG, 'base': WF, 'shade': WS}[d['tone']]

def make_pattern(view, name, info):
    img = np.zeros((H_, W_, 4), np.uint8)
    T = view == 'toward'
    def put(k, col): img[k[1], k[0], :3] = col; img[k[1], k[0], 3] = 255
    if name in ('tabby', 'spotted'):
        fn = {('tabby', 1): tabby_t, ('tabby', 0): tabby_a, ('spotted', 1): spotted_t, ('spotted', 0): spotted_a}[(name, int(T))]
        for k, d in info.items():
            r = fn(d)
            if r: put(k, DEEP if r == 'D' else SHADE)
        return img
    if name in ('tuxedo', 'calico'):
        cal = name == 'calico'
        wf = (white_t if T else white_a)
        wm = {k for k, d in info.items() if wf(d, cal)}
        cf = (cal_t if T else cal_a)
        patches = {}
        if cal:
            for k, d in info.items():
                if k in wm: continue
                r = cf(d)
                if r and d['part'] == 'head' and any((k[0] + a, k[1] + b) not in info for a in (-1, 0, 1) for b in (-1, 0, 1)): r = None
                if r: patches[k] = r
        for k, d in info.items():
            if k in wm:
                nb = [(k[0] + 1, k[1]), (k[0] - 1, k[1]), (k[0], k[1] + 1), (k[0], k[1] - 1)]
                if any(n in info and n not in wm for n in nb): put(k, WE)
                else: put(k, white_col(d))
            elif k in patches: put(k, DEEP if patches[k] == 'D' else SHADE)
        return img
    if name == 'pointed':
        pf = point_t if T else point_a
        for k, d in info.items():
            if pf(d): put(k, TONE_DOWN[d['tone']])
            elif d['part'] in ('chest', 'leg', 'body', 'belly') or (not T and d['part'] == 'head'): put(k, TONE_UP[d['tone']])
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
    band = band_of(grey); felt_old = (grey[..., 3] > 0) & ~band
    new = grey.copy(); new[remove] = 0
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

# ---------------------------------------------------------------- folded ears
FLAP = {'toward': grid(-12, {-9: '...LLLL', -8: '.LLLBBBB', -7: 'LBBBBBBBB', -6: 'BBBBBBBS', -5: 'SSSSS'}),
        'away': grid(-10, {-8: '..LLLL', -7: '.LLBBBB', -6: 'LBBBBBB', -5: 'BBBBBSS', -4: 'SSSS'})}
def flap_pixels(view, g, side):
    """felt pixels of one folded ear: dict (x,y)->(tone char, lx, ly) ; side -1 left, +1 right"""
    hx, hcy = g['hx'], g['hcy']
    eo = g['ear'][0 if side < 0 else 1]
    out = {}
    for (lx, ly), ch in FLAP[view].items():
        lx2 = lx if side < 0 else -lx
        ly2 = ly + (1 if eo[1] > 0 else (-1 if eo[1] < 0 else 0)) * 0
        out[(hx + lx2, int(hcy + ly2))] = (ch, lx2, ly2)
    return out
TONECOL = {'G': GLOSS, 'L': LIGHT, 'B': BASE, 'S': SHADE, 'D': DEEP}

def folded_ears(view, grey, emask, g):
    remove = np.zeros((H_, W_), bool); add = {}; meta = {}
    remove |= emask
    for side in (-1, 1):
        for (x, y), (t, lx, ly) in flap_pixels(view, g, side).items():
            if 0 <= x < W_ and 0 <= y < H_:
                add[(x, y)] = TONECOL[t]; meta[(x, y)] = (lx, ly)
    # drop old outline-only pixels under the new felt are handled by reoutline; felt pixels covered by the flap are overwritten by add
    out = reoutline(grey, remove & ~np.zeros_like(remove), add)
    return out, meta

def bobtail(view, grey, tmask, g):
    remove = np.zeros((H_, W_), bool); fill = {}
    tail = g['tail']
    arc0 = 3.0 if view == 'away' else 4.5
    cx, cy = chain_pt(tail, arc0)
    keep_r = 3.6 if view == 'away' else 3.9
    for y, x in np.argwhere(tmask):
        if math.hypot(x - cx, y - cy) > keep_r: remove[y, x] = True
    band = band_of(grey)
    # the tail's own crease lines (interior umber pixels hugging the removed felt) go too
    ys, xs = np.nonzero(remove)
    for y in range(H_):
        for x in range(W_):
            if grey[y, x, 3] and not band[y, x] and tuple(grey[y, x, :3]) in OLS and not tmask[y, x]:
                if math.hypot(x - cx, y - cy) <= keep_r + 0.6: continue
                if ((ys - y) ** 2 + (xs - x) ** 2).min() <= 2.3: remove[y, x] = True
    felt = (grey[..., 3] > 0) & ~band & ~remove & ~(np.array([[tuple(grey[y, x, :3]) in OLS for x in range(W_)] for y in range(H_)]))
    fy, fx = np.nonzero(felt)
    for y, x in zip(*np.nonzero(remove)):
        row = felt[y]; col = felt[:, x]
        if row[:x].any() and row[x + 1:].any() and col[:y].any() and col[y + 1:].any():
            d2 = (fy - y) ** 2 + (fx - x) ** 2; js = np.argsort(d2)[:7]
            cols = collections.Counter(tuple(int(v) for v in grey[fy[j], fx[j], :3]) for j in js)
            cols = {c: n for c, n in cols.items() if c not in (GLOSS, LIGHT)} or cols
            fill[(x, y)] = max(cols.items(), key=lambda kv: kv[1])[0]
    rm2 = remove.copy()
    for (x, y) in fill: rm2[y, x] = False
    out = reoutline(grey, rm2, None) if rm2.any() else grey.copy()
    for (x, y), c in fill.items(): out[y, x, :3] = c; out[y, x, 3] = 255
    # stub end cap: a short crease arc on the far side of the stub, a lighter tip below it
    ex, ey = chain_pt(tail, arc0 + 1.5); dx, dy = ex - cx, ey - cy; dn = math.hypot(dx, dy) or 1
    for y in range(H_):
        for x in range(W_):
            r = math.hypot(x - cx, y - cy)
            if tmask[y, x] and not remove[y, x] and keep_r - 1.1 < r <= keep_r and ((x - cx) * dx + (y - cy) * dy) / dn > 0.3:
                out[y, x, :3] = (0x4a, 0x2c, 0x1a); out[y, x, 3] = 255
    return out

# ---------------------------------------------------------------- io helpers
def rd(p): return np.array(Image.open(p).convert('RGBA'))
def save(a, p): Image.fromarray(a, 'RGBA').save(p, optimize=False)
def diff_layers(old, new):
    d = (old != new).any(-1) | ((old[..., 3] > 0) != (new[..., 3] > 0))
    part = np.zeros_like(old); part[d & (new[..., 3] > 0)] = new[d & (new[..., 3] > 0)]
    return part, d & (old[..., 3] > 0)
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

def tile(arrs, scale=2):
    im = Image.new('RGBA', (W_ * len(arrs), H_), (245, 236, 215, 255))
    for i, a in enumerate(arrs): im.alpha_composite(Image.fromarray(a, 'RGBA'), (i * W_, 0))
    return im.resize((im.width * scale, im.height * scale), Image.NEAREST) if scale != 1 else im

def main():
    os.makedirs(VIEW, exist_ok=True)
    for fn in os.listdir(OUT):
        if fn.endswith('.png'): os.remove(os.path.join(OUT, fn))
    SH, TW, AW = parse_lua()
    base_tones = {k: v[0] for k, v in R.load(os.path.join(R.CF, 'tones.json'), True).items()}
    overlays = R.load(os.path.join(R.CF, 'tones_overlays.json'))
    problems = []; n = 0
    D = {}                                               # per view data
    for view in VIEWS:
        layers = load_layers(view)
        greys = [rd(os.path.join(SRC, 'cf-cat-grey-run%s%02d.png' % (view, f + 1))) for f in range(NF)]
        emasks = [rd(os.path.join(SRC, 'cf-ears-mask-run%s%02d.png' % (view, f + 1)))[..., 3] > 0 for f in range(NF)]
        tmasks = [rd(os.path.join(SRC, 'cf-tail-mask-run%s%02d.png' % (view, f + 1)))[..., 3] > 0 for f in range(NF)]
        TBL = TW if view == 'toward' else AW
        geos = []
        for f in range(NF):
            gfun = geom_toward if view == 'toward' else geom_away
            g = gfun(SH[f], TBL[f], TBL[(f - 1) % NF])
            if view == 'away':
                pL, pR = f in (6, 7), f in (7, 0)
                g['hd'] = {'L': 2 if pL else (-1 if pR else 0), 'R': 2 if pR else (-1 if pL else 0)}
            geos.append(g)
        pats = {p: [] for p in R.PATTERNS}; patsf = {p: [] for p in R.PATTERNS}; fears = []; ears = []; tails = []; eyes = []; eclear = []; tclear = []; infos = []
        for f in range(NF):
            info = classify(view, f, geos[f], layers, greys[f]); infos.append(info)
            for p in R.PATTERNS: pats[p].append(make_pattern(view, p, info))
            fe, meta = folded_ears(view, greys[f], emasks[f], geos[f]); fears.append(fe)
            pe, ce = diff_layers(greys[f], fe); ears.append(pe); eclear.append(ce)
            tn = {GLOSS: 'gloss', LIGHT: 'light', BASE: 'base', SHADE: 'shade', DEEP: 'deep'}
            info_f = {k: v for k, v in info.items() if not ce[k[1], k[0]] and not (v['part'] == 'ear')}
            for (x, y), (lx, ly) in meta.items():
                if grey_tone(fe, x, y) is None: continue
                if view == 'toward' and False: pass
                info_f[(x, y)] = dict(x=x, y=y, tone=grey_tone(fe, x, y), lay='ears', part='ear', lx=lx, ly=ly)
            for p in R.PATTERNS: patsf[p].append(make_pattern(view, p, info_f))
            bt = bobtail(view, greys[f], tmasks[f], geos[f]); pt, ct = diff_layers(greys[f], bt); tails.append(pt); tclear.append(ct)
            e = np.zeros((H_, W_, 4), np.uint8)
            if view == 'toward':
                m = (greys[f][..., :3] == np.array(EYECREAM)).all(-1) & (greys[f][..., 3] > 0); e[m] = (*EYECREAM, 255)
            eyes.append(e)
        D[view] = dict(greys=greys, pats=pats, patsf=patsf, fears=fears, ears=ears, tails=tails, eyes=eyes, eclear=eclear, tclear=tclear, infos=infos, geos=geos)
        for f in range(NF):
            tag = 'run%s%02d' % (view, f + 1)
            for nm, cl in (('ears', eclear[f]), ('tail', tclear[f])):
                a = np.zeros((H_, W_, 4), np.uint8); a[cl] = (255, 255, 255, 255)
                save(a, os.path.join(OUT, 'cf-%s-clear-%s.png' % (nm, tag))); n += 1
            if view == 'toward':
                for ey, col in R.EYES.items():
                    a = eyes[f].copy(); a[a[..., 3] > 0, :3] = R.h2rgb(col)
                    save(a, os.path.join(OUT, 'cf-eyes-%s-%s.png' % (ey, tag))); n += 1
    # coats
    for coat in R.COATS:
        cmap = R.build_map(coat, base_tones, overlays, None)
        allowed = set(cmap.values()) | set(R.FIXED) | set(R.EYES.values())
        for view in VIEWS:
            d = D[view]
            for f in range(NF):
                tag = 'run%s%02d' % (view, f + 1)
                outs = [('cf-cat-%s-%s.png' % (coat, tag), d['greys'][f]), ('cf-ears-folded-%s-%s.png' % (coat, tag), d['ears'][f]),
                        ('cf-tail-bobtail-%s-%s.png' % (coat, tag), d['tails'][f])]
                outs += [('cf-pat-%s-%s-%s.png' % (p, coat, tag), d['pats'][p][f]) for p in R.PATTERNS]
                outs += [('cf-pat-%s-%s-%s-fold.png' % (p, coat, tag), d['patsf'][p][f]) for p in R.PATTERNS]
                for name, arr in outs:
                    o, unm = R.recolor(Image.fromarray(arr, 'RGBA'), cmap)
                    if unm: problems.append('%s unmapped %s' % (name, unm))
                    if any(v not in (0, 255) for v in np.unique(o[..., 3])): problems.append(name + ' semi alpha')
                    op = o[o[..., 3] > 0][:, :3]
                    for c in (np.unique(op, axis=0) if len(op) else []):
                        if R.hex_(c) not in allowed: problems.append('%s colour %s outside ramp' % (name, R.hex_(c)))
                    if o.shape != (64, 64, 4): problems.append(name + ' size')
                    save(o, os.path.join(OUT, name)); n += 1
    # containment
    for view in VIEWS:
        d = D[view]
        for f in range(NF):
            band = band_of(d['greys'][f]); bandf = band_of(d['fears'][f])
            for p in R.PATTERNS:
                if ((d['pats'][p][f][..., 3] > 0) & ((d['greys'][f][..., 3] == 0) | band)).any(): problems.append('%s pattern %s f%d bleeds outside silhouette' % (view, p, f + 1))
                if ((d['patsf'][p][f][..., 3] > 0) & ((d['fears'][f][..., 3] == 0) | bandf)).any(): problems.append('%s fold pattern %s f%d bleeds outside silhouette' % (view, p, f + 1))
    # views
    def loadc(coat, kind, view, f): return rd(os.path.join(OUT, kind % (coat, 'run%s%02d' % (view, f + 1))))
    def row(coat, view, pat=None, fold=False, bob=False):
        r = []; d = D[view]
        for f in range(NF):
            body = loadc(coat, 'cf-cat-%s-%s.png', view, f); parts = []; clears = []
            if fold: parts.append(loadc(coat, 'cf-ears-folded-%s-%s.png', view, f)); clears.append(d['eclear'][f])
            if bob: parts.append(loadc(coat, 'cf-tail-bobtail-%s-%s.png', view, f)); clears.append(d['tclear'][f])
            pt = rd(os.path.join(OUT, 'cf-pat-%s-%s-run%s%02d%s.png' % (pat, coat, view, f + 1, '-fold' if fold else ''))) if pat else None
            eye = rd(os.path.join(OUT, 'cf-eyes-amber-run%s%02d.png' % (view, f + 1))) if view == 'toward' else None
            r.append(compose(body, parts, pt, eye, clears))
        return r
    for coat in R.COATS:
        for view in VIEWS:
            rows = [row(coat, view)] + [row(coat, view, p) for p in R.PATTERNS] + [row(coat, view, 'tabby', True, True), row(coat, view, 'calico', True, True)]
            sheets = [tile(r, 2) for r in rows]
            big = Image.new('RGBA', (sheets[0].width, sum(s.height for s in sheets))); yy = 0
            for s in sheets: big.paste(s, (0, yy)); yy += s.height
            big.save(os.path.join(VIEW, 'coat-%s-%s.png' % (coat, view)))
    for view in VIEWS:
        for pat in ('tabby', 'calico', 'tuxedo', 'pointed', 'spotted'):
            rows = [tile(row(c, view, pat), 1) for c in R.COATS]
            big = Image.new('RGBA', (rows[0].width, H_ * len(rows)))
            for i, r_ in enumerate(rows): big.paste(r_, (0, i * H_))
            big.save(os.path.join(VIEW, 'all-coats-%s-%s.png' % (pat, view)))
        rows = [tile(row(c, view, 'calico', True, True), 1) for c in R.COATS]
        big = Image.new('RGBA', (rows[0].width, H_ * len(rows)))
        for i, r_ in enumerate(rows): big.paste(r_, (0, i * H_))
        big.save(os.path.join(VIEW, 'all-coats-folded-bob-%s.png' % view))
    # neighbour jump (core px: head + trunk; count for stripes/spots, coverage for fills)
    print('pattern jump report (limit 8%):')
    for view in VIEWS:
        d = D[view]; core_parts = ('head', 'chest') if view == 'toward' else ('head', 'body')
        for p in R.PATTERNS:
            core = []; felt = []
            for f in range(NF):
                m = d['pats'][p][f][..., 3] > 0
                ks = [k for k, v in d['infos'][f].items() if v['part'] in core_parts]
                core.append(sum(1 for k in ks if m[k[1], k[0]])); felt.append(len(ks))
            ser = [a / b for a, b in zip(core, felt)] if p == 'pointed' else core
            js = [abs(ser[(f + 1) % NF] - ser[f]) / max(1e-9, ser[f]) for f in range(NF)]
            print('  %-6s %-8s core %s max %.1f%% %s' % (view, p, core, 100 * max(js), 'OK' if max(js) <= .08 else 'OVER'))
    print('wrote %d PNG files to %s' % (n, OUT))
    for p in problems[:40]: print('PROBLEM', p)
    print('checks:', 'FAILED (%d)' % len(problems) if problems else 'ok (alpha 0/255, colours in coat ramps + fixed accents, patterns inside silhouette)')
    return 1 if problems else 0

def grey_tone(a, x, y):
    if a[y, x, 3] == 0: return None
    return GREYS.get('%02x%02x%02x' % tuple(a[y, x, :3]))

if __name__ == '__main__':
    sys.exit(main())
