import sys,glob
from PIL import Image,ImageDraw
names=sys.argv[2:]
sh=Image.new("RGB",(960,270*((len(names)+1)//2)),(40,40,40))
for i,n in enumerate(names):
    im=Image.open(f"out/{n}.png").convert("RGB"); sh.paste(im,((i%2)*480,(i//2)*270))
    ImageDraw.Draw(sh).text(((i%2)*480+4,(i//2)*270+4),n,fill=(255,255,255))
sh.save(sys.argv[1])
