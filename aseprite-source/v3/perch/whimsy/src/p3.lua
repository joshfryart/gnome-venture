------------------------------------------------ pinkhat drummer
new()
part(E(26,58,4.5,2.5),RMP"#6b4430") part(E(38,58,4.5,2.5),RMP"#6b4430")
part(E(32,47,12,9),RMP"#3a8a9a")
part(T{{23,44,3},{17,41,2.8}},RMP"#3a8a9a") part(T{{41,44,3},{47,41,2.8}},RMP"#3a8a9a")
part(P{{19,44},{45,44},{42,57},{22,57}},RMP"#b8743a",{tex=function(i,x,y)
  if (y-44)%5==0 and i<5 then return RMP"#b8743a"[i+1] end
  local zz=(x+ (floor((y-44)/3)%2)*3)%6 if y>46 and y<55 and zz==0 then return "#fff1c8" end end})
part(E(32,44,13,3.5),RMP"#f4e4c8")
part(E(32,44,10,2.2),RMP"#e8d4a8")
part(E(15,40,3.5,3.5),RMP"#f0b890") part(E(49,40,3.5,3.5),RMP"#f0b890")
line1(13,38,7,28,"#c89850") line1(14,38,8,28,"#8a5a34") part(E(7,27,2,2),RMP"#f4e4c8")
line1(51,38,57,28,"#c89850") line1(50,38,56,28,"#8a5a34") part(E(57,27,2,2),RMP"#f4e4c8")
part(E(32,31,9,7),RMP"#f0b890")
part(P{{22,32},{42,32},{39,46},{32,50},{25,46}},RMP"#f4f0ec",{tex=function(i,x,y) if (x+y)%5==0 and i<5 and y>38 then return RMP"#f4f0ec"[i+1] end end})
part(E(32,33,2.8,2.5),RMP"#e8707a") eye(26,26,4) eye(35,26,4)
rect(30,37,33,38,"#7a2a3a") px(30,37,"#e8707a") 
part(E(32,26,15,3.5),RMP"#e84a9a")
part(P{{19,26},{33,3},{45,26}},RMP"#e84a9a",{tex=function(i,x,y) if y>20 and y<23 then return "#ffe98a" end end})
part(P{{33,3},{38,2},{36,8}},RMP"#e84a9a")
px(30,13,"#ffe98a") px(32,17,"#fff1c8") px(34,11,"#fff1c8")
note(50,10) note(4,14,"#fff1c8")
rect(2,31,3,31,"#fff1c8") rect(60,31,61,31,"#fff1c8")
save("pl-drft-6",{32,61,17,1},{{57,18},{9,54},{56,52}})

------------------------------------------------ tanoa buddy
new()
for _,x in ipairs{16,30,43} do part(R(x,50,x+5,58),RMP"#6e3e24") end
part(E(10,38,3.5,3.5),RMP"#6e3e24") part(E(54,38,3.5,3.5),RMP"#6e3e24")
part(E(32,42,22,12,2),RMP"#8a5230",{tex=function(i,x,y)
  if y>=47 and y<=49 then local p=(x+y)%6 if p==0 or p==1 then return "#f4e4c8" elseif p==3 then return "#2f2a5e" end end
  if (x*2+floor(2*sin(y*.5)))%7==0 and i<5 and y<46 then return RMP"#8a5230"[i+1] end end})
part(E(32,34,21,6),RMP"#a8683a")
part(E(32,34,18,4),RMP"#a8886a",{tex=function(i,x,y) if y==33 and x>26 and x<36 then return "#d8c4a0" end if (x+y)%9==0 and i>2 then return "#7a5a48" end end})
ring(32,34,13.5,14.5,function() return "#8a6a50" end)
eyeC(24,41,5) eyeC(36,41,5) smile(29,46,5) blush(21,45) blush(40,45)
line1(10,41,10,46,"#f4e4c8") part(E(10,49,2.5,2),RMP"#f4e4c8") px(10,49,"#c89850")
save("pl-kava-6",{32,61,22,1},{{8,16},{56,16},{32,8}})

------------------------------------------------ pink stripe egg
new()
part(P{{21,50},{43,50},{41,58},{23,58}},RMP"#f4e4c8")
part(E(32,50,12,3),RMP"#f4e4c8")
local egg=EGG(32,31,15,21,0.12)
part(egg,RMP"#f48fb1",{tex=function(i,x,y)
  local b=(floor((y+floor(1.6*sin(x*.45)))/4))%3
  if b==0 then return RMP"#ffe0ec"[i] elseif b==1 and i>1 and i<5 then return RMP"#e8508a"[i] end
  if b==2 and (x%4==0) and i<5 then return "#fff1c8" end end})
