#!/usr/bin/env python3
"""Redraw the Tortoise Run (animals/tortoise_run.png; it was a boxed scene with no outline), which has no v3 picture. 64x64, transparent, 1 px ink outline, lit top-left.
Run: python3 -I tools/draw_fix_art.py   (needs Pillow)"""
import math, os
from PIL import Image, ImageDraw
REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__))); IMG = os.path.join(REPO, "game", "assets", "img")
T = 64; OUTL = (0x2b, 0x1c, 0x26, 255)
def c(h, a=255): return tuple(int(h[i:i + 2], 16) for i in (1, 3, 5)) + (a,)
def outline(im):
    src = im.load(); out = im.copy(); o = out.load()
    for y in range(T):
        for x in range(T):
            if src[x, y][3] == 0 and any(0 <= x + dx < T and 0 <= y + dy < T and src[x + dx, y + dy][3] > 200 for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))): o[x, y] = OUTL
    return out
def shadow(d, box): d.ellipse(box, fill=(0, 0, 0, 60))
def tortoise_run():
    im = Image.new("RGBA", (T, T), (0, 0, 0, 0)); d = ImageDraw.Draw(im)
    shadow(d, [6, 51, 59, 60])
    # grassy pen floor
    d.ellipse([6, 40, 58, 58], fill=c('#5a3a24')); d.ellipse([7, 40, 57, 55], fill=c('#8a5a34')); d.ellipse([12, 42, 46, 52], fill=c('#a8743f'))
    for x, y in ((14, 46), (22, 50), (40, 44), (48, 50), (30, 53), (50, 47), (10, 50), (36, 55)): d.point((x, y), fill=c('#e0c070')); d.point((x + 1, y - 1), fill=c('#c4a050')); d.point((x - 1, y + 1), fill=c('#6b4228'))
    for x in (10, 52): d.point((x, 44), fill=c('#5a9a48')); d.point((x, 43), fill=c('#97cc66'))
    # back fence: posts and two rails
    for px in (9, 24, 39, 54):
        d.rectangle([px, 22, px + 3, 44], fill=c('#8a5a34')); d.rectangle([px, 22, px + 1, 44], fill=c('#a8743f')); d.rectangle([px, 21, px + 3, 22], fill=c('#c8965a'))
    for ry in (28, 36): d.rectangle([9, ry, 57, ry + 3], fill=c('#a8743f')); d.rectangle([9, ry, 57, ry + 1], fill=c('#c8965a')); d.line([(9, ry + 3), (57, ry + 3)], fill=c('#6b4228'))
    # tortoise: legs, tail, head, shell
    for lx in (19, 40): d.rounded_rectangle([lx, 46, lx + 6, 53], 2, fill=c('#b89a5a')); d.line([(lx + 1, 52), (lx + 5, 52)], fill=c('#7a6238'))
    d.polygon([(14, 46), (9, 44), (12, 49)], fill=c('#b89a5a'))
    d.ellipse([45, 38, 57, 49], fill=c('#d8c07a')); d.ellipse([46, 38, 56, 47], fill=c('#e8d494')); d.point((53, 42), fill=c('#2b1c26')); d.point((54, 41), fill=c('#ffffff')); d.line([(50, 46), (55, 46)], fill=c('#a88c4a'))
    d.pieslice([13, 30, 47, 58], 180, 360, fill=c('#3d5a2a')); d.pieslice([13, 30, 47, 56], 180, 360, fill=c('#5a8a3a')); d.chord([13, 47, 47, 51], 0, 180, fill=c('#2f4a22'))
    d.pieslice([16, 32, 42, 54], 195, 300, fill=c('#7aaa4a'))
    for (x1, y1, x2, y2) in ((20, 42, 28, 38), (28, 38, 36, 38), (36, 38, 42, 42), (27, 46, 30, 38), (35, 46, 34, 38)): d.line([(x1, y1), (x2, y2)], fill=c('#3d5a2a'))
    for x, y in ((24, 36), (31, 34), (38, 36)): d.point((x, y), fill=c('#a8d070')); d.point((x - 1, y), fill=c('#98c060'))
    d.line([(15, 47), (45, 47)], fill=c('#2f4a22'))
    # a lettuce leaf in front
    d.ellipse([46, 50, 56, 56], fill=c('#97cc66')); d.line([(48, 53), (54, 53)], fill=c('#5a9a48'))
    return outline(im)
def main():
    tortoise_run().save(os.path.join(IMG, "animals", "tortoise_run.png"), optimize=True)
    print("tortoise_run.png written")
if __name__ == "__main__": main()
