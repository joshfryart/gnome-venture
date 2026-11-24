#!/usr/bin/env python3
"""Pixel menu icons for the dock mockup. 16x16, hard pixels, 1 px umber outline added automatically.
Run: python3 gen_nav_icons.py   -> nav-<slug>.png (16x16), nav-<slug>@2x.png (32x32), contact.html, icons.json (data URIs)
Draw only the fills inside x,y = 1..14; the outline is the dilation of the filled pixels."""
import base64, io, json, os
from PIL import Image
PAL = dict(k='#2a1a10', w='#fffaf0', c='#f2e4c0', r='#d6452f', R='#a8241f', o='#e8a317', y='#f6cf5a', g='#5f9a47', G='#2f5a2a',
           l='#8fc267', b='#4a8cc0', B='#2f5f8a', s='#a9d6ea', n='#a27e55', N='#6b4a2e', t='#f0b88a', T='#d69a6a', p='#e88aab',
           P='#4e3a8a', e='#a89c8c', E='#6f6558')
class Ico:
    def __init__(s): s.g = [[None]*16 for _ in range(16)]
    def P(s,x,y,c): s.g[y][x] = None if c == '.' else c
    def R(s,x,y,w,h,c):
        for j in range(h):
            for i in range(w): s.P(x+i,y+j,c)
    def H(s,y,x0,x1,c): s.R(x0,y,x1-x0+1,1,c)
    def pts(s,c,*xy):
        for x,y in xy: s.P(x,y,c)
    def image(s):
        g = s.g; out = [[None]*16 for _ in range(16)]
        for y in range(16):
            for x in range(16):
                if g[y][x]: out[y][x] = g[y][x]
        for y in range(16):
            for x in range(16):
                if g[y][x] is None:
                    for dx,dy in ((1,0),(-1,0),(0,1),(0,-1)):
                        xx,yy = x+dx,y+dy
                        if 0 <= xx < 16 and 0 <= yy < 16 and g[yy][xx]: out[y][x] = 'k'; break
        im = Image.new('RGBA',(16,16),(0,0,0,0))
        for y in range(16):
            for x in range(16):
                c = out[y][x]
                if c: h = PAL[c].lstrip('#'); im.putpixel((x,y),(int(h[0:2],16),int(h[2:4],16),int(h[4:6],16),255))
        return im
I = {}
def new(slug):
    I[slug] = Ico(); return I[slug]

