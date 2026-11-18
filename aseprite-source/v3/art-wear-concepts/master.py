import os,glob
from PIL import Image,ImageDraw
R=["NA","CA","CB","SA","NWE","SE","EE","MENA","WCA","ESA","CSA","EA","SEA","OC"]
C=["footwear","backpack","coat","cloak"]
Z=1;W=64
# rows: region x category; 5 icons each. Two category-groups side by side per row (footwear+backpack | coat+cloak)
cw=5*W+8
out=Image.new("RGBA",(4*cw+40,len(R)*(W+4)+24),(232,226,214,255));d=ImageDraw.Draw(out)
for ci,c in enumerate(C):d.text((30+ci*cw,4),c,fill=(43,28,38,255))
for ri,r in enumerate(R):
    y=24+ri*(W+4);d.text((2,y+28),r,fill=(43,28,38,255))
    for ci,c in enumerate(C):
        for i,f in enumerate(sorted(glob.glob(f"{r}/{c}-*.png"))[:5]):
            out.alpha_composite(Image.open(f).convert("RGBA"),(30+ci*cw+i*W,y))
out.save("master-sheet.png");print(out.size)
