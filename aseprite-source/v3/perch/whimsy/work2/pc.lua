----------------------------------------------------------- Minty Fez Vendor
new()
for _,x in ipairs{21,37} do paint(mRect(x,50,x+5,54),R.BROWN) end
local fez=mPoly{{21,13},{43,13},{48,50},{16,50}}
paint(fez,R.WINE,function(i,x,y) if (x+y)%8==0 and i>=2 and i<=4 then return R.WINE[i+1] end end)
paint(mEll(32,13,11,3),{"#f08098","#d8607a","#b0384e","#8a2a48","#66264a"})
paint(mPoly{{16,44},{48,44},{49,50},{15,50}}==nil and {} or mPoly{{16,44},{48,44},{49,51},{15,51}},R.GOLD,function(i,x,y) if (x+y)%4==0 then return "#7a5078" end end)
-- tassel
paint(mLine(34,12,44,13,2),R.GOLD); paint(mLine(44,13,50,19,2),R.GOLD); paint(mLine(50,19,51,29,2),R.GOLD)
blob(51,33,3,4,R.GOLD); for x=49,53 do px(x,37,"#7a5078") end
eye(21,25,4)
for _,p in ipairs{{34,27},{35,26},{36,26},{37,26},{38,27}} do px(p[1],p[2],"#2b1c26") end
px(36,28,"#ff9ab8")
px(28,35,"#2b1c26") px(29,36,"#2b1c26") px(30,36,"#2b1c26") px(31,36,"#2b1c26") px(32,35,"#2b1c26")
px(21,33,"#ff9a80") px(22,33,"#ff9a80") px(40,33,"#ff9a80") px(41,33,"#ff9a80")
-- mint tea glass
paint(mEll(48,40,3,3),R.TAN)
paint(mRect(52,36,57,47),{"#e8f8ff","#c8ecff","#9ad8d0","#7ab8b0","#5a8a98"},function(i,x,y) if y>=39 then return ({"#d0f8a0","#9ad852","#7ac048","#4a9a50","#3a7a50"})[i] end end)
rect(52,36,57,36,"#fffbe8"); px(53,40,"#fffbe8"); px(53,41,"#fffbe8")
paint(mPoly{{54,36},{51,31},{56,32}},R.GREEN); px(54,33,"#d0f08a")
paint(mEll(48,43,2,3),R.TAN)
save("pl-spsk-6",{32,57,17,1},{{7,12},{56,12},{8,48}})

----------------------------------------------------------- Chestwatch Goldfish
new()
-- chest
local ch=mRect(21,46,47,58)
paint(ch,R.WOOD,function(i,x,y) if y%4==0 and i<=4 then return R.WOOD[i+1] end end)
paint(mAdd(mRect(21,41,47,47),mEll(34,45,13,5)),{"#d8a468","#b88048","#94603c","#704438","#4a304a"})
rect(21,47,47,48,"#ffd866"); rect(21,47,47,47,"#fff2a8"); rect(21,53,47,53,"#e8a83a")
rect(21,46,22,58,"#ffd866"); rect(46,46,47,58,"#b8783c")
rect(32,48,36,52,"#fff2a8"); rect(33,49,35,51,"#c89a30"); px(34,50,"#2b1c26")
-- tail + fins
paint(mPoly{{22,28},{6,17},{3,27},{6,38}},R.ORANGE,function(i,x,y) if (x+y)%3==0 and i<=3 then return R.ORANGE[i+1] end end)
paint(mPoly{{28,20},{35,10},{45,20}},R.ORANGE)
local body=mEll(34,30,15,12)
paint(body,R.ORANGE,function(i,x,y) local dx,dy=(x-34),(y-30) if ((dx+3)%5==0 or (dx+y)%7==0)and i>=2 and i<=4 and dx<8 then return R.ORANGE[i-1] end end)
paint(mPoly{{27,34},{33,30},{36,40},{28,41}},R.ORANGE,function(i,x,y) if (x+y)%3==0 then return "#ffd08a" end end)
-- eye + mouth
blob(43,26,4,4,{"#fffbe8","#fff6e0","#f6ecd8","#dcd0d8","#b0a4c8"})
rect(43,25,45,28,"#2b1c26"); px(43,25,"#fff6e0"); px(44,26,"#fff6e0")
rect(48,31,48,32,"#2b1c26")
px(40,35,"#ff9a80") px(41,35,"#ff9a80")
-- bubbles
for _,b in ipairs{{50,17},{54,12},{52,8}} do for _,d in ipairs{{1,0},{-1,0},{0,1},{0,-1}} do px(b[1]+d[1],b[2]+d[2],"#8cc8f0") end px(b[1]-1,b[2]-1,"#fffbe8") end
save("pl-wcen-6",{34,60,16,1},{{8,52},{57,32},{14,8}})

