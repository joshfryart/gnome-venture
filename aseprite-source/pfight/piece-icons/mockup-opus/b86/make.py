#!/usr/bin/env python3
"""Batch b86 hand-drawn creature piece icons: Caribou Bull, Black Jaguar,
Goliath Frog + Frigatebird
(mockup, not wired into the game).

The pixels live in grids/<slug>-32.txt and grids/<slug>-20.txt: one char per
pixel, drawn by hand (each size drawn on its own, the 20px is not a downscale).
This script only maps chars to colours, adds the 1px ink edge (+ cream halo on
32px, like gen_pfight.finish_icon) and writes:

    ico-<slug>.png  (32x32)   ico-<slug>-s.png  (20x20)   sheet.png

Run:  python3 make.py            (writes next to this file)
      python3 make.py --peek SLUG OUT.png   (8x preview of one icon)
"""
import os
import sys
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, '..'))
import pix  # noqa: E402

# shared chars: . clear, k ink, C cream, H white gloss, G gold
# type chars:   B base, L light, D dark, E darkest  (from gen_pfight TYPES)
VELVET = {'V': (204, 168, 118), 'v': (156, 116, 74), 'u': (106, 76, 50)}      # velvet antler
JAG = {'y': (250, 214, 60), 'm': (120, 30, 36), 'r': (214, 92, 96)}          # eye glow, mouth
NIGHT = {'n': (60, 56, 92), 'N': (96, 92, 140)}                              # night shadow
BRANCH = {'b': (150, 108, 66), 'c': (98, 68, 42)}
FROG = {'y': (246, 206, 70), 'm': (120, 36, 44), 'r': (226, 112, 124)}       # eye, mouth, tongue
HAT = {'R': (204, 52, 48), 'Q': (138, 30, 30)}                               # squashed gnome hat
BIRD = {'r': (222, 46, 46), 'R': (252, 128, 112), 'Q': (150, 24, 30),        # throat pouch
        'b': (200, 190, 168), 'c': (128, 118, 104)}                          # hooked beak
FISH = {'f': (150, 190, 206), 'F': (222, 238, 244), 'e': (92, 128, 150)}

ICONS = [
    # slug, type, extra palette
    ('caribou-bull-rut-charge', 'hurt', dict(VELVET)),
    ('caribou-bull-antler-hook', 'trick', dict(VELVET)),
    ('caribou-bull-velvet-rack', 'guard', dict(VELVET)),
    ('caribou-bull-head-shake', 'hurt', dict(VELVET)),
    ('black-jaguar-night-lunge', 'hurt', dict(JAG)),
    ('black-jaguar-shadow-slip', 'trick', dict(JAG, **NIGHT)),
    ('black-jaguar-night-coat', 'guard', dict(JAG, **NIGHT)),
    ('black-jaguar-night-drop', 'hurt', dict(JAG, **BRANCH)),
    ('goliath-frog-belly-slam', 'hurt', dict(FROG)),
    ('goliath-frog-gulp-down', 'trick', dict(FROG, **HAT)),
    ('goliath-frog-rubbery-skin', 'guard', dict(FROG)),
    ('goliath-frog-sit-heavy', 'hurt', dict(FROG, **HAT)),
    ('frigatebird-air-snatch', 'hurt', dict(BIRD, **FISH)),
    ('frigatebird-chase-down', 'hurt', dict(BIRD)),
    ('frigatebird-storm-glide', 'guard', dict(BIRD)),
    ('frigatebird-fish-rob', 'trick', dict(BIRD, **FISH)),
]


def load(slug, size):
    p = os.path.join(HERE, 'grids', '%s-%d.txt' % (slug, size))
    if not os.path.exists(p):
        return None
    g = [l.rstrip('\n') for l in open(p) if l.strip()]
    assert len(g) == size, (p, len(g))
    return g


def pal_for(t, extra):
    p = pix.type_pal(t)
    p.update(extra)
    return p


def icon(slug, size):
    for s, t, extra in ICONS:
        if s == slug:
            g = load(slug, size)
            return None if g is None else pix.render(g, pal_for(t, extra), halo=(size == 32))
    raise KeyError(slug)


def up(im, z):
    return im.resize((im.size[0] * z, im.size[1] * z), Image.NEAREST)


def sheet(out):
    ref_dir = os.path.join(HERE, '..', '..', '..', '..', '..', 'game', 'assets', 'img', 'pfight')
    refs = ['hurt', 'guard', 'heal', 'trick']
    Z = 6
    cell = 32 * Z + 16
    rows = []
    for s, t, _ in ICONS:
        rows.append((icon(s, 32), icon(s, 20)))
    for r in refs:
        rows.append((Image.open(os.path.join(ref_dir, 'ico-%s.png' % r)).convert('RGBA'),
                     Image.open(os.path.join(ref_dir, 'ico-%s-s.png' % r)).convert('RGBA')))
    n = len(rows)
    # row 1: 32px at 6x; row 2: 20px at 6x; row 3: both at 2x and 1x (true-ish size)
    W = n * cell + 16
    H = 32 * Z + 20 * Z + 32 * 2 + 32 + 16 * 5
    sh = Image.new('RGBA', (W, H), (84, 64, 50, 255))
    sep = Image.new('RGBA', (4, H), (240, 228, 200, 255))
    for i, (a, b) in enumerate(rows):
        x = 16 + i * cell
        sh.alpha_composite(up(a, Z), (x, 16))
        if b is not None:
            sh.alpha_composite(up(b, Z), (x, 16 * 2 + 32 * Z))
        y3 = 16 * 3 + 32 * Z + 20 * Z
        sh.alpha_composite(up(a, 2), (x, y3))
        if b is not None:
            sh.alpha_composite(up(b, 2), (x + 72, y3))
            sh.alpha_composite(b, (x + 72 + 48, y3))
        sh.alpha_composite(a, (x + 72 + 48 + 28, y3))
    sh.alpha_composite(sep, (16 + len(ICONS) * cell - 10, 0))
    sh.save(out)


def main():
    if len(sys.argv) > 1 and sys.argv[1] == '--peek':
        slug, out = sys.argv[2], sys.argv[3]
        a, b = icon(slug, 32), icon(slug, 20)
        Z = 8
        W = 32 * Z + 20 * Z + 32 * 2 + 20 * 2 + 32 + 20 + 7 * 10
        sh = Image.new('RGBA', (W, 32 * Z + 20), (84, 64, 50, 255))
        x = 10
        for im, z in ((a, Z), (b, Z), (a, 2), (b, 2), (a, 1), (b, 1)):
            if im is not None:
                sh.alpha_composite(up(im, z), (x, 10))
                x += im.size[0] * z + 10
        sh.save(out)
        return
    for s, t, _ in ICONS:
        for size, suf in ((32, ''), (20, '-s')):
            im = icon(s, size)
            if im is None:
                print('missing', s, size)
                continue
            im.save(os.path.join(HERE, 'ico-%s%s.png' % (s, suf)))
    sheet(os.path.join(HERE, 'sheet.png'))
    print('ok')


if __name__ == '__main__':
    main()
