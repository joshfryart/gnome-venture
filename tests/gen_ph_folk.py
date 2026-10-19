#!/usr/bin/env python3
"""Generate placeholder SVGs: creature-{slug}.svg (64 box) and npc-{slug}.svg (80x100).
Usage: python3 gen_ph_folk.py [creatures.txt] [npcs.txt (slug|name|species)] [outdir]"""
import sys, os, re, zlib, math
G = '/home/claude/src/game'
CRE = sys.argv[1] if len(sys.argv) > 1 else G + '/includes/data/creatures.txt'
NPC = sys.argv[2] if len(sys.argv) > 2 else '/tmp/claude-0/phf/npcs.txt'
OUT = sys.argv[3] if len(sys.argv) > 3 else G + '/assets/img/ph'

INK='#2b2b2b'; CREAM='#f4f0e0'; WH='#fff'
# name -> (body, shade, light)
C = dict(
 brown=('#9a6b3f','#7a4a1f','#c9a96e'), dbrown=('#7a4a1f','#3d2a1c','#9a6b3f'), tan=('#c9a96e','#9a6b3f','#f1ece0'),
 cream=('#f4f0e0','#c9c5bc','#fff'), grey=('#8b8f96','#5b6470','#c9c5bc'), dgrey=('#5b6470','#2b2b2b','#8b8f96'),
 orange=('#f08a24','#e0501f','#f4f0e0'), red=('#d6322b','#a8241f','#f6b8cf'), green=('#4f9a45','#2f5a2a','#a4b86a'),
 lgreen=('#7ab55c','#4f9a45','#f4f0e0'), olive=('#a4b86a','#4f9a45','#f4f0e0'), blue=('#3f8fb0','#25637d','#a9d6ea'),
 lblue=('#a9d6ea','#3f8fb0','#f4f0e0'), purple=('#7a5cc0','#4e3a8a','#c3b2ea'), lpurple=('#c3b2ea','#7a5cc0','#f4f0e0'),
 pink=('#e46a9b','#a8241f','#f6b8cf'), gold=('#e8a317','#b07a10','#f5cf6a'), ink=('#2b2b2b','#000','#5b6470'),
 moss=('#4f9a45','#2f5a2a','#7ab55c'), rock=('#8b8f96','#5b6470','#c9c5bc'),
 soil=('#9a6b3f','#7a4a1f','#3d2a1c','#c9a96e'), petal=('#e46a9b','#a8241f','#f6b8cf'), stone=('#8b8f96','#5b6470','#c9c5bc'),
 ember=('#e0501f','#a8241f','#f08a24'), water=('#3f8fb0','#25637d','#a9d6ea'), dusk=('#7a5cc0','#4e3a8a','#c3b2ea'),
)
def f(n): 
    s=('%.1f'%n).rstrip('0').rstrip('.'); return s if s!='-0' else '0'
def el(cx,cy,rx,ry,fill,extra=''): return '<ellipse cx="%s" cy="%s" rx="%s" ry="%s" fill="%s"%s/>'%(f(cx),f(cy),f(rx),f(ry),fill,extra)
def ci(cx,cy,r,fill,extra=''): return '<circle cx="%s" cy="%s" r="%s" fill="%s"%s/>'%(f(cx),f(cy),f(r),fill,extra)
def pa(d,fill='none',extra=''): return '<path d="%s" fill="%s"%s/>'%(d,fill,extra)
def ln(d,col,w=2): return '<path d="%s" fill="none" stroke="%s" stroke-width="%s" stroke-linecap="round" stroke-linejoin="round"/>'%(d,col,f(w))
def eye(x,y,r=2.2): return ci(x,y,r,INK)+ci(x-r*.3,y-r*.35,r*.35,WH)
def hl(d): return '<path d="%s" fill="none" stroke="#fff" stroke-width="2.2" stroke-linecap="round" opacity=".4"/>'%d
def rot(inner,a,x,y): return '<g transform="rotate(%s %s %s)">%s</g>'%(f(a),f(x),f(y),inner)
def place(inner,x,y,s): return '<g transform="translate(%s %s) scale(%s)">%s</g>'%(f(x),f(y),f(s),inner)
def col(x): return C[x][0] if x in C else x
def h(s): return zlib.crc32(s.encode())
def pick(seed,lst,salt=0): return lst[(h(seed)>>salt)%len(lst)]

# ---------- creature kits (all draw into a 64 box, feet near y=56) ----------
def quad(c,ears='round',tail='none',snout='short',mark=None,horns=None,belly=None,face=None,mane=False,tusks=False,fat=1.0,eyecol=None,whisk=False):
    b,d,l=C[c]; belly=col(belly) if belly else l; o=''
    if tail=='bushy': o+=rot(el(50,44,5,11,d),-25,50,44)+rot(el(52,35,3,4,CREAM),-25,52,35)
    elif tail=='thin': o+=ln('M48 46q10 0 11-9',d,2.5)
    elif tail=='short': o+=ci(49,48,3.5,d)
    elif tail=='long': o+=ln('M48 48q12 2 10-12',d,3.5)
    if horns=='curl':
        o+=ln('M20 15q-12 -2 -12 9q1 5 6 3',INK if c!='cream' else d,3.2)+ln('M44 15q12 -2 12 9q-1 5 -6 3',INK if c!='cream' else d,3.2)
    elif horns=='spike': o+=pa('M19 17l-5-12 9 8zM45 17l5-12-9 8z','#f4f0e0')
    elif horns=='antlers':
        for s in(-1,1):
            x=32+s*10; o+=ln('M%s 16l%s -12m0 6l%s -4m%s 5l%s -5'%(f(x),f(s*4),f(s*5),f(-s*2),f(s*4)),'#7a4a1f',3)
    if ears=='round': o+=ci(20,16,5.5,b)+ci(44,16,5.5,b)+ci(20,16,3,belly if c!='cream' else d)+ci(44,16,3,belly if c!='cream' else d)
    elif ears=='point': o+=pa('M18 22l-1-16 11 9z',b)+pa('M46 22l1-16-11 9z',b)+pa('M20 19l0-9 6 5z',d)+pa('M44 19l0-9-6 5z',d)
    elif ears=='long': o+=el(23,8,4.5,12,b)+el(41,8,4.5,12,b)+el(23,9,2.2,8,'#f6b8cf')+el(41,9,2.2,8,'#f6b8cf')
    elif ears=='floppy': o+=el(19,24,5,10,d)+el(45,24,5,10,d)
    elif ears=='tuft': o+=pa('M20 20l-3-14 10 8z',b)+pa('M44 20l3-14-10 8z',b)+ln('M18 8l0 -5M46 8l0 -5',INK,2)
    # body
    rx=17*fat
    o+=el(22,54,6.5,4,d)+el(42,54,6.5,4,d)+el(32,42,rx,14,b)+el(32,46,10*fat,9,belly)
    if mark=='stripes': o+=ln('M17 36q4 4 1 9M47 36q-4 4 -1 9M22 30q3 3 2 7M42 30q-3 3 -2 7',INK,2.5)
    if mark=='spots': o+=''.join(ci(x,y,2,d) for x,y in((22,37),(42,40),(26,47),(38,34),(46,47)))
    if mane: o+=''.join(ci(32+13*math.cos(t),27+13*math.sin(t),5,d) for t in [i*math.pi/4 for i in range(8)])
    o+=ci(32,27,13,b)
    if mark=='stripes': o+=ln('M32 14v6M26 15l2 5M38 15l-2 5',INK,2.4)
    if mark=='mask': o+=pa('M19 23q13 -5 26 0q-2 7 -8 5q-5 -3 -10 0q-6 2 -8 -5z',INK)+ci(26,24,2.4,WH)+ci(38,24,2.4,WH)+ci(26,24,1.2,INK)+ci(38,24,1.2,INK)
    if mark=='stripe': o+=pa('M30 14h4l1 12h-6z',CREAM)
    if mark=='saddle': o+=pa('M20 22q12 -10 24 0q-4 4 -12 4q-8 0 -12 -4z',d)
    # face
    if snout=='short': o+=el(32,31,7,5,belly)+el(32,29,2.6,1.9,INK)
    elif snout=='long': o+=el(32,33,6,7,belly)+el(32,29,2.8,2,INK)
    elif snout=='pig': o+=el(32,32,7.5,5.5,'#f6b8cf')+ci(29.5,32,1.3,'#a8241f')+ci(34.5,32,1.3,'#a8241f')
    elif snout=='trunk': o+=el(32,36,4.5,10,belly)+ci(32,45,3,INK)
    elif snout=='flat': o+=el(32,31,9,6,belly)+el(32,29,3,2,INK)
    if mark!='mask': o+=eye(25,23)+eye(39,23)
    if tusks: o+=pa('M26 33l-2 7 4-4zM38 33l2 7-4-4z',CREAM)
    if whisk: o+=ln('M20 30h-8M20 33l-7 3M44 30h8M44 33l7 3','#fff',1.4)
    o+=ln('M29 34q3 2 6 0',INK,1.4) if snout in('short','flat') else ''
    o+=hl('M24 18q4-4 9-4')
    return o
