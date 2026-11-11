------------------------------------------------ snowpeak cub
new()
part(T{{43,54,3},{51,50,3},{53,42,3},{50,36,2.8}},RMP"#d9a05c")
part(E(50,36,2.8,2.5),RMP"#f4f6fb")
part(E(32,50,12,9),RMP"#d9a05c")
part(E(32,53,6,6),RMP"#f2e0bc")
part(E(25,58,4.5,2.5),RMP"#f2e0bc") part(E(39,58,4.5,2.5),RMP"#f2e0bc")
do local mane=E(32,30,14,12)
  for a=0,359,36 do local rr=15 mane=U(mane,E(32+cos(math.rad(a))*rr,30+sin(math.rad(a))*(rr-2),5,5)) end
  part(mane,RMP"#f4f6fb",{tex=function(i,x,y) if H(x,y)<.1 and i<5 then return RMP"#f4f6fb"[i+1] end if i==5 then return "#a8b8e0" end end})
end
part(E(21,19,4,4),RMP"#d9a05c") part(E(43,19,4,4),RMP"#d9a05c") part(E(21,20,2,2),RMP"#d08a98") part(E(43,20,2,2),RMP"#d08a98")
part(E(32,31,11,9.5),RMP"#d9a05c")
rect(30,21,30,23,"#a8703a") rect(33,21,33,23,"#a8703a") rect(32,22,32,24,"#a8703a")
eye(24,27,4) eye(37,27,4)
part(E(32,36,5.5,3.5),RMP"#f2e0bc") rect(31,34,32,35,"#d06a7a") px(31,34,"#ff9aa8") smile(30,37,4)
blush(22,34) blush(40,34)
for _,p in ipairs{{12,38},{51,22},{14,18}} do px(p[1],p[2],"#a8d8f0") px(p[1]-1,p[2],"#d8f0fc") px(p[1]+1,p[2],"#d8f0fc") px(p[1],p[2]-1,"#d8f0fc") px(p[1],p[2]+1,"#a8d8f0") end
save("pl-snw-6",{32,61,16,1},{{6,28},{56,12},{8,52}})

------------------------------------------------ firefly lamplighter
new()
for s=-1,1,2 do local cx=32+s*10
  part(P{{32+s*8,31},{32+s*20,38},{32+s*18,54},{32+s*9,48}},RMP"#d8eee8",{tex=function(i,x,y)
    if (x+y*s)%5==0 and i<5 then return "#9ac8c8" end end}) end
part(E(26,58,3,2),RMP"#5b4468") part(E(38,58,3,2),RMP"#5b4468")
part(E(32,44,13,13),RMP"#c8e04a",{tex=function(i,x,y) local d=sqrt((x+.5-32)^2+(y+.5-44)^2)/13
  if d<.38 then return "#fffbd0" elseif d<.66 then return "#f8f48a" elseif d<.86 and i<5 then return "#d4ea58" end
  if i==5 then return "#6a9a52" end end})
part(E(32,31,9,5),RMP"#6a4a74")
for y=30,31 do px(23,y,"#ffb347") end
part(T{{26,12,1.1},{23,6,1.1}},RMP"#6a4a74") part(T{{38,12,1.1},{41,6,1.1}},RMP"#6a4a74")
part(E(23,5,2.2,2.2),RMP"#f8f48a") part(E(41,5,2.2,2.2),RMP"#f8f48a")
part(E(32,21,12,10,2.3),RMP"#7a5a82")
eye(25,19,4) eye(35,19,4) smile(30,26,4) blush(23,25) blush(40,25)
px(31,12,"#ffe98a") px(32,12,"#ffe98a") px(32,11,"#fffbe8") px(31,13,"#ffe98a") px(32,13,"#ffe98a") px(30,13,"#ffe98a") px(33,13,"#ffe98a")
save("pl-ffy-6",{32,61,15,1},{{8,14},{57,14},{6,52}})

