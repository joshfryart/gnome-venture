#!/usr/bin/env python3
"""Tag marks (14), upgrade marks (11), rarity gems (3) and popover headers (7) for Puzzle Combat, felt style, hard pixels.
Run: python3 gen_marks.py <out dir>   -> tag-<key>.png mod-<key>.png rarity-<0..2>.png pop-header-<type>.png marks.json marks-preview.png
Cue rules (colour-blind): tag = cream ROUNDED SQUARE, upgrade = gold HEXAGON; rarity = SHAPE (circle / diamond / sparkle) + colour."""
import json
import os
import sys
from PIL import Image
import numpy as np
import base_icons as B
import gen4 as G

INK, CREAM, GOLD, CD = B.INK, B.CREAM, B.GOLD, B.CREAM_D
hx = B.hx
LGOLD = hx('#f8c552')
DGOLD = hx('#a05c08')

G8 = {  # 8x8 glyphs, '#' = ink
 'quick': ["...###..", "..###...", ".###....", ".######.", "...###..", "..###...", ".###....", ".##....."],
 'heavy': ["..####..", ".#....#.", ".#....#.", "########", "########", "########", "########", "########"],
 'pierce': ["........", "....#...", ".....#..", "########", ".....#..", "....#...", "........", "........"],
 'poison': ["...#....", "...#....", "..###...", ".#####..", ".#####..", ".#####..", "..###...", "........"],
 'trip': ["..####..", ".#....#.", "#..##..#", "#.#..#.#", "#.#..#.#", "#..##..#", ".#....#.", "..####.."],
 'bash': ["########", "#......#", "#......#", "#......#", ".#....#.", ".#....#.", "..#..#..", "...##..."],
 'hold': ["...##...", "...##...", ".######.", "...##...", "#..##..#", "#..##..#", ".#.##.#.", "..####.."],
 'thorns': ["...##...", ".#.##.#.", ".#.##.#.", ".####.#.", "...####.", "...##...", "...##...", "...##..."],
 'evade': ["........", ".#####..", "......#.", ".####.#.", "......#.", ".#####..", "........", "........"],
 'mend': [".....###", "....####", "...####.", "..####..", ".####...", "####....", "###.....", "........"],
 'hum': ["...#####", "...#..##", "...#..#.", "...#....", ".###....", "####....", ".##.....", "........"],
 'lull': ["..####..", ".##.....", "##......", "##......", "##......", ".##.....", "..####..", "........"],
 'bond': ["........", ".##..##.", "#..##..#", "#..##..#", "#..##..#", ".##..##.", "........", "........"],
 'pluck': [".#.#.#..", ".#.#.#..", ".#####..", ".#####..", "..####..", "..###...", "..##....", "........"],
}
M8 = {
 'sticky': ["##....##", "##....##", "##....##", "##....##", "##....##", ".##..##.", "..####..", "........"],
 'swift': ["......##", ".....###", "....###.", "...###..", "..###...", ".###....", "##......", "#......."],
 'hardy': ["########", "#..#...#", "########", "...#..#.", "########", "#..#...#", "########", "........"],
 'tender': [".##..##.", "########", "########", "########", ".######.", "..####..", "...##...", "........"],
 'leech': ["########", "########", ".######.", ".#.##.#.", ".#.##.#.", "..#..#..", "..#..#..", "........"],
 'spiky': ["#..#..#.", ".#.#.#..", "..###...", "########", "..###...", ".#.#.#..", "#..#..#.", "........"],
 'soft': ["..###...", ".#####.#", "########", "########", ".######.", "........", "........", "........"],
 'warm': ["...#....", "...##...", "..###.#.", ".######.", ".######.", ".######.", "..####..", "........"],
 'finisher': ["..####..", ".#....#.", "#..##..#", "#.####.#", "#.####.#", "#..##..#", ".#....#.", "..####.."],
 'lucky': [".##..##.", ".##..##.", "..####..", "...##...", "..####..", ".##..##.", ".##..##.", "........"],
 'steady': ["...##...", "########", "...##...", "#..##..#", "#..##..#", ".#.##.#.", "..####..", "........"],
}
RAR = {  # 5x5 fill masks; outline adds 1 px -> 7x7
 0: (["..#..", ".###.", "#####", ".###.", "..#.."] if False else [".###.", "#####", "#####", "#####", ".###."], CREAM, CD),
 1: (["..#..", ".###.", "#####", ".###.", "..#.."], hx('#56b4e9'), hx('#2f84bd')),
 2: (["#.#.#", ".###.", "#####", ".###.", "#.#.#"], GOLD, DGOLD),
}


