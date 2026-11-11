#!/usr/bin/env python3
"""Felt-style extras for the Puzzle Combat fight screen (hard pixels only). Run: python3 gen_extras.py <out dir>
Writes deck/discard icons, joint marks, chain glow strips, resolve bar, intent bubble, combo stamps, history chip frames,
ghost outline demo, extras.json (sizes, anchors, slice margins), extras-sheet.png (preview, not for the game)."""
import json
import math
import os
import sys
import numpy as np
from PIL import Image, ImageDraw
import base_icons as B
import gen4 as G

INK, CREAM, GOLD, FELT = B.INK, B.CREAM, B.GOLD, B.FELT
CD = B.CREAM_D
RUST, MAROON, BONE = G.RUST, G.MAROON, G.BONE
hx = B.hx
T = (0, 0, 0, 0)


def new(w, h):
    return Image.new('RGBA', (w, h), T)


def rect(d, x0, y0, x1, y1, c):
    d.rectangle([x0, y0, x1, y1], fill=c + (255,))


def outline_pass(im, col=INK):
    """1 px 4-neighbour ink outline around every opaque pixel (outside)."""
    a = np.array(im)
    m = a[..., 3] > 0
    p = np.pad(m, 1)
    nb = p[:-2, 1:-1] | p[2:, 1:-1] | p[1:-1, :-2] | p[1:-1, 2:]
    o = nb & ~m
    a[o] = col + (255,)
    return Image.fromarray(a)


def deck_icon():            # puzzle book: closed book, spine on the left, gold puzzle piece on the cover
    im = new(32, 32)
    d = ImageDraw.Draw(im)
    rect(d, 6, 5, 27, 26, INK)
    rect(d, 7, 6, 26, 25, hx('#00639e'))                  # cover (blue, the "guard" book colour is neutral blue)
    rect(d, 7, 6, 10, 25, hx('#0a3d6e'))                  # spine
    for y in range(8, 25, 4):
        rect(d, 8, y, 9, y + 1, GOLD)                     # spine stitches
    rect(d, 27, 8, 28, 24, INK)
    rect(d, 26, 8, 27, 24, CREAM)                         # page block (right edge)
    rect(d, 6, 26, 27, 27, INK)
    rect(d, 7, 26, 26, 26, CD)                            # pages underside
    rect(d, 13, 11, 22, 20, GOLD)                         # puzzle piece emblem: square + knob + hole
    rect(d, 14, 12, 21, 19, hx('#f8c552'))
    rect(d, 22, 14, 24, 17, GOLD)
    rect(d, 23, 15, 24, 16, hx('#f8c552'))
    rect(d, 13, 14, 14, 17, hx('#0a3d6e'))
    d.rectangle([13, 11, 22, 20], outline=INK + (255,))
    return im


def discard_icon():         # basket/bin with two pieces tipping in, dark felt so it differs from the book by shape
    im = new(32, 32)
    d = ImageDraw.Draw(im)
    d.polygon([(7, 14), (24, 14), (22, 27), (9, 27)], fill=INK + (255,))
    d.polygon([(8, 15), (23, 15), (21, 26), (10, 26)], fill=hx('#6b4a30') + (255,))
    for y in (18, 22):
        d.line([(9 if y == 18 else 10, y), (22 if y == 18 else 21, y)], fill=hx('#8a6240') + (255,))
    for x in (13, 17, 21):
        d.line([(x, 15), (x - 1 if x < 17 else x, 26)], fill=hx('#8a6240') + (255,))
    rect(d, 6, 12, 25, 14, INK)
    rect(d, 7, 13, 24, 13, CD)
    # two pieces tipping in (tilted squares with a knob)
    d.polygon([(9, 5), (15, 4), (16, 10), (10, 11)], fill=INK + (255,))
    d.polygon([(10, 6), (14, 5), (15, 9), (11, 10)], fill=hx('#d55e00') + (255,))
    d.polygon([(18, 3), (24, 5), (22, 11), (17, 9)], fill=INK + (255,))
    d.polygon([(19, 5), (23, 6), (21, 10), (18, 8)], fill=hx('#62bcee') + (255,))
    rect(d, 15, 7, 17, 9, hx('#d55e00'))
    # small curl lines = discarded
    rect(d, 4, 20, 5, 21, CD)
    rect(d, 27, 21, 28, 22, CD)
    return im


def joint(vertical):        # linked-joint mark centred on the seam: a gold link (two rings) with ink outline, 22x14 / 14x22
    w, h = (14, 22) if vertical else (22, 14)
    im = new(w, h)
    d = ImageDraw.Draw(im)
    for cx, cy in (((7, 7), (7, 14)) if vertical else ((7, 7), (14, 7))):
        d.ellipse([cx - 5, cy - 5, cx + 5, cy + 5], fill=INK + (255,))
        d.ellipse([cx - 4, cy - 4, cx + 4, cy + 4], fill=GOLD + (255,))
        d.ellipse([cx - 2, cy - 2, cx + 2, cy + 2], fill=INK + (255,))
        d.ellipse([cx - 1, cy - 1, cx + 1, cy + 1], fill=(0, 0, 0, 0))
    a = np.array(im)
    # light highlight on the top-left of each ring
    for y in range(h):
        for x in range(w):
            if tuple(a[y, x][:3]) == GOLD and a[y, x][3] and (x + y) % 5 == 0:
                a[y, x] = hx('#f8c552') + (255,)
    return Image.fromarray(a)


