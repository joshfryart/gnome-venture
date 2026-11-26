"""Remove the baked-in robin from craftmap/decor.png (yard corner scene).
The birdbath rim under the bird is rebuilt by mirroring the right half of the
(symmetric) bath across its axis x=451, recolouring the right-side shaded
outline browns to the left-side outline colour. Sky / pink hedge behind the
bird are filled from the nearest untouched pixel class."""
from collections import deque
import numpy as np
from PIL import Image

SRC = '/home/user/gnome-venture/game/assets/img/craftmap/decor.png'
OUT = '/home/user/gnome-venture/art-review/scenes/out/craftmap__decor.png'
CMP = '/home/user/gnome-venture/art-review/scenes/out/craftmap__decor-cmp.png'

im = Image.open(SRC)
a = np.array(im).astype(int)
H, W = a.shape[:2]
x0, x1, y0, y1 = 274, 428, 105, 206
ROBIN = [(154,107,63),(224,80,31),(201,169,110),(42,26,16),(122,74,31),(184,69,47),
         (74,44,26),(240,138,36),(176,122,16),(245,207,106),(232,163,23),(255,255,255)]
SKY = (159,211,234); PINK = (217,138,168); PINK_HI = (238,170,194); PINK_LO = (188,108,142)
BG = {SKY, PINK, PINK_HI, PINK_LO}
RIM_OUT = (116,70,42)
DARK_OUT = {(74,44,26),(42,26,16),(122,74,31)}
CX2 = 902

mask = np.zeros((H, W), bool)
sub = a[y0:y1, x0:x1]
m = np.zeros(sub.shape[:2], bool)
for c in ROBIN:
    m |= (sub == c).all(2)
mask[y0:y1, x0:x1] = m
# robin outline pixels that share the rim outline colour: robin where the
# mirrored pixel on the same row is still sky/hedge (i.e. above the rim)
for y in range(y0, y1):
    for x in range(x0, x1):
        if tuple(a[y, x]) == RIM_OUT and tuple(a[y, CX2 - x]) in BG and y < 190 and x > 278:
            mask[y, x] = True

out = a.copy()
need_bg = np.zeros_like(mask)
for y, x in zip(*np.nonzero(mask)):
    s = tuple(a[y, CX2 - x])
    if s in BG:
        need_bg[y, x] = True
    else:
        out[y, x] = RIM_OUT if s in DARK_OUT else s

# nearest-class fill for sky vs pink (BFS from untouched neighbours)
lab = np.full((H, W), -1)
q = deque()
for y in range(y0 - 2, y1 + 2):
    for x in range(x0 - 2, x1 + 2):
        if not need_bg[y, x]:
            c = tuple(out[y, x])
            if c == SKY: lab[y, x] = 0
            elif c in (PINK, PINK_HI, PINK_LO): lab[y, x] = 1
            else: continue
            q.append((y, x))
while q:
    y, x = q.popleft()
    for dy, dx in ((0,1),(0,-1),(1,0),(-1,0)):
        ny, nx = y+dy, x+dx
        if need_bg[ny, nx] and lab[ny, nx] < 0:
            lab[ny, nx] = lab[y, x]; q.append((ny, nx))
for y, x in zip(*np.nonzero(need_bg)):
    out[y, x] = SKY if lab[y, x] == 0 else PINK
# hedge left edge behind the tail: straight edge at x=304 with a 1px light rim
for y, x in zip(*np.nonzero(need_bg)):
    if 140 <= y <= 184:
        out[y, x] = SKY if x < 304 else (PINK_HI if x == 304 else PINK)

res = Image.fromarray(out.astype(np.uint8), im.mode)
res.save(OUT)
cmp = Image.new(im.mode, (W*4, H*2))
cmp.paste(im.resize((W*2, H*2), Image.NEAREST), (0, 0))
cmp.paste(res.resize((W*2, H*2), Image.NEAREST), (W*2, 0))
cmp.save(CMP)
res.crop((250, 90, 470, 230)).resize((1320, 840), Image.NEAREST).save(
    '/tmp/claude-0/-home-user-gnome-venture/cc3d4c9b-a800-56ef-8027-195f85f30c2e/scratchpad/zoom.png')
print(res.size, res.mode, len(set(map(tuple, out.reshape(-1,3)))), len(set(map(tuple, a.reshape(-1,3)))))
