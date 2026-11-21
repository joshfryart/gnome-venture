#!/usr/bin/env python3
"""Batch b40 hand-drawn creature piece icons: Marsh Spark Swarm, Foxfire Wisp,
Smooth Snake + Water Snake (mockup, not wired into the game).

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
GLOW = {'y': (255, 226, 110), 'Y': (255, 248, 200)}                    # marsh-light glow
FOX = {'g': (150, 226, 104), 'f': (214, 255, 176), 'h': (82, 156, 70)}   # foxfire green
WOOD = {'w': (150, 104, 64), 'W': (190, 146, 96), 'x': (98, 66, 42)}     # rotten stump
MIST = {'a': (214, 234, 240), 'A': (246, 252, 252), 'o': (160, 192, 208)}
POISON = {'p': (150, 80, 190), 'P': (200, 150, 230), 'q': (96, 44, 130)}
MOUTH = {'m': (122, 40, 40), 'M': (210, 90, 96)}
EYE = {'e': (250, 214, 74)}
STONE = {'s': (164, 158, 148), 'S': (206, 200, 188), 'z': (116, 110, 104)}
WATER = {'a': (128, 204, 232), 'A': (214, 244, 252), 'o': (64, 142, 192)}
REED = {'r': (120, 170, 70), 'R': (176, 214, 112), 'j': (76, 118, 46), 'n': (140, 92, 52), 'U': (184, 132, 84), 'x': (92, 60, 36)}
MUD = {'u': (150, 112, 70), 'U': (188, 152, 104), 'x': (104, 74, 46)}

SNAKE = dict(MOUTH, **EYE)

ICONS = [
    # slug, type, extra palette
    ('marsh-spark-swarm-spark-shell', 'guard', dict(GLOW)),
    ('marsh-spark-swarm-mist-cover', 'guard', dict(GLOW, **MIST)),
    ('marsh-spark-swarm-spark-sting', 'hurt', dict(GLOW)),
    ('marsh-spark-swarm-blink-storm', 'hurt', dict(GLOW)),
    ('foxfire-wisp-rot-glow', 'hurt', dict(FOX, **WOOD, **POISON)),
    ('foxfire-wisp-glow-cap-shell', 'guard', dict(FOX, **WOOD)),
    ('foxfire-wisp-spore-beckon', 'trick', dict(FOX, **WOOD)),
    ('foxfire-wisp-stump-snare', 'trick', dict(FOX, **WOOD)),
    ('smooth-snake-coil-squeeze', 'hurt', dict(SNAKE, **WOOD)),
    ('smooth-snake-scale-slip', 'guard', dict(SNAKE)),
    ('smooth-snake-hiss-feint', 'trick', dict(SNAKE, **POISON)),
    ('smooth-snake-stone-sunning', 'heal', dict(SNAKE, **STONE)),
    ('water-snake-water-snap', 'hurt', dict(SNAKE, **WATER)),
    ('water-snake-tight-coil', 'guard', dict(SNAKE)),
    ('water-snake-bank-slide', 'trick', dict(SNAKE, **MUD, a=(128, 204, 232), A=(214, 244, 252), o=(64, 142, 192))),
    ('water-snake-reed-weave', 'guard', dict(SNAKE, **REED)),
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
