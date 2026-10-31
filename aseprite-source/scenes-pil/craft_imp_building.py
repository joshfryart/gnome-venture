"""Crafting area scene: BUILDING / builders' yard (variant imp). Usage: python3 -B aseprite-source/scenes-pil/craft_imp_building.py [outdir]
Writes aseprite-source/craftmap/scenes/imp/building.png (1800 x 1200), building-thumb.png (450 x 300), building.json (hotspots) and building_hs.png.
Brief: claude/craftmap-scene-brief.md (Round 2). Clean and clear, five big tap targets under a timber lean-to on a calm putty yard wall:
hero = a pyramid of dressed grey stone blocks topped by a red marker pennant (centre, framed by an open gateway arch onto the sky);
left = a crane pulley hanging from the roof beam over a sawhorse with a plank and saw; right = rope coils on a wall post over a timber stack.
"""
import json
import os
import sys

from jigsaw_common import *  # noqa: F401,F403
from PIL import Image, ImageDraw

NAME = 'building'
OUTDIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'craftmap', 'scenes', 'imp')


def save_scene(cv, name, hotspots, outdir=None):
    """<name>.png (6x nearest), <name>-thumb.png (450 x 300), <name>.json, and <name>_hs.png with the hotspot rects."""
    outdir = outdir or OUTDIR
    os.makedirs(outdir, exist_ok=True)
    im = Image.fromarray(cv.px, 'RGB').resize((W * SCALE, H * SCALE), Image.NEAREST)
    im.save(os.path.join(outdir, name + '.png'), optimize=True)
    im.resize((450, 300), Image.NEAREST).save(os.path.join(outdir, name + '-thumb.png'), optimize=True)
    with open(os.path.join(outdir, name + '.json'), 'w') as f:
        json.dump({'scene': name, 'w': W, 'h': H, 'hotspots': hotspots}, f, indent=1)
    hs = im.copy()
    d = ImageDraw.Draw(hs)
    for i, h in enumerate(hotspots):
        for a, b in ((h, hotspots[j]) for j in range(i + 1, len(hotspots))):
            assert a['x'] + a['w'] <= b['x'] or b['x'] + b['w'] <= a['x'] or a['y'] + a['h'] <= b['y'] or b['y'] + b['h'] <= a['y'], (a['id'], b['id'])
        assert h['w'] >= 37 and h['h'] >= 37, h['id']
        x0, y0 = h['x'] * SCALE, h['y'] * SCALE
        x1, y1 = (h['x'] + h['w']) * SCALE - 1, (h['y'] + h['h']) * SCALE - 1
        d.rectangle([x0, y0, x1, y1], outline=(0, 255, 255), width=4)
        d.text((x0 + 10, y0 + 8), h['id'], fill=(0, 255, 255))
    hs.save(os.path.join(outdir, name + '_hs.png'))
    return cv.colours()


# ---------------------------------------------------------------- palette (stone grey / timber / rope tan / red accent)
WALL, WALL_S = '#b9ad98', '#a89b85'
SKY, SKY_L, HILL = '#cfe0e0', '#e2ecea', '#a9c2a6'
FLOOR, FLOOR_S, FLOOR_L = '#8c7d6a', '#766856', '#a29380'
SHADOW = '#635747'
STONE = ramp('#a9b1c0', '#7e8698', '#dfe3ea', '#959db0')
STONE_T = ramp('#d4d9e2', '#a9b1c0', '#f1f3f6')   # lit top faces
WOOD = ramp('#b07a45', '#8a4f2a', '#d9a660', '#9a6438')
DWOOD = ramp('#7a4a1f', '#5c3420', '#9a6b3f')
PLANK = ramp('#d0a064', '#a8743e', '#ecc58a', '#b8854a')
ENDG = ramp('#ecc58a', '#c99a5c', '#f6dcaa')   # end grain
ROPE = ramp('#d8b27a', '#a8804a', '#f0d8a4', '#bf9660')
IRON = ramp('#4e5262', '#34343f', '#767c90', '#5b6070')
STEEL = ramp('#b8c2cc', '#7e8a98', '#e8eef2')
RED = ramp('#d6322b', '#a8241f', '#f0603a')
GOLD = ramp('#e8a317', '#b07a10', '#f5cf6a')
UMB = '#2a1a10'

