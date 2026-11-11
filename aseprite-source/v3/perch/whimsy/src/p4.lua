------------------------------------------------ slowpage tortoise
new()
part(E(17,55,5,4),RMP"#c8b070") part(E(47,55,5,4),RMP"#c8b070")
part(E(33,34,21,16,2.2),RMP"#6fa04a",{tex=function(i,x,y)
  local r=floor((y-14)/7) local off=(r%2)*5 local ln=((y-14)%7==0) or ((x+off)%10==0)
  if ln then return RMP"#6fa04a"[math.min(5,i+1)] end
  if i<=2 and ((x+off)%10==3 or ((y-14)%7==3 and (x%10)<6 and false)) then return "#a8d078" end end})
part(E(32,19,3,2),RMP"#6fa04a")
-- scroll on shell
part(R(20,13,44,20),RMP"#f4e4c8",{tex=function(i,x,y) if y==16 and x%4<2 and x>24 and x<40 and i<4 then return "#c8a070" end end})
part(E(20,16,3,4.2),RMP"#e8d4a8") part(E(44,16,3,4.2),RMP"#e8d4a8")
px(20,16,"#8a6a50") px(44,16,"#8a6a50") rect(31,12,33,21,"#e0453a") px(31,12,"#ff7a5a")
part(E(32,50,11.5,8.5),RMP"#c8b070")
ring(24.5,48,3.4,4.6,function(dx,dy) return (dx+dy<=-2.5) and "#ffe08a" or ((dx+dy>=2.5) and "#a86a1c" or "#d99a32") end)
ring(39.5,48,3.4,4.6,function(dx,dy) return (dx+dy<=-2.5) and "#ffe08a" or ((dx+dy>=2.5) and "#a86a1c" or "#d99a32") end)
rect(28,47,35,47,"#d99a32")
eye(23,46,3) eye(38,46,3) px(24,47,"#fff6e0") px(39,47,"#fff6e0")
smile(30,53,4) 
px(14,58,INK) px(18,58,INK) px(46,58,INK) px(50,58,INK)
save("pl-wmud-6",{32,61,22,1},{{7,26},{57,28},{9,8}})

------------------------------------------------ grinning stone face
new()
local rt=RMP"#8a5a3a"
local function rg(i,x,y) if (x+y*2)%7==0 and i<5 then return rt[i+1] end end
part(T{{5,57,3},{6,47,3.4},{10,37,3},{15,30,2.4}},rt,{tex=rg}) part(T{{59,57,3},{58,47,3.4},{54,37,3},{49,30,2.4}},rt,{tex=rg})
part(T{{13,58,2.8},{23,55,3}},rt,{tex=rg}) part(T{{51,58,2.8},{41,55,3}},rt,{tex=rg})
local st=E(32,31,17,18,2.5)
part(st,RMP"#9aa0b0",{tex=function(i,x,y) if H(x,y)<.06 and i<5 then return RMP"#9aa0b0"[i+1] end end})
local moss=I(st,U(E(24,16,8,5),E(40,15,5,3.5),R(14,17,18,19)))
part(moss,RMP"#6fb450",{tex=function(i,x,y) if H(x,y)<.2 then return RMP"#6fb450"[math.min(5,i+1)] end end})
eye(22,24,5) eye(37,24,5)
rect(21,22,26,22,"#6a6a80") rect(37,22,42,22,"#6a6a80")
rect(30,27,33,36,RMP"#9aa0b0"[2]) rect(33,27,33,36,RMP"#9aa0b0"[4]) px(30,27,RMP"#9aa0b0"[1])
for _,p in ipairs{{23,39},{24,41},{26,43},{29,44},{30,44},{33,44},{34,44},{37,43},{39,41},{40,39}} do px(p[1],p[2],INK) end
for _,p in ipairs{{26,44},{29,45},{30,45},{33,45},{34,45},{37,44}} do px(p[1],p[2],"#c8ccd8") end
blush(20,38) blush(42,38)
line1(35,13,35,8,"#3a8a52") part(E(35,6,2.2,2.2),RMP"#ffd0e0") for _,d in ipairs{{-3,0},{3,0},{0,-3},{0,3}} do end
px(35,6,"#ffe08a")
save("pl-wroo-6",{32,61,22,1},{{8,12},{57,14},{58,40}})

