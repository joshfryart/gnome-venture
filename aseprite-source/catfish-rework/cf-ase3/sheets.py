from PIL import Image
import os
O='/home/user/gnome-venture/game/assets/img/catfish/'; N='out/'
LIGHT=(240,225,200,255); DARK=(40,32,48,255)
def load(p): return Image.open(p).convert('RGBA')
def cell(im,s,bg,pad=0):
    b=Image.new('RGBA',im.size,bg); b.alpha_composite(im); return b.resize((im.width*s,im.height*s),Image.NEAREST)
def grid(keys,pre,cols,s,sz=64):
    W=cols*sz*s; rows=(len(keys)+cols-1)//cols
    out=[]
    for bg in (LIGHT,DARK):
        for grp in range(rows):
            for src in (O,N):
                row=Image.new('RGBA',(W,sz*s),bg)
                for j,k in enumerate(keys[grp*cols:(grp+1)*cols]):
                    row.alpha_composite(cell(load(src+pre%k),s,bg),(j*sz*s,0))
                out.append(row)
    H=sum(r.height for r in out); sh=Image.new('RGBA',(W,H+ (len(out)//2)*0),(255,0,255,255))
    y=0
    for r in out: sh.alpha_composite(r,(0,y)); y+=r.height
    return sh
ic='fish silk catnip glitter string spring motor double sunbeam rug scratch window bowl toybox cattree catflap'.split()
grid(ic,'cf-up-%s.png',8,4).convert('RGB').save(N+'sheet-icons.png')
bd=['badge-'+k for k in 'first_cat full_house odd_eyed legendary nap1 nap5 book12'.split()]+['badge-book_half','badge-book_full']+['ribbon-'+k for k in 'best blue red white part'.split()]
grid(bd,'cf-%s.png',7,4).convert('RGB').save(N+'sheet-badges.png')
# room at 2x
names=['sunbeam','rug','scratch','window','bowl','toybox','cattree','catflap']
def comp(src,base_name='cf-room.png'):
    b=load(src+base_name); a=Image.new('RGBA',b.size,(0,0,0,0))
    for n in names: a.alpha_composite(load(src+'cf-room-%s.png'%n))
    full=b.copy(); full.alpha_composite(a); return b,a,full
ob,oa,of=comp(O); nb,na,nf=comp(N)
rows=[(of,nf),(ob,nb)]
sh=Image.new('RGB',(1280,400*4),(255,0,255))
y=0
for l,r in rows:
    sh.paste(l.resize((640,400),Image.NEAREST).convert('RGB'),(0,y)); sh.paste(r.resize((640,400),Image.NEAREST).convert('RGB'),(640,y)); y+=400
for bg in (LIGHT,DARK):
    pass
for bg in (LIGHT,DARK):
    pass
# overlays only: light (left half of canvas area) and dark in one row each
for bg in (LIGHT,DARK):
    for a,x in ((oa,0),(na,640)):
        sh.paste(cell(a,2,bg).convert('RGB'),(x,y))
    y+=400
sh=sh.crop((0,0,1280,y)); sh.save(N+'sheet-room.png'); print(sh.size)
