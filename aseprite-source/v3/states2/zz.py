import sys
from PIL import Image
b,W,H=sys.argv[1],int(sys.argv[2]),int(sys.argv[3]); names=sys.argv[4:]
d=f'{b}/{b}-'
fr=[]
for n in names:
    nm,i=(n.split(':')+['0'])[:2]; i=int(i)
    im=Image.open(d+nm+'.png').convert('RGBA'); fr.append(im.crop((i*W,0,i*W+W,H)))
o=Image.new('RGBA',(3*(W*6+6),((len(fr)+2)//3)*(H*6+6)),(190,226,160,255))
for i,a in enumerate(fr): o.alpha_composite(a.resize((W*6,H*6),Image.NEAREST),((i%3)*(W*6+6),(i//3)*(H*6+6)))
o.save('z.png')
