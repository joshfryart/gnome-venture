#!/usr/bin/env python3
"""Compose the strip-size piece picture of each wearable piece from game/assets/img/pfight/parts (README algorithm). -> img/piece-<REGION>-<cat>-<n>.png (74x52)."""
import json, os
from PIL import Image
P='/home/user/gnome-venture/game/assets/img/pfight/parts/'
A=json.load(open(P+'atlas.json')); RIM=json.load(open(P+'rim.json'))['palettes']['default']
ROLE={v['id']:k for k,v in json.load(open(P+'rim.json'))['roles'].items()}
SH=A['sheets']['strip-me']; CW,CH=A['sizes']['strip']['piece']
sheet=Image.open(P+SH['file']).convert('RGBA'); pat=Image.open(P+'patterns-strip.png').convert('RGBA'); icons=Image.open(P+'icons-strip.png').convert('RGBA')
TYPES=A['types']; HOLE={'hurt':'body','guard':'body','heal':'mind','charm':'mind','soothe':'mind','trick':'craft','item':'craft'}; UP={'hurt','charm','trick'}
def cell(c,r): return sheet.crop((c*CW,r*CH,c*CW+CW,r*CH+CH))
def index(edges):
    b=SH['base']; img=cell(b['col'],b['row'])
    px=img.load()
    for side,(kind,fam) in edges.items():
        st=SH['stamps'][f'{side}:{kind}:{fam}']; sc=cell(st['col'],st['row']).load()
        for y in range(CH):
            for x in range(CW):
                r,g,bb,a=sc[x,y]
                if a>0: px[x,y]=(0,0,0,0) if r==255 else (r,0,0,255)
    return img
FONT={'0':'111101101101111','1':'010110010010111','2':'111001111100111','3':'111001111001111','4':'101101111001001','5':'111100111001111','6':'111100111101111','7':'111001001001001','8':'111101111101111','9':'111101111001111'}
def digits(img,n,at,size):
    s=str(n); w=len(s)*4-1; x0=at[0]+(size[0]-w)//2; y0=at[1]+(size[1]-5)//2
    for i,ch in enumerate(s):
        for k,bit in enumerate(FONT[ch]):
            if bit=='1': img.putpixel((x0+i*4+k%3,y0+k//3),(42,26,16,255))
def piece_image(ty,knob,v,tag,mod,rarity):
    up=ty in UP; col='body'
    edges={'L':('hole',HOLE[ty]),'R':('knob',{'b':'body','m':'mind','c':'craft'}[knob]),'T':('knob' if up else 'hole',col),'B':('hole' if up else 'knob',col)}
    idx=index(edges); t=TYPES[ty]; ti=A['patterns']['strip']['order'].index(ty)
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
    ic=icons.crop((ti*20,0,ti*20+20,20))
    out.alpha_composite(ic,(30,19)); digits(out,v,(14,8),(12,10))
    def mark(path,at):
        if os.path.exists(path): out.alpha_composite(Image.open(path).convert('RGBA'),at)
    if tag not in('-',): mark(P+f'marks/tag-{tag}.png',(13,32))
    if mod!='-': mark(P+f'marks/mod-{mod}.png',(49,32))
    mark(P+f'marks/rarity-{rarity}.png',(54,8))
    return out
if __name__=='__main__':
    os.makedirs('img',exist_ok=True)
    for x in json.load(open('pieces.json')):
        im=piece_image(x['type'],x['knob'],x['v'],x['tag'],x['mod'],{'Common':0,'Uncommon':1,'Rare':2}[x['rarity']])
        im.save(f"img/piece-{x['region']}-{x['cat']}-{x['n']}.png")
    print('rendered')
