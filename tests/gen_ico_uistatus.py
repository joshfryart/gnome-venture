#!/usr/bin/env python3
"""Generate plain-source ui-status icons -> tests/ico_src/<slug>.svg"""
import math, os
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'ico_src')
G='#58a03e'; R='#9c2a1e'; PK='#d9667f'; GOLD='#dcb06a'; W='#3f93b2'; WOOD='#a5663a'; CR='#f8eed2'; ST='#968f96'; INK='#2b2b2b'
YEL='#e8c547'; SKIN='#e9b98a'; SKIN2='#c9966a'; RED2='#c8402e'
def pts(l): return ' '.join('%g,%g' % p for p in l)
def poly(l, f): return '<polygon points="%s" fill="%s"/>' % (pts(l), f)
def rot(l, deg, c=(32,32)):
    a=math.radians(deg); ca,sa=math.cos(a),math.sin(a)
    return [(c[0]+(x-c[0])*ca-(y-c[1])*sa, c[1]+(x-c[0])*sa+(y-c[1])*ca) for x,y in l]
def rect(x,y,w,h,f,rx=0): return '<rect x="%g" y="%g" width="%g" height="%g"%s fill="%s"/>' % (x,y,w,h,' rx="%g"'%rx if rx else '',f)
def circ(x,y,r,f): return '<circle cx="%g" cy="%g" r="%g" fill="%s"/>' % (x,y,r,f)
def ell(x,y,rx,ry,f): return '<ellipse cx="%g" cy="%g" rx="%g" ry="%g" fill="%s"/>' % (x,y,rx,ry,f)
def path(d,f): return '<path d="%s" fill="%s"/>' % (d,f)
def stroke(d,c,w): return '<path d="%s" fill="none" stroke="%s" stroke-width="%g" stroke-linecap="round" stroke-linejoin="round"/>' % (d,c,w)
def line(a,b,c,w): return stroke('M%g %g L%g %g'%(a+b),c,w)
def arc(cx,cy,r,a0,a1,c,w):
    p=lambda a:(cx+r*math.cos(math.radians(a)),cy+r*math.sin(math.radians(a)))
    x0,y0=p(a0); x1,y1=p(a1)
    return stroke('M%.1f %.1f A%g %g 0 %d 1 %.1f %.1f'%(x0,y0,r,r,1 if (a1-a0)%360>180 else 0,x1,y1),c,w)
def head(cx,cy,r,a,c,s=11):   # arrow head at angle a (clockwise travel) on circle
    x=cx+r*math.cos(math.radians(a)); y=cy+r*math.sin(math.radians(a)); t=math.radians(a+90)
    tip=(x+s*1.1*math.cos(t),y+s*1.1*math.sin(t)); n=(math.cos(math.radians(a)),math.sin(math.radians(a)))
    return poly([tip,(x+n[0]*s,y+n[1]*s),(x-n[0]*s,y-n[1]*s)],c)
def heart(f): return path('M32 57C4 38 4 14 19 11C26 10 30 15 32 20C34 15 38 10 45 11C60 14 60 38 32 57Z',f)
def medal(main,dark,r1,r2):
    return (poly([(18,6),(30,6),(37,30),(25,30)],r1)+poly([(46,6),(34,6),(27,30),(39,30)],r2)
            +circ(32,42,17,main)+circ(32,42,8,dark))
def gear():
    n=8; P=[]
    for i in range(n):
        a=i*360/n
        for da,rr in ((-11,18),(-8,26),(8,26),(11,18)):
            t=math.radians(a+da); P.append((32+rr*math.cos(t),32+rr*math.sin(t)))
    d='M'+' L'.join('%.1f %.1f'%p for p in P)+'Z M44 32A12 12 0 1 0 20 32A12 12 0 1 0 44 32Z'
    return '<path d="%s" fill="%s" fill-rule="evenodd"/>'%(d,ST)
ARR=[(56,32),(33,9),(33,22),(8,22),(8,42),(33,42),(33,55)]
def hand(dy=0):
    return (line((22,36),(22,16+dy),SKIN,8)+line((30,36),(30,10+dy),SKIN,8)+line((38,36),(38,10+dy),SKIN,8)+line((46,36),(46,16+dy),SKIN,8)
            +line((20,46),(11,32),SKIN,9)+rect(17,32,36,24,SKIN,10))
def thumb():
    return (rect(22,8,13,26,SKIN,6.5)+rect(20,26,34,30,SKIN,8)+rect(6,26,11,30,W,2))
I = {}
I['ico-check']=stroke('M13 34L27 48L51 17',G,10)
I['ico-cross']=stroke('M15 15L49 49M49 15L15 49',R,10)
I['ico-scroll']=rect(16,14,32,36,CR)+rect(9,8,46,12,GOLD,6)+rect(9,44,46,12,GOLD,6)+rect(22,28,20,5,INK)+rect(22,37,20,5,INK)
I['ico-trophy']=(stroke('M16 16H9V22C9 32 16 36 20 36',GOLD,5)+stroke('M48 16H55V22C55 32 48 36 44 36',GOLD,5)
    +path('M15 8H49V26C49 38 42 44 32 44C22 44 15 38 15 26Z',GOLD)+rect(28,42,8,10,GOLD)+rect(18,50,28,8,WOOD,2))
