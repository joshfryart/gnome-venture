import sys
from PIL import Image
# view.py out.png scale file...
out, sc = sys.argv[1], int(sys.argv[2]); fs = sys.argv[3:]
ims = [Image.open(f).convert('RGBA') for f in fs]
W = sum(i.width*sc+8 for i in ims); H = max(i.height for i in ims)*sc
S = Image.new('RGBA', (W, H*2+8), (205,205,210,255))
x = 0
for i in ims:
    r = i.resize((i.width*sc, i.height*sc), Image.NEAREST)
    S.alpha_composite(r, (x, 0))
    d = Image.new('RGBA', r.size, (52,46,64,255)); d.alpha_composite(r); S.paste(d, (x, H+8))
    x += r.width+8
S.save(out)
