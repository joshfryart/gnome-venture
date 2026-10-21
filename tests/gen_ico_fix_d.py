#!/usr/bin/env python3
"""Batch D plain-source icon redraws -> tests/ico_src/ico-<slug>.svg. Build: python3 tests/gen_ico_fix_d.py build"""
import os, sys, math
HERE = os.path.dirname(os.path.abspath(__file__)); OUT = os.path.join(HERE, 'ico_src')
U='#2a1a10'; CR='#f8eed2'; W='#a5663a'; DW='#8c4a1a'; GO='#dcb06a'; YL='#f2cf4a'; LF='#58a03e'; DL='#2e5a2c'
RD='#9c2a1e'; PK='#d9667f'; WA='#3f93b2'; ST='#968f96'; DS='#6a6070'; OR='#d9532a'
def f(v): return ('%.1f' % v).rstrip('0').rstrip('.')
def circ(x,y,r,c): return '<circle cx="%s" cy="%s" r="%s" fill="%s"/>' % (f(x),f(y),f(r),c)
def ell(x,y,rx,ry,c,rot=0): return '<ellipse cx="%s" cy="%s" rx="%s" ry="%s" fill="%s"%s/>' % (f(x),f(y),f(rx),f(ry),c,(' transform="rotate(%s %s %s)"' % (f(rot),f(x),f(y))) if rot else '')
def rect(x,y,w,h,c,rx=0): return '<rect x="%s" y="%s" width="%s" height="%s" fill="%s"%s/>' % (f(x),f(y),f(w),f(h),c,(' rx="%s"' % f(rx)) if rx else '')
def poly(p,c): return '<polygon points="%s" fill="%s"/>' % (' '.join('%s,%s' % (f(a),f(b)) for a,b in p),c)
def path(d,c): return '<path d="%s" fill="%s"/>' % (d,c)
def stroke(d,c,w): return '<path d="%s" fill="none" stroke="%s" stroke-width="%s" stroke-linecap="round" stroke-linejoin="round"/>' % (d,c,w)
def ln(x1,y1,x2,y2,c,w=5): return stroke('M%s %sL%s %s' % (f(x1),f(y1),f(x2),f(y2)),c,w)
I = {}
I['coin'] = ('coin',
    circ(32,32,26,GO)+circ(32,32,20,YL)
    +'<path fill="%s" fill-rule="evenodd" d="M32 19a13 13 0 1 0 .1 0ZM32 25a7 7 0 1 1 -.1 0Z"/>' % GO
    +ell(20,21,3,5.5,CR,40))
I['tent'] = ('tent',
    poly([(32,9),(57,54),(7,54)],LF)+poly([(32,9),(57,54),(32,54)],DL)
    +poly([(32,26),(41,54),(23,54)],U)+ln(32,9,32,3+6,DW))
I['sunflower'] = ('sunflower',
    ln(32,34,32,58,LF,6)+ell(43,50,9,5,LF,-30)
    +''.join(ell(32+13*math.sin(math.radians(a)),26-13*math.cos(math.radians(a)),5.5,7.5,YL,a) for a in range(0,360,45))
    +circ(32,26,9,U))
I['dragon'] = ('dragon',
    poly([(40,36),(58,16),(56,42)],RD)
    +poly([(24,24),(20,8),(34,20)],CR)+poly([(40,22),(48,8),(46,26)],CR)
    +circ(34,36,17,OR)+ell(20,44,11,8,OR)
    +circ(34,31,5,CR)+circ(35,31,2.5,U)+circ(14,46,2.8,RD))
I['milk'] = ('milk carton',
    poly([(16,26),(24,8),(40,8),(48,26)],WA)+rect(16,26,32,32,CR)
    +rect(16,36,32,16,WA)
    +path('M32 38Q40 46 36 50Q32 53 28 50Q24 46 32 38Z',CR))
I['staff'] = ('staff',
    ln(32,22,32,58,W,7)+circ(32,15,9,GO)+poly([(32,8),(38,15),(32,22),(26,15)],RD))
I['rod'] = ('fishing rod',
    ln(10,56,44,12,DW,5)+stroke('M44 12Q58 14 53 30',U,5)
    +circ(52,43,6,RD)+rect(46,41,12,5,CR))
I['flatbread'] = ('flatbread',
    circ(32,32,26,DW)+circ(32,32,22,GO)
    +circ(22,25,3.5,DW)+circ(41,23,3.5,DW)+circ(30,40,3.5,DW)+circ(44,38,3.5,DW)+circ(20,40,3,DW))
I['boat'] = ('sailboat',
    ln(32,8,32,42,DW,5)+poly([(36,10),(55,38),(36,38)],CR)
    +path('M8 42H56Q52 55 42 55H22Q12 55 8 42Z',W)+poly([(28,18),(14,38),(28,38)],GO))
I['curry'] = ('curry bowl',
    circ(28,34,22,W)+path('M28 17a17 17 0 0 0 0 34Z',CR)+path('M28 17a17 17 0 0 1 0 34Z',OR)
    +ln(43,29,57,10,ST,5)+ell(41,33,5,7,ST,40))
I['frog'] = ('frog',
    ell(32,40,24,17,'#3e7a2c')+circ(20,23,9.5,'#3e7a2c')+circ(44,23,9.5,'#3e7a2c')
    +circ(20,23,5.5,CR)+circ(44,23,5.5,CR)+circ(20,24,2.8,U)+circ(44,24,2.8,U)
    +ell(32,48,13,6.5,'#7fbf5a'))
I['dove'] = ('dove',
    poly([(16,34),(8,50),(26,46)],'#6f7f99')+ell(30,38,20,13,'#6f7f99')+circ(46,23,9,'#6f7f99')
    +poly([(53,21),(59,25),(53,29)],GO)+ell(29,33,12,7,CR,-30)+circ(48,21,2.8,U))
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
