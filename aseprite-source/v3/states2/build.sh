#!/bin/bash
# usage: build.sh greenhouse 72 64
b=$1; W=$2; H=$3
cd /tmp/ase/states2
{ echo "local W,H,NAME = $W,$H,\"$b\""; cat src_gt/kit.lua src_gt/${b}_body.lua; } > $b.lua
mkdir -p $b
/tmp/ase/squashfs-root/AppRun -b --script-param out=/tmp/ase/states2/$b/ --script /tmp/ase/states2/$b.lua 2>&1 | tail -15
python3 - <<PY
from PIL import Image
b="$b"; W=$W; H=$H
d="/tmp/ase/states2/%s/"%b
def frames(f,n):
    im=Image.open(d+f).convert("RGBA"); return [im.crop((i*W,0,(i+1)*W,H)) for i in range(n)]
fr=frames(b+"-empty.png",4)+[Image.open(d+b+"-l%d.png"%i).convert("RGBA") for i in (1,2,3)]+frames(b+"-ready.png",4)
s=3
sheet=Image.new("RGBA",(W*s*11,H*s),(190,222,150,255))
for i,f in enumerate(fr):
    sheet.alpha_composite(f.resize((W*s,H*s),Image.NEAREST),(i*W*s,0))
sheet.convert("RGB").save(d+b+"-sheet.png")
bad=0
for f in fr:
    for a in f.getchannel("A").getdata():
        if a not in (0,255): bad+=1
print("semi px:",bad)
PY
