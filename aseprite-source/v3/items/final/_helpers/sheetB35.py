import sys
from PIL import Image, ImageDraw
D="/home/user/gnome-venture/aseprite-source/v3/items/final/ph/"
out=sys.argv[1]; names=sys.argv[2:]
S=192; cols=5
rows=(len(names)+cols-1)//cols
sheet=Image.new("RGB",(cols*S,rows*(S+14)),(104,104,118))
d=ImageDraw.Draw(sheet)
for i,n in enumerate(names):
    try: im=Image.open(D+n+".png").convert("RGBA")
    except Exception: continue
    im3=im.resize((S,S),Image.NEAREST)
    x,y=(i%cols)*S,(i//cols)*(S+14)
    sheet.paste(im3,(x,y+14),im3); d.text((x+2,y+1),n,fill=(255,255,255))
    sm=im.resize((32,32),Image.NEAREST); sheet.paste(sm,(x+S-34,y+16),sm)
sheet.save(out)