cv = new_canvas(WALL)


def shadow(x0, y0, x1, y1):
    cv.fill(ell(x0, y0, x1, y1), SHADOW)


def draw(*parts):
    o = cv.obj()
    for p in parts:
        o.part(*p[:2], **(p[2] if len(p) > 2 else {}))
    return o.draw()


def sparkle(x, y, s=2, col=GOLD['r']):
    cv.fill(rect(x - s, y, x + s, y) | rect(x, y - s, x, y + s), col)
    cv.dots([(x, y)], '#ffffff')


# ---------------------------------------------------------------- yard: lean-to roof beam, putty wall in big courses, earth floor in flags
FY = 150
for k, y in enumerate(range(16, FY, 18)):
    cv.fill(rect(0, y, W - 1, y), WALL_S)
    for jx in range(20 + (k % 2) * 32, W, 64):
        cv.fill(rect(jx, y + 1, jx, min(FY - 1, y + 17)), WALL_S)
cv.fill(rect(0, 0, W - 1, 7), DWOOD['b'])
cv.fill(rect(0, 6, W - 1, 7), DWOOD['s'])
cv.fill(rect(0, 0, W - 1, 0), DWOOD['r'])
for bx in (40, 150, 260):
    cv.fill(rect(bx, 1, bx, 5), DWOOD['s'])
cv.fill(rect(0, 8, W - 1, 8), WALL_S)
cv.fill(rect(0, FY, W - 1, H - 1), FLOOR)
for k, y in enumerate((FY + 14, FY + 31)):
    cv.fill(rect(0, y, W - 1, y), FLOOR_S)
for k, (y0, y1) in enumerate(((FY, FY + 13), (FY + 15, FY + 30), (FY + 32, H - 1))):
    for jx in range(26 + k * 23, W, 62):
        cv.fill(rect(jx, y0, jx, y1), FLOOR_S)
        cv.fill(rect(jx + 1, y0 + 1, jx + 1, y0 + 3), FLOOR_L)
cv.fill(rect(0, FY, W - 1, FY), FLOOR_L)

# ---------------------------------------------------------------- gateway arch behind the hero: sky and a far hill (frames the stack)
AX0, AX1 = 96, 204
arch = rect(AX0, 50, AX1, FY - 1) | ell(AX0, 22, AX1, 78)
quoin = dil4(dil4(dil4(arch))) & ~arch & ~rect(0, FY, W, H)
draw((quoin, ramp('#cbc0ac', WALL_S, '#ddd4c2'), {'d': 1}))
cv.fill(arch, SKY)
cv.fill(arch & rect(0, 0, W, 60), SKY_L)
cv.fill(arch & (ell(70, 118, 170, 170) | ell(140, 124, 240, 172)), HILL)
for k, y in enumerate(range(30, FY, 14)):   # voussoir / jamb joints on the frame
    cv.fill(quoin & rect(0, y, W, y), WALL_S)

# ---------------------------------------------------------------- HERO: stacked dressed stone blocks with a red pennant
shadow(98, 172, 206, 184)


def block(x0, x1, ytop, yb, mark=0):
    """One dressed block: lit top face strip, front face with a drafted margin and a mason's mark."""
    top = poly([(x0 + 2, ytop), (x1 - 2, ytop), (x1, ytop + 6), (x0, ytop + 6)])
    front = rect(x0, ytop + 6, x1, yb)
    draw((top, STONE_T, {'d': 1}), (front, STONE, {'d': 3, 'contour': True}))
    cv.fill(rect(x0 + 3, ytop + 9, x1 - 3, yb - 3) & ~rect(x0 + 4, ytop + 10, x1 - 4, yb - 4), STONE['bo'])   # drafted margin
    cv.fill(rect(x0 + 3, ytop + 9, x1 - 3, ytop + 9) | rect(x0 + 3, ytop + 9, x0 + 3, yb - 3), STONE['r'])
    mx, my = (x0 + x1) // 2, (ytop + 6 + yb) // 2
    if mark == 1:
        cv.fill(line([(mx - 4, my + 3), (mx, my - 3), (mx + 4, my + 3)]), STONE['s'])
    elif mark == 2:
        cv.fill(rect(mx - 4, my, mx + 4, my) | rect(mx, my - 4, mx, my + 4), STONE['s'])