def blank(w, h):
    return Image.new('RGBA', (w, h), (0, 0, 0, 0))


def badge(shape, fill, shade, glyph):
    im = blank(12, 12)
    p = im.load()
    for y in range(12):
        for x in range(12):
            if shape == 'round':
                inside = not ((x in (0, 11)) and (y in (0, 11)))
            else:                                   # hexagon: corners cut 2 px diagonally
                cut = min(x, 11 - x) + min(y, 11 - y)
                inside = cut >= 2
            if inside:
                p[x, y] = INK + (255,)
    a = np.array(im)
    m = a[..., 3] > 0
    pm = np.pad(m, 1)
    edge = m & ~(pm[:-2, 1:-1] & pm[2:, 1:-1] & pm[1:-1, :-2] & pm[1:-1, 2:])
    for y in range(12):
        for x in range(12):
            if m[y, x] and not edge[y, x]:
                a[y, x] = (shade if y == 10 or (shape == 'hex' and y == 9) else fill) + (255,)
    for j, r in enumerate(glyph):
        for i, ch in enumerate(r):
            if ch == '#':
                a[2 + j, 2 + i] = INK + (255,)
    return Image.fromarray(a)


def gem(i):
    rows, fill, shade = RAR[i]
    im = blank(7, 7)
    for j, r in enumerate(rows):
        for k, ch in enumerate(r):
            if ch == '#':
                im.putpixel((1 + k, 1 + j), (shade if j == 4 or (i == 0 and j == 3) else fill) + (255,))
    a = np.array(im)
    m = a[..., 3] > 0
    p = np.pad(m, 1)
    nb = (p[:-2, 1:-1] | p[2:, 1:-1] | p[1:-1, :-2] | p[1:-1, 2:] | p[:-2, :-2] | p[:-2, 2:] | p[2:, :-2] | p[2:, 2:])[:7, :7]
    a[nb & ~m] = INK + (255,)
    return Image.fromarray(a)


def header(t):
    """popover header 9-slice 24x16, slice 9 left/right: type-coloured ends (pattern), cream text field in the middle."""
    c = B.TYPES[t]
    im = blank(24, 16)
    p = im.load()
    for y in range(16):
        for x in range(24):
            p[x, y] = INK + (255,)
    for y in range(1, 15):
        for x in range(1, 23):
            end = x < 9 or x >= 15
            if end:
                col = c['mark'] if B.pat(t, 'strip', x, y) else c['base']
                if y == 14 or y == 13:
                    col = c['shade']
                elif y == 1:
                    col = c['light']
            else:
                col = CREAM if y < 13 else CD
                if y == 1:
                    col = hx('#fff8e6')
            p[x, y] = col + (255,)
    for x in range(1, 23):
        if x % 4 < 2:
            p[x, 14] = GOLD + (255,) if 9 <= x < 15 else p[x, 14]
    for y in (0, 15):                                   # notch the four corners: ribbon feel
        for x in (0, 23):
            p[x, y] = (0, 0, 0, 0)
    return im


