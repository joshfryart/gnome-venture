#!/usr/bin/env python3
"""Batch b59 hand-drawn creature piece icons: Golden Mole, Raven Pair,
Jungle Crow, Tern Squadron
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
SAND = {'s': (226, 196, 128), 'S': (246, 224, 166), 'z': (176, 140, 80)}   # loose sand
CLAW = {'y': (172, 150, 118), 'Y': (220, 204, 170)}                        # horn claws
NOSE = {'n': (200, 138, 120), 'N': (236, 184, 164), 'm': (130, 74, 64), 'p': (200, 84, 84)}  # nose shield + mouth
BEAK = {'q': (64, 62, 76), 'Q': (118, 116, 134), 'M': (172, 170, 188)}     # corvid bill
TERNB = {'r': (214, 58, 40), 'R': (246, 124, 84), 'o': (140, 30, 24)}     # tern bill/feet
CAP = {'c': (54, 50, 62)}                                                  # tern black cap
FRUIT = {'r': (204, 48, 70), 'R': (240, 116, 128), 'o': (128, 24, 50)}     # fig / fruit
LEAF = {'g': (110, 176, 64), 'j': (64, 118, 44), 'J': (166, 212, 104)}      # jungle leaf
FISH = {'f': (178, 198, 214), 'F': (234, 242, 248), 'v': (96, 122, 146)}   # silver fish
MOUTH = {'m': (122, 40, 40), 'p': (200, 84, 84)}

ICONS = [
    # slug, type, extra palette
    ('golden-mole-sand-swim', 'hurt', dict(SAND, **NOSE, **CLAW)),
    ('golden-mole-velvet-rest', 'heal', dict(SAND, **NOSE, **CLAW)),
    ('golden-mole-dune-dive', 'guard', dict(SAND, **NOSE, **CLAW)),
    ('golden-mole-sightless-lunge', 'hurt', dict(SAND, **NOSE, **CLAW)),
    ('raven-pair-wing-block', 'guard', dict(BEAK, **CLAW)),
    ('raven-pair-pair-peck', 'hurt', dict(BEAK, **CLAW)),
    ('raven-pair-croak-sign', 'trick', dict(BEAK, **CLAW, **MOUTH)),
    ('raven-pair-two-voices', 'trick', dict(BEAK, **CLAW, **MOUTH)),
    ('jungle-crow-canopy-caw', 'hurt', dict(BEAK, **CLAW, **MOUTH)),
    ('jungle-crow-fruit-feast', 'heal', dict(BEAK, **CLAW, **FRUIT, **LEAF)),
    ('jungle-crow-leaf-mantle', 'guard', dict(BEAK, **CLAW, **LEAF)),
    ('jungle-crow-bill-snatch', 'hurt', dict(BEAK, **CLAW)),
    ('tern-squadron-dive-strike', 'hurt', dict(TERNB, **CAP)),
    ('tern-squadron-wing-wheel', 'trick', dict(TERNB, **CAP)),
    ('tern-squadron-fish-snatch', 'hurt', dict(TERNB, **CAP, **FISH)),
    ('tern-squadron-fly-past-cut', 'hurt', dict(TERNB, **CAP)),
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
