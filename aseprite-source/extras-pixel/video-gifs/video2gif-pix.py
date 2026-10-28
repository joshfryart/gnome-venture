import sys,glob,itertools,numpy as np
from PIL import Image
F={"soil":"3d2a1c 7a4a1f 9a6b3f c9a96e f1ece0","moss":"2f5a2a 4f9a45 7ab55c a4b86a","gold":"b07a10 e8a317 f5cf6a","ember":"a8241f d6322b e0501f f08a24","water":"25637d 3f8fb0 a9d6ea","stone":"5b6470 8b8f96 c9c5bc","extra":"f2e4c0 fff3c8 f5b860"}
rgb=lambda h:np.array([int(h[i:i+2],16) for i in (0,2,4)],float)
F={k:[rgb(h) for h in v.split()] for k,v in F.items()}
P=[c for v in F.values() for c in v]
for v in F.values():            # in-family midpoints
    for a,b in zip(v,v[1:]): P.append((a+b)/2)
X=[("soil","gold"),("soil","stone"),("moss","soil"),("water","stone"),("gold","moss"),("soil","ember")]
for a,b in X:
    for ca in F[a]:
        for cb in F[b]: P.append((ca+cb)/2)
pal=np.unique(np.array(P).round(),axis=0)
def lab(c):
    c=c/255; c=np.where(c>.04045,((c+.055)/1.055)**2.4,c/12.92)
    M=np.array([[.4124,.3576,.1805],[.2126,.7152,.0722],[.0193,.1192,.9505]]);xyz=c@M.T/np.array([.9505,1,1.089])
    f=np.where(xyz>.008856,np.cbrt(xyz),7.787*xyz+16/116)
    return np.stack([116*f[...,1]-16,500*(f[...,0]-f[...,1]),200*(f[...,1]-f[...,2])],-1)
pl=lab(pal); print(len(pal),"colours")
B=np.array([[0,8,2,10],[12,4,14,6],[3,11,1,9],[15,7,13,5]])/16-.5
for f in sorted(glob.glob(sys.argv[1]+"/*.png")):
    a=255*(np.asarray(Image.open(f).convert("RGB"),float)/255)**0.8
    h,w,_=a.shape; t=np.tile(B,(h//4+1,w//4+1))[:h,:w,None]*14
    l=lab(np.clip(a+t,0,255)); i=((l[:,:,None,:]-pl[None,None])**2).sum(3).argmin(2)
    Image.fromarray(pal[i].astype(np.uint8)).save(sys.argv[2]+"/"+f.split("/")[-1])
