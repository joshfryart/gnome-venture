----------------------------------------------------------- Starwise Cheerer
new()
for _,x in ipairs{23,36} do paint(mRect(x,56,x+5,58),R.BROWN) end
local SK=R.SKIN
-- arms up
paint(mLine(23,37,13,26,5,4),SK); paint(mLine(41,37,51,26,5,4),SK)
blob(12,23,3.5,3.5,SK); blob(52,23,3.5,3.5,SK)
-- starry robe
local NIGHT={"#6a6ac0","#4a4aa0","#38388a","#2a2a6a","#241c52"}
paint(mPoly{{22,35},{42,35},{47,57},{17,57}},NIGHT,function(i,x,y) if H(x,y)>0.93 then return "#ffe98a" end end)
for _,p in ipairs{{26,44},{37,48},{30,52},{41,41}} do sparkle(p[1],p[2]) end
paint(mRect(21,35,43,37),{"#ff9a80","#ee5a48","#c8383a","#923050","#5e2a58"})
-- head
blob(32,23,10,10,SK)
-- hair
paint(mEll(32,15,10,4.5),{"#6a5a7a","#463e6e","#342c58","#2e2048","#241c38"})
-- headband
paint(mRect(22,18,42,20),{"#ff9a80","#ee5a48","#c8383a","#923050","#5e2a58"})
blob(32,19,3,3,R.GOLD); px(32,17,"#fffbe8")
-- happy closed eyes
for _,p in ipairs{{26,25},{27,24},{28,24},{29,25},{35,25},{36,24},{37,24},{38,25}} do px(p[1],p[2],"#2b1c26") end
rect(30,28,34,29,"#2b1c26"); rect(31,29,33,30,"#c8383a"); px(31,28,"#fff6e0")
px(24,28,"#ff9a80") px(25,28,"#ff9a80") px(39,28,"#ff9a80") px(40,28,"#ff9a80")
save("pl-wsta-6",{32,60,16,1},{{6,12},{58,12},{8,52}})

----------------------------------------------------------- Plumetail Digger
new()
-- crate
paint(mRect(8,49,38,59),R.WOOD,function(i,x,y) if y==54 or (x-8)%10==0 then return R.WOOD[4] end end)
paint(mPoly{{8,49},{38,49},{43,45},{13,45}},{"#f0c888","#d8a468","#b88048","#94603c","#704438"})
paint(mPoly{{38,49},{43,45},{43,56},{38,59}},{"#94603c","#94603c","#704438","#704438","#4a304a"})
px(10,51,"#e8a83a") px(36,51,"#e8a83a") px(10,57,"#e8a83a") px(36,57,"#e8a83a")
-- amber
local AM={"#fff2a8","#ffd45a","#f2a030","#c8683a","#8a3a50"}
for a=0,1,0.04 do px(50+math.cos(a*6.283)*8,52+math.sin(a*6.283)*6,"#ffe98a") end
blob(50,52,6,5,AM)
px(47,49,"#fffbe8") px(48,49,"#fffbe8") px(47,50,"#fffbe8") px(52,55,"#ffd45a")
-- tail plume
local ORR={"#ffc08a","#f08a4a","#d0602e","#9a4040","#623a58"}
paint(mAdd(mEll(46,29,9,17),mEll(42,13,5,5)),ORR,function(i,x,y) if (x-y)%5==0 and i>=2 and i<=4 then return ORR[i+1] end end)
paint(mEll(48,15,3,3),R.CREAM)
-- body
blob(26,37,9,10,ORR)
paint(mEll(26,40,5,7),R.CREAM)
blob(26,46,6,2.5,ORR)
-- head
paint(mPoly{{17,15},{15,5},{21,10}},ORR); paint(mPoly{{35,15},{37,5},{31,10}},ORR)
px(16,8,"#4a304a") px(36,8,"#4a304a")
blob(26,22,9,8,ORR)
paint(mEll(26,26,5,3.5),R.CREAM)
eye(19,18,4); eye(28,18,4)
rect(25,24,26,25,"#2b1c26"); px(25,24,"#fff6e0")
px(24,28,"#2b1c26") px(27,28,"#2b1c26") rect(25,29,26,29,"#2b1c26")
-- pick
paint(mLine(15,42,13,32,2),R.WOOD)
paint(mPoly{{8,31},{18,30},{18,32},{8,33}},R.GREY); px(8,31,"#e8e4ee")
paint(mLine(16,41,19,40,3),ORR)
save("pl-ambr-6",{26,60,20,1},{{6,10},{56,8},{58,38}})

