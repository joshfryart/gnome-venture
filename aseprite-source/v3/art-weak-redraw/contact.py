from PIL import Image, ImageDraw
import os
ns=['ginseng','ginseng-seed','stone-wall-end','tomato','stuffed-peppers-goat']
d=os.path.dirname(os.path.abspath(__file__)); Z=5; P=64*Z
S=Image.new('RGB',(len(ns)*(P+8)+8,2*(P+8)+8+14),(118,118,130)); dr=ImageDraw.Draw(S)
for i,n in enumerate(ns):
    for r,p in enumerate([d+'/old/%s.png'%n, d+'/%s.png'%n]):
        im=Image.open(p).convert('RGBA').resize((P,P),Image.NEAREST)
        S.paste(im,(8+i*(P+8),8+r*(P+8)),im)
    dr.text((10+i*(P+8),2*(P+8)+8),n,fill=(255,255,255))
S.save(d+'/contact-old-vs-new.png')
