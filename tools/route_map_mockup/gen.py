import json,base64,io,sys
from PIL import Image
G='/home/user/gnome-venture/game/'
S='/tmp/claude-0/-home-user-gnome-venture/7812d112-b596-57f4-9049-767f85e5c2f4/scratchpad/'
L=json.load(open(S+'layout.json'))['regions']
R=json.load(open(G+'includes/data/trail_maps.json'))['routes']
regs={x['code']:x for x in L}
names={}
for x in L:
    names[x['town']['name']]=x['code']
    for s in x['stops']: names[s['name']]=x['code']
# region gnomish names
gn={}
for ln in open(G+'includes/data/regions.txt'):
    if ln.startswith('#') or '|' not in ln: continue
    p=ln.strip().split('|'); gn[p[0]]=p[1]
def b64(img,fmt,**kw):
    b=io.BytesIO(); img.save(b,fmt,**kw); return 'data:image/%s;base64,'%('jpeg' if fmt=='JPEG' else 'png')+base64.b64encode(b.getvalue()).decode()
order=[x['code'] for x in L]
byreg={c:[] for c in order}
def nodes(x): return {x['town']['name']}|{q['name'] for q in x['stops']}
adj={}
for x in L:
    pos={x['town']['name']:(x['town']['x'],x['town']['y'])}
    for q in x['stops']: pos[q['name']]=(q['x'],q['y'])
    inv={tuple(v):k for k,v in pos.items()}
    st=set()
    for r in x['roads']:
        ns=[inv.get(tuple(p)) for p in r['pts']]
        for i in range(len(ns)-1):
            if ns[i] and ns[i+1]: st.add((ns[i],ns[i+1]))
    for t in x['trails']:
        a_,b_=inv.get(tuple(t[0])),inv.get(tuple(t[-1]))
        if a_ and b_: st.add((a_,b_))
    adj[x['code']]=st
amb=0;last=0
for rid in sorted(R,key=int):
    r=R[rid]; c=[o for o in order if (r['from'],r['to']) in adj[o] or (r['to'],r['from']) in adj[o]]
    if not c: c=[o for o in order if r['from'] in nodes(regs[o])]
    if len(c)>1: amb+=1
    if c:
        fw=[o for o in c if order.index(o)>=last]; pick=(fw or c)[0]; last=order.index(pick); byreg[pick].append(rid)
    else: print('nomatch',rid,r['from'],r['to'],file=sys.stderr)
print('amb',amb,file=sys.stderr)
out=[]; miss=[]
for code,x in regs.items():
    pos={x['town']['name']:(x['town']['x'],x['town']['y'])}
    for s in x['stops']: pos[s['name']]=(s['x'],s['y'])
    roads=[{'name':r['name'],'to':r['to'],'pts':r['pts']} for r in x['roads']]
    # consecutive pts per road → segment lookup
    seg={}
    for r in x['roads']:
        pts=r['pts']; ns=[]
        for i,p in enumerate(pts):
            nm=next((k for k,v in pos.items() if tuple(v)==tuple(p)),None)
            ns.append(nm)
        for i in range(len(pts)-1):
            if ns[i] and ns[i+1]: seg[(ns[i],ns[i+1])]=[pts[i],pts[i+1]]
    for e in x['exits']: pass
    trails={}
    routes=[]
    for rid in byreg[code]:
        r=R[rid]
        a,b=r['from'],r['to']
        if (a,b) in seg: path=seg[(a,b)]
        elif (b,a) in seg: path=seg[(b,a)][::-1]
        elif a in pos and b in pos: path=[list(pos[a]),list(pos[b])]
        else:
            # cross-region: use the exit of the road toward that region
            tc=names.get(b); ex=next((e for e in x['exits'] if e['to']==tc),None)
            if a in pos and ex: path=[list(pos[a]),[ex['x'],ex['y']]]
            else: miss.append((rid,a,b)); continue
        im=Image.open(G+'assets/img/trail/ground/%s-1.png'%rid)
        secs=[]
        for k in range(1,len(r['sections'])+1):
            im=Image.open(G+'assets/img/trail/ground/%s-%d.png'%(rid,k)).convert('RGB').resize((264,92),Image.LANCZOS)
            secs.append(b64(im,'JPEG',quality=45))
        routes.append({'id':rid,'from':a,'to':b,'land':r['land'],'boss':r['boss'],'path':path,'secs':secs,'feat':[s.get('feature','') for s in r['sections']]})
    mp=Image.open(G+'assets/img/scenes/map-%s.png'%code).convert('RGB')
    out.append({'code':code,'name':gn.get(code,code),'map':b64(mp,'JPEG',quality=70),'town':x['town'],'stops':[{'name':s['name'],'x':s['x'],'y':s['y'],'kind':s['kind'],'type':s['type']} for s in x['stops']],'roads':roads,'trails':x['trails'],'exits':x['exits'],'routes':routes})
print('miss',len(miss),miss[:5],file=sys.stderr)
json.dump(out,open(S+'data.json','w'),separators=(',',':'))
import os; print(os.path.getsize(S+'data.json')/1e6,'MB',sum(len(o['routes']) for o in out),'routes',file=sys.stderr)
