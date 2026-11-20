import sys
from PIL import Image
b=sys.argv[1]; d=f'/tmp/ase/states2/{b}/'
rows=[Image.open(d+f'{b}-ready-l{i}.png').convert('RGBA') for i in (1,2,3)]
w,h=rows[0].size; S=2
sh=Image.new('RGBA',(w*S,h*S*3),(196,224,180,255))
for i,r in enumerate(rows):
    assert r.size==(w,h)
    assert set(r.getchannel('A').tobytes())<={0,255}
    sh.alpha_composite(r.resize((w*S,h*S),Image.NEAREST),(0,i*h*S))
sh.convert('RGB').save(d+f'{b}-ready-sheet.png')
