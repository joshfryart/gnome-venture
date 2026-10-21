#!/usr/bin/env python3
"""Plain-source redraws (21 icons whose reused art was illegible at 16-24px) -> tests/ico_src/ico-<name>.svg. stdlib only.
Then: PYTHONHASHSEED=1 python3 tests/ico_build.py restyle"""
import os, math
HERE = os.path.dirname(os.path.abspath(__file__)); OUT = os.path.join(HERE, 'ico_src')
G='#58a03e'; DG='#2e5a2c'; GOLD='#dcb06a'; SUN='#f2b830'; WOOD='#a5663a'; DWOOD='#6a4528'; CREAM='#f8eed2'
RED='#d6322b'; DRED='#9c2a1e'; ORG='#e8892b'; INK='#3a2f3a'; SIL='#cfd6dc'; STONE='#a9a2a8'; LSTONE='#c4bec4'
def f(v): return ('%.1f' % v).rstrip('0').rstrip('.')
def circ(x,y,r,c): return '<circle cx="%s" cy="%s" r="%s" fill="%s"/>' % (f(x),f(y),f(r),c)
def ell(x,y,rx,ry,c,rot=None): return '<ellipse cx="%s" cy="%s" rx="%s" ry="%s" fill="%s"%s/>' % (f(x),f(y),f(rx),f(ry),c,(' transform="rotate(%s %s %s)"' % (f(rot[0]),f(rot[1]),f(rot[2]))) if rot else '')
def rect(x,y,w,h,c): return '<rect x="%s" y="%s" width="%s" height="%s" fill="%s"/>' % (f(x),f(y),f(w),f(h),c)
def poly(p,c): return '<polygon points="%s" fill="%s"/>' % (' '.join('%s,%s' % (f(a),f(b)) for a,b in p),c)
def path(d,c): return '<path d="%s" fill="%s"/>' % (d,c)
def stroke(d,c,w): return '<path d="%s" fill="none" stroke="%s" stroke-width="%s" stroke-linecap="round" stroke-linejoin="round"/>' % (d,c,w)
def ln(x1,y1,x2,y2,c,w): return stroke('M%s %sL%s %s' % (f(x1),f(y1),f(x2),f(y2)),c,w)
def grp(rot,inner): return '<g transform="rotate(%s 32 32)">%s</g>' % (f(rot),inner)
def leaf(b,t,w,c):
    mx,my=(b[0]+t[0])/2,(b[1]+t[1])/2; dx,dy=t[0]-b[0],t[1]-b[1]; L=math.hypot(dx,dy); px,py=-dy/L*w,dx/L*w
    return path('M%s %sQ%s %s %s %sQ%s %s %s %sZ' % (f(b[0]),f(b[1]),f(mx+px),f(my+py),f(t[0]),f(t[1]),f(mx-px),f(my-py),f(b[0]),f(b[1])),c)
I = {}
# insects / animals
I['ant'] = ('ant', ln(30,34,20,52,DWOOD,5)+ln(30,34,40,52,DWOOD,5)+ln(30,34,22,17,DWOOD,5)+ln(30,34,40,17,DWOOD,5)+ln(14,32,8,18,DWOOD,5)+circ(49,35,11.5,'#7a3a1e')+circ(31,34,6.5,'#d9731f')+circ(16,33,8,'#7a3a1e'))
I['beetle'] = ('beetle', ln(18,30,9,24,INK,5)+ln(46,30,55,24,INK,5)+ln(17,40,8,42,INK,5)+ln(47,40,56,42,INK,5)+ln(19,50,11,57,INK,5)+ln(45,50,53,57,INK,5)
    +ln(27,13,22,7,INK,5)+ln(37,13,42,7,INK,5)+circ(32,16,8,INK)+ell(32,39,16,19,'#2f9a78')+ln(32,26,32,56,'#1d4f40',5))
I['fly'] = ('fly', ell(19,27,15,7.5,'#bcd8ec',(-30,19,27))+ell(45,27,15,7.5,'#bcd8ec',(30,45,27))+ell(32,41,8.5,15,INK)+circ(32,22,9,DRED)+circ(28.5,20,2.6,'#f8eed2')+circ(35.5,20,2.6,'#f8eed2'))
I['fish'] = ('fish', poly([(44,32),(58,18),(58,46)],'#d9611f')+poly([(20,21),(30,10),(38,21)],'#d9611f')+ell(28,33,20,13,ORG)+circ(17,30,4.8,CREAM)+circ(16.5,30,2.6,INK))
I['snake'] = ('snake', stroke('M14 50C28 58 50 54 50 42C50 30 14 34 14 22C14 14 30 10 42 14','#58a03e',11)
    +stroke('M14 50C28 58 50 54 50 42C50 30 14 34 14 22','#2e7a2c',5).replace('stroke-linecap="round"','stroke-linecap="round" stroke-dasharray="0 11"')
    +ell(47,16,9,7.5,'#4a9033',(20,47,16))+circ(49,13.5,2.6,CREAM)+poly([(54,18),(60,16),(57,20),(60,23),(54,21)],RED))
