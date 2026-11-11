#!/usr/bin/env python3
"""'Choose an upgrade' popover header art, 96x96, felt style, hard pixels. Run: python3 gen_popover.py [out dir]
Medallion with gold rays, three upgrade hexagons (2x of the 12x12 marks), sparkles, and an empty cream banner for the title text
(banner rect (7,73) 82x15, print the title in ink). Writes popover-header.png."""
import math
import os
import sys
from PIL import Image, ImageDraw
import base_icons as B

INK, CREAM, GOLD, FELT, CD = B.INK, B.CREAM, B.GOLD, B.FELT, B.CREAM_D
hx = B.hx
HERE = os.path.dirname(os.path.abspath(__file__))
MARKS = os.path.join(HERE, '..', '..', '..', '..', 'game', 'assets', 'img', 'pfight', 'parts', 'marks')


def c(x):
    return tuple(x) + (255,)


def sparkle(d, x, y, r, col):
    d.line([(x - r, y), (x + r, y)], fill=c(col))
    d.line([(x, y - r), (x, y + r)], fill=c(col))
    d.point((x, y), fill=c(hx('#fff8e6')))


def main(out):
    im = Image.new('RGBA', (96, 96), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    cx, cy, R = 47.5, 43.5, 43
    d.ellipse([cx - R - 2, cy - R - 2, cx + R + 2, cy + R + 2], fill=c(CREAM))       # cream halo
    d.ellipse([cx - R, cy - R, cx + R, cy + R], fill=c(INK))
    d.ellipse([cx - R + 1, cy - R + 1, cx + R - 1, cy + R - 1], fill=c(hx('#8a6240')))
    d.ellipse([cx - R + 3, cy - R + 3, cx + R - 3, cy + R - 3], fill=c(hx('#9a7048')))
    # rays (hard lines) from the centre, alternating light felt
    for i in range(16):
        a = math.pi * 2 * i / 16 + 0.1
        x1, y1 = cx + (R - 4) * math.cos(a), cy + (R - 4) * math.sin(a)
        d.line([(cx, cy + 4), (x1, y1)], fill=c(hx('#a67a50') if i % 2 else hx('#b0845a')), width=3 if i % 2 else 2)
    d.ellipse([cx - 22, cy - 18, cx + 22, cy + 26], fill=c(hx('#7a5638')))
    d.ellipse([cx - 19, cy - 15, cx + 19, cy + 23], fill=c(hx('#c49a68')))
    # dashed cream stitch ring
    for i in range(72):
        if i % 2:
            continue
        a = math.pi * 2 * i / 72
        d.point((round(cx + (R - 2.5) * math.cos(a)), round(cy + (R - 2.5) * math.sin(a))), fill=c(CREAM))
    # three upgrade hexagons at 2x
    def hexa(name, x, y):
        h = Image.open(os.path.join(MARKS, f'mod-{name}.png')).resize((24, 24), Image.NEAREST)
        sh = Image.new('RGBA', (24, 24), (0, 0, 0, 0))
        im.alpha_composite(h, (x, y))
    hexa('sticky', 13, 33)
    hexa('finisher', 59 + 0, 33)
    hexa('lucky', 36, 14)
    for (x, y, r) in ((20, 22, 3), (74, 24, 3), (48, 8, 2), (12, 52, 2), (82, 50, 2), (58, 18, 1), (30, 60, 1)):
        sparkle(d, x, y, r, GOLD)
    # ribbon banner (empty cream) with gold end caps and swallowtails
    bx, by, bw, bh = 7, 73, 82, 15
    d.polygon([(0, by + 3), (10, by + 3), (10, by + bh + 3), (0, by + bh + 3), (4, by + 9)], fill=c(INK))
    d.polygon([(95, by + 3), (85, by + 3), (85, by + bh + 3), (95, by + bh + 3), (91, by + 9)], fill=c(INK))
    d.polygon([(1, by + 4), (9, by + 4), (9, by + bh + 2), (1, by + bh + 2), (5, by + 9)], fill=c(hx('#a05c08')))
    d.polygon([(94, by + 4), (86, by + 4), (86, by + bh + 2), (94, by + bh + 2), (90, by + 9)], fill=c(hx('#a05c08')))
    d.rectangle([bx - 1, by - 1, bx + bw, by + bh], fill=c(INK))
    d.rectangle([bx, by, bx + bw - 1, by + bh - 1], fill=c(CREAM))
    d.line([(bx, by + bh - 1), (bx + bw - 1, by + bh - 1)], fill=c(CD))
    d.line([(bx, by), (bx + bw - 1, by)], fill=c(hx('#fff8e6')))
    for x in range(bx + 3, bx + bw - 3, 4):
        d.point((x, by + 1), fill=c(GOLD))
        d.point((x, by + bh - 2), fill=c(GOLD))
    os.makedirs(out, exist_ok=True)
    im.save(os.path.join(out, 'popover-header.png'))
    bg = Image.new('RGBA', (96 * 4, 96 * 4), c(FELT))
    bg.alpha_composite(im.resize((384, 384), Image.NEAREST))
    return bg


if __name__ == '__main__':
    out = sys.argv[1] if len(sys.argv) > 1 else os.path.join(HERE, '..', '..', '..', '..', 'game', 'assets', 'img', 'pfight')
    main(out).save('/tmp/claude-0/-home-user-gnome-venture/eeef1a78-9132-5047-a202-402fee8b4740/scratchpad/pop-prev.png')
