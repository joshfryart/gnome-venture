import sys,shutil
from PIL import Image
b=sys.argv[1]; d=f"/tmp/ase/states2/{b}/"
shutil.copy(d+f"{b}-ready.png", d+f"{b}-ready-l1.png")
rows=[Image.open(d+f"{b}-ready-l{i}.png").convert("RGBA") for i in (1,2,3)]
W,H=rows[0].size
S=Image.new("RGBA",(W*2,H*2*3),(196,226,160,255))
for i,r in enumerate(rows):
    r=r.resize((W*2,H*2),Image.NEAREST); S.alpha_composite(r,(0,i*H*2))
S.convert("RGB").save(d+f"{b}-ready-sheet.png")
for i in (1,2,3):
    a=Image.open(d+f"{b}-ready-l{i}.png").convert("RGBA").getchannel("A"); assert set(a.getdata())<={0,255}
# base match check
for i in (2,3):
    base=Image.open(d+f"{b}-l{i}.png").convert("RGBA"); r=Image.open(d+f"{b}-ready-l{i}.png").convert("RGBA")
    w=base.size[0]; diff=0
    for k in range(4):
        f=r.crop((k*w,0,(k+1)*w,base.size[1]))
        diff+=sum(1 for p,q in zip(f.getdata(),base.getdata()) if p!=q)
    print(b,"l",i,"px differing across 4 frames",diff)
