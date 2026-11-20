import sys
from PIL import Image
b,W,H=sys.argv[1],int(sys.argv[2]),int(sys.argv[3]); d=f"/tmp/ase/states2/{b}/"
def frames(n):
    im=Image.open(d+f"{b}-{n}.png").convert("RGBA"); return [im.crop((i*W,0,i*W+W,H)) for i in range(4)]
cells=frames("empty")+[Image.open(d+f"{b}-l{i}.png").convert("RGBA") for i in (1,2,3)]+frames("ready")
bad=0
for im in cells:
    for p in im.getdata():
        if p[3] not in(0,255): bad+=1
print("semi",bad)
S=3
sheet=Image.new("RGBA",(len(cells)*W*S+8,H*S+8),(198,230,190,255))
for i,im in enumerate(cells):
    sheet.alpha_composite(im.resize((W*S,H*S),Image.NEAREST),(4+i*W*S,4))
sheet.save(d+f"{b}-sheet.png")
