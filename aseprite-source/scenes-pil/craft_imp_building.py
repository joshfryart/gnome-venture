"""Crafting area scene: BUILDING / builders' yard (variant imp). Usage: python3 -B aseprite-source/scenes-pil/craft_imp_building.py [outdir]
Writes aseprite-source/craftmap/scenes/imp/building.png (1800 x 1200), building-thumb.png (450 x 300), building.json (hotspots) and building_hs.png.
Brief: claude/craftmap-scene-brief.md (Round 2). Clean and clear, five big tap targets under a timber lean-to on a warm terracotta plaster yard wall:
hero = a pyramid of dressed grey stone blocks topped by a red marker pennant (centre, backlit by a golden-hour sky through an open gateway arch);
left = a crane pulley hanging from the roof beam over a sawhorse with a plank and saw; right = a rope coil on a peg over a timber stack.
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
WALL, WALL_S, WALL_L = '#b47e66', '#9c6a55', '#c4927a'   # warm terracotta lime-plaster: deeper, sets off grey stone and tan rope
SKY, SKY_L, SKY_H = '#f2c88c', '#f6dcae', '#fbecc8'      # golden-hour sky through the gateway = warm backlight for the hero
HILL, HILL_S = '#a9a76e', '#8f8d5c'
FLOOR, FLOOR_S, FLOOR_L = '#80674f', '#69533f', '#967c62'
SHADOW = '#4f3f33'
STONE = ramp('#9aa3b4', '#717a8e', '#c9cfda', '#8891a4')
STONE_T = ramp('#e6e4e2', '#b8bcc6', '#fbf4e6')   # lit top faces
WOOD = ramp('#b07a45', '#8a4f2a', '#d9a660', '#9a6438')
DWOOD = ramp('#7a4a1f', '#5c3420', '#9a6b3f')
PLANK = ramp('#d0a064', '#a8743e', '#ecc58a', '#b8854a')
PLANK2 = ramp('#c08a50', '#9a6436', '#dcae72', '#a8743e')
ENDG = ramp('#ecc58a', '#c99a5c', '#f6dcaa')   # end grain
ROPE = ramp('#dcb478', '#a8804a', '#f2dcaa', '#bf9660')
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


def twist(m, col, step=4):
    """Diagonal lay marks across a rope band (down-right strokes)."""
    yy, xx = np.mgrid[0:H, 0:W]
    cv.fill(m & ((xx + yy) % step == 0) & shift(m, 1, 1) & shift(m, -1, -1), col)


# ---------------------------------------------------------------- yard: lean-to roof beam, sandy wall in big courses, packed-earth flags
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

# ---------------------------------------------------------------- gateway arch behind the hero: open sky and a far hill (frames the stack)
AX0, AX1 = 94, 206
arch = rect(AX0, 50, AX1, FY - 1) | ell(AX0, 20, AX1, 80)
band = dil4(dil4(dil4(arch))) & ~arch & ~rect(0, FY, W, H)
cv.fill(band, WALL_L)
cv.fill(dil4(band) & ~band & ~arch & ~rect(0, FY, W, H), WALL_S)
cv.fill(arch, SKY_L)
cv.fill(arch & rect(0, 104, W, H), SKY)
cv.fill(arch & ell(104, 24, 196, 128), SKY_H)   # sunlit halo behind the stack (two hard steps)
cv.fill(arch & ell(118, 40, 182, 116), '#fff6de')
hill = arch & (ell(60, 116, 172, 176) | ell(136, 124, 250, 180))
cv.fill(hill, HILL)
cv.fill(hill & ~shift(hill, 0, 2), HILL_S)

sun = poly([(AX0, FY), (AX1, FY), (AX1 + 24, H - 1), (AX0 - 24, H - 1)])   # daylight falling in through the gateway
cv.fill(sun, FLOOR_L)
for k, y in enumerate((FY + 14, FY + 31)):
    cv.fill(sun & rect(0, y, W, y), FLOOR)
for k, (y0, y1) in enumerate(((FY, FY + 13), (FY + 15, FY + 30), (FY + 32, H - 1))):
    for jx in range(26 + k * 23, W, 62):
        cv.fill(sun & rect(jx, y0, jx, y1), FLOOR)

# ---------------------------------------------------------------- HERO: stacked dressed stone blocks with a red marker pennant
BW, BH, TD = 36, 26, 6   # block width, front height, top depth


def block(x0, yb, pits=(), chip=False):
    """One dressed block (front bottom at yb): lit top strip, eased front edges, a few tooling pits (dark pit, lit lip)."""
    x1 = x0 + BW - 1
    ytop = yb - BH - TD
    fy0 = ytop + TD
    top = poly([(x0 + 2, ytop), (x1 - 2, ytop), (x1, fy0), (x0, fy0)])
    front = rrect(x0, fy0, x1, yb, 1)
    if chip:   # a knocked corner at the upper right
        front &= ~poly([(x1 - 5, fy0), (x1 + 1, fy0), (x1 + 1, fy0 + 6)])
        top &= ~poly([(x1 - 7, ytop - 1), (x1 + 1, ytop - 1), (x1 + 1, fy0 + 1)])
    draw((top, STONE_T, {'d': 1}), (front, STONE, {'d': 3, 'contour': True}))
    for dx, dy in pits:
        px, py = x0 + dx, fy0 + dy
        cv.fill(rect(px, py, px + 2, py), STONE['s'])
        cv.dots([(px - 1, py - 1), (px, py - 1)], STONE['r'])


SB = 178
shadow(90, 172, 212, 185)
for i, pits in enumerate((((8, 6), (22, 14)), ((12, 10), (26, 5)), ((6, 13), (20, 7)))):
    block(96 + i * BW, SB, pits, chip=(i == 2))
for i, pits in enumerate((((10, 8), (24, 15)), ((7, 14), (20, 6)))):
    block(114 + i * BW, SB - BH - 3, pits)
block(132, SB - 2 * (BH + 3), ((8, 12), (25, 7)))
# red marker pennant planted on the top block
PTOP = 44
draw((rect(149, PTOP, 151, SB - 2 * (BH + 3) - BH - 2), WOOD, {'d': 1}), (ell(147, PTOP - 3, 153, PTOP + 2), GOLD, {'d': 1}))
flag = poly([(152, PTOP + 2), (184, PTOP + 11), (152, PTOP + 22)])
draw((flag, RED, {'d': 2}))
cv.fill(rect(153, PTOP + 5, 160, PTOP + 6), RED['r'])
for sx, sy, s in ((122, 70, 2), (184, 78, 2), (128, 46, 1), (190, 40, 2), (111, 96, 1)):
    sparkle(sx, sy, s, GOLD['b'])

# ---------------------------------------------------------------- LEFT TOP: crane pulley hanging from the roof beam
import math
PCX, PCY, PR = 54, 38, 21
draw((rect(PCX - 3, 6, PCX + 3, 13), IRON, {'d': 1}))   # hanger strap
fork = (rect(PCX - 25, 12, PCX + 25, 16) | rect(PCX - 25, 12, PCX - 22, PCY + 3) | rect(PCX + 22, 12, PCX + 25, PCY + 3))
wheel = ell(PCX - PR, PCY - PR, PCX + PR, PCY + PR)
draw((wheel, WOOD, {'d': 3}), (fork, IRON, {'d': 1, 'contour': True}))
cv.fill(wheel & ~ell(PCX - PR + 4, PCY - PR + 4, PCX + PR - 4, PCY + PR - 4), DWOOD['b'])   # groove rim
for a in range(4):
    ang = math.pi / 4 + a * math.pi / 2
    cv.fill(line([(PCX, PCY), (int(PCX + (PR - 5) * math.cos(ang)), int(PCY + (PR - 5) * math.sin(ang)))], 3), DWOOD['s'])
draw((ell(PCX - 5, PCY - 5, PCX + 5, PCY + 5), IRON, {'d': 1}))
cv.dots([(PCX - 2, PCY - 2)], IRON['r'])
# rope over the wheel and down both sides
ropearc = (ell(PCX - PR - 2, PCY - PR - 2, PCX + PR + 2, PCY + PR + 2) & ~ell(PCX - PR + 1, PCY - PR + 1, PCX + PR - 1, PCY + PR - 1)) & rect(0, 0, W, PCY)
lstr = rect(PCX - PR - 2, PCY, PCX - PR + 1, 70)
rstr = rect(PCX + PR - 1, PCY, PCX + PR + 2, 62)
rope_m = ropearc | lstr | rstr
draw((rope_m, ROPE, {'d': 1}))
twist(lstr | rstr, ROPE['bo'])
draw((ell(PCX + PR - 4, 60, PCX + PR + 5, 69), ROPE, {'d': 1}))   # knotted end
cv.dots([(PCX + PR - 1, 63), (PCX + PR, 63)], ROPE['r'])
hk = PCX - PR
hook = (ell(hk - 13, 70, hk + 7, 90) & ~ell(hk - 7, 75, hk + 1, 84) & ~rect(hk - 2, 70, W, 80)) | rect(hk - 3, 66, hk + 2, 74)
draw((hook, IRON, {'d': 1}))
cv.fill(rect(hk - 3, 66, hk + 2, 67), IRON['r'])

# ---------------------------------------------------------------- LEFT BOTTOM: sawhorse with a plank and a handsaw in the cut
shadow(6, 179, 92, 187)
legs = blank()
for lx in (22, 70):
    legs |= line([(lx, 150), (lx - 8, 183)], 4) | line([(lx, 150), (lx + 8, 183)], 4)
draw((legs, WOOD, {'d': 1}), (rect(14, 146, 78, 152), WOOD, {'d': 2, 'contour': True}))
# handsaw: toe down in the kerf, handle up to the right. Built in blade coordinates u (toe -> heel) and v (towards the teeth)
TX, TY = 46, 146
yy, xx = np.mgrid[0:H, 0:W]
uu = ((xx - TX) - (yy - TY)) / 1.4142
vv = ((xx - TX) + (yy - TY)) / 1.4142
BL = 40
blade = (yy < 138) & (uu >= 0) & (uu <= BL) & (vv <= 0.5) & (vv >= -(6 + 8 * uu / BL))
teeth = (yy < 138) & (uu >= 0) & (uu <= BL) & (vv > 0.5) & (vv <= 2.2) & (np.floor(uu) % 3 < 1.5)
grip = (uu > BL - 1) & (uu <= BL + 17) & (vv <= 3) & (vv >= -17)
grip &= ~((uu > BL + 5) & (uu < BL + 12) & (vv > -12) & (vv < -3))   # hand slot
grip &= ~((uu > BL + 14) & (vv > 0)) & ~((uu > BL + 15) & (vv < -14))   # round off the heel corners
draw((blade | teeth, STEEL, {'d': 1}), (grip, WOOD, {'d': 2, 'contour': True}))
cv.fill(blade & (vv > -3) & (vv <= -2) & (uu > 3), STEEL['r'])
cv.dots([(int(TX + (BL + 8) / 1.4142 - 4), int(TY - (BL + 8) / 1.4142 - 4))], GOLD['b'])   # brass rivet
cv.fill(teeth, STEEL['s'])
plank = rect(4, 138, 88, 145)
draw((plank, PLANK, {'d': 1}))
cv.fill(rect(5, 139, 87, 139), PLANK['r'])
cv.fill(rect(16, 142, 40, 142), PLANK['s'])
cv.fill(rect(TX, 138, TX, 141), UMB)   # the kerf

# ---------------------------------------------------------------- RIGHT TOP: one fat rope coil hung from a short peg (wall shows through the eye)
RCX = 255
draw((rect(RCX - 4, 8, RCX + 4, 26), DWOOD, {'d': 1}))   # peg bracket from the beam
coil = ell(RCX - 33, 24, RCX + 33, 102) & ~ell(RCX - 18, 40, RCX + 18, 86)
tail = line([(RCX + 18, 92), (RCX + 22, 100), (RCX + 21, 106)], 5)
o = cv.obj()
o.part(coil, ROPE, d=3, contour=True)
o.part(tail, ROPE, d=1, contour=True)
o.part(rrect(RCX - 10, 20, RCX + 10, 34, 3), ROPE, d=1, contour=True)   # binding turns at the neck
o.draw()
for k in (5, 10):   # two groove rings = three strands laid side by side
    g = ell(RCX - 33 + k, 24 + k, RCX + 33 - k, 102 - k)
    edge = coil & g & ~(shift(g, 1, 0) & shift(g, 0, 1)) & ~rect(RCX - 11, 19, RCX + 11, 35)
    cv.fill(edge, ROPE['bo'])
    cv.fill(shift(edge, -1, -1) & coil & ~edge & ~rect(RCX - 11, 19, RCX + 11, 35), ROPE['r'])   # lit lip above each groove
for y in (24, 28, 32):
    cv.fill(rect(RCX - 8, y, RCX + 8, y) & rrect(RCX - 10, 20, RCX + 10, 34, 3), ROPE['s'])
cv.dots([(RCX - 4, 13), (RCX - 4, 14)], DWOOD['r'])

# ---------------------------------------------------------------- RIGHT BOTTOM: stack of timber planks on bearers, lashed with rope
shadow(206, 176, 298, 186)
draw((rect(216, 170, 226, 180) | rect(274, 170, 284, 180), DWOOD, {'d': 1}))   # bearers
rows = [(212, 294, 159, 169), (216, 297, 148, 158), (209, 290, 137, 147), (217, 295, 126, 136), (213, 286, 115, 125)]
for i, (x0, x1, y0, y1) in enumerate(rows):
    rp = PLANK if i % 2 == 0 else PLANK2
    o = cv.obj()
    o.part(rect(x0 + 8, y0, x1, y1), rp, d=1)
    o.part(rect(x0, y0, x0 + 8, y1), ENDG, d=1, contour=True)
    o.draw()
    cv.fill(rect(x0 + 10, y0 + 1, x1 - 2, y0 + 1), rp['r'])
    cv.fill(rect(x0 + 22 + i * 5, y0 + 5, x0 + 48 + i * 5, y0 + 5), rp['s'])
    ring = ell(x0 + 1, y0 + 1, x0 + 7, y1 - 1)
    cv.fill(ring & ~(shift(ring, 1, 0) & shift(ring, -1, 0) & shift(ring, 0, 1) & shift(ring, 0, -1)) & rect(x0 + 1, y0 + 2, x0 + 7, y1 - 2), ENDG['s'])   # growth ring
    cv.dots([(x0 + 4, (y0 + y1) // 2)], ENDG['s'])   # pith
lash = rect(262, 113, 266, 171)
draw((lash, ROPE, {'d': 1}))
twist(lash, ROPE['bo'])

HOTSPOTS = [
    {'id': 'pulley', 'label': 'Crane pulley', 'x': 14, 'y': 6, 'w': 78, 'h': 86},
    {'id': 'sawhorse', 'label': 'Sawhorse', 'x': 2, 'y': 92, 'w': 92, 'h': 98},
    {'id': 'stones', 'label': 'Stone blocks', 'x': 94, 'y': 36, 'w': 112, 'h': 152},
    {'id': 'rope', 'label': 'Rope coil', 'x': 214, 'y': 8, 'w': 82, 'h': 101},
    {'id': 'timber', 'label': 'Timber stack', 'x': 206, 'y': 110, 'w': 92, 'h': 80},
]

if __name__ == '__main__':
    out = sys.argv[1] if len(sys.argv) > 1 else None
    n = save_scene(cv, NAME, HOTSPOTS, out)
    print(NAME + ':', n, 'colours')
