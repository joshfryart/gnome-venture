local olive={"#c8e07a","#9cc860","#6ea24a","#487a48","#35507a"}
----------------------------------------------------------- cocopaddle
pal("ss-cocopaddle",{32,60,17,1},{{9,12},{56,7},{58,36}},function()
  sblob(32,56,25,4,2,R.blue,function(i,x,y) if i<=2 and H(x,y)<0.15 then return "#fffaf0" end end)
  -- paddle behind hull
  line(47,38,54,52,"#8f5a38",2); line(47,38,47,38,"#b87a45",1)
  poly({{51,50},{58,52},{56,58},{49,56}},R.wood)
  CL=function(x,y) return y>=41 end
  sblob(32,43,20,14,2,R.brown,function(i,x,y) if (x%5==0 and i>=2 and i<=4) then return R.brown[i+1] end if i==1 and H(x,y)<.3 then return R.brown[2] end end)
  CL=nil
  sblob(32,41,20,4,2,R.brown)
  sblob(32,41,17,3,2,R.cream)
  rect(15,41,17,41,"#fffaf0")
  box(31,8,32,41,R.wood)
  poly({{33,11},{33,36},{51,36}},R.cream)
  for k,_ in pairs(M) do local y,x=k:match("(%-?%d+),(%-?%d+)") y=tonumber(y) x=tonumber(x) if y%5==0 then px(x,y,(x>40) and "#c0689a" or "#f08aa8") end end
  poly({{31,5},{31,10},{41,7.5}},R.red)
  for _,p in ipairs{{39,26},{41,26},{38,27},{39,27},{40,27},{41,27},{42,27},{39,28},{40,28},{41,28},{40,29}} do px(p[1],p[2],"#e8523f") end
  px(39,26,"#ff9a80")
  eye(21,46,4,5); eye(37,46,4,5)
  rect(29,52,34,52,"#2b1c26"); px(28,51,"#2b1c26"); px(35,51,"#2b1c26"); rect(30,53,33,53,"#c0332f")
  px(19,51,"#f08aa8"); px(20,51,"#f08aa8"); px(42,51,"#f08aa8"); px(43,51,"#f08aa8")
end)
----------------------------------------------------------- mirage moon
pal("dw-mirage-moon",{32,60,19,1},{{8,10},{57,12},{59,40}},function()
  poly({{12,51},{52,51},{57,58},{7,58}},R.red,function(i,x,y)
    if y==54 then return (x%4<2) and "#ffd966" or "#b04880" end
    if y==56 and x%2==0 then return "#fff0a0" end end)
  for x=8,56,2 do px(x,59,"#ffd966") end
  blobf(function(x,y) return ((x-30)^2+(y-32)^2<=400) and ((x-43)^2+(y-28)^2>200) end,30,32,20,20,R.yellow,function(i,x,y)
    if (x==17 and y==40) or (x==20 and y==44) or (x==36 and y==49) then return R.yellow[4] end
    if (x==16 and y==40) or (x==19 and y==44) then return R.yellow[3] end end)
  eye(14,30,4,5)
  for _,p in ipairs{{21,33},{22,32},{23,31},{24,31},{25,32},{26,33}} do px(p[1],p[2],"#2b1c26") end
  rect(14,36,16,36,"#f5a0b8"); rect(24,36,26,36,"#f5a0b8")
  px(19,37,"#2b1c26"); px(20,38,"#2b1c26"); px(21,38,"#2b1c26"); px(22,37,"#2b1c26")
  px(47,45,"#e8b040"); px(46,46,"#b8803a")
end)
----------------------------------------------------------- bill brolly
pal("mt-bill-brolly",{31,60,13,1},{{7,48},{58,6},{57,32}},function()
  line(37,13,40,44,"#3a8a52",2); line(37,13,37,30,"#5fae4a",1)
  poly({{39,44},{55,48},{54,56},{38,52}},R.black)
  rect(46,50,54,51,"#fffaf0"); rect(46,53,53,54,"#fffaf0")
  rect(25,55,28,58,"#e87a2a"); rect(34,55,37,58,"#e87a2a"); rect(25,55,28,55,"#ffc870"); rect(34,55,37,55,"#ffc870")
  sblob(31,46,12,11,2,R.black)
  sblob(30,50,7,6,2,R.cream)
  sblob(26,31,10,9,2,R.black)
  -- beak
  poly({{20,22},{5,34},{9,39},{20,41}},R.yellow)
  line(9,38,21,40,"#b8803a",1)
  poly({{19,20},{9,27},{6,33},{15,29},{21,27}},R.orange)
  px(7,34,"#2b1c26")
  sblob(26,28,5,5,2,R.cream); eye(24,26,4,5)
  sblob(34,29,3,4,2,R.cream); eye(33,28,3,4)
  px(22,33,"#2b1c26")
  -- leaf umbrella
  CL=function(x,y) return y<=14 end
  sblob(38,14,20,10,2,R.green)
  CL=nil
  for _,i in ipairs{-14,-7,0,7,14} do line(38,14,38+i,6+math.abs(i)*0.2,"#3a8a52",1) end
  px(40,7,"#b4e873"); px(41,7,"#b4e873")
  -- frog
  sblob(49,54,6,5,2,R.green)
  sblob(46,48,2,2,2,R.green); sblob(52,48,2,2,2,R.green)
  px(46,48,"#2b1c26"); px(52,48,"#2b1c26"); px(45,47,"#fff6e0"); px(51,47,"#fff6e0")
  rect(47,55,51,55,"#2b1c26"); rect(48,56,50,56,"#c0332f")
end)
----------------------------------------------------------- mossback monitor
pal("pl-dlz-6",{32,60,19,1},{{8,14},{57,10},{58,52}},function()
  for _,b in ipairs{{47,50,6,5},{52,45,5,4},{55,40,4,4},{55,35,3,3},{53,31,2,2}} do sblob(b[1],b[2],b[3],b[4],2,olive) end
  sblob(17,51,4,4,2,olive); sblob(47,51,4,4,2,olive)
  sblob(32,46,17,10,3,olive,function(i,x,y) if i>=2 and i<=4 and x%4==0 and (y%3~=0) then return olive[i+1] end end)
  sblob(32,51,10,5,2,{"#fff0a0","#ffe08a","#e8c868","#b89a5a","#7a6a7a"})
  for x=26,38,3 do px(x,50,"#b89a5a"); px(x,53,"#b89a5a") end
  sblob(22,56,5,3,2,olive); sblob(42,56,5,3,2,olive)
  for _,x in ipairs{19,22,25,39,42,45} do px(x,58,"#35507a") end
  sblob(31,32,11,9,2,olive)
  -- moss tuft with flower
  sblob(39,39,4,2,2,{"#d8ff9a","#b4e873","#8fd05a","#5fae4a","#3a8a52"})
  px(40,37,"#ff9ab8"); px(41,37,"#ff9ab8"); px(40,36,"#fff6e0")
  eye(23,28,4,5); eye(31,28,4,5)
  px(27,34,"#35507a"); px(31,34,"#35507a")
  rect(25,38,33,38,"#2b1c26"); px(24,37,"#2b1c26"); px(34,37,"#2b1c26")
  rect(29,39,29,42,"#e8523f"); px(28,43,"#e8523f"); px(30,43,"#e8523f")
  px(22,35,"#f5a0b8"); px(23,35,"#f5a0b8")
end)
----------------------------------------------------------- lotus perch
pal("pl-jdf-6",{32,61,22,1},{{7,28},{58,22},{57,44}},function()
  sblob(32,55,26,6,2,R.green,function(i,x,y) if i<=3 and (x*3+y)%11==0 then return olive[i+1] end end)
  rect(30,50,34,60,"#35507a")
  local function petal(cx,by,w,h,tilt)
    poly({{cx-w,by},{cx-w*0.9+tilt*0.3,by-h*0.55},{cx+tilt,by-h},{cx+w*0.9+tilt*0.3,by-h*0.55},{cx+w,by}},R.pink)
    line(cx,by-3,cx+tilt*0.9,by-h+5,"#e8688f",1)
  end
  petal(21,52,9,28,-5); petal(43,52,9,28,5)
  petal(32,50,9,34,0)
  petal(25,55,10,24,-2); petal(40,55,10,24,2)
  -- face on front petals
  for _,p in ipairs{{23,44},{24,43},{25,43},{26,44}} do px(p[1],p[2],"#2b1c26") end
  for _,p in ipairs{{37,44},{38,43},{39,43},{40,44}} do px(p[1],p[2],"#2b1c26") end
  rect(21,46,23,46,"#ff9ab8"); rect(40,46,42,46,"#ff9ab8")
  px(30,47,"#2b1c26"); px(31,48,"#2b1c26"); px(32,48,"#2b1c26"); px(33,47,"#2b1c26")
  -- dragonfly nap
  rect(36,12,47,13,"#3aa8a8"); rect(36,12,47,12,"#5ccfc0"); px(47,13,"#2a7a90"); rect(40,12,40,13,"#2a7a90"); rect(44,12,44,13,"#2a7a90")
  poly({{26,12},{14,7},{15,13},{27,14}},{"#fffaf0","#eef9fc","#cfe6f2","#a8cce0","#7aa4d0"})
  poly({{30,11},{22,3},{29,5},{33,10}},{"#fffaf0","#eef9fc","#cfe6f2","#a8cce0","#7aa4d0"})
  line(15,10,26,13,"#6a8ab8",1)
  sblob(32,12,5,4,2,R.teal)
  px(29,12,"#2b1c26"); px(30,13,"#2b1c26"); px(31,13,"#2b1c26"); px(32,12,"#2b1c26")
  px(34,12,"#2b1c26"); px(35,13,"#2b1c26")
  for _,p in ipairs{{44,6},{45,6},{46,6},{45,7},{44,8},{45,8},{46,8}} do px(p[1],p[2],"#a8cce0") end
end)
