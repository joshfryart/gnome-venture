#!/usr/bin/env python3
"""Batch C plain-source icon redraws -> tests/ico_src/ico-<slug>.svg. stdlib only.
Restyle only these slugs: python3 tests/gen_ico_fix_c.py build"""
import os, sys, math
HERE = os.path.dirname(os.path.abspath(__file__)); OUT = os.path.join(HERE, 'ico_src')
U='#2a1a10'; CR='#f8eed2'; W='#a5663a'; DW='#8c4a1a'; GO='#dcb06a'; YE='#f2cf4a'; LF='#58a03e'; DL='#2e5a2c'
RD='#9c2a1e'; PK='#d9667f'; LP='#e8a0a8'; WA='#3f93b2'; ST='#968f96'; DS='#6a6070'; SK='#e9b98a'; OR='#e0832a'
def f(v): return ('%.1f' % v).rstrip('0').rstrip('.')
def circ(x,y,r,c): return '<circle cx="%s" cy="%s" r="%s" fill="%s"/>' % (f(x),f(y),f(r),c)
def ell(x,y,rx,ry,c,rot=0): return '<ellipse cx="%s" cy="%s" rx="%s" ry="%s" fill="%s"%s/>' % (f(x),f(y),f(rx),f(ry),c,(' transform="rotate(%s %s %s)"' % (f(rot),f(x),f(y))) if rot else '')
def rect(x,y,w,h,c,rx=0): return '<rect x="%s" y="%s" width="%s" height="%s" fill="%s"%s/>' % (f(x),f(y),f(w),f(h),c,(' rx="%s"' % f(rx)) if rx else '')
def poly(p,c): return '<polygon points="%s" fill="%s"/>' % (' '.join('%s,%s' % (f(a),f(b)) for a,b in p),c)
def path(d,c): return '<path d="%s" fill="%s"/>' % (d,c)
def stroke(d,c,w): return '<path d="%s" fill="none" stroke="%s" stroke-width="%s" stroke-linecap="round" stroke-linejoin="round"/>' % (d,c,w)
def ln(x1,y1,x2,y2,c,w=5): return stroke('M%s %sL%s %s' % (f(x1),f(y1),f(x2),f(y2)),c,w)
def grp(rot,cx,cy,inner): return '<g transform="rotate(%s %s %s)">%s</g>' % (f(rot),f(cx),f(cy),inner)
def qb(p0,c,p1,t): return tuple((1-t)**2*p0[i]+2*(1-t)*t*c[i]+t*t*p1[i] for i in (0,1))
def qd(p0,c,p1,t): return tuple(2*(1-t)*(c[i]-p0[i])+2*t*(p1[i]-c[i]) for i in (0,1))
I = {}

# worm: horizontal wiggle, head right
P0,C1,P1,C2,P2 = (11,44),(19,22),(30,35),(41,48),(47,28)
body = 'M%d %dQ%d %d %d %dQ%d %d %d %d' % (P0+C1+P1+C2+P2)
segs=''
for (a,c,b,t) in ((P0,C1,P1,.45),(P0,C1,P1,.9),(P1,C2,P2,.5)):
    x,y = qb(a,c,b,t); dx,dy = qd(a,c,b,t); L=math.hypot(dx,dy); nx,ny=-dy/L,dx/L
    segs += ln(x-nx*4.2,y-ny*4.2,x+nx*4.2,y+ny*4.2,PK,5)
I['worm'] = ('worm', stroke(body,LP,11)+segs+circ(49,27,8.5,LP)+circ(52,25,2.8,U))

# handbag: drawstring pouch
I['handbag'] = ('drawstring pouch',
    path('M24 25C12 30 7 42 12 51Q17 58 32 58Q47 58 52 51C57 42 52 30 40 25Z',W)
    +path('M25 25L18 10Q25 16 32 9Q39 16 46 10L39 25Z',DW)
    +rect(22,22,20,6,YE,3)+stroke('M37 27Q43 33 41 43',YE,5)+stroke('M27 27Q22 33 24 41',YE,5))

