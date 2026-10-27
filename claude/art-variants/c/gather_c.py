"""Gather UI variation C: foraging satchel / found-it reveal.

Usage: python3 claude/art-variants/c/gather_c.py   (writes PNGs next to this file)
Scene on the 240x135 grid at 2x (480x270) via aseprite-source/scenes-pil/pixlib.py.
Flourishes: 4-frame strips per rarity (frame 48x48 native, 96x96 out, transparent).
Tool-belt slots: 24x24 native icons (+@2x), tools from game/includes/tools.php gather set
(hand=bare-hand foraging, forage knife, basket, rod, net, pick, bucket, axe) plus empty / locked.
"""
import os, sys
import numpy as np
from PIL import Image
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, '..', '..', '..', 'aseprite-source', 'scenes-pil'))
import pixlib as P
from pixlib import Canvas, ramp, rect, rrect, ell, poly, line, shift, OL

WOOD = ramp('#9a6b3f', '#7a4a1f', '#c9a96e', '#8a5a30')
DWOOD = ramp('#7a4a1f', '#5c3420', '#9a6b3f')
LEATHER = ramp('#b07a3a', '#7a4a1f', '#d9a35a', '#8a5a30')
DLEATH = ramp('#7a4a1f', '#5c3420', '#9a6b3f')
CREAM = ramp('#f2e4c0', '#c9a96e', '#fff3c8')
MOSS = ramp('#4f9a45', '#2f6a3a', '#7ab55c')
LEAF = ramp('#7ab55c', '#4f9a45', '#a4b86a')
STONE = ramp('#8b8f96', '#5b6470', '#c9c5bc')
SOIL = ramp('#6b4a2e', '#4a2c1a', '#8a6440')
GOLD = ramp('#e8a317', '#b07a10', '#f5cf6a')
EMBER = ramp('#d6322b', '#a8241f', '#f08a24')
WATER = ramp('#3f8fb0', '#25637d', '#a9d6ea')
DUSK = ramp('#7a5cc0', '#4e3a8a', '#c3b2ea')
METAL = ramp('#c9c5bc', '#8b8f96', '#ffffff')
KEY = '#ff00ff'
RAR = {  # (main, light, deep) per rarity, from the shared families
    'common': ('#c9c5bc', '#ffffff', '#8b8f96'),
    'uncommon': ('#7ab55c', '#c8e6a0', '#4f9a45'),
    'rare': ('#3f8fb0', '#a9d6ea', '#7a5cc0'),
    'legendary': ('#e8a317', '#fff3c8', '#f08a24'),
}


def keyed(cv, box, scale):
    x0, y0, x1, y1 = box
    a = cv.px[y0:y1, x0:x1]
    im = Image.fromarray(a, 'RGB').convert('RGBA')
    arr = np.array(im)
    arr[np.all(a == P.hx(KEY), axis=2), 3] = 0
    im = Image.fromarray(arr, 'RGBA')
    return im.resize((im.width * scale, im.height * scale), Image.NEAREST)


