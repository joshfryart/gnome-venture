#!/usr/bin/env python3
"""Cuts a creature's pedestal mini (game/assets/img/mini/mini-<slug>.png, 80x80, faces right) into rig parts for the fight engine:
   body, head, legB (hind legs), legF (fore legs) -> game/assets/img/fight/rig-<slug>-<part>.png, all 80x80 in one frame, so they stack with no offsets.
   The pedestal is dropped and the art is shifted down so the feet sit on the frame's bottom row (the actor stands on the board, not on a toy base).
   Specs are hand-measured pixel regions (print the grid with --grid to measure a new creature). Pivots (printed, shifted coords) go into RIGS in fightengine.js.
   python3 tools/creature_rig_parts.py wild-boar [--grid]"""
import sys, pathlib
from PIL import Image, ImageDraw
ROOT = pathlib.Path(__file__).resolve().parents[1] / 'game/assets/img'
def hx(h): return tuple(int(h[i:i + 2], 16) for i in (0, 2, 4)) + (255,)
SPECS = {
  'wild-boar': dict(
    foot=62,                                        # row of the feet in the source; shifted to the bottom row
    head=lambda x, y: x >= 44 and y <= 51 and (y <= 44 or x >= 60) and not (x < 52 and y > 38) and not (x < 47 and y > 33),
    legs={'legB': (14, 50, 32, 62), 'legF': (46, 50, 63, 62)},   # x0,y0,x1,y1 boxes (hind pair, fore pair)
    legcols={'7a4a1f', '5d2d18', '2a1a10'},          # leg brown, far-leg dark, ink: anything else in a leg box is pedestal
    belly=56,                                       # the body keeps rows above this (outside the leg boxes)
    fill='7a4a1f',                                  # body colour painted where the head used to be
    fillbox=(44, 28, 57, 52),
    pivots={'head': (48, 42), 'body': (30, 50), 'legB': (20, 51), 'legF': (56, 51)}),
}
def main():
    slug = sys.argv[1]; S = SPECS[slug]; src = Image.open(ROOT / f'mini/mini-{slug}.png').convert('RGBA'); W, H = src.size
    if '--grid' in sys.argv:
        k = 10; b = Image.new('RGBA', (W * k, H * k), (70, 55, 45, 255)); b.alpha_composite(src.resize((W * k, H * k), Image.NEAREST)); d = ImageDraw.Draw(b)
        for i in range(0, W, 5): d.line([(i * k, 0), (i * k, H * k)], fill=(255, 255, 255, 90 if i % 10 == 0 else 35)); d.line([(0, i * k), (W * k, i * k)], fill=(255, 255, 255, 90 if i % 10 == 0 else 35))
        b.save('/tmp/grid.png'); return
    dy = H - 1 - S['foot']
    parts = {n: Image.new('RGBA', (W, H), (0, 0, 0, 0)) for n in ('body', 'head', 'legB', 'legF')}
    def col(x, y): return '%02x%02x%02x' % src.getpixel((x, y))[:3]
    def put(n, x, y, c):
        if 0 <= y + dy < H: parts[n].putpixel((x, y + dy), c)
    inleg = {}
    for n, (x0, y0, x1, y1) in S['legs'].items():
        for y in range(y0, y1 + 1):
            for x in range(x0, x1 + 1):
                if src.getpixel((x, y))[3] and col(x, y) in S['legcols']: inleg[(x, y)] = n
    fx0, fy0, fx1, fy1 = S['fillbox']
    for y in range(H):
        for x in range(W):
            c = src.getpixel((x, y))
            if not c[3]: continue
            if (x, y) in inleg: put(inleg[(x, y)], x, y, c)
            elif S['head'](x, y): put('head', x, y, c)
            inbox = any(b[0] <= x <= b[2] and b[1] <= y <= b[3] for b in S['legs'].values())
            if (x, y) not in inleg and y < S['belly'] and not (inbox and y >= 52):
                if S['head'](x, y): 
                    if fx0 <= x <= fx1 and fy0 <= y <= fy1: put('body', x, y, hx(S['fill']))
                else: put('body', x, y, c)
    out = ROOT / 'fight'
    for n, im in parts.items(): im.save(out / f'rig-{slug}-{n}.png')
    print({k: (v[0], v[1] + dy) for k, v in S['pivots'].items()}, 'shift', dy)
main()
