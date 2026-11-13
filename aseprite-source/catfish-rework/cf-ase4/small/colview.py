import sys
from PIL import Image,ImageDraw
N='/tmp/claude-0/-home-user-gnome-venture/5ea3a19c-b77b-53be-abcb-7211df396576/scratchpad/cf-ase2/final2/'
ims=[]
for f in ['idleA','pounce','catch','nap']:
    c=Image.open('out/cf-collar-rose-%s.png'%f).convert('RGBA'); k=Image.open(N+'cf-cat-grey-%s.png'%f).convert('RGBA')
    bg=Image.new('RGBA',(64,64),(70,60,80,255)); bg.alpha_composite(k); bg.alpha_composite(c)
    ims.append(bg.resize((512,512),Image.NEAREST))
W=Image.new('RGB',(512*4,512))
for i,im in enumerate(ims): W.paste(im.convert('RGB'),(i*512,0))
W.resize((1600,400),Image.NEAREST).save('v/col.png')
