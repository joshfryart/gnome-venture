#!/usr/bin/env python3
"""Install the 64x64 art of the 280 Tailor wearables (game/includes/data/wear_items.txt) as their item pictures.

Source: aseprite-source/v3/art-wear-concepts/<REGION>/<category>-<n>-<slug without the region prefix>.png
Game:   game/assets/img/ph/<slug>.png, <slug>-lined.png and <slug>-fine.png (the three ranks are three items; same picture), copied byte for byte.
Idempotent: a file whose sha256 already matches is left alone. The 33 older wearable icons (WEAR_DEFS) are other names and never touched.

usage: python3 tools/install_wear_art.py [--check]   (--check: write nothing, list missing sources and game files that differ; exit 1 if any)
"""
import hashlib
import os
import shutil
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(ROOT, 'aseprite-source/v3/art-wear-concepts')
PH = os.path.join(ROOT, 'game/assets/img/ph')
DATA = os.path.join(ROOT, 'game/includes/data/wear_items.txt')
RANKS = ('', '-lined', '-fine')


def sha(path):
    return hashlib.sha256(open(path, 'rb').read()).hexdigest() if os.path.isfile(path) else ''


def rows():
    for line in open(DATA, encoding='utf-8'):
        line = line.strip()
        if line and not line.startswith('#'):
            c = line.split('|')
            yield c[0], c[1], c[2], c[3]   # slug, region, category, n


def main():
    check = '--check' in sys.argv
    bad = []; wrote = 0; same = 0
    for slug, region, cat, n in rows():
        src = os.path.join(SRC, region, '%s-%s-%s.png' % (cat, n, slug.split('-', 1)[1]))
        if not os.path.isfile(src):
            bad.append('missing source ' + os.path.relpath(src, ROOT)); continue
        h = sha(src)
        for r in RANKS:
            dst = os.path.join(PH, slug + r + '.png')
            if sha(dst) == h:
                same += 1; continue
            if check:
                bad.append('differs ' + os.path.relpath(dst, ROOT)); continue
            shutil.copyfile(src, dst); wrote += 1
            if sha(dst) != h: bad.append('copy failed ' + os.path.relpath(dst, ROOT))
    for b in bad: print(b)
    print('%d written, %d already in place, %d problems' % (wrote, same, len(bad)))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
