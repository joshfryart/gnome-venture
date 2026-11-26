#!/usr/bin/env python3
"""Text-free puzzle piece cards of the 280 Tailor wearables: game/assets/img/wearpiece/<slug>.png (132x92 RGBA, hard edges).

Art review (Baked-in text): the old cards (claude/wear-pieces/render2.py) drew the piece value into a cream box at the top left and the piece
name into a cream ribbon at the bottom, both in 3x5 pixel letters. Text belongs in code: shop.php now prints the name, type and value under the
card as real text (.spiece figcaption in style.css). This builds the same card from the same template (the hand-me base cell of
assets/img/pfight/parts/atlas.json, the type pattern, the rim palette, the item art on its medallion, the rarity mark) with the two plates
taken out: their pixels become the card's own fill (pattern, light row and stitched rim continue across), so nothing is painted over.

Same size, same mode, every pixel alpha 0 or 255. Uses the helpers of claude/wear-pieces/render2.py (it reproduces the old cards
pixel for pixel), so the rest of each card is unchanged.

usage: python3 tools/build_wearpiece_cards.py [--check]   (--check: write nothing; exit 1 if a game card differs from what this would build)
"""
import glob
import json
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
WP = os.path.join(ROOT, 'claude/wear-pieces')
sys.path.insert(0, WP)
import render2 as R  # noqa: E402
from PIL import Image  # noqa: E402

OUT = os.path.join(ROOT, 'game/assets/img/wearpiece')
COST_BOX = (38, 14, 53, 27)    # x0, y0, x1, y1 inclusive: the value plate with its ink border (top row sits on the rim stitch row)
RIBBON = (41, 57, 100, 67)     # the name ribbon with its ink border and its two notches
FILL, LIGHT, RIM_ME, STITCH_ME = 11, 13, 2, 3   # role ids of rim.json


def plate_free(idx):
    """Role-index image with both plates replaced by what the card has around them."""
    px = idx.load()
    x0, y0, x1, y1 = COST_BOX
    for y in range(y0, y1 + 1):
        for x in range(x0, x1 + 1):
            if y == 14: r = RIM_ME if x % 5 in (0, 4) else STITCH_ME   # the stitched rim row runs on (period 5, as on both sides)
            elif y == 15: r = LIGHT                                      # the light row under the rim
            else: r = FILL
            px[x, y] = (r, 0, 0, 255)
    x0, y0, x1, y1 = RIBBON
    for y in range(y0, y1 + 1):
        for x in range(x0, x1 + 1):
            px[x, y] = (FILL, 0, 0, 255)
    return idx


def card(ty, knob, rarity, item_png):
    up = ty in R.UP
    edges = {'L': ('hole', R.HOLE[ty]), 'R': ('knob', {'b': 'body', 'm': 'mind', 'c': 'craft'}[knob]),
             'T': ('knob' if up else 'hole', 'body'), 'B': ('hole' if up else 'knob', 'body')}
    idx = plate_free(R.index(edges)); t = R.TYPES[ty]; ti = R.A['patterns']['hand']['order'].index(ty)
    CW, CH = R.CW, R.CH
    pm = R.pat.crop((ti * CW, 0, ti * CW + CW, CH)).load(); ip = idx.load()
    out = Image.new('RGBA', (CW, CH), (0, 0, 0, 0)); op = out.load()
    for y in range(CH):
        for x in range(CW):
            r, g, b, a = ip[x, y]
            if a == 0: continue
            if 1 <= r <= 10: c = R.RIM[R.ROLE[r]]
            elif r == 11: c = t['mark'] if pm[x, y][0] == 255 and pm[x, y][3] else t['base']
            elif r == 12: c = t['shade']
            elif r == 13: c = t['light']
            elif r == 14: c = t['base']
            else: c = (255, 0, 255)
            op[x, y] = tuple(c) + (255,)
    cx, cy = 55, 25   # item art on its cream medallion (unchanged)
    med = Image.new('RGBA', (32, 32), (0, 0, 0, 0)); mp = med.load()
    for y in range(32):
        for x in range(32):
            d = ((x - 15.5) ** 2 + (y - 15.5) ** 2) ** .5
            if d <= 16: mp[x, y] = (42, 26, 16, 255) if d > 15 else (242, 228, 192, 255)
    out.alpha_composite(med, (cx, cy)); out.alpha_composite(R.reduce(Image.open(item_png)), (cx, cy))
    rp = R.P + f'marks/rarity-{rarity}.png'
    if os.path.exists(rp): out.alpha_composite(Image.open(rp).convert('RGBA'), (100, 18))
    return out


def main():
    check = '--check' in sys.argv
    bad = []; wrote = same = 0
    for x in json.load(open(os.path.join(WP, 'pieces.json'))):
        src = glob.glob(f"{R.ART}/{x['region']}/{x['cat']}-{x['n']}-*.png")
        if not src: bad.append('missing art ' + x['slug']); continue
        im = card(x['type'], x['knob'], {'Common': 0, 'Uncommon': 1, 'Rare': 2}[x['rarity']], src[0])
        if sum(im.getchannel('A').histogram()[1:255]): bad.append('semi-transparent ' + x['slug']); continue
        dst = os.path.join(OUT, x['slug'] + '.png')
        if os.path.isfile(dst) and Image.open(dst).convert('RGBA').tobytes() == im.tobytes():
            same += 1; continue
        if check: bad.append('differs ' + os.path.relpath(dst, ROOT)); continue
        im.save(dst, optimize=True); wrote += 1
    for b in bad: print(b)
    print('%d written, %d already in place, %d problems' % (wrote, same, len(bad)))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
