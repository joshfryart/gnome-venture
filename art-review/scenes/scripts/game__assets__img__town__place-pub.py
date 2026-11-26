"""Remove the two baked-in gnomes from the pub backdrop; add a log pile and a barrel."""
from PIL import Image
import numpy as np

SRC = '/home/user/gnome-venture/game/assets/img/town/place-pub.png'
OUT = '/home/user/gnome-venture/art-review/scenes/out/game__assets__img__town__place-pub.png'
CMP = '/home/user/gnome-venture/art-review/scenes/out/game__assets__img__town__place-pub-cmp.png'

im = Image.open(SRC)
mode, size = im.mode, im.size
a = np.array(im.convert('RGBA'))

def px(x, y):
    return a[y, x].copy()

# palette sampled from the picture
P = {
    '6': px(142, 0) if False else px(58, 44),   # dark outline (fireplace edge)
    '2': px(60, 88),     # floor plank
    '8': px(80, 30),     # wall plank
    '9': px(80, 36),     # wall seam line
    'c': px(30, 44),     # fireplace stone
    'b': px(56, 44),     # stone shade
    '1': px(76, 66),     # bar top board / bark
    '3': px(4, 4),       # light wood
    '4': px(8, 8) if False else px(6, 6),
    '5': px(88, 64),     # mid wood
    '7': px(20, 20),     # dark wood
}
# sanity: lookup explicit colours where above guesses might be off
def rgb(c): return np.array(list(c) + [255], dtype=np.uint8)
P['3'] = rgb((192, 138, 82)); P['4'] = rgb((227, 196, 140)); P['5'] = rgb((160, 106, 58))
P['7'] = rgb((90, 58, 30)); P['1'] = rgb((116, 70, 42)); P['6'] = rgb((42, 26, 16))
P['2'] = rgb((74, 44, 26)); P['8'] = rgb((122, 74, 31)); P['9'] = rgb((92, 52, 32))
P['c'] = rgb((138, 138, 146)); P['b'] = rgb((98, 98, 108))

def wall(y):
    return P['9'] if (y - 36) % 12 in (0, 1) else P['8']

def put(x, y, k):
    a[y, x] = P[k]

# ---- gnome 1 (between fireplace and bar): x54-73, y50-83
for y in range(50, 84):
    for x in range(54, 74):
        if x < 56:
            k = 'b' if y >= 82 else 'c'
            a[y, x] = P[k]
        elif x < 58:
            a[y, x] = P['b']
        elif x < 60:
            a[y, x] = P['6']
        else:
            a[y, x] = wall(y)
# floor top under gnome 1
for y in (84, 85):
    for x in range(54, 74):
        a[y, x] = P['6'] if x < 56 or x in (66, 67) else P['2']

# ---- gnome 2 (right of bar): x114-135, y50-83
for y in range(50, 84):
    for x in range(114, 136):
        a[y, x] = wall(y)
# restore bar right edge
for y in range(64, 84):
    for x in (114, 115):
        a[y, x] = P['1'] if y < 68 else P['6']
for y in (84, 85):
    for x in range(114, 136):
        a[y, x] = P['6'] if x in (120, 121) else P['2']

def stamp(rows, ax0, ay0):
    for j, row in enumerate(rows):
        for i, k in enumerate(row.split()):
            if k == '.':
                continue
            for dy in (0, 1):
                for dx in (0, 1):
                    put(ax0 * 2 + i * 2 + dx, ay0 * 2 + j * 2 + dy, k)

# log pile next to the hearth (art cols 30-36, rows 35-41)
logs = [
    '. . 6 6 6 . .',
    '. 6 4 3 3 6 .',
    '. 6 3 5 5 6 .',
    '6 6 6 6 6 6 6',
    '6 4 3 6 4 3 6',
    '6 3 5 6 3 5 6',
    '6 6 6 6 6 6 6',
]
stamp(logs, 30, 35)
for y in (84, 85):
    for x in range(60, 74):
        a[y, x] = P['6']

# barrel right of the bar (art cols 58-67, rows 31-41)
barrel = [
    '. . 6 6 6 6 6 6 . .',
    '. 6 1 7 7 7 7 1 6 .',
    '. 6 c c c c c b 6 .',
    '6 4 3 3 3 3 5 5 1 6',
    '6 4 3 3 3 3 5 5 1 6',
    '6 c c c c c c b b 6',
    '6 4 3 3 3 3 5 5 1 6',
    '6 4 3 3 3 3 5 5 1 6',
    '. 6 c c c c c b 6 .',
    '. 6 3 3 3 3 5 1 6 .',
    '. . 6 6 6 6 6 6 . .',
]
stamp(barrel, 58, 31)
for y in (84, 85):
    for x in range(118, 134):
        a[y, x] = P['6']

out = Image.fromarray(a, 'RGBA').convert(mode)
assert out.size == size
out.save(OUT)
orig = Image.open(SRC).convert('RGBA')
w, h = size
cmp = Image.new('RGBA', (w * 4 + 8, h * 2), (255, 255, 255, 255))
cmp.paste(orig.resize((w * 2, h * 2), Image.NEAREST), (0, 0))
cmp.paste(out.convert('RGBA').resize((w * 2, h * 2), Image.NEAREST), (w * 2 + 8, 0))
cmp.save(CMP)
al = np.array(out.convert('RGBA'))[..., 3]
print('alpha values', sorted(set(al.flatten().tolist())))
