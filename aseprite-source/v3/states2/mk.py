import sys
from PIL import Image
for b,W,H in (("greenhouse",72,64),("tailor",64,64)):
    d=f"/tmp/ase/states2/{b}/"
    rows=[Image.open(d+f"{b}-ready-l{i}.png").convert("RGBA") for i in (1,2,3)]
    for r in rows[1:]:
        a=r.getchannel("A").getdata(); assert set(a)<={0,255}, b
    s=Image.new("RGBA",(4*W*2,3*H*2),(184,220,140,255))
    for i,r in enumerate(rows):
        r=r.resize((r.width*2,r.height*2),Image.NEAREST); s.alpha_composite(r,(0,i*H*2))
    s.save(d+f"{b}-ready-sheet.png")