def bird(c,beak='short',crest=None,legs='short',owl=False,belly=None,wing=None,bc=None,hood=False,pouch=False,face=None,neck=False):
    b,d,l=C[c]; belly=col(belly) if belly else l; wing=col(wing) if wing else d; bcol=C[bc][0] if bc else '#e8a317'; o=''
    y=0
    if neck: # heron style: long neck, side-ish head
        o+=ln('M24 56v-8M36 56v-8',C['brown'][1],2.2)
        o+=el(30,42,15,10,b)+pa('M16 40q-8 -2 -10 -9q8 0 14 6z',d)+el(30,44,9,6,belly)+pa('M36 36q0 -14 -6 -22',b,' stroke="%s" stroke-width="7" stroke-linecap="round"'%b)
        o+=ln('M36 36q0 -14 -6 -22',b,7)+ci(29,13,7,b)+pa('M35 12l22 4-22 4z',bcol)+eye(27,12,2)+pa('M22 8q-6 -4 -9 0q5 1 9 6z',INK)
        return o+hl('M25 8q3-3 6-2')
    if owl: o+=pa('M17 22l2-13 9 8zM47 22l-2-13-9 8z',d)
    o+=ln('M25 52v5M39 52v5','#e8a317' if not owl else d,2.6)
    o+=el(32,36,17,17,b)+el(32,42,10,11,belly)
    o+=rot(el(16,40,5,11,wing),12,16,40)+rot(el(48,40,5,11,wing),-12,48,40)
    if hood: o+=pa('M19 26q13 -22 26 0q-6 -4 -13 -4q-7 0 -13 4z',INK)
    if crest=='tuft': o+=pa('M28 12q-2 -8 4 -9q-1 5 5 9z',d)
    elif crest=='crown': o+=pa('M24 13q8 -10 16 0z',d)
    elif crest=='casque': o+=pa('M28 12q4 -9 8 0z','#e8a317')
    if owl:
        o+=ci(24,24,7.5,CREAM)+ci(40,24,7.5,CREAM)+ci(24,24,4,'#e8a317')+ci(40,24,4,'#e8a317')+ci(24,24,2.3,INK)+ci(40,24,2.3,INK)+pa('M32 25l-3 4h6z','#e8a317')
    else:
        if beak=='short': o+=pa('M28 25h8l-4 6z',bcol)
        elif beak=='hook': o+=pa('M28 24h8q1 6 -3 9q1 -4 -1 -5q-2 0 -4 -4z',bcol)
        elif beak=='long': o+=pa('M29 24h6l-3 14z',bcol)
        elif beak=='wide': o+=pa('M27 25h10l3 4h-16z',bcol)
        if pouch: o+=pa('M26 28h12q-1 14 -6 14q-5 0 -6 -14z','#f5cf6a')+pa('M30 24h4l-1 24h-2z',bcol)
        o+=ci(26,21,3.4,WH)+ci(38,21,3.4,WH)+ci(26.4,21.4,1.9,INK)+ci(38.4,21.4,1.9,INK)
        if beak=='hook': o+=pa('M21 17l9 3M43 17l-9 3','#2b2b2b','stroke="#2b2b2b" stroke-width="2.4" stroke-linecap="round"'[0:0]); o+=ln('M21 17l9 4M43 17l-9 4',INK,2.6)
    return o+hl('M24 16q5-5 11-3')
def frog(c,spots=False,big=1.0,bright=False,belly=None,warts=False):
    b,d,l=C[c]; belly=col(belly) if belly else l; o=''
    o+=el(20,54,8,3.5,d)+el(44,54,8,3.5,d)+el(32,42,19*big,14,b)+el(32,47,11,8,belly)
    o+=ci(22,26,8,b)+ci(42,26,8,b)+ci(22,25,5.5,CREAM)+ci(42,25,5.5,CREAM)+ci(22,25,3,INK)+ci(42,25,3,INK)+ci(21,24,1,WH)+ci(41,24,1,WH)
    o+=el(32,34,13,7,b)+ln('M22 36q10 6 20 0',INK,1.8)
    if spots or warts: o+=''.join(ci(x,y,2.2,d if warts else INK) for x,y in((18,40),(46,41),(26,46),(38,45),(32,30)))
    if bright: o+=ci(30,39,2,'#f5cf6a')
    return o+hl('M18 36q3-4 8-5')
def lizard(c,kind='lizard',spots=False,frill=False,belly=None):
    b,d,l=C[c]; belly=col(belly) if belly else l; o=''
    if kind=='croc':
        o+=pa('M8 48q-4 6 -1 8q10 -1 20 -8z',d)+el(30,46,22,9,b)+el(22,54,4,3,d)+el(40,54,4,3,d)+pa('M40 40q4 -8 12 -4l10 5q2 2 0 5l-10 1q-8 4 -12 -2z',b)
        o+=pa('M44 46l14 -3 2 4-14 3z',belly)+ci(46,37,3,CREAM)+ci(46.5,37.5,1.6,INK)+''.join(pa('M%s 45l1.5 3 1.5-3z'%x,WH) for x in(50,54,58))
        o+=''.join(pa('M%s 38l2 -4 2 4z'%x,d) for x in(14,20,26,32))
    else:
        o+=ln('M12 44q-10 6 -8 12',b,5)+el(30,44,17,9,b)+el(30,48,11,5,belly)
        for x in(18,42): o+=el(x,54,4,3,d)
        o+=ci(46,38,8,b)+pa('M50 36q8 0 8 5q-4 3 -10 1z',b)
        if frill: o+=''.join(pa('M%s 36l%s -9 4 7z'%(f(40+i*3),f(i*2-3)),'#e0501f') for i in range(4))
        o+=ci(46,34,3.4,CREAM)+eye(46.5,34,1.8)+el(40,38,1,1,d)
        if kind=='monitor': o+=ln('M58 40l5 2m-5 0l5 -3',C['pink'][0],1.4)
    if spots: o+=''.join(ci(x,y,2,d if d!=INK else b) for x,y in((22,41),(30,39),(38,42),(26,46),(34,46)))
    return o+hl('M22 38q5-3 12-2')
def snake(c,belly=None,pat='diamond',hood=False,side=False):
    b,d,l=C[c]; belly=col(belly) if belly else l; o=''
    pth='M12 54q-8 -4 0 -9q18 -4 38 -2q10 2 4 9q-4 2 -16 0q-18 -3 -26 2q-6 4 6 6'
    o+=pa('M10 52q2 7 26 6q22 -2 18 -14q-4 -8 -22 -6q-18 2 -22 8q-4 6 8 8',b,' stroke="%s" stroke-width="0"'%b)
    o+=ln('M10 52q4 4 22 3q20 -1 20 -10q0 -8 -20 -6q-18 2 -20 7',b,10)
    o+=ln('M10 52q4 4 22 3q20 -1 20 -10q0 -8 -20 -6q-18 2 -20 7',belly,3.5)
    if pat=='diamond': o+=''.join(pa('M%s %sl2.5 2.5 -2.5 2.5 -2.5 -2.5z'%(f(x),f(y)),d) for x,y in((20,54),(30,55),(40,53),(48,47),(40,40),(28,40)))
    if pat=='stripe': o+=''.join(ln('M%s %sv5'%(f(x),f(y)),d,2.2) for x,y in((20,50),(30,52),(40,50),(48,43),(38,37),(26,38)))
    if hood: o+=pa('M44 20q10 -6 20 0q-4 10 -10 10q-6 0 -10 -10z',b)
    o+=ci(14,38,8,b)+ci(14,38,8,'none')+pa('M16 33q14 -10 20 0q-2 8 -10 8q-8 0 -10 -8z',b) if False else ''
    # head up on left
    o+=ln('M12 50q-4 -10 2 -16',b,9)+ci(15,30,8.5,b)+pa('M22 30q9 0 9 4h-9z',b)+eye(13,28,2)+eye(20,28,2)+ln('M17 34q2 1 4 0',INK,1.3)+ln('M22 34l7 3m-3 -1l4 -2','#d6322b',1.2)
    return o+hl('M10 26q3-4 8-3')
