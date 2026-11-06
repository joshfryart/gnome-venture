#!/usr/bin/env python3
"""Cuts a creature's pedestal mini (game/assets/img/mini/mini-<slug>.png, faces right) into rig parts for the fight engine:
   game/assets/img/fight/rig-<slug>-<part>.png, all the same size as the mini, so parts stack with no offsets.
   Quadrupeds: pedestal dropped and the art shifted down so the feet sit on the bottom row (the actor stands on the board).
   Front-facing toys (scorpion, frog): the pedestal is kept as a static 'base' part.
   Specs are hand-measured pixel regions: `--grid` writes /tmp/grid.png (10x, every 5 px) to measure a new creature.
   A pixel goes to the FIRST part whose mask matches; what is left (and passes `bodymask`) is the body. `fills` paint body colour where a moving part used to be.
   Pivots (shifted coords) are printed: copy them into CRIT[slug] in fightengine.js.
   python3 tools/creature_rig_parts.py <slug|all> [--grid]"""
import sys, pathlib
from PIL import Image, ImageDraw
ROOT = pathlib.Path(__file__).resolve().parents[1] / 'game/assets/img'
def hx(h): return tuple(int(h[i:i + 2], 16) for i in (0, 2, 4)) + (255,)
def box(x0, y0, x1, y1): return lambda x, y: x0 <= x <= x1 and y0 <= y <= y1
def anyof(*m): return lambda x, y: any(f(x, y) for f in m)
def leg(src, b, plate, extra=()):
    """Mask of a leg pair: pixels in box b whose colour appears in the box ABOVE the pedestal plate (row < plate) or at the extra sample points (hooves). Pedestal colours are left out."""
    x0, y0, x1, y1 = b; cols = set()
    for y in range(y0, min(y1, plate - 1) + 1):
        for x in range(x0, x1 + 1):
            if src.getpixel((x, y))[3]: cols.add(src.getpixel((x, y))[:3])
    for p in extra: cols.add(src.getpixel(p)[:3])
    return lambda x, y: x0 <= x <= x1 and y0 <= y <= y1 and src.getpixel((x, y))[3] > 0 and src.getpixel((x, y))[:3] in cols
def quad(slug, S, src):
    """Shared quadrupeds: parts = tail?, legB, legF, head; body is what is left above the belly line."""
    P = [(n, m) for n, m in S.get('tail', [])]
    P += [('legB', leg(src, S['legB'], S['plate'], S.get('hoof', ()))), ('legF', leg(src, S['legF'], S['plate'], S.get('hoof', ()))), ('head', S['head'])]
    lb, lf = S['legB'], S['legF']
    def bodymask(x, y): return y < S['belly'] and not ((lb[0] <= x <= lb[2] or lf[0] <= x <= lf[2]) and y >= S['belly'] - 4)
    return dict(foot=62, parts=P, bodymask=bodymask, fills=[('head', S['fill'][0], S['fill'][1])] + ([('tail', S['tailfill'][0], S['tailfill'][1])] if 'tailfill' in S else []))
