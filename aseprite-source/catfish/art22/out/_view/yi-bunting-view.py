from PIL import Image
import sys,glob
im=Image.open('out/cf-yi-bunting.png').convert('RGBA')
im.resize((256,256),Image.NEAREST).save('out/_view/yi-bunting-4x.png')
h=im.resize((32,32),Image.NEAREST)
fs=sorted(f for f in glob.glob('out/cf-yi-*.png') if 'bunting' not in f)[:6]+['out/cf-yi-bunting.png']
W=Image.new('RGBA',(len(fs)*72+len(fs)*40,72),(235,225,205,255))
for i,f in enumerate(fs):
  a=Image.open(f).convert('RGBA'); W.paste(a,(i*72+4,4),a)
  b=a.resize((32,32),Image.NEAREST); W.paste(b,(len(fs)*72+i*40+4,20),b)
W=W.resize((W.width*2,W.height*2),Image.NEAREST); W.save('out/_view/yi-bunting-cmp.png')
