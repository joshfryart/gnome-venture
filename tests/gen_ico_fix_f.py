#!/usr/bin/env python3
"""Batch F plain-source icon redraws -> tests/ico_src/ico-<slug>.svg. stdlib only.
Redo: clap, party, watering-can, flatbread, boat, grain.
Write only: python3 tests/gen_ico_fix_f.py   Write + restyle into game/assets/img/ico: python3 tests/gen_ico_fix_f.py build"""
import os, sys, math
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import gen_ico_fix_e as E
from gen_ico_fix_e import *
I = {}

# clap: two palms meeting, thumbs up front, spark lines above
def hand(rot, cx, body, shade):
    return grp(rot, cx, 58,
        rect(cx-8,16,16,42,body,8)
        +ln(cx-3,24,cx-3,34,shade,3.5)+ln(cx+3,24,cx+3,34,shade,3.5)
        +ell(cx+(8 if rot>0 else -8),42,4.5,9,body,0))
I['clap'] = ('clapping hands',
    hand(18,20,'#d9a477','#a5663a')+hand(-18,44,SK,'#c9854f')
    +ln(32,3,32,12,YE,5)+ln(13,8,18,15,YE,5)+ln(51,8,46,15,YE,5))

# party popper: striped cone, ring at mouth, streamers and confetti
I['party'] = ('party popper',
    poly([(6,58),(22,28),(36,42)],OR)+poly([(6,58),(15,41),(22,48)],YE)+poly([(15,41),(22,28),(29,35)],RD)
    +E.stroke('M20 26L38 44',DW,5)
    +E.stroke('M30 24Q36 12 44 18Q50 24 56 12',PK,3.5)+E.stroke('M40 34Q52 30 54 40Q56 48 60 46',WA,3.5)
    +circ(36,10,3.2,YE)+circ(52,24,3.2,LF)+circ(46,6,2.6,WA)+circ(58,34,2.6,PK)+circ(28,12,2.6,RD)
    +poly([(44,28),(47,31),(44,34),(41,31)],YE))

# watering can: steel-blue body, back handle, long spout with rose, drops
I['watering-can'] = ('watering can',
    E.stroke('M16 28Q4 28 6 42Q8 52 18 48',ST,5)
    +path('M14 22H42L46 54H12Z',WA)+rect(12,20,32,6,DS,3)
    +E.stroke('M40 44L58 20',ST,5.5)+poly([(52,14),(64,24),(58,28),(50,20)],DS)
    +circ(58,38,2.4,WA)+circ(62,46,2.4,WA)+circ(54,48,2.4,WA)
    +ell(22,38,2.5,6,CR,10))

# flatbread: folded pita, filling peeking out
I['flatbread'] = ('flatbread',
    path('M6 52A26 26 0 0 1 58 52Z',GO)+path('M12 52A20 20 0 0 1 52 52Z',SK)
    +ell(18,24,8,5.5,LF,-20)+ell(30,18,8,5.5,LF,0)+circ(42,22,6,RD)+ell(48,26,5,4,LF,25)
    +path('M4 50H60V56Q60 58 58 58H6Q4 58 4 56Z',W)
    +circ(20,45,2.6,DW)+circ(32,42,2.6,DW)+circ(44,46,2.6,DW))

# boat: sailboat with two sails, pennant, waves
I['boat'] = ('sailboat',
    ln(30,8,30,44,W,4.5)+poly([(30,10),(30,40),(10,40)],CR)+poly([(33,16),(33,40),(52,40)],YE)
    +poly([(30,4),(42,8),(30,12)],RD)
    +path('M8 44H56Q54 54 44 56H20Q10 54 8 44Z',W)+rect(8,42,48,5,DW,2.5)
    +E.stroke('M4 60Q10 55 16 60T28 60T40 60T52 60T62 60',WA,3.5))

# grain: one bold ear on a bent stalk, leaf
def grains(cx,y0,n):
    s=''
    for i in range(n):
        y=y0+i*9
        s+=ell(cx-8,y,3,5.5,GO,-40)+ell(cx+8,y,3,5.5,GO,40)
    return s
I['grain'] = ('grain',
    E.stroke('M32 62L32 34',BR,5)+path('M32 52Q46 46 52 34Q40 38 32 48Z',LF)
    +grains(32,16,4)+ell(32,8,3.4,7,GO))

if __name__ == '__main__':
    os.makedirs(OUT, exist_ok=True)
    for n,(label,body) in I.items():
        open(os.path.join(OUT,'ico-%s.svg'%n),'w',encoding='utf-8').write('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64" role="img" aria-label="%s">%s</svg>' % (label,body))
    print('wrote',len(I))
    if len(sys.argv)>1 and sys.argv[1]=='build':
        os.environ['PYTHONHASHSEED']='1'
        import hearth
        D=os.path.join(os.path.dirname(HERE),'game/assets/img/ico')
        for n in I:
            s='ico-'+n
            o=hearth.restyle(open(os.path.join(OUT,s+'.svg'),encoding='utf-8').read(),s)
            open(os.path.join(D,s+'.svg'),'w',encoding='utf-8').write(o)
        print('built',len(I))
