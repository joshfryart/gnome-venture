#!/usr/bin/env python3
"""Copy P3 (odd-size UI, v3/ui-odd) and P2 (flower layers, v3/flowers) art into the game tree.
P3 -> game/assets/img/<folder>/<name>.png (size must equal the file it replaces, else it is skipped and reported).
P2 -> game/assets/img/flowers-pixel/<name>.png (the code already reads this dir; sizes must match too).
No pink border here (weak.txt covers ph/ items only). Prints the list of changed PNGs; --zip <path> writes a flat zip of them.
Usage (from aseprite-source/v3): python3 rollout/export_p2p3.py [--dry] [--zip upload-zips/x.zip]"""
import os, sys, glob, shutil, zipfile
from PIL import Image
HERE = os.path.dirname(os.path.abspath(__file__)); V3 = os.path.dirname(HERE)
GAME = os.path.abspath(os.path.join(V3, '..', '..', 'game', 'assets', 'img'))
dry = '--dry' in sys.argv
zpath = sys.argv[sys.argv.index('--zip') + 1] if '--zip' in sys.argv else None
jobs = []   # (src, dst)
for d in ['items', 'fx', 'steps', 'roadkinds', 'ui']:
    for dst in sorted(glob.glob(os.path.join(GAME, d, '*.png'))):
        n = os.path.basename(dst)
        cands = [os.path.join(V3, 'ui-odd', d, n)] + glob.glob(os.path.join(V3, 'ui-odd', n[:-4], n))
        src = next((c for c in cands if os.path.exists(c)), None)
        if src: jobs.append((src, dst, 'p3'))
        else: print('NO SOURCE', d + '/' + n)
for src in sorted(glob.glob(os.path.join(V3, 'flowers', '*.png'))):
    n = os.path.basename(src)
    if n.startswith('_'): continue
    jobs.append((src, os.path.join(GAME, 'flowers-pixel', n), 'p2'))
ok = []; bad = 0
for src, dst, pk in jobs:
    s = Image.open(src)
    if os.path.exists(dst) and Image.open(dst).size != s.size:
        print('SIZE MISMATCH', os.path.relpath(dst, GAME), Image.open(dst).size, '->', s.size); bad += 1; continue
    if not dry: os.makedirs(os.path.dirname(dst), exist_ok=True); shutil.copyfile(src, dst)
    ok.append((src, dst, pk))
print(f'{len(ok)} copied ({sum(1 for o in ok if o[2]=="p3")} UI, {sum(1 for o in ok if o[2]=="p2")} flower), {bad} skipped{" [dry]" if dry else ""}')
if zpath and not dry:
    with zipfile.ZipFile(zpath, 'w', zipfile.ZIP_DEFLATED) as z:
        for src, dst, pk in ok: z.write(dst, os.path.basename(dst))
    print('zip', zpath, len(ok), 'entries')
