import json,sys
from PIL import Image,ImageDraw
S='/tmp/claude-0/-home-user-gnome-venture/9c742976-d6c0-5f98-947e-a8c24c975813/scratchpad/doors/'
L=json.load(open(S+'list1.json'))
P='/home/user/gnome-venture/game/assets/img/ph/npc-%s.png'
im=Image.open(P%L[0]['slug']); print(im.size)
sc=2 if im.size[0]>150 else 4
w,h=im.size[0]*sc,im.size[1]*sc
for k in range(2):
    sh=Image.new('RGB',(w*5,(h+14)*2),(200,190,170));d=ImageDraw.Draw(sh)
    for i,e in enumerate(L[k*10:k*10+10]):
        a=Image.open(P%e['slug']).convert('RGBA').resize((w,h),Image.NEAREST)
        x,y=(i%5)*w,(i//5)*(h+14)
        sh.paste(a,(x,y+14),a);d.text((x+2,y+1),e['slug']+' '+e['home'],fill=(0,0,0))
    sh.save(S+'w1/pt%d.png'%k)