part(E(32,50,12,3),RMP"#f4e4c8") 
part(P{{32,12},{21,6},{21,17}},RMP"#e0453a") part(P{{32,12},{43,6},{43,17}},RMP"#e0453a")
part(P{{30,12},{26,19},{31,17}},RMP"#c0392b") part(P{{34,12},{38,19},{33,17}},RMP"#c0392b")
part(E(32,12,2.8,2.8),RMP"#e0453a") px(31,11,"#ff9a80")
eye(24,24,4) eye(36,24,4) 
rect(27,33,36,34,INK) rect(28,35,35,36,"#7a2a3a") rect(28,33,35,33,"#fff6e0") px(32,36,"#e8707a") px(33,36,"#e8707a")
blush(22,31) blush(39,31)
save("pl-eggs-6",{32,61,15,1},{{8,18},{56,22},{8,46}})

------------------------------------------------ branch meditator
new()
local br=T{{6,54,3},{20,52,3.5},{44,52,3.5},{58,54,3}}
part(br,RMP"#7a5238",{tex=function(i,x,y) if (x*2+y)%9==0 and i<5 then return RMP"#7a5238"[i+1] end end})
for _,p in ipairs{{6,52},{58,52}} do for k=-1,1 do part(P{{p[1],p[2]},{p[1]+k*6-1,p[2]-7},{p[1]+k*6+1,p[2]-7}},RMP"#4a9a5a") end end
local wd=RMP"#d49a60"
local function grain(i,x,y) if (x+floor(2*sin(y*.45)))%6==0 and i<5 then return wd[i+1] end end
part(E(32,48,15,5.5),wd,{tex=grain})
part(E(32,39,9,9.5),wd,{tex=grain})
part(T{{24,35,3},{20,43,2.8}},wd) part(T{{40,35,3},{44,43,2.8}},wd)
part(E(19,47,3.5,3),wd) part(E(45,47,3.5,3),wd)
part(E(32,25,9.5,9),wd,{tex=function(i,x,y) local d=sqrt((x+.5-32)^2+(y-10.5-14)^2) if abs(d-5)<.5 and y<20 then return wd[math.min(5,i+1)] end return grain(i,x,y) end})
eyeC(26,24,4,true) eyeC(34,24,4,true) smile(30,29,4) blush(24,28) blush(37,28)
line1(32,41,32,46,"#8a5a34") line1(28,44,36,44,"#8a5a34")
part(P{{32,16},{27,10},{31,14}},RMP"#6fb450") part(P{{32,16},{38,9},{33,14}},RMP"#6fb450") 
for _,p in ipairs{{8,36},{12,30},{50,34},{54,28}} do px(p[1],p[2],"#e8f0f8") px(p[1]+1,p[2],"#cfd8f0") px(p[1]+2,p[2]+1,"#e8f0f8") end
note(48,10)
save("pl-wced-6",{32,61,20,1},{{8,14},{8,44},{58,44}})

------------------------------------------------ swinging glowtail
new()
line1(32,0,30,12,"#e8f0f8") line1(33,0,31,12,"#9a96c0")
local segs={{33,50,8,"#a8cfd0"},{32,40,10.5,"#bfe0d0"},{31,30,11,"#a8cfd0"},{30,19,9.5,"#bfe0d0"}}
part(E(34,53,9,8),RMP"#c8e04a",{tex=function(i,x,y) local d=sqrt((x+.5-34)^2+(y+.5-53)^2)/8.5
  if d<.4 then return "#fffbd0" elseif d<.72 then return "#f8f48a" elseif i==5 then return "#6a9a52" end end})
for k=1,#segs do local s=segs[k] local rr=s[3]
  part(E(s[1],s[2],rr,rr*.95),RMP(s[4])) end
part(E(30,19,9.5,9),RMP"#bfe0d0")
for _,p in ipairs{{21,36},{42,35},{20,27},{41,26}} do part(E(p[1],p[2],2,2),RMP"#a8cfd0") end
eye(24,17,4) eye(32,17,4) smile(28,24,4) blush(22,23) blush(35,23)
for y=1,10 do px(31,y,y%2==0 and "#e8f0f8" or "#9a96c0") end px(32,0,"#e8f0f8")
for _,y in ipairs{43,53,47} do end
for _,p in ipairs{{6,44},{5,50},{7,56},{58,44},{59,50},{57,56}} do px(p[1],p[2],"#fff1c8") end
note(47,20)
save("pl-wgwo-6",{34,61,12,2},{{10,12},{55,10},{55,34}})
