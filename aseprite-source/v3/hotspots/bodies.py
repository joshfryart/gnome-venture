# icon bodies (Lua, 48x48 coords, centre 24,24, keep inside radius ~17). Helpers come from prelude.lua.
B = {}
B['shops'] = '''
fill(rect(11,27,36,36), R.wood)
fill(rect(12,19,14,27), R.wood) fill(rect(33,19,35,27), R.wood)
for i=0,5 do local x0=10+i*4.5 x0=floor(x0)
  fill(rect(x0,12,x0+4,19), (i%2==0) and R.red or R.cream)
  fill(ell(x0+2.5,19.5,2.5,2), (i%2==0) and R.red or R.cream) end
fill(ell(17,25,2.5,2.5),R.red) fill(ell(24,25,2.5,2.5),R.gold) fill(ell(31,25,2.5,2.5),R.green)
'''
B['homes'] = '''
fill(rect(30,11,33,19), R.stone)
fill(rect(13,23,34,35), R.cream)
fill(poly{{9,24},{24,9},{39,24}}, R.red)
fill(rect(21,28,26,35), R.wood)
fill(rect(15,26,19,30), R.gold) fill(rect(29,26,32,30), R.gold)
'''
B['do'] = '''
fill(ell(22,26,13,13), R.red) fill(ell(22,26,9,9), R.cream) fill(ell(22,26,5.5,5.5), R.red) fill(ell(22,26,2.5,2.5), R.gold)
fill(line(37,10,24,24,2.4), R.wood)
fill(poly{{34,8},{40,8},{40,14},{37,12}}, R.green)
fill(poly{{22,26},{27,26},{24,22}}, R.stone)
'''
B['people'] = '''
fill(poly{{9,36},{11,27},{23,27},{25,36}}, R.blue)
fill(poly{{23,36},{25,28},{37,28},{39,36}}, R.green)
fill(ell(17,22,5,5), R.skin) fill(ell(31,23,5,5), R.skin)
fill(poly{{11,19},{17,8},{23,19}}, R.red)
fill(poly{{25,20},{31,9},{37,20}}, R.orange)
'''
B['stop'] = '''
fill(rect(22,13,25,38), R.bark)
fill(poly{{10,12},{31,12},{37,17},{31,22},{10,22}}, R.wood)
fill(poly{{38,25},{17,25},{11,30},{17,35},{38,35}}, R.cream)
dot(14,17,INK) dot(15,17,INK) dot(33,30,INK) dot(34,30,INK)
'''
B['garden'] = '''
fill(rect(10,32,37,37), R.bark)
fill(line(24,33,24,21,2.4), R.green)
fill(poly{{24,29},{11,22},{12,28},{20,31}}, R.green)
fill(poly{{24,26},{37,18},{37,25},{28,29}}, R.green)
fill(ell(24,17,5,5), R.pink) fill(ell(24,17,2,2), R.gold)
'''
B['fire'] = '''
fill(poly{{24,7},{32,18},{34,27},{24,33},{14,27},{16,18}}, R.red)
fill(poly{{24,14},{29,22},{30,28},{24,32},{18,28},{19,22}}, R.orange)
fill(poly{{24,22},{27,27},{24,31},{21,27}}, R.gold)
fill(line(10,37,38,31,4), R.bark) fill(line(10,31,38,37,4), R.wood)
'''
B['shop'] = '''
fill(Mi(ell(24,24,11,12), Mi(ell(24,24,7,8), rect(0,0,47,23))), R.bark)
fill(ell(18,22,4.5,4.5), R.red) fill(ell(28,22,4.5,4.5), R.gold) fill(poly{{22,17},{26,13},{28,19}}, R.green)
fill(poly{{10,24},{38,24},{34,38},{14,38}}, R.wood)
for y=28,35,4 do for x=12,36 do if I[K(x,y)] then I[K(x,y)] = R.wood[3] end end end
'''
B['investigate'] = '''
fill(poly{{23,6},{27,20},{41,24},{27,28},{23,42},{19,28},{5,24},{19,20}}, R.gold)
fill(poly{{34,7},{36,12},{41,14},{36,16},{34,21},{32,16},{27,14},{32,12}}, R.cream)
fill(poly{{12,30},{14,34},{18,36},{14,38},{12,42},{10,38},{6,36},{10,34}}, R.cream)
'''
B['mouth'] = '''
fill(Mi(ell(24,37,16,22), rect(0,38,47,47)), R.stone)
fill(Mi(ell(24,38,8.5,14), rect(0,38,47,47)), R.dark)
fill(ell(11,35,4,3), R.stone) fill(ell(37,35,4,3), R.stone)
fill(ell(14,26,3,2), R.green) fill(ell(33,24,3,2.5), R.green)
'''
B['mouth-lair'] = '''
fill(Mi(ell(24,37,16,22), rect(0,38,47,47)), R.dark)
fill(Mi(ell(24,38,9,14), rect(0,38,47,47)), {"#2a1424","#1a0c1a","#1a0c1a"})
for i=0,3 do local x=17+i*4.5 fill(poly{{x,24},{x+4,24},{x+2,30}}, R.cream) end
for i=0,2 do local x=19+i*4.5 fill(poly{{x,37},{x+4,37},{x+2,32}}, R.cream) end
flat(ell(20.5,33,1.5,1.5),"#ff5a3a") flat(ell(28.5,33,1.5,1.5),"#ff5a3a")
fill(ell(11,35,4,3), R.dark) fill(ell(37,35,4,3), R.dark)
'''
B['wild'] = '''
fill(poly{{11,37},{12,23},{22,12},{37,9},{36,22},{26,32}}, R.green)
fill(line(10,38,32,15,1.8), {R.green[3],R.green[3],R.green[3]})
fill(poly{{22,24},{27,24},{27,28},{23,28}}, R.green)
dot(19,32,R.green[1]) dot(25,25,R.green[1])
'''
B['green'] = '''
fill(rect(22,27,26,38), R.bark)
fill(ell(24,17,10,9), R.green) fill(ell(16,25,8,6.5), R.green) fill(ell(32,25,8,6.5), R.green)
flat(ell(19,15,2,1.5), R.green[1]) flat(ell(29,24,2,1.5), R.green[3])
'''
B['teahouse'] = '''
fill(Mi(ell(24,26,12,12), rect(0,0,47,25)), R.blue)
fill(rect(12,24,35,27), R.cream)
fill(ring(37,28.5,5,2.5), R.blue)
fill(ell(24,37,14,2), R.stone)
fill(line(20,19,22,15,2), R.cream) fill(line(22,15,20,11,2), R.cream)
fill(line(28,19,30,15,2), R.cream) fill(line(30,15,28,11,2), R.cream)
'''
B['board'] = '''
fill(rect(15,34,18,39), R.bark) fill(rect(30,34,33,39), R.bark)
fill(rect(9,10,38,34), R.wood) fill(rect(11,12,36,32), R.cream)
fill(rect(13,14,21,21), R.pink) fill(rect(25,15,34,23), R.gold) fill(rect(14,24,24,30), R.green)
flat(rect(26,26,34,31), R.blue[2])
dot(17,15,R.red[2]) dot(29,16,R.red[2]) dot(19,25,R.red[2]) dot(30,27,R.red[1])
'''
B['library'] = '''
fill(rect(10,31,37,37), R.red) fill(rect(12,32,13,36), R.gold)
fill(rect(13,24,38,30), R.blue) fill(rect(15,25,16,29), R.gold)
fill(rect(10,17,34,23), R.green) fill(rect(12,18,13,22), R.gold)
fill(rect(34,17,37,23), R.cream) fill(rect(35,31,37,37), R.cream)
fill(poly{{29,10},{32,10},{32,17},{30.5,15},{29,17}}, R.red)
'''
B['books'] = '''
fill(poly{{9,15},{23,18},{23,36},{9,33}}, R.cream) fill(poly{{25,18},{39,15},{39,33},{25,36}}, R.cream)
fill(line(24,17,24,37,2), R.teal)
fill(poly{{12,19},{20,21},{20,23},{12,21}}, R.blue) fill(poly{{28,21},{36,19},{36,21},{28,23}}, R.blue)
fill(poly{{12,26},{20,28},{20,30},{12,28}}, R.blue) fill(poly{{28,28},{36,26},{36,28},{28,30}}, R.blue)
'''
B['rest'] = '''
fill(rect(9,32,38,36), R.bark) fill(rect(9,27,12,36), R.bark) fill(rect(35,30,38,38), R.bark)
fill(rect(11,26,36,32), R.cream)
fill(rect(21,24,36,32), R.blue)
fill(ell(16.5,25,5,3), R.glass)
fill(Mi(ell(33,14,5.5,5.5), ell(35.5,12.5,4.5,4.5)), R.gold)
'''
B['knock'] = '''
fill(U(rect(14,16,33,38), Mi(ell(23.5,17,9.5,6), rect(0,18,47,47))), R.wood)
fill(rect(23,13,24,38), {R.wood[3],R.wood[3],R.wood[3]})
fill(ring(24,27,4.5,2.4), R.gold) fill(rect(22,19,26,22), R.gold)
fill(line(36,19,39,16,2), R.cream) fill(line(36,25,40,25,2), R.cream) fill(line(36,31,39,34,2), R.cream)
'''
B['gift'] = '''
fill(rect(11,22,36,37), R.red) fill(rect(9,17,38,23), {R.red[1],R.red[1],R.red[2]})
fill(rect(22,17,25,37), R.gold)
fill(ell(18.5,13.5,5,3.5), R.gold) fill(ell(29.5,13.5,5,3.5), R.gold) fill(ell(24,15,2.5,2.5), R.gold)
flat(ell(18.5,13.5,2,1.2), R.red[3]) flat(ell(29.5,13.5,2,1.2), R.red[3])
'''
B['back'] = '''
fill(line(35,37,35,20,5), R.blue)
fill(line(35,20,22,20,5), R.blue)
fill(poly{{8,20},{21,8},{21,32}}, R.blue)
'''
B['prev'] = '''
fill(rect(11,11,15,37), R.gold)
fill(poly{{37,10},{37,38},{17,24}}, R.gold)
'''
B['next'] = '''
fill(rect(33,11,37,37), R.gold)
fill(poly{{11,10},{11,38},{31,24}}, R.gold)
'''
B['building'] = '''
fill(rect(12,14,35,38), R.cream)
fill(rect(10,10,37,15), R.red)
for r=0,1 do for c=0,2 do fill(rect(15+c*7,18+r*8,18+c*7,22+r*8), R.blue) end end
fill(rect(21,30,26,38), R.wood)
'''
B['trip'] = '''
fill(rect(12,10,36,16), R.blue) fill(rect(10,10,12,16), R.cream) fill(rect(36,10,38,16), R.cream)
fill(U(rect(13,23,34,38), ell(23.5,23,10.5,6)), R.orange)
fill(rect(13,26,34,31), {R.orange[2],R.orange[2],R.orange[3]})
fill(rect(22,29,25,33), R.gold)
fill(rect(15,17,17,23), R.bark) fill(rect(30,17,32,23), R.bark)
'''
B['delve'] = '''
fill(line(12,38,31,12,3), R.wood)
fill(poly{{18,9},{27,6},{39,13},{37,19},{29,14},{21,16}}, R.stone)
fill(poly{{12,40},{16,36},{16,40}}, R.stone) 
'''
B['cellar'] = '''
fill(ell(24,24,12,14), R.wood)
for _,y in ipairs({14,22,30}) do local b=X(rect(0,y,47,y+2), ell(24,24,12,14)) fill(b, R.stone) end
fill(rect(22,26,26,29), R.gold) fill(rect(21,28,27,29), R.gold)
'''
B['loft'] = '''
fill(line(16,39,16,20,3), R.wood) fill(line(32,39,32,20,3), R.wood)
for _,y in ipairs({22,28,34}) do fill(rect(15,y,33,y+2), R.wood) end
fill(poly{{24,6},{35,18},{13,18}}, R.gold)
'''
B['cooking'] = '''
fill(poly{{14,34},{18,38},{30,38},{34,34}}, R.red) fill(poly{{22,34},{24,29},{26,34}}, R.gold)
fill(U(rect(11,19,36,29), ell(23.5,29,12.5,6)), R.dark)
fill(rect(9,17,38,20), R.stone)
fill(rect(5,22,10,25), R.stone) fill(rect(37,22,42,25), R.stone)
fill(line(19,14,21,10,2), R.cream) fill(line(21,10,19,6,2), R.cream)
fill(line(27,14,29,10,2), R.cream) fill(line(29,10,27,6,2), R.cream)
'''
B['pantry'] = '''
fill(rect(9,36,38,39), R.wood)
fill(rect(11,22,22,36), R.glass) fill(rect(12,27,21,35), R.red) fill(rect(10,19,23,22), R.wood)
fill(rect(26,16,36,36), R.glass) fill(rect(27,23,35,35), R.gold) fill(rect(25,13,37,16), R.wood)
'''
B['tools'] = '''
fill(line(12,37,30,15,3), R.wood)
fill(poly{{23,7},{37,14},{34,20},{20,13}}, R.stone)
fill(line(36,37,18,15,3), R.stone)
fill(ring(16,13,5,2.5), R.stone)
'''
B['potions'] = '''
fill(rect(21,9,26,19), R.glass)
fill(ell(24,29,11,10), R.glass)
fill(X(ell(24,29,10,9), rect(0,27,47,47)), R.purple)
fill(rect(20,6,27,10), R.wood)
fill(ell(20,31,2,2), R.pink) fill(ell(27,28,1.5,1.5), R.pink) dot(23,24,R.purple[1])
'''
B['decor'] = '''
fill(U(ell(24,33,8,6), rect(20,24,27,30)), R.teal)
fill(line(21,25,15,13,2), R.green) fill(line(26,25,32,12,2), R.green) fill(line(24,25,24,10,2), R.green)
fill(ell(15,12,4.5,4.5), R.pink) fill(ell(32,11,4.5,4.5), R.gold) fill(ell(24,9.5,4,4), R.red)
flat(ell(24,9.5,1.4,1.4), R.gold[2])
'''
B['station'] = '''
fill(rect(9,22,38,26), R.wood)
fill(rect(11,26,14,38), R.bark) fill(rect(33,26,36,38), R.bark)
fill(U(rect(14,16,24,21), ell(19,21,5,4)), R.cream)
fill(line(30,24,35,12,2.4), R.gold) fill(ell(35.5,11,3,3), R.gold)
'''
B['plate'] = '''
fill(line(16,8,16,15,2), R.stone) fill(line(32,8,32,15,2), R.stone)
fill(rect(9,15,38,34), R.wood) fill(rect(12,18,35,31), R.cream)
fill(poly{{24,29},{19,24},{19,21},{22,20},{24,22},{26,20},{29,21},{29,24}}, R.green)
'''
B['sick'] = '''
fill(line(12,36,36,12,10), R.cream)
fill(rect(19,19,28,28), R.cream)
flat(rect(21,21,26,26), R.red[2]) 
fill(ring(24,24,19.5,19.5), R.red) if false then end
dot(19,19,R.red[3]) dot(28,28,R.red[3])
'''
B['light'] = '''
fill(ring(24,11,5,2.5), R.stone)
fill(rect(17,15,30,18), R.dark) fill(rect(17,32,30,35), R.dark)
fill(rect(18,18,29,32), R.glass)
fill(ell(23.5,26,4.5,5.5), R.orange) fill(ell(23.5,27,2.5,3.5), R.gold)
fill(rect(16,18,17,32), R.dark) fill(rect(30,18,31,32), R.dark)
'''
B['yard'] = '''
fill(rect(22,26,26,38), R.bark)
fill(ell(24,17,10,9), R.green) fill(ell(16,25,7,5.5), R.green) fill(ell(32,25,7,5.5), R.green)
fill(rect(9,34,38,38), R.green)
'''
B['catfish'] = '''
fill(U(ell(22,24,12,8), poly{{32,24},{40,15},{40,33}}), R.teal)
fill(poly{{16,17},{22,10},{28,18}}, R.teal)
flat(rect(14,22,15,23), INK)
fill(line(8,22,3,19,2), R.stone) fill(line(8,26,3,29,2), R.stone)
fill(rect(17,28,28,29), R.cream)
'''
B['puzzles'] = '''
fill(U(rect(11,16,34,38), ell(22.5,13,4.5,4.5), ell(36,27,4.5,4.5)), R.purple)
fill(ell(11,27,4.5,4.5), {R.purple[2],R.purple[2],R.purple[2]})
flat(ell(11,27,2,2), R.purple[2])
'''
B['parlour'] = '''
fill(rect(11,12,36,26), R.red)
fill(rect(8,20,13,36), R.red) fill(rect(34,20,39,36), R.red)
fill(rect(11,26,36,36), R.orange)
fill(rect(13,36,16,39), R.bark) fill(rect(31,36,34,39), R.bark)
fill(ell(24,22,8,3), R.pink)
'''
B['contests'] = '''
fill(Mi(ell(24,19,10,12), rect(0,0,47,6)), R.gold)
fill(ring(11,16,5,2.5), R.gold) fill(ring(37,16,5,2.5), R.gold)
fill(rect(22,28,26,34), R.gold) fill(rect(15,34,32,38), R.wood)
fill(ell(24,21,2.5,2.5), R.cream)
'''
# fix up odd ones after the dict
B['sick'] = '''
fill(poly{{24,36},{10,23},{10,16},{15,11},{20,11},{24,15},{28,11},{33,11},{38,16},{38,23}}, R.red)
fill(rect(21,16,26,29), R.cream) fill(rect(16,20,31,25), R.cream)
'''
B['catfish'] = '''
fill(poly{{30,24},{40,14},{40,34}}, R.teal)
fill(ell(21,24,12,8.5), R.teal)
fill(poly{{15,17},{21,11},{27,17}}, R.teal)
flat(rect(12,21,13,22), INK) flat(rect(12,21,13,21), R.cream[1])
fill(line(10,25,3,22,2), R.cream) fill(line(10,27,3,30,2), R.cream)
fill(rect(17,28,27,29), R.teal[1])
'''
