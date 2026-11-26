import os,sys,hashlib,json,collections,re
from multiprocessing import Pool
from PIL import Image
Image.MAX_IMAGE_PIXELS=None
R='/home/user/gnome-venture/game/assets/img'
S='/tmp/claude-0/-home-user-gnome-venture/cc3d4c9b-a800-56ef-8027-195f85f30c2e/scratchpad/'
def one(p):
    rel=os.path.relpath(p,R); b=os.path.getsize(p); sha=hashlib.sha256(open(p,'rb').read()).hexdigest()
    d=dict(rel=rel,bytes=b,sha=sha,ext=rel.rsplit('.',1)[-1].lower())
    if d['ext']!='png' and d['ext'] not in('jpg','gif','webp'): return d
    try:
        im=Image.open(p); d.update(w=im.width,h=im.height,mode=im.mode)
        if d['ext']!='png': return d
        a=im.convert('RGBA')
        c=a.getcolors(maxcolors=1<<24)
        d['colors']=len(c)
        d['semi']=sum(n for n,(r,g,bb,al) in c if 0<al<255)
        d['black']=sum(n for n,(r,g,bb,al) in c if al>0 and r+g+bb==0)
        d['empty']=a.getchannel('A').getbbox() is None
    except Exception as e: d['err']=str(e)
    return d
if __name__=='__main__':
    files=[os.path.join(dp,f) for dp,_,fs in os.walk(R) for f in fs]
    with Pool(os.cpu_count()) as pl: rows=pl.map(one,files,chunksize=50)
    json.dump(rows,open(S+'scan_all.json','w'))
    print(len(rows))