def turtle(c,shell='green',spots=True,head=None,tort=False):
    b,d,l=C[c]; sb,sd,sl=C[shell]; o=''
    for x in(18,44): o+=el(x,53,6,4,b)
    o+=pa('M8 50q0 -30 24 -30q24 0 24 30z',sb)+pa('M6 50h52v4q-26 4 -52 0z',sd)
    o+=''.join(pa(p,'none',' stroke="%s" stroke-width="2"'%sd) for p in('M32 20v30','M14 36h36','M20 26l6 10-6 14','M44 26l-6 10 6 14'))
    o+=hl('M16 36q4-10 12-12')
    o+=ci(54,44,6,b)+eye(56,42,1.6)+ln('M54 47q2 1 4 0',INK,1.2)+ln('M10 50l-5 3',d,3)
    return o
def beetle(c,kind='beetle',horns=False,glow=False,spots=False,stripe=False):
    b,d,l=C[c]; o=''
    o+=''.join(ln('M%s %sq%s %s %s %s'%(f(32+s*10),f(y),f(s*10),f(-3),f(s*14),f(dy)),INK,2.2) for s in(-1,1) for y,dy in((34,-6),(40,2),(46,10)))
    if glow: o+=ci(32,40,22,'#e8a317',' opacity=".28"')
    o+=el(32,41,15,17,b)+ln('M32 25v33',d,2)+hl('M22 34q3-8 8-9')
    if spots: o+=''.join(ci(x,y,2.6,INK) for x,y in((24,38),(40,38),(26,48),(38,48)))
    if stripe: o+=ln('M17 42q15 5 30 0M19 50q13 5 26 0',INK,3)
    if glow: o+=el(32,45,6,8,'#f5cf6a')+el(32,43,3,5,CREAM)
    o+=ci(32,22,7,d)+eye(28.5,21,1.8)+eye(35.5,21,1.8)
    if horns: o+=pa('M26 18q-10 -6 -6 -12q4 6 9 8zM38 18q10 -6 6 -12q-4 6 -9 8z',INK)
    else: o+=ln('M29 15q-4 -7 -8 -7M35 15q4 -7 8 -7',INK,1.8)
    return o
def wasp(c='gold',bee=False):
    b,d,l=C[c]; o=''
    o+=el(20,32,12,7,WH,' opacity=".5"')+el(44,32,12,7,WH,' opacity=".5"')
    o+=el(32,44,12,14,b)+''.join(ln('M%s %sq9 4 18 0'%(f(23),f(y)),INK,3.5) for y in(40,47,53))
    o+=pa('M32 57l0 5',INK)+ci(32,28,8,b if bee else INK)+el(32,31,4,3,b if not bee else CREAM)+eye(28,26,1.9)+eye(36,26,1.9)
    o+=ln('M29 20q-3 -6 -6 -6M35 20q3 -6 6 -6',INK,1.8)+hl('M24 40q2-6 6-8')
    return o
def moth(c='lpurple',dusk=True):
    b,d,l=C[c]; o=''
    o+=pa('M30 28C18 8 4 16 6 32c2 10 14 16 24 8z',b)+pa('M34 28c12 -20 26 -12 24 4c-2 10 -14 16 -24 8z',b)
    o+=pa('M30 40C22 38 12 46 18 54c6 4 12 -2 12 -14z',d)+pa('M34 40c8 -2 18 6 12 14c-6 4 -12 -2 -12 -14z',d)
    o+=ci(16,28,4,CREAM)+ci(48,28,4,CREAM)+ci(16,28,2,INK)+ci(48,28,2,INK)
    o+=el(32,38,4,13,'#f1ece0')+ci(32,24,5,'#f1ece0')+eye(30,24,1.4)+eye(34,24,1.4)+ln('M30 20q-3 -6 -7 -6M34 20q3 -6 7 -6',d,1.6)
    return o+hl('M12 20q4-6 11-6')
def ant(c='dbrown',n=3):
    b,d,l=C[c]; o=''
    o+=''.join(ln('M%s 40l%s 12M%s 40l%s 12'%(f(x),f(-7),f(x),f(7)),INK,1.8) for x in(26,32,38))
    o+=el(46,40,11,9,b)+el(32,41,6,5,b)+ci(20,38,8,b)+eye(17,36,1.8)+eye(23,36,1.8)
    o+=ln('M16 31q-4 -8 -9 -7M24 31q2 -8 8 -9',INK,1.8)+hl('M42 35q3-3 8-2')
    return o
def spider(c='dgrey',kind='spider'):
    b,d,l=C[c]; o=''
    for s in(-1,1):
        for y,dy in((32,-10),(37,-3),(42,5),(47,13)): o+=ln('M%s %sq%s %s %s %s'%(f(32+s*6),f(y),f(s*12),f(-8),f(s*22),f(dy)),INK,2.2)
    o+=el(32,42,11,12,b)+ci(32,28,8,d if kind=='spider' else b)+eye(28,26,2.4)+eye(36,26,2.4)+eye(32,30,1.4)
    o+=ci(28,40,2.5,'#e8a317')+ci(36,40,2.5,'#e8a317')+ci(32,46,2.5,'#e8a317')
    return o+hl('M26 36q2-5 6-6')
def scorpion(c='gold'):
    b,d,l=C[c]; o=''
    o+=''.join(ln('M%s 44l%s 8'%(f(x),f(s*7)),INK,2) for x in(26,32,38) for s in(1,))
    o+=ln('M44 46q14 -2 12 -16q-2 -8 -10 -6',b,6)+pa('M42 22l6 -6 2 8z',INK)
    o+=el(30,44,13,9,b)+ln('M22 44h16',d,1.6)
    for s in(-1,1): o+=ln('M%s 38q%s -10 %s -14'%(f(32+s*6),f(s*8),f(s*6)),b,4)+pa('M%s 20q%s -9 %s -2q%s 6 %s 2z'%(f(32+s*12),f(s*-2),f(s*9),f(s*-4),f(s*-4)),b)
    o+=ci(30,38,7,b)+eye(27,36,1.6)+eye(33,36,1.6)
    return o+hl('M22 40q4-3 10-2')
def crab(c='orange',armor=False,king=False,hermit=False):
    b,d,l=C[c]; o=''
    o+=''.join(ln('M%s 44l%s 12'%(f(32+s*12),f(s*10)),d,2.6) for s in(-1,1))+''.join(ln('M%s 48l%s 9'%(f(32+s*8),f(s*12)),d,2.6) for s in(-1,1))
    for s in(-1,1):
        o+=ln('M%s 38q%s -8 %s -12'%(f(32+s*14),f(s*6),f(s*4)),d,4)
    o+=pa('M7 26q-3 -12 8 -14q8 4 3 16q-6 2 -11 -2z',b)+pa('M57 26q3 -12 -8 -14q-8 4 -3 16q6 2 11 -2z',b)+pa('M9 24l4 -8M55 24l-4 -8',d,' stroke="%s" stroke-width="2"'%d)
    o+=el(32,42,18,12,b)+el(32,46,10,6,l)
    o+=ln('M26 30v-6M38 30v-6',d,2)+ci(26,23,3.4,WH)+ci(38,23,3.4,WH)+ci(26,23,1.8,INK)+ci(38,23,1.8,INK)
    if armor: o+=pa('M16 44q16 -22 32 0z','#8b8f96')+ln('M32 28v12',C['stone'][1],2)+pa('M32 28q6 -8 9 -2z',C['ember'][1])
    if king: o+=''.join(pa('M%s 24l1.5 -5 1.5 5z'%f(x),C['stone'][2]) for x in(28,32,36))
    if hermit: o+=pa('M20 44q0 -20 18 -20q16 4 8 26q-14 6 -26 -6z',C['petal'][1] if False else C['soil'][3])+ln('M30 28q-4 6 0 12q6 2 6 -8',C['soil'][0],2)
    return o+hl('M20 38q3-5 9-6')
def fish(c='green',kind='pike',big=False):
    b,d,l=C[c]; o=''
    if kind=='eel':
        o+=ln('M8 52q10 -22 24 -8q12 12 22 -14',b,10)+ln('M8 52q10 -22 24 -8q12 12 22 -14',l,3)+ci(56,26,8,b)+pa('M54 28q8 4 4 8z',b)
        o+=eye(58,24,2)+''.join(pa('M%s %sl2 3 -2 1z'%(f(54+i*2),f(31)),WH) for i in range(2))
        return o+hl('M12 44q6-10 14-4')
    o+=pa('M6 32l12 8 -12 12z',d)+el(34,40,26,12,b)+el(34,45,20,6,l)+pa('M28 30q6 -8 14 0z',d)
    o+=pa('M50 36h13l-3 6h-10z',b)+''.join(pa('M%s 38l2 3 2 -3z'%f(x),WH) for x in(53,57,61))
    o+=ci(48,35,3.4,CREAM)+eye(48.5,35,1.8)+ln('M18 36v9M24 35v10',d,1.8)
    return o+hl('M20 34q8-5 16-3')
