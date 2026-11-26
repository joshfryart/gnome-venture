"""Remove baked gnome from town/place-teahouse.png; replace with a potted plant."""
from PIL import Image
import numpy as np

SRC = "/home/user/gnome-venture/game/assets/img/town/place-teahouse.png"
OUT = "/home/user/gnome-venture/art-review/scenes/out/town__place-teahouse.png"
CMP = "/home/user/gnome-venture/art-review/scenes/out/town__place-teahouse-cmp.png"

im = Image.open(SRC).convert("RGBA")
a = np.array(im)
orig = a.copy()

# 1. Wall: rows 48..81, copy clean wall column x=34 across gnome area x 36..61
for y in range(48, 82):
    a[y, 36:62] = orig[y, 34]
# 2. Skirting rows 82..83: plain skirting colour (sampled at x=70)
for y in range(82, 84):
    a[y, 36:62] = orig[y, 70]
# 3. Floor rows 84..85: copy floor row 86 (boards with seams every 18 px)
for y in range(84, 86):
    a[y, 36:62] = orig[86, 36:62]

# 4. Prop: potted plant, drawn in 2x2 cells
C = orig[84, 42]            # dark outline (42,26,16)
g = np.array([78, 138, 60, 255], np.uint8)   # leaf green from shelf jar
H = orig[52, 46]            # terracotta (192,68,46)
F = orig[50, 50]            # dark terracotta (142,46,30)
L = orig[68, 52]            # light terracotta (224,138,122)
hl = np.array([132, 176, 88, 255], np.uint8)  # leaf highlight (lit from upper left)
pal = {"o": C, "g": g, "h": hl, "t": H, "T": F, "l": L}
art = [
    "....oo....",
    "...ohgo.o.",
    ".o.ohgoogo",
    "ohoohggogo",
    "ohhgoggggo",
    "ohggggggo.",
    ".ogggggggo",
    "..ooggoo..",
    ".oooooooo.",
    ".ollttttTo",
    "..olttTTo.",
    "..otttTTo.",
    "...oooooo.",
]
x0, y0 = 38, 58
for r, row in enumerate(art):
    for c, ch in enumerate(row):
        if ch in pal:
            y, x = y0 + 2 * r, x0 + 2 * c
            a[y:y + 2, x:x + 2] = pal[ch]
# soft contact shadow on floor like the original had
a[84:86, 40:58] = C

out = Image.fromarray(a, "RGBA")
out.save(OUT)
w, h = im.size
cmp = Image.new("RGBA", (w * 4 + 8, h * 2), (0, 0, 0, 0))
cmp.paste(im.resize((w * 2, h * 2), Image.NEAREST), (0, 0))
cmp.paste(out.resize((w * 2, h * 2), Image.NEAREST), (w * 2 + 8, 0))
cmp.save(CMP)
