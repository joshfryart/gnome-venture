"""Remove baked gnome + stirring stick from place-grind; replace with an open grain sack."""
from PIL import Image
import numpy as np

SRC = '/home/user/gnome-venture/game/assets/img/town/place-grind.png'
OUT = '/home/user/gnome-venture/art-review/scenes/out/game__assets__img__town__place-grind.png'
CMP = '/home/user/gnome-venture/art-review/scenes/out/game__assets__img__town__place-grind-cmp.png'

im = Image.open(SRC)
mode = im.mode
a = np.array(im.convert('RGBA'))
orig = a.copy()

def px(x, y):
    return tuple(int(v) for v in orig[y, x])

SKY = px(60, 40)        # pale sky
HEDGE = px(42, 60)      # hedge green
RIM = px(44, 82)        # light grass rim
GRASS = px(44, 84)      # grass
OUT1 = px(37, 60)       # warm brown outline (as boulder left edge)
DARK = px(38, 84)       # darkest brown (shadows/outline)
BODY = px(20, 60)       # boulder/sack tan
SHADE = px(20, 82)      # tan shade
HI = px(8, 4)           # light highlight (227,196,140)
GOLD = px(90, 66)       # grain gold
ROPE = px(0, 70)        # dark rope brown (frame shadow)
assert ROPE == (74, 44, 26, 255), ROPE
assert SKY == (207, 232, 230, 255), SKY

def top(x):
    if x < 64: return 56
    if x < 80: return 58
    return 62

def bg(x, y):
    if y >= 84: return GRASS
    if y >= 82: return RIM
    if y >= top(x): return HEDGE
    return SKY

# 1. gnome rectangle -> background
for y in range(46, 86):
    for x in range(48, 76):
        a[y, x] = bg(x, y)

# 2. stirring stick (dark/grey pixels) outside the bowl
stick = {(74, 44, 26, 255), (138, 132, 120, 255), (42, 26, 16, 255)}
for y in range(40, 74):
    for x in range(60, 94):
        if x >= 76 and y >= 70:
            continue
        if px(x, y) in stick:
            a[y, x] = bg(x, y)

# 2b. sky notch left behind the stick between hedge and grain pile
for y in range(62, 70):
    for x in range(76, 94):
        if tuple(int(v) for v in a[y, x]) == SKY:
            a[y, x] = HEDGE

# 3. open grain sack prop on 2px grid
C = {'o': OUT1, 'd': DARK, 'F': BODY, 'G': SHADE, 'h': HI, 'C': GOLD, 'r': ROPE}
sack = [
    "..oooooo..",
    ".oCCCCCCd.",
    ".oGFFFFGd.",
    "..oFFFGd..",
    "..orrrrd..",
    ".oFhFFFGd.",
    "oFhFFFFGGd",
    "oFhFFFFFGd",
    "oFFFFFFFGd",
    "oFFFFFFGGd",
    "oGFFFFFGGd",
    "oGGGGGGGGd",
]
X0, Y0 = 50, 60
for j, row in enumerate(sack):
    for i, ch in enumerate(row):
        if ch in C:
            a[Y0 + 2*j:Y0 + 2*j + 2, X0 + 2*i:X0 + 2*i + 2] = C[ch]
# ground shadow under sack
a[84:86, 50:70] = DARK

out = Image.fromarray(a, 'RGBA').convert(mode)
assert out.size == im.size
out.save(OUT)
w, h = im.size
cmp = Image.new('RGBA', (w * 4 + 8, h * 2), (0, 0, 0, 0))
cmp.paste(im.convert('RGBA').resize((w*2, h*2), Image.NEAREST), (0, 0))
cmp.paste(out.convert('RGBA').resize((w*2, h*2), Image.NEAREST), (w*2 + 8, 0))
cmp.save(CMP)
print('ok', out.size, out.mode)
