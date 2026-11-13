from PIL import Image
B='../out/'; A='out/'
LIGHT=(240,225,200,255); DARK=(40,32,48,255)
ld=lambda p:Image.open(p).convert('RGBA')
names=['sunbeam','rug','scratch','window','bowl','toybox','cattree','catflap']
def full(src):
    f=ld(src+'cf-room.png')
    for n in names: f.alpha_composite(ld(src+'cf-room-%s.png'%n))
    return f
def ov(src,bg):
    o=ld(src+'cf-room-sunbeam.png'); b=Image.new('RGBA',o.size,bg); b.alpha_composite(o); return b
def sc(i,s): return i.resize((i.width*s,i.height*s),Image.NEAREST).convert('RGB')
W=1280
items=['cf-ribbon-best','cf-up-catflap','cf-up-sunbeam','cf-up-glitter','cf-up-motor','cf-badge-odd_eyed','cf-badge-book_half','cf-badge-book_full','cf-ribbon-blue','cf-up-spring']
rows=[]
rows.append((sc(full(B),2),sc(full(A),2)))
rows.append((sc(ov(B,DARK).crop((0,60,320,200)),2),sc(ov(A,DARK).crop((0,60,320,200)),2)))
rows.append((sc(ov(B,LIGHT).crop((0,60,320,200)),2),sc(ov(A,LIGHT).crop((0,60,320,200)),2)))
H=sum(l.height for l,_ in rows)+2*(2*(64*2+4))+20
sh=Image.new('RGB',(W,H),(255,0,255)); y=0
for l,r in rows: sh.paste(l,(0,y)); sh.paste(r,(640,y)); y+=l.height+2
for bg in (LIGHT,DARK):
    for src,x0 in ((B,0),(A,640)):
        for j,n in enumerate(items):
            im=ld(src+n+'.png'); b=Image.new('RGBA',(64,64),bg); b.alpha_composite(im)
            sh.paste(sc(b.resize((64,64)),1).resize((64,64)) if False else b.convert('RGB').resize((64,64)),(x0+j*64,y)) if False else sh.paste(b.convert('RGB'),(x0+j*64,y))
    y+=66
sh.save('sheet-fix.png'); print(sh.size)
# overlay darkness check
o=ld(A+'cf-room-sunbeam.png'); px=[p for p in o.getdata() if p[3]>0]
print('overlay px',len(px),'min lum',min(0.3*p[0]+.59*p[1]+.11*p[2] for p in px))
