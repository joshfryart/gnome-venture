#!/usr/bin/env bash
# Runs tools/catfish_recolor.py on the grey cat frames: expects 8 coats x 5 frames, check passing, grey identical to template.
set -e
cd "$(dirname "$0")/.."
OUT=$(mktemp -d); trap 'rm -rf "$OUT"' EXIT
python3 tools/catfish_recolor.py --check --out "$OUT" | tee "$OUT.log"
IN=aseprite-source/catfish/test
N=$(ls "$OUT"/cf-cat-*-*.png | wc -l)
[ "$N" = 40 ] || { echo "FAIL: expected 40 outputs, got $N"; exit 1; }
for c in grey black white orange cream brown silver-blue ginger-red; do
  for f in idleA pounce catch nap stalk; do [ -f "$OUT/cf-cat-$c-$f.png" ] || { echo "FAIL missing $c $f"; exit 1; }; done
done
python3 -I - "$IN" "$OUT" <<'P'
import sys, numpy as np
from PIL import Image
i, o = sys.argv[1:]
for f in ('idleA','pounce','catch','nap','stalk'):
    a = np.array(Image.open(f'{i}/cf-cat-grey-{f}.png').convert('RGBA')); b = np.array(Image.open(f'{o}/cf-cat-grey-{f}.png').convert('RGBA'))
    assert (a == b).all(), 'grey != template ' + f
    ws = np.array(Image.open(f'{o}/cf-cat-white-{f}.png').convert('RGBA')); bk = np.array(Image.open(f'{o}/cf-cat-black-{f}.png').convert('RGBA'))
    assert (ws[...,3] == a[...,3]).all() and (bk[...,3] == a[...,3]).all(), 'alpha changed'
    for im in (ws, bk):
        assert len({tuple(p) for p in im.reshape(-1,4) if p[3]} - {tuple(p) for p in a.reshape(-1,4)}) >= 4, 'tones not swapped'
print('ok')
P
grep -q FAILED "$OUT.log" && exit 1
rm -f "$OUT.log"; echo "catfish_recolor: ok (40 files)"
