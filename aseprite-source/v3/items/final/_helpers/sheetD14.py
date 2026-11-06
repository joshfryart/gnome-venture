import sys
from PIL import Image, ImageDraw
D="/home/user/gnome-venture/aseprite-source/v3/items/final/ph/"
names=sys.argv[2:]; out=sys.argv[1]
S=256; cols=6
rows=(len(names)+cols-1)//cols
sheet=Image.new("RGB",(cols*S,rows*(S+14)),(104,104,118))
d=ImageDraw.Draw(sheet)
for i,n in enumerate(names):
    try: im=Image.open(D+n+".png").convert("RGBA")
    except Exception: continue
    x,y=(i%cols)*S,(i//cols)*(S+14)
    im4=im.resize((S,S),Image.NEAREST); sheet.paste(im4,(x,y+14),im4); d.text((x+2,y+1),n,fill=(255,255,255))
    sm=im.resize((32,32),Image.NEAREST); sheet.paste(sm,(x+S-34,y+16),sm)
sheet.save(out)