def octo(c='purple'):
    b,d,l=C[c]; o=''
    for i in range(6):
        x=14+i*7.2; o+=ln('M%s 46q%s 8 %s 14'%(f(x),f(-4 if i<3 else 4),f(-6 if i<3 else 6)),d,5)
    o+=ln('M12 46q-6 6 -3 10M52 46q6 6 3 10',d,5)
    o+=el(32,32,19,19,b)+el(32,46,16,8,b)+ci(25,36,5,CREAM)+ci(39,36,5,CREAM)+ci(25,37,2.6,INK)+ci(39,37,2.6,INK)
    o+=''.join(ci(x,y,1.8,l) for x,y in((22,22),(28,17),(36,18),(42,24)))
    return o+hl('M18 26q4-9 12-10')
def slug(c='tan',kind='slug',spots=False,shell=None,leech=False):
    b,d,l=C[c]; o=''
    o+=el(32,50,26,8,b)+ci(52,44,6.5,b)+ln('M54 40l3 -10M49 39l-2 -9',b,2.4)+ci(57,29,2.2,INK)+ci(47,29,2.2,INK)
    if shell:
        sb=C[shell]; o+=ci(26,36,15,sb[0])+ln('M26 36m-5 0a5 5 0 1 1 5 5a9 9 0 1 1 -9 -9a13 13 0 1 1 13 13',sb[1],2)+hl('M16 30q4-8 12-8')
    else:
        o+=el(26,41,19,10,b)+(''.join(ci(x,y,2.2,d) for x,y in((16,40),(24,36),(30,42),(36,38),(22,45))) if spots else ln('M12 42h26',d,2))+hl('M14 36q8-6 20-2')
    o+=eye(54,45,1.4)+ln('M54 49q2 1 4 0',INK,1.2)
    return o
def leech():
    o=ln('M8 52q14 -26 28 -6q10 12 20 -14',C['dbrown'][1] if False else C['soil'][1],10)+ln('M8 52q14 -26 28 -6q10 12 20 -14',C['soil'][0],3)
    return o+ci(56,32,6.5,C['soil'][1])+eye(55,30,1.6)+ci(60,37,2,C['ember'][1])+hl('M12 44q4-6 12-6')
def wisp(c='lblue'):
    b,d,l=C[c]; o=''
    o+=ci(32,34,26,b,' opacity=".25"')+ci(32,34,19,b,' opacity=".35"')
    o+=pa('M32 8q-12 14 -12 28q0 12 12 12q12 0 12 -12q0 -14 -12 -28z',b)+pa('M32 22q-6 8 -6 17q0 7 6 7q6 0 6 -7q0 -9 -6 -17z',l)
    o+=eye(27,38,2.2)+eye(37,38,2.2)+ln('M29 44q3 2 6 0',INK,1.4)
    return o
def golem(c='rock',moss=True,fiery=False):
    b,d,l=C[c]; o=''
    o+=pa('M10 56q-2 -22 8 -30q14 -8 28 0q10 8 8 30z',b)+pa('M4 46l8 -4 6 12 -8 4zM60 46l-8 -4 -6 12 8 4z',d)
    o+=pa('M18 20q14 -8 28 0l-2 10h-24z',l)+hl('M22 22q6-4 14-2')
    o+=pa('M24 26h6l-1 5h-5zM34 26h6l-1 5h-5z','#2b2b2b')+ci(27,28.5,1.5,'#f5cf6a')+ci(37,28.5,1.5,'#f5cf6a')+ln('M27 37h10',INK,2)
    if moss: o+=pa('M12 38q8 -6 16 -2q-4 4 -8 8q-4 -1 -8 -6zM38 46q8 -4 14 0q-2 6 -8 6z','#4f9a45')+pa('M14 36q-2 -5 3 -6q2 4 -3 6zM46 20q4 -8 6 0z','#7ab55c')
    return o
def thistle():
    o=''
    o+=''.join(pa('M%s %sl%s %s %s %s'%(f(32+20*math.cos(t)),f(38+20*math.sin(t)),f(-3*math.sin(t)),f(3*math.cos(t)),f(-2*math.cos(t)),f(-2*math.sin(t))),'#4f9a45') for t in [i*math.pi/6 for i in range(12)]) if False else ''
    for i in range(14):
        t=i*math.pi*2/14; x,y=32+17*math.cos(t),38+15*math.sin(t); o+=pa('M%s %sL%s %sL%s %sz'%(f(x-3*math.sin(t)),f(y+3*math.cos(t)),f(32+25*math.cos(t)),f(38+23*math.sin(t)),f(x+3*math.sin(t)),f(y-3*math.cos(t))),C['moss'][1])
    o+=el(32,38,19,17,C['moss'][0])+el(32,28,12,9,C['dusk'][1])
    o+=''.join(pa('M%s 22l1.5 -6 1.5 6z'%f(x),C['petal'][0]) for x in(22,26,30,34,38,42) if False)
    o+=''.join(ln('M%s 21l%s -5'%(f(x),f((x-32)/3)),C['petal'][0],2) for x in(22,26,30,34,38,42))
    o+=el(26,40,3.5,4,CREAM)+el(38,40,3.5,4,CREAM)+eye(26,41,1.8)+eye(38,41,1.8)+pa('M27 48q5 3 10 0q-5 -2 -10 0z',INK)
    o+=el(24,56,6,3,C['moss'][1])+el(40,56,6,3,C['moss'][1])
    return o+hl('M20 34q4-8 12-9')
def clam():
    o=''
    o+=pa('M6 48q0 -26 26 -30q26 4 26 30q-26 12 -52 0z',C['petal'][1] if False else C['stone'][2])
    o+=''.join(ln('M32 18l%s 34'%f(i*8),C['stone'][0],1.8) for i in range(-3,4))
    o+=pa('M10 46q22 -14 44 0q-22 8 -44 0z',C['petal'][0])+pa('M16 46q16 -8 32 0q-16 4 -32 0z','#a8241f')
    o+=''.join(pa('M%s 44l2 -4 2 4z'%f(x),WH) for x in(18,26,34,42))
    o+=eye(26,36,2.2)+eye(38,36,2.2)+el(32,56,20,3,'#000',' opacity=".0"')
    return o+hl('M12 36q6-12 18-14')
def fluff(c,ears='round',swarm=None): pass
def swarm(inner,pos): return ''.join(place(inner,x,y,s) for x,y,s in pos)
def gnats(): 
    o=''
    for i,(x,y) in enumerate(((18,22),(34,14),(46,26),(24,38),(40,42),(14,48),(52,48),(30,28))):
        o+=el(x-3,y-3,4,2,WH,' opacity=".6"')+el(x+3,y-3,4,2,WH,' opacity=".6"')+el(x,y,3,2.2,C['dgrey'][0])+ci(x-3.5,y,1.6,INK)
    return o
def aphids():
    o=''
    for x,y,s in((16,44,.9),(30,40,1),(44,46,.9),(22,28,.8),(38,28,.85),(30,16,.7),(50,30,.7)):
        o+=place(el(0,0,6,5,C['lgreen'][0])+ci(-2,-1,1,INK)+ci(2,-1,1,INK)+ln('M-3 -5l-2 -4M3 -5l2 -4',C['moss'][1],1)+el(-6,-3,3,2,WH,' opacity=".6"'),x,y,s*1.4)
    return o
def flea():
    return ''.join(place(el(0,0,5,4,C['dbrown'][0])+ci(3,-1,1,INK)+ln('M-3 3l-3 4M0 4l0 4',INK,1)+ln('M3 -4q3 -4 5 -1',INK,1),x,y,1.6) for x,y in((14,30),(36,22),(24,44),(44,40),(50,22)))
def centipede(c='ember'):
    b,d,l=C[c]; o=''
    seg=[(10+i*6.5, 44+6*math.sin(i*.9)) for i in range(8)]
    for x,y in seg: o+=ln('M%s %sv9M%s %sv-9'%(f(x),f(y),f(x),f(y)),INK,1.6)
    for x,y in seg[::-1]: o+=ci(x,y,5.5,b if int(x)%2 else d)
    x,y=seg[-1]; o+=ci(x+3,y-2,7,d)+eye(x+2,y-4,1.8)+eye(x+7,y-4,1.8)+ln('M%s %sl-3 -9m6 9l3 -9'%(f(x+3),f(y-8)),INK,1.6)
    return o
def glowworm():
    o=''
    seg=[(12+i*8,46-2*math.sin(i)) for i in range(6)]
    o+=ci(52,40,24,'#f5cf6a',' opacity=".25"')
    for i,(x,y) in enumerate(seg): o+=ci(x,y,6.5,C['tan'][0] if i<5 else '#f5cf6a')
    o+=ci(52,42,7,'#f5cf6a')+ci(52,42,4,CREAM)+ci(8,44,5,C['tan'][1])+eye(7,43,1.4)
    return o+hl('M12 40q6-4 14-2')
