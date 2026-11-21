#!/usr/bin/env python3
"""Batch b03 hand-drawn creature piece icons (Leopard Slug, Sand Flea Pack).

Pixels live in grids/<slug>-32.txt and grids/<slug>-20.txt (one char per
pixel, each size drawn on its own). This script maps chars to colours via the
shared pix renderer (ink edge + cream halo on 32px) and writes:

    ico-<slug>.png  (32x32)   ico-<slug>-s.png  (20x20)   sheet.png

Run:  python3 make.py                    (writes next to this file)
      python3 make.py --peek SLUG OUT.png   (8x preview of one icon)
"""
import os
import sys
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.dirname(HERE))
import pix  # noqa: E402

# shared chars: . clear, k ink, C cream, H white gloss, G gold
# type chars:   B base, L light, D dark, E darkest
SLIME = {'m': (186, 226, 214), 'M': (232, 248, 240), 'n': (118, 170, 166)}
SAND = {'a': (226, 194, 134), 'A': (246, 224, 172), 'z': (170, 134, 86), 'Z': (120, 92, 58)}
POISON = {'p': (148, 200, 58), 'P': (206, 236, 120), 'q': (84, 132, 40)}

ICONS = [
    ('leopard-slug-slime-slick', 'trick', dict(SLIME)),
    ('leopard-slug-slug-lunge', 'hurt', dict(SLIME)),
    ('leopard-slug-thick-slime', 'guard', dict(SLIME)),
    ('leopard-slug-blotch-warn', 'guard', dict(SLIME)),
    ('sand-fleas-flea-hop', 'hurt', dict(SAND)),
    ('sand-fleas-itch', 'hurt', dict(SAND, **POISON)),
    ('sand-fleas-sand-burrow', 'guard', dict(SAND)),
    ('sand-fleas-heap-pile', 'guard', dict(SAND)),
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
            if g is None:
                return None
            bad = pix.check_edges(g, 2 if size == 32 else 1)
            if bad:
                print('edge warning', slug, size, bad[:6])
            return pix.render(g, pal_for(t, extra), halo=(size == 32))
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


def peek(slugs, out):
    Z = 8
    W = 32 * Z + 20 * Z + 32 * 2 + 20 * 2 + 32 + 20 + 7 * 10
    sh = Image.new('RGBA', (W, (32 * Z + 20) * len(slugs)), (84, 64, 50, 255))
    for j, slug in enumerate(slugs):
        a, b = icon(slug, 32), icon(slug, 20)
        x = 10
        for im, z in ((a, Z), (b, Z), (a, 2), (b, 2), (a, 1), (b, 1)):
            if im is not None:
                sh.alpha_composite(up(im, z), (x, 10 + j * (32 * Z + 20)))
                x += im.size[0] * z + 10
    sh.save(out)


def main():
    if len(sys.argv) > 1 and sys.argv[1] == '--peek':
        peek(sys.argv[2].split(','), sys.argv[3])
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
