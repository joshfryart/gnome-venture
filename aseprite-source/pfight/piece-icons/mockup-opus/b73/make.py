#!/usr/bin/env python3
"""Batch b73 hand-drawn creature piece icons: Willow Grouse Covey, Garfish,
Thorny Devil, Beaded Lizard
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
GROUSE = {'W': (244, 240, 230), 'w': (196, 192, 184),            # white wings/feet
          'r': (222, 52, 40), 'z': (70, 52, 40)}                    # red comb, beak
WILLOW = {'g': (138, 176, 84), 'j': (86, 124, 52), 'J': (186, 214, 124),   # willow leaves
          't': (128, 96, 66), 'T': (90, 66, 46)}                            # twig
GAR = {'n': (118, 176, 96), 'N': (70, 124, 70), 'W': (232, 240, 226)}  # green bone, teeth
WATER = {'u': (120, 184, 224), 'U': (196, 230, 248), 'v': (60, 120, 180)}
DEVIL = {'s': (214, 156, 96), 'S': (240, 200, 140), 'z': (150, 96, 56), 'W': (244, 240, 230)}
DEW = {'u': (120, 196, 236), 'U': (210, 240, 255), 'v': (52, 126, 190)}
BEAD = {'n': (40, 30, 34), 'm': (122, 40, 40), 'r': (200, 84, 84)}     # black beads, mouth
POISON = {'p': (150, 80, 190), 'P': (200, 150, 230), 'q': (96, 44, 130)}

ICONS = [
    # slug, type, extra palette
    ('willow-grouse-covey-covey-flush', 'hurt', dict(GROUSE)),
    ('willow-grouse-covey-wing-whirr', 'hurt', dict(GROUSE)),
    ('willow-grouse-covey-willow-hide', 'guard', dict(GROUSE, **WILLOW)),
    ('willow-grouse-covey-sit-tight', 'guard', dict(GROUSE, **WILLOW)),
    ('garfish-scale-plate', 'guard', dict(GAR)),
    ('garfish-needle-cover', 'guard', dict(GAR)),
    ('garfish-needle-jab', 'hurt', dict(GAR)),
    ('garfish-glint-leap', 'hurt', dict(GAR, **WATER)),
    ('thorny-devil-spike-nip', 'hurt', dict(DEVIL, m=(122, 40, 40))),
    ('thorny-devil-dew-drink', 'heal', dict(DEVIL, **DEW)),
    ('thorny-devil-spike-hide', 'guard', dict(DEVIL)),
    ('thorny-devil-dew-skin', 'heal', dict(DEVIL, **DEW)),
    ('beaded-lizard-bead-flash', 'guard', dict(BEAD)),
    ('beaded-lizard-dodge-roll', 'trick', dict(BEAD)),
    ('beaded-lizard-venom-chew', 'hurt', dict(BEAD, **POISON)),
    ('beaded-lizard-won-t-let-go', 'hurt', dict(BEAD, **POISON, t=(128, 96, 66), T=(90, 66, 46))),
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
