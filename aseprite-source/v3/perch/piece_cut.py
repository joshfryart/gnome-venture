#!/usr/bin/env python3
"""Perch sprite cut INTO a jigsaw piece: the creature is the picture on a 24px piece (shape-coded tabs/blanks, knob), backdrop = its own picture cell, softened.
usage: piece_cut.py <repo> <outdir> [key1,key2,...]   (default: every non-whimsy pal)"""
import sys, os
import numpy as np
from PIL import Image
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import piece_mask as pm
REPO, OUT = pm.REPO, pm.OUT
YARD = os.environ.get('PIECE_YARD') == '1'   # 1: 64px yard/normal pal picture from aseprite-source/v3/pals-creature/; else 36px perch
if YARD: BS, B0, S, K, FIT, SRC = 48, 8, 64, 1.5, 46, REPO + '/aseprite-source/v3/pals-creature/'
else:    BS, B0, S, K, FIT, SRC = 24, 6, 36, 1.0, 22, REPO + '/game/assets/img/pals/perch/'
def make(row):
    slug, key, rar, piece_, shape, knob = row[0], row[1], row[3], row[9], row[10], row[11]
    sp = Image.open(SRC + key + '.png').convert('RGBA')
    sd = pm.sides(shape)
    # backdrop = the pal's picture cell, softened toward cream so the creature reads
    im = pm.pic(slug); c, r = map(int, piece_.split('-')); cw, ch = im.width // 12, im.height // 8
    cl = np.array(im.crop((c*cw, r*ch, c*cw+cw, r*ch+ch)).resize((BS, BS), Image.BOX if im.width > 400 else Image.LANCZOS)).astype(float)
    cl = cl * 0.5 + np.array([244, 232, 206]) * 0.5
    body = np.zeros((S, S), bool); hole = np.zeros((S, S), bool); body[B0:B0+BS, B0:B0+BS] = True
    cx = cy = B0 + BS / 2
    for si, t in enumerate(sd):
        if t == 'F': continue
        for y in range(S):
            for x in range(S):
                X, Y = x + .5, y + .5
                u, v = [(X-cx, B0-Y), (Y-cy, X-(B0+BS)), (X-cx, Y-(B0+BS)), (Y-cy, B0-X)][si]
                if t == 'T' and pm.tab(knob, u / K, v / K): body[y, x] = True
                if t == 'B' and v < 0 and pm.tab(knob, u / K, -v / K): hole[y, x] = True
    body &= ~hole
    # creature: crop to bbox, fit 22x22, crisp (box + palette snap)
    a = sp.crop(sp.getbbox()); s = min(FIT / a.width, FIT / a.height, 1.0)
    sz = (max(1, round(a.width * s)), max(1, round(a.height * s)))
    src = np.array(a).astype(float); pre = src.copy(); pre[..., :3] *= pre[..., 3:] / 255
    b = np.array(Image.fromarray(np.clip(pre, 0, 255).astype('uint8'), 'RGBA').resize(sz, Image.BOX)).astype(float)
    al = b[..., 3]; rgb = np.where(al[..., None] > 0, b[..., :3] / np.maximum(al[..., None], 1) * 255, 0)
    op = src[src[..., 3] > 200][:, :3]; cols, cnt = np.unique(op.astype('uint8'), axis=0, return_counts=True)
    pal = cols[np.argsort(-cnt)[:40]].astype(float)
    idx = ((rgb.reshape(-1, 3)[:, None, :] - pal[None]) ** 2).sum(2).argmin(1)
    cre = pal[idx].reshape(sz[1], sz[0], 3); cmask = al >= 110
    ox, oy = B0 + (BS - sz[0]) // 2, B0 + BS - 1 - sz[1]
    out = np.zeros((S, S, 4), np.uint8)
    for y in range(S):
        for x in range(S):
            if body[y, x]:
                col = cl[min(BS-1, max(0, y-B0)), min(BS-1, max(0, x-B0))].copy()
                up = not body[y-1, x]; lf = not body[y, x-1]; dn = not body[min(S-1, y+1), x]; rt = not body[y, min(S-1, x+1)]
                if up or lf: col = col * .8 + 255 * .2
                if dn or rt: col = col * .82
                out[y, x] = [*np.clip(col, 0, 255).astype(np.uint8), 255]
    for yy in range(sz[1]):
        for xx in range(sz[0]):
            if cmask[yy, xx] and body[oy+yy, ox+xx]: out[oy+yy, ox+xx] = [*cre[yy, xx].astype(np.uint8), 255]
    oc = (170, 95, 40) if rar == 'rare' else pm.INK
    for y in range(S):
        for x in range(S):
            if not body[y, x] and any(0 <= y+dy < S and 0 <= x+dx < S and body[y+dy, x+dx] for dy, dx in ((1,0),(-1,0),(0,1),(0,-1))): out[y, x] = [*oc, 255]
    return Image.fromarray(out, 'RGBA')
if __name__ == '__main__':
    os.makedirs(OUT, exist_ok=True); n = 0
    for l in open(REPO + '/game/includes/data/puzzle_pals.txt'):
        if l.startswith('#') or '|' not in l: continue
        r = l.rstrip('\n').split('|')
        if r[10].startswith('whimsy') or (pm.ONLY and r[1] not in pm.ONLY): continue
        make(r).save(OUT + '/' + r[1] + '.png'); n += 1
    print(n)
