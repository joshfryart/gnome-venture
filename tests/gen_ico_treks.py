#!/usr/bin/env python3
"""Generate plain-source treks-combat / objects-tools icons into tests/ico_src/. usage: python3 tests/gen_ico_treks.py"""
import math, os
ST,SD,WD,WK,GD,RD,CR,LF='#968f96','#6a6070','#a5663a','#8c4a1a','#dcb06a','#9c2a1e','#f8eed2','#58a03e'
DK,GR,GL,BL,OR,YL,PK,TA,SK='#3a2e2a','#3e7a2c','#7fbf5a','#4a7fb0','#e8892a','#f2cf4a','#e8a0a8','#c0693a','#e8b98a'
def R(x,y,w,h,f,rx=0): return f'<rect x="{x}" y="{y}" width="{w}" height="{h}"'+(f' rx="{rx}"' if rx else '')+f' fill="{f}"/>'
def C(x,y,r,f): return f'<circle cx="{x}" cy="{y}" r="{r}" fill="{f}"/>'
def E(x,y,rx,ry,f): return f'<ellipse cx="{x}" cy="{y}" rx="{rx}" ry="{ry}" fill="{f}"/>'
def P(pts,f): return '<polygon points="'+' '.join(f'{a},{b}' for a,b in pts)+f'" fill="{f}"/>'
def L(x1,y1,x2,y2,w,f,cap='butt'): return f'<line x1="{x1}" y1="{y1}" x2="{x2}" y2="{y2}" stroke="{f}" stroke-width="{w}" stroke-linecap="{cap}"/>'
def S(d,w,f,cap='butt'): return f'<path d="{d}" fill="none" stroke="{f}" stroke-width="{w}" stroke-linecap="{cap}" stroke-linejoin="round"/>'
def star(cx,cy,ro,ri,n):
    return [(round(cx+(ro if i%2==0 else ri)*math.sin(i*math.pi/n),1),round(cy-(ro if i%2==0 else ri)*math.cos(i*math.pi/n),1)) for i in range(2*n)]
def sword():
    one=L(14,14,40,40,8,ST)+L(34,48,48,34,7,GD)+L(42,42,52,52,7,WD)+C(53,53,4.5,GD)
    return one+'<g transform="translate(64 0) scale(-1 1)">'+one+'</g>'
