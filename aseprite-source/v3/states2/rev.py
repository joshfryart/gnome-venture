import sys
from PIL import Image
b,W,H,s=sys.argv[1],int(sys.argv[2]),int(sys.argv[3]),int(sys.argv[4])
d="/tmp/ase/states2/%s/"%b
def fr(f,n):
    im=Image.open(d+f).convert("RGBA"); return [im.crop((i*W,0,(i+1)*W,H)) for i in range(n)]
rows={"A":fr(b+"-empty.png",4)[:2],"B":[Image.open(d+b+"-l%d.png"%i).convert("RGBA") for i in (1,2,3)],"C":fr(b+"-ready.png",4)[:2]}
for k,v in rows.items():
    im=Image.new("RGBA",(W*s*len(v),H*s),(190,222,150,255))
    for i,f in enumerate(v): im.alpha_composite(f.resize((W*s,H*s),Image.NEAREST),(i*W*s,0))
    im.convert("RGB").save("/tmp/ase/states2/rev_%s_%s.png"%(b,k))
