import sys
from PIL import Image
V='/home/user/gnome-venture/aseprite-source/catfish/art22/out/_view/'
O='/home/user/gnome-venture/aseprite-source/catfish/art22/out/'
G='/home/user/gnome-venture/game/assets/img/'
which=sys.argv[1]
if which=='npc':
    im=Image.open(O+'npc-didi_marigold.png').convert('RGBA')
    print('size',im.size,'colours',len(im.getcolors(9999)))
    refs=['ph/npc-lantern-lou.png','ph/npc-indigo-fennelwick.png']
    row=Image.new('RGBA',(240,100),'#5a5a5a')
    row.alpha_composite(Image.open(G+refs[0]).convert('RGBA'),(0,0))
    row.alpha_composite(im,(80,0))
    row.alpha_composite(Image.open(G+refs[1]).convert('RGBA'),(160,0))
    big=row.resize((960,400),Image.NEAREST)
    half=row.resize((120,50),Image.NEAREST)
    can=Image.new('RGBA',(960,460),'#2b2b2b'); can.alpha_composite(big,(0,0)); can.alpha_composite(half,(0,405))
    lite=Image.new('RGBA',(80,100),'#f1ece0'); lite.alpha_composite(im); can.alpha_composite(lite,(200,360))
    can.save(V+'front-CSA-npc.png')
else:
    im=Image.open(O+'banner-CSA-pets.png').convert('RGBA')
    print('size',im.size,'colours',len(im.getcolors(9999)), 'alpha',set(p[3] for p in im.getdata()))
    im.crop((120,0,360,120)).resize((960,480),Image.NEAREST).save(V+'front-CSA-banner4x.png')
    can=Image.new('RGBA',(480,370),'#2b2b2b')
    can.alpha_composite(Image.open(G+'scenes/banner-market.png').convert('RGBA'),(0,0))
    can.alpha_composite(im,(0,125))
    can.alpha_composite(im.resize((240,60),Image.NEAREST),(0,250))
    can.alpha_composite(Image.open(G+'scenes/banner-CSA.png').convert('RGBA').resize((240,60),Image.NEAREST),(240,250))
    can.save(V+'front-CSA-banner.png')
