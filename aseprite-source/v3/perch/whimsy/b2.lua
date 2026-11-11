local jag={"#ffd68a","#ffb04a","#e8872a","#b8603a","#6a3a55"}
----------------------------------------------------------- scarab
pal("pl-scr-6",{32,61,16,1},{{7,14},{57,8},{58,50}},function()
  local lc="#35306e"
  for _,l in ipairs{{19,36,8,29},{17,44,6,46},{19,52,9,58}} do
    line(l[1],l[2],l[3],l[4],lc,2); line(63-l[1],l[2],63-l[3],l[4],lc,2)
    px(l[3],l[4],"#6a6fb0"); px(63-l[3],l[4],"#6a6fb0") end
  sblob(32,44,15,15,2,R.blue,function(i,x,y)
    if x==31 or x==32 then return R.blue[5] end
    if i==1 and (x<30 and y<40) then return "#e8f8ff" end end)
  for y=34,56,3 do px(24,y,"#ffd966"); px(39,y,"#ffd966") end
  for x=22,41,3 do px(x,58,"#ffd966") end
  px(23,37,"#fff6e0"); px(24,36,"#fff6e0")
  sblob(32,26,9,7,2,R.blue)
  eye(25,24,4,5); eye(35,24,4,5)
  px(31,30,"#2b1c26"); px(32,31,"#2b1c26"); px(33,30,"#2b1c26")
  px(27,31,"#f5a0b8"); px(37,31,"#f5a0b8")
  poly({{29,20},{35,20},{32,12}},R.blue)
  sblob(32,18,3,3,2,{"#ffc0b0","#ff6a5a","#d8332f","#9a2a40","#55284f"}); px(31,17,"#fff6e0")
  px(26,32,"#35306e"); px(38,32,"#35306e")
end)
----------------------------------------------------------- jaguar
pal("pl-jrc-6",{32,61,22,1},{{7,16},{57,10},{58,36}},function()
  sblob(32,55,23,6,2,R.grey,function(i,x,y) if i<=2 and H(x,y)<0.2 then return "#8fd05a" end end)
  for _,b in ipairs{{49,50,3,5},{52,43,3,5},{51,36,3,4}} do sblob(b[1],b[2],b[3],b[4],2,jag) end
  sblob(50,32,3,3,2,R.black)
  sblob(32,47,10,10,2,jag)
  sblob(32,50,6,6,2,R.cream)
  px(27,44,"#2b1c26"); px(28,44,"#2b1c26"); px(37,45,"#2b1c26"); px(36,45,"#2b1c26"); px(25,49,"#2b1c26"); px(40,49,"#2b1c26")
  sblob(26,55,4,3,2,R.cream); sblob(38,55,4,3,2,R.cream)
  sblob(21,19,4,4,2,jag); sblob(43,19,4,4,2,jag); px(21,20,"#f5a0b8"); px(22,20,"#f5a0b8"); px(43,20,"#f5a0b8"); px(42,20,"#f5a0b8")
  sblob(32,30,14,11,2,jag)
  sblob(32,35,6,4,2,R.cream)
  for _,e in ipairs{22,37} do
    rect(e,25,e+4,30,"#8fd05a"); rect(e,25,e+4,25,"#c8f08a"); rect(e+2,25,e+2,30,"#2b1c26"); rect(e+1,26,e+3,29,"#2b1c26")
    px(e+1,26,"#fff6e0"); px(e,26,"#fff6e0"); px(e+3,29,"#d8f0a8")
  end
  line(21,23,26,24,"#6a3a55",1); line(37,24,42,23,"#6a3a55",1)
  rect(31,33,32,33,"#e8688f"); px(31,34,"#2b1c26"); px(32,34,"#2b1c26"); px(29,35,"#2b1c26"); px(30,35,"#2b1c26"); px(33,35,"#2b1c26"); px(34,35,"#2b1c26")
  for _,p in ipairs{{31,20},{32,20},{32,21},{28,21},{36,21},{18,28},{46,28}} do px(p[1],p[2],"#6a3a55") end
  px(18,33,"#fff6e0"); px(19,34,"#fff6e0"); px(46,33,"#fff6e0"); px(45,34,"#fff6e0")
end)
----------------------------------------------------------- barrel
pal("pl-scg-6",{31,61,18,1},{{8,20},{57,12},{58,44}},function()
  sblob(32,41,17,17,3,R.wood,function(i,x,y) if x%6==0 and i>=2 and i<=4 then return R.wood[i+1] end end)
  for k,_ in pairs(M) do local y,x=k:match("(%-?%d+),(%-?%d+)") y=tonumber(y) x=tonumber(x)
    if y==30 or y==52 then px(x,y,"#9aa4be") elseif y==31 or y==53 then px(x,y,"#707a9c") elseif y==29 or y==51 then if x<34 then px(x,y,"#e4e8f0") end end end
  sblob(32,25,15,5,2,{"#e0b078","#c8905a","#a8683c","#7a4a38","#4a2f45"})
  sblob(32,25,12,3,2,{"#fffbe8","#fff0a0","#ffe08a","#d8c868","#9a8a5a"})
  -- peeking moon
  blobf(function(x,y) return ((x-32)^2+(y-17)^2<=36) and ((x-35)^2+(y-14)^2>20) end,32,17,6,6,{"#fffbe8","#fff6c8","#ffe98a","#e8c868","#b89a6a"})
  px(30,13,"#fffbe8")
  eye(23,37,4,5); eye(36,37,4,5)
  px(31,43,"#2b1c26"); px(32,44,"#2b1c26"); px(33,44,"#2b1c26"); px(34,43,"#2b1c26")
  rect(21,43,23,43,"#e8688f"); rect(40,43,42,43,"#e8688f")
  rect(49,41,54,44,"#9aa4be"); rect(49,41,54,41,"#e4e8f0"); rect(49,44,54,44,"#4a4a72"); rect(52,45,53,46,"#9aa4be")
  px(53,48,"#ffe98a"); px(53,49,"#ffe98a"); px(53,50,"#fffbe8")
end)
----------------------------------------------------------- fox
pal("pl-aurc-6",{32,60,22,1},{{8,16},{57,12},{58,38}},function()
  sblob(38,47,19,11,2,R.orange)
  sblob(22,44,11,10,2,R.orange)
  sblob(18,48,7,5,2,R.cream)
  px(12,47,"#2b1c26"); px(13,47,"#2b1c26"); px(12,48,"#2b1c26")
  sblob(34,55,17,5,2,{"#ffd090","#ffb860","#f08a3a","#b8603a","#6a3a55"})
  sblob(51,54,5,5,2,R.cream)
  for _,p in ipairs{{16,43},{17,44},{18,44},{19,43}} do px(p[1],p[2],"#2b1c26") end
  for _,p in ipairs{{25,42},{26,43},{27,43},{28,42}} do px(p[1],p[2],"#2b1c26") end
  rect(15,46,16,46,"#f5a0b8"); rect(27,47,28,47,"#f5a0b8")
  -- cap
  poly({{13,36},{14,31},{31,30},{31,36}},R.cream)
  poly({{18,31},{32,29},{47,39},{45,45},{30,36}},R.blue)
  for _,p in ipairs{{26,32},{33,34},{39,38}} do px(p[1],p[2],"#fff6e0") end
  sblob(46,46,3,3,2,R.cream)
  poly({{12,35},{12,26},{19,32}},R.orange); px(14,31,"#f5a0b8"); px(14,32,"#f5a0b8")
  poly({{27,32},{30,26},{34,32}},R.orange)
  for _,p in ipairs{{8,36},{9,36},{10,36},{10,35},{9,34},{8,33},{9,33},{10,33}} do px(p[1],p[2]+0,"#d8c8f0") end
  rect(6,57,9,58,"#e8523f"); px(7,56,"#ffc870"); px(8,57,"#ffe98a")
end)
----------------------------------------------------------- marigold
pal("pl-flfm-6",{32,60,20,1},{{6,40},{57,8},{58,34}},function()
  -- ladle behind
  line(49,50,59,59,"#8f5a38",2); poly({{54,55},{60,57},{57,62},{52,60}},R.wood)
  -- petals: deep orange with dark seams
  for a=0,11 do local t=a*math.pi/6
    sblob(32+math.cos(t)*14,32+math.sin(t)*13,6,6,2,(a%2==0) and R.orange or {"#ffd966","#ffb040","#e8802a","#b8503a","#6a3a55"}) end
  sblob(32,32,11,10,2,R.orange)
  -- pale face disc
  sblob(32,32,9,8,2,{"#fffbe0","#fff0a0","#ffe070","#e8b040","#b8803a"})
  eye(26,30,4,4); eye(34,30,4,4)
  px(31,36,"#2b1c26"); px(32,37,"#2b1c26"); px(33,37,"#2b1c26"); px(34,36,"#2b1c26")
  rect(24,35,26,35,"#ff9ab8"); rect(38,35,40,35,"#ff9ab8")
  -- pink hat
  sblob(32,20,13,3,2,R.pink)
  poly({{23,19},{29,3},{34,2},{37,6},{41,19}},R.pink)
  rect(24,17,40,18,"#ffd966"); px(33,3,"#ffc8dc")
  -- blue bowl
  CL=function(x,y) return y>=50 end
  sblob(32,55,21,9,2,R.blue,function(i,x,y) if y%4==0 and i<=4 then return R.blue[i+1] end end)
  CL=nil
  rect(11,50,53,50,"#fffaf0")
  for i=0,8 do local x=14+i*4.5 local y=51+math.sin(i/8*math.pi)*3
    sblob(x,y,2.5,2.5,2,(i%3==0) and R.pink or ((i%3==1) and R.red or R.yellow)) end
end)