----------------------------------------------------------- Twinhump Stroller
new()
for _,x in ipairs{20,25,37,43} do paint(mRect(x,48,x+3,57),TAN==nil and R.TAN or R.TAN) end
for _,x in ipairs{19,24,36,42} do paint(mRect(x,56,x+5,58),R.BROWN) end
-- neck + head
paint(mLine(20,38,16,24,7,6),R.TAN)
blob(15,21,9,7,R.TAN)
paint(mEll(12,25,5,3),{"#fff0d0","#f6dcaa","#e4bc82","#c4966a","#9a6c50"})
paint(mEll(8,15,2.5,3),R.TAN); paint(mEll(22,15,2.5,3),R.TAN)
px(8,15,"#ff9ab8") px(22,15,"#ff9ab8")
-- body
blob(35,42,17,9,R.TAN)
-- humps
blob(28,31,6,7,R.TAN) blob(42,31,6,7,R.TAN)
for _,p in ipairs{{26,26},{27,25},{40,26},{41,25},{44,26}} do px(p[1],p[2],"#fff0d0") end
-- red blanket
paint(mPoly{{24,36},{48,36},{51,47},{22,47}},R.RED)
for x=23,50,3 do px(x,47,"#ffd866") px(x,48,"#b8783c") end
for x=25,48,4 do px(x,41,"#ffd866") px(x+1,42,"#ffd866") px(x+2,41,"#ffd866") end
rect(24,36,48,36,"#ffd866")
-- face
eye(10,17,3); eye(16,17,3)
rect(10,26,12,26,"#2b1c26") px(9,25,"#2b1c26") px(13,25,"#2b1c26")
px(9,22,"#2b1c26") px(10,22,"#2b1c26")
-- tail tuft
paint(mEll(53,40,2.5,4),R.BROWN)
save("pl-oasi-6",{32,60,20,1},{{8,6},{56,8},{54,54}})

----------------------------------------------------------- Scarlet Riddlecaller
new()
-- perch
paint(mLine(8,54,56,53,5,5),R.WOOD,function(i,x,y) if x%9==0 then return R.WOOD[4] end end)
-- tail
paint(mPoly{{27,46},{38,46},{43,57},{34,60}},R.RED)
paint(mPoly{{34,52},{40,52},{43,57},{36,60}},R.BLUE)
-- body
blob(30,37,12,15,R.RED,function(i,x,y) if (x+y)%6==0 and i>=2 and i<=4 then return R.RED[i+1] end end)
-- wing
paint(mPoly{{34,30},{43,34},{44,46},{36,48}},R.RED)
paint(mPoly{{34,36},{44,38},{44,43},{35,42}},R.YEL); paint(mPoly{{35,42},{44,43},{44,48},{36,48}},R.BLUE)
-- feet
for _,x in ipairs{25,32} do rect(x,48,x+2,51,"#c4a8a0"); rect(x,52,x+3,52,"#c4a8a0") end
-- head
blob(29,20,10,9,R.RED)
paint(mEll(24,21,5.5,5),{"#ffffff"=="" and "" or "#fffbf4","#fffbf4","#f0e8ec","#d0c4d8","#a898c4"})
for _,p in ipairs{{21,20},{22,22},{23,24},{25,25}} do px(p[1],p[2],"#d0c4d8") end
eye(21,17,3)
px(23,23,"#ff9ab8")
-- open beak
paint(mPoly{{27,20},{34,20},{36,26},{34,28},{29,26}},{"#fffbe8","#f6ecd8","#dcd0d8","#b0a4c8","#7c72a8"})
paint(mPoly{{29,28},{34,28},{33,32},{30,31}},{"#f6ecd8","#dcd0d8","#b0a4c8","#b0a4c8","#7c72a8"})
rect(30,26,34,27,"#923050"); px(32,27,"#ff9a80")
-- riddle mark
rect(47,12,50,12,"#ffd866"); px(51,13,"#ffd866"); px(51,14,"#ffd866"); px(50,15,"#ffd866"); px(49,16,"#ffd866"); px(49,17,"#ffd866"); px(49,19,"#ffd866"); px(49,20,"#ffd866")
px(48,13,"#fff2a8") px(47,13,"#ffd866")
save("pl-step-6",{32,60,17,1},{{8,10},{12,34},{56,30}})
