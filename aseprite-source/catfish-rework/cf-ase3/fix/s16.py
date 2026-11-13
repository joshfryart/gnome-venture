import sys
from PIL import Image, ImageDraw
src=sys.argv[1]; dst=sys.argv[2]
ic='fish silk catnip glitter string spring motor double sunbeam rug scratch window bowl toybox cattree catflap'.split()
names=['cf-up-%s'%k for k in ic]+['cf-badge-%s'%k for k in 'first_cat full_house odd_eyed legendary nap1 nap5 book12 book_half book_full'.split()]+['cf-ribbon-%s'%k for k in 'best blue red white part'.split()]
cols=8; cell=16*4+8
rows=(len(names)+cols-1)//cols
sh=Image.new('RGB',(cols*cell,rows*(cell+10)*2),(0,0,0))
d=ImageDraw.Draw(sh)
for bi,bg in enumerate(((240,225,200),(40,32,48))):
  for i,n in enumerate(names):
    im=Image.open(f'{src}/{n}.png').convert('RGBA').resize((16,16),Image.NEAREST)
    b=Image.new('RGBA',(16,16),bg+(255,)); b.alpha_composite(im)
    x=(i%cols)*cell+4; y=bi*rows*(cell+10)+(i//cols)*(cell+10)+4
    sh.paste(b.resize((64,64),Image.NEAREST).convert('RGB'),(x,y))
    d.text((x,y+64),str(i),fill=(255,0,255))
sh.save(dst)
