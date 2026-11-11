local out = app.params.out or "./"
local INK = "#2b1c26"
local floor, ceil, abs, sqrt, sin, cos = math.floor, math.ceil, math.abs, math.sqrt, math.sin, math.cos
local function hexc(h) h=h:gsub("#","") return Color{r=tonumber(h:sub(1,2),16),g=tonumber(h:sub(3,4),16),b=tonumber(h:sub(5,6),16)} end
local img
local function px(x,y,c) x=floor(x) y=floor(y) if x>=0 and y>=0 and x<64 and y<64 then img:putPixel(x,y,hexc(c)) end end
local function filled(x,y) return x>=0 and y>=0 and x<64 and y<64 and (img:getPixel(x,y)&0xff000000)~=0 end
local function H(x,y) return (sin(x*12.9898+y*78.233)*43758.5453)%1 end
local function rect(x0,y0,x1,y1,c) for y=y0,y1 do for x=x0,x1 do px(x,y,c) end end end
local function h2(h) h=h:gsub("#","") return {tonumber(h:sub(1,2),16),tonumber(h:sub(3,4),16),tonumber(h:sub(5,6),16)} end
local function mix(a,b,t) a=h2(a) b=h2(b) return string.format("#%02x%02x%02x",floor(a[1]+(b[1]-a[1])*t+.5),floor(a[2]+(b[2]-a[2])*t+.5),floor(a[3]+(b[3]-a[3])*t+.5)) end
local RC={}
local function RMP(base) -- 5 tones: hl, lit, mid, shade(cool violet), deep
  if RC[base] then return RC[base] end
  local r={mix(base,"#fff1c8",.58),mix(base,"#fff1c8",.26),base,mix(base,"#4a3a8a",.34),mix(base,"#2f2a5e",.6)}
  RC[base]=r return r
end
-- masks
local function mset(m,x,y) if x>=0 and y>=0 and x<64 and y<64 then m[y*64+x]=true end end
local function mhas(m,x,y) return x>=0 and y>=0 and x<64 and y<64 and m[y*64+x]==true end
local function each(m,fn) for k,_ in pairs(m) do fn(k%64,floor(k/64)) end end
local function E(cx,cy,rx,ry,pw) pw=pw or 2 local m={}
  for y=floor(cy-ry)-1,ceil(cy+ry)+1 do for x=floor(cx-rx)-1,ceil(cx+rx)+1 do
    local dx,dy=(x-cx+.5)/rx,(y-cy+.5)/ry
    if (abs(dx)^pw+abs(dy)^pw)^(1/pw)<=1 then mset(m,x,y) end end end return m end
local function R(x0,y0,x1,y1) local m={} for y=y0,y1 do for x=x0,x1 do mset(m,x,y) end end return m end
local function P(pts) local m={} local x0,y0,x1,y1=99,99,-99,-99
  for _,p in ipairs(pts) do x0=math.min(x0,p[1]) x1=math.max(x1,p[1]) y0=math.min(y0,p[2]) y1=math.max(y1,p[2]) end
  for y=floor(y0),ceil(y1) do for x=floor(x0),ceil(x1) do
    local X,Y=x+.5,y+.5 local ins=false local n=#pts local j=n
    for i=1,n do local a,b=pts[i],pts[j]
      if (a[2]>Y)~=(b[2]>Y) and X<(b[1]-a[1])*(Y-a[2])/(b[2]-a[2])+a[1] then ins=not ins end j=i end
    if ins then mset(m,x,y) end end end return m end
local function U(...) local m={} for _,a in ipairs{...} do for k,_ in pairs(a) do m[k]=true end end return m end
local function D(a,b) local m={} for k,_ in pairs(a) do if not b[k] then m[k]=true end end return m end
local function I(a,b) local m={} for k,_ in pairs(a) do if b[k] then m[k]=true end end return m end
local function T(pts) -- tube through {x,y,r}
  local m={}
  for i=1,#pts-1 do local a,b=pts[i],pts[i+1]
    local L=math.max(1,sqrt((b[1]-a[1])^2+(b[2]-a[2])^2)) local n=ceil(L*2)
    for s=0,n do local t=s/n local cx,cy,r=a[1]+(b[1]-a[1])*t,a[2]+(b[2]-a[2])*t,a[3]+(b[3]-a[3])*t
      for y=floor(cy-r)-1,ceil(cy+r)+1 do for x=floor(cx-r)-1,ceil(cx+r)+1 do
        if (x+.5-cx)^2+(y+.5-cy)^2<=r*r then mset(m,x,y) end end end end end
  return m end
local function EGG(cx,cy,rx,ry,k) local m={}
  for y=floor(cy-ry),ceil(cy+ry) do local v=(y+.5-cy)/ry
    if abs(v)<=1 then local w=rx*sqrt(1-v*v)*(1+k*v)
      for x=floor(cx-w),ceil(cx+w) do if abs(x+.5-cx)<=w then mset(m,x,y) end end end end return m end
