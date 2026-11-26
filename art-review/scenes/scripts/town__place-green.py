# Remove baked gnome (+ dark bag on seat) and duck from place-green; rebuild empty bench and pond edge.
from PIL import Image
import numpy as np
SRC = '/home/user/gnome-venture/game/assets/img/town/place-green.png'
OUT = '/home/user/gnome-venture/art-review/scenes/out/town__place-green.png'
CMP = '/home/user/gnome-venture/art-review/scenes/out/town__place-green-cmp.png'
im = Image.open(SRC)
mode = im.mode
a = np.array(im.convert('RGBA'))
O = 28  # column offset used when mapping
def px(c, r): return tuple(a[r, O + c])
# sample colours from the picture
SKY = px(40, 40); GRASS = px(5, 64); OUT_C = px(0, 64)
PLANK = px(14, 58); EDGE = px(10, 58); DARK = px(18, 64); WATER = px(100, 80)
def fill(c0, c1, r0, r1, col):  # inclusive grid cols/rows
    a[r0:r1 + 1, O + c0:O + c1 + 1] = col
# --- gnome: sky above the backrest
fill(18, 39, 36, 55, SKY)
# backrest plank rows 56-63 across gnome span
fill(20, 41, 56, 57, DARK)
fill(20, 41, 58, 59, PLANK)
fill(20, 41, 60, 61, EDGE)
fill(20, 41, 62, 63, OUT_C)
fill(38, 39, 56, 57, DARK)            # old gnome outline on top edge
# gap between backrest and seat: grass behind, two posts
fill(20, 55, 64, 69, GRASS)
fill(18, 19, 62, 69, DARK)
fill(46, 47, 62, 69, DARK)
# seat rows 70-73 continuous plank
fill(12, 51, 70, 73, PLANK)
# --- duck: grass above, pond below
fill(76, 99, 64, 75, GRASS)
fill(76, 87, 76, 77, GRASS)
fill(88, 97, 76, 77, WATER)
fill(76, 97, 78, 83, WATER)
out = Image.fromarray(a, 'RGBA')
if mode != 'RGBA': out = out.convert(mode)
out.save(OUT)
orig = Image.open(SRC).convert('RGBA')
w, h = orig.size
cmp = Image.new('RGBA', (w * 4 + 8, h * 2), (0, 0, 0, 255))
cmp.paste(orig.resize((w * 2, h * 2), Image.NEAREST), (0, 0))
cmp.paste(out.convert('RGBA').resize((w * 2, h * 2), Image.NEAREST), (w * 2 + 8, 0))
cmp.save(CMP)
