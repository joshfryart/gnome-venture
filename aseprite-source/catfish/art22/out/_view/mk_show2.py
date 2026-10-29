from PIL import Image
import glob
base='/home/user/gnome-venture/'
im=Image.open(base+'aseprite-source/catfish/art22/out/cf-yi-show2.png').convert('RGBA')
im.resize((256,256),Image.NEAREST).save(base+'aseprite-source/catfish/art22/out/_view/show2_4x.png')
fs=[base+'game/assets/img/catfish/cf-up-%s.png'%k for k in ['silk','toybox','catflap','double','window']]+[base+'game/assets/img/catfish/cf-ribbon-blue.png']
W=Image.new('RGBA',(64*7,64+32),(236,226,204,255))
for i,f in enumerate(fs):
  a=Image.open(f).convert('RGBA'); W.paste(a,(i*64,0),a)
W.paste(im,(6*64,0),im)
h=im.resize((32,32),Image.NEAREST); W.paste(h,(0,64),h)
q=im.resize((16,16),Image.NEAREST); W.paste(q,(40,72),q)
for i,f in enumerate(fs):
  a=Image.open(f).convert('RGBA').resize((32,32),Image.NEAREST); W.paste(a,(64+i*32,64),a)
W.resize((W.width*2,W.height*2),Image.NEAREST).save(base+'aseprite-source/catfish/art22/out/_view/show2_cmp.png')
print(len(set(p for p in im.getdata() if p[3])))
