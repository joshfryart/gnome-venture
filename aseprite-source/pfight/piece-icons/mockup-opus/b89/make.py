#!/usr/bin/env python3
"""Batch b89 hand-drawn creature piece icons: Elder Mire Toad, Tide Crab Paladin,
Peat Golem, Elder Bramble Wolf
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
EYE = {'e': (24, 16, 10)}
GOLDEYE = {'y': (250, 214, 74), 'Y': (255, 240, 150), 'a': (196, 146, 40)}  # toad eye
MOSS = {'m': (122, 150, 64), 'M': (170, 196, 96), 'n': (78, 100, 44)}       # moss tufts
SLIME = {'W': (222, 246, 214), 'w': (166, 216, 150), 'v': (104, 160, 100)}   # mire slime
GAS = {'p': (150, 128, 170), 'P': (198, 180, 214), 'q': (100, 80, 124)}    # bog gas
FOG = {'W': (246, 248, 250), 'w': (214, 222, 230), 'v': (168, 180, 196)}
MOUTH = {'r': (122, 40, 40), 'R': (200, 84, 84)}
SHELL = {'i': (214, 204, 182), 'I': (244, 238, 222), 'x': (150, 138, 116)}  # barnacle plate
WEED = {'g': (96, 156, 70), 'J': (150, 200, 100), 'j': (52, 100, 50)}      # weed / bramble
POLE = {'o': (150, 100, 56), 'O': (196, 146, 90), 'u': (96, 60, 30)}       # pole / peat stripe
PEAT = {'o': (110, 72, 44), 'O': (150, 104, 66), 'u': (66, 42, 26)}        # cut peat seams
REED = {'s': (206, 186, 110), 'S': (236, 222, 160), 'z': (150, 128, 66)}   # reeds
STEAM = {'W': (240, 242, 244), 'w': (200, 210, 214), 'v': (150, 164, 172)}
FUR = {'f': (206, 204, 196), 'F': (240, 238, 232), 'd': (150, 148, 140)}   # grey beard
BERRY = {'r': (200, 40, 60), 'R': (240, 110, 120)}
TEETH = {'t': (122, 40, 40)}

TOAD = dict(EYE, **GOLDEYE, **MOSS)
AMBER = {'y': (236, 150, 40), 'Y': (252, 200, 90), 'a': (160, 92, 24)}   # eye on yellow
CRAB = dict(EYE, **SHELL, **WEED, a=(196, 146, 40))
GOLEM = dict(EYE, **PEAT, **REED, **GOLDEYE)
WOLF = dict(EYE, **FUR, **WEED, **BERRY, **TEETH, y=(250, 214, 74), Y=(255, 240, 150))

ICONS = [
    # slug, type, extra palette
    ('elder-mire-toad-slime-mantle', 'guard', dict(TOAD, **SLIME)),
    ('elder-mire-toad-mire-belch', 'hurt', dict(TOAD, **GAS, **MOUTH)),
    ('elder-mire-toad-bog-mutter', 'trick', dict(TOAD, **AMBER)),
    ('elder-mire-toad-fog-hush', 'trick', dict(TOAD, **FOG, **AMBER)),
    ('tide-crab-paladin-pauldron-spike', 'guard', CRAB),
    ('tide-crab-paladin-shield-hook', 'hurt', CRAB),
    ('tide-crab-paladin-tide-banner', 'trick', dict(CRAB, **POLE)),
    ('tide-crab-paladin-oath-strike', 'hurt', CRAB),
    ('peat-golem-peat-slump', 'guard', GOLEM),
    ('peat-golem-bog-fist', 'hurt', GOLEM),
    ('peat-golem-reed-bristle', 'guard', GOLEM),
    ('peat-golem-steam-vent', 'heal', dict(GOLEM, **STEAM)),
    ('elder-bramble-wolf-thorn-lunge', 'hurt', WOLF),
    ('elder-bramble-wolf-bramble-snap', 'hurt', WOLF),
    ('elder-bramble-wolf-hedge-dodge', 'guard', WOLF),
    ('elder-bramble-wolf-ruff-shake', 'trick', dict(WOLF, **AMBER)),
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
