#!/usr/bin/env python3
"""Jigsaw Places pictures (v2.0.87): cut each unique-location scene (assets/img/wonders/<kind>-<name>.png, 480 x 270 = 240 x 135 art pixels at 2x) to an EXACT 3:2 window
of 360 x 240 pixels = 180 x 120 art pixels, saved as assets/img/jigsaw/places/<key>.png. 180 x 120 is the biggest 3:2 window whose every tier cuts on whole art pixels:
Easy 6x4 = 30 x 30 art px a piece, Advanced 12x8 = 15 x 15, Expert 18x12 = 10 x 10 (a 405 x 270 window gave 16.875 art px, which is why it is not used).
Window position: centred (x 30, y 8 art px) unless game/includes/data/place_crops.txt has a row  key|x|y  (art pixels; x 0..60, y 0..15). Offsets are in art pixels so cuts stay on pixel edges.
Usage: python3 tools/gen_place_crops.py [--sheet OUT.png]   (re-runnable; writes only what changed; --sheet makes a contact sheet to choose offsets from)
"""
import glob, os, sys
from PIL import Image, ImageDraw

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'game')
SRC = os.path.join(ROOT, 'assets', 'img', 'wonders')
OUT = os.path.join(ROOT, 'assets', 'img', 'jigsaw', 'places')
DATA = os.path.join(ROOT, 'includes', 'data', 'place_crops.txt')


def offsets():
    o = {}
    if os.path.isfile(DATA):
        for ln in open(DATA, encoding='utf-8'):
            ln = ln.strip()
            if ln and not ln.startswith('#'):
                k, x, y = ln.split('|')
                assert 0 <= int(x) <= 60 and 0 <= int(y) <= 15, ln
                o[k] = (int(x), int(y))
    return o


def main():
    os.makedirs(OUT, exist_ok=True)
    off = offsets()
    sheet = sys.argv[sys.argv.index('--sheet') + 1] if '--sheet' in sys.argv else None
    tiles = []
    n = 0
    for f in sorted(glob.glob(os.path.join(SRC, '*.png'))):
        key = os.path.basename(f)[:-4]
        im = Image.open(f).convert('RGB')
        assert im.size == (480, 270), (key, im.size)
        x, y = off.get(key, (30, 8))
        crop = im.crop((x * 2, y * 2, x * 2 + 360, y * 2 + 240))
        crop.save(os.path.join(OUT, key + '.png'), optimize=True)
        n += 1
        if sheet:
            full = im.copy()
            ImageDraw.Draw(full).rectangle([x * 2, y * 2, x * 2 + 359, y * 2 + 239], outline=(255, 0, 255), width=3)
            tiles.append((key, full.resize((240, 135))))
    if sheet:
        cols = 6
        rows = (len(tiles) + cols - 1) // cols
        S = Image.new('RGB', (cols * 244, rows * 150), (30, 30, 30))
        d = ImageDraw.Draw(S)
        for i, (k, t) in enumerate(tiles):
            S.paste(t, ((i % cols) * 244 + 2, (i // cols) * 150 + 2))
            d.text(((i % cols) * 244 + 4, (i // cols) * 150 + 138), k[:38], fill=(255, 255, 255))
        S.save(sheet)
    print(n, 'places written to', os.path.relpath(OUT))


main()