I['ico-map-pin']=path('M32 5C20 5 13 14 13 24C13 38 32 59 32 59C32 59 51 38 51 24C51 14 44 5 32 5Z',R)+circ(32,24,8,CR)
I['ico-medal-gold']=medal(GOLD,'#b8893f',R,W)
I['ico-medal-silver']=medal('#b9b4b9',ST,R,W)
I['ico-medal-bronze']=medal(WOOD,'#7a4a28',R,W)
I['ico-question']=stroke('M21 22C21 8 43 8 43 22C43 33 32 33 32 41',W,9)+circ(32,53,6,W)
I['ico-exclaim']=line((32,10),(32,38),R,11)+circ(32,52,6.5,R)
I['ico-refresh']=arc(32,32,19,200,330,G,8)+head(32,32,19,330,G)+arc(32,32,19,20,150,G,8)+head(32,32,19,150,G)
def pencil():
    u=(0.7071,-0.7071); n=(0.7071,0.7071); w=7
    def P(t,s): return (10+u[0]*t+n[0]*s, 54+u[1]*t+n[1]*s)
    return (poly([P(0,0),P(15,w),P(15,-w)],CR)+poly([P(0,0),P(5,2.3),P(5,-2.3)],INK)+poly([P(13,w),P(13,-w),P(48,-w),P(48,w)],YEL)
            +poly([P(48,w),P(48,-w),P(56,-w),P(56,w)],ST)+poly([P(56,w),P(56,-w),P(64,-w),P(64,w)],PK))
I['ico-pencil']=pencil()
I['ico-heart-yellow']=heart(YEL); I['ico-heart-red']=heart(RED2); I['ico-heart-green']=heart(G)
I['ico-lock']=stroke('M22 30V21A10 10 0 0 1 42 21V30',ST,7)+rect(12,28,40,28,GOLD,5)+circ(32,39,5,INK)+rect(29.5,40,5,10,INK)
I['ico-face-sigh']=(circ(28,34,24,YEL)+line((16,29),(25,29),INK,6)+line((31,29),(40,29),INK,6)+ell(28,46,6,5,INK)
    +circ(53,24,6,'#8cc6da')+circ(57,38,4.5,'#8cc6da'))
I['ico-face-smile']=circ(32,32,26,YEL)+circ(23,26,4.5,INK)+circ(41,26,4.5,INK)+stroke('M19 38Q32 52 45 38',INK,5)
I['ico-play']=poly([(16,9),(54,32),(16,55)],G)
I['ico-ribbon']=(poly([(32,32),(24,57),(33,52),(40,58)],R)+poly([(32,32),(6,14),(6,46)],PK)+poly([(32,32),(58,14),(58,46)],PK)+circ(32,32,8,R))
I['ico-mailbox']=(rect(28,44,8,14,WOOD)+rect(8,16,44,30,R,12)+rect(18,27,22,6,INK)+rect(52,10,6,26,GOLD)+rect(46,10,12,8,GOLD))
I['ico-hand-stop']=hand()
I['ico-hand-wave']='<g transform="translate(-6,12) scale(0.8)">'+hand()+'</g>'+arc(30,30,22,-70,-25,W,6)+arc(30,30,31,-68,-28,W,6)
I['ico-pushpin']=(line((32,38),(32,58),ST,5)+rect(18,34,28,7,R,3)+poly([(22,18),(42,18),(38,36),(26,36)],R)+ell(32,15,15,9,PK))
I['ico-bell']=path('M32 6C21 6 17 15 17 27V36L10 45H54L47 36V27C47 15 43 6 32 6Z',GOLD)+circ(32,52,6,'#b8893f')
I['ico-arrow-right']=poly(ARR,W); I['ico-arrow-down']=poly(rot(ARR,90),W)
I['ico-arrow-left']=poly(rot(ARR,180),W); I['ico-arrow-up']=poly(rot(ARR,270),W)
I['ico-party']=(poly([(8,57),(21,23),(41,43)],GOLD)+poly([(8,57),(14,40),(25,51)],'#b8893f')+circ(40,14,5,R)+circ(56,26,4.5,G)+circ(28,9,4.5,W)+circ(54,46,4.5,PK)
    +line((44,28),(50,22),YEL,5)+line((32,26),(36,18),G,5))
I['ico-graduation']=(poly([(16,32),(16,46),(32,54),(48,46),(48,32),(32,40)],'#44506a')+poly([(32,10),(59,25),(32,40),(5,25)],'#2f3a52')
    +line((53,28),(53,45),GOLD,5)+circ(53,49,5,GOLD))
