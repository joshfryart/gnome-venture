#!/usr/bin/env python3
"""Batch b41 hand-drawn creature piece icons: Night Heron, Egret Flock,
Macaque Troop, Tanuki
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
HERON = {'n': (40, 46, 66), 'N': (78, 90, 118),          # black cap / back
         'r': (214, 44, 44),                                # red eye
         'b': (64, 66, 78), 'q': (128, 130, 146),           # dark bill
         'y': (214, 190, 84), 'Y': (240, 222, 130),         # yellow legs
         'W': (236, 240, 244)}                              # white plume
FISH = {'S': (206, 220, 228), 's': (146, 168, 184), 'z': (92, 110, 128)}
EGRET = {'g': (186, 128, 20), 'q': (255, 214, 110),       # bill shade / shine
         'n': (50, 50, 60),                                  # black legs
         'W': (240, 244, 246), 'w': (196, 206, 214)}        # white plumes
MACAQUE = {'f': (222, 104, 104), 'F': (244, 150, 140), 'd': (160, 60, 64)}
NUTS = {'a': (176, 112, 54), 'A': (216, 158, 92), 'o': (112, 66, 34)}
TANUKI = {'m': (70, 48, 38), 'M': (116, 86, 64)}           # dark mask / stripes
GRASS = {'g': (120, 176, 70), 'j': (78, 124, 48)}

ICONS = [
    # slug, type, extra palette
    ('night-heron-night-stab', 'hurt', dict(HERON)),
    ('night-heron-stalk-still', 'trick', dict(HERON)),
    ('night-heron-hooded-wing', 'guard', dict(HERON)),
    ('night-heron-gulp-whole', 'hurt', dict(HERON, **FISH)),
    ('egret-flock-spear-jab', 'hurt', dict(EGRET)),
    ('egret-flock-flock-stab', 'hurt', dict(EGRET)),
    ('egret-flock-white-wing-screen', 'guard', dict(EGRET)),
    ('egret-flock-stepping-stride', 'trick', dict(EGRET)),
    ('macaque-troop-troop-shove', 'hurt', dict(MACAQUE)),
    ('macaque-troop-cheek-dump', 'trick', dict(MACAQUE, **NUTS)),
    ('macaque-troop-troop-huddle', 'guard', dict(MACAQUE)),
    ('macaque-troop-quick-fingers', 'hurt', dict(MACAQUE)),
    ('tanuki-belly-drum', 'trick', dict(TANUKI)),
    ('tanuki-leaf-disguise', 'guard', dict(TANUKI)),
    ('tanuki-rolling-barge', 'hurt', dict(TANUKI)),
    ('tanuki-stump-pose', 'guard', dict(TANUKI, **GRASS)),
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
    """one creature per row (4 icons), last row the generic type icons.
    each cell: 32px at 5x, 20px at 5x, then 2x and 1x of both underneath."""
    ref_dir = os.path.join(HERE, '..', '..', '..', '..', '..', 'game', 'assets', 'img', 'pfight')
    refs = ['hurt', 'guard', 'heal', 'trick']
    Z = 5
    cw = 32 * Z + 20 * Z + 12 + 24
    ch = 32 * Z + 12 + 64 + 24
    items = [(icon(s, 32), icon(s, 20)) for s, t, _ in ICONS]
    items += [(Image.open(os.path.join(ref_dir, 'ico-%s.png' % r)).convert('RGBA'),
               Image.open(os.path.join(ref_dir, 'ico-%s-s.png' % r)).convert('RGBA')) for r in refs]
    cols = 4
    nrows = (len(items) + cols - 1) // cols
    W, H = cols * cw + 16, nrows * ch + 16
    sh = Image.new('RGBA', (W, H), (84, 64, 50, 255))
    for i, (a, b) in enumerate(items):
        x, y = 16 + (i % cols) * cw, 16 + (i // cols) * ch
        if i >= len(ICONS) and i % cols == 0:
            sh.alpha_composite(Image.new('RGBA', (W, 4), (240, 228, 200, 255)), (0, y - 14))
        sh.alpha_composite(up(a, Z), (x, y))
        if b is not None:
            sh.alpha_composite(up(b, Z), (x + 32 * Z + 12, y))
        y2 = y + 32 * Z + 12
        sh.alpha_composite(up(a, 2), (x, y2))
        if b is not None:
            sh.alpha_composite(up(b, 2), (x + 72, y2))
            sh.alpha_composite(b, (x + 72 + 48, y2))
        sh.alpha_composite(a, (x + 72 + 48 + 28, y2))
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
