#!/usr/bin/env python3
"""usage: make_contact.py <repo> <perch_dir> <out.png> <order.txt> key1 key2 ... (6 per row, stickers row above perches row)"""
import sys
from PIL import Image
repo,pd,out,order=sys.argv[1:5]; keys=sys.argv[5:]
S=6; cell=64*S; per=6; rows=(len(keys)+per-1)//per
im=Image.new("RGB",(per*cell,rows*2*cell),(128,128,128))
for i,k in enumerate(keys):
    r,c=divmod(i,per)
    for j,p in enumerate([repo+"/game/assets/img/puzzles/pals/%s.png"%k, pd+"/%s.png"%k]):
        a=Image.open(p).convert("RGBA").resize((cell,cell),Image.NEAREST)
        im.paste(a,(c*cell,(r*2+j)*cell),a)
im.save(out)
open(order,"w").write("\n".join("row %d col %d: %s"%(i//per+1,i%per+1,k) for i,k in enumerate(keys))+"\n")
