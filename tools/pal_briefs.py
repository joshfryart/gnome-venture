#!/usr/bin/env python3
"""Puzzle Pals art helper (build step 1 stub). Usage:
  tools/pal_briefs.py --placeholders [OUTDIR]   write the red-border THIS IS PLACEHOLDER sticker (64 px, tools/gen_placeholder_art.py style) as
        OUTDIR/_placeholder.png (the reference ppal_art_ready() compares against) and one identical copy per authored pal key in puzzle_pals.txt.
        Default OUTDIR = game/assets/img/puzzles/pals. Placeholders are for dev and admin preview only: a picture whose pals are placeholders is NOT art-ready.
  Design briefs (claude/art-briefs/pals/<pic>.md) arrive in a later step."""
import os, shutil, sys
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from gen_placeholder_art import make

def main():
    if '--placeholders' not in sys.argv:
        print(__doc__); sys.exit(2)
    rest = [a for a in sys.argv[1:] if not a.startswith('--')]
    out = rest[0] if rest else os.path.join(HERE, '..', 'game', 'assets', 'img', 'puzzles', 'pals')
    os.makedirs(out, exist_ok=True)
    ref = os.path.join(out, '_placeholder.png')
    make(ref, 64)
    n = 0
    for l in open(os.path.join(HERE, '..', 'game', 'includes', 'data', 'puzzle_pals.txt'), encoding='utf-8'):
        c = l.rstrip('\n').split('|')
        if l.startswith('#') or len(c) != 14: continue
        dst = os.path.join(out, c[1] + '.png')
        if not os.path.exists(dst):   # never overwrite real art
            shutil.copyfile(ref, dst); n += 1
    print('placeholders: %d new, reference %s' % (n, ref))

main()
