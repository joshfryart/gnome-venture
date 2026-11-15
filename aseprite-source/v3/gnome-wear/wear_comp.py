import sys,os
from PIL import Image
D='/home/user/gnome-venture/game/assets/img/gnome25/'
MARK={(0xf0,0xf0,0xf0):0,(0xb4,)*3:1,(0x78,)*3:2,(0x3c,)*3:3}
DEF={'hat':['#ff8a5c','#e8493b','#b52e3f','#6e2038'],'tunic':['#b6f0e0','#5fc4c8','#3a86b0','#2a4a7a'],'scarf':['#ffe38a','#f5b82e','#d98322','#51302b'],
'beard':['#fff4d6','#e2e0e6','#aaa9b8','#74758c'],'boots':['#e8b982','#b97a4a','#864c33','#51302b'],'skin':['#ffe0bd','#f0b98d','#c98462','#51302b'],'trim':['#ffe38a','#f5b82e','#d98322','#51302b']}
ORDER=[('shadow',None),('outline',None),('boots','boots'),('tunic','tunic'),('scarf','scarf'),('skin','skin'),('beard','beard'),('face',None),('hat','hat'),('trim','trim')]
AFTER={'front':{'cape':'','pack':'','wboots':'boots','gloves':'skin','brim':'hat'},
'back':{'cape':'tunic','pack':'tunic','wboots':'boots','gloves':'skin','brim':'hat'},
'side':{'cape':'tunic','pack':'tunic','wboots':'boots','gloves':'skin','brim':'hat'}}
WEAR=['wboots','gloves','cape','brim','pack']
def h(x): return tuple(int(x[i:i+2],16) for i in (1,3,5))
def load(view,name,role,wd):
    f=(wd if name in WEAR else D)+f'{view}-{name}.png'
    if not os.path.exists(f): return None
    im=Image.open(f).convert('RGBA')
    if role:
        px=im.load(); r=[h(c) for c in DEF[role]]
        for y in range(im.height):
            for x in range(im.width):
                p=px[x,y]
                if p[3] and p[:3] in MARK: px[x,y]=r[MARK[p[:3]]]+(p[3],)
    return im
def compose(view,worn=(),wd=D,skip=()):
    st=[(w,None) for w in worn if AFTER[view][w]=='']
    for n,r in ORDER:
        st.append((n,r)); st+=[(w,None) for w in worn if AFTER[view][w]==n]
    out=Image.new('RGBA',(512,80))
    for n,r in st:
        if n in skip: continue
        im=load(view,n,r,wd)
        if im: out.alpha_composite(im)
    return out