# grain: wheat V
def stalk(tx,ty):
    bx,by = 32,58; L=math.hypot(tx-bx,ty-by); ux,uy=(tx-bx)/L,(ty-by)/L; px,py=-uy,ux
    ang=math.degrees(math.atan2(uy,ux))+90
    o=[ln(bx,by,tx-ux*8,ty-uy*8,GO,5)]
    for t in (-18,-9,0):
        cx,cy=tx+ux*t,ty+uy*t
        for s in (-1,1): o.append(ell(cx+px*4.5*s,cy+py*4.5*s,4,6.5,YE,ang+s*22))
    o.append(ell(tx+ux*3,ty+uy*3,3.6,7,YE,ang)); o.append(ln(tx+ux*8,ty+uy*8,tx+ux*14,ty+uy*14,W,5))
    return ''.join(o)
I['grain'] = ('wheat', stalk(10,34)+stalk(54,34)+stalk(32,26)+rect(23,45,18,6,RD,2))

# ruin
I['ruin'] = ('ruin',
    rect(7,50,50,7,DS,1)
    +poly([(10,50),(10,30),(14,26),(18,31),(22,25),(22,50)],ST)
    +poly([(25,50),(25,22),(29,13),(33,19),(37,9),(41,18),(41,50)],ST)
    +poly([(44,50),(44,36),(48,31),(52,38),(54,34),(54,50)],ST)
    +rect(31,22,5,28,DS)+rect(14,36,4,14,DS)
    +rect(8,46,8,6,DS,1)+rect(50,45,8,7,ST,1)+rect(40,52,7,5,ST,1))

# path
pts=[]
for i in range(0,11):
    t=i/10; y=58-46*t; x=32+11*math.sin(t*5.2)*(1-.3*t); w=15-9*t; pts.append((x,y,w))
Lp=[(x-w,y) for x,y,w in pts]; Rp=[(x+w,y) for x,y,w in pts]
I['path'] = ('winding path',
    path('M8 54Q6 34 16 22Q22 12 32 10Q44 12 50 22Q58 34 56 54Q32 62 8 54Z',LF)
    +poly(Lp+Rp[::-1],GO)
    +ell(pts[1][0],pts[1][1],5,3.2,CR)+ell(pts[4][0]+3,pts[4][1],4.5,3,CR)+ell(pts[7][0]-1,pts[7][1],3.5,2.6,CR))

# compost
I['compost'] = ('compost heap',
    path('M10 44Q12 28 32 26Q52 28 54 44Z',U)
    +poly([(8,42),(56,42),(52,58),(12,58)],DW)+rect(11,47,42,5,W)
    +stroke('M13 24Q18 15 28 19',OR,5)
    +path('M30 24Q30 17 38 16Q44 17 44 24Q44 28 41 28L41 30L33 30L33 28Q30 28 30 24Z',CR)+rect(35,18,4,5,RD)
    +path('M46 26Q48 17 56 17Q56 25 46 26Z',LF))

# wind chime
I['wind-chime'] = ('wind chime',
    stroke('M32 14V9',ST,5)+circ(32,8.5,3.5,ST)
    +rect(10,15,44,8,W,4)
    +ln(14,23,14,31,ST)+ln(50,23,50,34,ST)+ln(32,23,32,38,ST)
    +rect(10,31,8,23,GO,3)+rect(46,34,8,14,GO,3)+rect(28,36,8,16,YE,3)
    +circ(32,56,4,W) if False else
    stroke('M32 15V10',ST,5)+ell(32,10,4,4,ST)
    +rect(9,15,46,8,W,4)
    +ln(13,23,13,30,ST)+ln(51,23,51,34,ST)+ln(32,23,32,31,ST)
    +rect(9,30,8,26,GO,3)+rect(47,34,8,14,GO,3)+rect(28,31,8,16,YE,3)+circ(32,54,4.5,W))

