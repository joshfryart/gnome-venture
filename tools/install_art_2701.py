#!/usr/bin/env python3
"""2.7.01: install the approved Opus art of the art-2701 batches into game/ (Josh chose 'Opus rich' as THE look).

Each row of INSTALL is (source PNG under aseprite-source/v3/, game path under game/assets/img/, size or None).
size None = copied byte for byte (the source is already the size of the game file); a size = a box downscale of the 64x64 master
(alpha snapped to 0/255, so it stays hard-pixel) for the puzzle-fight tag icons (32x32 hand, 20x20 strip).
The final pass of each batch is used: opus3 where there is one, else the single Opus pass.
Step 2 (2.7.01, after the first install): the 128 pals of art-2701-pals-all (c00..c15), the rest of the wearable icons (batch4, batch4b, batch5: all 33 are hand-drawn now),
the rest / signpost / hazard Trail markers and the Maplewold inn / ferry / spring stop looks (batch4).

usage: python3 tools/install_art_2701.py [--check]   (--check: only report rows whose game file differs from what this would write)
tests/art_2701.sh reads the same table (python3 tools/install_art_2701.py --list) to check every file is in place.
After an install of wearable icons, re-run aseprite-source/v3/gnome-wear/derive_icons.py: it skips the hand-drawn ones (PROTECTED there).
"""
import io
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
V3 = os.path.join(ROOT, 'aseprite-source/v3')
IMG = os.path.join(ROOT, 'game/assets/img')

OPUS = 'art-2701-opus'
B3 = 'art-2701-batch3'
INSTALL = []

# puzzle-fight tag icons (PF_TAG_ICON / TAGICON in pfparts*.js): ico-<name>.png 32x32 and ico-<name>-s.png 20x20 from the 64x64 masters
TAGS = [(OPUS + '/tags/' + n, n) for n in ('jab', 'pierce', 'sting', 'trip', 'bash', 'smash', 'brace', 'roll')]
TAGS += [('art-2701-next8/opus3/' + s, g) for s, g in (('hum', 'hum'), ('lull', 'lull'), ('bond', 'bond'), ('pluck', 'pluck'), ('mend', 'mending'), ('thorns', 'thornhide'))]
for src, g in TAGS:
    INSTALL.append((src + '.png', 'pfight/ico-%s.png' % g, (32, 32)))
    INSTALL.append((src + '.png', 'pfight/ico-%s-s.png' % g, (20, 20)))

# wearable item icons, 64x64 (hand-drawn: derive_icons.py must never overwrite these)
WEAR = [(OPUS + '/wear/' + n, n) for n in ('travel-cloak', 'flood-boots-b', 'work-gloves-b')]
WEAR += [(B3 + '/wear/opus3/' + n, n) for n in ('travel-cloak-lined', 'travel-cloak-fine', 'flood-boots-lined', 'flood-boots-fine',
                                                 'work-gloves-lined', 'work-gloves-fine', 'trail-pack-lined', 'trail-pack-fine')]
WEAR += [('art-2701-next8/opus3/' + n, n) for n in ('trail-pack-b',)]
WEAR += [('art-2701-rest/opus3/wayfarers-hat-b', 'wayfarers-hat-b')]
# step 2 (after the first install): every other base / Lined / Fine and every cut b Lined / Fine is hand-drawn too (33 in all: derive_icons.py makes none of them now).
# batch5 redrew the cut b travel cloak (the hanging cloak): its -b, -b-lined and -b-fine REPLACE next8's travel-cloak-b and batch4b's -b-lined / -b-fine.
WEAR += [('art-2701-batch4/wear/opus3/' + n, n) for n in ('flood-boots', 'work-gloves', 'trail-pack', 'yarn-scarf', 'wayfarers-hat', 'wayfarers-hat-lined',
                                                          'wayfarers-hat-fine', 'yarn-scarf-lined')]
WEAR += [('art-2701-batch4b/wear/opus3/' + n, n) for n in ('flood-boots-b-lined', 'flood-boots-b-fine', 'work-gloves-b-lined', 'work-gloves-b-fine', 'trail-pack-b-lined',
                                                           'trail-pack-b-fine', 'wayfarers-hat-b-lined', 'wayfarers-hat-b-fine', 'yarn-scarf-fine')]
