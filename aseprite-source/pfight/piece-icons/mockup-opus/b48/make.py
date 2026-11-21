#!/usr/bin/env python3
"""Batch b48 hand-drawn creature piece icons: Piglet Squeal, Warthog,
Muskrat Crew, Capybara Herd
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
SNOUT = {'p': (236, 150, 150), 'P': (250, 200, 194), 'n': (140, 56, 70)}     # pig snout
MOUTH = {'m': (122, 40, 40), 'r': (200, 84, 84)}
TUSK = {'t': (248, 240, 214), 'c': (176, 150, 108)}                             # tusk ivory + shade
MUD = {'u': (128, 86, 52), 'U': (168, 122, 78), 'z': (86, 56, 36)}
RAT = {'s': (146, 102, 66), 'S': (188, 140, 94), 'z': (96, 64, 42), 'o': (236, 146, 40), 'p': (226, 140, 140)}
REED = {'g': (120, 176, 70), 'j': (78, 124, 48), 'J': (170, 210, 110), 'y': (150, 96, 56)}
POISON = {'v': (150, 80, 190), 'V': (200, 150, 230), 'q': (96, 44, 130), 'W': (236, 216, 248)}
WATER = {'W': (210, 238, 250), 'w': (140, 200, 232), 'x': (70, 140, 196)}
YUZU = {'o': (240, 150, 30), 'O': (255, 206, 96), 'g': (90, 150, 60)}
EAR = {'p': (214, 136, 120)}                                                    # capybara inner ear
BIRD = {'b': (70, 62, 66), 'a': (128, 118, 112), 'y': (240, 176, 40), 'r': (200, 64, 60)}

ICONS = [
    # slug, type, extra palette
    ('piglet-squeal-piglet-charge', 'hurt', dict(SNOUT, **MUD)),
    ('piglet-squeal-squeal-dodge', 'guard', dict(SNOUT, **MOUTH)),
    ('piglet-squeal-root-kick', 'trick', dict(SNOUT, **MUD)),
    ('piglet-squeal-behind-knees', 'hurt', dict(SNOUT)),
    ('warthog-tusk-bash', 'hurt', dict(SNOUT, **TUSK)),
    ('warthog-mud-shove', 'trick', dict(SNOUT, **TUSK, **MUD)),
    ('warthog-bristle-mane', 'guard', dict(SNOUT, **TUSK)),
    ('warthog-tusk-lift', 'hurt', dict(SNOUT, **TUSK)),
    ('muskrat-crew-lodge-wall', 'guard', dict(RAT, **WATER)),
    ('muskrat-crew-reed-mat', 'guard', dict(RAT, **WATER)),
    ('muskrat-crew-musk-gnaw', 'hurt', dict(RAT, **REED)),
    ('muskrat-crew-musk-cloud', 'trick', dict(RAT, **POISON)),
    ('capybara-herd-herd-shove', 'hurt', dict(EAR)),
    ('capybara-herd-calm-float', 'guard', dict(EAR, **WATER, **YUZU)),
    ('capybara-herd-water-slap', 'trick', dict(EAR, **WATER)),
    ('capybara-herd-riding-birds', 'heal', dict(BIRD, **EAR)),
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
