#!/usr/bin/env python3
"""build.py : assemble the stat-kit sheets (game/assets/img/pfight/stat/) from the PNGs kit.lua draws, check them, write a preview.
  /tmp/aseq/squashfs-root/AppRun -b --script kit.lua && python3 build.py [--preview PATH]
Does not touch parts48/."""
import os, sys
from PIL import Image
HERE = os.path.dirname(os.path.abspath(__file__))
SRC = os.path.abspath(os.path.join(HERE, '..'))
OUT = os.path.abspath(os.path.join(HERE, '../../../../game/assets/img/pfight/stat'))
SIZES = {'strip': dict(piece=(82, 73), body=(56, 47), tab=13, badge=11, stolen=14, at=(13, 13)),
         'hand': dict(piece=(140, 124), body=(96, 80), tab=22, badge=18, stolen=24, at=(22, 22))}
def L(size, name): return Image.open(os.path.join(SRC, size, name)).convert('RGBA')
def hstack(ims):
    w, h = ims[0].size; o = Image.new('RGBA', (w * len(ims), h), (0, 0, 0, 0))
    for i, im in enumerate(ims): o.paste(im, (i * w, 0))
    return o
def main():
    os.makedirs(OUT, exist_ok=True)
    made = {}
    for s, z in SIZES.items():
        made['socks-any-%s.png' % s] = hstack([L(s, 'sock-%s-any-knob.png' % s), L(s, 'sock-%s-any-hole.png' % s)])
        made['envtile-spring-%s.png' % s] = L(s, 'env-%s-spring-tile.png' % s)
        made['envglyph-spring-%s.png' % s] = L(s, 'env-%s-spring-glyph.png' % s)
        made['snare-%s.png' % s] = L(s, 'snare-%s.png' % s)
        made['badges-stat-%s.png' % s] = L(s, 'badges-%s.png' % s)
        made['stolen-%s.png' % s] = L(s, 'stolen-%s.png' % s)
    bad = []
    for n, im in made.items():
        im.save(os.path.join(OUT, n))
        px = list(im.getdata())
        for p in px:
            if p[3] not in (0, 255): bad.append('%s partial alpha %s' % (n, p)); break
        for p in px:
            if p[3] and p[:3] in ((0, 0, 0), (255, 255, 255)): bad.append('%s pure black/white' % n); break
        print('%-28s %s' % (n, im.size))
    for s, z in SIZES.items():
        W, H = z['piece']
        if made['socks-any-%s.png' % s].size != (W * 2, H): bad.append('socks size')
        if made['envtile-spring-%s.png' % s].size != (W, H): bad.append('envtile size')
        if made['snare-%s.png' % s].size != z['body']: bad.append('snare size')
        if made['badges-stat-%s.png' % s].size != (z['badge'] * 4, z['badge']): bad.append('badges size')
        if made['stolen-%s.png' % s].size != (z['stolen'],) * 2: bad.append('stolen size')
    print('PROBLEMS:' if bad else 'checks ok', *bad, sep='\n  ')
    return made
def preview(made, path):
    """a quick look: every kit piece on a light and a dark cell, upscaled"""
    Z = {'strip': 3, 'hand': 2}
    rows = []
    for s in ('strip', 'hand'):
        z, k = SIZES[s], Z[s]
        W, H = z['piece']
        row = []
        for bgc in ((176, 150, 110, 255), (46, 40, 58, 255)):
            cell = Image.new('RGBA', (W * 2 + W, H * 2), bgc)
            sk = made['socks-any-%s.png' % s]
            cell.alpha_composite(Image.new('RGBA', (1, 1)), (0, 0))
            # a parchment env piece with the spring glyph
            t = made['envtile-spring-%s.png' % s].copy(); t.alpha_composite(made['envglyph-spring-%s.png' % s]); cell.alpha_composite(t, (0, 0))
            # a body with a knob and a hole: neutral tile
            body = Image.new('RGBA', (W, H), (0, 0, 0, 0))
            bw, bh = z['body']; ox, oy = z['at']
            body.paste(Image.new('RGBA', (bw, bh), (138, 122, 102, 255)), (ox, oy))
            cell.alpha_composite(sk.crop((0, 0, W, H)), (0, 0)); cell.alpha_composite(sk.crop((W, 0, 2 * W, H)), (W, 0))
            sn = made['snare-%s.png' % s]; cell.alpha_composite(sn, (W * 2 + ox, oy)) if False else None
            row.append(cell)
        rows.append((s, row))
    # the second half: snare on cells, badges, stolen
    out = Image.new('RGBA', (1200, 760), (60, 60, 60, 255))
    y = 4
    for s, row in rows:
        k = Z[s]; W, H = SIZES[s]['piece']
        x = 4
        for cell in row:
            im = cell.resize((cell.width * k, cell.height * k), Image.NEAREST)
            if x + im.width < out.width: out.alpha_composite(im, (x, y))
            x += im.width + 8
        y += row[0].height * k + 8
    out.convert('RGB').save(path)
if __name__ == '__main__':
    made = main()
    if '--preview' in sys.argv: preview(made, sys.argv[sys.argv.index('--preview') + 1])