WEAR += [('art-2701-batch5/wear/opus3/' + n, n) for n in ('travel-cloak-b', 'travel-cloak-b-lined', 'travel-cloak-b-fine')]
for src, g in WEAR:
    INSTALL.append((src + '.png', 'ph/%s.png' % g, None))

# avatar layer strips 512x80 (gnome25.php)
for n in ('front-wboots', 'front-pack', 'back-gloves'):
    INSTALL.append((OPUS + '/wear/%s.png' % n, 'gnome25/%s.png' % n, None))

# pal sprites: yard 64x64 = pals/<key>.png (treehouse fallback and the Pal Yard), perch 36x36 = pals/perch/<key>.png (treehouse perches)
PALS = [(OPUS + '/pals/', 'acorn-nip', 'mw-acorn-nip'), (OPUS + '/pals/', 'husk-hopper', 'mh-husk-hopper'), (OPUS + '/pals/', 'bark-badger', 'mw-bark-badger'),
        (OPUS + '/pals/', 'fourwind-finch', 'mw-fourwind-finch'), (OPUS + '/pals/', 'samara-spin', 'mw-samara-spin'), (OPUS + '/pals/', 'sap-drip', 'mw-sap-drip')]
PALS += [(B3 + '/pals/opus3/', s, k) for s, k in (('toadstool-tuck', 'mm-toadstool-tuck'), ('kapok-nook', 'rr-kapok-nook'), ('shell-skip', 'ss-shell-skip'),
                                                    ('stone-sentry', 'mm-stone-sentry'), ('mate-mumble', 'rr-mate-mumble'), ('glimmer-frog', 'rr-glimmer-frog'),
                                                    ('cocopaddle', 'ss-cocopaddle'), ('gatepost-hoot', 'mm-gatepost-hoot'))]
# step 2: the 128 pals of art-2701-pals-all chunks c00..c15 (opus3 = the final pass). Their files are already named by the game key (<key>-yard.png, <key>-perch.png:
# the key of puzzle_pals.txt, pic_slug|key|name, which treehouse_pal_pic() looks up), so slug = key here. worklist.json lists them in chunks of 8.
PALS_ALL = 'art-2701-pals-all'
def _pals_all():
    import json
    wl = json.load(open(os.path.join(V3, PALS_ALL, 'worklist.json')))
    return [('%s/c%02d/opus3/' % (PALS_ALL, c), p['key'], p['key']) for c in range(16) for p in wl[c]]
PALS += _pals_all()
for d, s, k in PALS:
    INSTALL.append((d + s + '-yard.png', 'pals/%s.png' % k, None))
    INSTALL.append((d + s + '-perch.png', 'pals/perch/%s.png' % k, None))

# creature minis and folk portraits (same size as the game picture)
for n in ('mini-blight-mother', 'mini-paper-wasp', 'mini-bog-leech', 'mini-dew-leech', 'mini-basalt-borer', 'mini-clam-lurker'):
    INSTALL.append((B3 + '/creatures/opus3/%s.png' % n, 'mini/%s.png' % n, None))
for n in ('folk-butterfly-1',):
    INSTALL.append((B3 + '/creatures/opus3/%s.png' % n, 'folk/portrait/%s.png' % n, None))
# 2026-11-26: butterfly villager 3 redrawn (clean round head, big eyes): portrait and sprite strip live in folk/redo-butterfly3/out/
INSTALL.append(('folk/redo-butterfly3/out/portrait/folk-butterfly-3.png', 'folk/portrait/folk-butterfly-3.png', None))
INSTALL.append(('folk/redo-butterfly3/out/sprite/folk-butterfly-3.png', 'folk/sprite/folk-butterfly-3.png', None))
# 2026-11-26: moth villager 1 redrawn as a true moth (no snout, comb antennae): the approved portrait now lives in folk/redo-moth1/out/portrait/ (opus3's file is the old bear-snout one)
INSTALL.append(('folk/redo-moth1/out/portrait/folk-moth-1.png', 'folk/portrait/folk-moth-1.png', None))
# 2026-11-26: tortoise portrait 1 redrawn with a domed, scuted shell (folk/redo-tortoise/); the approved file lives there, not in opus3
INSTALL.append(('folk/redo-tortoise/new/portrait/folk-tortoise-1.png', 'folk/portrait/folk-tortoise-1.png', None))

