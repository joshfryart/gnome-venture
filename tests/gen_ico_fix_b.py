#!/usr/bin/env python3
"""Batch B ico redraws: writes plain sources to tests/ico_src and restyles ONLY these slugs into game/assets/img/ico.
usage: python3 tests/gen_ico_fix_b.py [src-only]"""
import os, sys, math
if os.environ.get('PYTHONHASHSEED') != '1':
    os.environ['PYTHONHASHSEED'] = '1'; os.execv(sys.executable, [sys.executable] + sys.argv)
HERE = os.path.dirname(os.path.abspath(__file__)); ROOT = os.path.dirname(HERE)
sys.path.insert(0, HERE)
U='#2a1a10'; CR='#f8eed2'; W1='#a5663a'; W2='#8c4a1a'; GO='#dcb06a'; L1='#58a03e'; L2='#2e5a2c'; R1='#9c2a1e'; PK='#d9667f'
OR='#e8892a'; WA='#3f93b2'; S1='#968f96'; S2='#6a6070'; SK='#e9b98a'; PI='#e8a0a8'

def star(cx, cy, ro, ri, n=5):
    pts = []
    for i in range(n*2):
        r = ro if i % 2 == 0 else ri; a = -math.pi/2 + i*math.pi/n
        pts.append('%.1f,%.1f' % (cx + r*math.cos(a), cy + r*math.sin(a)))
    return ' '.join(pts)
def E(cx, cy, rx, ry, f, rot=0):
    t = ' transform="rotate(%s %s %s)"' % (rot, cx, cy) if rot else ''
    return '<ellipse cx="%s" cy="%s" rx="%s" ry="%s" fill="%s"%s/>' % (cx, cy, rx, ry, f, t)
def C(cx, cy, r, f): return '<circle cx="%s" cy="%s" r="%s" fill="%s"/>' % (cx, cy, r, f)
def P(d, f): return '<path d="%s" fill="%s"/>' % (d, f)
def Y(pts, f): return '<polygon points="%s" fill="%s"/>' % (pts, f)
def R(x, y, w, h, f, rx=0): return '<rect x="%s" y="%s" width="%s" height="%s" rx="%s" fill="%s"/>' % (x, y, w, h, rx, f)
def L(d, c, w): return '<path d="%s" fill="none" stroke="%s" stroke-width="%s" stroke-linecap="round" stroke-linejoin="round"/>' % (d, c, w)

