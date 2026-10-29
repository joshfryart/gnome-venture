import sys
from PIL import Image
G='/home/user/gnome-venture/game/assets/img/gnome/gnome-'
OUT='/home/user/gnome-venture/aseprite-source/catfish/art22/out/'
def tint(im,hexc):
    r,g,b=[int(hexc[i:i+2],16)/255*1.25 for i in (1,3,5)]
    px=im.load(); o=im.copy(); op=o.load()
    for y in range(im.size[1]):
        for x in range(im.size[0]):
            p=px[x,y]
            if p[3]: op[x,y]=(min(255,round(p[0]*r)),min(255,round(p[1]*g)),min(255,round(p[2]*b)),p[3])
    return o
def comp(hat,beard,scarf,with_scarf=True):
    bg=Image.new('RGBA',(80,100),(236,226,205,255))
    for l in ['shadow','body','face','beard','hat','band']:
        im=Image.open(G+l+'.png').convert('RGBA')
        if l=='beard': im=tint(im,beard)
        if l=='hat': im=tint(im,hat)
        bg.alpha_composite(im)
    if with_scarf:
        s=Image.open(OUT+'gnome-scarf.png').convert('RGBA'); bg.alpha_composite(tint(s,scarf))
    return bg
combos=[('#c0392b','#f4f1ea','#2e7d4f'),('#2f5d9e','#b5651d','#e0a526'),('#7d4fa0','#3b2f2f','#c0392b'),('#8a8370','#d8c9a8','#2f5d9e')]
row=Image.new('RGBA',(80*5,100),(236,226,205,255))
row.paste(comp(*combos[0],with_scarf=False),(0,0))
for i,c in enumerate(combos): row.paste(comp(*c),(80*(i+1),0))
row.resize((1600,400),Image.NEAREST).save(OUT+'_view/comp4x.png')
row.resize((200,50),Image.NEAREST).save(OUT+'_view/comp_half.png')
row.save(OUT+'_view/comp1x.png')
s=Image.open(OUT+'gnome-scarf.png').convert('RGBA')
s.resize((320,400),Image.NEAREST).save(OUT+'_view/scarf4x.png')
