#!/usr/bin/env python3
"""Copy finished v3 art into the game tree (game/assets/img/<folder>/<name>.png, same names as the old art).
Weak images (rollout/weak.txt) get a bright pink (#ff2bd6) 2 px border in the COPY only; source art is untouched.
Usage: python3 rollout/export_game.py [--dry]   (run from aseprite-source/v3)   Re-run any time; idempotent."""
import json, os, sys, shutil
from PIL import Image
HERE = os.path.dirname(os.path.abspath(__file__)); V3 = os.path.dirname(HERE)
GAME = os.path.abspath(os.path.join(V3, '..', '..', 'game', 'assets', 'img'))
PINK = (255, 43, 214, 255)
LISTS = ['run1', 'run2-part1', 'run2-part2', 'run2-part3', 'run3-part1', 'run3-part2', 'run3-part3', 'run4-part1', 'run4-part2', 'run4-part3']
weak = {l.strip() for l in open(os.path.join(HERE, 'weak.txt')) if l.strip() and not l.startswith('#')}
dry = '--dry' in sys.argv
def pinkify(im):
    im = im.convert('RGBA'); w, h = im.size; px = im.load()
    for y in range(h):
        for x in range(w):
            if x < 2 or y < 2 or x >= w - 2 or y >= h - 2: px[x, y] = PINK
    return im
n = nw = skipped = new = 0
for L in LISTS:
    for it in json.load(open(os.path.join(HERE, L + '.json'))):
        f, name = it['folder'], it['name']
        if f == 'flowers': skipped += 1; continue
        src = os.path.join(V3, 'items', 'final', f, name + '.png'); dst = os.path.join(GAME, f, name + '.png')
        if not os.path.exists(src): print('MISSING', f, name); continue
        if not os.path.exists(dst): new += 1
        key = f + '/' + name
        if not dry:
            os.makedirs(os.path.dirname(dst), exist_ok=True)
            if key in weak: pinkify(Image.open(src)).save(dst); nw += 1
            else: shutil.copyfile(src, dst)
        else: nw += key in weak
        n += 1
print(f'{n} copied ({nw} with pink border, {new} new files, {skipped} flowers skipped){" [dry]" if dry else ""}')
