#!/usr/bin/env python3
"""Perch sprites drawn AS jigsaw pieces (36x36): body = the pal's own picture cell, tabs/blanks from its shape code, knob style, face, feet.
usage: piece_perch.py <repo> <outdir> [key1,key2,...]   (default: every non-whimsy pal)"""
import sys, os, re, hashlib, math
import numpy as np
from PIL import Image
REPO, OUT = sys.argv[1], sys.argv[2]
ONLY = set(sys.argv[3].split(',')) if len(sys.argv) > 3 else None
INK = (43, 28, 38)
J = REPO + '/game/assets/img/jigsaw/'
PL = {}
for f in os.listdir(J + 'places'):
    k = f[:-4]; PL['pl-' + k[:44] + '-' + hashlib.md5(k.encode()).hexdigest()[:6]] = J + 'places/' + f
_c = {}
def pic(slug):
    p = PL.get(slug) or J + slug + '.jpg'
    if p not in _c: _c[p] = Image.open(p).convert('RGB')
    return _c[p]
def cell(slug, piece):
    im = pic(slug); c, r = map(int, piece.split('-')); cw, ch = im.width // 12, im.height // 8
    return im.crop((c * cw, r * ch, c * cw + cw, r * ch + ch))
BX0, BY0, BS = 9, 11, 18        # body box (x0,y0,size) on the 36 canvas
def tabmask(style, u, v):       # u across the side (centre 0), v outward from the edge (>=0 out)
    if style == 'round':   return (u*u + (v-2.2)**2) <= 3.1**2
    if style == 'keyhole': return (abs(u) <= 1.0 and 0 <= v <= 2.2) or (u*u + (v-3.8)**2 <= 2.7**2)
    if style == 'peg':     return abs(u) <= 2.2 and 0 <= v <= 4.2
    if style == 'tri':     return 0 <= v <= 5 and abs(u) <= 3.2 * (1 - v / 5.4)
    if style == 'double':  return ((abs(u) - 2.6)**2 + (v-2.0)**2) <= 2.1**2 or (abs(u) <= 1 and 0 <= v <= 1.5)
    if style == 'hook':    return (abs(u) <= 1.2 and 0 <= v <= 4.2) or (1 <= u <= 3.6 and 3 <= v <= 4.6)
    return (u*u + (v-2.2)**2) <= 3.1**2
def sides(shape):               # top,right,bottom,left : F/T/B
    fam, code = shape.split('-')
    if fam == 'corner': return ['F', code[0], code[1], 'F']   # flat top+left
    if fam == 'edge':   return ['F', code[0], code[1], code[2]]
    return list(code)