for x0, m in ((102, 1), (134, 0), (166, 2)):
    block(x0, x0 + 31, 140, 176, m)
for x0, m in ((118, 2), (150, 1)):
    block(x0, x0 + 31, 106, 143, m)
block(134, 165, 72, 109, 0)
# red marker pennant planted on the top block
draw((rect(148, 40, 150, 76), WOOD, {'d': 1}))
draw((poly([(151, 40), (176, 47), (151, 56)]), RED, {'d': 2}))
cv.fill(rect(152, 43, 156, 44), RED['r'])
for sx, sy in ((122, 64), (186, 72), (130, 40), (182, 36)):
    sparkle(sx, sy)

# ---------------------------------------------------------------- LEFT TOP: crane pulley hanging from the roof beam
PCX, PCY, PR = 52, 40, 21
draw((rect(PCX - 3, 6, PCX + 3, 14), IRON, {'d': 1}))   # hanger strap
fork = (rect(PCX - 25, 14, PCX + 25, 18) | rect(PCX - 25, 14, PCX - 22, PCY + 3) | rect(PCX + 22, 14, PCX + 25, PCY + 3))
wheel = ell(PCX - PR, PCY - PR, PCX + PR, PCY + PR)
draw((wheel, WOOD, {'d': 3}), (fork, IRON, {'d': 1, 'contour': True}))
cv.fill(wheel & ~ell(PCX - PR + 4, PCY - PR + 4, PCX + PR - 4, PCY + PR - 4), DWOOD['b'])   # groove rim
for a in range(4):
    import math
    ang = math.pi / 4 + a * math.pi / 2
    cv.fill(line([(PCX, PCY), (int(PCX + (PR - 5) * math.cos(ang)), int(PCY + (PR - 5) * math.sin(ang)))], 3), DWOOD['s'])
draw((ell(PCX - 5, PCY - 5, PCX + 5, PCY + 5), IRON, {'d': 1}))
cv.dots([(PCX - 2, PCY - 2)], IRON['r'])
# rope over the wheel and down both sides
ropearc = (ell(PCX - PR - 2, PCY - PR - 2, PCX + PR + 2, PCY + PR + 2) & ~ell(PCX - PR + 1, PCY - PR + 1, PCX + PR - 1, PCY + PR - 1)) & rect(0, 0, W, PCY)
lstr = rect(PCX - PR - 2, PCY, PCX - PR + 1, 92)
rstr = rect(PCX + PR - 1, PCY, PCX + PR + 2, 74)
draw((ropearc | lstr | rstr, ROPE, {'d': 1}))
for y in range(PCY + 2, 92, 4):
    cv.fill(rect(PCX - PR - 1, y, PCX - PR, y), ROPE['s'])
for y in range(PCY + 2, 74, 4):
    cv.fill(rect(PCX + PR, y, PCX + PR + 1, y), ROPE['s'])
draw((ell(PCX + PR - 4, 72, PCX + PR + 5, 80), ROPE, {'d': 1}))   # knotted end
hook = (ell(PCX - PR - 12, 90, PCX - PR + 6, 108) & ~ell(PCX - PR - 7, 94, PCX - PR + 1, 103) & ~rect(PCX - PR - 3, 90, W, 99)) | rect(PCX - PR - 3, 88, PCX - PR + 2, 94)
draw((hook, IRON, {'d': 1}))

# ---------------------------------------------------------------- LEFT BOTTOM: sawhorse with a plank and a saw
shadow(8, 178, 96, 186)
legs = blank()
for lx in (22, 76):
    legs |= line([(lx, 142), (lx - 9, 182)], 4) | line([(lx, 142), (lx + 9, 182)], 4)
