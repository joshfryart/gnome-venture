import sys
from PIL import Image
b,W,H=sys.argv[1],int(sys.argv[2]),int(sys.argv[3])
d=f'/tmp/ase/states2/{b}/'
cells=[]
def strip(n):
    im=Image.open(d+f'{b}-{n}.png').convert('RGBA'); 
    return [im.crop((i*W,0,(i+1)*W,H)) for i in range(im.width//W)]
import os
if os.path.exists(d+f'{b}-empty.png'):
    cells+=strip('empty')+strip('l1')+strip('l2')+strip('l3')
cells+=strip('ready')
s=3
bg=(190,226,160,255)
out=Image.new('RGBA',(len(cells)*W*s+(len(cells)+1)*4,H*s+8),bg)
for i,cl in enumerate(cells):
    a=cl.resize((W*s,H*s),Image.NEAREST)
    out.alpha_composite(a,(4+i*(W*s+4),4))
    # semi check
    al=set(cl.getchannel('A').getdata())
    assert al<={0,255},(b,i,al)
out.save(d+f'{b}-sheet.png'); print(out.size)
