------------------------------------------------ samara spin
new()
part(E(22,57,3,2),RMP"#7a4e32") part(E(31,57,3,2),RMP"#7a4e32")
do -- wing
  local wing=P{{28,36},{35,22},{45,10},{55,6},{57,14},{52,28},{42,38}}
  local ax,ay,bx,by=30,34,55,9 local L=sqrt((bx-ax)^2+(by-ay)^2) local ux,uy=(bx-ax)/L,(by-ay)/L
  local r=RMP"#e8743a"
  part(wing,r,{tex=function(i,x,y) local vx,vy=x+.5-ax,y+.5-ay local t=vx*ux+vy*uy local d=vx*uy*-1+vy*ux
    if abs(d)<0.7 then return "#a8323f" end
    local k=(t-abs(d)*1.3)%5 if k<1 and abs(d)>1 then return (i<=2) and "#d8453a" or "#a8323f" end
    if i==1 then return "#ffc070" end end})
end
part(E(25,45,12,11,2.4),RMP"#dcae62",{tex=function(i,x,y)
  if i==5 and H(x,y)<.4 then return "#8a6a8a" end
  if x>=33 and x<=34 and y>36 and y<54 then return i<=3 and "#b8864a" or "#7a5a6e" end end})
eye(18,40,4) eye(27,40,4) smile(23,47,4) blush(17,45) blush(31,45)
px(22,52,"#b8864a") px(25,52,"#b8864a") px(23,53,"#b8864a")
for _,p in ipairs{{37,10},{39,7},{42,5},{45,4}} do px(p[1],p[2],"#fff1c8") end
px(47,16,"#ffe98a") px(49,13,"#ffe98a") px(50,26,"#fff1c8") px(48,30,"#ffe98a")
save("mw-samara-spin",{26,60,13,2},{{7,12},{6,30},{54,48}})

------------------------------------------------ harbour leap dolphin
new()
part(E(30,56,21,5),RMP"#5aa8d8",{tex=function(i,x,y) if y==52 and (x%5<3) then return "#e8f6fc" end if y==55 and (x%7<2) then return "#cfeaf8" end end})
local body=T{{20,52,3.5},{22,44,6},{27,34,8},{33,25,8.5},{39,17,7},{44,11,4}}
local beak=T{{44,11,3.2},{51,8,2}}
part(P{{19,52},{9,46},{7,53},{13,57},{19,56}},RMP"#4a78b0")
part(P{{23,34},{15,24},{24,24}},RMP"#4a78b0")
part(U(body,beak),RMP"#5f8fc4")
local belly=D(U(body,beak),(function() local m={} each(U(body,beak),function(x,y) mset(m,x-4,y-3) end) return m end)())
part(belly,RMP"#e6eef6")
part(P{{35,30},{43,34},{38,38},{33,35}},RMP"#4a78b0")
do local band=I(body,P{{25.4,21.4},{36.8,29.4},{34.6,32.6},{23.2,24.6}}) part(band,RMP"#e0453a")
  px(23,26,"#e0453a") px(22,27,"#a8323f") px(21,28,"#a8323f") px(20,29,"#6e2a4a") end
part(E(30,56,16,3),RMP"#5aa8d8",{tex=function(i,x,y) if y==54 and (x%6<3) then return "#e8f6fc" end end})
eye(37,13,4) blush(39,19) px(46,11,INK) px(47,10,INK)
for _,p in ipairs{{50,22},{54,17},{47,30},{11,38},{14,32}} do rect(p[1],p[2],p[1]+1,p[2]+1,"#cfeaf8") px(p[1],p[2],"#fff6e0") end
save("ow-harbour-leap",{31,61,22,2},{{56,36},{7,20},{54,50}})

------------------------------------------------ lofty kite
new()
part(E(31,57,12,3.5),RMP"#e8ecf8")
part(T{{32,44,1.5},{34,48,1.5},{29,51,1.5},{34,54,1.5},{30,57,1.5}},RMP"#35a8c8")
for _,p in ipairs{{35,48,"#ffb347"},{28,52,"#e8453c"},{34,55,"#ffb347"}} do
  part(P{{p[1],p[2]},{p[1]-4,p[2]-2},{p[1]-4,p[2]+3}},RMP(p[3])) part(P{{p[1],p[2]},{p[1]+4,p[2]-2},{p[1]+4,p[2]+3}},RMP(p[3])) end