# ---- main menus
a = new('you')            # gnome head
for y,(x0,x1,c) in enumerate([(7,8,'r'),(6,9,'r'),(5,10,'r'),(5,10,'r')],1): a.H(y,x0,x1,c)
a.P(7,2,'p'); a.H(5,3,12,'R'); a.H(3,10,10,'R'); a.H(4,10,10,'R')
a.R(4,6,8,3,'t'); a.pts('k',(6,7),(9,7)); a.pts('T',(7,8),(8,8))
a.H(9,4,11,'w'); a.H(10,4,11,'w'); a.H(11,5,10,'w'); a.H(12,6,9,'w'); a.H(13,7,8,'c')
a.pts('c',(11,9),(11,10),(10,11),(9,12))
a = new('hobby')          # watering can
a.R(4,7,7,6,'b'); a.R(10,8,1,5,'B'); a.H(12,4,10,'B'); a.H(7,4,10,'s'); a.pts('s',(5,8),(5,9))
a.pts('E',(11,6),(12,6),(13,7),(13,8),(13,9),(13,10),(12,11),(11,11))
a.pts('b',(3,10),(3,11),(2,9),(2,8),(1,7)); a.H(5,1,3,'s'); a.H(6,1,3,'B')
a.pts('s',(6,3),(7,2),(5,3)) if False else None
a.pts('c',(12,2),(13,3),(11,3)) if False else None
a.pts('s',(1,4),(3,4),(2,3))
a = new('out')            # signpost
a.R(7,2,2,13,'n'); a.R(8,2,1,13,'N')
a.R(2,3,10,3,'c'); a.pts('c',(12,4),(13,4)); a.pts('c',(12,3),(12,5)) if False else None; a.pts('N',(4,4),(6,4),(8,4))
a.R(4,8,10,3,'c'); a.pts('c',(3,9),(2,9)); a.pts('N',(7,9),(9,9),(11,9))
a.H(5,2,11,'e'); a.H(10,4,13,'e')
a = new('tog')            # hearth fire
for y,(x0,x1) in {3:(8,8),4:(7,8),5:(7,9),6:(6,9),7:(5,10),8:(5,10),9:(4,11),10:(4,11),11:(5,10)}.items(): a.H(y,x0,x1,'o')
a.pts('r',(8,3),(7,4)) ; a.H(7,7,8,'y'); a.H(8,6,9,'y'); a.H(9,6,9,'y'); a.H(10,6,9,'y'); a.H(11,7,8,'y')
a.R(2,12,12,2,'N'); a.H(12,2,13,'n'); a.pts('N',(6,12),(9,12))
# ---- you tiles
a = new('hovel')
for y,(x0,x1) in {2:(7,8),3:(6,9),4:(5,10),5:(4,11),6:(3,12),7:(2,13)}.items(): a.H(y,x0,x1,'r')
a.H(7,2,13,'R'); a.R(10,2,2,3,'e'); a.pts('E',(11,2),(11,3),(11,4))
a.R(3,8,10,6,'c'); a.R(12,8,1,6,'T'); a.R(7,10,2,4,'N'); a.P(7,10,'n'); a.R(4,9,2,2,'s'); a.R(10,9,2,2,'s'); a.H(14,2,13,'e') if False else None
a = new('almanac')
a.R(2,4,6,8,'w'); a.R(8,4,6,8,'w'); a.R(7,4,2,8,'c'); a.R(1,12,14,2,'G'); a.H(12,1,14,'g')
for yy in (6,8,10): a.H(yy,3,6,'e'); a.H(yy,9,12,'e')
a.R(8,12,1,3,'r'); a.pts('r',(8,14))
a = new('satchel')
a.R(3,6,10,8,'n'); a.R(12,7,1,7,'N'); a.H(13,3,12,'N'); a.R(3,4,10,4,'N'); a.H(4,3,12,'n'); a.pts('N',(5,3),(10,3)) ; a.R(5,2,6,1,'N')
a.pts('N',(4,3),(11,3)) if False else None
a.R(7,7,2,2,'o'); a.P(7,7,'y'); a.pts('c',(4,10),(6,10),(9,10),(11,10))
a = new('crafting')       # hammer
a.R(2,2,11,4,'e'); a.H(2,2,12,'w'); a.H(5,2,12,'E'); a.R(12,3,2,2,'E'); a.pts('e',(1,3),(1,4))
a.R(6,6,3,8,'n'); a.R(8,6,1,8,'N'); a.R(6,13,3,1,'N')
a = new('tailor')         # thread spool + needle
a.R(4,2,8,2,'N'); a.H(2,4,11,'n'); a.R(5,4,6,8,'p'); a.R(9,4,2,8,'R') ; a.R(5,4,1,8,'w') if False else None
a.H(6,5,10,'c'); a.H(9,5,10,'c'); a.R(4,12,8,2,'N'); a.H(12,4,11,'n')
a.R(13,3,1,9,'e'); a.P(13,2,'w'); a.P(13,12,'E')
a = new('start')          # sprout with sparkle
a.R(7,7,2,7,'g'); a.pts('G',(8,8),(8,9),(8,10),(8,11),(8,12),(8,13))
a.H(5,4,6,'l'); a.H(6,3,7,'g'); a.H(7,5,6,'G'); a.H(4,10,12,'l'); a.H(5,9,13,'g'); a.H(6,9,10,'G')
a.H(14,5,10,'N'); a.pts('y',(12,1),(12,2),(12,3),(11,2),(13,2))
a = new('account')        # gold cog
a.R(6,1,4,2,'o'); a.R(6,13,4,2,'o'); a.R(1,6,2,4,'o'); a.R(13,6,2,4,'o')
for x,y in ((3,3),(11,3),(3,11),(11,11)): a.R(x,y,2,2,'o')
a.R(4,3,8,10,'o'); a.R(3,4,10,8,'o'); a.R(6,6,4,4,'.'); a.H(3,6,9,'y'); a.H(4,4,5,'y'); a.R(4,5,1,2,'y'); a.R(11,5,1,8,'N'); a.H(12,4,11,'N'); a.pts('N',(13,8),(8,14),(13,7))
# ---- hobbies tiles
a = new('garden')
a.R(1,11,14,3,'N'); a.H(11,1,14,'n')
a.R(7,5,2,6,'g'); a.pts('l',(5,7),(6,7),(4,6),(10,8),(11,8),(11,7)); a.pts('g',(5,8),(6,8),(9,9),(10,9))
a.pts('p',(7,2),(8,2),(6,3),(9,3),(7,4),(8,4)); a.pts('y',(7,3),(8,3))
a = new('games')          # red die, three quarter view
a.R(2,6,9,8,'r'); a.H(3,5,13,'p'); a.H(4,4,13,'p'); a.H(5,3,12,'p'); a.R(11,6,3,8,'R'); a.R(12,5,2,1,'R'); a.H(13,2,13,'R')
a.pts('w',(4,8),(8,8),(6,10),(4,12),(8,12)); a.pts('w',(12,8),(12,11)) if False else None
a = new('pals')           # puzzle piece with a face
a.R(4,5,8,8,'l'); a.R(6,2,4,3,'l'); a.R(12,7,2,4,'l'); a.R(11,5,1,8,'g'); a.H(12,4,11,'g'); a.pts('g',(13,8),(13,9),(13,10))
a.pts('.',(4,7),(4,8),(4,9)); a.pts('.',(3,7)) if False else None
a.pts('k',(7,8),(10,8)); a.pts('k',(7,10),(8,11),(9,11),(10,10)); a.pts('w',(6,6),(7,6)) if False else None
a = new('box')            # box with a puzzle piece on it
a.R(2,6,12,8,'n'); a.R(13,6,1,8,'N'); a.H(13,2,13,'N'); a.R(1,4,14,3,'N'); a.H(4,1,14,'n')
a.R(6,9,4,3,'y'); a.R(7,8,2,1,'y'); a.pts('o',(9,11),(9,10))
# ---- out tiles
a = new('world')          # globe
for y,(x0,x1) in {2:(5,10),3:(4,11),4:(3,12),5:(2,13),6:(2,13),7:(2,13),8:(2,13),9:(2,13),10:(2,13),11:(3,12),12:(4,11),13:(5,10)}.items(): a.H(y,x0,x1,'b')
a.R(4,4,3,3,'g'); a.R(8,6,4,3,'g'); a.R(5,9,3,2,'g'); a.H(10,12,12,'B') if False else None
a.R(12,5,1,6,'B'); a.H(12,5,10,'B'); a.pts('s',(3,5),(4,3))
a = new('here')           # map pin
for y,(x0,x1) in {1:(6,9),2:(5,10),3:(4,11),4:(4,11),5:(4,11),6:(4,11),7:(5,10),8:(5,10),9:(6,9),10:(6,9),11:(7,8),12:(7,8)}.items(): a.H(y,x0,x1,'r')
a.R(7,4,2,2,'w'); a.R(10,3,1,5,'R'); a.pts('R',(9,9),(8,11),(8,12)); a.H(14,4,11,'E')
a = new('villagers')      # two villagers
a.R(1,5,5,5,'T'); a.H(4,1,5,'N'); a.R(0+1,10,6,4,'B'); a.pts('k',(2,7),(4,7))
a.R(7,3,7,6,'t'); a.H(2,7,13,'n'); a.R(7,3,1,3,'n'); a.R(13,3,1,3,'n'); a.R(6,10,9,4,'b'); a.pts('k',(9,6),(11,6)); a.pts('T',(10,8),(11,8))
a = new('gourmand')       # chef hat
for y,(x0,x1) in {2:(5,10),3:(3,12),4:(3,12),5:(4,11)}.items(): a.H(y,x0,x1,'w')
a.R(5,6,6,5,'w'); a.R(10,6,1,5,'c'); a.R(5,11,6,3,'c'); a.H(11,5,10,'e'); a.pts('c',(11,3),(11,4),(12,3),(12,4))
a = new('treks')          # boot
a.R(4,2,5,8,'N'); a.R(5,2,1,8,'n'); a.R(4,9,10,4,'N'); a.H(9,5,13,'n'); a.R(3,13,12,1,'E')
a.pts('c',(8,4),(8,6),(8,8),(10,10),(12,10))
# ---- together tiles
a = new('trading')        # swap arrows
a.R(2,4,9,2,'o'); a.R(11,2,1,6,'o'); a.R(12,3,1,4,'o'); a.R(13,4,1,2,'o')
a.R(5,9,9,2,'g'); a.R(4,7,1,6,'g'); a.R(3,8,1,4,'g'); a.R(2,9,1,2,'g'); a.H(4,2,10,'y'); a.H(9,5,13,'l')
a = new('together')       # sunflower
a.R(6,2,4,3,'y'); a.R(6,9,4,3,'y'); a.R(3,5,3,4,'y'); a.R(10,5,3,4,'y'); a.pts('y',(5,4),(10,4),(5,9),(10,9))
a.R(6,5,4,4,'N'); a.pts('n',(7,6),(8,7)); a.H(2,6,9,'o') if False else None
a.R(7,12,2,3,'g'); a.pts('l',(5,13),(6,13),(10,12),(11,12)) if False else None; a.H(13,5,6,'l'); a.H(12,9,10,'l')
a = new('tasks')          # clipboard
a.R(3,2,10,12,'n'); a.R(12,3,1,11,'N'); a.R(4,4,8,9,'w'); a.R(6,1,4,3,'e'); a.H(1,7,8,'E')
a.pts('g',(5,6),(6,7),(7,6)); a.H(6,9,11,'e'); a.pts('g',(5,9),(6,10),(7,9)); a.H(9,9,11,'e'); a.H(12,5,10,'e')
a = new('friends')        # two friends and a heart
a.H(1,4,5,'r'); a.H(1,8,9,'r'); a.H(2,3,10,'r'); a.H(3,4,9,'r'); a.H(4,5,8,'r'); a.H(5,6,7,'r'); a.pts('p',(4,2),(5,2))
a.R(2,7,5,5,'t'); a.H(7,2,6,'n'); a.R(1,12,7,2,'b'); a.pts('k',(3,9),(5,9))
a.R(9,7,5,5,'T'); a.H(7,9,13,'N'); a.R(8,12,7,2,'g'); a.pts('k',(10,9),(12,9))
a = new('festival')       # bunting
a.H(2,1,14,'N'); a.H(3,1,1,'N') if False else None
for x,c in ((1,'r'),(5,'y'),(9,'b')):
    a.H(3,x,x+3,c); a.H(4,x,x+3,c); a.H(5,x+1,x+2,c); a.P(x+1,6,c) if False else None
