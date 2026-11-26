import os,re,json,collections
G='/home/user/gnome-venture/game'; IMG=G+'/assets/img'
S='/tmp/claude-0/-home-user-gnome-venture/cc3d4c9b-a800-56ef-8027-195f85f30c2e/scratchpad/'
src=[]
for dp,dn,fs in os.walk(G):
    if dp.startswith(IMG) or '/uploads' in dp or '/vendor' in dp: continue
    for f in fs:
        if f.rsplit('.',1)[-1] in('php','js','css','json','txt','html','md','svg','xml','py'):
            try: src.append((os.path.relpath(dp+'/'+f,G),open(dp+'/'+f,errors='ignore').read()))
            except: pass
# also tools/ at repo root
corpus='\n'.join(t for _,t in src)
print('source files',len(src),'bytes',len(corpus))
assets=[os.path.relpath(dp+'/'+f,IMG) for dp,_,fs in os.walk(IMG) for f in fs if f.rsplit('.',1)[-1] in('png','svg','jpg','gif','webp')]
aset=set(assets)
# tokens
tok=set(re.findall(r'[A-Za-z0-9_\-\.]+',corpus))
stems=lambda r:re.sub(r'\.[a-z]+$','',r.split('/')[-1])
paths=set(re.findall(r'[A-Za-z0-9_\-\./]+\.(?:png|svg|jpg|gif|webp)',corpus))
tiers={}
prefix=set()
for t_ in tok:
    for m in re.finditer(r'[-_]',t_):
        if m.end()>=3: prefix.add(t_[:m.end()])
dirs={}
for d in {a.rsplit('/',1)[0] for a in assets if '/' in a}:
    dirs[d]=(d+'/' in corpus) or (d.split('/')[0]+'/' in corpus)
pathtail=set(); 
for p in paths:
    pathtail.add(p); pathtail.add(p.split('/')[-1])
for a in assets:
    s=stems(a); base=a.split('/')[-1]
    if a in pathtail or base in pathtail or base in tok or s in tok: t='A'
    else:
        t='C'; parts=re.split(r'(?<=[-_])',s)
        for i in range(len(parts)-1,0,-1):
            pre=''.join(parts[:i])
            if len(pre)>=3 and pre in prefix: t='B';break
        if t=='C' and dirs.get(a.rsplit('/',1)[0] if '/' in a else '',False): t='D'
    tiers[a]=t
c=collections.Counter(tiers.values()); print(c)
fam=collections.defaultdict(collections.Counter)
for a,t in tiers.items():
    k=a.split('/')[0] if '/' in a else '(root)'; fam[k][t]+=1
# missing literal refs
miss=collections.defaultdict(set)
for f,t in src:
    for m in re.finditer(r"[\"'(]((?:[A-Za-z0-9_\-\./]*?)([A-Za-z0-9_\-]+)\.(?:png|svg|jpg|gif|webp))[\"')]",t):
        p=m.group(1)
        if '$' in p or '{' in p: continue
        q=re.sub(r'^.*?assets/img/','',p) if 'assets/img/' in p else p
        q=q.lstrip('./')
        if q in aset: continue
        cands=[q,'ph/'+q.split('/')[-1]]
        if not any(x in aset for x in cands): miss[q].add(f)
print('literal refs not found',len(miss))
json.dump(dict(tiers=tiers,miss={k:sorted(v) for k,v in miss.items()}),open(S+'refs.json','w'))
for k,v in sorted(fam.items(),key=lambda x:-x[1]['C']-x[1]['D'])[:25]: print(k,dict(v))
print(sorted(miss.items(),key=lambda x:x[0])[:60])
