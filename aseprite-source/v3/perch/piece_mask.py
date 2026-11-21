#!/usr/bin/env python3
"""Existing perch sprite + its own jigsaw piece (picture cell, shape-coded tabs) placed over the face/eyes.
usage: piece_mask.py <repo> <outdir> [key1,key2,...]   (default: every non-whimsy pal)"""
import sys, os, hashlib
import numpy as np
from PIL import Image
REPO, OUT = sys.argv[1], sys.argv[2]
ONLY = set(sys.argv[3].split(',')) if len(sys.argv) > 3 else None
INK = (43, 28, 38); J = REPO + '/game/assets/img/jigsaw/'
PL = {}
for f in os.listdir(J + 'places'):
    k = f[:-4]; PL['pl-' + k[:44] + '-' + hashlib.md5(k.encode()).hexdigest()[:6]] = J + 'places/' + f
_c = {}
def pic(slug):
    p = PL.get(slug) or J + slug + '.jpg'
    if p not in _c: _c[p] = Image.open(p).convert('RGB')
    return _c[p]
def tab(style, u, v):
    if style == 'keyhole': return (abs(u) <= 1.0 and 0 <= v <= 2.2) or (u*u + (v-3.8)**2 <= 2.7**2)
    if style == 'peg':     return abs(u) <= 2.2 and 0 <= v <= 4.2
    if style == 'tri':     return 0 <= v <= 5 and abs(u) <= 3.2 * (1 - v / 5.4)
    if style == 'double':  return ((abs(u) - 2.6)**2 + (v-2.0)**2) <= 2.1**2 or (abs(u) <= 1 and 0 <= v <= 1.5)
    if style == 'hook':    return (abs(u) <= 1.2 and 0 <= v <= 4.2) or (1 <= u <= 3.6 and 3 <= v <= 4.6)
    return (u*u + (v-2.2)**2) <= 3.1**2
def sides(shape):
    fam, c = shape.split('-')
    return ['F', c[0], c[1], 'F'] if fam == 'corner' else (['F'] + list(c) if fam == 'edge' else list(c))
BS = 10; K = 0.62; PAD = 4; N = BS + 2 * PAD
def piece(row):
    slug, piece_, shape, knob = row[0], row[9], row[10], row[11]
    im = pic(slug); c, r = map(int, piece_.split('-')); cw, ch = im.width // 12, im.height // 8
    cl = np.array(im.crop((c*cw, r*ch, c*cw+cw, r*ch+ch)).resize((BS, BS), Image.BOX if im.width > 400 else Image.LANCZOS)).astype(float)
    m = cl.mean(2, keepdims=True); cl = np.clip(m + (cl - m) * 1.3, 0, 255)
    sd = sides(shape); body = np.zeros((N, N), bool); hole = np.zeros((N, N), bool)
    body[PAD:PAD+BS, PAD:PAD+BS] = True; cx = cy = N / 2
    for si, t in enumerate(sd):
        if t == 'F': continue
        for y in range(N):
            for x in range(N):
                X, Y = x + .5, y + .5
                u, v = [(X-cx, PAD-Y), (Y-cy, X-(PAD+BS)), (X-cx, Y-(PAD+BS)), (Y-cy, PAD-X)][si]
                if t == 'T' and tab(knob, u/K, v/K): body[y, x] = True
                if t == 'B' and v < 0 and tab(knob, u/K, -v/K): hole[y, x] = True
    body &= ~hole
    out = np.zeros((N, N, 4), np.uint8)
    for y in range(N):
        for x in range(N):
            if body[y, x]:
                col = cl[min(BS-1, max(0, y-PAD)), min(BS-1, max(0, x-PAD))]
                up = not body[y-1, x]; lf = not body[y, x-1]; dn = not body[min(N-1, y+1), x]; rt = not body[y, min(N-1, x+1)]
                if y == 0 or x == 0: up = lf = True
                if up or lf: col = col * .75 + 255 * .25
                if dn or rt: col = col * .75
                out[y, x] = [*np.clip(col, 0, 255).astype(np.uint8), 255]
    for y in range(N):
        for x in range(N):
            if not body[y, x] and any(0 <= y+dy < N and 0 <= x+dx < N and body[y+dy, x+dx] for dy, dx in ((1,0),(-1,0),(0,1),(0,-1))): out[y, x] = [*INK, 255]
    return Image.fromarray(out, 'RGBA')
def face_centre(sp):
    a = np.array(sp)[..., 3] > 0; ys, xs = np.nonzero(a)
    x0, x1, y0, y1 = xs.min(), xs.max(), ys.min(), ys.max()
    return (x0 + x1) // 2, int(y0 + (y1 - y0) * 0.42)   # estimate: horizontal middle, ~42% down the sprite
def make(row):
    sp = Image.open(REPO + '/game/assets/img/pals/perch/' + row[1] + '.png').convert('RGBA')
    pc = piece(row); fx, fy = face_centre(sp)
    sp.alpha_composite(pc, (min(36 - N, max(0, fx - N // 2)), min(36 - N, max(0, fy - N // 2))))
    return sp
if __name__ == '__main__':
    os.makedirs(OUT, exist_ok=True); n = 0
    for l in open(REPO + '/game/includes/data/puzzle_pals.txt'):
        if l.startswith('#') or '|' not in l: continue
        r = l.rstrip('\n').split('|')
        if r[10].startswith('whimsy') or (ONLY and r[1] not in ONLY): continue
        make(r).save(OUT + '/' + r[1] + '.png'); n += 1
    print(n)
