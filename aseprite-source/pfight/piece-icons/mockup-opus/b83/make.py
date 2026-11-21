#!/usr/bin/env python3
"""Batch b83 hand-drawn creature piece icons: Tufted Lynx, Clam Lurker, Giant Clam,
Desert Tortoise
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
LYNX = {'y': (176, 214, 70), 'n': (214, 120, 130), 'm': (122, 40, 40), 'r': (200, 84, 84),
        'K': (186, 168, 140)}                                                # eyes, nose, mouth, claw shade
FLESH = {'f': (230, 150, 160), 'F': (248, 200, 204), 'd': (170, 88, 108)}  # clam mantle (lurker)
MANTLE = {'v': (150, 100, 196), 'V': (200, 166, 232), 'q': (92, 56, 132),
          'c': (90, 200, 200)}                                               # giant clam mantle + spots
PEARL = {'W': (244, 240, 250), 'w': (196, 190, 220)}
WATER = {'u': (120, 184, 224), 'U': (186, 224, 244), 'x': (60, 120, 176)}
SAND = {'a': (222, 192, 130), 'A': (242, 222, 172), 'o': (172, 138, 86)}
SKIN = {'S': (212, 180, 128), 's': (172, 140, 96), 'z': (112, 88, 60)}    # tortoise skin
FLOWER = {'p': (226, 96, 140), 'P': (246, 170, 196), 'g': (120, 176, 70), 'j': (78, 124, 48),
          'J': (170, 210, 110)}
EYE = {'e': (40, 30, 30)}

ICONS = [
    # slug, type, extra palette
    ('tufted-lynx-ear-twitch', 'trick', dict(LYNX)),
    ('tufted-lynx-lynx-spring', 'hurt', dict(LYNX)),
    ('tufted-lynx-hook-claw', 'hurt', dict(LYNX)),
    ('tufted-lynx-surprise-pounce', 'hurt', dict(LYNX)),
    ('clam-lurker-clamp', 'hurt', dict(FLESH, **PEARL, **EYE)),
    ('clam-lurker-shut-tight', 'guard', dict(FLESH, **EYE)),
    ('clam-lurker-pearl-glint', 'trick', dict(FLESH, **PEARL, **EYE)),
    ('clam-lurker-clam-undertow', 'trick', dict(FLESH, **WATER, **EYE)),
    ('giant-clam-slam-shut', 'hurt', dict(MANTLE, **WATER)),
    ('giant-clam-pearl-blind', 'trick', dict(MANTLE, **PEARL)),
    ('giant-clam-shell-wall', 'guard', dict(MANTLE, **SAND)),
    ('giant-clam-sudden-shut', 'hurt', dict(MANTLE)),
    ('desert-tortoise-shell-in', 'guard', dict(SKIN, **SAND)),
    ('desert-tortoise-beak-nip', 'hurt', dict(SKIN, m=(122, 40, 40), r=(200, 84, 84))),
    ('desert-tortoise-dig-down', 'trick', dict(SKIN, **SAND)),
    ('desert-tortoise-desert-long-patience', 'heal', dict(SKIN, **SAND, **FLOWER)),
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
