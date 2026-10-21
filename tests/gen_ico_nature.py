#!/usr/bin/env python3
"""Generate plain-source icons for weather-time + nature-plants groups into tests/ico_src/."""
import math, os
G='#58a03e'; DG='#2e5a2c'; GOLD='#dcb06a'; SUN='#f2b830'; W='#3f93b2'; WOOD='#a5663a'; CREAM='#f8eed2'
ST='#968f96'; RED='#9c2a1e'; ORG='#d9731f'; PINK='#e58aa8'; INK='#2b2b2b'; CLOUD='#dfe8ec'; DCLOUD='#8c9ca6'; MIST='#9fb4bf'
def f(v): return ('%.1f'%v).rstrip('0').rstrip('.')
def pts(p): return ' '.join(f(a)+','+f(b) for a,b in p)
def poly(p,fill): return f'<polygon points="{pts(p)}" fill="{fill}"/>'
def circ(x,y,r,fill): return f'<circle cx="{f(x)}" cy="{f(y)}" r="{f(r)}" fill="{fill}"/>'
def line(a,b,c,w,col): return f'<line x1="{f(a)}" y1="{f(b)}" x2="{f(c)}" y2="{f(w)}" stroke="{col}" stroke-width="{{}}" stroke-linecap="round"/>'
def ln(x1,y1,x2,y2,col,w): return f'<line x1="{f(x1)}" y1="{f(y1)}" x2="{f(x2)}" y2="{f(y2)}" stroke="{col}" stroke-width="{w}" stroke-linecap="round"/>'
def path(d,fill): return f'<path d="{d}" fill="{fill}"/>'
def spath(d,col,w,cap='round'): return f'<path d="{d}" fill="none" stroke="{col}" stroke-width="{w}" stroke-linecap="{cap}" stroke-linejoin="round"/>'
def rect(x,y,w,h,fill,rx=0): return f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="{rx}" fill="{fill}"/>'
def ell(x,y,rx,ry,fill): return f'<ellipse cx="{f(x)}" cy="{f(y)}" rx="{f(rx)}" ry="{f(ry)}" fill="{fill}"/>'
def star(cx,cy,R,r,n=5):
    return [(cx+(R if i%2==0 else r)*math.cos(-math.pi/2+i*math.pi/n), cy+(R if i%2==0 else r)*math.sin(-math.pi/2+i*math.pi/n)) for i in range(2*n)]
def leaf(b,t,w,fill):
    mx,my=(b[0]+t[0])/2,(b[1]+t[1])/2; dx,dy=t[0]-b[0],t[1]-b[1]; L=math.hypot(dx,dy); px,py=-dy/L*w,dx/L*w
    return path(f'M{f(b[0])} {f(b[1])} Q{f(mx+px)} {f(my+py)} {f(t[0])} {f(t[1])} Q{f(mx-px)} {f(my-py)} {f(b[0])} {f(b[1])}Z',fill)
def cloud(fill,dy=0,dx=0):
    return ''.join([circ(22+dx,30+dy,10,fill),circ(34+dx,24+dy,13,fill),circ(46+dx,31+dy,9,fill),rect(12+dx,30+dy,43,12,fill,6)])
