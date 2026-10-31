"""Crafting scene (variant low): KITCHEN. python3 -B craft_low_kitchen.py
Warm red/orange/cream: brick hearth with fire, iron stove with a copper stew pot, hanging pan rack, worktable with board and bread, barrel of produce."""
from craft_low_base import *  # noqa: F401,F403

cv = new_canvas('#f2e4c0')
r = rnd(11)
BRICK = ramp('#b8412d', '#8a2c20', '#dc6a4a', '#c85a3a')
RED = ramp('#d6322b', '#a8241f', '#f08a64')
ORG = ramp('#e8841f', '#b85a14', '#f5b04a')
YEL = ramp('#f0b92b', '#c98a14', '#f8dc6a')
GRN = ramp('#7ab55c', '#4f9a45', '#a4d27a')
BREAD = ramp('#d99a4a', '#a8682a', '#f2c47a')

room(cv, '#f2dcb0', '#e2c490', '#a8682a', '#7a4a1f', plank=False)
# wall: cream plaster with a red-tile band behind the work area
for x in range(0, W, 10):
    for y in range(64, 100, 9):
        off = 5 if (y // 9) % 2 else 0
        cv.fill(rect(x + off, y, x + off + 8, y + 7), '#e8a070' if (x // 10 + y // 9) % 3 else '#dc8a5a')
cv.fill(rect(0, 63, W - 1, 63), '#c9a96e')
cv.fill(rect(0, 0, W - 1, 6), '#7a4a1f')
cv.fill(rect(0, 7, W - 1, 7), '#5c3420')
# window (calm, upper middle-right) with warm light
o = cv.obj()
o.part(rrect(250, 16, 292, 56, 2), DWOOD, d=1)
o.draw()
cv.fill(rect(254, 20, 288, 52), '#a9d3e8')
cv.fill(rect(254, 40, 288, 52), '#c3e2ee')
cv.fill(rect(270, 20, 271, 52) | rect(254, 35, 288, 36), '#7a4a1f')
cv.fill(ell(258, 44, 268, 54) & rect(254, 20, 288, 52), '#7ab55c')

for x0, x1, y in ((2, 88, 150), (92, 166, 150), (164, 250, 150), (250, 298, 162), (156, 180, 186)):
    shadow(cv, x0, x1, y, '#7a4a1f')
cv.fill(rrect(120, 170, 220, 196, 3), '#b8412d')   # rug under the gnome
cv.fill(rrect(124, 173, 216, 193, 2), '#dc6a4a')
for x in range(128, 214, 8):
    cv.fill(rect(x, 176, x + 3, 190), '#f2c47a')
# ---- hearth (left): brick arch with fire
hm = rect(8, 30, 80, 149)
o = cv.obj()
o.part(hm, BRICK, d=3)
o.part(rect(4, 24, 84, 32), DWOOD, d=2)   # mantel
o.draw()
for y in range(36, 148, 6):
    cv.fill(rect(10, y, 78, y) & ~rect(20, 70, 68, 149), '#8a2c20')
    for x in range(10 + (y // 6 % 2) * 6, 78, 12):
        cv.fill(rect(x, y - 5, x, y - 1) & ~rect(20, 70, 68, 149), '#8a2c20')
arch = rect(22, 84, 66, 149) | ell(22, 66, 66, 102)
cv.fill(dil4(arch), '#4a2c1a')
cv.fill(arch, '#2a1a10')
cv.fill(rect(28, 140, 60, 145), '#5c3420')   # logs
cv.fill(rect(30, 136, 58, 139), '#7a4a1f')
flame = poly([(30, 138), (36, 112), (40, 124), (44, 100), (49, 122), (53, 110), (58, 138)])
cv.fill(flame, '#e8841f')
cv.fill(poly([(36, 138), (40, 120), (44, 112), (48, 124), (52, 138)]), '#f0b92b')
cv.fill(poly([(40, 138), (44, 124), (48, 138)]), '#fff4d8')
# mantel jars
for x, c in ((14, ORG), (64, GRN)):
    o = cv.obj(); o.part(rrect(x, 12, x + 8, 23, 2), c, d=2); o.draw()

# ---- stove with copper pot (centre-left)
o = cv.obj()
o.part(rect(98, 100, 158, 149), IRON, d=3)
o.part(rect(94, 96, 162, 102), IRON, d=1)
o.part(rect(140, 18, 146, 95), IRON, d=1)   # flue pipe
o.draw()
cv.fill(rrect(108, 112, 148, 136, 2), '#2e2e38')
cv.fill(rrect(112, 116, 144, 132, 2), '#f08a24')
cv.fill(rect(112, 124, 144, 132) & rrect(112, 116, 144, 132, 2), '#d6322b')
cv.fill(rect(108, 140, 148, 141), '#7a7a8a')
o = cv.obj()
o.part(ell(104, 64, 138, 98) & rect(0, 72, W, 98), COPPER, d=3)
o.part(rect(102, 70, 140, 75), COPPER, d=1)
o.part(rect(98, 76, 104, 79) | rect(136, 76, 142, 79), COPPER, d=1)
o.draw()
cv.fill(ell(106, 68, 136, 75), '#a8241f')   # stew
cv.fill(ell(110, 69, 122, 72), '#e8841f')
cv.dots([(116, 70), (126, 71), (120, 72)], '#7ab55c')
o = cv.obj(); o.part(line([(124, 70), (136, 46)], 3), WOOD, d=1); o.draw()   # ladle
for sx in (112, 122):   # steam puffs
    for k in range(3):
        cv.fill(ell(sx + k * 2 - 3, 56 - k * 10, sx + k * 2 + 4, 62 - k * 10), '#fff4d8')

# ---- hanging pan rack (wall, centre-right)
o = cv.obj()
o.part(rect(170, 18, 238, 22), DWOOD, d=1)
o.draw()
for x in (174, 234):
    cv.fill(line([(x, 8), (x, 18)]), '#4a2c1a')
for x, k in ((176, 0), (196, 1), (216, 2)):
    cv.fill(rect(x + 6, 23, x + 7, 28), '#4a2c1a')
    o = cv.obj()
    if k == 1:
        o.part(rect(x + 5, 28, x + 8, 38), DWOOD, d=1)
        o.part(ell(x, 38, x + 13, 54), IRON, d=2)
    elif k == 0:
        o.part(rect(x + 5, 28, x + 8, 34), DWOOD, d=1)
        o.part(ell(x - 1, 34, x + 14, 50), COPPER, d=2)
    else:
        o.part(rect(x + 5, 28, x + 8, 44), WOOD, d=1)
        o.part(ell(x + 1, 44, x + 12, 56), WOOD, d=2)
    o.draw()

# ---- worktable with board and bread (right)
o = cv.obj()
o.part(rect(172, 112, 178, 149) | rect(236, 112, 242, 149), WOOD, d=2)
o.part(rect(168, 104, 246, 112), WOOD, d=2)
o.part(rect(176, 128, 238, 131), DWOOD, d=1)
o.draw()
o = cv.obj(); o.part(rrect(176, 98, 214, 103, 1), ramp('#d9a35a', '#b07a3a', '#f2c47a'), d=1); o.draw()
o = cv.obj(); o.part(ell(180, 82, 210, 100), BREAD, d=3); o.draw()
for x in (188, 195, 202):
    cv.fill(line([(x, 86), (x - 3, 93)]), '#a8682a')
o = cv.obj(); o.part(ell(220, 90, 238, 103), RED, d=2); o.draw()   # tomato
cv.fill(rect(228, 88, 230, 91), '#4f9a45')

# ---- barrel of produce (far right, floor)
o = cv.obj()
o.part(rrect(254, 108, 294, 162, 4), WOOD, d=3)
o.draw()
for y in (116, 152):
    cv.fill(rect(255, y, 293, y + 2) & rrect(254, 108, 294, 162, 4), '#4a4a56')
for x in (264, 274, 284):
    cv.fill(rect(x, 119, x, 151), '#7a4a1f')
for (cx, cy, c) in ((262, 103, RED), (274, 100, ORG), (286, 104, RED), (268, 96, YEL), (281, 95, GRN)):
    o = cv.obj(); o.part(ell(cx - 6, cy - 6, cx + 6, cy + 6), c, d=2); o.draw()

gnome(cv, 168, 186)

save(cv, 'kitchen', [
    ('hearth', 'Hearth', 4, 12, 82, 140),
    ('stove', 'Stove', 92, 40, 72, 112),
    ('rack', 'Pan rack', 168, 8, 74, 50),
    ('table', 'Worktable', 166, 80, 80, 72),
    ('barrel', 'Produce barrel', 250, 88, 48, 78),
])