------------------------------------------------ rose canyon camel
new()
part(E(32,56,25,5),RMP"#e8c88a",{tex=function(i,x,y) if H(x,y)<.1 and i>2 then return "#b88a60" end end})
part(P{{10,44},{6,48},{12,50}},RMP"#b88a50")
part(E(40,53,5.5,3.5),RMP"#c89850") part(E(22,54,5.5,3.5),RMP"#c89850")
local body=E(29,44,18,10,2.3)
local hum=U(E(22,34,6,6),E(36,34,6,6))
part(U(body,hum),RMP"#c89850")
local bl=I(U(body,hum),P{{6,30},{44,26},{47,52},{6,52}})
local st={RMP"#e0607a",RMP"#f4e4c8",RMP"#3aa89a"}
part(bl,st[1],{tex=function(i,x,y) local b=(floor((y+ (x%6<3 and 0 or 0))/3))%3 return st[b+1][i] end})
for x=12,42,3 do px(x,50,"#f4e4c8") px(x,51,"#e0607a") end
part(T{{40,42,5},{44,34,4.5}},RMP"#c89850")
part(E(46,30,8,7),RMP"#c89850") part(E(52,34,4.5,3.8),RMP"#e6c890")
part(E(41,22,2,3),RMP"#c89850") part(E(51,22,2,3),RMP"#c89850")
eyeC(43,27,4) eyeC(49,27,3) px(53,33,INK) px(54,33,INK) smile(51,36,3) blush(42,31)
for _,p in ipairs{{54,13},{58,9}} do local x,y=p[1],p[2] rect(x,y,x+3,y,"#fff1c8") px(x+2,y+1,"#fff1c8") px(x+1,y+2,"#fff1c8") rect(x,y+3,x+3,y+3,"#fff1c8") end
save("pl-rrc-6",{32,61,24,1},{{7,18},{5,34},{57,46}})

------------------------------------------------ lookout turret
new()
local wl=R(5,46,20,58) local wr=R(44,46,59,58)
local function bricks(base) return function(i,x,y) local row=floor(y/4) local off=(row%2)*4
  if y%4==3 then return RMP(base)[math.min(5,i+1)] end if (x+off)%8==7 then return RMP(base)[math.min(5,i+1)] end end end
part(wl,RMP"#a8a0b4",{tex=bricks"#a8a0b4"}) part(wr,RMP"#a8a0b4",{tex=bricks"#a8a0b4"})
for _,x in ipairs{5,11,17} do part(R(x,43,x+2,45),RMP"#a8a0b4") end for _,x in ipairs{44,50,56} do part(R(x,43,x+2,45),RMP"#a8a0b4") end
part(R(20,20,43,58),RMP"#b4acc0",{tex=function(i,x,y) local c=bricks"#b4acc0"(i,x,y) if c then return c end if x>=36 and i>3 then return RMP"#b4acc0"[4] end end})
part(R(17,14,46,20),RMP"#b4acc0",{tex=bricks"#b4acc0"})
for _,x in ipairs{17,25,33,41} do part(R(x,8,x+5,13),RMP"#b4acc0",{tex=bricks"#b4acc0"}) end
line1(31,8,31,0+2,"#7a4e32") part(P{{32,2},{40,4},{32,7}},RMP"#e0453a")
eye(23,26,4) eye(37,26,4) smile(29,35,5) blush(22,32) blush(40,32)
part(P{{27,58},{27,50},{29,47},{35,47},{37,50},{37,58}},RMP"#8a5230")
px(35,53,"#ffe08a")
-- bird perched on left merlon
part(E(20,6,4,3.2),RMP"#4aa8e0") part(P{{16,6},{11,9},{17,8}},RMP"#2a6aa8") part(P{{24,6},{27,6},{24,8}},RMP"#ffb347")
px(21,5,INK) px(22,5,INK) px(21,4,"#fff6e0")
save("pl-lwp-6",{32,61,26,1},{{7,22},{57,22},{56,6}})