def leafcutter():
    o=''
    for i,(x,y) in enumerate(((6,34),(22,48),(38,36))):
        o+=place(ant('dbrown'),x-8,y-8,.6)+ rot(pa('M%s %sq9 -12 18 0q-9 6 -18 0z'%(f(x-4),f(y-6)),C['moss'][0 if i%2 else 2]),-8,x,y)
    return o
def pelican(): return bird('cream',beak='long',pouch=True,belly='cream',wing='lblue' if False else 'stone',bc='gold') if False else bird('cream',beak='long',pouch=True,wing='grey')

# ---------- creature spec ----------
def spec(slug,name,landsc):
    S=slug
    T={
 'aphid-swarm':lambda:aphids(),'garden-snail':lambda:slug_('tan','slug',shell='brown'),
 'ant-scouts':lambda:swarm(ant('dbrown'),[(0,2,.7),(4,26,.6)]) ,
 'gnat-cloud':gnats,'leopard-slug':lambda:slug_('tan','slug',spots=True),
 'sand-fleas':flea,'dusk-moth':lambda:moth('lpurple'),'dung-beetle':lambda:beetle('dbrown')+ci(50,22,9,C['soil'][1])+hl('M45 18q3-3 6-2'),
 'earwig':lambda:beetle('brown')+pa('M26 12q-4 -10 2 -9M38 12q4 -10 -2 -9',INK) ,
 'cave-glowworm':glowworm,'orb-spider':lambda:spider('orange'),'paper-wasp':lambda:wasp('gold'),'bog-leech':leech,
 'grumpy-lemming':lambda:quad('tan',ears='round',tail='short',mark='stripe',fat=1.05)+ln('M20 20l8 3M44 20l-8 3',INK,2.2),
 'bullfrog':lambda:frog('green',spots=True),'shore-crab':lambda:crab('orange'),'barn-rat':lambda:quad('grey',ears='round',tail='long',snout='long',whisk=True),
 'sun-lizard':lambda:lizard('gold',spots=True),'tunnel-mole':lambda:quad('dgrey',ears='none',snout='flat',whisk=False)+pa('M26 28l6 5 6 -5-6 -2z','#e46a9b')+el(32,28,3,2,'#e46a9b'),
 'carrion-crow':lambda:bird('ink',beak='short',wing='ink',belly='dgrey',bc='gold' if False else 'grey'),
 'herring-gull':lambda:bird('cream',beak='hook',wing='grey',belly='cream',bc='gold'),
 'dune-scorpion':lambda:scorpion('gold'),'frost-hare':lambda:quad('lblue',ears='long',tail='short',belly='cream',whisk=True),
 'giant-centipede':lambda:centipede('red'),'thistle-beast':thistle,
 'ember-beetle':lambda:beetle('ember' if 'ember' in C else 'red',glow=True),
 'will-o-wisp':lambda:wisp('lblue'),
 'grass-snake':lambda:snake('green',pat='stripe'),'grey-heron':lambda:bird('grey',neck=True,bc='gold'),
 'mischief-monkey':lambda:quad('brown',ears='round',tail='long',snout='flat',belly='tan',face='tan'),
 'red-fox':lambda:quad('orange',ears='point',tail='bushy',snout='long',belly='cream'),
 'raccoon':lambda:quad('grey',ears='round',tail='bushy',mark='mask',snout='short',belly='cream')+ln('M44 40q6 2 8 6M47 38q6 2 8 6',INK,2),
 'tawny-owl':lambda:bird('brown',owl=True,wing='dbrown',belly='tan'),
 'arctic-fox':lambda:quad('cream',ears='point',tail='bushy',snout='short',belly='cream',whisk=False),
 'badger':lambda:quad('grey',ears='round',tail='short',mark='stripe',snout='long',belly='dgrey'),
 'mire-toad':lambda:frog('olive',warts=True,big=1.05),'tide-crab-knight':lambda:crab('red',armor=True),
 'moss-golem':lambda:golem('rock'),
 'bramble-wolf':lambda:quad('dgrey',ears='point',tail='bushy',snout='long',belly='grey')+''.join(ln(p,C['moss'][0],2.4)+ci(x,y,1.6,C['petal'][0]) for p,x,y in(('M14 36q6 -6 10 2',24,38),('M40 34q6 -6 10 4',50,38),('M22 50q6 -4 10 2',32,52))),
 'coconut-crab-titan':lambda:crab('brown',armor=False),
 'great-hawk':lambda:bird('brown',beak='hook',wing='dbrown',belly='tan',crest=None),
 'ancient-snapper':lambda:turtle('olive','dbrown'),
 'reef-leviathan':lambda:fish('blue','eel'),'old-bramblehorn':lambda:quad('brown',ears='round',tail='short',snout='long',horns='antlers',belly='tan'),
 'dune-wyrm':lambda:snake('tan',pat='diamond',hood=True),'snow-owl-monarch':lambda:bird('cream',owl=True,wing='lblue',belly='cream'),
 'storm-eagle':lambda:bird('dusk' if False else 'purple',beak='hook',wing='dgrey' if False else 'purple',belly='lpurple',crest='tuft'),
 'jade-jaguar':lambda:quad('lgreen' if False else 'green',ears='round',tail='long',mark='spots',snout='short',belly='olive'),
 'delta-gharial':lambda:lizard('olive',kind='croc'),'emerald-python':lambda:snake('lgreen',pat='diamond'),
 'jungle-tiger':lambda:quad('orange',ears='round',tail='long',mark='stripes',snout='short',belly='cream'),
 'spice-monitor':lambda:lizard('brown',kind='monitor',spots=True),
 'cloud-leopard':lambda:quad('tan',ears='round',tail='long',mark='spots',snout='short',belly='cream'),
 'savanna-hyena':lambda:quad('tan',ears='round',tail='short',mark='spots',snout='long',belly='cream',mane=True),
 'mangrove-crab-king':lambda:crab('brown',king=True),'sand-viper-matriarch':lambda:snake('tan',pat='diamond',belly='cream'),
 'honey-badger-brute':lambda:quad('dgrey',ears='round',tail='short',mark='saddle',snout='short',belly='dgrey'),
 'thunder-yak':lambda:quad('dbrown',ears='floppy',tail='thin',snout='flat',horns='curl',fat=1.12,belly='brown'),
 'reef-eel-lord':lambda:fish('purple','eel'),'outback-dingo':lambda:quad('tan',ears='point',tail='bushy',snout='long',belly='cream'),
 'fern-cassowary':lambda:bird('ink',beak='short',crest='casque',wing='ink',belly='dgrey',bc='blue') ,
 'deep-octopus':lambda:octo('purple'),'hermit-crab-hoarder':lambda:crab('red',hermit=True),
 'sea-otter-bandit':lambda:quad('dbrown',ears='round',tail='thin',snout='short',mark='mask' if False else None,belly='tan',whisk=True),
 'dust-sidewinder':lambda:snake('tan',pat='stripe'),'poison-dart-frog':lambda:frog('blue',spots=True,bright=True),
 'reef-turtle':lambda:turtle('green','moss'),'leafcutter-column':leafcutter,
 'ptarmigan-flock':lambda:swarm(bird('cream',wing='tan',belly='cream'),[(0,6,.6),(26,4,.55),(14,22,.7)]),
 'bog-pike':lambda:fish('olive','pike'),'desert-gila-dragon':lambda:lizard('pink','lizard',spots=True),
 'cliff-ram':lambda:quad('tan',ears='round',tail='short',snout='short',horns='curl',belly='cream'),
 'wolverine':lambda:quad('dbrown',ears='round',tail='bushy',mark='saddle',snout='short',belly='brown'),
 'wild-boar':lambda:quad('dbrown',ears='point',tail='thin',snout='pig',tusks=True,fat=1.08,belly='brown'),
 'pelican-parliament':lambda:swarm(pelican(),[(-4,8,.62),(26,4,.58),(10,22,.7)]),
 'beaver-foreman':lambda:quad('brown',ears='round',tail='short',snout='short',belly='tan')+pa('M28 33h8v6h-8z',CREAM)+ln('M32 33v6',C['stone'][0],1)+el(32,56,9,3,C['dbrown'][1]),
 'giant-anteater':lambda:quad('grey',ears='round',tail='bushy',snout='trunk',belly='cream',mark='saddle'),
 'giant-bumblebee':lambda:wasp('gold',bee=True),'tufted-lynx':lambda:quad('tan',ears='tuft',tail='short',snout='short',belly='cream',mark='spots'),
 'clam-lurker':clam,'desert-tortoise':lambda:turtle('tan','brown'),
 'griffon-vulture':lambda:bird('tan',beak='hook',wing='brown',belly='cream',hood=False,crest=None),
 'black-bear':lambda:quad('ink',ears='round',tail='short',snout='long',belly='dgrey',fat=1.12),
 'salt-sea-lion':lambda:quad('brown',ears='none',tail='none',snout='flat',belly='tan',whisk=True,fat=1.1),
 'glacier-bear':lambda:quad('lblue',ears='round',tail='short',snout='long',belly='cream',fat=1.12),
 'prairie-bison':lambda:quad('dbrown',ears='round',tail='thin',snout='flat',horns='spike',mane=True,fat=1.12,belly='brown'),
 'desert-camel':lambda:quad('tan',ears='round',tail='thin',snout='long',belly='cream',fat=1.0)+''.join(el(x,38,6,8,C['tan'][0])+hl('M%s 32q3-3 6 0'%f(x-3)) for x in(21,43)),
 'lichen-reindeer':lambda:quad('grey',ears='round',tail='short',snout='long',horns='antlers',belly='cream')+ci(18,6,2.4,C['moss'][1])+ci(46,6,2.4,C['moss'][1]),
    }
    return T.get(S)