def render(row):
    slug, key, name, rar, calling, g, n, h, l, piece, shape, knob = row[:12]
    sd = sides(shape); S = 36
    cellim = cell(slug, piece).resize((BS, BS), Image.BOX if pic(slug).width > 400 else Image.LANCZOS)
    cellim = np.array(cellim).astype(float)
    # posterize + lift so the picture reads at 18px
    m = cellim.mean(2, keepdims=True); cellim = np.clip(m + (cellim - m) * 1.25, 0, 255)
    body = np.zeros((S, S), bool); fill = np.zeros((S, S, 3)); hole = np.zeros((S, S), bool)
    body[BY0:BY0 + BS, BX0:BX0 + BS] = True
    def sample(x, y):
        return cellim[min(BS-1, max(0, y - BY0)), min(BS-1, max(0, x - BX0))]
    for y in range(S):
        for x in range(S): fill[y, x] = sample(x, y)
    cx = BX0 + BS / 2; cy = BY0 + BS / 2
    for si, t in enumerate(sd):
        if t == 'F': continue
        for y in range(S):
            for x in range(S):
                X, Y = x + .5, y + .5
                if si == 0: u, v = X - cx, BY0 - Y              # top: out = up
                elif si == 1: u, v = Y - cy, X - (BX0 + BS)     # right
                elif si == 2: u, v = X - cx, Y - (BY0 + BS)     # bottom
                else: u, v = Y - cy, BX0 - X                    # left
                if t == 'T' and tabmask(knob, u, v): body[y, x] = True
                if t == 'B' and tabmask(knob, u, -v + 0.0 + 0.0) and v < 0: hole[y, x] = True
                if t == 'B' and v < 0 and tabmask(knob, u, -v - 0.0): hole[y, x] = True
    body &= ~hole
    # feet
    feet = np.zeros((S, S), bool)
    fy = BY0 + BS + (4 if sd[2] == 'T' else 0)
    for fx in (BX0 + 2, BX0 + BS - 6):
        feet[BY0 + BS - 1:BY0 + BS + 3, fx:fx + 4] = True
    feet &= ~body
    allm = body | feet
    img = np.zeros((S, S, 4), np.uint8)
    # shade: top-left highlight, bottom-right shade 1px inside the body
    for y in range(S):
        for x in range(S):
            if body[y, x]:
                c = fill[y, x].copy()
                up = not body[y-1, x] if y > 0 else True; lf = not body[y, x-1] if x > 0 else True
                dn = not body[y+1, x] if y < S-1 else True; rt = not body[y, x+1] if x < S-1 else True
                if up or lf: c = c * .72 + 255 * .28
                if dn or rt: c = c * .72
                img[y, x] = [*np.clip(c, 0, 255).astype(np.uint8), 255]
    for y in range(S):
        for x in range(S):
            if feet[y, x]: img[y, x] = [*INK, 255] if False else [92, 64, 56, 255]
    # outline
    ol = np.zeros((S, S), bool)
    for y in range(S):
        for x in range(S):
            if not allm[y, x] and any(0 <= y+dy < S and 0 <= x+dx < S and allm[y+dy, x+dx] for dy, dx in ((1,0),(-1,0),(0,1),(0,-1))): ol[y, x] = True
    oc = INK
    if rar == 'rare': oc = (170, 95, 40)
    for y in range(S):
        for x in range(S):
            if ol[y, x]: img[y, x] = [*oc, 255]
    # uncommon: coloured seam accent (picture's most saturated tone) as a 1px ribbon across the bottom of the body
    # face
    def P(x, y, c):
        if 0 <= x < S and 0 <= y < S: img[y, x] = [*c, 255]
    ey = BY0 + 6
    for ex in (BX0 + 4, BX0 + BS - 7):
        for dx in range(4):
            for dy in range(-1, 4): P(ex + dx - 0, ey + dy, (255, 252, 240))
        for dx in (1, 2):
            for dy in (0, 1, 2): P(ex + dx, ey + dy, INK)
        P(ex + 1, ey, (255, 255, 255))
    my = BY0 + 10
    for mx, mdy in ((BX0+6, 0), (BX0+7, 1), (BX0+8, 1), (BX0+9, 1), (BX0+10, 1), (BX0+11, 0)): P(mx, my + mdy, INK)
    for bx in (BX0 + 2, BX0 + BS - 4): P(bx, ey + 3, (255, 150, 150)); P(bx+1, ey + 3, (255, 150, 150))
    if rar == 'uncommon':
        acc = tuple(int(v) for v in np.clip(cellim.reshape(-1, 3)[np.argmax(cellim.reshape(-1, 3).max(1) - cellim.reshape(-1, 3).min(1))] * 1.0, 0, 255))
        for x in range(BX0 + 1, BX0 + BS - 1): P(x, BY0 + BS - 2, acc)
    if rar == 'rare':
        for sx, sy in ((5, 8), (30, 12), (28, 5), (6, 22)): P(sx, sy, (255, 240, 170)); P(sx+1, sy, (255, 240, 170)); P(sx, sy+1, (255,240,170)); P(sx-1, sy, (255,240,170)); P(sx, sy-1, (255,240,170))
    # drop shadow under feet
    for x in range(BX0 + 1, BX0 + BS - 1):
        if img[34, x, 3] == 0 and (x + 34) % 1 == 0: img[34, x] = [60, 40, 70, 90]
    return Image.fromarray(img, 'RGBA')
if __name__ == '__main__':
    os.makedirs(OUT, exist_ok=True); n = 0
    for l in open(REPO + '/game/includes/data/puzzle_pals.txt'):
        if l.startswith('#') or '|' not in l: continue
        r = l.rstrip('\n').split('|')
        if r[10].startswith('whimsy') or (ONLY and r[1] not in ONLY): continue
        render(r).save(OUT + '/' + r[1] + '.png'); n += 1
    print(n)