# 2026-11-26: butterfly portrait 2 redrawn with a clean round head and clear eyes (folk/redo-butterfly2/); the approved file lives there
INSTALL.append(('folk/redo-butterfly2/out-portrait/folk-butterfly-2.png', 'folk/portrait/folk-butterfly-2.png', None))

# Trail markers 32x32: trail/mark/<name>.png (all drawn on the Trail map by trail_art.php / trail_tiles.php; tests/trail_marks.php)
for n in ('camp', 'ferry', 'tunnel', 'pass', 'toll', 'sight', 'villager', 'fight'):
    INSTALL.append((OPUS + '/trail/%s.png' % n, 'trail/mark/%s.png' % n, None))
for n in ('haven', 'wonder', 'delve', 'lair', 'overgrown', 'flooded', 'market'):
    INSTALL.append(('art-2701-rest/opus3/trail-%s.png' % n, 'trail/mark/%s.png' % n, None))
# step 2: batch4 rest (the way on into a rest stop), signpost (the first stretch of a side path), hazard (installed, not drawn on the map: no Trail data has a hazard yet)
for n in ('rest', 'signpost', 'hazard'):
    INSTALL.append(('art-2701-batch4/trail/opus3/%s.png' % n, 'trail/mark/%s.png' % n, None))

# stop looks 480x270, Maplewold style (layouts: stop-<type>-grassland_maplewold in includes/data/here_layouts.json)
for t in ('mill', 'shrine', 'jetty', 'herb', 'workshop', 'orchard', 'tower', 'camp'):
    INSTALL.append((B3 + '/stops/opus3/%s.png' % t, 'scenes/here-stop-%s-grassland_maplewold.png' % t, None))
for t in ('inn', 'ferry', 'spring'):   # step 2: batch4 (its opus3 builds on batch3's frame)
    INSTALL.append(('art-2701-batch4/stops/opus3/%s.png' % t, 'scenes/here-stop-%s-grassland_maplewold.png' % t, None))


def render(src, size):
    """The bytes to write: the file itself, or a hard-pixel box downscale."""
    if size is None:
        return open(src, 'rb').read()
    from PIL import Image   # only the downscaled rows need Pillow (--list does not)
    im = Image.open(src).convert('RGBA').resize(size, Image.BOX)
    px = im.load()
    for y in range(size[1]):
        for x in range(size[0]):
            r, g, b, a = px[x, y]
            px[x, y] = (r, g, b, 255) if a >= 128 else (0, 0, 0, 0)
    buf = io.BytesIO()
    im.save(buf, 'PNG', optimize=True)
    return buf.getvalue()


def main():
    if '--list' in sys.argv:   # source|game path|w|h (w h of the game file; 0 0 = same as the source)
        for src, dst, size in INSTALL:
            print('%s|%s|%d|%d' % (src, dst, size[0] if size else 0, size[1] if size else 0))
        return
    check = '--check' in sys.argv
    n = bad = 0
    for src, dst, size in INSTALL:
        s, d = os.path.join(V3, src), os.path.join(IMG, dst)
        data = render(s, size)
        same = os.path.isfile(d) and open(d, 'rb').read() == data
        if check:
            if not same and size is None:
                print('differs:', dst); bad += 1
            continue
        if not same:
            os.makedirs(os.path.dirname(d), exist_ok=True)
            open(d, 'wb').write(data)
            n += 1
    print(('%d of %d differ' % (bad, len(INSTALL))) if check else ('%d of %d written' % (n, len(INSTALL))))
    sys.exit(1 if bad else 0)


if __name__ == '__main__':
    main()