def glow_strip(length, vertical, frames=4):
    """tileable chain glow: dashed gold/cream sparkle line, 4 frames running along the strip. length must be divisible by 8."""
    th = 8
    fr = []
    for f in range(frames):
        im = new(length, th)
        px = im.load()
        for x in range(length):
            ph = (x - f * 2) % 8
            for y in range(th):
                core = y in (3, 4)
                halo = y in (2, 5)
                if core:
                    px[x, y] = (CREAM if ph < 3 else GOLD) + (255,)
                elif halo and ph in (1, 2, 5):
                    px[x, y] = GOLD + (255,)
                elif y in (1, 6) and ph == 2:
                    px[x, y] = BONE + (255,)
        fr.append(im.rotate(-90, expand=True) if vertical else im)
    return fr


def resolve():
    frame = new(96, 12)
    d = ImageDraw.Draw(frame)
    d.rounded_rectangle([0, 0, 95, 11], 2, fill=INK + (255,))
    d.rectangle([1, 1, 94, 10], fill=CREAM + (255,))
    d.rectangle([2, 2, 93, 9], fill=INK + (255,))
    d.rectangle([3, 3, 92, 8], fill=(0, 0, 0, 0))                   # 90x6 transparent window
    rect(d, 47, 0, 48, 11, INK)
    rect(d, 47, 1, 48, 10, GOLD)                                    # centre mark
    rect(d, 47, 3, 48, 8, INK)
    rect(d, 47, 4, 48, 7, GOLD)
    hurt = new(90, 6)
    charm = new(90, 6)
    for x in range(90):
        for y in range(6):
            hurt.putpixel((x, y), (hx('#9c3608') if (x + y) % 6 < 2 else hx('#d55e00')) + (255,))       # stripes (like Hurt)
            charm.putpixel((x, y), (hx('#eaa6c8') if x % 4 == 1 and y % 2 == 0 else hx('#cc79a7')) + (255,))  # dots (like Charm)
    return frame, hurt, charm


def bubble():
    im = new(28, 24)
    d = ImageDraw.Draw(im)
    d.rounded_rectangle([0, 0, 27, 19], 4, fill=INK + (255,))
    d.rounded_rectangle([1, 1, 26, 18], 3, fill=CREAM + (255,))
    d.polygon([(6, 19), (12, 19), (6, 23)], fill=INK + (255,))
    d.polygon([(7, 19), (11, 19), (7, 22)], fill=CREAM + (255,))
    d.line([(1, 17), (26, 17)], fill=CD + (255,))
    return im


def stamp(spikes, fill, rim):
    im = new(32, 32)
    d = ImageDraw.Draw(im)
    pts = []
    for i in range(spikes * 2):
        a = math.pi * i / spikes - math.pi / 2
        r = 15.5 if i % 2 == 0 else 11
        pts.append((15.5 + r * math.cos(a), 15.5 + r * math.sin(a)))
    d.polygon(pts, fill=INK + (255,))
    pts2 = [(15.5 + (r - 1.6) * (x - 15.5) / r, 15.5 + (r - 1.6) * (y - 15.5) / r)
            for (x, y), r in ((p, math.hypot(p[0] - 15.5, p[1] - 15.5)) for p in pts)]
    d.polygon(pts2, fill=rim + (255,))
    d.ellipse([6, 6, 25, 25], fill=INK + (255,))
    d.ellipse([7, 7, 24, 24], fill=fill + (255,))
    rect(d, 9, 10, 22, 21, INK)
    rect(d, 10, 11, 21, 20, CREAM)                                  # number plate 12x10 at (10,11): game prints the number in ink
    rect(d, 10, 20, 21, 20, CD)
    return im


