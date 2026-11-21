#!/usr/bin/env python3
"""Batch b75 hand-drawn creature piece icons: Booby Colony, Tamandua,
Carpenter Bee, Caracal
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
WING = {'W': (214, 234, 240), 'w': (163, 199, 216), 'v': (98, 136, 160)}
# Booby Colony: bright blue feet, grey-blue bill, pale eye, guano
BOOBY = {'f': (64, 186, 214), 'F': (150, 226, 240), 'g': (24, 112, 150),     # blue feet
         'n': (120, 140, 158), 'N': (176, 192, 204), 'm': (78, 92, 110),      # bill
         'y': (250, 248, 222)}                                                 # pale eye
GUANO = {'W': (240, 238, 228), 'w': (196, 192, 178), 'v': (148, 142, 128)}
# Tamandua: black vest, pink tongue, branch
VEST = {'v': (60, 50, 54), 'V': (98, 86, 90)}
TONGUE = {'p': (222, 112, 132), 'P': (248, 168, 178), 'q': (156, 60, 82)}
WOOD = {'w': (150, 102, 58), 'W': (194, 144, 86), 'x': (98, 64, 38)}
# Carpenter bee: wings, sawdust, flower
DUST = {'a': (224, 190, 128), 'A': (246, 224, 172), 'o': (178, 140, 86)}
FLOWER = {'p': (232, 118, 168), 'P': (250, 176, 208), 'q': (166, 62, 114)}
# Caracal: pink ear lining, nose, scrub, bird
CAT = {'p': (220, 150, 140), 'n': (150, 70, 70)}
SCRUB = {'j': (92, 128, 58), 'J': (150, 186, 92), 'i': (60, 88, 40)}
MOON = {'M': (250, 236, 170)}

ICONS = [
    # slug, type, extra palette
    ('booby-colony-blue-foot-strut', 'trick', dict(BOOBY)),
    ('booby-colony-plunge', 'hurt', dict(BOOBY, **WING)),
    ('booby-colony-guano-cover', 'guard', dict(BOOBY, **GUANO)),
    ('booby-colony-rude-stamp', 'trick', dict(BOOBY)),
    ('tamandua-claw-hook', 'hurt', dict(VEST)),
    ('tamandua-tree-hug', 'guard', dict(VEST, **WOOD)),
    ('tamandua-tongue-flick', 'trick', dict(VEST, **TONGUE)),
    ('tamandua-tail-hang', 'guard', dict(VEST, **WOOD)),
    ('carpenter-bee-wood-drill', 'hurt', dict(WING, **WOOD, **DUST)),
    ('carpenter-bee-nectar-sip', 'heal', dict(WING, **FLOWER)),
    ('carpenter-bee-sawdust-cover', 'guard', dict(WING, **DUST)),
    ('carpenter-bee-hollow-tap', 'hurt', dict(WING, **WOOD)),
    ('caracal-bird-leap', 'hurt', dict(CAT, W=(240, 240, 236), w=(180, 186, 196))),
    ('caracal-dusk-rest', 'heal', dict(CAT, **MOON)),
    ('caracal-scrub-cover', 'guard', dict(CAT, **SCRUB)),
    ('caracal-tuft-flick', 'trick', dict(CAT)),
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
