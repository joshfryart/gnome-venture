#!/usr/bin/env python3
"""Placeholder pictures for the graphical navigation (plan Phase 1e): one PNG per layout in game/includes/data/here_layouts.json,
drawn from the layout itself (sky, ground, horizon, the 8 trail stubs, spot / stand / house / door slots), so every picture page can be
built and tested before the v3 art exists. Real art overwrites the same file name. The game never needs these files (without a PNG the
scene engine draws its own sky and ground), so run this only when you want to see the slots in a screenshot.

Usage: tools/gen_here_placeholders.py [--out DIR] [--layouts FILE] [KEY ...]
  default out   game/assets/img/scenes   (files here-<key>.png, ':' in a key becomes '-': slug:foo -> here-slug-foo.png)
  default keys  every layout in the file
The size of each PNG is that layout's own w x h.
"""
import json, os, sys
from PIL import Image, ImageDraw, ImageFont

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

def font(sz):
    try:
        return ImageFont.load_default(size=sz)
    except TypeError:
        return ImageFont.load_default()

def draw(key, L, name=None):
    w, h, hz = int(L['w']), int(L['h']), int(L.get('horizon', 0))
    im = Image.new('RGB', (w, h), (191, 225, 238))
    d = ImageDraw.Draw(im)
    if hz:
        d.rectangle([0, hz, w, h], fill=(159, 194, 122))
        d.line([0, hz, w, hz], fill=(95, 127, 74), width=1)
    cx, cy = w // 2, int((hz + h) / 2) if hz else h // 2
    for e in L.get('exits', []):   # a dirt stub from the middle of the ground to each exit
        d.line([cx, cy, int(e['x']), int(e['y'])], fill=(196, 168, 120), width=max(6, w // 60))
    for s in L.get('stand', []):
        x, y = int(s['x']), int(s['y'])
        d.ellipse([x - 10, y - 3, x + 10, y + 3], outline=(60, 120, 60))
    f = font(max(9, w // 48))
    for e in L.get('exits', []):
        x, y = int(e['x']), int(e['y'])
        d.ellipse([x - 5, y - 5, x + 5, y + 5], fill=(200, 60, 50))
        d.text((x + 7, y - 6), e['a'], fill=(120, 20, 20), font=f)
    for s in L.get('spots', []):
        x, y = int(s['x']), int(s['y'])
        d.rectangle([x - 16, y - 16, x + 16, y + 10], outline=(40, 80, 160), width=2, fill=(238, 232, 214))
        d.text((x - 14, y - 8), s['k'][:6], fill=(30, 60, 130), font=f)
    for i, p in enumerate(L.get('houses', [])):
        x, y = int(p['x']), int(p['y'])
        d.rectangle([x - 28, y - 30, x + 28, y + 14], outline=(150, 100, 40), width=2, fill=(228, 206, 160))
        d.rectangle([x - 6, y - 4, x + 6, y + 14], fill=(110, 70, 40))
        d.text((x - 6, y - 26), str(i + 1), fill=(90, 50, 20), font=f)
    d.text((6, 4), 'PLACEHOLDER ' + (name or fname(key)[:-4]) + '  ' + str(w) + 'x' + str(h), fill=(200, 30, 30), font=f)
    d.rectangle([0, 0, w - 1, h - 1], outline=(220, 20, 20), width=2)
    return im

def fname(k):
    # street and door layouts keep their own file names (scenes/resid-<n>.png, scenes/door-<key>.png); the rest are scenes/here-<key>.png
    if k.startswith('resid-') or k.startswith('door'):
        return (k if k != 'door' else 'door-cottage').replace(':', '-') + '.png'
    return 'here-' + k.replace(':', '-') + '.png'

def main(argv):
    out = os.path.join(ROOT, 'game', 'assets', 'img', 'scenes')
    lay = os.path.join(ROOT, 'game', 'includes', 'data', 'here_layouts.json')
    keys = []
    i = 0
    while i < len(argv):
        if argv[i] == '--out': out = argv[i + 1]; i += 2
        elif argv[i] == '--layouts': lay = argv[i + 1]; i += 2
        else: keys.append(argv[i]); i += 1
    data = {k: v for k, v in json.load(open(lay)).items() if not k.startswith('_')}
    os.makedirs(out, exist_ok=True)
    n = 0
    for k in keys or list(data):
        if k not in data:
            print('no such layout:', k, file=sys.stderr); continue
        if k == 'door':   # one shared door per home kind (door-<homekey>.png), lit/dark comes from the page
            for hk in ('cottage', 'burrow', 'treehouse', 'hut', 'stone', 'boat'):
                draw(k, data[k], 'door-' + hk).save(os.path.join(out, 'door-' + hk + '.png'), optimize=True)
                n += 1
            continue
        draw(k, data[k]).save(os.path.join(out, fname(k)), optimize=True)
        n += 1
    print('wrote', n, 'pictures to', out)

if __name__ == '__main__':
    main(sys.argv[1:])
