"""Contact sheets for every raster asset under game/assets/img (PNG/JPG/GIF). SVG twins are skipped.
Usage: python3 -I make_contact.py   -> art-review/contact/<family>/<n>.{png,jpg} + index.json"""
import os,json,re,math,sys
from multiprocessing import Pool
from PIL import Image,ImageDraw,ImageFont
Image.MAX_IMAGE_PIXELS=None
ROOT='/home/user/gnome-venture'; IMG=ROOT+'/game/assets/img'; OUT=ROOT+'/art-review/contact'
LIGHT=(241,236,224); DARK=(42,26,16); INK=(42,26,16); INKD=(242,228,192)
SHEET_W=1600; PER=120; PAD=6; LBL=12
def fam(rel):
    p=rel.split('/')
    return '/'.join(p[:-1]) or '_root'
def scale(im):
    w,h=im.size; m=max(w,h)
    if m<=128: return im.resize((w*min(4,max(1,128//m)),h*min(4,max(1,128//m))),Image.NEAREST)
    if m>240: s=240/m; return im.resize((max(1,round(w*s)),max(1,round(h*s))),Image.LANCZOS)
    return im
def job(args):
    fname,names=args; d=fname
    ims=[]
    for n in names:
        try:
            im=Image.open(f'{IMG}/{d}/{n}' if d!='_root' else f'{IMG}/{n}'); im.load()
            ims.append((n,im.convert('RGBA'),im.mode))
        except Exception as e: ims.append((n,None,str(e)))
    tiles=[(n,scale(im) if im else None) for n,im,_ in ims]
    cw=max([t.width for _,t in tiles if t]+[60])+PAD*2; ch=max([t.height for _,t in tiles if t]+[20])+PAD*2+LBL
    cols=max(1,SHEET_W//cw); rows=math.ceil(len(tiles)/cols); W=cols*cw; H=rows*ch
    opaque=all(im is None or im.getchannel('A').getextrema()[0]==255 for _,im,_ in ims)
    res=[]
    font=ImageFont.load_default(size=10)
    for theme,bg,ink in (('light',LIGHT,INK),('dark',DARK,INKD)):
        if theme=='dark' and opaque: continue
        sh=Image.new('RGB',(W,H),bg); dr=ImageDraw.Draw(sh)
        for i,(n,t) in enumerate(tiles):
            x=(i%cols)*cw; y=(i//cols)*ch
            if t: sh.paste(t,(x+PAD+(cw-2*PAD-t.width)//2,y+PAD),t)
            else: dr.rectangle((x+PAD,y+PAD,x+cw-PAD,y+ch-PAD-LBL),outline=(168,36,31))
            dr.text((x+PAD,y+ch-LBL-2),re.sub(r'\.[a-z]+$','',n)[:max(8,cw//6)],fill=ink,font=font)
        res.append((theme,sh))
    return res
if __name__=='__main__':
    groups={}
    for dp,_,fs in os.walk(IMG):
        for f in sorted(fs):
            if f.rsplit('.',1)[-1].lower() in('png','jpg','gif','webp'):
                rel=os.path.relpath(dp+'/'+f,IMG); groups.setdefault(fam(rel),[]).append(os.path.basename(f))
    jobs=[];meta=[]
    for d,names in sorted(groups.items()):
        names.sort()
        for i in range(0,len(names),PER):
            jobs.append((d,names[i:i+PER])); meta.append((d,i//PER+1,names[i],names[min(i+PER,len(names))-1],len(names[i:i+PER])))
    print(len(jobs),'sheet jobs',flush=True)
    index=[]
    def run(j): return job(j)
    with Pool(4) as pl:
        for k,res in enumerate(pl.imap(job,jobs,chunksize=1)):
            d,n,a,b,cnt=meta[k]; od=f'{OUT}/{d}'; os.makedirs(od,exist_ok=True)
            for theme,sh in res:
                path=f'{od}/{n:02d}-{theme}.jpg'
                sh.save(path,'JPEG',quality=88,subsampling=0)
                index.append(dict(family=d,sheet=n,theme=theme,first=a,last=b,count=cnt,path=os.path.relpath(path,ROOT),w=sh.width,h=sh.height))
            if k%25==0: print(k,len(jobs),flush=True)
    json.dump(index,open(OUT+'/index.json','w'),indent=0)
    print('done',len(index),'images',flush=True)
