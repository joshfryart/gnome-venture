import sys
from PIL import Image
b=sys.argv[1]; d=f"/tmp/ase/states2/{b}/"
import shutil; shutil.copy(d+f"{b}-ready.png", d+f"{b}-ready-l1.png")
rows=[Image.open(d+f"{b}-ready-l{i}.png").convert("RGBA") for i in (1,2,3)]
w,h=rows[0].size
for r in rows:
    assert r.size==(w,h)
    assert all(a in (0,255) for a in r.getchannel("A").getdata()), "semi alpha"
sh=Image.new("RGBA",(w*2,h*2*3),(196,228,170,255))
for i,r in enumerate(rows):
    sh.alpha_composite(r.resize((w*2,h*2),Image.NEAREST),(0,i*h*2))
sh.save(d+f"{b}-ready-sheet.png")
# base compare
for i in (2,3):
    base=Image.open(d+f"{b}-l{i}.png").convert("RGBA"); r=rows[i-1]; W=w//4
    for k in range(4):
        fr=r.crop((k*W,0,k*W+W,h)); n=sum(1 for p,q in zip(base.getdata(),fr.getdata()) if p!=q)
        print("l%d frame%d diff px %d"%(i,k+1,n))
