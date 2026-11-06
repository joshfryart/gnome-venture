"""Crafting scene (variant low): PANTRY. python3 -B craft_low_pantry.py
Plum/amber/glass larder: shelf of jam jars with gingham lids, hanging garlic string and cloth-wrapped cheese, crate of cordial bottles,
a pickle crock, a sauerkraut barrel."""
from craft_low_base import *  # noqa: F401,F403

cv = new_canvas('#6a3a5a')
PLUM = ramp('#8a3a6a', '#5c2048', '#b8609a')
AMB = ramp('#e8a020', '#b06a10', '#f8d060')
RASP = ramp('#c8304a', '#8a1c34', '#f07088')
GRN = ramp('#8ab040', '#5a8028', '#c0dc70')
CROCK = ramp('#c9a96e', '#9a7a48', '#f2e4c0', '#b08a58')
CHEESE = ramp('#f2e4c0', '#c9a96e', '#ffffff')
GARLIC = ramp('#f1ece0', '#c9b8c8', '#ffffff')

room(cv, '#6a3a5a', '#5a2c4c', '#7a4a1f', '#5c3420', fy=152)
for x0, x1, y in ((4, 108, 152), (6, 82, 184), (150, 226, 152), (232, 298, 172)):
    shadow(cv, x0, x1, y, '#5c3420')

# ---- jam shelf (left wall): two boards, jars with gingham lids
o = cv.obj()
o.part(rect(8, 14, 12, 110) | rect(100, 14, 104, 110), WOOD, d=1)
o.part(rect(4, 58, 108, 63), WOOD, d=2)
o.part(rect(4, 106, 108, 111), WOOD, d=2)
o.draw()
cv.fill(rect(13, 14, 99, 57) | rect(13, 64, 99, 105), '#4a2040')
for row, yb in ((0, 57), (1, 105)):
    for i, (x, rp) in enumerate(((16, RASP), (38, PLUM), (60, AMB), (80, RASP)) if row == 0 else ((16, AMB), (38, RASP), (60, PLUM), (80, AMB))):
        w, h = 17, 24
        o = cv.obj()
        o.part(rrect(x, yb - h, x + w, yb, 3), GLASS, d=1)
        o.part(rrect(x + 2, yb - h + 6, x + w - 2, yb - 1, 2), rp, d=2)
        o.part(rect(x + 1, yb - h - 6, x + w - 1, yb - h + 1), ramp('#ffffff', '#e0d0d8'), d=0)
        o.draw()
        lid = rect(x + 1, yb - h - 6, x + w - 1, yb - h + 1)
        ck = (rp['b'] if rp is not AMB else '#d6322b')
        for yy in range(yb - h - 6, yb - h + 2, 2):
            for xx in range(x + 1, x + w, 2):
                a, b = (xx - x) // 2 % 2, (yy - yb) // 2 % 2
                cv.fill(rect(xx, yy, xx + 1, yy + 1) & lid, ck if a and b else ('#ffffff' if not (a or b) else '#e8a0b0'))
        cv.fill(rect(x + 4, yb - h + 8, x + 5, yb - h + 14), '#ffffff')   # glass glint

# ---- hanging garlic string and cheese (from the ceiling beam)
cv.fill(rect(124, 8, 125, 22), '#c9a96e')
for k, y in enumerate(range(20, 60, 8)):
    cx = 125 + (3 if k % 2 else -3)
    o = cv.obj(); o.part(ell(cx - 6, y, cx + 6, y + 10) | poly([(cx - 1, y - 2), (cx + 1, y - 2), (cx, y + 1)]), GARLIC, d=2); o.draw()
    cv.fill(rect(cx, y + 3, cx, y + 8), '#c9b8c8')
cv.fill(rect(160, 8, 161, 30), '#c9a96e')
o = cv.obj()
o.part(ell(144, 30, 178, 66), CHEESE, d=3)
o.part(poly([(154, 28), (168, 28), (161, 36)]), CHEESE, d=1)
o.draw()
cv.fill(line([(150, 37), (172, 60)]) | line([(172, 37), (150, 60)]), '#b8609a')   # string tie

# ---- crate of cordial bottles
o = cv.obj()
o.part(rect(154, 116, 222, 151), WOOD, d=3)
o.draw()
for y in (128, 140):
    cv.fill(rect(156, y, 220, y), '#7a4a1f')
for i, (x, rp, h) in enumerate(((160, RASP, 38), (178, AMB, 44), (196, GRN, 36), (210, PLUM, 30))):
    o = cv.obj()
    o.part(rrect(x, 116 - h + 12, x + 12, 116, 3), rp, d=2)
    o.part(rect(x + 4, 116 - h, x + 8, 116 - h + 12), rp, d=1)
    o.part(rect(x + 3, 116 - h - 4, x + 9, 116 - h), ramp('#b07a3a', '#7a4a1f', '#d9a35a'), d=1)
    o.draw()
    cv.fill(rect(x + 2, 116 - h + 16, x + 3, 116 - h + 26), '#ffffff')
    cv.fill(rect(x + 2, 116 - 16, x + 10, 116 - 8), '#f2e4c0')   # label

# ---- pickle crock (floor, left)
o = cv.obj()
o.part(rrect(14, 134, 74, 184, 8), CROCK, d=3)
o.part(rect(18, 128, 70, 135), CROCK, d=1)
o.part(rect(38, 119, 50, 125), DWOOD, d=1)   # lid knob
o.part(rect(20, 124, 68, 129), DWOOD, d=1)
o.draw()
cv.fill(rect(15, 150, 73, 154) & rrect(14, 134, 74, 184, 8), '#5a8028')
cv.fill(rect(15, 151, 73, 152) & rrect(14, 134, 74, 184, 8), '#8ab040')

for px, py in ((30, 164), (44, 168), (58, 163)):   # pickle motif on the crock
    o = cv.obj(); o.part(ell(px - 4, py - 7, px + 4, py + 7), GRN, d=2); o.draw()

# ---- sauerkraut barrel (floor, right)
bm = rrect(236, 96, 292, 172, 5)
o = cv.obj(); o.part(bm, WOOD, d=3); o.draw()
for y in (106, 160):
    cv.fill(rect(236, y, 292, y + 2) & bm, '#4a4a56')
for x in (248, 260, 272, 284):
    cv.fill(rect(x, 109, x, 159) & bm, '#7a4a1f')
o = cv.obj()
o.part(ell(232, 86, 296, 100), DWOOD, d=1)   # lid with a stone weight
o.part(ell(254, 76, 274, 90), ramp('#b9b2a2', '#8a8474', '#d8d2c2'), d=2)
o.draw()
cv.fill(rect(244, 99, 284, 100), '#e8d870')   # kraut peeking out

gnome(cv, 120, 186, hat='#8a3a6a', coat='#e8a020')

save(cv, 'pantry', [
    ('jams', 'Jam shelf', 2, 6, 110, 108),
    ('hanging', 'Garlic and cheese', 114, 8, 68, 62),
    ('cordials', 'Cordial bottles', 150, 70, 76, 84),
    ('crock', 'Pickle crock', 8, 116, 72, 72),
    ('barrel', 'Sauerkraut barrel', 228, 72, 70, 104),
])