draw((legs, WOOD, {'d': 1}), (rect(16, 140, 84, 146), WOOD, {'d': 2, 'contour': True}))
plank = rect(6, 131, 96, 138)
draw((plank, PLANK, {'d': 1}))
cv.fill(rect(7, 132, 95, 132), PLANK['r'])
cv.fill(rect(30, 135, 60, 135), PLANK['s'])
# handsaw biting into the plank's right end
blade = poly([(62, 131), (80, 131), (92, 104), (82, 100)])
draw((blade, STEEL, {'d': 1}))
for k in range(5):
    cv.dots([(64 + k * 3, 130)], STEEL['s'])
handle = rrect(80, 88, 98, 106, 3) & ~rrect(85, 93, 93, 100, 1)
draw((handle, RED if False else WOOD, {'d': 2}))

# ---------------------------------------------------------------- RIGHT TOP: rope coils hung on a wall post
draw((rect(248, 8, 258, 108), DWOOD, {'d': 2}))
for py in (20, 96):
    draw((rect(246, py, 260, py + 3), IRON, {'d': 1}))
cv.dots([(249, py + 1) for py in (20, 96)], IRON['r'])


def coil(cx, cy, rx, ry, turns=3):
    outer = ell(cx - rx, cy - ry, cx + rx, cy + ry)
    hole = ell(cx - rx + 14, cy - ry + 12, cx + rx - 14, cy + ry - 12)
    ring = outer & ~hole
    draw((ring, ROPE, {'d': 2}))
    for t in range(1, turns):
        e = ell(cx - rx + t * 4, cy - ry + t * 4, cx + rx - t * 4, cy + ry - t * 4)
        cv.fill(e & ~shift(e, 1, 1) & ring, ROPE['s'])
    for k in range(0, 360, 20):   # twist marks around the coil
        import math
        a = math.radians(k)
        x = int(cx + (rx - 6) * math.cos(a))
        y = int(cy + (ry - 6) * math.sin(a))
        cv.dots([(x, y), (x + 1, y - 1)], ROPE['s'])
    return ring


coil(253, 50, 30, 28)
draw((rect(250, 22, 256, 28), DWOOD, {'d': 1}))   # peg
coil(234, 88, 20, 18, 2)

# ---------------------------------------------------------------- RIGHT BOTTOM: stack of timber planks on bearers
shadow(206, 176, 298, 186)
draw((rect(214, 170, 224, 180) | rect(272, 170, 282, 180), DWOOD, {'d': 1}))   # bearers
rows = [(210, 292, 160, 169), (214, 296, 150, 159), (208, 288, 140, 149), (216, 294, 130, 139), (212, 284, 120, 129)]
for x0, x1, y0, y1 in rows:
    o = cv.obj()
    o.part(rect(x0 + 6, y0, x1, y1), PLANK, d=1)
    o.part(rect(x0, y0, x0 + 6, y1), ENDG, d=1, contour=True)
    o.draw()
    cv.fill(rect(x0 + 8, y0 + 1, x1 - 2, y0 + 1), PLANK['r'])
    cv.fill(rect(x0 + 20, y0 + 5, x0 + 46, y0 + 5), PLANK['s'])
    cv.dots([(x0 + 3, y0 + 4), (x0 + 3, y0 + 5), (x0 + 2, y0 + 3)], ENDG['s'])
draw((rect(262, 118, 267, 171), ROPE, {'d': 1}))   # rope lashing
cv.fill(rect(263, 120, 266, 120), ROPE['r'])

HOTSPOTS = [
    {'id': 'pulley', 'label': 'Crane pulley', 'x': 14, 'y': 10, 'w': 80, 'h': 100},
    {'id': 'sawhorse', 'label': 'Sawhorse', 'x': 4, 'y': 112, 'w': 94, 'h': 78},
    {'id': 'stones', 'label': 'Stone blocks', 'x': 100, 'y': 34, 'w': 102, 'h': 152},
    {'id': 'rope', 'label': 'Rope coils', 'x': 210, 'y': 10, 'w': 86, 'h': 102},
    {'id': 'timber', 'label': 'Timber stack', 'x': 204, 'y': 116, 'w': 94, 'h': 72},
]

if __name__ == '__main__':
    out = sys.argv[1] if len(sys.argv) > 1 else None
    n = save_scene(cv, NAME, HOTSPOTS, out)
    print(NAME + ':', n, 'colours')