def slug_(c,kind,spots=False,shell=None): return slug(c,kind,spots,shell)

SZ={'small':.74,'medium':.88,'large':1.0,'boss':1.0}
# families that already fill the canvas (swarms / long things): do not shrink
FULL={'aphid-swarm','gnat-cloud','sand-fleas','leafcutter-column','ptarmigan-flock','pelican-parliament','ant-scouts','giant-centipede','cave-glowworm'}
def creature_svg(slug,name,size,land):
    fn=spec(slug,name,land)
    if fn is None: raise SystemExit('no spec '+slug)
    inner=fn(); s=SZ.get(size,1.0)
    boss=size=='boss'
    if slug in FULL: s=max(s,.95)
    o=''
    if boss: o+=ci(32,34,30,'#e8a317',' opacity=".22"')+ci(32,34,22,'#f5cf6a',' opacity=".22"')
    o+=el(32,57,16*s+4,3.2,'#000',' opacity=".15"')
    o+='<g transform="translate(32 57) scale(%s) translate(-32 -57)">%s</g>'%(f(s),inner)
    if boss:
        cy=57-(57-4)*s
        o+='<g transform="translate(32 %s)"><path d="M-8 3l-1-9 4 4 5-7 5 7 4-4-1 9z" fill="#e8a317"/><rect x="-9" y="3" width="18" height="3" rx="1.5" fill="#b07a10"/><circle cx="0" cy="-4" r="1.3" fill="#d6322b"/></g>'%f(max(cy-4,9))
    return svg(64,64,'Creature '+name,o,64)
def svg(w,hh,label,o,k):
    if k==64: border=''
    else: border=''
    return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 %d %d" role="img" aria-label="%s">%s%s</svg>'%(w,hh,label.replace('&','&amp;').replace('"',''),o,border)

