"""Build per-pal inputs for the redraw: pals.json plus source picture and cell crops under art-review/redo/_src/."""
import json,re,os
from PIL import Image
G='/home/user/gnome-venture/game'; O='/home/user/gnome-venture/art-review/redo'
pals=[]
for ln in open(G+'/includes/data/puzzle_pals.txt',encoding='utf-8'):
    if ln.startswith('#') or not ln.strip(): continue
    c=ln.rstrip('\n').split('|')
    pic,key,name,rar,call,gr,ni,ha,lu,piece,shape,knob,perk,blurb=c
    pals.append(dict(pic=pic,key=key,name=name,rarity=rar,calling=call,piece=piece,shape=shape,knob=knob,blurb=blurb))
def src(pic):
    if pic.startswith('pl-'):
        k=re.sub(r'-[0-9a-f]{6}$','',pic[3:]); return f'{G}/assets/img/jigsaw/places/{k}.png',k
    return f'{G}/assets/img/jigsaw/{pic}.jpg',pic
done={'sp-saffron-snip','sp-yak-yonder','sp-chilli-chime','sp-stupa-snug','sp-teal-ferry','sp-lofty-kite'}
out=[];miss=[]
for p in pals:
    f,k=src(p['pic'])
    if not os.path.isfile(f): miss.append((p['key'],f)); continue
    im=Image.open(f).convert('RGB'); W,H=im.size
    pic_out=f'{O}/_src/{k}-pic.png'
    if not os.path.isfile(pic_out): im.resize((540,360),Image.LANCZOS).save(pic_out)
    c,r=map(int,p['piece'].split('-')); cw,ch=W/12,H/8
    cell=im.crop((round(c*cw),round(r*ch),round((c+1)*cw),round((r+1)*ch)))
    s=max(1,240//max(cell.size)); cell=cell.resize((cell.width*s,cell.height*s),Image.NEAREST) if cell.width<240 else cell.resize((240,round(240*cell.height/cell.width)),Image.LANCZOS)
    cell.save(f"{O}/_src/{p['key']}-cell.png")
    p['picfile']=f'art-review/redo/_src/{k}-pic.png'; p['cellfile']=f"art-review/redo/_src/{p['key']}-cell.png"
    p['oldsticker']=f"game/assets/img/puzzles/pals/{p['key']}.png"; p['oldyard']=f"game/assets/img/pals/{p['key']}.png"; p['oldperch']=f"game/assets/img/pals/perch/{p['key']}.png"
    p['pilot']=p['key'] in done; out.append(p)
json.dump(out,open(O+'/pals.json','w'),indent=0)
print(len(pals),len(out),'missing',miss[:5],len(miss),'todo',sum(1 for p in out if not p['pilot']))
import collections; print(collections.Counter(p['shape'].split('-')[0] for p in out), collections.Counter(p['knob'] for p in out))
