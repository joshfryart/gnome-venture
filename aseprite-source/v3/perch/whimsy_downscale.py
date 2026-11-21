import os,sys
import numpy as np
from PIL import Image
D='game/assets/img/pals/';P=D+'perch/'
def mk(k):
    a=Image.open(D+k+'.png').convert('RGBA');a=a.crop(a.getbbox())
    s=min(34/a.width,34/a.height);sz=(max(1,round(a.width*s)),max(1,round(a.height*s)))
    src=np.array(a).astype(float)
    pre=src.copy();pre[...,:3]*=pre[...,3:]/255
    b=Image.fromarray(np.clip(pre,0,255).astype('uint8'),'RGBA').resize(sz,Image.BOX)
    b=np.array(b).astype(float);al=b[...,3]
    rgb=np.where(al[...,None]>0,b[...,:3]/np.maximum(al[...,None],1)*255,0)
    # palette of source opaque pixels (most common 48)
    op=src[src[...,3]>200][:,:3].astype('uint8')
    cols,cnt=np.unique(op,axis=0,return_counts=True)
    pal=cols[np.argsort(-cnt)[:48]].astype(float)
    mask=al>=110
    out=np.zeros((sz[1],sz[0],4),'uint8')
    flat=rgb.reshape(-1,3);idx=((flat[:,None,:]-pal[None])**2).sum(2).argmin(1)
    out[...,:3]=pal[idx].reshape(sz[1],sz[0],3).astype('uint8');out[...,3]=np.where(mask,255,0)
    o=Image.new('RGBA',(36,36),(0,0,0,0));o.paste(Image.fromarray(out,'RGBA'),((36-sz[0])//2,35-sz[1]))
    return o
if __name__=='__main__':
    rows=[l.rstrip('\n').split('|') for l in open('game/includes/data/puzzle_pals.txt') if not l.startswith('#') and '|' in l]
    wh=[r[1] for r in rows if r[10].startswith('whimsy')]
    have=[k for k in wh if os.path.exists(P+k+'.png')];miss=[k for k in wh if not os.path.exists(P+k+'.png')]
    if sys.argv[1]=='test':
        im=Image.new('RGB',(8*116,2*116),(205,195,170))
        for i,k in enumerate(have[:8]):
            for j,pic in enumerate([Image.open(P+k+'.png').convert('RGBA'),mk(k)]):
                p=pic.resize((108,108),Image.NEAREST);im.paste(p,(i*116+4,j*116+4),p)
        im.save(sys.argv[2])
    else:
        for k in miss: mk(k).save(P+k+'.png')
        print(len(miss))
