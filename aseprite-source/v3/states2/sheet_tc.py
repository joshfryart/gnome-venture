import sys
from PIL import Image
b=sys.argv[1]; d=f'/tmp/ase/states2/{b}/'
def strip(n):
    im=Image.open(d+f'{b}-{n}.png').convert('RGBA'); w=im.width//4
    return [im.crop((i*w,0,(i+1)*w,im.height)) for i in range(4)]
fr=strip('empty')+[Image.open(d+f'{b}-l{i}.png').convert('RGBA') for i in (1,2,3)]+strip('ready')
for f in fr:
    assert set(f.getchannel('A').tobytes())<={0,255}, 'semi alpha'
w,h=fr[0].size; S=3; pad=4
sheet=Image.new('RGBA',(len(fr)*(w*S+pad)+pad, h*S+2*pad),'#c4e3b8')
for i,f in enumerate(fr):
    sheet.alpha_composite(f.resize((w*S,h*S),Image.NEAREST),(pad+i*(w*S+pad),pad))
sheet.save(d+f'{b}-sheet.png')
for name,sub in (('a',fr[:4]),('b',fr[4:7]),('c',fr[7:])):
    s=Image.new('RGBA',(len(sub)*(w*5+pad)+pad,h*5+2*pad),'#c4e3b8')
    for i,f in enumerate(sub): s.alpha_composite(f.resize((w*5,h*5),Image.NEAREST),(pad+i*(w*5+pad),pad))
    s.save(f'/tmp/ase/states2/{b}/zoom_{name}.png')
print('ok')