# ---------- NPC portraits (80x100) ----------
BG=['#a4b86a','#a9d6ea','#f6b8cf','#c3b2ea','#f5cf6a','#c9c5bc','#7ab55c','#c9a96e']
CLO=[('#4f9a45','#2f5a2a'),('#3f8fb0','#25637d'),('#d6322b','#a8241f'),('#7a5cc0','#4e3a8a'),('#e8a317','#b07a10'),('#e46a9b','#a8241f'),('#9a6b3f','#7a4a1f'),('#8b8f96','#5b6470')]
HAT=[('#d6322b','#a8241f'),('#4f9a45','#2f5a2a'),('#3f8fb0','#25637d'),('#7a5cc0','#4e3a8a'),('#e8a317','#b07a10'),('#e46a9b','#a8241f'),('#9a6b3f','#7a4a1f')]
CX=40
def head(sp,seed):
    """returns (svg_before_hat, top_y, half_width, hatok)"""
    s=sp.lower(); o=''
    def face(c,sc,ly,eyes=True):
        return eyes
    if s=='hedgehog':
        for i in range(15):
            a=math.pi+ i*math.pi/14; x=CX+23*math.cos(a); y=52+23*math.sin(a); o+=pa('M%s %sL%s %sL%s %sz'%(f(CX+17*math.cos(a-.12)),f(52+17*math.sin(a-.12)),f(x+4*math.cos(a)),f(y+4*math.sin(a)-1),f(CX+17*math.cos(a+.12)),f(52+17*math.sin(a+.12))),'#3d2a1c' if i%2 else '#7a4a1f')
        o+=el(CX,52,22,20,'#7a4a1f')+el(CX,56,17,16,'#f1ece0')+el(CX,50,18,7,'#f1ece0')+el(CX,62,5,4,INK)+eye(32,50,2.6)+eye(48,50,2.6)+ci(27,58,3,'#f6b8cf',' opacity=".7"')+ci(53,58,3,'#f6b8cf',' opacity=".7"')+ln('M36 67q4 3 8 0',INK,1.6)
        return o,30,20,True
    if s in('mouse','field mouse','dormouse','shrew'):
        col={'mouse':'tan','field mouse':'brown','dormouse':'gold','shrew':'grey'}[s]; b,d,l=C[col]
        o+=ci(24,36,11,b)+ci(56,36,11,b)+ci(24,36,7,'#f6b8cf')+ci(56,36,7,'#f6b8cf')
        o+=el(CX,52,21,19,b)+el(CX,60,13,10,l)+el(CX,58,4.5,3.5,'#e46a9b')+eye(31,50,3)+eye(49,50,3)+ln('M26 60h-9M26 63l-8 3M54 60h9M54 63l8 3','#fff',1.4)+ln('M37 66q3 2 6 0',INK,1.5)
        if s=='shrew': o+=pa('M32 56q8 14 16 0q-8 -16 -16 0z',b)
        return o,34,20,True
    if s in('frog','toad'):
        b,d,l=C['green'] if s=='frog' else C['olive']
        o+=el(CX,56,26,20,b)+el(CX,62,17,10,l)+ci(26,36,10,b)+ci(54,36,10,b)+ci(26,36,7.5,CREAM)+ci(54,36,7.5,CREAM)+ci(27,37,4.2,INK)+ci(53,37,4.2,INK)+ci(26,35,1.4,WH)+ci(52,35,1.4,WH)
        o+=ln('M22 62q18 12 36 0',INK,2.2)+ci(36,53,1.4,d)+ci(44,53,1.4,d)
        if s=='toad': o+=''.join(ci(x,y,2.4,d) for x,y in((22,50),(58,52),(30,70),(52,68),(40,44)))
        else: o+=ci(24,60,3.5,'#f6b8cf',' opacity=".7"')+ci(56,60,3.5,'#f6b8cf',' opacity=".7"')
        return o,30,24,True
    if s=='mole':
        b,d,l=C['dgrey']
        o+=el(CX,52,22,20,b)+el(CX,54,15,12,C['grey'][0])+''.join(ci(CX+7*math.cos(t),60+7*math.sin(t),2.1,'#e46a9b') for t in[i*math.pi/4 for i in range(8)])+ci(CX,60,3.5,'#e46a9b')+ci(30,48,1.8,INK)+ci(50,48,1.8,INK)
        o+=ln('M34 70q6 3 12 0',INK,1.6)+el(22,64,6,4,'#f6b8cf')+el(58,64,6,4,'#f6b8cf') if False else ''
        o=el(CX,52,22,20,b)+el(CX,66,12,10,'#c9c5bc')+''.join(pa('M%s %sl%s %s'%(f(CX),f(62),f(6*math.cos(t)),f(6*math.sin(t))),'none',' stroke="#f6b8cf" stroke-width="2.2" stroke-linecap="round"') for t in[i*math.pi/4 for i in range(8)])+ci(CX,62,4,'#e46a9b')+ci(31,48,1.8,INK)+ci(49,48,1.8,INK)+ln('M34 74q6 3 12 0',INK,1.6)
        return o,32,21,True
    if s=='hare':
        b,d,l=C['tan']
        o+=el(30,16,6,20,b)+el(50,16,6,20,b)+el(30,17,3,15,'#f6b8cf')+el(50,17,3,15,'#f6b8cf')+el(CX,52,20,19,b)+el(CX,60,12,9,CREAM)+el(CX,57,3.5,2.6,'#e46a9b')+eye(32,50,2.8)+eye(48,50,2.8)+ln('M37 64q3 2 6 0',INK,1.5)+ln('M28 60h-9M52 60h9','#fff',1.4)
        return o,34,18,False
    if s=='snail':
        b,d,l=C['tan']
        o+=ci(52,40,17,C['brown'][0])+ln('M52 40m-4 0a4 4 0 1 1 4 4a8 8 0 1 1 -8 -8a12 12 0 1 1 12 12',C['soil'][1],2)+el(CX-4,58,19,19,b)+el(CX-4,64,12,9,l)
        o+=ln('M30 40q-5 -12 -9 -13M42 40q0 -13 3 -15',b,3)+ci(21,26,3.4,CREAM)+ci(45,24,3.4,CREAM)+ci(21,26,1.8,INK)+ci(45,24,1.8,INK)+ci(32,54,2.2,INK)+ci(44,54,2.2,INK)+ln('M34 64q4 3 8 0',INK,1.6)
        return o,36,20,True
    if s in('bumblebee',):
        b,d,l=C['gold']
        o+=el(20,36,10,6,'#fff',' opacity=".6"')+el(60,36,10,6,'#fff',' opacity=".6"')+ln('M32 36q-5 -14 -11 -14M48 36q5 -14 11 -14',INK,2)+ci(21,22,2.6,INK)+ci(59,22,2.6,INK)
        o+=el(CX,54,21,20,b)+pa('M20 46q20 -8 40 0M20 58q20 -6 40 0','none',' stroke="%s" stroke-width="5"'%INK)+eye(32,52,2.8)+eye(48,52,2.8)+ln('M35 62q5 3 10 0',INK,1.6)+ci(27,58,2.8,'#f6b8cf',' opacity=".7"')+ci(53,58,2.8,'#f6b8cf',' opacity=".7"')
        return o,35,20,True
    if s=='ladybird':
        o+=ln('M32 36q-6 -12 -10 -12M48 36q6 -12 10 -12',INK,2)+ci(22,24,2.4,INK)+ci(58,24,2.4,INK)
        o+=el(CX,54,22,20,'#d6322b')+pa('M18 44q22 -12 44 0q-4 -8 -22 -10q-18 2 -22 10z','#2b2b2b')+''.join(ci(x,y,3.4,INK) for x,y in((26,62),(54,62),(40,70)))+eye(32,52,3)+eye(48,52,3)+ln('M35 62q5 3 10 0',INK,1.6)+ci(CX,38,0.01,INK)
        return o,34,20,True
    if s in('beetle','stag beetle'):
        b,d,l=C['dgrey'] if s=='beetle' else C['dbrown']
        o+=ln('M34 38q-5 -10 -10 -10M46 38q5 -10 10 -10',INK,2)
        o+=el(CX,54,21,20,b)+hl_('M26 44q4 -8 12 -8')+eye(32,52,3)+eye(48,52,3)+ln('M35 62q5 3 10 0',INK,1.6)
        if s=='stag beetle': o+=ln('M24 62q-8 6 -3 14q4 -6 10 -8M56 62q8 6 3 14q-4 -6 -10 -8',C['soil'][1],3.5)
        else: o+=ln('M40 36v8',d,2)
        return o,34,20,True
    if s=='grasshopper':
        b,d,l=C['lgreen']
        o+=ln('M32 36q-8 -20 -18 -22M48 36q8 -20 18 -22',INK,1.8)
        o+=pa('M20 56q0 -22 20 -22q20 0 20 22q-2 18 -20 18q-18 0 -20 -18z',b)+ci(28,48,6.5,CREAM)+ci(52,48,6.5,CREAM)+ci(28,49,3.4,INK)+ci(52,49,3.4,INK)+ci(27,47,1.2,WH)+ci(51,47,1.2,WH)+ln('M34 64q6 4 12 0',INK,1.8)+ln('M40 36v8',d,2)
        return o,34,20,True
    if s=='tortoise':
        b,d,l=C['olive']
        o+=pa('M10 50q4 -34 30 -34q26 0 30 34z',C['brown'][0])+''.join(ln(p,C['soil'][1],2) for p in('M40 16v34','M22 22l6 28','M58 22l-6 28','M14 38h52'))
        o+=el(CX,60,18,17,b)+ci(CX,46,0.01,b)+el(CX,66,10,8,l)+eye(33,56,2.6)+eye(47,56,2.6)+ln('M35 68q5 3 10 0',INK,1.6)+ln('M28 50q4 -3 8 0M44 50q4 -3 8 0',d,1.6)
        return o,30,28,False
    if s=='wren':
        b,d,l=C['brown']
        o+=pa('M16 50q0 -24 24 -24q24 0 24 24q0 22 -24 22q-24 0 -24 -22z',b)+el(CX,62,14,10,C['tan'][2])+pa('M10 36q-4 -2 -4 -8q8 0 12 8z',d)
        o+=pa('M36 52h8l-4 8z','#e8a317')+ci(30,46,3.4,WH)+ci(50,46,3.4,WH)+ci(30.4,46.4,1.9,INK)+ci(50.4,46.4,1.9,INK)+ln('M24 40l8 3M56 40l-8 3',d,2)
        return o,28,22,True
    if s=='dragonfly':
        b,d,l=C['water'][1],C['water'][2],'#a9d6ea'
        o+=el(14,50,13,7,'#fff',' opacity=".55"')+el(66,50,13,7,'#fff',' opacity=".55"')+el(18,62,12,6,'#fff',' opacity=".45"')+el(62,62,12,6,'#fff',' opacity=".45"')
        o+=el(CX,52,17,19,C['water'][0])+ci(26,46,11,C['moss'][0] if False else '#2f5a2a')+ci(54,46,11,'#2f5a2a')+ci(26,46,8,'#7ab55c')+ci(54,46,8,'#7ab55c')+ci(26,47,3.4,INK)+ci(54,47,3.4,INK)+ln('M34 64q6 3 12 0',INK,1.6)
        return o,34,26,True
    if s=='gecko':
        b,d,l=C['olive']
        o+=el(CX,54,22,19,b)+''.join(ci(x,y,2.2,C['moss'][1]) for x,y in((26,40),(54,42),(34,36),(46,36)))+ci(28,44,8,CREAM)+ci(52,44,8,CREAM)+ci(28,45,4,INK)+ci(52,45,4,INK)+ci(27,43,1.4,WH)+ci(51,43,1.4,WH)+ln('M24 62q16 10 32 0',INK,1.8)+el(CX,72,10,3,l)
        return o,34,22,True
    if s=='butterfly':
        b,d,l=C['petal']
        o+=pa('M32 54C14 24 0 34 6 54c4 14 20 14 26 0z',b)+pa('M48 54C66 24 80 34 74 54c-4 14 -20 14 -26 0z',b)+ci(14,46,4,CREAM)+ci(66,46,4,CREAM)
        o+=ln('M34 36q-5 -12 -12 -12M46 36q5 -12 12 -12',INK,1.8)+ci(22,24,2.4,INK)+ci(58,24,2.4,INK)
        o+=el(CX,56,15,19,C['gold'][1] if False else '#f5cf6a')+eye(34,52,2.6)+eye(46,52,2.6)+ln('M36 62q4 3 8 0',INK,1.6)
        return o,36,16,True
    if s=='stick insect':
        b,d,l=C['brown']
        o+=ln('M34 34q-6 -16 -16 -18M46 34q6 -16 16 -18',d,1.8)+pa('M30 28q10 -6 20 0q4 20 2 38q-12 8 -24 0q-2 -18 2 -38z',b)+ln('M40 28v40',d,1.6)+eye(34,44,2.6)+eye(46,44,2.6)+ln('M36 58q4 3 8 0',INK,1.5)+''.join(ln('M%s %sl2 3'%(f(x),f(y)),d,1.4) for x,y in((34,32),(46,36),(34,52)))
        return o,28,12,True
    if s=='moth':
        b,d,l=C['lpurple']
        o+=pa('M32 54C12 24 2 40 8 58c6 10 20 8 24 -4z',b)+pa('M48 54C68 24 78 40 72 58c-6 10 -20 8 -24 -4z',b)+ci(16,50,5,CREAM)+ci(64,50,5,CREAM)+ci(16,50,2.4,INK)+ci(64,50,2.4,INK)
        o+=ln('M34 36q-8 -8 -8 -18M46 36q8 -8 8 -18',d,2)+''.join(ln('M%s %sl%s -3'%(f(x),f(y),f(s_*3)),d,1.4) for x,y,s_ in((26,28,-1),(54,28,1),(27,22,-1),(53,22,1)))
        o+=el(CX,56,16,19,CREAM)+eye(34,52,2.6)+eye(46,52,2.6)+ln('M36 62q4 3 8 0',INK,1.6)+ci(31,58,2.4,'#f6b8cf',' opacity=".7"')+ci(49,58,2.4,'#f6b8cf',' opacity=".7"')
        return o,34,16,True
    if s=='firefly':
        b,d,l=C['dbrown']
        o+=ci(CX,64,28,'#f5cf6a',' opacity=".35"')+ci(CX,64,20,'#f5cf6a',' opacity=".4"')+ln('M34 36q-5 -10 -10 -10M46 36q5 -10 10 -10',INK,2)+el(CX,52,18,18,C['soil'][1])+el(CX,68,11,8,'#f5cf6a')+eye(34,50,2.8)+eye(46,50,2.8)+ln('M36 60q4 3 8 0',CREAM,1.6)
        return o,34,18,True
    if s=='bat':
        b,d,l=C['dusk']
        o+=pa('M8 52q0 -18 8 -26q4 8 12 10q-6 6 -2 14z',b[1] if False else C['dusk'][1])+pa('M72 52q0 -18 -8 -26q-4 8 -12 10q6 6 2 14z',C['dusk'][1])
        o+=pa('M26 38l-4 -20 12 12zM54 38l4 -20 -12 12z',C['dusk'][0])+pa('M27 33l-2 -10 6 6zM53 33l2 -10 -6 6z','#f6b8cf')
        o+=el(CX,54,19,19,C['dusk'][0])+el(CX,62,11,9,C['dusk'][2])+eye(33,50,2.8)+eye(47,50,2.8)+pa('M36 64l1.5 4 1.5 -3zM44 64l-1.5 4 -1.5 -3z','#fff')+ln('M36 62q4 2 8 0',INK,1.4)
        return o,34,18,False
    # fallback round critter
    o+=el(CX,52,20,19,'#c9a96e')+eye(32,50,3)+eye(48,50,3)+ln('M36 62q4 3 8 0',INK,1.6)
    return o,34,20,True
