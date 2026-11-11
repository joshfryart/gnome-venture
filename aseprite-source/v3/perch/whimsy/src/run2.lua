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
