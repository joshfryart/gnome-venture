"""Remove the baked-in robin from the craftmap birdbath backdrop (decor-t.png).

The robin sits on the left rim of the birdbath, over the pink bush and the sky.
Its pixels are repainted with the bush/sky behind it and the birdbath rim is
continued under it (outline, cream lip, stone, water), using colours sampled
from the image itself. The birdbath stays the focal point, so no prop is added.
"""
import sys
from PIL import Image
import numpy as np

SRC = "/home/user/gnome-venture/game/assets/img/craftmap/decor-t.png"
OUT = "/home/user/gnome-venture/art-review/scenes/out/game__assets__img__craftmap__decor-t.png"
CMP = "/home/user/gnome-venture/art-review/scenes/out/game__assets__img__craftmap__decor-t-cmp.png"

im = Image.open(SRC)
mode = im.mode
a = np.array(im.convert("RGB")).copy()
orig = a.copy()

SKY = (159, 211, 234)
PINK = (217, 138, 168)
PINK_HI = (238, 170, 194)
RIM_OL = (116, 70, 42)
LIP = (247, 244, 236)
STONE = (226, 220, 207)
WATER = (31, 106, 158)

BIRD = {(154, 107, 63), (224, 80, 31), (116, 70, 42), (201, 169, 110), (42, 26, 16),
        (122, 74, 31), (184, 69, 47), (74, 44, 26), (240, 138, 36), (176, 122, 16),
        (245, 207, 106), (232, 163, 23), (255, 255, 255)}

X0, X1, Y0, Y1 = 138, 213, 55, 100

# rim rows: list of (start_x, colour) segments, starting at the outline
RIM = {
    88: [(202, RIM_OL)],
    89: [(202, RIM_OL)],
    90: [(192, RIM_OL), (202, LIP)],
    91: [(178, RIM_OL), (190, LIP), (204, STONE)],
    92: [(178, RIM_OL), (190, LIP), (204, STONE)],
    93: [(168, RIM_OL), (178, LIP), (189, STONE)],
    94: [(160, RIM_OL), (168, LIP), (178, STONE)],
    95: [(160, RIM_OL), (168, LIP), (178, STONE)],
    96: [(154, RIM_OL), (160, LIP), (168, STONE), (201, WATER)],
    97: [(150, RIM_OL), (154, LIP), (162, STONE), (184, WATER)],
    98: [(150, RIM_OL), (154, LIP), (162, STONE), (184, WATER)],
    99: [(147, RIM_OL), (150, LIP), (156, STONE), (174, WATER)],
}


def bush_edge(y):
    """x where the small bush bump starts (sky to the left) for rows 67-89."""
    if y <= 71:
        return 151
    if y <= 79:
        return 150
    if y <= 84:
        return 151
    if y <= 87:
        return 152
    return 153


def colour(x, y):
    if y in RIM and x >= RIM[y][0][0]:
        c = None
        for sx, col in RIM[y]:
            if x >= sx:
                c = col
        return c
    if y >= 90:
        return PINK
    if y >= 67:
        e = bush_edge(y)
        if x < e:
            return SKY
        if 72 <= y <= 79 and x < e + 2:
            return PINK_HI
        return PINK
    return PINK


for y in range(Y0, Y1):
    for x in range(X0, X1):
        if tuple(int(v) for v in orig[y, x]) in BIRD:
            a[y, x] = colour(x, y)

out = Image.fromarray(a, "RGB").convert(mode)
out.save(OUT)

w, h = im.size
cmp_img = Image.new("RGB", (w * 4 + 8, h * 2), (0, 0, 0))
cmp_img.paste(im.convert("RGB").resize((w * 2, h * 2), Image.NEAREST), (0, 0))
cmp_img.paste(out.convert("RGB").resize((w * 2, h * 2), Image.NEAREST), (w * 2 + 8, 0))
cmp_img.save(CMP)
print("ok", out.size, out.mode)
