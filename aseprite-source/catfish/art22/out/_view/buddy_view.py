import sys
from PIL import Image
G='/home/user/gnome-venture/game/assets/img/catfish/'
V='/home/user/gnome-venture/aseprite-source/catfish/art22/out/_view/'
b=Image.open('/home/user/gnome-venture/aseprite-source/catfish/art22/out/cf-yi-buddy.png').convert('RGBA')
b.resize((256,256),Image.NEAREST).save(V+'buddy_4x.png')
ims=[Image.open(G+n+'.png').convert('RGBA') for n in ['cf-up-catflap','cf-up-toybox','cf-up-cattree']]+[b]
s=Image.new('RGBA',(74*4,64),(240,232,214,255))
for i,im in enumerate(ims): s.paste(im,(i*74,0),im)
h=s.resize((s.width//2,32),Image.NEAREST)
out=Image.new('RGBA',(s.width,96),(240,232,214,255)); out.paste(s,(0,0)); out.paste(h,(0,64))
q=Image.new('RGBA',(s.width,96),(40,36,48,255)); q.paste(out,(0,0))
out.resize((out.width*3,out.height*3),Image.NEAREST).save(V+'buddy_cmp.png')
