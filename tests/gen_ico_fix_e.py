#!/usr/bin/env python3
"""Batch E (final round) plain-source icon redraws -> tests/ico_src/ico-<slug>.svg. stdlib only.
Restyle only these slugs: python3 tests/gen_ico_fix_e.py build"""
import os, sys, math
HERE = os.path.dirname(os.path.abspath(__file__)); OUT = os.path.join(HERE, 'ico_src')
U='#2a1a10'; CR='#f8eed2'; W='#a5663a'; DW='#8c4a1a'; GO='#dcb06a'; YE='#f2cf4a'; LF='#58a03e'; DL='#2e5a2c'
RD='#9c2a1e'; PK='#d9667f'; LP='#e8a0a8'; WA='#3f93b2'; ST='#968f96'; DS='#6a6070'; SK='#e9b98a'; OR='#e8892a'
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
BR='#b8893f'; UM=U
# handbag: small purse
I['handbag'] = ('handbag',
    stroke('M15 30Q15 13 32 13Q49 13 49 30',RD,5)
    +rect(6,27,52,28,PK,9)+path('M6 36Q6 27 15 27H49Q58 27 58 36Q58 40 52 41L36 47Q32 49 28 47L12 41Q6 40 6 36Z',RD)+circ(32,42,4.5,CR))

# money-bag: tied sack
I['money-bag'] = ('money bag',
    path('M24 24C8 32 6 49 15 54Q32 59 49 54C58 49 56 32 40 24Z',W)
    +path('M21 8Q27 15 32 10Q37 15 43 8L41 22H23Z',DW)+rect(21,21,22,6,YE,3)
    +circ(32,41,8.5,YE)+circ(32,41,3.5,GO)
    +circ(13,52,4.8,YE)+circ(51,52,4.8,YE))

# porridge: wide shallow bowl
I['porridge'] = ('porridge',
    path('M13 36Q14 21 32 21Q50 21 51 36Z',CR)+rect(26,16,11,9,YE,2.5)
    +ln(37,31,51,15,W,5)+ell(53,13,5.5,4,W,-50)
    +path('M6 35H58Q58 55 32 55Q6 55 6 35Z',WA)+rect(6,33,52,6,GO,3))

# pancakes
I['pancakes'] = ('pancakes',
    rect(9,43,46,13,GO,6.5)+rect(9,32,46,13,W,6.5)+rect(9,21,46,13,GO,6.5)
    +ell(32,26,14,4.2,OR)+ln(46,27,46,48,OR,5.5)+rect(24,12,15,10,YE,2.5))

# fist
I['fist'] = ('fist',
    rect(9,21,46,35,SK,11)+circ(14.8,23,6.5,SK)+circ(26.3,21,6.5,SK)+circ(37.8,21,6.5,SK)+circ(49.2,23,6.5,SK)
    +ln(20.5,20,20.5,37,DW,5)+ln(32,18,32,37,DW,5)+ln(43.5,20,43.5,37,DW,5)
    +rect(5,36,40,17,DW,8.5)+rect(7.5,38.5,35,12,SK,6)+ln(48,40,48,50,DW,5))

# compost
I['compost'] = ('compost bin',
    ell(20,16,8.5,5.5,RD)+ln(20,16,20,29,YE,6)+ell(20,29,8.5,5.5,RD)
    +stroke('M31 32Q33 14 45 19',YE,6)
    +ln(51,32,51,21,LF,5)+ell(56,20,5,3.5,LF,-25)+ell(46,23,5,3.5,LF,25)
    +rect(8,31,48,25,DW,4)+ln(12,40,52,40,U,5)+ln(12,50,52,50,U,5))

# burst
import random
random.seed(7)
def star(cx,cy,n,ro,ri,rot):
    pts=[]
    for i in range(2*n):
        r=(ro if i%2==0 else ri)*(0.82+0.18*((i*37)%5)/4) if i%2==0 else ri
        a=math.radians(rot+i*180/n); pts.append((cx+r*math.cos(a),cy+r*math.sin(a)))
    return pts
I['burst'] = ('burst',
    poly(star(32,32,9,27,13,-90),OR)+poly(star(32,32,9,17,8,-70),CR))

# staff
I['staff'] = ('staff',
    ln(12,55,40,26,W,6)+ell(41,25,9,5,BR,-45)+circ(45,19,10.5,WA)+circ(41.5,15.5,3.5,CR))

# telescope
tube = rect(8,28,14,9,BR,3)+rect(21,25,16,15,GO,3)+rect(36,21,16,23,BR,3)+rect(49,19,6,27,DW,3)+rect(51,24,6,17,WA,3)
I['telescope'] = ('telescope',
    ln(31,38,22,56,W)+ln(31,38,42,56,W)+'<g transform="translate(32 28) scale(.9) translate(-32 -32)">'+grp(-35,32,32,tube)+'</g>')

# curry
SA='#c4601c'
I['curry'] = ('curry',
    path('M11 34Q12 12 32 12Q52 12 53 34Z',CR)
    +path('M6 33H58Q58 55 32 55Q6 55 6 33Z',WA)+rect(6,31,52,6,GO,3)
    +ell(37,21,13,6.5,SA,-12)+ln(45,24,45,37,SA,6)+ln(33,26,33,35,SA,5.5))

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