SPECS = {
  'wild-boar': lambda src: quad('wild-boar', dict(plate=56, belly=56, legB=(14, 50, 32, 62), legF=(46, 50, 63, 62),
      head=lambda x, y: x >= 44 and y <= 51 and (y <= 44 or x >= 60) and not (x < 52 and y > 38) and not (x < 47 and y > 33), fill=((44, 28, 57, 52), (30, 40))), src) | dict(
      pivots={'head': (48, 42), 'body': (30, 50), 'legB': (20, 51), 'legF': (56, 51)}, order=['legB', 'legF', 'body', 'head']),
  'bramble-wolf': lambda src: quad('bramble-wolf', dict(plate=56, belly=56, legB=(21, 50, 32, 62), legF=(46, 50, 57, 62),
      tail=[('tail', box(0, 24, 19, 50))],
      head=lambda x, y: x >= 44 and ((y <= 40) or (x >= 55 and y <= 47)) and y <= 47, fill=((44, 30, 55, 42), (35, 42))), src) | dict(
      pivots={'head': (48, 40), 'body': (34, 50), 'legB': (26, 51), 'legF': (51, 51), 'tail': (20, 42)}, order=['tail', 'legB', 'legF', 'body', 'head']),
  'black-bear': lambda src: quad('black-bear', dict(plate=56, belly=56, legB=(17, 50, 31, 62), legF=(46, 50, 63, 62),
      head=lambda x, y: x >= 41 and y <= 50 and (y <= 44 or x >= 60) and not (x < 50 and y > 38) and not (x < 45 and y > 33), fill=((41, 28, 56, 52), (30, 40))), src) | dict(
      pivots={'head': (46, 42), 'body': (30, 50), 'legB': (23, 51), 'legF': (55, 51)}, order=['legB', 'legF', 'body', 'head']),
  'cliff-ram': lambda src: quad('cliff-ram', dict(plate=57, belly=57, legB=(16, 45, 31, 62), legF=(47, 45, 62, 62), hoof=[(20, 60), (52, 60)],
      tail=[('tail', box(0, 28, 14, 48))],
      head=lambda x, y: (x >= 41 and y <= 26) or (x >= 45 and y <= 44), fill=((41, 22, 56, 44), (35, 40))), src) | dict(
      pivots={'head': (50, 38), 'body': (32, 48), 'legB': (23, 46), 'legF': (55, 46), 'tail': (14, 40)}, order=['tail', 'legB', 'legF', 'body', 'head']),
  'dune-scorpion': lambda src: dict(foot=None, parts=[('base', lambda x, y: y >= 44), ('tail', box(10, 16, 19, 30)), ('clawL', box(0, 27, 17, 43)), ('clawR', box(38, 26, 55, 43))],
      bodymask=lambda x, y: True, fills=[], pivots={'body': (28, 40), 'tail': (15, 30), 'clawL': (17, 35), 'clawR': (39, 35)}, order=['base', 'tail', 'body', 'clawL', 'clawR']),
  'bullfrog': lambda src: dict(foot=None, parts=[('base', lambda x, y: y >= 49), ('eyeL', box(0, 9, 27, 26)), ('eyeR', box(28, 9, 55, 26))],
      bodymask=lambda x, y: True, fills=[('eyeL', (8, 14, 47, 26), (28, 32)), ('eyeR', (8, 14, 47, 26), (28, 32))], pivots={'body': (28, 45), 'eyeL': (18, 24), 'eyeR': (38, 24)}, order=['base', 'body', 'eyeL', 'eyeR']),
}
def cut(slug):
    src = Image.open(ROOT / f'mini/mini-{slug}.png').convert('RGBA'); W, H = src.size; S = SPECS[slug](src)
    dy = 0 if S['foot'] is None else H - 1 - S['foot']
    names = [n for n, _ in S['parts']] + ['body']
    parts = {n: Image.new('RGBA', (W, H), (0, 0, 0, 0)) for n in names}
    def put(n, x, y, c):
        if 0 <= y + dy < H: parts[n].putpixel((x, y + dy), c)
    owner = {}
    for y in range(H):
        for x in range(W):
            c = src.getpixel((x, y))
            if not c[3]: continue
            for n, m in S['parts']:
                if m(x, y): owner[(x, y)] = n; put(n, x, y, c); break
            else:
                if S['bodymask'](x, y): put('body', x, y, c)
    for n, b, (sx, sy) in S['fills']:   # body colour where a moving part used to be
        fc = src.getpixel((sx, sy))
        for (x, y), o in owner.items():
            if o == n and b[0] <= x <= b[2] and b[1] <= y <= b[3]: put('body', x, y, fc)
    out = ROOT / 'fight'
    for n, im in parts.items():
        if im.getbbox(): im.save(out / f'rig-{slug}-{n}.png')
    print(slug, 'size', (W, H), 'order', S['order'], 'pivots', {k: (v[0], v[1] + dy) for k, v in S['pivots'].items()}, 'shift', dy)
def grid(slug):
    src = Image.open(ROOT / f'mini/mini-{slug}.png').convert('RGBA'); W, H = src.size; k = 10
    b = Image.new('RGBA', (W * k, H * k), (70, 55, 45, 255)); b.alpha_composite(src.resize((W * k, H * k), Image.NEAREST)); d = ImageDraw.Draw(b)
    for i in range(0, max(W, H), 5):
        d.line([(i * k, 0), (i * k, H * k)], fill=(255, 255, 255, 90 if i % 10 == 0 else 35)); d.line([(0, i * k), (W * k, i * k)], fill=(255, 255, 255, 90 if i % 10 == 0 else 35))
    b.save('/tmp/grid.png')
if __name__ == '__main__':
    a = sys.argv[1]
    for s in (SPECS if a == 'all' else [a]): (grid if '--grid' in sys.argv else cut)(s)