def chip(foe):
    """9-slice history chip, 24x24, slice margin 5. me = solid cream border + gold corner stitches, foe = dashed rust border."""
    im = new(24, 24)
    d = ImageDraw.Draw(im)
    d.rounded_rectangle([0, 0, 23, 23], 5, fill=INK + (255,))
    inner = hx('#2a1a10') if foe else hx('#4a3220')
    d.rounded_rectangle([1, 1, 22, 22], 4, fill=(RUST if foe else CREAM) + (255,))
    d.rounded_rectangle([2, 2, 21, 21], 3, fill=INK + (255,))
    d.rounded_rectangle([3, 3, 20, 20], 2, fill=inner + (255,))
    px = im.load()
    if foe:                                                         # dashed: gaps in the rust band
        for i in range(2, 22):
            if (i // 2) % 2:
                for (x, y) in ((i, 1), (i, 22), (1, i), (22, i)):
                    px[x, y] = INK + (255,)
    else:
        for i in range(5, 19, 4):
            for (x, y) in ((i, 1), (i, 22), (1, i), (22, i)):
                px[x, y] = GOLD + (255,)
    return im


def ghost(piece_alpha_img):
    """lit-spot ghost: piece-shaped outline of a candidate piece, 1 px, dashed gold/cream; interior left empty.
    rule (piece-local px): outline = opaque px with a 4-neighbour outside; colour = GOLD if (x+y)%4<2 else CREAM."""
    a = np.array(piece_alpha_img)
    m = a[..., 3] > 0
    p = np.pad(m, 1)
    o = m & ~(p[:-2, 1:-1] & p[2:, 1:-1] & p[1:-1, :-2] & p[1:-1, 2:])
    out = np.zeros_like(a)
    for y, x in zip(*np.nonzero(o)):
        out[y, x] = (GOLD if (x + y) % 4 < 2 else CREAM) + (255,)
    return Image.fromarray(out)


def main(out):
    os.makedirs(out, exist_ok=True)
    files = {}

    def save(name, im, **meta):
        im.save(os.path.join(out, name))
        files[name] = dict(size=list(im.size), **meta)

    save('deck-book.png', deck_icon(), note='puzzle book (deck), 32x32')
    save('discard-bin.png', discard_icon(), note='discard bin, 32x32')
    save('joint-h.png', joint(False), centre_on='the vertical seam between left/right neighbours, centred on the socket row')
    save('joint-v.png', joint(True), centre_on='the horizontal seam between top/bottom neighbours, centred on the socket column')
    for v in (False, True):
        fr = glow_strip(64, v)
        w, h = fr[0].size
        sh = new(w * (1 if v else 1), h * len(fr)) if not v else new(w * len(fr), h)
        for i, f in enumerate(fr):
            sh.alpha_composite(f, ((0, i * h) if not v else (i * w, 0)))
        save('chain-glow-%s.png' % ('v' if v else 'h'), sh, frames=len(fr), frame=[w, h], tile='repeat along the long axis; 8 px period',
             layout='frames stacked ' + ('left to right' if v else 'top to bottom'), fps=8)
    fr_, hu, ch = resolve()
    save('resolve-frame.png', fr_, window=[3, 3, 90, 6], centre_mark_x=47)
    save('resolve-fill-hurt.png', hu, note='stripe pattern; clip to width, anchor LEFT of window')
    save('resolve-fill-charm.png', ch, note='dot pattern; clip to width, anchor RIGHT of window')
    save('intent-bubble.png', bubble(), icon_at=[4, 1], icon_size=20, tail='bottom-left')
    save('combo-stamp-small.png', stamp(8, hx('#e8a317'), GOLD), plate=[10, 11, 12, 10], note='combo 2-3')
    save('combo-stamp-big.png', stamp(12, hx('#d55e00'), RUST), plate=[10, 11, 12, 10], note='combo 4+')
    save('chip-me.png', chip(False), slice=5, note='9-slice, YOU, solid border')
    save('chip-foe.png', chip(True), slice=5, note='9-slice, FOE, dashed border')
    json.dump(files, open(os.path.join(out, 'extras.json'), 'w'), indent=1)

    # ghost demo from the felt board: candidate = strip 'hurt' with R hole body, placed at cell (0,0) of its own canvas
    cand = G.render('hurt', 'strip', {'L': ('hole', 'body'), 'T': ('knob', 'mind'), 'R': ('knob', 'craft')}, 'me')
    gim = ghost(cand)
    save('ghost-demo-strip.png', gim, note='DEMO of the ghost rule on one candidate piece; build it in code from the candidate alpha')

    # preview sheet (not for the game)
    sheet = Image.new('RGBA', (360, 150), FELT + (255,))
    x = 4
    for n in ('deck-book.png', 'discard-bin.png', 'combo-stamp-small.png', 'combo-stamp-big.png', 'intent-bubble.png', 'joint-h.png', 'joint-v.png'):
        im = Image.open(os.path.join(out, n))
        sheet.alpha_composite(im, (x, 4))
        x += im.width + 6
    sheet.alpha_composite(Image.open(os.path.join(out, 'resolve-frame.png')), (4, 44))
    f = Image.open(os.path.join(out, 'resolve-fill-hurt.png')).crop((0, 0, 30, 6))
    sheet.alpha_composite(f, (7, 47))
    f = Image.open(os.path.join(out, 'resolve-fill-charm.png')).crop((0, 0, 20, 6))
    sheet.alpha_composite(f, (73, 47))
    g1 = Image.open(os.path.join(out, 'glow-h.png' if False else 'chain-glow-h.png')).crop((0, 0, 64, 8))
    sheet.alpha_composite(g1, (4, 64))
    sheet.alpha_composite(Image.open(os.path.join(out, 'chip-me.png')), (110, 44))
    sheet.alpha_composite(Image.open(os.path.join(out, 'chip-foe.png')), (140, 44))
    sheet.alpha_composite(gim, (180, 44))
    sheet.alpha_composite(cand, (260, 44))
    sheet.resize((1080, 450), Image.NEAREST).save(os.path.join(out, 'extras-sheet.png'))


if __name__ == '__main__':
    main(sys.argv[1])
