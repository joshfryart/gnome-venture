#!/usr/bin/env python3
"""check.py : the v48 faces keep v47's edge. Sizes, no semi-transparent pixels, the silhouette of every tile is v47's, glyphs centred and clear of every hole,
knob/hole interlock of composed pieces, no overlap in a cluster, a dark outline on every silhouette edge, mine / creature / environment told apart without colour.
Prints PASS/FAIL lines; exit 1 on any FAIL."""
import os, sys, glob, random
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import pv48
from pv48 import CFG, TYPES, FAMS, SIDES, KINDS, ERASE, region, piece, P, glyph, pv47
from PIL import Image
fails = 0
def rep(ok, msg):
    global fails
    print(('PASS ' if ok else 'FAIL ') + msg)
    if not ok: fails += 1
def alpha(im): return im.getchannel('A').tobytes()
def opaque(img, ox=0, oy=0):
    px = img.load(); return {(x + ox, y + oy) for x in range(img.width) for y in range(img.height) if px[x, y][3] > 0}
SETS = [('me', t) for t in TYPES] + [('foe', t) for t in TYPES] + [('env', k) for k in KINDS]
FILE = {'me': 'tile', 'foe': 'foe', 'env': 'env'}

for size, c in CFG.items():
    # 1. files, sizes, alpha
    bad_size, bad_alpha, n = [], [], 0
    k = pv48.SLOTS[size]['k']; pw, ph = pv48.SLOTS[size]['plate'][2:]
    for f in sorted(glob.glob(os.path.join(pv48.V, size, '*.png'))):
        im = Image.open(f).convert('RGBA'); n += 1; name = os.path.basename(f)
        want = (pw, ph) if name.startswith('plate-') else (30 * k, 5 * k) if name.startswith('digits-') else (c['W'], c['H'])
        if im.size != want: bad_size.append((name, im.size))
        if any(0 < a < 255 for a in alpha(im)): bad_alpha.append(name)
    rep(not bad_size and n == 22, '%s: 22 PNGs (7 mine, 7 creature, 6 environment, plate, digits; found %d) in the right size (piece %dx%d, plate %dx%d, digits %dx%d each) %s' % (size, n, c['W'], c['H'], pw, ph, 3 * k, 5 * k, bad_size or ''))
    rep(not bad_alpha, '%s: no semi-transparent pixel in any PNG %s' % (size, bad_alpha or ''))
    rep(all(os.path.isfile(os.path.join(pv48.V, size, '%s-%s-%s.aseprite' % (FILE[o], size, nm))) for o, nm in SETS), '%s: every tile has its .aseprite source (layers base, bevel, [teeth | stitch], rim, glyph)' % size)
    # 2. the silhouette is v47's (the engine and the tests depend on the knob and hole positions; sockets, badges and overlays are read from v47 itself)
    ref = alpha(pv47.P(size, 'tile-%s-hurt' % size))
    diff = [nm for o, nm in SETS if alpha(P(size, '%s-%s-%s' % (FILE[o], size, nm))) != ref]
    rep(not diff, '%s: all 20 tiles have exactly the v47 body silhouette %s' % (size, diff or ''))
    # 3. glyphs: centred on the body (half a pixel at most where the size is odd against the body), clear of every hole and its rim, clear of the plate
    off, hit, gaps, plate = [], [], [], []
    holes = [opaque(pv47.P(size, 'sock-%s-%s-hole' % (size, fam))) for fam in FAMS]
    T = c['T']; sl = pv48.SLOTS[size]['plate']
    for o, nm in SETS:
        g = glyph(size, o, nm); x0, y0, x1, y1 = g.getchannel('A').getbbox(); x1 -= 1; y1 -= 1
        dx, dy = (x0 + x1) / 2 - (c['W'] - 1) / 2, (y0 + y1) / 2 - (c['H'] - 1) / 2
        if abs(dx) > .5 or abs(dy) > .5: off.append((o, nm, dx, dy))
        gp = opaque(g)
        for hp in holes:
            if gp & hp: hit.append((o, nm))
            gaps.append(min(max(abs(a[0] - b[0]), abs(a[1] - b[1])) for a in gp for b in hp) - 1)
        if o != 'env' and any(T + sl[0] - 1 <= x < T + sl[0] + sl[2] + 1 and T + sl[1] - 1 <= y < T + sl[1] + sl[3] + 1 for x, y in gp): plate.append((o, nm))
    rep(not off, '%s: 20 glyphs centred on the body (within half a pixel) %s' % (size, off or ''))
    rep(not hit, '%s: no glyph overlaps a hole or its rim; smallest gap %d px (0 = touching, as in v47) %s' % (size, min(gaps), hit[:3] or ''))
    rep(not plate, '%s: no glyph touches the number plate %s' % (size, plate or ''))
    # 4. told apart without colour: a creature glyph and my glyph of the same type differ in shape (under 80% shared silhouette); creature tiles carry teeth, environment tiles a stitch, mine neither
    same = []
    for t in TYPES:
        a, b = opaque(glyph(size, 'me', t)), opaque(glyph(size, 'foe', t))
        if len(a & b) / len(a | b) > .8: same.append((t, round(len(a & b) / len(a | b), 2)))
    rep(not same, '%s: my glyph and the creature\'s glyph of a type are different shapes (shared silhouette at most 80%%) %s' % (size, same or ''))
    # 5. interlock: a knob on one piece, the neighbour's hole, at the pitch, for the three owners
    OPP = {'top': 'bottom', 'bottom': 'top', 'left': 'right', 'right': 'left'}; STEP = {'top': (0, -1), 'bottom': (0, 1), 'left': (-1, 0), 'right': (1, 0)}
    px_, py_ = c['pitch']; res = []
    for i, fam in enumerate(FAMS):
        for side in SIDES:
            for a_kind, b_kind in (('knob', 'hole'), ('hole', 'knob')):
                oa_, na = SETS[(len(res) * 3) % 20]; ob_, nb = SETS[(len(res) * 7 + 5) % 20]
                A = piece(size, na, {side: (a_kind, fam)}, oa_, 7 if oa_ != 'env' else None); B = piece(size, nb, {OPP[side]: (b_kind, fam)}, ob_, 12 if ob_ != 'env' else None)
                dx, dy = STEP[side][0] * px_, STEP[side][1] * py_
                oa, ob = opaque(A), opaque(B, dx, dy)
                knob_owner = oa if a_kind == 'knob' else ob
                hs = pv47.P(size, 'sock-%s-%s-hole' % (size, fam)); x0, y0, x1, y1 = region(size, OPP[side] if a_kind == 'knob' else side)
                hoff = (dx, dy) if a_kind == 'knob' else (0, 0)
                cut = {(x + hoff[0], y + hoff[1]) for x in range(x0, x1) for y in range(y0, y1) if hs.getpixel((x, y)) == ERASE}
                res.append((len(oa & ob), len([p for p in cut if p not in knob_owner]), len(cut)))
    rep(all(r[0] == 0 and r[1] == 0 and r[2] > 0 for r in res), '%s: interlock of composed pieces, 3 families x 4 directions x both ways over all owners: overlap %d px, gap %d px' % (size, sum(r[0] for r in res), sum(r[1] for r in res)))
    # 6. the cluster of the sheet: no overlapping pixel
    occ = {}; over = 0
    for x, y, nm, o, e, num in pv48.CLUSTER:
        for p in opaque(piece(size, nm, e, o, num), x * px_, y * py_):
            over += p in occ; occ[p] = 1
    rep(over == 0, '%s: cluster of %d pieces: %d overlapping pixels' % (size, len(pv48.CLUSTER), over))
    # 7. outline: every silhouette edge pixel of 60 random pieces is dark; no orphan pixel
    lum = lambda p: 0.3 * p[0] + 0.59 * p[1] + 0.11 * p[2]
    rnd = random.Random(5); light, orph = [], []
    for n_ in range(60):
        o, nm = SETS[n_ % 20]
        e = {s: (rnd.choice(['knob', 'hole', None]), rnd.choice(FAMS)) for s in SIDES}; e = {s: v for s, v in e.items() if v[0]}
        im = piece(size, nm, e, o, rnd.randint(1, 30) if o != 'env' else None); px = im.load(); W_, H_ = im.size
        for y in range(H_):
            for x in range(W_):
                if px[x, y][3] == 0: continue
                if any(not (0 <= a < W_ and 0 <= b < H_) or px[a, b][3] == 0 for a, b in ((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1))) and lum(px[x, y]) > 80: light.append((o, nm, x, y))
                if not any(0 <= x + dx < W_ and 0 <= y + dy < H_ and px[x + dx, y + dy][3] and (dx or dy) for dx in (-1, 0, 1) for dy in (-1, 0, 1)): orph.append((o, nm, x, y))
    rep(not light, '%s: every silhouette edge pixel of 60 random pieces is dark (1 px outline) %s' % (size, light[:3] or ''))
    rep(not orph, '%s: no isolated pixel in 60 random pieces %s' % (size, orph[:3] or ''))
    # 8. the number reads: cream digits on the dark plate, contrast over 10:1; every digit is a different drawing
    d = P(size, 'digits-' + size); gw = 3 * k
    cells = [d.crop((i * gw, 0, i * gw + gw, 5 * k)).tobytes() for i in range(10)]
    def rl(p): 
        f = lambda v: (v / 255 / 12.92) if v / 255 <= .03928 else ((v / 255 + .055) / 1.055) ** 2.4
        return .2126 * f(p[0]) + .7152 * f(p[1]) + .0722 * f(p[2])
    cr = (rl((0xff, 0xf1, 0xc8)) + .05) / (rl(P(size, 'plate-' + size).getpixel((pw // 2, ph // 2))) + .05)
    rep(len(set(cells)) == 10 and cr > 10, '%s: 10 different digits, cream on the plate at %.1f:1' % (size, cr))
print('RESULT', 'FAIL (%d)' % fails if fails else 'ALL PASS')
sys.exit(1 if fails else 0)
