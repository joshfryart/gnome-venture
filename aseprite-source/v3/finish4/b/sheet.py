import sys
from PIL import Image, ImageDraw
names=sys.argv[2:]
W,Hh=480,270
cols=2; rows=(len(names)+1)//2
im=Image.new("RGB",(W*cols,Hh*rows),(40,40,40))
for i,n in enumerate(names):
    p=Image.open(f"out/{n}.png").convert("RGB"); im.paste(p,((i%2)*W,(i//2)*Hh))
    ImageDraw.Draw(im).text(((i%2)*W+4,(i//2)*Hh+4),n,fill=(255,255,0))
im.save(sys.argv[1])