----------------------------------------------------------- Supervising Billy
new()
for _,x in ipairs{23,35} do paint(mRect(x,54,x+5,58),R.DARK) end
local WOOL={"#fffbe8","#f6ecd8","#e0d4d8","#b8a8c4","#8478a8"}
blob(32,45,17,11,WOOL,function(i,x,y) if H(x,y)<0.22 and i>=2 then return WOOL[math.max(1,i-1)] end if (x+y*2)%7==0 and i>=3 then return WOOL[i+1>5 and 5 or i+1] end end)
-- horns
local HR={"#f6dcaa","#dcb888","#b8946a","#8a6c58","#5e4a58"}
paint(mAdd(mLine(24,17,17,13,4,3),mLine(17,13,13,6,3,2),mLine(13,6,17,3,2,2)),HR)
paint(mAdd(mLine(40,17,47,13,4,3),mLine(47,13,51,6,3,2),mLine(51,6,47,3,2,2)),HR)
for _,p in ipairs{{20,14},{22,15},{44,14},{42,15}} do px(p[1],p[2],"#8a6c58") end
-- ears
paint(mEll(20,24,5,2.5),{"#fff0e0","#e8d4c0","#c8b0a0","#a08494","#745a78"}); paint(mEll(44,24,5,2.5),{"#fff0e0","#e8d4c0","#c8b0a0","#a08494","#745a78"})
-- head
paint(mEll(32,28,9,11),{"#fff6e8","#f0e0cc","#dcc4b4","#b09aa8","#7c6a90"})
-- eyes: amber w/ horizontal pupil
for _,x in ipairs{25,35} do paint(mEll(x+2,25,3,2.5),{"#fff2a8","#ffd866","#f0b43a","#c8883a","#8a5a48"}) rect(x,25,x+3,25,"#2b1c26") px(x,24,"#fffbe8") end
-- nose + mouth w/ grape
paint(mEll(32,33,4,3),{"#ffd0dc","#ffb0c8","#e08aa8","#b06488","#7a4a74"})
px(30,32,"#7a4a74") px(34,32,"#7a4a74")
rect(29,36,35,36,"#2b1c26")
-- beard
paint(mPoly{{29,38},{35,38},{33,47},{31,47}},{"#fff6e8","#f0e0cc","#dcc4b4","#b09aa8","#7c6a90"})
-- grape
blob(37,38,3,3,{"#c8a0f0","#9a6ad8","#7a4ab8","#5a3a98","#3c2a70"}); px(36,37,"#fffbe8")
paint(mLine(37,35,38,33,1),R.GREEN); px(39,34,"#9ad852") px(40,33,"#9ad852")
save("pl-wgoa-6",{32,60,17,1},{{8,38},{56,40},{32,4}})

----------------------------------------------------------- Splinter Paw Panda
new()
local PB={"#8a84b0","#625c8c","#463e6e","#342c58","#2e2048"}
local PW={"#fffbf4","#f6f0ec","#dcd4e0","#b4acd0","#8078b0"}
paint(mEll(25,57,6,3.5),PB); paint(mEll(39,57,6,3.5),PB)
blob(32,45,15,12,PW)
-- left arm (viewer's left) holding bamboo
paint(mLine(19,41,17,50,6,5),PB)
paint(mRect(12,44,15,56),R.GREEN,function(i,x,y) if y%5==0 then return R.GREEN[4] end end)
paint(mPoly{{12,44},{15,44},{13,40}},R.GREEN)
-- raised right arm
paint(mLine(46,42,51,29,6,5),PB)
blob(51,26,4,4,PB); paint(mEll(51,27,2,2),{"#ffd0dc","#ffb0c8","#e08aa8","#e08aa8","#b06488"})
paint(mLine(52,22,54,26,1),{"#f6dcaa","#e4bc82","#c4966a","#c4966a","#9a6c50"}); px(52,22,"#fff0c0") px(51,23,"#e4bc82")
-- head
paint(mEll(22,15,4.5,4.5),PB); paint(mEll(42,15,4.5,4.5),PB)
blob(32,25,14,11,PW)
paint(mEll(25,26,4,5),PB); paint(mEll(39,26,4,5),PB)
rect(24,24,26,26,"#fffbf4"); rect(38,24,40,26,"#fffbf4"); rect(24,24,25,25,"#fffbf4"); px(25,25,"#2b1c26"); px(39,25,"#2b1c26"); px(24,24,"#ffffff" == "" and "" or "#fff6e0"); px(38,24,"#fff6e0")
rect(24,25,24,26,"#2b1c26") rect(40,25,40,26,"#2b1c26") px(25,26,"#6a4a7a") px(39,26,"#6a4a7a")
rect(30,29,34,30,"#463e6e"); px(31,29,"#8a84b0")
px(31,33,"#463e6e") px(32,34,"#463e6e") px(33,33,"#463e6e")
-- brow (serious)
rect(22,21,27,21,"#462e5a"); rect(37,21,42,21,"#462e5a")
save("pl-wpan-6",{32,60,17,1},{{8,20},{58,12},{54,52}})