a.H(9,2,13,'N')
for x,c in ((3,'g'),(7,'p'),(11,'o')):
    a.H(10,x,x+2,c); a.H(11,x,x+2,c); a.H(12,x+1,x+1,c)
# ---- write
os.makedirs('.',exist_ok=True)
uris = {}
for slug,ic in I.items():
    im = ic.image(); im.save('nav-%s.png'%slug)
    im.resize((32,32),Image.NEAREST).save('nav-%s@2x.png'%slug)
    buf = io.BytesIO(); im.resize((32,32),Image.NEAREST).save(buf,'PNG')
    uris[slug] = 'data:image/png;base64,' + base64.b64encode(buf.getvalue()).decode()
json.dump(uris,open('icons.json','w'))
# contact sheet
cells = ''.join('<figure><img src="nav-%s@2x.png" width="64" height="64"><img class="s" src="nav-%s.png" width="16" height="16"><figcaption>%s</figcaption></figure>'%(s,s,s) for s in I)
open('contact.html','w').write('<!doctype html><meta charset="utf-8"><title>Dock menu icons</title><style>body{font:14px system-ui;background:#f1ece0;margin:16px}figure{display:inline-block;margin:6px;padding:8px;text-align:center;background:#fff3c8;border:2px solid #9a6b3f}img{image-rendering:pixelated;display:block;margin:0 auto 4px}.s{margin-top:4px}.d{background:#3d2a1c;color:#f2e4c0}</style>'+cells)
print(len(I),'icons')
