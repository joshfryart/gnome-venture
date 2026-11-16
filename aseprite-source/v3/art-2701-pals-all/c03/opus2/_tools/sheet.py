import sys
from PIL import Image
# usage: sheet.py out.png scale file1 file2 ...
out, sc = sys.argv[1], int(sys.argv[2]); fs = sys.argv[3:]
ims = [Image.open(f).convert("RGBA") for f in fs]
W = sum(i.width*sc+8 for i in ims); H = max(i.height*sc for i in ims)+8
S = Image.new("RGBA", (W, H), (150,160,150,255)); x = 4
for i in ims:
    S.paste(i.resize((i.width*sc, i.height*sc), Image.NEAREST), (x,4), i.resize((i.width*sc, i.height*sc), Image.NEAREST)); x += i.width*sc+8
S.save(out)
