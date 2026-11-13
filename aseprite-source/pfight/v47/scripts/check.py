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
                A = piece(size, 'hurt', {side: (a_kind, fam)}); B = piece(size, 'guard', {OPP[side]: (b_kind, fam)})
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
print('RESULT', 'FAIL (%d)' % fails if fails else 'ALL PASS')
sys.exit(1 if fails else 0)
