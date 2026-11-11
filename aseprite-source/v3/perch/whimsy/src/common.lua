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
