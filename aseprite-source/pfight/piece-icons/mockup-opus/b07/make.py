#!/usr/bin/env python3
"""Batch b07: hand-drawn creature piece icons (Bog Leech, Grumpy Lemming).

Pixels live in grids/<slug>-32.txt and grids/<slug>-20.txt (one char per pixel,
each size drawn on its own). This script maps chars to colours via ../pix.py and
writes ico-<slug>.png (32x32), ico-<slug>-s.png (20x20) and sheet.png.

Run:  python3 make.py                    (writes next to this file)
      python3 make.py --peek SLUG OUT.png  (8x preview of one icon)
"""
import os
import sys
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
PARENT = os.path.dirname(HERE)
sys.path.insert(0, PARENT)
import pix  # noqa: E402

# shared chars: . clear, k ink, C cream, H white gloss, G gold
# type chars:   B base, L light, D dark, E darkest  (from gen_pfight TYPES)
MOUTH = {'m': (122, 40, 40), 'r': (200, 84, 84), 'M': (74, 22, 30)}
POISON = {'p': (150, 206, 64), 'P': (206, 238, 120), 'q': (86, 132, 40)}
MUD = {'u': (138, 100, 64), 'U': (176, 138, 92), 'n': (92, 64, 40)}
BLOOD = {'R': (214, 64, 64), 'S': (246, 150, 140), 'Q': (140, 34, 40)}
SNOW = {'W': (244, 250, 255), 'w': (200, 224, 240), 'v': (150, 184, 212)}
NOSE = {'n': (232, 140, 150)}
TEETH = {'W': (255, 252, 240)}

ICONS = [
    # slug, type, extra palette
    ('bog-leech-latch', 'hurt', dict(MOUTH, **POISON)),
    ('bog-leech-slick', 'guard', dict(MOUTH, w=(170, 214, 240))),
    ('bog-leech-drain', 'heal', dict(MOUTH, **BLOOD)),
    ('bog-leech-mire-slide', 'trick', dict(MOUTH, **MUD)),
    ('grumpy-lemming-grumble', 'trick', dict(MOUTH, **NOSE, **TEETH, w=(226, 226, 216), v=(160, 160, 160))),
    ('grumpy-lemming-lemming-bite', 'hurt', dict(MOUTH, **NOSE, **TEETH)),
    ('grumpy-lemming-dig-snow', 'guard', dict(SNOW, n=(232, 140, 150))),
    ('grumpy-lemming-sulk-stare', 'trick', dict(MOUTH, **NOSE, **TEETH, w=(150, 150, 164), v=(104, 104, 120))),
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
    ref_dir = os.path.join(PARENT, '..', '..', '..', '..', 'game', 'assets', 'img', 'pfight')
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
