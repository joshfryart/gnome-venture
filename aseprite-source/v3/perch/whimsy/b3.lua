----------------------------------------------------------- chili
pal("pl-chil-6",{32,60,17,1},{{7,18},{57,10},{58,38}},function()
  sblob(26,57,4,2,2,R.brown); sblob(38,57,4,2,2,R.brown)
  blobf(function(x,y)
    if y<=38 then return ((x-32)/14)^2+((y-38)/16)^2<=1 end
    local t=(y-38)/17 if t>1 then return false end
    local w=14*(1-t*t*0.8); local cx=32+t*2
    return math.abs(x-cx)<=w end,32,40,14,17,R.red,function(i,x,y) if i==1 and H(x,y)<0.25 then return R.red[2] end end)
  px(23,34,"#ffc8b8"); px(24,33,"#ffc8b8"); px(22,36,"#ff9a80"); px(23,37,"#ff9a80")
  sblob(32,24,8,4,2,R.green); line(30,22,36,17,"#3a8a52",2); px(37,16,"#5fae4a")
  poly({{26,21},{26,11},{29,15},{32,9},{35,15},{38,11},{38,21}},R.yellow)
  rect(26,19,38,20,"#e8b040"); px(32,10,"#fffbe8"); px(26,12,"#ffe98a"); px(32,16,"#e8523f"); px(28,18,"#4a8ad0"); px(36,18,"#4a8ad0")
  eye(24,35,4,5); eye(35,35,4,5)
  px(30,42,"#2b1c26"); px(31,43,"#2b1c26"); px(32,43,"#2b1c26"); px(33,42,"#2b1c26")
  rect(21,41,23,41,"#ff9ab8"); rect(40,41,42,41,"#ff9ab8")
  for _,p in ipairs{{50,40},{51,39},{51,38},{52,37},{50,36},{49,35},{49,37},{50,38}} do px(p[1],p[2],"#ffa040") end
  px(50,38,"#ffe98a"); px(50,39,"#ffe98a"); px(51,38,"#e8523f")
end)
----------------------------------------------------------- hedgehog
pal("pl-thch-6",{32,60,21,1},{{7,20},{57,12},{58,46}},function()
  sblob(22,58,4,2,2,R.brown); sblob(38,58,4,2,2,R.brown); sblob(48,56,3,2,2,R.brown)
  sblob(34,44,21,14,2,R.brown,function(i,x,y) if H(x,y)<0.35 and i>=2 and i<=4 then return R.brown[i+1] end if (x+y)%3==0 and i<=3 then return R.brown[i-1<1 and 1 or i-1] end end)
  local keys={} for k,_ in pairs(M) do keys[#keys+1]=k end
  for _,k in ipairs(keys) do local y,x=k:match("(%-?%d+),(%-?%d+)") y=tonumber(y) x=tonumber(x)
    if not M[(y-1)..","..x] and H(x,y)<0.55 then px(x,y-1,R.brown[3]); if H(y,x)<0.4 then px(x,y-2,R.brown[2]) end end end
  local sk={"#ffe0b8","#f0c890","#d8a470","#a87a5a","#6a4a5a"}
  sblob(18,49,10,9,2,sk)
  sblob(12,41,3,3,2,sk); sblob(24,41,3,3,2,sk)
  px(12,41,"#f5a0b8"); px(24,41,"#f5a0b8")
  sblob(10,52,3,2,2,{"#6a4a5a","#4a3a52","#3a2a46","#2b1c26","#2b1c26"}); px(9,51,"#fff6e0")
  eye(13,44,4,5); eye(21,44,4,5)
  px(15,55,"#2b1c26"); px(16,56,"#2b1c26"); px(17,56,"#2b1c26"); px(18,55,"#2b1c26")
  rect(11,50,12,50,"#2b1c26")
  rect(10,53,11,53,"#ff9ab8"); rect(22,53,24,53,"#ff9ab8")
  -- tray + teacup
  rect(31,28,47,29,"#9aa4be"); rect(31,28,47,28,"#e4e8f0"); rect(31,29,47,29,"#707a9c")
  poly({{33,21},{42,21},{41,28},{34,28}},R.cream)
  rect(34,21,41,22,"#b8602a"); rect(34,23,41,23,"#ff9ab8")
  px(43,22,"#dcccc4"); px(44,23,"#dcccc4"); px(44,24,"#b4a4c0"); px(43,25,"#b4a4c0")
  sblob(45,25,3,3,2,R.pink); px(45,22,"#e8523f"); px(44,24,"#fffaf0")
  px(36,19,"#fffaf0"); px(37,18,"#fffaf0"); px(38,17,"#dcccc4")
end)
----------------------------------------------------------- host
pal("pl-wcof-6",{32,61,24,1},{{7,12},{57,10},{58,36}},function()
  local robe={"#ffb888","#f08a58","#d0603f","#963a46","#4a2f55"}
  local cocoa={"#e8b080","#c98a5a","#a8683f","#7a4a38","#4a2f45"}
  -- tray
  sblob(32,58,27,3,2,R.cream); rect(7,59,57,59,"#e8523f")
  -- robe body
  sblob(20,46,11,12,2,robe,function(i,x,y) if y==53 then return "#ffd966" end end)
  sblob(14,57,4,2,2,R.brown); sblob(27,57,4,2,2,R.brown)
  -- head
  sblob(20,25,10,10,2,cocoa)
  sblob(20,16,9,5,2,{"#6a6088","#4a4268","#3a3256","#2e2648","#261c3c"})
  rect(10,19,30,21,"#fff0d0")
  for x=10,30,3 do rect(x,19,x+1,21,"#e8523f") end
  eye(14,25,4,4); eye(23,25,4,4)
  px(18,31,"#2b1c26"); px(19,32,"#2b1c26"); px(20,32,"#2b1c26"); px(21,31,"#2b1c26")
  rect(11,29,13,29,"#ff9ab8"); rect(27,29,29,29,"#ff9ab8")
  -- arm to pour
  line(27,40,36,36,robe[3],3); px(27,40,robe[2])
  sblob(37,35,3,3,2,cocoa)
  -- teal teapot with bright rim
  sblob(46,32,7,6,2,R.teal)
  poly({{39,30},{34,35},{36,36},{40,34}},R.teal)
  rect(43,25,49,26,"#fff0a0"); px(46,24,"#ffd966")
  px(42,30,"#d8fff0"); px(43,30,"#d8fff0")
  line(52,28,55,32,"#fff0a0",1); line(55,32,52,36,"#fff0a0",1)
  -- cocoa stream + cups
  line(35,37,35,50,"#7a4a38",1)
  for _,cx in ipairs{35,43,51} do
    poly({{cx-3,50},{cx+3,50},{cx+2,56},{cx-2,56}},R.cream)
    rect(cx-3,50,cx+3,50,"#8a4f32")
  end
  px(36,52,"#fffaf0"); px(44,52,"#fffaf0")
  for _,p in ipairs{{46,19},{47,18},{46,17},{47,16}} do px(p[1],p[2],"#fffaf0") end
end)
----------------------------------------------------------- gorilla
pal("pl-wgor-6",{32,60,22,1},{{7,14},{58,10},{57,40}},function()
  local fur={"#a4a8c8","#7c84ae","#5c6496","#444a7c","#323660"}
  local sil={"#e0dcec","#c4bedc","#a49cc4","#7c76a4","#585480"}
  local face={"#e8c8a8","#d0a888","#a8806e","#7a5860","#52384e"}
  -- feet
  sblob(22,57,6,3,2,fur); sblob(42,57,6,3,2,fur)
  -- legs
  sblob(23,52,6,6,2,fur); sblob(41,52,6,6,2,fur)
  -- torso + hunched shoulders
  sblob(32,43,13,13,2,fur)
  sblob(32,32,24,9,2,fur)
  -- silver saddle across shoulders/back
  CL=function(x,y) return y<=31 end
  sblob(32,29,19,5,2,sil)
  CL=nil
  -- arms: thick, hanging, knuckles on ground
  sblob(11,43,6,13,2,fur); sblob(53,43,6,13,2,fur)
  for _,x in ipairs{16,48} do line(x,36,x+(x<32 and 1 or -1),52,"#323660",1) end
  sblob(9,56,6,3,2,fur); sblob(55,56,6,3,2,fur)
  for _,x in ipairs{5,8,11,52,55,58} do px(x,58,"#323660"); px(x,57,"#7c84ae") end
  -- light chest
  sblob(32,40,9,8,2,face)
  line(32,34,32,44,face[4],1); line(24,41,31,43,face[4],1); line(40,41,33,43,face[4],1)
  -- head: crest, brow, light muzzle
  sblob(32,16,7,6,2,fur); px(31,10,fur[1]); px(32,10,fur[1])
  sblob(32,22,9,8,2,fur)
  rect(24,20,40,21,"#323660")
  eye(26,21,3,3); eye(35,21,3,3)
  sblob(32,27,6,4,2,face)
  px(30,26,"#2b1c26"); px(34,26,"#2b1c26")
  rect(29,29,35,29,"#2b1c26"); px(28,28,"#2b1c26"); px(36,28,"#2b1c26")
  -- fruit
  sblob(57,50,3,3,2,R.orange); px(56,48,"#ffe0a0"); px(57,46,"#3a8a52"); px(58,46,"#5fae4a")
end)
----------------------------------------------------------- diver
pal("pl-wpea-6",{31,61,24,1},{{7,38},{57,6},{58,44}},function()
  sblob(32,59,27,3,2,R.blue,function(i,x,y) if i<=2 and H(x,y)<0.2 then return "#fffaf0" end end)
  sblob(32,56,23,3,2,R.wood,function(i,x,y) if x%7==0 then return R.wood[4] end end)
  local tl={"#8ae8d8","#4cc4b8","#2f9aa4","#2a7090","#2a4a7a"}
  sblob(18,43,4,8,2,tl)
  sblob(30,43,12,13,2,tl)
  rect(19,47,41,47,"#6b4030"); rect(19,47,41,47,"#6b4030"); rect(29,46,31,48,"#ffd966")
  sblob(41,50,4,4,2,R.brown); px(41,46,"#ffd966"); px(40,47,"#4a2f45")
  sblob(25,56,4,2,2,R.brown); sblob(35,56,4,2,2,R.brown)
  line(38,37,45,28,tl[3],4); line(39,36,44,29,tl[2],2)
  line(46,26,47,20,tl[3],4)
  sblob(47,18,3,3,2,R.skin)
  sblob(48,11,4,4,2,{"#fffaf0","#f6ecd8","#e8d4e4","#c8b4d8","#8a7aa8"}); px(46,9,"#fffbe8"); px(47,9,"#fffbe8"); px(46,10,"#fffbe8")
  sblob(30,21,10,8,2,tl)
  sblob(30,26,7,6,2,R.skin)
  poly({{22,30},{38,30},{35,40},{30,44},{25,40}},R.cream)
  rect(20,23,40,23,"#7a5a34")
  for _,cx in ipairs{25,35} do sblob(cx,24,4,4,2,R.yellow); sblob(cx,24,3,3,2,{"#e8faff","#a8e0f8","#7ac0ea","#4a8ad0","#3a5aa8"}); px(cx,25,"#2b1c26"); px(cx,24,"#2b1c26"); px(cx-1,23,"#fffbe8") end
  px(29,33,"#e8a0a0"); px(30,33,"#e8a0a0")
end)