# nature / food
I['mushroom'] = ('mushroom', path('M24 36H40L42 53Q42 58 37 58H27Q22 58 22 53Z',CREAM)+path('M7 38A25 24 0 0 1 57 38Z',RED)+circ(21,30,4.6,CREAM)+circ(34,22,5.2,CREAM)+circ(46,32,4.2,CREAM))
I['peach'] = ('peach', circ(25.5,38,18,'#f4936b')+circ(38.5,38,18,'#f4936b')+stroke('M32 24Q26 38 32 56','#d9673f',5)+ln(32,24,32,13,DWOOD,5)+leaf((33,16),(50,8),6,G))
I['peanut'] = ('peanut', grp(-38, circ(32,17,12,'#d9b27a')+circ(32,46,14,'#d9b27a')+rect(26,22,12,20,'#d9b27a')+circ(29,14,2.8,'#b98a52')+circ(35,48,2.8,'#b98a52')+circ(28,44,2.8,'#b98a52')+circ(35,21,2.8,'#b98a52')))
heart = 'M32 33C24 30 21 17 28.5 16Q32 17 32 21Q32 17 35.5 16C43 17 40 30 32 33Z'
I['four-leaf-clover'] = ('four-leaf clover', stroke('M32 32Q30 46 40 57','#2e5a2c',5)+''.join('<path d="%s" fill="%s" transform="rotate(%d 32 32)"/>' % (heart,G,a) for a in (0,90,180,270)))
I['chili'] = ('chili', path('M12 23C20 11 36 18 44 34C50 44 53 49 54 52C42 53 29 50 20 40C12 32 8 29 12 23Z',RED)+circ(14.5,22,7,G)+ln(14,21,12,10,DG,5))
I['cherry'] = ('cherry', ln(20,38,34,12,DG,5)+ln(44,40,34,12,DG,5)+leaf((34,13),(54,12),6,G)+circ(20,47,11,RED)+circ(44,49,11,RED)+circ(16,43,2.6,'#f6c4b8')+circ(40,45,2.6,'#f6c4b8'))
I['sunflower'] = ('sunflower', ''.join(ell(32,16,6,9.5,SUN,(a,32,32)) for a in range(0,360,45))+circ(32,32,12.5,'#5a3a20')+circ(32,32,6,'#8a5a30'))
I['watermelon'] = ('watermelon', path('M5 22A27 27 0 0 0 59 22Z','#3f8a3a')+path('M9 22A23 23 0 0 0 55 22Z','#d6eaa8')+path('M12 22A20 20 0 0 0 52 22Z','#e04a4a')+circ(24,33,3,INK)+circ(35,38,3,INK)+circ(44,30,3,INK))
I['shell'] = ('spiral shell', circ(32,32,25,'#f6d9b8')+stroke('M32 32a5 5 0 0 1 10 0a10 10 0 0 1-20 0a15 15 0 0 1 30 0','#d28b6a',5)+path('M12 46Q6 54 14 56Q20 55 22 50Z','#f6d9b8'))
# objects
I['knife'] = ('knife', grp(40, path('M28 34V10Q37 14 36 34Z',SIL)+rect(23,33,18,5,GOLD)+rect(28,38,8,19,DWOOD)))
I['test-tube'] = ('test tube', grp(32, path('M26 12V46a6 6 0 0 0 12 0V12Z','#cfe6ee')+path('M26 30H38V46a6 6 0 0 1-12 0Z','#3fbf72')+rect(22,8,20,5,'#8a98a0')+circ(31,38,2.6,'#c8f2d6')))
# places / people
I['person'] = ('villager', path('M10 58Q10 40 32 40Q54 40 54 58Z','#4a7ab5')+circ(32,31,11.5,'#f2cfa5')+poly([(18,28),(46,28),(34,6),(30,6)],RED)+rect(16,26,32,5,DRED))
I['shop'] = ('shop', rect(12,28,40,29,'#e8d3a2')+rect(20,38,24,11,DWOOD)
    +path('M8 12H20V28A6 6 0 0 1 8 28ZM32 12H44V28A6 6 0 0 1 32 28Z',RED)+path('M20 12H32V28A6 6 0 0 1 20 28ZM44 12H56V28A6 6 0 0 1 44 28Z',CREAM))
I['shrine'] = ('shrine gate', rect(16,22,7,35,RED)+rect(41,22,7,35,RED)+rect(11,32,42,6,RED)+path('M5 14Q32 24 59 14L57 24Q32 28 7 24Z',DRED))
I['tent'] = ('tent', poly([(32,12),(32,54),(6,54)],'#e8a640')+poly([(32,12),(58,54),(32,54)],'#d98a2a')+poly([(32,28),(42,54),(22,54)],DWOOD)+rect(6,52,52,6,G))
I['tower'] = ('tower', rect(20,26,24,32,STONE)+rect(16,18,32,10,LSTONE)+rect(13,8,9,11,LSTONE)+rect(27.5,8,9,11,LSTONE)+rect(42,8,9,11,LSTONE)+path('M28 58V50A4 4 0 0 1 36 50V58Z','#3a2a2a')+rect(29.5,32,5,8,'#3a3a44'))

SHRINK = {'mushroom': .88, 'test-tube': .88, 'tower': .9}
if __name__ == '__main__':
    os.makedirs(OUT, exist_ok=True)
    for n, (label, body) in I.items():
        if n in SHRINK: body = '<g transform="translate(32 32) scale(%s) translate(-32 -32)">%s</g>' % (SHRINK[n], body)   # keeps the halo off the frame
        open(os.path.join(OUT, 'ico-%s.svg' % n), 'w', encoding='utf-8').write('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64" role="img" aria-label="%s">%s</svg>' % (label, body))
    print('wrote', len(I))
