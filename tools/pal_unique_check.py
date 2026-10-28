#!/usr/bin/env python3
"""Puzzle Pals uniqueness check: flags pal pairs that look too alike.
Usage: tools/pal_unique_check.py [PREFIX ...]   (key prefixes, default all pals; e.g. pl-cwy)
Compares every pair inside the chosen set (and each chosen pal against ALL pals): silhouette overlap (IoU of the 64x64 alpha masks)
and colour overlap (share of body pixels whose colour is within a small distance of the other pal's palette). Exit 1 if any pair is flagged."""
import glob, os, sys
from PIL import Image
D = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'game', 'assets', 'img', 'puzzles', 'pals')
IOU_MAX, PAL_MAX = 0.86, 0.80
def load(f):
    im = Image.open(f).convert('RGBA'); px = im.load(); w, h = im.size
    mask = {(x, y) for y in range(h) for x in range(w) if px[x, y][3]}
    cols = {}
    for p in mask:
        c = px[p][:3]; q = (c[0] >> 4, c[1] >> 4, c[2] >> 4); cols[q] = cols.get(q, 0) + 1
    return mask, cols
def pal_overlap(a, b):
    ta = sum(a.values()); return sum(n for q, n in a.items() if q in b) / ta
def main():
    pre = sys.argv[1:]
    allp = {os.path.basename(f)[:-4]: f for f in glob.glob(os.path.join(D, '*.png')) if not os.path.basename(f).startswith('_')}
    data = {k: load(f) for k, f in allp.items()}
    chosen = [k for k in sorted(data) if not pre or any(k.startswith(p) for p in pre)]
    bad = 0; seen = set()
    for k in chosen:
        ma, ca = data[k]
        for j in sorted(data):
            if j == k or (j, k) in seen: continue
            seen.add((k, j))
            mb, cb = data[j]
            iou = len(ma & mb) / max(1, len(ma | mb))
            po = min(pal_overlap(ca, cb), pal_overlap(cb, ca))
            if iou > IOU_MAX and po > PAL_MAX:
                print('TOO ALIKE %s ~ %s  silhouette %.2f  palette %.2f' % (k, j, iou, po)); bad += 1
    print('%d pals checked, %d flagged' % (len(chosen), bad)); sys.exit(1 if bad else 0)
main()
