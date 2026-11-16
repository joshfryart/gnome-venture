import sys
from PIL import Image
# usage: sheet.py out.png scale file1 file2 ... (grid 4 cols)
out=sys.argv[1]; s=int(sys.argv[2]); fs=sys.argv[3:]
ims=[Image.open(f).convert("RGBA") for f in fs]
cw=max(i.width for i in ims)*s+8; ch=max(i.height for i in ims)*s+8
cols=min(4,len(ims)); rows=(len(ims)+cols-1)//cols
S=Image.new("RGBA",(cw*cols,ch*rows),(150,150,160,255))
for k,i in enumerate(ims):
    S.alpha_composite(i.resize((i.width*s,i.height*s),Image.NEAREST),((k%cols)*cw+4,(k//cols)*ch+4))
S.save(out)
