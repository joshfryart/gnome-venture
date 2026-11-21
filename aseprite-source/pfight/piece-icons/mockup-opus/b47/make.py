#!/usr/bin/env python3
"""Batch b47 hand-drawn creature piece icons: Night Adder, Termite Column,
Stickleback Shoal, Fisher (mockup, not wired into the game).

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
MOUTH = {'r': (200, 64, 72), 'm': (122, 32, 44)}                            # snake mouth / tongue
ROAD = {'s': (150, 140, 128), 'S': (186, 176, 160), 'z': (104, 96, 88)}    # night road
TERMITE = {'p': (224, 200, 152), 'P': (244, 228, 192), 'q': (170, 140, 96),  # pale soft body
           'o': (198, 120, 48), 'O': (232, 166, 84), 'n': (128, 66, 26)}     # soldier head
MUD = {'u': (150, 108, 70), 'U': (186, 146, 100), 'y': (100, 70, 46)}      # mud / clay
FISH = {'r': (214, 58, 48), 'R': (244, 120, 96), 'm': (140, 30, 30),       # red throat
        'b': (96, 190, 230), 'W': (226, 240, 246)}                          # blue eye, silver
WEED = {'g': (120, 176, 70), 'j': (70, 118, 44), 'J': (172, 212, 108)}     # nest weed
WATER = {'w': (150, 206, 232), 'v': (92, 150, 196)}
FUR = {'f': (214, 196, 160), 'F': (240, 226, 196)}                         # pale muzzle / chest
QUILL = {'q': (228, 216, 186), 'Q': (250, 244, 226), 'y': (128, 98, 70),   # porcupine
         'Y': (164, 130, 94), 'z': (84, 62, 44)}
BRANCH = {'t': (126, 88, 54), 'T': (168, 124, 78), 'x': (86, 58, 36),
          'g': (120, 176, 70), 'j': (70, 118, 44)}

ICONS = [
    # slug, type, extra palette
    ('night-adder-fang-strike', 'hurt', dict(MOUTH)),
    ('night-adder-quick-fangs', 'hurt', dict(MOUTH)),
    ('night-adder-night-coil', 'guard', dict(MOUTH)),
    ('night-adder-road-sit', 'guard', dict(MOUTH, **ROAD)),
    ('termite-column-mound-wall', 'guard', dict(TERMITE)),
    ('termite-column-soldier-bite', 'hurt', dict(TERMITE)),
    ('termite-column-clay-armour', 'guard', dict(TERMITE)),
    ('termite-column-tunnel-crowd', 'hurt', dict(TERMITE)),
    ('stickleback-shoal-spine-flick', 'hurt', dict(FISH)),
    ('stickleback-shoal-shoal-wave', 'trick', dict(FISH, **WATER)),
    ('stickleback-shoal-fin-jab', 'hurt', dict(FISH)),
    ('stickleback-shoal-nest-guard', 'guard', dict(FISH, **WEED)),
    ('fisher-quill-slide', 'guard', dict(FUR, **QUILL)),
    ('fisher-fisher-bite', 'hurt', dict(FUR, r=(200, 84, 84), m=(122, 40, 40), R=(236, 140, 136))),
    ('fisher-tree-drop', 'trick', dict(FUR, **BRANCH)),
    ('fisher-flip-hunt', 'hurt', dict(FUR, **QUILL)),
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
        if a is not None:
            sh.alpha_composite(up(a, Z), (x, 16))
        if b is not None:
            sh.alpha_composite(up(b, Z), (x, 16 * 2 + 32 * Z))
        y3 = 16 * 3 + 32 * Z + 20 * Z
        if a is not None:
            sh.alpha_composite(up(a, 2), (x, y3))
            sh.alpha_composite(a, (x + 72 + 48 + 28, y3))
        if b is not None:
            sh.alpha_composite(up(b, 2), (x + 72, y3))
            sh.alpha_composite(b, (x + 72 + 48, y3))
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