do local kite=P{{32,3},{50,21},{32,45},{14,21}}
  local A,B=RMP"#e8453c",RMP"#ffb347"
  part(kite,A,{tex=function(i,x,y) local q=((x<32) == (y<21)) return (q and A or B)[i] end})
  line1(32,5,32,44,"#7a4e32") line1(15,21,49,21,"#7a4e32") px(31,22,"#fff1c8")
end
-- smug face: half-lidded eyes, raised brow, monocle
rect(22,20,25,22,INK) px(23,21,"#fff6e0") rect(21,19,26,19,INK) 
rect(38,20,41,22,INK) px(39,21,"#fff6e0") rect(37,19,42,19,INK)
px(38,16,INK) px(39,15,INK) px(40,15,INK) px(41,16,INK)
ring(39.5,21,3.6,5,function(dx,dy) return (dx+dy<0) and "#ffe08a" or "#a86a1c" end)
line1(44,24,48,31,"#d99a32")
smile(30,27,5) px(34,26,INK) blush(20,25) blush(43,26)
save("sp-lofty-kite",{31,61,12,1},{{8,8},{56,10},{55,40}})

------------------------------------------------ condor plume
new()
for _,p in ipairs{{12,30},{53,22},{50,42}} do part(E(p[1],p[2],2,2),RMP"#f2f0f0") end
local feather=T{{32,52,1.2},{31,45,6},{30,35,10.5},{31,25,11},{34,15,8},{38,6,2.2}}
part(feather,RMP"#5a4a68",{tex=function(i,x,y)
  local ed=not (mhas(feather,x-2,y) and mhas(feather,x+2,y) and mhas(feather,x,y-2))
  if y<17 or (ed and y<44 and i<5) then return (i<=2) and "#f0ecf2" or ((i==3) and "#d0cce0" or "#9a96c0") end
  if abs(x-(31+(35-y)*-0.12))<0.8 then return "#9a96b4" end
  local left=x< 31
  local k= left and (x-y)%4 or (x+y)%4
  if k==0 and i<5 then return RMP"#5a4a68"[i+1] end end})
part(E(32,54,13,5,2),RMP"#f2f0f0",{tex=function(i,x,y) if H(x,y)<.12 then return RMP"#f2f0f0"[math.min(5,i+1)] end end})
for x=20,44,3 do px(x,50,"#f2f0f0") end
eye(24,29,4) eye(34,29,4) smile(29,36,4) blush(22,35) blush(37,35)
for _,p in ipairs{{8,44},{9,46},{55,34},{54,36}} do px(p[1],p[2],"#bfe4f4") end
save("pl-cnd-6",{32,60,15,2},{{8,12},{56,12},{56,52}})

------------------------------------------------ grey wolf whistle
new()
part(T{{43,52,3},{51,49,3},{55,41,3},{54,37,2.6}},RMP"#8a93a8")
part(E(54,38,2.6,2.2),RMP"#eef2f6")
part(E(32,48,13,10),RMP"#8a93a8")
part(E(32,52,7,6),RMP"#e6dcd0")
part(E(26,58,4.5,2.5),RMP"#e6dcd0") part(E(38,58,4.5,2.5),RMP"#e6dcd0")
part(P{{18,24},{19,8},{29,16}},RMP"#8a93a8") part(P{{46,24},{45,8},{35,16}},RMP"#8a93a8")
part(P{{21,21},{21,12},{26,17}},RMP"#d08a98") part(P{{43,21},{43,12},{38,17}},RMP"#d08a98")
part(E(32,29,15,12,2.5),RMP"#8a93a8")
part(P{{17,31},{13,36},{20,36}},RMP"#8a93a8") part(P{{47,31},{51,36},{44,36}},RMP"#8a93a8")
part(E(32,35,8,6),RMP"#e6dcd0")
rect(30,31,33,32,"#3a2a3a") px(30,31,"#8a7aa0")
eye(21,25,4) eye(39,25,4) px(32,34,INK) smile(29,35,4) 
line1(25,38,32,45,"#d8453a") line1(39,38,32,45,"#d8453a")
part(R(29,45,36,48),RMP"#e8b84a") px(31,46,INK) px(32,46,INK) rect(36,46,37,47,"#a86a1c")
note(48,8) note(54,15,"#fff1c8")
save("pl-gwk-6",{32,61,17,1},{{6,16},{8,46},{57,28}})
