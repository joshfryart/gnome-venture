import sys
from PIL import Image
# usage: _sheet.py out.png scale a.png b.png ...  (grid, gray bg, 4 per row)
out, sc, files = sys.argv[1], int(sys.argv[2]), sys.argv[3:]
ims = [Image.open(f).convert("RGBA") for f in files]
cw = max(i.width for i in ims)*sc + 8; ch = max(i.height for i in ims)*sc + 8
cols = min(4, len(ims)); rows = (len(ims)+cols-1)//cols
S = Image.new("RGBA", (cw*cols, ch*rows), (128,128,128,255))
for k, im in enumerate(ims):
    b = im.resize((im.width*sc, im.height*sc), Image.NEAREST)
    S.alpha_composite(b, ((k%cols)*cw+4, (k//cols)*ch+4))
S.save(out)
