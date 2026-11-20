import sys,shutil
from PIL import Image
b=sys.argv[1]; d=f"/tmp/ase/states2/{b}/"
shutil.copy(d+f"{b}-ready.png", d+f"{b}-ready-l1.png")
S=2; rows=[Image.open(d+f"{b}-ready-l{i}.png").convert("RGBA") for i in (1,2,3)]
w,h=rows[0].size
sh=Image.new("RGBA",(w*S,h*S*3),(200,228,160,255))
bad=0
for i,r in enumerate(rows):
    sh.alpha_composite(r.resize((w*S,h*S),Image.NEAREST),(0,i*h*S))
    bad+=sum(1 for p in r.getdata() if p[3] not in(0,255))
# base match
for i in (2,3):
    base=Image.open(d+f"{b}-l{i}.png").convert("RGBA"); r=rows[i-1]; W=w//4
    diff=[sum(1 for x in range(W) for y in range(h) if r.getpixel((f*W+x,y))!=base.getpixel((x,y))) for f in range(4)]
    print("l",i,"diff px per frame",diff)
sh.save(d+f"{b}-ready-sheet.png"); print("semi",bad)
