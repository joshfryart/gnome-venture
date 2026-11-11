#!/usr/bin/env python3
"""Real four-sided jigsaw shapes: every edge can be flat, a knob or a hole, in any family.

Writes (to <out>):
  shapes-assembled-<hand|strip>.png   4x3 puzzle snapped together (corners, edges, centres)
  shapes-exploded-<hand|strip>.png    the same pieces pulled apart so every silhouette is visible
Piece canvas = body + depth P on all four sides. Body is placed at (P, P).
Run: python3 gen_shapes.py <out dir>
"""
import math
import os
import random
import sys
from PIL import Image
from gen_pfight import TYPES, INK, CREAM, GOLD, dark_of, light_of, pat, in_rr
from gen_pieces import prof, depth_map, G

FAM3 = ['body', 'mind', 'craft']
TY = list(TYPES)


def shape_mask(k, edges):
    g = G[k]
    W, H, P, R = g['W'], g['H'], g['P'], g['R']
    PV = max(6, P * 2 // 3)                     # shallower tabs top/bottom so they miss the icon
    Wc, Hc = W + 2 * P, H + 2 * PV
    ox, oy = P, PV
    m = [[False] * Wc for _ in range(Hc)]
    for y in range(H):
        for x in range(W):
            m[oy + y][ox + x] = in_rr(x, y, W, H, R)
    cy, cx = oy + H / 2.0, ox + W / 2.0
    for side in 'LRTB':
        kind, fam = edges[side]
        if kind == 'flat':
            continue
        dep = P if side in 'LR' else PV
        hp = prof(fam, dep, k, 1.0 if side in 'LR' else dep / P)
        for t in range(dep):
            rng = range(Hc) if side in 'LR' else range(Wc)
            for s in rng:
                c = cy if side in 'LR' else cx
                if abs(s + .5 - c) > hp[t]:
                    continue
                if side == 'L':
                    x, y = (ox + t if kind == 'hole' else ox - 1 - t), s
                elif side == 'R':
                    x, y = (ox + W - 1 - t if kind == 'hole' else ox + W + t), s
                elif side == 'T':
                    x, y = s, (oy + t if kind == 'hole' else oy - 1 - t)
                else:
                    x, y = s, (oy + H - 1 - t if kind == 'hole' else oy + H + t)
                m[y][x] = (kind == 'knob')
    return m, Wc, Hc, ox, oy


def paint(t, k, edges, owner='me', icon_dir=None):
    m, Wc, Hc, ox, oy = shape_mask(k, edges)
    d = depth_map(m, Wc, Hc)
    base = TYPES[t]
    dk, lt = dark_of(base), light_of(base)
    pm = {'d': dk, 'l': lt, 'g': CREAM, 'y': GOLD}
    im = Image.new('RGBA', (Wc, Hc), (0, 0, 0, 0))
    px = im.load()
    for y in range(Hc):
        for x in range(Wc):
            if not m[y][x]:
                continue
            dd = d[y][x]
            code = pat(t, x - ox, y - oy, k)
            c = pm[code] if code else base
            if owner == 'foe':                               # dark thorn rim, rust accent
                if dd == 1:
                    c = INK
                elif dd == 2:
                    c = (150, 52, 28)
                elif dd == 3 and (x + y) % 4 < 2:
                    c = INK
            elif dd == 1:
                c = INK
            elif dd == 2:
                c = CREAM                                    # stitched cream piping
            elif dd == 3 and (x + y) % 3 < 2:
                c = GOLD
            elif dd == 3:
                c = lt
            px[x, y] = c + (255,)
    if icon_dir:                                     # medallion + icon + value plate (as the 1D pieces)
        g = G[k]
        for y in range(Hc):
            for x in range(Wc):
                d2 = (x + .5 - ox - g['mx']) ** 2 + (y + .5 - oy - g['my']) ** 2
                if d2 <= g['mr'] ** 2 and m[y][x] and d[y][x] > 3:
                    px[x, y] = (INK if d2 > (g['mr'] - 1.15) ** 2 else CREAM) + (255,)
        ic = Image.open(os.path.join(icon_dir, 'ico-%s.png' % t if k == 'hand' else 'ico-%s-s.png' % t)).convert('RGBA')
        ix, iy = ox + (37 if k == 'hand' else 21), oy + (9 if k == 'hand' else 14)
        ip = ic.load()
        for yy in range(ic.height):
            for xx in range(ic.width):
                if ip[xx, yy][3] and m[iy + yy][ix + xx]:
                    px[ix + xx, iy + yy] = ip[xx, yy]
        for y in range(g['vh']):
            for x in range(g['vw']):
                X, Y = ox + g['vx'] + x, oy + g['vy'] + y
                if in_rr(x, y, g['vw'], g['vh'], 2) and m[Y][X]:
                    edge = not all(in_rr(x + a, y + b, g['vw'], g['vh'], 2) for a, b in ((1, 0), (-1, 0), (0, 1), (0, -1)))
                    px[X, Y] = (CREAM if edge else INK) + (255,)
    else:                                            # gold button in the middle of the body
        bx, by = ox + G[k]['W'] // 2, oy + G[k]['H'] // 2
        b = 4 if k == 'hand' else 3
        for yy in range(b):
            for xx in range(b):
                px[bx - b // 2 + xx, by - b // 2 + yy] = (INK if xx in (0, b - 1) and yy in (0, b - 1) else GOLD) + (255,)
    return im


def layout(cols, rows, seed):
    """edge assignment so neighbours fit: returns edges[r][c] dict"""
    rnd = random.Random(seed)
    E = [[{s: ('flat', None) for s in 'LRTB'} for _ in range(cols)] for _ in range(rows)]
    for r in range(rows):
        for c in range(cols):
            if c + 1 < cols:
                fam, kn = rnd.choice(FAM3), rnd.random() < .5
                E[r][c]['R'] = ('knob' if kn else 'hole', fam)
                E[r][c + 1]['L'] = ('hole' if kn else 'knob', fam)
            if r + 1 < rows:
                fam, kn = rnd.choice(FAM3), rnd.random() < .5
                E[r][c]['B'] = ('knob' if kn else 'hole', fam)
                E[r + 1][c]['T'] = ('hole' if kn else 'knob', fam)
    return E


def build(out, k, cols=4, rows=3):
    g = G[k]
    W, H, P = g['W'], g['H'], g['P']
    best = None
    for seed in range(1, 200):               # pick a layout that uses all 3 families a few times
        E = layout(cols, rows, seed)
        fams = [e[1] for row in E for p in row for e in p.values() if e[0] == 'knob']
        if all(fams.count(f) >= 3 for f in FAM3):
            best = E
            break
    E = best
    for name, gap in (('assembled', 0), ('exploded', 2 * P + 6)):
        cw, ch = W + gap, H + gap
        cv = Image.new('RGBA', (cols * cw + 2 * P + (gap and 0), rows * ch + 2 * P), (0, 0, 0, 0))
        for r in range(rows):
            for c in range(cols):
                im = paint(TY[(r * cols + c) % 7], k, E[r][c])
                cv.alpha_composite(im, (c * cw, r * ch))
        cv.save(os.path.join(out, f'shapes-{name}-{k}.png'))


if __name__ == '__main__':
    os.makedirs(sys.argv[1], exist_ok=True)
    for k in ('hand', 'strip'):
        build(sys.argv[1], k)
    print('ok')
