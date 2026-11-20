import sys
from PIL import Image
b=sys.argv[1]; d=f'/tmp/ase/states2/{b}/'
W=H=56
def strip(n):
    im=Image.open(d+f'{b}-{n}.png').convert('RGBA'); return [im.crop((i*W,0,(i+1)*W,H)) for i in range(4)]
fr=strip('empty')+[Image.open(d+f'{b}-l{i}.png').convert('RGBA') for i in (1,2,3)]+strip('ready')
for f in fr:
    assert set(f.getchannel('A').tobytes())<= {0,255}, 'semi'
S=3; sh=Image.new('RGBA',(len(fr)*(W*S+4)+4,H*S+8),(196,226,160,255))
for i,f in enumerate(fr):
    sh.alpha_composite(f.resize((W*S,H*S),Image.NEAREST),(4+i*(W*S+4),4))
sh.save(d+f'{b}-sheet.png')
# bbox report
for n,f in zip(['e1','e2','e3','e4','l1','l2','l3','r1','r2','r3','r4'],fr): print(n,f.getbbox(),end=' | ')
print()
