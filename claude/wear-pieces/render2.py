#!/usr/bin/env python3
"""Hand-size piece picture (132x92) with the ITEM art as the icon (64x64 -> 32x32, darkest-pixel block reduce keeps the ink outline). -> img/piece-<REGION>-<cat>-<n>.png"""
import json, os, glob
from PIL import Image
P='/home/user/gnome-venture/game/assets/img/pfight/parts/'
A=json.load(open(P+'atlas.json')); RIM=json.load(open(P+'rim.json'))['palettes']['default']
ROLE={v['id']:k for k,v in json.load(open(P+'rim.json'))['roles'].items()}
SH=A['sheets']['hand-me']; CW,CH=A['sizes']['hand']['piece']
sheet=Image.open(P+SH['file']).convert('RGBA'); pat=Image.open(P+'patterns-hand.png').convert('RGBA')
TYPES=A['types']; HOLE={'hurt':'body','guard':'body','heal':'mind','charm':'mind','soothe':'mind','trick':'craft','item':'craft'}; UP={'hurt','charm','trick'}
ART='/home/user/gnome-venture/aseprite-source/v3/art-wear-concepts'
def cell(c,r): return sheet.crop((c*CW,r*CH,c*CW+CW,r*CH+CH))
def index(edges):
    img=cell(SH['base']['col'],SH['base']['row']); px=img.load()
    for side,(kind,fam) in edges.items():
        st=SH['stamps'][f'{side}:{kind}:{fam}']; sc=cell(st['col'],st['row']).load()
        for y in range(CH):
            for x in range(CW):
                r,g,b,a=sc[x,y]
                if a>0: px[x,y]=(0,0,0,0) if r==255 else (r,0,0,255)
    return img
FONT={'0':'111101101101111','1':'010110010010111','2':'111001111100111','3':'111001111001111','4':'101101111001001','5':'111100111001111','6':'111100111101111','7':'111001001001001','8':'111101111101111','9':'111101111001111'}
def digits(img,n,at,size):
    s=str(n); w=len(s)*4-1; x0=at[0]+(size[0]-w)//2; y0=at[1]+(size[1]-5)//2
    for i,ch in enumerate(s):
        for k,bit in enumerate(FONT[ch]):
            if bit=='1': img.putpixel((x0+i*4+k%3,y0+k//3),(42,26,16,255))
def reduce(item):
    im=item.convert('RGBA'); bb=im.getbbox(); im=im.crop(bb); w,h=im.size
    s=max(w,h); sq=Image.new('RGBA',(s,s),(0,0,0,0)); sq.paste(im,((s-w)//2,(s-h)//2))
    k=s/32; out=Image.new('RGBA',(32,32),(0,0,0,0)); sp=sq.load(); op=out.load()
    for y in range(32):
        for x in range(32):
            pts=[sp[xx,yy] for yy in range(int(y*k),max(int(y*k)+1,int((y+1)*k))) for xx in range(int(x*k),max(int(x*k)+1,int((x+1)*k))) if xx<s and yy<s]
            op_=[p for p in pts if p[3]>0]
            if len(op_)*2>=len(pts) and op_:
                op[x,y]=min(op_,key=lambda p:p[0]*3+p[1]*5+p[2])[:3]+(255,) if len(op_)<len(pts)*0.9 or True else op_[0]
    return out
def piece_image(ty,knob,v,rarity,item_png):
    up=ty in UP; col='body'
    edges={'L':('hole',HOLE[ty]),'R':('knob',{'b':'body','m':'mind','c':'craft'}[knob]),'T':('knob' if up else 'hole',col),'B':('hole' if up else 'knob',col)}
    idx=index(edges); t=TYPES[ty]; ti=A['patterns']['hand']['order'].index(ty)
    pm=pat.crop((ti*CW,0,ti*CW+CW,CH)).load(); ip=idx.load(); out=Image.new('RGBA',(CW,CH),(0,0,0,0)); op=out.load()
    for y in range(CH):
        for x in range(CW):
            r,g,b,a=ip[x,y]
            if a==0: continue
            if 1<=r<=10: c=RIM[ROLE[r]]
            elif r==11: c=t['mark'] if pm[x,y][0]==255 and pm[x,y][3] else t['base']
            elif r==12: c=t['shade']
            elif r==13: c=t['light']
            elif r==14: c=t['base']
            else: c=(255,0,255)
            op[x,y]=tuple(c)+(255,)
    # item art on a cream medallion so it reads on any type colour
    cx,cy=55,25
    med=Image.new('RGBA',(32,32),(0,0,0,0)); mp=med.load()
    for y in range(32):
        for x in range(32):
            d=((x-15.5)**2+(y-15.5)**2)**.5
            if d<=16: mp[x,y]=(42,26,16,255) if d>15 else (242,228,192,255)
    out.alpha_composite(med,(cx,cy)); out.alpha_composite(reduce(Image.open(item_png)),(cx,cy))
    digits(out,v,(39,15),(14,12))
    rp=P+f'marks/rarity-{rarity}.png'
    if os.path.exists(rp): out.alpha_composite(Image.open(rp).convert('RGBA'),(100,18))
    return out
if __name__=='__main__':
    os.makedirs('img',exist_ok=True)
    for x in json.load(open('pieces.json')):
        ip=glob.glob(f"{ART}/{x['region']}/{x['cat']}-{x['n']}-*.png")[0]
        piece_image(x['type'],x['knob'],x['v'],{'Common':0,'Uncommon':1,'Rare':2}[x['rarity']],ip).save(f"img/piece-{x['region']}-{x['cat']}-{x['n']}.png")
    print('rendered')