def hl_(d): return '<path d="%s" fill="none" stroke="#fff" stroke-width="2.4" stroke-linecap="round" opacity=".4"/>'%d

def hat(kind,top,hw,col):
    a,b=col; o=''
    if kind=='pointy':
        o+=pa('M%s %sQ%s %s %s %sL%s %sZ'%(f(CX-hw-3),f(top+8),f(CX+2),f(top-6),f(CX+8),f(top-26),f(CX+hw+3),f(top+8)),a)
        o+=el(CX,top+8,hw+8,4.5,b)+ln('M%s %sq%s %s %s %s'%(f(CX+8),f(top-26),f(8),f(2),f(7),f(10)),a,5) if False else el(CX,top+8,hw+8,4.5,b)+pa('M%s %sl2 -4 3 4z'%(f(CX+5),f(top-22)),b)
        o+=hl_('M%s %sq3 -8 8 -14'%(f(CX-hw+2),f(top+3)))
    elif kind=='cap':
        o+=pa('M%s %sq%s %s %s %sz'%(f(CX-hw-2),f(top+8),f(hw+2),f(-22),f(2*hw+4),f(0)),a)+pa('M%s %sq%s 5 %s 0q-2 -5 -%s -2z'%(f(CX+2),f(top+8),f(16),f(14),f(14)),b)+ci(CX,top-6,2.4,b)
    elif kind=='straw':
        o+=el(CX,top+8,hw+14,5.5,'#c9a96e')+pa('M%s %sq%s -20 %s 0z'%(f(CX-hw),f(top+8),f(hw),f(2*hw)),'#e8a317' if False else '#f5cf6a')+pa('M%s %sh%sv-4h-%sz'%(f(CX-hw+1),f(top+4),f(2*hw-2),f(2*hw-2)),a)
    elif kind=='bonnet':
        o+=pa('M%s %sq%s -24 %s 0q2 12 -2 22h-4q2 -12 -%s -18q-%s 6 -%s 18h-4q-4 -10 0 -22z'%(f(CX-hw-3),f(top+14),f(hw+3),f(2*hw+6),f(hw+3),f(hw),f(hw)),a) if False else pa('M%s %sq%s -26 %s 0q2 10 -2 24l-8 -10q-%s -6 -%s 0l-8 10q-4 -14 0 -24z'%(f(CX-hw-3),f(top+16),f(hw+3),f(2*hw+6),f(hw-4),f(2*hw-16)),a)+ln('M%s %sq%s 6 %s 0'%(f(CX-hw),f(top+6),f(hw),f(2*hw)),b,2.4)
    elif kind=='flowers':
        for i,x in enumerate(range(CX-hw+2,CX+hw-1,7)): o+=ci(x,top+8-(i%2)*2,3.4,['#e46a9b','#f5cf6a','#f4f0e0','#c3b2ea'][i%4])+ci(x,top+8-(i%2)*2,1.2,'#e8a317')
        o+=ln('M%s %sq%s 3 %s 0'%(f(CX-hw),f(top+10),f(hw),f(2*hw)),'#4f9a45',2)
    elif kind=='hood':
        o+=pa('M%s %sq0 -26 %s -26q%s 0 %s 26q-%s -10 -%s -10q-%s 0 -%s 10z'%(f(CX-hw-5),f(top+22),f(hw+5),f(hw+5),f(hw+5),f(hw+5),f(hw*2),f(0),f(0)) ,a) if False else pa('M%s %sQ%s %s %s %sQ%s %s %s %sQ%s %s %s %sQ%s %s %s %sZ'%(f(CX-hw-6),f(top+26),f(CX-hw-8),f(top-10),f(CX),f(top-8),f(CX+hw+8),f(top-10),f(CX+hw+6),f(top+26),f(CX+hw-2),f(top+12),f(CX),f(top+8),f(CX-hw+2),f(top+12),f(CX-hw-6),f(top+26)),a)
    elif kind=='band':
        o+=pa('M%s %sq%s -8 %s 0v5q-%s -8 -%s 0z'%(f(CX-hw),f(top+9),f(hw),f(2*hw),f(hw),f(hw)),a) if False else ln('M%s %sq%s -6 %s 0'%(f(CX-hw+1),f(top+10),f(hw-1),f(2*hw-2)),a,5)+ci(CX+hw-6,top+7,3,b)
    return o

def npc_svg(slug,name,species):
    sd=slug; bg=pick(sd,BG,0); cl=pick(sd,CLO,3); ht=pick(sd,HAT,6)
    o=ci(CX,50,36,bg)+ci(CX,50,36,'#fff',' opacity=".18"')
    # body
    o+=pa('M6 100Q6 78 40 76Q74 78 74 100z',cl[0])+pa('M30 78Q40 90 50 78l-3 -3h-14z',cl[1])
    style=h(sd)>>9
    deco=['collar','apron','scarf','buttons','bare'][style%5]
    if deco=='apron': o+=pa('M26 82h28l4 18h-36z','#f4f0e0')+ln('M28 80l4 6M52 80l-4 6','#f4f0e0',2)
    elif deco=='scarf': o+=ln('M28 79q12 8 24 0',ht[0],6)+pa('M48 80l3 16h-6z',ht[0])
    elif deco=='buttons': o+=ln('M40 84v14',cl[1],1.5)+ci(40,88,1.6,'#f5cf6a')+ci(40,94,1.6,'#f5cf6a')
    elif deco=='collar': o+=pa('M30 77l10 10 10 -10',CREAM)
    inner,top,hw,hatok=head(species,sd)
    o+=inner
    if hatok:
        kinds=['pointy','pointy','cap','straw','bonnet','flowers','hood','band','none']
        k=kinds[(h(sd)>>12)%len(kinds)]
        o+=hat(k,top,hw,ht)
    else:
        o+=hat(['flowers','band'][h(sd)%2],top+10,10,ht) if species.lower()=='hare' else ''
    o+=ln('M16 18q6 -8 14 -9','#fff',3).replace('stroke-width="3"','stroke-width="3" opacity=".3"') if False else ''
    return svg(80,100,'Portrait of '+name+' the '+species.lower(),o,80)

def main():
    os.makedirs(OUT,exist_ok=True)
    nc=0; big=[]
    for ln_ in open(CRE,encoding='utf8'):
        ln_=ln_.strip()
        if not ln_ or ln_.startswith('#'): continue
        p=ln_.split('|'); s,n,sz,land=p[0],p[1],p[2],p[3]
        t=creature_svg(s,n,sz,land); open('%s/creature-%s.svg'%(OUT,s),'w',encoding='utf8').write(t); nc+=1
        if len(t)>4000: big.append(s)
    nn=0
    for ln_ in open(NPC,encoding='utf8'):
        ln_=ln_.strip()
        if not ln_: continue
        s,n,sp=ln_.split('|')
        t=npc_svg(s,n,sp); open('%s/npc-%s.svg'%(OUT,s),'w',encoding='utf8').write(t); nn+=1
        if len(t)>4000: big.append(s)
    print('creatures',nc,'npcs',nn,'over4k',big)
main()
