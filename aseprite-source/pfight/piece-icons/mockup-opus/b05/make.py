#!/usr/bin/env python3
"""Batch b05 hand-drawn creature piece icons (Pincer Earwig, Cave Glowworm).

Pixels live in grids/<slug>-32.txt and grids/<slug>-20.txt (one char per pixel,
each size drawn on its own). This script maps chars to colours via ../pix.py
(1px ink edge + cream halo on 32px) and writes:

    ico-<slug>.png  (32x32)   ico-<slug>-s.png  (20x20)   sheet.png

Run:  python3 make.py
      python3 make.py --peek SLUG OUT.png   (8x preview of one icon)
"""
import os
import sys
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, '..'))
import pix  # noqa: E402

# shared chars: . clear, k ink, C cream, H white gloss, G gold
# type chars:   B base, L light, D dark, E darkest
MOON = {'M': (246, 240, 206), 'm': (214, 204, 160)}
GLOW = {'q': (226, 255, 246), 'g': (140, 232, 214), 'j': (64, 170, 168)}   # glowworm light
SILK = {'W': (232, 236, 240), 'w': (176, 186, 200)}                         # sticky thread
BEAD = {'W': (232, 236, 240), 'w': (176, 186, 200), 'q': (226, 255, 246), 'g': (140, 232, 214)}

ICONS = [
    ('earwig-pincer', 'hurt', {}),
    ('earwig-tuck-under', 'guard', {}),
    ('earwig-night-scuttle', 'trick', dict(MOON)),
    ('earwig-pincer-fold', 'guard', {}),
    ('cave-glowworm-glow-lure', 'trick', dict(GLOW, **SILK)),
    ('cave-glowworm-sticky-thread', 'hurt', dict(GLOW, **SILK)),
    ('cave-glowworm-dim', 'guard', dict(GLOW, **SILK)),
    ('cave-glowworm-light-snare', 'hurt', dict(GLOW, **SILK)),
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
    Z = 5
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
        sh.alpha_composite(up(a, Z), (x, 16))
        if b is not None:
            sh.alpha_composite(up(b, Z), (x, 16 * 2 + 32 * Z))
        y3 = 16 * 3 + 32 * Z + 20 * Z
        sh.alpha_composite(up(a, 2), (x, y3))
        if b is not None:
            sh.alpha_composite(up(b, 2), (x + 70, y3))
            sh.alpha_composite(b, (x + 70 + 44, y3))
        sh.alpha_composite(a, (x + 70 + 44 + 24, y3))
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
