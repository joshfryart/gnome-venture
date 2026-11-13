import sys, json, math
from PIL import Image
from collections import Counter
def lab(c):
    def f(v):
        v/=255; v=v/12.92 if v<=.04045 else ((v+.055)/1.055)**2.4; return v
    r,g,b=map(f,c); x=(.4124*r+.3576*g+.1805*b)/.95047; y=.2126*r+.7152*g+.0722*b; z=(.0193*r+.1192*g+.9505*b)/1.08883
    g_=lambda t: t**(1/3) if t>.008856 else 7.787*t+16/116
    fx,fy,fz=g_(x),g_(y),g_(z); return (116*fy-16,500*(fx-fy),200*(fy-fz))
def de(a,b): return math.dist(lab(a),lab(b))
def cluster(cnt,target):
    cols={c:n for c,n in cnt.items()}; mp={c:c for c in cols}
    while len(cols)>target:
        best=None
        ks=list(cols)
        for i,a in enumerate(ks):
            for b in ks[i+1:]:
                d=de(a,b); cost=d*math.sqrt(min(cols[a],cols[b]))
                if best is None or cost<best[0]: best=(cost,a,b,d)
        _,a,b,d=best
        lo,hi=(a,b) if cols[a]<=cols[b] else (b,a)
        cols[hi]+=cols[lo]; del cols[lo]
        for k,v in mp.items():
            if v==lo: mp[k]=hi
    return mp
def hx(c): return '#%02x%02x%02x'%c[:3]
def stats(im,mp):
    px=[p for p in im.getdata() if p[3]==255]
    ds=[de(p[:3],mp[p[:3]]) for p in px]
    return dict(mean=sum(ds)/len(ds), p99=sorted(ds)[int(len(ds)*.99)], max=max(ds), changed=sum(1 for d in ds if d>0)/len(ds), over3=sum(1 for d in ds if d>3)/len(ds))
if __name__=='__main__':
    src=sys.argv[1]; jobs=[('cf-room',48),('cf-room-toybox',24),('cf-badge-book_half',28),('cf-badge-book_full',28)]
    maps={}
    for name,t in jobs:
        im=Image.open(f'{src}/{name}.png').convert('RGBA')
        cnt=Counter(p[:3] for p in im.getdata() if p[3]==255)
        mp=cluster(cnt,t); st=stats(im,mp)
        print(name,len(cnt),'->',len(set(mp.values())),{k:round(v,3) for k,v in st.items()})
        maps[name]={hx(k):hx(v) for k,v in mp.items() if k!=v}
        if name=='cf-room':
            maps['cf-room-yarnpatch']=maps[name]
            for cap in (24,):
                m2=cluster(cnt,cap); s2=stats(im,m2); print(' cap',cap,{k:round(v,3) for k,v in s2.items()})
    with open('maps.lua','w') as f:
        f.write('return {\n')
        for n,m in maps.items():
            f.write(' [%s] = {%s},\n'%(json.dumps(n),', '.join('[%s]=%s'%(json.dumps(k),json.dumps(v)) for k,v in m.items())))
        f.write('}\n')