def book(c,d): return R(12,8,40,48,c,4)+R(12,8,9,48,d,4)+R(52,12,4,40,CR)+R(27,18,17,12,GD)
I={}
I['compass']=C(32,32,25,GD)+C(32,32,17,CR)+P([(32,15),(39,32),(25,32)],RD)+P([(32,49),(39,32),(25,32)],ST)
I['target']=C(32,32,25,RD)+C(32,32,17,CR)+C(32,32,9,RD)
I['gift']=R(12,30,40,26,RD)+R(9,22,46,10,'#b8402e')+R(28,22,8,34,GD)+E(23,15,9,7,GD)+E(41,15,9,7,GD)+C(32,17,4.5,WK)
I['sword']=sword()
I['dragon']=P([(16,26),(12,8),(27,19)],CR)+P([(48,26),(52,8),(37,19)],CR)+C(32,35,19,LF)+E(32,47,12,9,GL)+C(24,32,4.5,DK)+C(40,32,4.5,DK)+C(27,47,3,GR)+C(37,47,3,GR)
I['shield']=C(32,32,25,ST)+C(32,32,17,RD)+C(32,32,7,GD)
I['hole']=E(32,36,26,19,LF)+E(32,38,23,15,WK)+E(32,39,15,8.5,'#2a1e18')+P([(10,26),(14,16),(19,27)],GR)+P([(45,27),(50,16),(54,26)],GR)
I['coin']=C(32,32,25,GD)+C(32,32,16,'#c4903f')+R(29,22,6,20,GD,2)
I['signpost']=R(28,10,8,48,WK)+P([(10,14),(48,14),(56,22),(48,30),(10,30)],WD)+P([(54,34),(16,34),(8,41),(16,48),(54,48)],GD)
I['hammer']=R(28,26,8,32,WD)+R(10,10,36,16,ST)+P([(46,10),(56,6),(56,26),(46,26)],SD)
I['money-bag']=C(32,40,19,WD)+P([(22,12),(42,12),(38,26),(26,26)],WD)+R(21,21,22,6,RD,2)+C(32,42,7,GD)
I['toolbox']=S('M22 26V17H42V26',6,ST)+R(8,24,48,32,RD,3)+R(8,34,48,4,'#6e1c14')+R(27,30,10,12,GD,2)
I['dice']=R(9,9,46,46,RD,9)+C(21,21,5,CR)+C(43,21,5,CR)+C(32,32,5,CR)+C(21,43,5,CR)+C(43,43,5,CR)
I['boot']=P([(18,8),(40,8),(40,32),(52,38),(58,45),(58,56),(18,56)],WD)+R(18,8,22,9,CR)+R(18,48,40,8,WK)
I['book-green']=book(LF,GR)
I['path']=S('M20 58C18 44 46 44 44 32C42 20 20 24 30 6',17,WK)+S('M20 58C18 44 46 44 44 32C42 20 20 24 30 6',10,'#d8b07a')
I['carp-streamer']=R(8,8,6,48,WD)+P([(16,14),(56,26),(56,38),(16,50)],RD)+E(16,32,5,18,DK)+P([(30,20),(38,22),(38,42),(30,44)],CR)
I['book-red']=book(RD,'#6e1c14')
I['flag-red']=R(13,8,7,50,WD)+P([(20,10),(56,10),(46,22),(56,34),(20,34)],RD)
I['paw']=E(32,42,14,12,WK)+C(14,30,6,WK)+C(25,19,6.5,WK)+C(39,19,6.5,WK)+C(50,30,6,WK)
I['stamp-cart']=S('M50 20L57 10',6,WK)+P([(8,20),(52,20),(46,42),(14,42)],WD)+C(22,17,6,LF)+C(35,15,6,GL)+C(20,52,6.5,DK)+C(41,52,6.5,DK)
I['dna']=S('M20 8C48 20 16 44 44 56',7,BL,'round')+S('M44 8C16 20 48 44 20 56',7,RD,'round')
I['burst']=P(star(32,32,27,14,10),OR)+P(star(32,32,16,9,10),YL)
I['ladder']=R(16,6,8,52,WD)+R(40,6,8,52,WD)+R(24,15,16,6,WK)+R(24,29,16,6,WK)+R(24,43,16,6,WK)
I['books']=R(8,8,44,13,RD,2)+R(52,10,4,9,CR)+R(14,25,44,13,LF,2)+R(10,27,4,9,CR)+R(8,42,44,13,BL,2)+R(52,44,4,9,CR)
I['roadworks']=R(14,34,7,24,WD)+R(43,34,7,24,WD)+R(6,14,52,22,CR,3)+P([(12,14),(22,14),(16,36),(6,36)],RD)+P([(30,14),(40,14),(34,36),(24,36)],RD)+P([(48,14),(58,14),(52,36),(42,36)],RD)
I['palette']=E(32,33,26,22,'#d8b07a')+C(18,31,6,RD)+C(27,19,6,LF)+C(41,19,6,BL)+C(49,31,6,YL)+C(40,44,6,CR)
I['finish']=R(13,8,7,50,WD)+R(20,10,36,27,CR)+R(20,10,12,13.5,DK)+R(44,10,12,13.5,DK)+R(32,23.5,12,13.5,DK)
I['fist']=R(14,28,36,24,SK,8)+C(20,28,6,SK)+C(29,26,6,SK)+C(38,26,6,SK)+C(47,28,6,SK)+E(24,42,10,5,'#d49a68')+R(18,50,28,8,CR,2)
I['drum']=R(12,22,40,28,RD)+E(32,50,20,8,RD)+R(12,34,40,5,GD)+E(32,22,20,8,CR)+L(16,6,32,20,7,WD)+L(48,6,32,20,7,WD)
I['puzzle']=R(12,22,34,34,BL,3)+C(29,19,8,BL)+C(49,39,8,BL)
I['trowel-pot']=E(32,38,21,19,TA)+R(24,14,16,14,TA)+R(19,8,26,8,WK,2)+R(13,34,38,5,GD)
I['telescope']=L(14,50,30,34,13,WD)+L(28,36,43,21,11,GD)+L(41,23,53,11,8,WK)+L(20,44,12,58,6.6,WK)
I['music']=E(19,46,9,7,SD)+E(43,40,9,7,SD)+R(24,14,6,32,SD)+R(48,8,6,32,SD)+P([(24,14),(54,8),(54,19),(24,25)],SD)
I['bone']=L(19,45,45,19,9,CR)+C(15,41,6.5,CR)+C(23,49,6.5,CR)+C(41,15,6.5,CR)+C(49,23,6.5,CR)
I['brain']=C(24,27,14,PK)+C(40,27,14,PK)+E(32,40,21,13,PK)+L(32,14,32,46,5,'#c8606e')
I['skull']=C(32,28,21,CR)+R(21,40,22,16,CR,4)+C(24,30,6,DK)+C(40,30,6,DK)+R(30,42,4,10,DK)
I['bow']=S('M22 8Q58 32 22 56',7,WD)+L(22,8,22,56,5,CR)+L(14,32,48,32,6,WK)+P([(57,32),(46,25),(46,39)],ST)+P([(7,26),(20,32),(7,38)],RD)
I['goblin']=P([(14,30),(6,20),(15,42)],GL)+P([(50,30),(58,20),(49,42)],GL)+E(32,36,19,19,GL)+C(24,32,4.5,DK)+C(40,32,4.5,DK)+R(23,45,18,7,DK,2)+P([(26,45),(30,45),(28,50)],CR)+P([(34,45),(38,45),(36,50)],CR)
I['bridge']=R(6,52,52,6,BL)+'<path d="M6 42Q32 6 58 42V52H44Q44 34 32 34Q20 34 20 52H6Z" fill="'+ST+'"/>'+S('M10 38Q32 12 54 38',5,SD)
if __name__=='__main__':
    os.makedirs('tests/ico_src',exist_ok=True) if os.path.isdir('tests') else os.makedirs('ico_src',exist_ok=True)
    out='tests/ico_src' if os.path.isdir('tests') else 'ico_src'
    for k,v in I.items():
        n='ico-'+k
        open(f'{out}/{n}.svg','w').write(f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64" role="img" aria-label="{k.replace("-"," ")}">{v}</svg>\n')
    print(len(I))
