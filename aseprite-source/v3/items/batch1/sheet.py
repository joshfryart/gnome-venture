import sys,glob,os
from PIL import Image
d='/home/user/gnome-venture/aseprite-source/v3/items/batch1/'
names=sys.argv[2:] or sorted(os.path.basename(f)[:-4] for f in glob.glob(d+'*.png') if '_x' not in f)
cols=6; S=4; cw=64*S//2*2
rows=(len(names)+cols-1)//cols
W=Image.new('RGB',(cols*64*S//1,rows*64*S),(150,160,150))
# 4x at 256px cells -> too big; use x3
S=4
W=Image.new('RGB',(cols*64*S,rows*64*S),(140,150,140))
for i,n in enumerate(names):
    im=Image.open(d+n+'.png').convert('RGBA').resize((64*S,64*S),Image.NEAREST)
    W.paste(im,((i%cols)*64*S,(i//cols)*64*S),im)
W.save(sys.argv[1])