------------------------------------------------ beaming headpicker
new()
part(E(27,59,4.5,2.2),RMP"#6b4430") part(E(37,59,4.5,2.2),RMP"#6b4430")
part(E(32,52,11,7.5),RMP"#3a8a9a")
rect(24,51,40,52,"#2a6a7a")
part(T{{42,50,3},{48,44,2.8}},RMP"#3a8a9a") part(T{{22,50,3},{16,52,2.8}},RMP"#3a8a9a")
part(E(16,52,3.4,3.4),RMP"#e0a070")
-- tea sprig
line1(49,42,50,32,"#3a8a52") 
part(P{{50,34},{56,30},{54,37}},RMP"#8fd05a") part(P{{50,36},{43,32},{46,38}},RMP"#6fb450") part(P{{50,32},{50,26},{53,32}},RMP"#b4e873")
part(E(49,44,3.6,3.6),RMP"#e0a070")
part(E(32,38,10.5,8),RMP"#e0a070")
line1(23,34,22,41,"#c0392b") line1(41,34,42,41,"#c0392b")
eye(25,35,4) eye(36,35,4)
rect(28,42,36,43,INK) rect(29,42,35,42,"#fff6e0") px(32,43,"#e8707a") 
blush(22,40) blush(40,40)
part(E(32,31,22,4),RMP"#e8c060")
part(P{{12,31},{32,3},{52,31}},RMP"#e8c060",{tex=function(i,x,y)
  if ((x+y)%5==0) and i<5 then return RMP"#e8c060"[i+1] elseif ((x-y)%7==0) and i>1 and i<5 then return RMP"#e8c060"[math.min(5,i+1)] end end})
for x=14,50 do if mhas(E(32,31,22,4),x,31) and not mhas(P{{12,31},{32,3},{52,31}},x,31) then px(x,31,(x%2==0) and "#a86a1c" or "#c0392b") end end
rect(18,26,46,26,"#c0392b") 
save("pl-tegr-6",{32,61,17,1},{{7,14},{57,12},{58,36}})

------------------------------------------------ puddle dancer flamingo
new()
part(E(32,56,22,5),RMP"#bfe8f0",{tex=function(i,x,y) if y==54 and x%7<3 then return "#fffbf0" end end})
ring(32,57,10,12,function() return "#e8f6fc" end)
part(E(33,58,8,2),RMP"#f3a8c0")
part(T{{30,44,1.6},{31,55,1.4}},RMP"#f06aa0")
part(T{{33,43,1.6},{38,47,1.4},{35,51,1.4}},RMP"#f06aa0")
part(P{{21,34},{11,40},{21,43}},RMP"#c83a7a")
part(T{{37,31,3},{42,25,2.6},{39,17,2.6},{35,13,2.6}},RMP"#f06aa0")
part(E(30,37,11,9),RMP"#f06aa0")
part(E(27,39,7,6),RMP"#d84a8a",{tex=function(i,x,y) if (x+y)%4==0 and i<5 then return RMP"#d84a8a"[i+1] end if y>=43 then return "#6e2a4a" end end})
part(E(34,12,5.5,5),RMP"#f06aa0")
part(T{{37,13,1.8},{43,16,1.5}},RMP"#f8c0d0") px(43,17,INK) px(44,17,INK) px(44,16,INK) px(43,18,INK) px(42,18,INK)
eye(31,9,3) px(36,14,"#ff9aa8")
for _,p in ipairs{{12,22},{9,26},{54,36},{57,32}} do px(p[1],p[2],"#fff1c8") px(p[1]+1,p[2]+1,"#ffb0c8") px(p[1]+2,p[2]+1,"#fff1c8") end
save("pl-mirr-6",{32,61,22,1},{{8,10},{56,12},{55,48}})

------------------------------------------------ hollowtop menhir
new()
local st=E(32,35,15,23,2.8)
part(st,RMP"#a8a0b0",{tex=function(i,x,y) if H(x,y)<.05 and i<5 then return RMP"#a8a0b0"[i+1] end end})
local cap=I(st,U(R(0,0,63,19),E(22,22,4,3),E(40,21,5,3.5),E(32,21,3,4)))
part(cap,RMP"#6fb450",{tex=function(i,x,y) if H(x,y)<.2 then return RMP"#6fb450"[math.min(5,i+1)] end end})
part(E(32,15,8,3.2),RMP"#4a8a42") flat(E(32,15,6,2.2),"#2f2440") flat(E(32,14,6,1.2),"#3f3258") rect(26,16,36,16,"#241a38")
for _,p in ipairs{{29,13},{34,14}} do px(p[1],p[2],"#a898d0") end
eye(25,29,4) eye(36,29,4) smile(29,37,5) blush(22,35) blush(40,35)
part(E(21,50,4,3),RMP"#6fb450") part(E(43,53,4,2.5),RMP"#6fb450")
for _,b in ipairs{{12,58,9,50},{16,58,16,51},{20,58,23,52},{44,58,41,51},{48,58,50,52},{52,58,55,50}} do
  part(P{{b[1]-1,b[2]},{b[1]+1,b[2]},{b[3],b[4]}},RMP"#5aa04a") end
note(47,3) 
for _,p in ipairs{{43,9},{40,6}} do px(p[1],p[2],"#fff1c8") end
save("pl-stnd-6",{32,61,22,1},{{8,12},{9,40},{57,34}})
