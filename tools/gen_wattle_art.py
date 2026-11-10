#!/usr/bin/env python3
"""Redraw the wattle-fence placeholder set (game/assets/img/ph/wattle-fence-*.png), 64x64, top-down.
Base orientation matches YARD_SHAPE_MASK in game/includes/yard.php (N=1 E=2 S=4 W=8): end=E, straight=E+W, corner=E+S, tee=E+S+W, cross=all.
The game rotates the image, so every piece is drawn flat from above. Usage: python3 tools/gen_wattle_art.py"""
import os
from PIL import Image, ImageDraw

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'game', 'assets', 'img', 'ph')
INK = (58, 34, 32, 255)
ROD = [(122, 79, 44, 255), (163, 115, 58, 255), (201, 150, 74, 255), (229, 187, 98, 255)]     # dark -> light
STK = [(94, 58, 42, 255), (133, 80, 52, 255), (168, 108, 62, 255), (207, 145, 80, 255)]
CORD = (183, 159, 100, 255); CORD_D = (90, 74, 48, 255)
IRON = (69, 70, 89, 255); IRON_L = (163, 165, 184, 255)
SHADOW = (30, 20, 24, 70)
C, HW = 32, 10          # centre, half band width: band spans y 22..41
STEP = 8                # weave period; divides 64 so straight pieces tile


def band(img):
    """E-W woven hurdle across the whole tile: pale willow rods run along, dark round stakes cross, over/under."""
    p = img.load()
    rows = [(C - HW + 1 + i * 5, 4) for i in range(4)]            # 4 rods, 4px tall, 1px gap between
    for y in range(C - HW, C + HW):
        for x in range(64):
            p[x, y] = (74, 46, 34, 255)                           # gap / shade colour behind the weave
    for ri, (ya, h) in enumerate(rows):
        for x in range(64):
            # which stake (if any) is this x column part of: stakes are 4px wide every STEP, offset per row so the weave staggers
            k = (x - 2) % STEP
            stake = k < 4
            over_stake = ((x - 2) // STEP + ri) % 2 == 0           # rod passes over this stake on this row
            if stake and not over_stake:
                for j in range(h):
                    sh = [3, 2, 1, 0][min(3, (x - 2) % STEP)]
                    p[x, ya + j] = STK[0] if sh == 0 else (STK[1] if sh < 3 else STK[2])
            else:
                near = (x - 2) % STEP
                for j in range(h):
                    sh = 3 if j == 0 else (2 if j < 3 else 1)
                    if stake and over_stake and near in (0, 3): sh -= 1   # rod dips at stake edges
                    p[x, ya + j] = ROD[max(0, sh)]
    for x in range(64):
        for y in (C - HW - 1, C + HW):
            p[x, y] = INK


def post(img, cx=C, cy=C, r=7):
    d = ImageDraw.Draw(img)
    d.ellipse((cx - r - 1, cy - r - 1, cx + r, cy + r), fill=INK)
    d.ellipse((cx - r, cy - r, cx + r - 1, cy + r - 1), fill=STK[1])
    d.ellipse((cx - r + 1, cy - r + 1, cx + r - 3, cy + r - 3), fill=STK[2])
    d.ellipse((cx - r + 2, cy - r + 2, cx + r - 5, cy + r - 5), fill=STK[3])
    d.line((cx - r + 1, cy + 1, cx + r - 2, cy + 1), fill=CORD, width=2)   # rope lashing
    d.line((cx - r + 1, cy + 3, cx + r - 2, cy + 3), fill=CORD_D)
    d.line((cx - 1, cy - r + 1, cx - 1, cy + r - 2), fill=CORD, width=2)
    d.point((cx - 2, cy - 3), (248, 220, 142, 255))


def piece(mask, with_post, gate=False):
    arms = Image.new('RGBA', (64, 64), (0, 0, 0, 0))
    full = Image.new('RGBA', (64, 64), (0, 0, 0, 0)); band(full)
    for bit, rot, lo, hi in ((2, 0, C, 63), (8, 0, 0, C - 1), (4, -90, C, 63), (1, 90, C, 63)):
        if mask & bit:
            half = full.rotate(rot, resample=Image.NEAREST) if rot else full
            m = Image.new('L', (64, 64), 0)
            ImageDraw.Draw(m).rectangle((lo, 0, hi, 63) if not rot else (C, 0, 63, 63), fill=255)
            if rot: m = m.rotate(rot, resample=Image.NEAREST)
            arms.alpha_composite(Image.composite(half, Image.new('RGBA', (64, 64), (0, 0, 0, 0)), m))
    # soft shadow: arms silhouette shifted down-right
    sh = Image.new('RGBA', (64, 64), (0, 0, 0, 0))
    a = arms.split()[3].point(lambda v: 255 if v else 0)
    sh.paste(SHADOW, (2, 3), a)
    out = Image.new('RGBA', (64, 64), (0, 0, 0, 0)); out.alpha_composite(sh); out.alpha_composite(arms)
    # side outlines of the arms (outline pixels the band() draws only cover the E-W case)
    o = out.load(); src = arms.load()
    for y in range(64):
        for x in range(64):
            if src[x, y][3] == 0:
                for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    nx, ny = x + dx, y + dy
                    if 0 <= nx < 64 and 0 <= ny < 64 and src[nx, ny][3] and src[nx, ny] != INK:
                        o[x, y] = INK; break
    if gate:
        d = ImageDraw.Draw(out)
        d.rectangle((14, C - 8, 49, C + 7), fill=INK)
        d.rectangle((15, C - 7, 48, C + 6), fill=(168, 108, 62, 255))
        for gx in range(18, 48, 5):
            d.rectangle((gx, C - 6, gx + 2, C + 5), fill=(207, 145, 80, 255)); d.line((gx + 3, C - 6, gx + 3, C + 5), fill=STK[0])
        d.line((17, C + 5, 46, C - 6), fill=STK[0], width=2)
        for hx in (9, 54):
            post(out, hx, C, 5)
        d.rectangle((13, C - 3, 16, C - 2), fill=IRON); d.rectangle((13, C + 2, 16, C + 3), fill=IRON)
        d.point((14, C - 3), IRON_L); d.point((14, C + 2), IRON_L)
        d.rectangle((46, C - 1, 49, C + 0), fill=IRON); d.point((47, C - 1), IRON_L)
    elif with_post:
        post(out)
    return out


PIECES = {'end': (2, True), 'straight': (10, False), 'corner': (6, True), 'tee': (14, True), 'cross': (15, True)}

if __name__ == '__main__':
    for name, (mask, wp) in PIECES.items():
        piece(mask, wp).save(os.path.join(OUT, f'wattle-fence-{name}.png'))
    piece(10, False, gate=True).save(os.path.join(OUT, 'wattle-fence-gate.png'))
    # inventory icon: a capped run
    ic = piece(10, False)
    post(ic, 9, C, 6); post(ic, 54, C, 6)
    ic.save(os.path.join(OUT, 'wattle-fence.png'))
