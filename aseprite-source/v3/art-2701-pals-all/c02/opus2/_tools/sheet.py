import sys
from PIL import Image
# usage: sheet.py out.png scale a.png b.png ...
out, sc = sys.argv[1], int(sys.argv[2]); fs = sys.argv[3:]
ims = [Image.open(f).convert('RGBA') for f in fs]
W = sum(max(i.width,64)*sc + 8 for i in ims) + 8
H = max(i.height for i in ims)*sc + 16 + 40
S = Image.new('RGBA', (W, H), (150,150,150,255))
x = 8
for i in ims:
    big = i.resize((i.width*sc, i.height*sc), Image.NEAREST)
    S.alpha_composite(big, (x, 8))
    sm = i  # 1x preview
    S.alpha_composite(sm, (x, H-i.height-4))
    x += max(i.width,64)*sc + 8
S.save(out)
