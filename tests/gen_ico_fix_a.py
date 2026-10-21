#!/usr/bin/env python3
"""Batch A plain-source icon redraws -> tests/ico_src/ico-<slug>.svg. stdlib only.
Then restyle only these slugs (see bottom: python3 tests/gen_ico_fix_a.py build)."""
import os, sys, math
HERE = os.path.dirname(os.path.abspath(__file__)); OUT = os.path.join(HERE, 'ico_src')
U='#2a1a10'; CR='#f8eed2'; W='#a5663a'; DW='#8c4a1a'; GO='#dcb06a'; LF='#58a03e'; DL='#2e5a2c'
RD='#9c2a1e'; PK='#d9667f'; WA='#3f93b2'; ST='#968f96'; DS='#6a6070'; SK='#e9b98a'
def f(v): return ('%.1f' % v).rstrip('0').rstrip('.')
def circ(x,y,r,c): return '<circle cx="%s" cy="%s" r="%s" fill="%s"/>' % (f(x),f(y),f(r),c)
def ell(x,y,rx,ry,c,rot=0): return '<ellipse cx="%s" cy="%s" rx="%s" ry="%s" fill="%s"%s/>' % (f(x),f(y),f(rx),f(ry),c,(' transform="rotate(%s %s %s)"' % (f(rot),f(x),f(y))) if rot else '')
def rect(x,y,w,h,c,rx=0): return '<rect x="%s" y="%s" width="%s" height="%s" fill="%s"%s/>' % (f(x),f(y),f(w),f(h),c,(' rx="%s"' % f(rx)) if rx else '')
def poly(p,c): return '<polygon points="%s" fill="%s"/>' % (' '.join('%s,%s' % (f(a),f(b)) for a,b in p),c)
def path(d,c,extra=''): return '<path d="%s" fill="%s"%s/>' % (d,c,extra)
def stroke(d,c,w,dash=None,cap='round'): return '<path d="%s" fill="none" stroke="%s" stroke-width="%s" stroke-linecap="%s" stroke-linejoin="round"%s/>' % (d,c,w,cap,(' stroke-dasharray="%s"' % dash) if dash else '')
def ln(x1,y1,x2,y2,c,w=5): return stroke('M%s %sL%s %s' % (f(x1),f(y1),f(x2),f(y2)),c,w)
def grp(rot,cx,cy,inner): return '<g transform="rotate(%s %s %s)">%s</g>' % (f(rot),f(cx),f(cy),inner)
I = {}
I['world-map'] = ('folded map',
    poly([(8,14),(23,19),(23,52),(8,47)],CR)+poly([(23,19),(41,12),(41,46),(23,52)],GO)+poly([(41,12),(56,17),(56,50),(41,46)],CR)
    +stroke('M13 42Q22 26 33 35T50 23',RD,5)+circ(50,23,5,RD))
I['shield'] = ('shield',
    path('M12 10H52V30Q52 50 32 58Q12 50 12 30Z',W)+path('M32 10H52V30Q52 50 32 58Z',DW)
    +stroke('M12 10H52V30Q52 50 32 58Q12 50 12 30Z',ST,5)+circ(32,30,7.5,DS))
I['book-open'] = ('open book',
    poly([(6,12),(32,20),(58,12),(58,49),(32,57),(6,49)],DW)
    +poly([(9,12),(30,19),(30,49),(9,42)],CR)+poly([(55,12),(34,19),(34,49),(55,42)],CR)
    +ln(14,25,25,28.7,GO)+ln(14,35,25,38.7,GO)+ln(50,25,39,28.7,GO)+ln(50,35,39,38.7,GO))
I['coin'] = ('coin',
    circ(32,32,25,W)+circ(32,32,20,GO)
    +''.join(ell(32,32-7.5,4.5,8,W,a).replace('cy="%s"'%f(32-7.5),'cy="%s"'%f(24.5)).replace('transform="rotate(%s 32 %s)"'%(f(a),f(24.5)),'transform="rotate(%s 32 32)"'%f(a)) for a in (0,72,144,216,288))
    +circ(32,32,4,GO))
I['lightning'] = ('lightning', poly([(40,6),(12,36),(28,36),(22,58),(52,24),(35,24),(46,6)],GO))
I['compass'] = ('compass',
    circ(32,32,26,GO)+poly([(32,9),(43,32),(21,32)],RD)+poly([(21,32),(43,32),(32,55)],CR))
I['gnome-gardener'] = ('gnome gardener',
    poly([(24,41),(40,41),(43,57),(21,57)],LF)+poly([(32,6),(20,24),(44,24)],RD)
    +poly([(21,27),(43,27),(32,46)],CR)+circ(32,29,5,SK)
    +ln(51,52,51,40,W)+poly([(51,13),(58,29),(51,41),(44,29)],ST))
I['person'] = ('person',
    path('M8 58Q8 38 32 38Q56 38 56 58Z',WA)+circ(32,24,12.5,U)+circ(32,29,10.5,SK))