-- shaded part: ramp r (5 tones), lit upper-left, rim shade lower-right
local function part(m,r,o) o=o or {}
  local x0,y0,x1,y1=99,99,-1,-1
  each(m,function(x,y) if x<x0 then x0=x end if x>x1 then x1=x end if y<y0 then y0=y end if y>y1 then y1=y end end)
  local cx,cy=(x0+x1+1)/2,(y0+y1+1)/2 local rx,ry=(x1-x0+1)/2,(y1-y0+1)/2
  each(m,function(x,y)
    local dx,dy=(x+.5-cx)/rx,(y+.5-cy)/ry
    local l=-0.5*dx-0.7*dy
    if not mhas(m,x+1,y) or not mhas(m,x,y+1) then l=l-0.6 elseif not mhas(m,x+2,y+1) or not mhas(m,x+1,y+2) then l=l-0.22 end
    if not mhas(m,x-1,y) or not mhas(m,x,y-1) then l=l+0.18 end
    local i= l>0.55 and 1 or (l>0.15 and 2 or (l>-0.28 and 3 or (l>-0.7 and 4 or 5)))
    local c=o.tex and o.tex(i,x,y) or nil
    px(x,y,c or r[i]) end)
end
local function flat(m,c) each(m,function(x,y) px(x,y,c) end) end
local function line1(x0,y0,x1,y1,c) x0,y0,x1,y1=floor(x0),floor(y0),floor(x1),floor(y1)
  local dx,dy=abs(x1-x0),abs(y1-y0) local sx,sy=x0<x1 and 1 or -1,y0<y1 and 1 or -1 local e=dx-dy
  while true do px(x0,y0,c) if x0==x1 and y0==y1 then break end local e2=2*e
    if e2>-dy then e=e-dy x0=x0+sx end if e2<dx then e=e+dx y0=y0+sy end end end
local function eye(x,y,w) w=w or 4
  rect(x,y,x+w-1,y+4,INK) px(x+1,y+1,"#fff6e0") px(x+2,y+1,"#fff6e0") px(x+1,y+2,"#fff6e0") px(x+2,y+2,"#fff6e0")
  px(x+w-2,y+3,"#d8c8f0") px(x+1,y+4,"#6a4a7a") end
local function eyeC(x,y,w,up) w=w or 4 for i=0,w-1 do local edge=(i==0 or i==w-1) if up then px(x+i,edge and y+1 or y,INK) else px(x+i,edge and y or y+1,INK) end end end
local function smile(x,y,w) px(x,y,INK) px(x+w-1,y,INK) for i=1,w-2 do px(x+i,y+1,INK) end end
local function blush(x,y) px(x,y,"#ff9aa8") px(x+1,y,"#ff9aa8") px(x,y+1,"#e8708a") end
local function note(x,y,c) c=c or "#ffe98a" px(x,y+4,c) px(x+1,y+4,c) px(x,y+5,c) px(x+1,y+5,c) for i=0,4 do px(x+2,y+i,c) end px(x+3,y,c) px(x+3,y+1,c) end
local function ring(cx,cy,r0,r1,fn) for y=floor(cy-r1)-1,ceil(cy+r1)+1 do for x=floor(cx-r1)-1,ceil(cx+r1)+1 do
  local d=sqrt((x+.5-cx)^2+(y+.5-cy)^2) if d>=r0 and d<=r1 then px(x,y,fn(x+.5-cx,y+.5-cy)) end end end end
local function outline()
  local o={}
  for y=0,63 do for x=0,63 do if not filled(x,y) then
    for _,d in ipairs{{1,0},{-1,0},{0,1},{0,-1}} do if filled(x+d[1],y+d[2]) then o[#o+1]={x,y} break end end end end end
  for _,p in ipairs(o) do px(p[1],p[2],INK) end end
local function shadow(cx,cy,rx,ry)
  for y=cy-ry,cy+ry do for x=cx-rx,cx+rx do local dx,dy=(x-cx)/rx,(y-cy)/ry local d=dx*dx+dy*dy
    if d<=1 and x>=0 and x<64 and y>=0 and y<64 and not filled(x,y) then px(x,y,d<0.45 and "#4a3a68" or "#6e5e8e") end end end end
local function spark(x,y) for _,d in ipairs{{0,0},{1,0},{-1,0},{0,1},{0,-1}} do if not filled(x+d[1],y+d[2]) then px(x+d[1],y+d[2],"#ffe98a") end end
  if not filled(x,y) then px(x,y,"#fffbe8") end
  for _,d in ipairs{{2,0},{-2,0},{0,2},{0,-2}} do if false then end end end
local function new() img=Image(64,64) end
local function save(name,sh,sp)
  outline() if sh then shadow(sh[1],sh[2],sh[3],sh[4]) end
  for _,s in ipairs(sp or {}) do spark(s[1],s[2]) end
  local s=Sprite(64,64) s.cels[1].image:drawImage(img) s:saveCopyAs(out..name..".png") s:close()
end

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
