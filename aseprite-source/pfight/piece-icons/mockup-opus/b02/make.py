#!/usr/bin/env python3
"""Batch b02 hand-drawn creature piece icons (Ant Scouts, Gnat Cloud).

Pixels live in grids/<slug>-32.txt and grids/<slug>-20.txt (one char per pixel,
each size drawn on its own).  This script maps chars to colours via ../pix.py
and writes ico-<slug>.png, ico-<slug>-s.png and sheet.png next to itself.

Run:  python3 make.py
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
WING = {'W': (214, 234, 240), 'w': (163, 199, 216), 'v': (98, 136, 160)}
CRUMB = {'c': (196, 140, 84), 'q': (150, 98, 58), 'Q': (226, 186, 130)}

ICONS = [
    ('ant-scouts-scout-bite', 'hurt', {}),
    ('ant-scouts-ant-trail', 'trick', {}),
    ('ant-scouts-carry-off', 'hurt', dict(CRUMB)),
    ('ant-scouts-scout-sign', 'trick', {'r': (200, 84, 84), 'R': (230, 120, 110)}),
    ('gnat-cloud-whine', 'trick', dict(WING)),
    ('gnat-cloud-scatter', 'guard', dict(WING)),
    ('gnat-cloud-gnat-veil', 'guard', dict(WING, e=(214, 196, 160))),
]


def load(slug, size):
    p = os.path.join(HERE, 'grids', '%s-%d.txt' % (slug, size))
    if not os.path.exists(p):
        return None
    g = [l.rstrip('\n') for l in open(p) if l.strip()]
    assert len(g) == size, (p, len(g))
    return g


def icon(slug, size):
    for s, t, extra in ICONS:
        if s == slug:
            g = load(slug, size)
            if g is None:
                return None
            p = pix.type_pal(t)
            p.update(extra)
            return pix.render(g, p, halo=(size == 32))
    raise KeyError(slug)


def up(im, z):
    return im.resize((im.size[0] * z, im.size[1] * z), Image.NEAREST)


def sheet(out):
    ref_dir = os.path.join(HERE, '..', '..', '..', '..', '..', 'game', 'assets', 'img', 'pfight')
    refs = ['hurt', 'guard', 'heal', 'trick']
    Z = 6
    cell = 32 * Z + 16
    rows = [(icon(s, 32), icon(s, 20)) for s, _, _ in ICONS]
    for r in refs:
        rows.append((Image.open(os.path.join(ref_dir, 'ico-%s.png' % r)).convert('RGBA'),
                     Image.open(os.path.join(ref_dir, 'ico-%s-s.png' % r)).convert('RGBA')))
    n = len(rows)
    W = n * cell + 16
    H = 32 * Z + 20 * Z + 32 * 2 + 32 + 16 * 5
    sh = Image.new('RGBA', (W, H), (84, 64, 50, 255))
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
    sep = Image.new('RGBA', (4, H), (240, 228, 200, 255))
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
    for s, _, _ in ICONS:
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
