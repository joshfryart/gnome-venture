#!/usr/bin/env python3
"""check.py : sizes, no semi-transparent pixels, glyph + tab centering, knob/hole exact interlock, glyph clear of holes. Prints PASS/FAIL lines; exit 1 on any FAIL."""
import os, sys, glob
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from pv47 import *
from PIL import Image
fails = 0
def rep(ok, msg):
    global fails
    print(('PASS ' if ok else 'FAIL ') + msg)
    if not ok: fails += 1

# 1. sizes + 2. alpha
for size, c in CFG.items():
    bad_size, bad_alpha, n = [], [], 0
    for f in sorted(glob.glob(os.path.join(V, size, '*.png'))):
        im = Image.open(f).convert('RGBA'); n += 1; name = os.path.basename(f)
        want = (c['badge'], c['badge']) if name.startswith('badge-') else (c['W'], c['H'])
        if im.size != want: bad_size.append((name, im.size))
        if any(0 < a < 255 for a in im.getchannel('A').getdata()): bad_alpha.append(name)
    rep(not bad_size, '%s: %d PNGs have the right size (piece %dx%d, body %dx%d at (%d,%d), tab %d, badge %d) %s' % (size, n, c['W'], c['H'], c['BW'], c['BH'], c['T'], c['T'], c['T'], c['badge'], bad_size or ''))
    rep(not bad_alpha, '%s: no semi-transparent pixel in any PNG %s' % (size, bad_alpha or ''))
    # expected file count: 7 tiles + 6 socks + 3 frames + 3 overlays + 5 badges
    rep(n == 24, '%s: 24 PNG files present (found %d)' % (size, n))

# 3. glyph centering (glyph-only layer exported by the build)
for size, c in CFG.items():
    for t in TYPES:
        im = Image.open(os.path.join(V, 'scripts/layers/glyph-%s-%s.png' % (size, t))).convert('RGBA')
        x0, y0, x1, y1 = im.getchannel('A').getbbox(); x1 -= 1; y1 -= 1
        bx0, by0 = x0 - c['T'], y0 - c['T']; bx1, by1 = x1 - c['T'], y1 - c['T']
        cx, cy = (bx0 + bx1) / 2, (by0 + by1) / 2
        ok = cx == (c['BW'] - 1) / 2 and cy == (c['BH'] - 1) / 2
        rep(ok, '%s glyph %-6s %dx%d at body x %d..%d y %d..%d  centre (%.1f, %.1f) = body centre (%.1f, %.1f)' % (size, t, x1 - x0 + 1, y1 - y0 + 1, bx0, bx1, by0, by1, cx, cy, (c['BW'] - 1) / 2, (c['BH'] - 1) / 2))

# 4. tab centering
for size, c in CFG.items():
    for fam in FAMS:
        sock = P(size, 'sock-%s-%s-knob' % (size, fam)); out = []
        for side in SIDES:
            x0, y0, x1, y1 = region(size, side)
            bb = sock.crop((x0, y0, x1, y1)).getchannel('A').getbbox()
            bx0, by0, bx1, by1 = bb[0] + x0, bb[1] + y0, bb[2] + x0 - 1, bb[3] + y0 - 1
            if side in ('top', 'bottom'): cen, want, w = (bx0 + bx1) / 2, (c['W'] - 1) / 2, bx1 - bx0 + 1
            else: cen, want, w = (by0 + by1) / 2, (c['H'] - 1) / 2, by1 - by0 + 1
            out.append((cen == want, side, w))
        rep(all(o[0] for o in out), '%s knob %-5s centred on its side; widths %s' % (size, fam, ', '.join('%s %d' % (o[1], o[2]) for o in out)))

# 5. interlock: a knob on one piece, the neighbouring piece's hole, at the pitch
OPP = {'top': 'bottom', 'bottom': 'top', 'left': 'right', 'right': 'left'}
STEP = {'top': (0, -1), 'bottom': (0, 1), 'left': (-1, 0), 'right': (1, 0)}
def opaque(img, ox, oy):
    return {(x + ox, y + oy) for x in range(img.width) for y in range(img.height) if img.getpixel((x, y))[3] > 0}
for size, c in CFG.items():
    px, py = c['pitch']
    for fam in FAMS:
        res = []
        for side in SIDES:
            for a_kind, b_kind in (('knob', 'hole'), ('hole', 'knob')):
                A = piece(size, TYPES[(len(res) + 0) % 7], {side: (a_kind, fam)}); B = piece(size, TYPES[(len(res) + 3) % 7], {OPP[side]: (b_kind, fam)})
                dx, dy = STEP[side][0] * px, STEP[side][1] * py
                oa, ob = opaque(A, 0, 0), opaque(B, dx, dy)
                overlap = oa & ob
                knob_owner, hole_owner = (oa, ob) if a_kind == 'knob' else (ob, oa)
                # the cut-out cells of the hole piece (erase marker in its sock)
                hsock = P(size, 'sock-%s-%s-hole' % (size, fam)); x0, y0, x1, y1 = region(size, OPP[side] if a_kind == 'knob' else side)
                hoff = (dx, dy) if a_kind == 'knob' else (0, 0)
                cut = {(x + hoff[0], y + hoff[1]) for x in range(x0, x1) for y in range(y0, y1) if hsock.getpixel((x, y)) == ERASE}
                gap = [p for p in cut if p not in knob_owner]
                res.append((side, a_kind, len(overlap), len(gap), len(cut)))
        ok = all(r[2] == 0 and r[3] == 0 and r[4] > 0 for r in res)
        rep(ok, '%s %-5s interlock, 4 directions x knob/hole both ways: overlap %d px, gap %d px, hole cells %s' % (size, fam, sum(r[2] for r in res), sum(r[3] for r in res), sorted({r[4] for r in res})))
    # flat neighbours never overlap
    A = piece(size, 'hurt'); B = piece(size, 'guard')
    ok = all(not (opaque(A, 0, 0) & opaque(B, STEP[s][0] * px, STEP[s][1] * py)) for s in SIDES)
    rep(ok, '%s flat edges: neighbours abut without overlap' % size)

