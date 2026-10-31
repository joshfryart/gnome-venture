"""Crafting scene (variant low): ALCHEMY station. python3 -B craft_low_alchemy.py
Teal/violet/gold: shelf of coloured potion flasks, bench with mortar and pestle, bubbling cauldron over embers,
copper alembic still with a glass coil, lectern with an open spell book."""
from craft_low_base import *  # noqa: F401,F403

cv = new_canvas('#1f5a5e')
TEAL = ramp('#2f8a8a', '#1f5a5e', '#6fc8c0')
VIO = ramp('#8a5ac8', '#5c3a8a', '#c4a0f0')
GOLD = ramp('#d9a22a', '#a8741a', '#f2d46a')
RED = ramp('#d6322b', '#a8241f', '#f08a64')
LIME = ramp('#8ad040', '#5a9028', '#c8f080')
STONE = ramp('#5a6a78', '#3e4a58', '#8a9aa8')
PAGE = ramp('#f2e4c0', '#c9a96e', '#fff4d8')

room(cv, '#245e66', '#1c4c54', '#4a3468', '#36244e', fy=150, plank=False)
for y in range(8, 146, 10):   # calm stone-block wall
    off = 12 if (y // 10) % 2 else 0
    cv.fill(rect(0, y, W - 1, y), '#1c4c54')
    for x in range(off, W, 24):
        cv.fill(rect(x, y, x, y + 9), '#1c4c54')
cv.fill(rect(0, 0, W - 1, 6), '#3e2a5a')
cv.fill(rect(0, 7, W - 1, 7), '#2a1a3a')
# round night window with a gold moon (top centre, calm)
o = cv.obj(); o.part(ell(118, 14, 172, 62), STONE, d=2); o.draw()
cv.fill(ell(124, 20, 166, 56), '#2a1a5a')
cv.fill(ell(148, 26, 160, 38) & ~ell(144, 24, 156, 36), '#f2d46a')
cv.dots([(132, 30), (138, 44), (156, 48), (130, 40)], '#f2d46a')
cv.fill(rect(144, 20, 145, 56) | rect(124, 37, 166, 38), '#3e4a58')
for x0, x1, y in ((4, 94, 152), (106, 186, 182), (188, 260, 152), (260, 298, 172)):
    shadow(cv, x0, x1, y, '#36244e')

# ---- potion shelf (left wall)
o = cv.obj()
o.part(rect(4, 60, 96, 65), DWOOD, d=2)
o.part(poly([(10, 66), (18, 66), (10, 74)]) | poly([(82, 66), (90, 66), (90, 74)]), DWOOD, d=1)
o.draw()
for x, rp, kind in ((8, RED, 0), (30, VIO, 1), (54, LIME, 2), (76, GOLD, 0)):
    o = cv.obj()
    if kind == 0:     # round flask
        o.part(ell(x, 38, x + 16, 59), GLASS, d=1)
        o.part(ell(x + 2, 44, x + 14, 58), rp, d=2)
        o.part(rect(x + 5, 26, x + 11, 39), GLASS, d=1)
        o.part(rect(x + 4, 22, x + 12, 27), DWOOD, d=1)
    elif kind == 1:   # tall bottle
        o.part(rrect(x, 30, x + 16, 59, 3), GLASS, d=1)
        o.part(rrect(x + 2, 36, x + 14, 58, 2), rp, d=2)
        o.part(rect(x + 5, 20, x + 11, 30), GLASS, d=1)
        o.part(rect(x + 4, 16, x + 12, 21), DWOOD, d=1)
    else:             # conical flask
        o.part(poly([(x + 5, 30), (x + 11, 30), (x + 17, 59), (x - 1, 59)]), GLASS, d=1)
        o.part(poly([(x + 3, 44), (x + 13, 44), (x + 16, 58), (x, 58)]), rp, d=2)
        o.part(rect(x + 4, 25, x + 12, 30), DWOOD, d=1)
    o.draw()
    cv.fill(rect(x + 3, 46, x + 4, 52), '#ffffff')

# ---- bench with mortar and pestle (left floor)
o = cv.obj()
o.part(rect(12, 120, 18, 150) | rect(80, 120, 86, 150), WOOD, d=2)
o.part(rect(6, 112, 92, 120), WOOD, d=2)
o.draw()
o = cv.obj()
o.part(line([(52, 92), (70, 66)], 6), ramp('#d8d2c2', '#b9b2a2', '#ffffff'), d=1)   # pestle
o.part(ell(20, 80, 74, 106) & rect(0, 86, W, 106) | rect(28, 106, 66, 108) | rect(24, 108, 70, 111), STONE, d=3)
o.draw()
cv.fill(ell(24, 83, 70, 91), '#2e3846')
cv.fill(ell(30, 85, 50, 90), LIME['b'])
for (lx, ly) in ((80, 104), (86, 108)):   # a couple of herb leaves
    cv.fill(ell(lx - 3, ly - 2, lx + 3, ly + 2), LIME['s'])

# ---- cauldron (centre floor) bubbling over embers
o = cv.obj()
o.part(ell(104, 104, 188, 176), IRON, d=4)
o.part(rect(110, 168, 118, 182) | rect(174, 168, 182, 182), IRON, d=1)
o.part(rrect(102, 100, 190, 109, 2), IRON, d=2)
o.draw()
cv.fill(ell(108, 99, 184, 106), TEAL['s'])
cv.fill(ell(112, 100, 180, 105), '#4ac8a8')
for (bx, by, s) in ((124, 92, 7), (146, 84, 9), (166, 94, 6), (138, 70, 5), (158, 64, 4)):
    o = cv.obj(outline=False); o.part(ell(bx - s, by - s, bx + s, by + s), ramp('#6fe0c0', '#3aa890', '#c8fff0'), d=2); o.draw()
    cv.dots([(bx - s // 2, by - s // 2)], '#ffffff')
cv.fill(rect(108, 128, 184, 131) & ell(104, 104, 188, 176), GOLD['b'])   # gold band
cv.fill(rect(108, 128, 184, 128) & ell(104, 104, 188, 176), GOLD['r'])
for ex, ec in ((126, '#f08a24'), (146, '#f0b92b'), (166, '#f08a24')):
    cv.fill(poly([(ex - 7, 186), (ex, 172), (ex + 7, 186)]), ec)
cv.fill(rect(116, 185, 176, 189), '#5c3420')

# ---- alembic still (right): copper pot on a burner, swan neck and glass coil into a receiving flask
o = cv.obj()
o.part(rect(194, 128, 230, 149), STONE, d=2)     # brick burner
o.part(ell(192, 86, 232, 130), COPPER, d=3)
o.part(rect(206, 68, 218, 88), COPPER, d=2)
o.part(ell(202, 54, 222, 72), COPPER, d=2)
o.draw()
cv.fill(rrect(202, 136, 222, 146, 1), '#2a1a10')
cv.fill(rect(204, 140, 220, 146), '#f08a24')
o = cv.obj(); o.part(line([(220, 60), (236, 66), (244, 86)], 3), COPPER, d=1); o.draw()
o = cv.obj()
o.part(ell(234, 116, 256, 148), GLASS, d=1)
o.part(rect(240, 86, 248, 117), GLASS, d=1)
o.part(ell(236, 126, 254, 147), VIO, d=2)
o.draw()
cv.fill(rect(238, 120, 239, 128), '#ffffff')
for y in range(92, 112, 5):
    cv.fill(rect(239, y, 249, y + 1), '#9cc4cc')   # coil turns

# ---- lectern with spell book (far right)
o = cv.obj()
o.part(rect(274, 100, 282, 168), DWOOD, d=2)
o.part(rect(264, 164, 292, 171), DWOOD, d=1)
o.part(poly([(260, 88), (296, 76), (296, 98), (266, 110)]), DWOOD, d=2)
o.draw()
o = cv.obj()
o.part(poly([(262, 82), (278, 76), (280, 98), (266, 104)]), PAGE, d=1)
o.part(poly([(278, 76), (296, 68), (296, 90), (280, 98)]), PAGE, d=1)
o.draw()
for k in range(3):
    cv.fill(line([(266, 87 + k * 4), (276, 83 + k * 4)]), '#9a7a48')
cv.fill(ell(283, 76, 292, 86), VIO['b'])   # sigil
cv.fill(ell(285, 78, 290, 84), GOLD['r'])
cv.fill(line([(279, 98), (281, 114)], 2), RED['b'])   # ribbon

save(cv, 'alchemy', [
    ('potions', 'Potion shelf', 4, 12, 94, 60),
    ('mortar', 'Mortar and pestle', 4, 72, 92, 82),
    ('cauldron', 'Cauldron', 98, 60, 92, 132),
    ('still', 'Alembic still', 190, 50, 68, 102),
    ('book', 'Spell book', 258, 62, 42, 114),
])
