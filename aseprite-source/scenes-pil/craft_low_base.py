"""Crafting-area scenes, variant 'low': shared bits for craft_low_<kitchen|pantry|alchemy>.py.
Writes aseprite-source/craftmap/scenes/low/<name>.png (1800x1200), <name>-thumb.png (450x300), <name>.json (+ _hs.png check)."""
import json
import os

from jigsaw_common import *  # noqa: F401,F403
from PIL import Image, ImageDraw

OUTD = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'craftmap', 'scenes', 'low')
WOOD = ramp('#b07a3a', '#7a4a1f', '#d9a35a', '#c98a4a')
DWOOD = ramp('#7a4a1f', '#5c3420', '#9a6b3f')
IRON = ramp('#4a4a56', '#2e2e38', '#7a7a8a')
COPPER = ramp('#c8743a', '#94502a', '#f0a868')
SKIN = ramp('#f2c8a0', '#d9a07a', '#fff0d8')
BEARD = ramp('#f1ece0', '#c9c5bc', '#ffffff')
CREAM = ramp('#f2e4c0', '#c9a96e', '#fff4d8')
GLASS = ramp('#cfe6ea', '#9cc4cc', '#ffffff')


def room(cv, wall, wall2, floor, floor2, fy=150, plank=True):
    """Calm back wall (vertical boards) and a floor band."""
    cv.fill(rect(0, 0, W - 1, fy - 1), wall)
    if plank:
        for x in range(0, W, 25):
            cv.fill(rect(x, 0, x, fy - 1), wall2)
    cv.fill(rect(0, fy - 4, W - 1, fy - 1), '#5c3420')   # skirting
    cv.fill(rect(0, fy - 4, W - 1, fy - 4), '#7a4a1f')
    cv.fill(rect(0, fy, W - 1, H - 1), floor)
    for i, y in enumerate(range(fy + 8, H, 12)):
        cv.fill(rect(0, y, W - 1, y), floor2)
        for x in range((i * 37) % 60, W, 60):
            cv.fill(rect(x, y - 11, x, y - 1), floor2)
    cv.fill(rect(0, 0, W - 1, 6), wall2)   # ceiling beam
    cv.fill(rect(0, 7, W - 1, 7), '#5c3420')


def shadow(cv, x0, x1, y, col):
    cv.fill(ell(x0, y - 3, x1, y + 3), col)


def gnome(cv, gx, gy, hat='#d6322b', coat='#3f8fb0', flip=False):
    """Small standing gnome, feet at (gx, gy), ~30 px tall."""
    HAT = ramp(hat, '#8a2c20' if hat == '#d6322b' else '#4a2c5a', '#f08a64' if hat == '#d6322b' else '#b49ad6')
    COAT = ramp(coat, '#25637d' if coat == '#3f8fb0' else '#2f5a3a', '#a9d6ea' if coat == '#3f8fb0' else '#8cc48c')
    o = cv.obj()
    o.part(rect(gx - 5, gy - 3, gx - 1, gy), DWOOD, d=1)
    o.part(rect(gx + 1, gy - 3, gx + 5, gy), DWOOD, d=1)
    o.part(poly([(gx - 7, gy - 3), (gx + 7, gy - 3), (gx + 5, gy - 16), (gx - 5, gy - 16)]), COAT, d=2)
    o.part(ell(gx - 5, gy - 22, gx + 5, gy - 13), SKIN, d=1)
    o.part(poly([(gx - 6, gy - 18), (gx + 6, gy - 18), (gx, gy - 7)]), BEARD, d=1)
    tip = gx + (-5 if flip else 5)
    o.part(poly([(gx - 7, gy - 20), (gx + 7, gy - 20), (tip, gy - 34)]), HAT, d=2)
    o.draw()
    cv.dots([(gx - 2, gy - 18), (gx + 2, gy - 18)], '#2a1a10')
    cv.dots([(gx, gy - 17)], '#d9a07a')


def save(cv, name, hotspots):
    os.makedirs(OUTD, exist_ok=True)
    im = Image.fromarray(cv.px, 'RGB').resize((W * SCALE, H * SCALE), Image.NEAREST)
    im.save(os.path.join(OUTD, name + '.png'), optimize=True)
    im.resize((450, 300), Image.NEAREST).save(os.path.join(OUTD, name + '-thumb.png'), optimize=True)
    with open(os.path.join(OUTD, name + '.json'), 'w') as f:
        json.dump({'scene': name, 'w': W, 'h': H, 'hotspots': [dict(id=i, label=l, x=x, y=y, w=w, h=h) for i, l, x, y, w, h in hotspots]}, f, indent=1)
    hs = im.copy()
    d = ImageDraw.Draw(hs)
    for i, l, x, y, w, h in hotspots:
        assert w >= 37 and h >= 37, i
        d.rectangle([x * SCALE, y * SCALE, (x + w) * SCALE - 1, (y + h) * SCALE - 1], outline=(255, 0, 255), width=6)
        d.text((x * SCALE + 10, y * SCALE + 10), i, fill=(255, 0, 255))
    hs.resize((900, 600)).save(os.path.join(OUTD, name + '_hs.png'))
    for a in range(len(hotspots)):
        for b in range(a + 1, len(hotspots)):
            _, _, x, y, w, h = hotspots[a]
            _, _, X, Y, WW, HH = hotspots[b]
            assert x + w <= X or X + WW <= x or y + h <= Y or Y + HH <= y, (hotspots[a][0], hotspots[b][0])
    print(name, 'colours', cv.colours())
