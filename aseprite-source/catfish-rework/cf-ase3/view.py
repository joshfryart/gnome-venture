import sys
from PIL import Image
im=Image.open(sys.argv[1]).convert('RGBA'); s=int(sys.argv[2]); 
bg=Image.new('RGBA',im.size,(70,60,80,255)); bg.alpha_composite(im)
if len(sys.argv)>4:
    x0,y0,x1,y1=map(int,sys.argv[4].split(',')); bg=bg.crop((x0,y0,x1,y1))
bg.resize((bg.width*s,bg.height*s),Image.NEAREST).save(sys.argv[3])
