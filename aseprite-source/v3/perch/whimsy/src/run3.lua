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