# grain: bent stalk, ear leaning right, whiskers
def grain():
    out = [stroke('M20 58Q36 57 30 46',LF,5)]
    ax = (30,46); tip = (34,24); L = math.hypot(tip[0]-ax[0],tip[1]-ax[1]); ux,uy = (tip[0]-ax[0])/L,(tip[1]-ax[1])/L; px,py = -uy,ux
    ang = math.degrees(math.atan2(uy,ux))+90
    for t in (0.0,0.38,0.72):
        cx,cy = ax[0]+ux*L*t, ax[1]+uy*L*t
        for s in (-1,1): out.append(ell(cx+px*6*s,cy+py*6*s,5,8.5,GO,ang+s*25))
    out.append(ell(tip[0]-ux*2,tip[1]-uy*2,5,8,GO,ang))
    out += [ln(33,17,25,9,W),ln(34,16,34,8,W),ln(35,17,43,9,W)]
    return ''.join(out)
I['grain'] = ('wheat', grain())
I['handbag'] = ('pouch',
    path('M20 22Q6 38 11 50Q16 58 32 58Q48 58 53 50Q58 38 44 22Z',W)
    +poly([(20,25),(14,9),(30,20)],DW)+poly([(44,25),(50,9),(34,20)],DW)
    +stroke('M17 27Q32 35 47 27',GO,5)+circ(47,27,4.5,GO))
I['ghost'] = ('ghost',
    path('M12 50V28Q12 8 32 8Q52 8 52 28V50Q45.3 58 38.7 50Q32 58 25.3 50Q18.7 58 12 50Z',CR)
    +circ(24,28,4.5,U)+circ(40,28,4.5,U)+ell(32,40,3.5,4.5,U))
I['handshake'] = ('handshake',
    rect(6,22,14,26,RD,3)+rect(44,22,14,26,WA,3)+rect(17,22,30,24,SK,6)
    +''.join(circ(x,46,4.5,SK) for x in (24,31,38,45))
    +ln(28,38,28,48,W)+ln(35,38,35,48,W)+ln(42,38,42,48,W)
    +ell(33,25,10,5.5,SK,18)+stroke('M22 31Q34 36 44 31',W,5))
def boat():
    return (ln(24,44,44,17,DW)+ell(48,12,5.5,9,DW,36)
        +path('M6 29Q12 47 32 47Q52 47 58 29Q52 35 32 35Q12 35 6 29Z',W)
        +stroke('M8 56Q16 51 24 56T40 56T56 56',WA,5))
I['boat'] = ('canoe', boat())
def ring(cx,cy,ro,ri,c):
    def circ_d(r): return 'M%s %sa%s %s 0 1 0 %s 0a%s %s 0 1 0 %s 0Z' % (f(cx-r),f(cy),f(r),f(r),f(2*r),f(r),f(r),f(-2*r))
    return '<path d="%s%s" fill="%s" fill-rule="evenodd"/>' % (circ_d(ro),circ_d(ri),c)
I['tools'] = ('hammer and wrench',
    ln(46,52,22,24,ST,6)+ring(18,19,10,4,ST)
    +ln(14,52,40,22,W,6)+grp(40,44,18,rect(33,12,22,12,DS,2)))
I['clap'] = ('clapping hands',
    ell(22,40,8.5,17,SK,14)+ell(42,40,8.5,17,SK,-14)
    +ln(32,7,32,14,GO)+ln(18,10,22,17,GO)+ln(46,10,42,17,GO))
def dna():
    def bez(p0,p1,p2,p3,t):
        m=1-t; return tuple(m**3*a+3*m*m*t*b+3*m*t*t*c+t**3*d for a,b,c,d in zip(p0,p1,p2,p3))
    A=[((20,8),(20,24),(44,22),(44,32)),((44,32),(44,42),(20,40),(20,56))]
    def xat(strand,y):
        best=None
        for seg in strand:
            for i in range(201):
                p=bez(*seg,i/200)
                if best is None or abs(p[1]-y)<abs(best[1]-y): best=p
        return best[0]
    B=[tuple((64-a,b) for a,b in seg) for seg in A]
    rungs=''.join(ln(xat(A,y),y,xat(B,y),y,CR) for y in (10,32,54))
    return (rungs+stroke('M20 8C20 24 44 22 44 32C44 42 20 40 20 56',WA,5)+stroke('M44 8C44 24 20 22 20 32C20 42 44 40 44 56',RD,5))
I['dna'] = ('DNA', dna())
I['brain'] = ('brain',
    ''.join(circ(*c,PK) for c in ((19,32,12),(32,22,13),(46,28,12),(33,38,13),(22,43,9)))
    +circ(46,44,9,PK)+rect(37,48,9,10,PK,3)
    +stroke('M32 12Q26 22 32 30',RD,5)+stroke('M17 36Q27 33 33 40',RD,5)+stroke('M42 20Q48 28 40 36',RD,5))
I['telescope'] = ('telescope',
    ln(32,34,20,58,W,6)+ln(32,34,44,58,W,6)+ln(32,36,32,58,DW,6)
    +grp(-30,32,30,rect(6,25,9,10,DW,2)+rect(12,22,26,16,GO,2)+rect(36,17,20,26,GO,3)+rect(36,22,6,16,W)))
if __name__ == '__main__':
    os.makedirs(OUT, exist_ok=True)
    SH={'boat':.8,'person':.88,'telescope':.8,'tools':.9}
    for n,(label,body) in I.items():
        if n in SH: body='<g transform="translate(32 32) scale(%s) translate(-32 -32)">%s</g>'%(SH[n],body)
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