def main(out):
    os.makedirs(out, exist_ok=True)
    meta = {'tags': {}, 'mods': {}, 'rarity': {}, 'headers': {}}
    for k, g in G8.items():
        badge('round', CREAM, CD, g).save(os.path.join(out, f'tag-{k}.png'))
        meta['tags'][k] = [12, 12]
    for k, g in M8.items():
        badge('hex', GOLD, DGOLD, g).save(os.path.join(out, f'mod-{k}.png'))
        meta['mods'][k] = [12, 12]
    for i in RAR:
        gem(i).save(os.path.join(out, f'rarity-{i}.png'))
        meta['rarity'][str(i)] = [7, 7]
    for t in B.ORDER:
        header(t).save(os.path.join(out, f'pop-header-{t}.png'))
        meta['headers'][t] = [24, 16]
    sg = G.GEO['strip']
    KX, KY = sg['KX'], sg['KY']
    meta['anchors'] = {
        'note': 'top-left of the mark, in PIECE IMAGE coords, drawn over the piece (1x marks). rarity 0 common, 1 uncommon, 2 rare.',
        'strip': {'tag': [KX + 4, KY + 26], 'mod': [KX + 40, KY + 26], 'rarity': [KX + 45, KY + 2]},
        'hand': {'tag': [18 + 6, 12 + 52], 'mod': [18 + 78, 12 + 52], 'rarity': [18 + 82, 12 + 6]},
        'popover': 'draw marks at 2x (24x24 / 14x14), integer scale only',
        'header': '9-slice, slice 9 px left and right, 16 px tall, stretch the middle; print the name in ink on the cream middle'}
    meta['cue'] = 'tag = cream rounded square, upgrade = gold hexagon; rarity = circle (common) / diamond (uncommon) / sparkle (rare)'
    json.dump(meta, open(os.path.join(out, 'marks.json'), 'w'), indent=1)
    # preview: foe 'trick' strip example, and a mine hand piece, marks at the anchors, 3x
    sh = Image.new('RGBA', (460, 150), B.FELT + (255,))

    def put(piece, size, tag, mod, rar, x0):
        im = piece.copy()
        an = meta['anchors'][size]
        im.alpha_composite(Image.open(os.path.join(out, f'tag-{tag}.png')), tuple(an['tag']))
        im.alpha_composite(Image.open(os.path.join(out, f'mod-{mod}.png')), tuple(an['mod']))
        im.alpha_composite(Image.open(os.path.join(out, f'rarity-{rar}.png')), tuple(an['rarity']))
        sh.alpha_composite(im, (x0, 6))
    full = {s: ('hole', 'mind') for s in 'L'} | {'R': ('knob', 'body'), 'T': ('hole', 'craft'), 'B': ('hole', 'mind')}
    put(G.render('trick', 'strip', full, 'foe'), 'strip', 'bash', 'spiky', 2, 6)
    put(G.render('hurt', 'strip', full, 'me'), 'strip', 'quick', 'leech', 1, 86)
    put(G.render('guard', 'strip', {}, 'me'), 'strip', 'hold', 'hardy', 0, 166)
    put(G.render('heal', 'hand', full, 'me'), 'hand', 'mend', 'tender', 1, 246)
    x = 6
    for k in list(G8)[:14]:
        sh.alpha_composite(Image.open(os.path.join(out, f'tag-{k}.png')), (x, 62 + 0))
        x += 13
    x = 6
    for k in M8:
        sh.alpha_composite(Image.open(os.path.join(out, f'mod-{k}.png')), (x, 78))
        x += 13
    for i in RAR:
        sh.alpha_composite(Image.open(os.path.join(out, f'rarity-{i}.png')), (170 + i * 10, 62))
    for j, t in enumerate(B.ORDER):
        sh.alpha_composite(Image.open(os.path.join(out, f'pop-header-{t}.png')), (6 + (j % 4) * 28, 96 + (j // 4) * 18))
    sh.resize((sh.width * 3, sh.height * 3), Image.NEAREST).save(os.path.join(out, 'marks-preview.png'))


if __name__ == '__main__':
    main(sys.argv[1])