I['ico-label-tag']=poly([(6,32),(20,16),(57,16),(57,48),(20,48)],GOLD)+circ(21,32,5,CR)
I['ico-notepad']=rect(14,12,36,44,CR,3)+rect(14,8,36,10,WOOD,3)+rect(21,28,22,5,ST)+rect(21,37,22,5,ST)+rect(21,46,14,5,ST)
I['ico-ballot']=rect(22,6,22,28,CR)+stroke('M27 18L31 22L39 13',G,5)+rect(8,28,48,28,WOOD,3)+rect(20,36,24,6,INK)
I['ico-scales']=(rect(29,10,6,42,GOLD)+rect(16,50,32,7,GOLD,3)+line((9,15),(55,15),GOLD,6)+circ(32,11,5,GOLD)
    +line((14,15),(7,34),GOLD,4.5)+line((14,15),(25,34),GOLD,4.5)+line((50,15),(39,34),GOLD,4.5)+line((50,15),(57,34),GOLD,4.5)
    +path('M5 34H27A11 11 0 0 1 5 34Z',GOLD)+path('M37 34H59A11 11 0 0 1 37 34Z',GOLD))
I['ico-magnifier']=circ(26,26,18,W)+circ(26,26,10,'#cfe9f0')+line((40,40),(55,55),WOOD,10)
I['ico-chart']=rect(8,38,13,18,G,2)+rect(25,26,13,30,G,2)+rect(42,10,13,46,G,2)
I['ico-cog']=gear()
I['ico-bulb']=circ(32,26,19,'#f2d45c')+poly([(21,36),(43,36),(39,47),(25,47)],'#f2d45c')+rect(23,44,18,6,ST,3)+rect(26,51,12,6,ST,3)
I['ico-menu']=rect(9,12,46,9,WOOD,4.5)+rect(9,28,46,9,WOOD,4.5)+rect(9,44,46,9,WOOD,4.5)
I['ico-warning']=('<polygon points="32,10 55,51 9,51" fill="%s" stroke="%s" stroke-width="8" stroke-linejoin="round"/>'%(YEL,YEL)+line((32,26),(32,38),INK,7)+circ(32,46,4,INK))
I['ico-undo']=stroke('M20 26H38A14 14 0 0 1 38 54H22',W,8)+poly([(6,26),(24,10),(24,42)],W)
I['ico-eyes']=ell(19,32,13,16,CR)+ell(45,32,13,16,CR)+circ(22,35,6,INK)+circ(48,35,6,INK)
I['ico-key']=stroke('M26 32H55',GOLD,7)+'<circle cx="16" cy="32" r="10" fill="none" stroke="%s" stroke-width="7"/>'%GOLD+rect(41,34,6,11,GOLD)+rect(50,34,6,9,GOLD)
I['ico-newspaper']=rect(8,10,48,44,CR,3)+rect(14,16,26,9,INK)+rect(44,16,6,17,ST)+rect(14,30,26,5,ST)+rect(14,39,36,5,ST)+rect(14,47,36,4,ST)
I['ico-clap']=(line((12,52),(38,18),SKIN2,14)+line((52,52),(26,18),SKIN,14)
    +line((16,12),(22,19),GOLD,5)+line((48,12),(42,19),GOLD,5)+line((32,6),(32,14),GOLD,5))
I['ico-pointing']=rect(6,22,9,28,W,2)+rect(14,22,26,28,SKIN,8)+rect(32,25,24,10,SKIN,5)+rect(20,16,16,12,SKIN,6)
I['ico-prayer']=path('M32 6C52 20 52 42 40 58H24C12 42 12 20 32 6Z',SKIN)+line((32,22),(32,54),SKIN2,5)
I['ico-shuffle']=(line((8,16),(40,42),W,7)+poly([(56,56),(34,50),(50,34)],W)+line((8,48),(40,22),G,7)+poly([(56,8),(34,14),(50,30)],G))
I['ico-thumbs-up']=thumb()
I['ico-thumbs-down']='<g transform="translate(0,64) scale(1,-1)">'+thumb()+'</g>'
I['ico-floppy']=rect(8,8,48,48,W,5)+rect(18,8,28,18,ST)+rect(36,11,6,12,CR)+rect(16,34,32,22,CR)
I['ico-crown']=poly([(6,48),(6,16),(21,30),(32,10),(43,30),(58,16),(58,48)],GOLD)+rect(6,46,52,10,'#b8893f',2)+circ(32,36,4.5,R)
I['ico-page']=poly([(14,6),(38,6),(52,20),(52,58),(14,58)],CR)+poly([(38,6),(38,20),(52,20)],ST)+rect(21,32,24,5,ST)+rect(21,43,24,5,ST)
I['ico-info']=circ(32,32,27,W)+circ(32,19,4.5,CR)+rect(27.5,28,9,19,CR,3)
I['ico-plus']=stroke('M32 11V53M11 32H53',G,11)

def main():
    os.makedirs(OUT,exist_ok=True)
    for slug,body in I.items():
        name=slug[4:].replace('-',' ')
        open(os.path.join(OUT,slug+'.svg'),'w').write('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64" role="img" aria-label="%s">%s</svg>\n'%(name,body))
    print(len(I))
main()
