#!/usr/bin/env python3
"""make_sheet.py : the contact sheets of the v48 pass (../sheet/): every face at 4 x (strip) and 2 x (hand), and a cluster of composed pieces of the three owners at 1 x, 3 x (strip) and 2 x (hand)."""
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import pv48
from PIL import Image
OUT = os.path.join(pv48.V, 'sheet'); os.makedirs(OUT, exist_ok=True)
BG = (58, 42, 34, 255)
def faces(size, k):
    c = pv48.CFG[size]; t = c['T']; cw, ch = c['BW'] + 4, c['BH'] + 4
    o = Image.new('RGBA', (cw * 7, ch * 3), BG)
    for r, (pre, names) in enumerate((('tile', pv48.TYPES), ('foe', pv48.TYPES), ('env', pv48.KINDS))):
        for i, n in enumerate(names): o.alpha_composite(pv48.P(size, '%s-%s-%s' % (pre, size, n)).crop((t - 2, t - 2, c['W'] - t + 2, c['H'] - t + 2)), (i * cw, r * ch))
    return o.resize((o.width * k, o.height * k), Image.NEAREST)
def cluster(size, k, bg=BG):
    cl = pv48.cluster(size); o = Image.new('RGBA', cl.size, bg); o.alpha_composite(cl)
    return o.resize((o.width * k, o.height * k), Image.NEAREST)
faces('strip', 4).save(os.path.join(OUT, 'faces-strip-4x.png'), optimize=True); faces('hand', 2).save(os.path.join(OUT, 'faces-hand-2x.png'), optimize=True)
cluster('strip', 1).save(os.path.join(OUT, 'cluster-strip-1x.png'), optimize=True); cluster('strip', 3).save(os.path.join(OUT, 'cluster-strip-3x.png'), optimize=True)
cluster('hand', 2).save(os.path.join(OUT, 'cluster-hand-2x.png'), optimize=True); cluster('strip', 1, (236, 224, 196, 255)).save(os.path.join(OUT, 'cluster-strip-1x-light.png'), optimize=True)
d = pv48.P('strip', 'digits-strip'); d.resize((d.width * 6, d.height * 6), Image.NEAREST).save(os.path.join(OUT, 'digits-strip-6x.png'), optimize=True)
print('sheets:', sorted(os.listdir(OUT)))