I={}
I['ico-sparkle']=('sparkle',poly([(30,10),(35,27),(52,32),(35,37),(30,54),(25,37),(8,32),(25,27)],SUN)+poly([(49,6),(51.5,12.5),(58,15),(51.5,17.5),(49,24),(46.5,17.5),(40,15),(46.5,12.5)],GOLD))
I['ico-lightning']=('lightning bolt',poly([(38,6),(14,36),(28,36),(22,58),(50,24),(35,24),(44,6)],SUN))
I['ico-droplet']=('water drop',path('M32 7C26 17 14 29 14 40a18 18 0 0 0 36 0C50 29 38 17 32 7Z',W))
I['ico-star']=('star',poly(star(32,34,26,11),SUN))
I['ico-star-empty']=('empty star',f'<polygon points="{pts(star(32,34,22,10))}" fill="none" stroke="{GOLD}" stroke-width="5" stroke-linejoin="round"/>')
I['ico-wind']=('wind',spath('M10 22H36a7 7 0 1 0-7-7',MIST,5)+spath('M10 34H46a7 7 0 1 1-7 7',MIST,5)+spath('M10 46H26',MIST,5))
I['ico-hourglass']=('hourglass',poly([(18,14),(46,14),(35,32),(46,50),(18,50),(29,32)],'#bcd8e0')+poly([(22,16),(42,16),(33,28),(31,28)],GOLD)+poly([(21,49),(43,49),(34,40),(30,40)],GOLD)+rect(12,7,40,7,WOOD,2)+rect(12,50,40,7,WOOD,2))
I['ico-moon']=('moon',path('M38 7A25 25 0 1 0 57 41A20 20 0 0 1 38 7Z',SUN))
sunrays=''.join(ln(32+20*math.cos(a*math.pi/4),32+20*math.sin(a*math.pi/4),32+26*math.cos(a*math.pi/4),32+26*math.sin(a*math.pi/4),SUN,5) for a in range(8))
I['ico-sun']=('sun',sunrays+circ(32,32,14,SUN))
I['ico-clock']=('clock',circ(32,32,25,WOOD)+circ(32,32,18,CREAM)+ln(32,32,32,20,INK,4.5)+ln(32,32,41,32,INK,4.5))
I['ico-rain']=('rain cloud',cloud(DCLOUD,-10)+ln(22,47,18,56,W,5)+ln(34,47,30,56,W,5)+ln(46,47,42,56,W,5))
I['ico-fire']=('fire',path('M32 6C34 18 48 24 48 38C48 50 40 58 32 58C24 58 16 50 16 38C16 30 21 26 24 20C26 26 28 28 30 28C30 20 28 12 32 6Z',ORG)+path('M32 34C36 40 40 42 40 48C40 53 36 56 32 56C28 56 24 53 24 48C24 42 29 40 32 34Z',SUN))
I['ico-snowflake']=('snowflake',''.join(ln(32-26*math.cos(a*math.pi/3),32-26*math.sin(a*math.pi/3),32+26*math.cos(a*math.pi/3),32+26*math.sin(a*math.pi/3),'#6fb6d6',4.5) for a in range(3))+circ(32,32,7,'#6fb6d6'))
sr=''.join(ln(20+13*math.cos(a*math.pi/4),20+13*math.sin(a*math.pi/4),20+18*math.cos(a*math.pi/4),20+18*math.sin(a*math.pi/4),SUN,4.5) for a in range(8))
I['ico-sun-rain']=('sun with rain',sr+circ(20,20,9,SUN)+circ(35,38,9,DCLOUD)+circ(45,40,8,DCLOUD)+rect(26,40,27,10,DCLOUD,5)+ln(31,53,29,58,W,4.5)+ln(41,53,39,58,W,4.5)+ln(51,53,49,58,W,4.5)) if False else ('sun with rain',sr+circ(20,20,9,SUN)+circ(35,36,9,DCLOUD)+circ(45,38,8,DCLOUD)+rect(24,38,29,10,DCLOUD,5)+ln(31,51,29,57,W,4.5)+ln(41,51,39,57,W,4.5)+ln(51,51,49,57,W,4.5))
I['ico-rainbow']=('rainbow',spath('M10 50A22 22 0 0 1 54 50',RED,7,'butt')+spath('M17 50A15 15 0 0 1 47 50',SUN,7,'butt')+spath('M24 50A8 8 0 0 1 40 50',W,7,'butt'))
I['ico-cloud']=('cloud',cloud(CLOUD,6))
I['ico-calendar']=('calendar',rect(10,12,44,44,CREAM,5)+path('M10 17a5 5 0 0 1 5-5h34a5 5 0 0 1 5 5v9H10Z',RED)+ln(21,8,21,17,INK,5)+ln(43,8,43,17,INK,5)+rect(17,33,8,7,ST)+rect(28,33,8,7,ST)+rect(39,33,8,7,RED)+rect(17,44,8,7,ST)+rect(28,44,8,7,ST))
I['ico-storm']=('storm',cloud(DCLOUD,-12)+poly([(36,32),(24,47),(32,47),(27,58),(43,40),(35,40),(41,32)],SUN))
I['ico-fog']=('fog',ln(18,14,46,14,MIST,6)+ln(10,26,40,26,MIST,6)+ln(24,38,54,38,MIST,6)+ln(12,50,44,50,MIST,6))
# nature
half=[(32,6),(38,17),(46,12),(44,26),(57,24),(49,35),(53,42),(35,43),(34,50)]
mp=half+[(64-x,y) for x,y in reversed(half[1:])]
I['ico-autumn-leaf']=('autumn leaf',ln(32,44,32,58,WOOD,4.5)+poly(mp,'#c9481e'))
I['ico-blossom']=('blossom',''.join(circ(32+13*math.cos(-math.pi/2+i*2*math.pi/5),32+13*math.sin(-math.pi/2+i*2*math.pi/5),11,PINK) for i in range(5))+circ(32,32,6,SUN))
I['ico-daisy']=('daisy',''.join(circ(32+17*math.cos(i*math.pi/4),32+17*math.sin(i*math.pi/4),7,CREAM) for i in range(8))+circ(32,32,9,SUN))
I['ico-tree']=('tree',poly([(27,58),(29,36),(35,36),(37,58)],WOOD)+circ(32,26,20,G)+circ(20,32,10,G)+circ(44,32,10,G))
I['ico-leaf']=('leaf',path('M12 52C10 28 28 10 54 10C56 36 40 54 12 52Z',G)+ln(14,50,42,22,CREAM,4))
I['ico-herb-sprig']=('herb sprig',ln(32,58,32,12,DG,4.5)+leaf((32,48),(12,38),6,G)+leaf((32,48),(52,38),6,G)+leaf((32,34),(12,24),6,G)+leaf((32,34),(52,24),6,G)+leaf((32,22),(32,6),6,G))
I['ico-sprout']=('sprout',ell(32,54,22,6,WOOD)+ln(32,50,32,30,DG,5)+leaf((32,36),(11,20),7,G)+leaf((32,30),(53,14),7,G))
I['ico-clover']=('clover',ln(32,38,36,58,DG,5)+circ(32,20,11,G)+circ(20,34,11,G)+circ(44,34,11,G)+circ(32,30,8,G))
I['ico-moss-rock']=('mossy rock',path('M8 52C6 36 16 18 32 18C48 18 58 34 56 52Z',ST)+path('M14 33C18 24 25 19 32 19C42 19 50 24 52 35C45 31 39 35 32 31C26 29 20 34 14 33Z',G))
I['ico-gem']=('gem',poly([(18,14),(46,14),(58,28),(32,58),(6,28)],W)+poly([(18,14),(46,14),(55,28),(9,28)],'#8fd0e4'))
I['ico-wave']=('wave',path('M8 54C8 32 22 14 40 12C52 11 58 22 52 29C48 24 40 24 38 30C44 36 44 46 50 54Z',W)+circ(48,19,4,CREAM))
d=os.path.join(os.path.dirname(os.path.abspath(__file__)),'ico_src'); os.makedirs(d,exist_ok=True)
for slug,(name,body) in I.items():
    open(os.path.join(d,slug+'.svg'),'w').write(f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64" role="img" aria-label="{name}">{body}</svg>\n')
print(len(I))
