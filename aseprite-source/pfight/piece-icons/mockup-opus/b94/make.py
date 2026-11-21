#!/usr/bin/env python3
"""Batch b94 hand-drawn creature piece icons: Leatherback, Ibex Patriarch,
Bearded Pig, Albatross
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
WATER = {'W': (214, 236, 246), 'w': (156, 200, 226), 'v': (98, 146, 180)}     # sea / bubbles
SPECK = {'u': (226, 236, 240)}                                               # leatherback speckles
HORN = {'n': (214, 196, 150), 'N': (244, 234, 200), 'o': (150, 124, 84)}     # ibex horn (bone)
BEARD = {'f': (150, 128, 100), 'F': (196, 176, 140), 'x': (102, 84, 64)}     # ibex beard
GOATEYE = {'y': (244, 196, 60)}                                              # amber eye
GOATEYE_Y = {'y': (226, 120, 36)}                                            # eye on yellow
ROCK = {'r': (150, 144, 136), 'R': (192, 186, 176), 'q': (98, 92, 88)}       # cliff rock
SNOUT = {'p': (236, 150, 150), 'P': (250, 200, 194), 'n': (140, 56, 70)}     # pig snout
WHISK = {'W': (246, 240, 226), 'w': (206, 196, 176), 'v': (150, 138, 118)}   # pig beard
MUD = {'m': (118, 82, 52), 'M': (160, 116, 76), 'Q': (82, 56, 36)}           # mud
NUT = {'o': (164, 106, 48), 'O': (210, 154, 86), 'j': (106, 66, 30)}         # nut
FRUIT = {'f': (196, 52, 92), 'F': (244, 124, 150), 'x': (126, 30, 64),
         'g': (110, 176, 70), 'j': (66, 120, 44)}                             # fig + leaf
PLUME = {'a': (228, 230, 222), 'A': (250, 250, 244), 'z': (164, 166, 162)}   # white head/belly
BEAK = {'y': (240, 206, 160), 'Y': (255, 238, 210), 'o': (184, 136, 96)}     # albatross beak
SQUID = {'p': (226, 140, 180), 'P': (250, 200, 222), 'q': (160, 76, 126)}    # squid

ICONS = [
    # slug, type, extra palette
    ('leatherback-ocean-glide', 'guard', dict(WATER, **SPECK)),
    ('leatherback-deep-slip', 'trick', dict(WATER, **SPECK)),
    ('leatherback-flipper-heave', 'hurt', dict(WATER, **SPECK)),
    ('leatherback-oar-sweep', 'hurt', dict(WATER, **SPECK)),
    ('ibex-patriarch-horn-sweep', 'hurt', dict(HORN, **BEARD, **GOATEYE)),
    ('ibex-patriarch-cliff-leap', 'trick', dict(HORN, **BEARD, **GOATEYE_Y, **ROCK)),
    ('ibex-patriarch-ledge-stand', 'guard', dict(HORN, **BEARD, **GOATEYE, **ROCK)),
    ('ibex-patriarch-herd-stare', 'trick', dict(HORN, **BEARD, **GOATEYE_Y)),
    ('bearded-pig-beard-barge', 'hurt', dict(SNOUT, **WHISK)),
    ('bearded-pig-mud-plough', 'hurt', dict(SNOUT, **WHISK, **MUD)),
    ('bearded-pig-nut-shield', 'guard', dict(SNOUT, **WHISK, **NUT)),
    ('bearded-pig-fruit-snatch', 'hurt', dict(SNOUT, **WHISK, **FRUIT)),
    ('albatross-squid-snatch', 'hurt', dict(BEAK, **PLUME, **SQUID)),
    ('albatross-sea-rest', 'heal', dict(BEAK, **PLUME, **WATER)),
    ('albatross-dynamic-soar', 'guard', dict(BEAK, **PLUME)),
    ('albatross-wing-nap', 'heal', dict(BEAK, **PLUME)),
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
