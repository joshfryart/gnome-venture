import os,sys,hashlib,json,collections
from PIL import Image
root='/home/user/gnome-venture/game/assets/img'
sets={'pals':'pals','perch':'pals/perch','puzzles_pals':'puzzles/pals'}
out={}
names={}
for k,d in sets.items():
    rows=[]
    for f in sorted(os.listdir(f'{root}/{d}')):
        p=f'{root}/{d}/{f}'
        if not os.path.isfile(p): continue
        if not f.endswith('.png'): rows.append(dict(f=f,other=True));continue
        im=Image.open(p); mode=im.mode; w,h=im.size
        rgba=im.convert('RGBA'); px=rgba.getdata()
        cols=len(set(px)); opaque=sum(1 for a in px if a[3]==255); semi=sum(1 for a in px if 0<a[3]<255)
        bbox=rgba.getchannel('A').getbbox()
        rows.append(dict(f=f,w=w,h=h,mode=mode,bytes=os.path.getsize(p),colors=cols,semi=semi,
          bbox=bbox,empty=bbox is None,sha=hashlib.sha256(open(p,'rb').read()).hexdigest()))
    out[k]=rows; names[k]={r['f'] for r in rows if not r.get('other')}
res={}
for k,rows in out.items():
    R=[r for r in rows if 'w' in r]
    res[k]=dict(n=len(R),bytes=sum(r['bytes'] for r in R),
      sizes=collections.Counter(f"{r['w']}x{r['h']}" for r in R).most_common(8),
      modes=collections.Counter(r['mode'] for r in R),
      maxcolors=max(r['colors'] for r in R),medcolors=sorted(r['colors'] for r in R)[len(R)//2],
      semi_files=sum(1 for r in R if r['semi']>0),empty=[r['f'] for r in R if r['empty']],
      dupgroups=[g for g in (lambda c:[[x['f'] for x in R if x['sha']==s] for s,n in c.items() if n>1])(collections.Counter(r['sha'] for r in R))],
      biggest=sorted([(r['bytes'],r['f']) for r in R])[-3:],
      nonpng=[r['f'] for r in rows if r.get('other')])
a,b,c=names['pals'],names['perch'],names['puzzles_pals']
res['parity']=dict(pals_not_perch=sorted(a-b),perch_not_pals=sorted(b-a),pals_not_puzzles=sorted(a-c),puzzles_not_pals=sorted(c-a))
json.dump(res,open('/tmp/claude-0/-home-user-gnome-venture/cc3d4c9b-a800-56ef-8027-195f85f30c2e/scratchpad/pals_scan.json','w'),indent=1,default=list)
print(json.dumps(res,indent=1,default=list)[:6000])