# ------------------------------------------------------------------ scene
def scene():
    W, H = P.W, P.H
    cv = Canvas('#a9d6ea')
    # sky band + far hedge + forest floor
    cv.fill(rect(0, 0, W - 1, 30), '#c8e6ea')
    for i, x in enumerate(range(-10, W + 20, 22)):
        o = cv.obj(outline=False)
        o.part(ell(x, 14 + (i % 3) * 3, x + 34, 56), MOSS if i % 2 else LEAF, d=3)
        o.draw()
    cv.fill(rect(0, 50, W - 1, H - 1), '#8a6440')
    cv.fill(rect(0, 50, W - 1, 53), '#4f9a45')
    for y in range(58, H, 9):
        for x in range((y * 7) % 17, W, 23):
            cv.fill(rect(x, y, x + 3, y), '#6b4a2e')
    # moss patch where the find lands
    o = cv.obj(); o.part(ell(70, 92, 170, 122), MOSS, d=3); o.draw()
    cv.dots([(x, y) for x in range(80, 160, 6) for y in (100, 108) if (x // 6 + y) % 2], '#a4b86a')
    # stones + mushroom + fern props
    for (x, y, w) in ((12, 100, 22), (200, 108, 26), (186, 96, 12)):
        o = cv.obj(); o.part(ell(x, y, x + w, y + w * 2 // 3), STONE, d=3); o.draw()
    o = cv.obj(); o.part(rect(30, 74, 33, 86), CREAM, d=1); o.part(ell(22, 66, 42, 78) & rect(0, 0, W, 73), EMBER, d=2); o.draw()
    cv.dots([(27, 69), (35, 70), (31, 67)], '#fff3c8')
    for k in range(5):
        o = cv.obj(outline=False); o.part(line([(222, 90), (206 + k * 7, 62 + abs(k - 2) * 4)], 2), LEAF, d=1); o.draw()
    # open satchel, right of centre, flap thrown back
    o = cv.obj()
    o.part(rrect(150, 50, 206, 64, 3), DLEATH, d=2)            # back wall / opening
    o.part(rrect(146, 60, 210, 104, 4), LEATHER, d=3)          # body
    o.part(poly([(150, 52), (206, 52), (214, 34), (146, 36)]), LEATHER, d=2, contour=True)  # flap back
    o.part(rect(173, 64, 183, 76), DLEATH, d=1, contour=True)  # buckle tab
    o.draw()
    cv.fill(rrect(152, 54, 204, 62, 2), '#2a1a10')            # dark inside
    cv.fill(rect(175, 68, 181, 73) & ~rect(177, 70, 179, 71), '#e8a317')
    for x in range(150, 207, 3):
        cv.dots([(x, 99)], '#f5cf6a')                           # stitched seam
    o = cv.obj(); o.part(line([(146, 64), (128, 30), (100, 22)], 3), DLEATH, d=1); o.draw()  # strap
    # landing ring shadow + spotlight for the find
    cv.fill(ell(96, 98, 144, 112), '#2f6a3a')
    cv.fill(ell(100, 100, 140, 110), '#4f9a45')
    cv.save(os.path.join(HERE, 'gather-c-scene.png'))
    return cv


# ------------------------------------------------------------------ flourish strips
def flourish(rarity, lvl):
    main, light, deep = RAR[rarity]
    F, N = 48, 4
    strip = Image.new('RGBA', (F * N * 2, F * 2), (0, 0, 0, 0))
    for f in range(N):
        cv = Canvas(KEY)
        c = F // 2
        ring = lvl >= 1
        if ring:
            r = 10 + f * 2 + lvl
            m = ell(c - r, c - r, c + r, c + r) & ~ell(c - r + 1, c - r + 1, c + r - 1, c + r - 1)
            if f % 2:
                m &= ~(rect(0, c - 1, F, c + 1) | rect(c - 1, 0, c + 1, F))
            cv.fill(m, main if f < 3 else deep)
        if lvl >= 3:  # legendary rays
            for k in range(8):
                a = k * np.pi / 4 + f * np.pi / 16
                r0, r1 = 6 + f, 16 + f * 2
                cv.fill(line([(c + r0 * np.cos(a), c + r0 * np.sin(a)), (c + r1 * np.cos(a), c + r1 * np.sin(a))]), light if k % 2 else main)
        rng = np.random.RandomState(lvl * 10 + 1)
        pts = rng.randint(4, F - 4, (3 + lvl * 3, 2))
        for i, (x, y) in enumerate(pts):
            ph = (f + i) % 4  # sparkle grows 0..2 then fades
            s = (0, 1, 2, 1)[ph] + (1 if lvl >= 2 and i % 2 == 0 else 0)
            if s == 0:
                cv.dots([(x, y)], deep); continue
            cv.fill(rect(x - s, y, x + s, y) | rect(x, y - s, x, y + s), main)
            cv.dots([(x, y)], light)
        if lvl == 0 and f == 1:
            cv.dots([(c - 3, c - 3), (c + 3, c + 3)], light)
        strip.paste(keyed(cv, (0, 0, F, F), 2), (f * F * 2, 0))
    strip.save(os.path.join(HERE, f'gather-c-flourish-{rarity}.png'), optimize=True)
    return strip


# ------------------------------------------------------------------ tool-belt slot icons
def slot_base(cv, state):
    cv.fill(rrect(0, 0, 23, 23, 3), '#4a2c1a')
    cv.fill(rrect(1, 1, 22, 22, 3), '#7a4a1f' if state != 'locked' else '#5c3420')
    cv.fill(rect(0, 18, 23, 21), '#9a6b3f')                     # belt strap
    cv.dots([(x, 19) for x in range(2, 22, 3)], '#f5cf6a')
    # leather loop the tool hangs on
    cv.fill(rect(10, 2, 13, 5) & ~rect(11, 3, 12, 4), '#d9a35a' if state != 'locked' else '#7a4a1f')


def tool(cv, name):
    o = cv.obj()
    if name == 'hand':
        o.part(rrect(7, 9, 16, 17, 2), ramp('#f2c09a', '#c98a5a', '#fff3c8'), d=1)
        for x in (8, 10, 12, 14):
            o.part(rect(x, 6, x + 1, 10), ramp('#f2c09a', '#c98a5a', '#fff3c8'), d=1)
        o.part(rect(4, 11, 7, 13), ramp('#f2c09a', '#c98a5a'), d=1)
    elif name == 'forage':
        o.part(rect(11, 6, 12, 11), DWOOD, d=1)
        o.part(poly([(10, 12), (13, 12), (13, 19), (11, 17)]), METAL, d=1, contour=True)
    elif name == 'basket':
        o.part(line([(6, 11), (8, 6), (15, 6), (17, 11)], 1), WOOD, d=0)
        o.part(rrect(5, 11, 18, 17, 2), WOOD, d=1)
    elif name == 'rod':
        o.part(line([(5, 18), (18, 5)], 1), WOOD, d=0)
        o.part(rect(17, 6, 17, 13), ramp('#c9c5bc', '#8b8f96'), d=0, flat=True)
        o.part(rect(16, 13, 18, 15), EMBER, d=1)
    elif name == 'net':
        o.part(line([(6, 18), (11, 12)], 1), WOOD, d=0)
        o.part(ell(10, 4, 19, 13) & ~ell(11, 5, 18, 12), CREAM, d=0)
    elif name == 'pick':
        o.part(rect(11, 7, 12, 17), WOOD, d=1)
        o.part(poly([(4, 9), (12, 5), (19, 9), (12, 7)]), STONE, d=1, contour=True)
    elif name == 'bucket':
        o.part(poly([(6, 9), (17, 9), (15, 17), (8, 17)]), WATER, d=1)
        o.part(rect(6, 8, 17, 9), METAL, d=0, contour=True)
    elif name == 'axe':
        o.part(rect(11, 6, 12, 18), WOOD, d=1)
        o.part(poly([(12, 7), (18, 5), (18, 13), (12, 11)]), METAL, d=1, contour=True)
    o.draw()
    if name == 'net':
        cv.dots([(x, y) for x in range(12, 18, 2) for y in range(6, 12, 2)], '#c9a96e')


def icon(name, state='owned'):
    cv = Canvas(KEY)
    slot_base(cv, state)
    if state == 'owned':
        tool(cv, name)
    elif state == 'empty':
        cv.dots([(x, 14) for x in range(7, 17, 2)] + [(12, y) for y in range(8, 18, 2)], '#9a6b3f')
    else:  # locked: padlock
        o = cv.obj(); o.part(rrect(8, 10, 15, 17, 1), GOLD, d=1); o.draw()
        cv.fill(rect(9, 6, 14, 9) & ~rect(10, 7, 13, 9), '#8b8f96')
        cv.dots([(11, 13), (12, 13), (11, 14), (12, 14)], '#4a2c1a')
    base = f'gather-c-slot-{name}'
    for sc, suf in ((1, ''), (2, '@2x')):
        keyed(cv, (0, 0, 24, 24), sc).save(os.path.join(HERE, base + suf + '.png'), optimize=True)
    return keyed(cv, (0, 0, 24, 24), 2)


TOOLS = ['hand', 'forage', 'basket', 'rod', 'net', 'pick', 'bucket', 'axe']

if __name__ == '__main__':
    sc = scene()
    strips = [flourish(r, i) for i, r in enumerate(RAR)]
    icons = [icon(t) for t in TOOLS] + [icon('empty', 'empty'), icon('locked', 'locked')]
    # contact sheet
    sheet = Image.new('RGBA', (800, 270 + 4 * 100 + 60), (42, 26, 16, 255))
    big = Image.open(os.path.join(HERE, 'gather-c-scene.png'))
    sheet.paste(big, (10, 0))
    # demo: legendary frame 2 over the landing spot
    sheet.alpha_composite(strips[3].crop((192, 0, 288, 96)), (10 + 240 - 48, 210 - 48))
    for i, s in enumerate(strips):
        sheet.alpha_composite(s, (10, 280 + i * 100))
    for i, ic in enumerate(icons):
        sheet.alpha_composite(ic, (10 + i * 56, 690))
    sheet.save(os.path.join(HERE, 'preview.png'))
    print('colours in scene:', sc.colours())