# clap
hand = lambda mir: (
    rect(-3,0,0,0,SK)+'')
def hnd(sgn):
    cx = 32; a = sgn*14
    inner = rect(22,24,17,32,SK,7)+ell(22,44,4.5,7,SK,-sgn*20)   # palm + thumb
    inner += ln(27,25,27,34,W,3.2)+ln(33,25,33,34,W,3.2)
    return inner
left = grp(-16,32,56,rect(14,18,17,38,SK,7)+ln(20,19,20,29,DW,3)+ln(26,19,26,29,DW,3))
right = grp(16,32,56,rect(33,18,17,38,SK,7)+ln(38,19,38,29,DW,3)+ln(44,19,44,29,DW,3))
I['clap'] = ('clapping hands', left+right+ln(32,6,32,12,YE)+ln(14,10,18,15,YE)+ln(50,10,46,15,YE))

# otter
I['otter'] = ('otter',
    stroke('M6 53Q13 48 20 53T34 53T48 53T58 51',WA,5)
    +ell(11,44,7,4.5,DW,-10)+ell(28,40,19,10,W)+ell(28,37,12,5,CR)
    +ell(24,39,3,2.6,W)+ell(33,39,3,2.6,W)
    +circ(47,32,9,W)+circ(41,25,3.5,DW)+ell(53,35,5,3.8,CR)+circ(56,34,2.4,U)+circ(48,29,2,U))

# deer
I['deer'] = ('deer',
    ln(25,24,21,10,GO)+ln(23,17,15,14,GO)+ln(39,24,43,10,GO)+ln(41,17,49,14,GO)
    +ell(14,31,5.5,10,DW,-40)+ell(50,31,5.5,10,DW,40)
    +poly([(19,24),(45,24),(41,46),(32,57),(23,46)],W)+ell(14,31,2.3,6,LP,-40)+ell(50,31,2.3,6,LP,40)
    +ell(32,49,8.5,6.5,CR)+circ(32,46,3,U)+circ(24,36,2.6,U)+circ(40,36,2.6,U))

# telescope
tube = (rect(6,28,9,8,DW,2)+rect(14,26,22,12,GO,2)+rect(35,24,12,16,YE,2)
        +poly([(46,23),(58,16),(58,48),(46,41)],GO)+poly([(58,18),(58,46),(61,48),(61,16)],CR) if False else
        rect(5,28,9,8,DW,2)+rect(13,26,22,12,GO,2)+rect(34,24,12,16,YE,2)+poly([(45,22),(56,15),(56,49),(45,42)],GO)+rect(52,19,5,26,CR,1))
I['telescope'] = ('telescope',
    ln(31,36,22,56,W)+ln(31,36,40,56,W)+grp(-30,32,32,tube.replace('','')) )
I['telescope'] = ('telescope',
    ln(30,34,21,56,W)+ln(30,34,41,56,W)+'<g transform="translate(32 26) scale(.85) translate(-32 -32)">'+grp(-30,32,32,tube)+'</g>')

if __name__ == '__main__':
    os.makedirs(OUT, exist_ok=True)
    for n,(label,body) in I.items():
        open(os.path.join(OUT,'ico-%s.svg'%n),'w',encoding='utf-8').write('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64" role="img" aria-label="%s">%s</svg>' % (label,body))
    print('wrote',len(I))
    if len(sys.argv)>1 and sys.argv[1]=='build':
        os.environ['PYTHONHASHSEED']='1'
        sys.path.insert(0,HERE); import hearth
        D=os.path.join(os.path.dirname(HERE),'game/assets/img/ico')
        for n in I:
            s='ico-'+n
            o=hearth.restyle(open(os.path.join(OUT,s+'.svg'),encoding='utf-8').read(),s)
            open(os.path.join(D,s+'.svg'),'w',encoding='utf-8').write(o)
        print('built',len(I))
