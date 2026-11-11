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
    Wc, Hc = W + 2 * P, H + 2 * P
    ox = oy = P
    m = [[False] * Wc for _ in range(Hc)]
    for y in range(H):
        for x in range(W):
            m[oy + y][ox + x] = in_rr(x, y, W, H, R)
    cy, cx = oy + H / 2.0, ox + W / 2.0
    for side in 'LRTB':
        kind, fam = edges[side]
        if kind == 'flat':
            continue
        hp = prof(fam, P, k)
        for t in range(P):
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


def paint(t, k, edges):
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
            if dd == 1:
                c = INK
            elif dd == 2:
                c = CREAM                                    # stitched cream piping
            elif dd == 3 and (x + y) % 3 < 2:
                c = GOLD
            elif dd == 3:
                c = lt
            px[x, y] = c + (255,)
    # gold button in the middle of the body
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
