import sys
from PIL import Image
b=sys.argv[1]; idx=[int(i) for i in sys.argv[2].split(',')]; S=int(sys.argv[3]) if len(sys.argv)>3 else 6
d=f'/tmp/ase/states2/{b}/'; W=H=56
e=Image.open(d+f'{b}-empty.png').convert('RGBA'); r=Image.open(d+f'{b}-ready.png').convert('RGBA')
fr=[e.crop((i*W,0,(i+1)*W,H)) for i in range(4)]+[Image.open(d+f'{b}-l{i}.png').convert('RGBA') for i in (1,2,3)]+[r.crop((i*W,0,(i+1)*W,H)) for i in range(4)]
sh=Image.new('RGBA',(len(idx)*(W*S+4)+4,H*S+8),(196,226,160,255))
for j,i in enumerate(idx): sh.alpha_composite(fr[i].resize((W*S,H*S),Image.NEAREST),(4+j*(W*S+4),4))
sh.save('/tmp/ase/states2/zoom.png')
