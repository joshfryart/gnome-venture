import sys
from PIL import Image
# usage: sheet.py out.png scale file1 file2 ...  (each sprite at scale, plus a 1x copy under it)
out, sc = sys.argv[1], int(sys.argv[2]); fs = sys.argv[3:]
ims = [Image.open(f).convert("RGBA") for f in fs]
W = sum(i.width*sc+8 for i in ims)+4; H = max(i.height*sc for i in ims)+80
S = Image.new("RGBA", (W, H), (150,160,150,255)); x = 4
for i in ims:
    b = i.resize((i.width*sc, i.height*sc), Image.NEAREST)
    S.paste(b, (x,4), b); S.paste(i, (x, H-70), i); x += i.width*sc+8
S.save(out)
