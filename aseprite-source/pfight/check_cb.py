#!/usr/bin/env python3
"""Tell-apart check: composite each tile, simulate colour vision, report the closest pair per view."""
import sys, itertools
import numpy as np
from PIL import Image
d = sys.argv[1]
T = ['hurt', 'guard', 'heal', 'charm', 'soothe', 'trick', 'item']
F = ['body', 'mind', 'craft']
M = {  # Machado 2009, severity 1.0, linear RGB
 'deuteranopia': [[.367322, .860646, -.227968], [.280085, .672501, .047413], [-.011820, .042940, .968881]],
 'protanopia':   [[.152286, 1.052583, -.204868], [.114503, .786281, .099216], [-.003882, -.048116, 1.051998]],
 'tritanopia':   [[1.255528, -.076749, -.178779], [-.078411, .930809, .147602], [.004733, .691367, .303900]]}
def lin(a): a = a / 255.; return np.where(a <= .04045, a / 12.92, ((a + .055) / 1.055) ** 2.4)
def srgb(a): a = np.clip(a, 0, 1); return np.where(a <= .0031308, a * 12.92, 1.055 * a ** (1 / 2.4) - .055) * 255
def sim(rgb, v):
    if v == 'gray':
        y = (lin(rgb) @ np.array([.2126, .7152, .0722]))[..., None]
        return srgb(np.repeat(y, 3, -1))
    return srgb(lin(rgb) @ np.array(M[v]).T)
def L(n): return Image.open(f'{d}/{n}').convert('RGBA')
def flat(im, bg=(61, 42, 28)):
    b = Image.new('RGBA', im.size, bg + (255,)); b.alpha_composite(im); return np.asarray(b.convert('RGB'), float)
def tile(k, t):
    b = L(f'tile-{k}-{t}.png'); b.alpha_composite(L('ico-%s.png' % t if k == 'hand' else 'ico-%s-s.png' % t), (37, 9) if k == 'hand' else (21, 14)); return flat(b)
def lum(rgb): return lin(rgb) @ np.array([.2126, .7152, .0722])
bad = 0
for k in ('hand', 'strip'):
    for v in ('none', 'gray', 'deuteranopia', 'protanopia', 'tritanopia'):
        ims = {t: tile(k, t) for t in T}
        if v != 'none': ims = {t: sim(a, v) for t, a in ims.items()}
        # features that survive: mean colour, plus structure (pattern = std of luminance and edge density)
        res = []
        for a, b in itertools.combinations(T, 2):
            A, B = ims[a], ims[b]
            col = np.abs(A.reshape(-1, 3).mean(0) - B.reshape(-1, 3).mean(0)).max()
            pa, pb = (np.abs(np.diff(lum(A) , axis=1)).mean(), np.abs(np.diff(lum(B), axis=1)).mean())
            pix = np.abs(A - B).mean()  # per-pixel difference includes pattern differences
            res.append((pix, a, b, col, abs(pa - pb)))
        res.sort()
        print(f'{k:5} {v:13} closest pair by pixel diff: {res[0][1]}/{res[0][2]} = {res[0][0]:.1f}/255 (colour-only gap {res[0][3]:.0f})')
# sockets: shape only, silhouettes of the cavity/peg area never depend on colour
import hashlib
for k in ('hand', 'strip'):
    for kind in ('knob', 'hole'):
        ms = {}
        for f in F:
            a = np.asarray(L(f'sock-{k}-{f}-{kind}.png').convert('RGB'), int)
            ms[f] = (a.sum(-1) > 3 * 200) if kind == 'hole' else (a.sum(-1) < 3 * 70) | (np.abs(a - np.array([242, 228, 192])).sum(-1) < 6)
        for a, b in itertools.combinations(F, 2):
            diff = (ms[a] ^ ms[b]).sum()
            print(f'sock {k} {kind} {a}/{b}: {diff} px differ (shape only)')
            if diff < 12: bad += 1
sys.exit(1 if bad else 0)