D = {}
D['pumpkin'] = ''.join([R(29,9,7,13,L2,2), L('M36 14Q44 8 50 14',L1,5), E(32,38,25,19,'#c76a1c'), E(32,38,18,19,OR), E(32,38,9,19,'#f4a24a')])
D['melon'] = ''.join([E(24,28,18,17,L1), L('M14 15Q8 28 16 41',L2,5), L('M26 11Q20 28 26 45',L2,5), L('M35 16Q39 28 33 41',L2,5), P('M21 38H55A17 17 0 0 1 21 38Z',L1), P('M26 38H50A12 12 0 0 1 26 38Z','#f0f0c0')])
D['tomato'] = ''.join([E(32,37,25,19,'#c23a2a'), '<polygon points="%s" fill="%s"/>' % (star(32,24,14,5.5),L1), R(30,10,5,8,L2,2)])
D['worm'] = ''.join([L('M12 16C54 6 54 30 32 34S10 54 50 48',PI,12), '<path d="M12 16C54 6 54 30 32 34S10 54 50 48" fill="none" stroke="%s" stroke-width="12" stroke-dasharray="5 10" stroke-dashoffset="-6"/>' % PK, C(14,16,3,U)])
D['turtle'] = ''.join([R(12,42,10,13,L1,3), R(32,42,10,13,L1,3), C(52,36,7,L1), C(54,34,2,U), P('M7 46A21 21 0 0 1 49 46Z',L2), Y('28,26 36,31 36,39 28,43 20,39 20,31',L1), C(14,41,4.5,L1), C(42,41,4.5,L1)])
D['mountain'] = ''.join([Y('28,56 46,22 58,56',S1), Y('6,56 24,14 44,56',S2), Y('24,14 15,33 21,30 24,36 29,30 33,33',CR), Y('46,22 40,34 44,32 47,36 50,32 52,34',CR)])
D['island'] = ''.join([L('M33 44Q36 34 32 23',W2,5), L('M32 23Q24 14 14 23',L1,6), L('M32 23Q40 14 50 23',L1,6), L('M32 23Q32 16 31 13',L1,6), C(34,27,3.5,W2), P('M12 50Q32 28 52 50Z',GO), L('M12 53Q16 49 20 53T28 53T36 53T44 53T52 53',WA,5)])
D['desert'] = ''.join([R(26,12,10,42,L1,5), L('M26 38H17V27',L1,7), L('M36 32H45V21',L1,7), P('M6 56C14 38 28 42 38 48C46 40 54 44 58 56Z',GO), C(50,16,6,OR)])
D['curry'] = ''.join([P('M10 36H54A22 20 0 0 1 10 36Z',R1), E(32,36,22,6,OR), C(43,33,4,W2), C(49,35,3,L1), P('M12 36C12 17 32 17 32 36Z',CR)])
D['soup-bowl'] = ''.join([L('M24 20Q19 15 24 10',S1,5), L('M38 20Q33 15 38 10',S1,5), P('M12 30H52V38A20 16 0 0 1 12 38Z',S2), R(11,25,42,7,S1,3), R(8,35,6,5,S2,2), R(50,35,6,5,S2,2)])
D['prayer'] = ''.join([P('M18 50V25Q18 12 27 7Q32 4 33 9V50Z',SK), P('M46 50V25Q46 12 37 7Q32 4 31 9V50Z','#d6a070'), R(14,46,36,11,CR,3)])
D['pudding'] = ''.join([E(32,52,26,5,S1), P('M12 51Q12 20 32 20Q52 20 52 51Z','#f0c860'), P('M13 36Q14 20 32 20Q50 20 51 36Q47 32 45 41Q42 32 38 38Q34 31 30 40Q26 32 22 40Q18 32 13 36Z',W2)])
D['compost'] = ''.join([L('M32 32V16',L2,5), E(23,16,8,5,L1,-25), E(41,16,8,5,L1,25), P('M6 56Q9 30 32 30Q55 30 58 56Z','#5b3a1e'), C(22,45,3.5,OR), C(40,44,3.5,R1), C(31,50,3,CR)])
D['carp-streamer'] = ''.join([R(8,8,6,48,W1), Y('18,16 30,19.5 30,41 18,44',R1), Y('30,19.5 40,22.5 40,39 30,41',CR), Y('40,22.5 52,26 52,36 40,39',R1), Y('52,26 58,21 55,31 58,41 52,36',R1), E(18,30,4,14,U), C(26,26,3.5,CR)])
D['caterpillar'] = ''.join([L('M44 20Q41 12 37 10',L2,5), L('M52 20Q55 12 57 10',L2,5), C(14,46,7,L2), C(25,48,7,L1), C(36,46,7,L2), C(45,43,8,L1), C(48,28,10,L1), C(44,27,3,U), C(53,27,3,U)])
D['deer'] = ''.join([L('M25 28L19 10M21 19L11 15',W2,5), L('M39 28L45 10M43 19L53 15',W2,5), E(15,35,8,4.5,W1,-20), E(49,35,8,4.5,W1,20), P('M20 28Q32 22 44 28L39 51Q32 56 25 51Z',W1), E(32,50,6,4.5,SK), C(32,50,3.5,U), C(25,37,3,U), C(39,37,3,U)])
D['path'] = ''.join([P('M6 58C10 48 24 46 26 38C28 30 20 24 26 8H34C32 22 42 28 38 38C36 46 52 48 58 58Z',S2), E(24,54,12,4.5,'#bdb7bd'), E(44,53,8,4,'#bdb7bd'), E(32,46,7,3.5,'#bdb7bd'), E(32,37,6,3.2,'#bdb7bd'), E(30,27,4.5,3,'#bdb7bd'), E(30,17,3.5,3,'#bdb7bd')])
D['ruin'] = ''.join([R(6,32,12,24,S1), Y('46,56 46,38 50,33 53,38 58,35 58,56',S1), P('M6 34C6 16 16 8 28 8V20C23 21 19 25 18 34Z',S2), P('M58 36C58 22 52 14 42 12V22C46 24 47 28 46 36Z',S2), R(26,46,12,10,S2,2)])
rows=[(10,[(6,24,S1),(32,26,S2)]),(26,[(6,12,S2),(20,24,S1),(46,12,S2)]),(42,[(6,24,S1),(32,26,S2)])]
D['stone-wall'] = ''.join(R(x,y,w,14,c,3) for y,rr in rows for x,w,c in rr)
D['wind-chime'] = ''.join([R(8,8,48,7,W2,3)]+[R(x,15,8,h,GO,3) for x,h in ((11,28),(22,38),(33,24),(44,33))])
D['bird'] = ''.join([Y('20,42 6,54 8,36',W2), C(32,32,20,W1), E(35,42,12,8,CR), E(27,35,10,7,W2,-15), Y('50,27 58,31 50,36',OR), C(40,26,3.5,U), L('M26 52V58M38 52V58',OR,5)])
D['rainbow'] = ''.join('<path d="M%s 52A%s %s 0 0 1 %s 52" fill="none" stroke="%s" stroke-width="5.2"/>' % (32-r, r, r, 32+r, c) for r, c in ((23,R1),(18,OR),(13,L1),(8,WA)))
D['wolf'] = ''.join([Y('10,8 28,20 12,34',S1), Y('54,8 36,20 52,34',S1), Y('13,14 24,21 14,28',S2), Y('51,14 40,21 50,28',S2), P('M12 24Q32 14 52 24L52 34L40 56H24L12 34Z',S1), P('M26 40H38L40 54H24Z',CR), E(32,52,5,3.5,U), C(23,33,3.5,OR), C(41,33,3.5,OR)])
D['badger'] = ''.join([C(13,17,7,U), C(51,17,7,U), E(32,35,22,20,CR), L('M22 15Q18 34 28 52',U,9), L('M42 15Q46 34 36 52',U,9), C(22,32,3.5,CR), C(42,32,3.5,CR), E(32,50,5,3.5,U)])
D['monkey'] = ''.join([C(14,32,8,W1), C(50,32,8,W1), C(14,32,4,SK), C(50,32,4,SK), C(32,32,18,W1), E(32,29,12,8,SK), E(32,43,12,9,CR), C(26,30,3,U), C(38,30,3,U), E(32,39,4,2.8,U)])
D['otter'] = ''.join([C(15,25,4.5,W2), C(49,25,4.5,W2), E(32,36,26,16,W2), E(32,43,16,10,CR), E(32,36,6,4,U), C(22,30,3,U), C(42,30,3,U), C(21,43,2.5,U), C(25,48,2.5,U), C(43,43,2.5,U), C(39,48,2.5,U)])

def src(slug, body):
    return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64" role="img" aria-label="%s">%s</svg>' % (slug.replace('-', ' '), body)

if __name__ == '__main__':
    import hearth
    os.makedirs(os.path.join(HERE, 'ico_src'), exist_ok=True)
    out_dir = os.environ.get('ICO_OUT') or os.path.join(ROOT, 'game/assets/img/ico'); os.makedirs(out_dir, exist_ok=True)
    for slug, body in D.items():
        s = src(slug, body); open(os.path.join(HERE, 'ico_src', 'ico-%s.svg' % slug), 'w').write(s)
        if len(sys.argv) > 1 and sys.argv[1] == 'src-only': continue
        o = hearth.restyle(s, 'ico-' + slug)
        open(os.path.join(out_dir, 'ico-%s.svg' % slug), 'w').write(o)
        print(slug, len(o.encode()))