# 5b. the 5 x 3 cluster: no overlap anywhere (sum of pieces = union), every seam filled
for size, c in CFG.items():
    px, py = c['pitch']
    import pv47
    spec = pv47.CLUSTER
    pcs = [(x, y, piece(size, t, e, o)) for x, y, t, o, e in spec]
    occ = {}; over = 0
    for x, y, im in pcs:
        for p in opaque(im, x * px, y * py):
            over += p in occ; occ[p] = 1
    rep(over == 0, '%s cluster of %d pieces (5x3 grid): %d overlapping pixels' % (size, len(pcs), over))
    seams = 0; gaps = 0
    for x, y, t, o, e in spec:
        for side, (kind, fam) in e.items():
            if kind != 'hole': continue
            hs = P(size, 'sock-%s-%s-hole' % (size, fam)); x0, y0, x1, y1 = region(size, side)
            for xx in range(x0, x1):
                for yy in range(y0, y1):
                    if hs.getpixel((xx, yy)) == ERASE:
                        seams += 1; gaps += (xx + x * px, yy + y * py) not in occ
    rep(gaps == 0 and seams > 0, '%s cluster: %d hole cells, %d left empty (no gaps)' % (size, seams, gaps))

# 6. no hole (cut-out or its rim) touches a glyph pixel; report the gap to the nearest one
for size, c in CFG.items():
    hit, gaps = [], []
    for t in TYPES:
        gl = Image.open(os.path.join(V, 'scripts/layers/glyph-%s-%s.png' % (size, t))).convert('RGBA')
        gp = {(x, y) for x in range(gl.width) for y in range(gl.height) if gl.getpixel((x, y))[3]}
        for fam in FAMS:
            hs = P(size, 'sock-%s-%s-hole' % (size, fam))
            hp = {(x, y) for x in range(hs.width) for y in range(hs.height) if hs.getpixel((x, y))[3]}
            if gp & hp: hit.append((t, fam))
            gaps.append(min(max(abs(a[0] - b[0]), abs(a[1] - b[1])) for a in gp for b in hp) - 1)
    rep(not hit, '%s glyphs never overlap a hole or its rim; smallest gap %d px (0 = touching) %s' % (size, min(gaps), hit[:3] or ''))
# 7. polish: symmetric tabs and holes, identical outline weight (every silhouette edge pixel is dark), no orphan pixels
for size, cf in CFG.items():
    bad = []
    for fam in FAMS:
        for kind in ('knob', 'hole'):
            sk = P(size, 'sock-%s-%s-%s' % (size, fam, kind))
            for side in SIDES:
                x0, y0, x1, y1 = region(size, side)
                for x in range(x0, x1):
                    for y in range(y0, y1):
                        mx, my = (cf['W'] - 1 - x, y) if side in ('top', 'bottom') else (x, cf['H'] - 1 - y)
                        if not (x0 <= mx < x1 and y0 <= my < y1): continue
                        if (sk.getpixel((x, y))[3] > 0) != (sk.getpixel((mx, my))[3] > 0): bad.append((fam, kind, side, x, y))
    rep(not bad, '%s all tabs and holes are mirror-symmetric (alpha) %s' % (size, bad[:2] or ''))
    lum = lambda p: 0.3 * p[0] + 0.59 * p[1] + 0.11 * p[2]
    light_edge, orph = [], []
    import random
    rnd = random.Random(5)
    for n in range(40):
        t = TYPES[n % 7]
        e = {s: (rnd.choice(['knob', 'hole', None]), rnd.choice(FAMS)) for s in SIDES}
        e = {s: v for s, v in e.items() if v[0]}
        owner = ['me', 'foe'][n % 2]
        im = piece(size, t, e, owner); px = im.load(); W_, H_ = im.size
        for y in range(H_):
            for x in range(W_):
                if px[x, y][3] == 0: continue
                nb4 = [(x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)]
                if any(not (0 <= a < W_ and 0 <= b < H_) or px[a, b][3] == 0 for a, b in nb4):
                    if lum(px[x, y]) > 80: light_edge.append((t, x, y))
                if not any(0 <= x + dx < W_ and 0 <= y + dy < H_ and px[x + dx, y + dy][3] and (dx or dy) for dx in (-1, 0, 1) for dy in (-1, 0, 1)): orph.append((t, x, y))
    rep(not light_edge, '%s outline weight: all silhouette edge pixels of 40 random pieces are dark (1 px, same colour family) %s' % (size, light_edge[:3] or ''))
    rep(not orph, '%s no isolated orphan pixels in 40 random pieces %s' % (size, orph[:3] or ''))
    # grain budget
    g = Image.open(os.path.join(V, 'scripts/layers/grain-%s-hurt.png' % size)).convert('RGBA')
    ng = sum(1 for p in g.getdata() if p[3]); body = sum(1 for p in P(size, 'tile-%s-hurt' % size).getchannel('A').getdata() if p)
    rep(ng / body <= 0.06, '%s felt grain uses %.1f%% of body pixels (limit 6%%)' % (size, 100. * ng / body))
print('RESULT', 'FAIL (%d)' % fails if fails else 'ALL PASS')
sys.exit(1 if fails else 0)
