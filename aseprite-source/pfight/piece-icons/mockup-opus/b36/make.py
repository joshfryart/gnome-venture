#!/usr/bin/env python3
"""Batch b36 hand-drawn creature piece icons: Carrion Beetle Crew, Tumblebug
Troupe, Earwig Matron, Firefly Flicker (mockup, not wired into the game).

The pixels live in grids/<slug>-32.txt and grids/<slug>-20.txt: one char per
pixel (each size drawn on its own, the 20px is not a downscale).
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
SHELL = {'x': (62, 54, 66), 'X': (120, 110, 130)}                          # black beetle shell
CLUB = {'o': (236, 140, 36), 'O': (252, 200, 110)}                        # orange antenna clubs
SOIL = {'b': (150, 104, 64), 'N': (190, 146, 98), 'n': (102, 68, 44), 'm': (58, 38, 30)}
EGG = {'e': (214, 204, 176)}                                               # pale egg shade
POISON = {'p': (150, 80, 190), 'P': (200, 150, 230), 'q': (96, 44, 130)}
FIRE = {'r': (214, 70, 70), 'R': (244, 142, 128),                         # firefly hood
        'y': (196, 240, 96), 'Y': (240, 255, 190), 'j': (122, 176, 52)}   # lantern glow
WING = {'W': (214, 234, 240), 'w': (163, 199, 216), 'v': (98, 136, 160)}

CB = dict(SHELL, **CLUB)
ICONS = [
    # slug, type, extra palette
    ('carrion-beetle-crew-carrion-feast', 'heal', dict(CB, **EGG)),
    ('carrion-beetle-crew-burying-shell', 'guard', dict(CB, **SOIL)),
    ('carrion-beetle-crew-mandible-nip', 'hurt', dict(CB, **POISON)),
    ('carrion-beetle-crew-bury-drop', 'trick', dict(CB, **SOIL)),
    ('tumblebug-troupe-tumble-shove', 'hurt', dict(SHELL)),
    ('tumblebug-troupe-ball-shield', 'guard', dict(SHELL)),
    ('tumblebug-troupe-roll-out', 'trick', dict(SHELL)),
    ('tumblebug-troupe-ball-relay', 'hurt', dict(SHELL)),
    ('earwig-matron-brood-tend', 'heal', dict(EGG)),
    ('earwig-matron-egg-shell-ward', 'guard', dict(EGG)),
    ('earwig-matron-matron-pincer', 'hurt', dict(EGG)),
    ('earwig-matron-egg-cushion', 'heal', dict(EGG)),
    ('firefly-flicker-flash-strike', 'hurt', dict(FIRE, **SHELL, **WING)),
    ('firefly-flicker-blink-out', 'trick', dict(FIRE, **SHELL, **WING)),
    ('firefly-flicker-lamp-glow', 'guard', dict(FIRE, **SHELL, **WING)),
    ('firefly-flicker-lamp-wink', 'trick', dict(FIRE, **SHELL, **WING)),
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
    # two banks of 10 columns so the sheet stays viewable
    per = 10
    banks = [rows[i:i + per] for i in range(0, len(rows), per)]
    bh = 32 * Z + 20 * Z + 32 * 2 + 16 * 4
    W = per * cell + 16
    H = len(banks) * bh + 16
    sh = Image.new('RGBA', (W, H), (84, 64, 50, 255))
    for bi, bank in enumerate(banks):
        y0 = 16 + bi * bh
        for i, (a, b) in enumerate(bank):
            x = 16 + i * cell
            if a is not None:
                sh.alpha_composite(up(a, Z), (x, y0))
            if b is not None:
                sh.alpha_composite(up(b, Z), (x, y0 + 16 + 32 * Z))
            y3 = y0 + 16 * 2 + 32 * Z + 20 * Z
            if a is not None:
                sh.alpha_composite(up(a, 2), (x, y3))
                sh.alpha_composite(a, (x + 72 + 48 + 28, y3))
            if b is not None:
                sh.alpha_composite(up(b, 2), (x + 72, y3))
                sh.alpha_composite(b, (x + 72 + 48, y3))
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
