#!/usr/bin/env python3
"""Batch b51 hand-drawn creature piece icons: Giant Banded Snail, Fire Ant
Raiders, Army Ant Column, Sandfly Cloud
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
SNAIL = {'S': (206, 186, 150), 's': (164, 140, 108), 'z': (110, 90, 70)}   # snail skin
SLIME = {'W': (214, 236, 246), 'w': (156, 200, 226), 'v': (104, 150, 184)}
DUST = {'u': (196, 170, 120), 'U': (226, 208, 166)}                         # leaf-litter dust
BOOT = {'n': (140, 92, 56), 'N': (186, 130, 82), 'm': (92, 58, 38)}         # gnome boot
SUGAR = {'W': (250, 250, 244), 'w': (206, 210, 220)}                        # sugar cube
FIRE = {'f': (236, 60, 30), 'F': (255, 160, 50)}                            # sting flame
ROCK = {'r': (150, 146, 136), 'R': (194, 190, 178), 'q': (98, 94, 90)}      # obstacle stone
BLOOD = {'r': (196, 36, 40), 'R': (240, 104, 96), 'm': (122, 20, 30)}
SALT = {'W': (244, 248, 250)}
DUSK = {'p': (120, 70, 120), 'P': (170, 100, 140)}                          # dusk sky band

ICONS = [
    # slug, type, extra palette
    ('giant-banded-snail-banded-slam', 'hurt', dict(SNAIL, **DUST)),
    ('giant-banded-snail-shell-spiral', 'guard', dict(SNAIL)),
    ('giant-banded-snail-slime-sheet', 'trick', dict(SNAIL, **SLIME)),
    ('giant-banded-snail-striped-roll', 'hurt', dict(SNAIL, **DUST)),
    ('fire-ant-raiders-fire-sting', 'hurt', dict(FIRE)),
    ('fire-ant-raiders-ankle-tangle', 'trick', dict(BOOT)),
    ('fire-ant-raiders-raider-rush', 'hurt', dict(DUST)),
    ('fire-ant-raiders-sugar-trail', 'trick', dict(SUGAR)),
    ('army-ant-column-column-wall', 'guard', {}),
    ('army-ant-column-flank-slip', 'trick', dict(ROCK)),
    ('army-ant-column-mandible-wave', 'hurt', {}),
    ('army-ant-column-endless-file', 'guard', {}),
    ('sandfly-cloud-sand-bite', 'hurt', dict(WING, r=(196, 36, 40))),
    ('sandfly-cloud-blood-meal', 'heal', dict(WING, **BLOOD)),
    ('sandfly-cloud-salt-haze', 'guard', dict(SALT, w=(163, 199, 216))),
    ('sandfly-cloud-pinprick-dusk', 'hurt', dict(DUSK, W=(214, 234, 240), w=(163, 199, 216))),
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
