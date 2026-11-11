local out = app.params.out or "./"
local INK = Color{r=0x2b,g=0x1c,b=0x26}
local function hex(h) h=h:gsub("#","") return Color{r=tonumber(h:sub(1,2),16),g=tonumber(h:sub(3,4),16),b=tonumber(h:sub(5,6),16)} end
local img
local floor,ceil,abs,sqrt=math.floor,math.ceil,math.abs,math.sqrt
local function px(x,y,c) if x>=0 and y>=0 and x<64 and y<64 then img:putPixel(x,y,type(c)=="string" and hex(c) or c) end end
local function rect(x0,y0,x1,y1,c) for y=y0,y1 do for x=x0,x1 do px(x,y,c) end end end
local function H(x,y) return (math.sin(x*12.9898+y*78.233)*43758.5453)%1 end
local R={
 brown={"#d9a46a","#b87a46","#8f5a38","#684030","#46324f"},
 tan={"#f0d0a0","#d8aa70","#b88450","#8a6040","#5a4458"},
 cream={"#fff3d6","#f6e0b4","#e0c090","#b8946e","#7a6488"},
 grey={"#e4e8f0","#c4c8d8","#9a9ebb","#727694","#4e4a72"},
 red={"#ff8a6a","#e8503f","#c03040","#8f2a46","#5a2a55"},
 orange={"#ffc47a","#ff9a45","#e0702f","#b04a3a","#6a3558"},
 yellow={"#fff29a","#ffd84a","#e8b02f","#b9802f","#7a5048"},
 green={"#c4ee82","#8fd05a","#5fae4a","#3a8a52","#2f4f6a"},
 olive={"#cfe07a","#a8c050","#7f9a3a","#58763a","#35505a"},
 teal={"#7fdcc8","#3fb0a8","#2a8a9a","#2a6482","#34426e"},
 blue={"#bfe4ff","#8ac4f0","#5a96d6","#406ab0","#383a78"},
 ice={"#f4fcff","#d0f0fa","#9fd8ee","#6aa8d8","#4a6ab0"},
 pink={"#ffd0e0","#ff9ec0","#f06a98","#c04a7e","#7a3a72"},
 purple={"#d8b0f0","#b080d8","#8a5cb8","#64428f","#42306e"},
 navy={"#7a8ab8","#566494","#3e4a78","#2e3860","#241f4a"},
 white={"#fffaf0","#f0ecf4","#d8d4e8","#b0acd0","#807ca8"},
 peach={"#ffe0c4","#ffc49a","#e89a70","#c0705a","#7a4a62"},
 dark={"#8a7aa8","#665a88","#4a4068","#3a3058","#2e2446"},
}
R.wood={"#e0b074","#bf8450","#946040","#6e4434","#4a3452"}
local M={}
-- masks return fn(x,y)->inside,dx,dy,d
local function E(cx,cy,rx,ry,pw) pw=pw or 2.4
  return {x0=floor(cx-rx)-1,x1=ceil(cx+rx)+1,y0=floor(cy-ry)-1,y1=ceil(cy+ry)+1,f=function(x,y)
    local dx,dy=(x-cx+0.5)/rx,(y-cy+0.5)/ry; local d=(abs(dx)^pw+abs(dy)^pw)^(1/pw); return d<=1,dx,dy,d end} end
local function B(x0,y0,x1,y1,rd) rd=rd or 1
  local cx,cy,rx,ry=(x0+x1+1)/2,(y0+y1+1)/2,(x1-x0+1)/2,(y1-y0+1)/2
  return {x0=x0,x1=x1,y0=y0,y1=y1,f=function(x,y)
    if x<x0 or x>x1 or y<y0 or y>y1 then return false,0,0,1 end
    local dx,dy=(x-cx+0.5)/rx,(y-cy+0.5)/ry
    local ex=math.min(x-x0,x1-x); local ey=math.min(y-y0,y1-y)
    if ex+ey<rd then return false,dx,dy,1 end
    return true,dx,dy,math.max(abs(dx),abs(dy))*0.9 end} end
local function P(pts)
  local x0,y0,x1,y1=99,99,-99,-99
  for _,p in ipairs(pts) do x0=math.min(x0,p[1]) x1=math.max(x1,p[1]) y0=math.min(y0,p[2]) y1=math.max(y1,p[2]) end
  local cx,cy,rx,ry=(x0+x1)/2,(y0+y1)/2,math.max(1,(x1-x0)/2),math.max(1,(y1-y0)/2)
  return {x0=floor(x0)-1,x1=ceil(x1)+1,y0=floor(y0)-1,y1=ceil(y1)+1,f=function(x,y)
    local X,Y=x+0.5,y+0.5; local ins=false; local n=#pts; local j=n
    for i=1,n do local a,b=pts[i],pts[j]
      if ((a[2]>Y)~=(b[2]>Y)) and (X<(b[1]-a[1])*(Y-a[2])/(b[2]-a[2])+a[1]) then ins=not ins end j=i end
    local dx,dy=(X-cx)/rx,(Y-cy)/ry
    return ins,dx,dy,math.min(1,sqrt(dx*dx+dy*dy)*0.8) end} end
-- fill mask with 5-tone ramp; tex(i,x,y)->colour|nil
local function F(m,r,tex)
  if type(r)=="string" then r=R[r] end
  local S={}
  for y=m.y0,m.y1 do for x=m.x0,m.x1 do local ok=m.f(x,y) if ok then S[y..","..x]=true end end end
  for y=m.y0,m.y1 do for x=m.x0,m.x1 do
    if S[y..","..x] then
      local _,dx,dy,d=m.f(x,y)
      local l=-0.55*dx-0.75*dy-0.5*d*d*d
      local i= l>0.55 and 1 or (l>0.12 and 2 or (l>-0.32 and 3 or (l>-0.72 and 4 or 5)))
      if not S[(y+1)..","..(x+1)] and i<4 then i=4 end
      if not S[(y+1)..","..x] and not S[y..","..(x+1)] and i<5 and H(x,y)>0.0 then i=math.max(i,5) end
      if not S[(y-1)..","..(x-1)] and i>2 then i=2 end
      local c=(tex and tex(i,x,y)) or r[i]
      px(x,y,c) end end end
  M=S
  return S
end
local function inS(S,x,y) return S[y..","..x] end
local function L(x0,y0,x1,y1,w,c) -- thick line
  local n=math.max(abs(x1-x0),abs(y1-y0)); if n==0 then n=1 end
  for i=0,n do local x=floor(x0+(x1-x0)*i/n+0.5); local y=floor(y0+(y1-y0)*i/n+0.5)
    for a=0,w-1 do for b=0,w-1 do px(x+a,y+b,c) end end end
end
local function LR(x0,y0,x1,y1,w,r) -- thick line shaded by ramp: lit upper-left edge, shade lower-right
  local rr=type(r)=="string" and R[r] or r
  L(x0,y0,x1,y1,w,rr[3]); L(x0,y0,x1,y1,1,rr[2]) 
  if w>=3 then L(x0+w-1,y0+w-1,x1+w-1,y1+w-1,1,rr[4]) end
end
local function outline()
  local o=Image(64,64)
  for y=0,63 do for x=0,63 do
    if img:getPixel(x,y)&0xff000000==0 then
      for _,d in ipairs{{1,0},{-1,0},{0,1},{0,-1}} do
        local a,b=x+d[1],y+d[2]
        if a>=0 and b>=0 and a<64 and b<64 and img:getPixel(a,b)&0xff000000~=0 then o:putPixel(x,y,INK) break end end end end end
  for y=0,63 do for x=0,63 do if o:getPixel(x,y)&0xff000000~=0 then img:putPixel(x,y,INK) end end end
end
local function shadow(cx,cy,rx,ry)
  for y=cy-ry,cy+ry do for x=cx-rx,cx+rx do
    local dx,dy=(x-cx)/rx,(y-cy)/ry; local d=dx*dx+dy*dy
    if d<=1 and x>=0 and x<64 and y<64 and img:getPixel(x,y)&0xff000000==0 then img:putPixel(x,y,hex(d<0.45 and "#4a3a68" or "#6e5e8e")) end end end
end
local function eye(x,y,w) w=w or 4
  rect(x,y,x+w-1,y+4,"#2b1c26"); rect(x+1,y+1,x+2,y+2,"#fff6e0"); px(x+w-2,y+3,"#d8c8f0"); px(x+1,y+4,"#6a4a7a")
end
local function reye(cx,cy,r,ring) -- round eye: pale ring, ink pupil, big highlight
  F(E(cx,cy,r,r,2),ring or "cream")
  rect(cx-1,cy-1,cx+1,cy+1,"#2b1c26"); px(cx-1,cy-1,"#fff6e0"); px(cx,cy-1,"#fff6e0")
end
local function happy(x,y,w) -- closed smiling eye arc
  for i=0,w-1 do local dy=(i==0 or i==w-1) and 1 or 0; px(x+i,y+dy,"#2b1c26") end
end
local function smile(x,y,w) px(x,y,"#2b1c26"); px(x+w-1,y,"#2b1c26"); for i=1,w-2 do px(x+i,y+1,"#2b1c26") end end
local function blush(x,y) px(x,y,"#ff9ec0"); px(x+1,y,"#ff9ec0") end
local function sparkle(x,y) for _,d in ipairs{{1,0},{-1,0},{0,1},{0,-1}} do px(x+d[1],y+d[2],"#ffe98a") end px(x,y,"#fffbe8") end
local function twinkle(x,y) px(x,y,"#fffbe8"); px(x+1,y,"#ffe98a"); px(x-1,y,"#ffe98a"); px(x,y+1,"#ffe98a"); px(x,y-1,"#ffe98a") end
local function save(name,sh,sp)
  outline() if sh then shadow(sh[1],sh[2],sh[3],sh[4]) end
  for _,p in ipairs(sp or {}) do sparkle(p[1],p[2]) end
  local s=Sprite(64,64); s.cels[1].image:drawImage(img)
  s:saveCopyAs(out..name..".png"); s:close()
end
local function new() img=Image(64,64) end
local function pal(name,fn) new() local ok,err=pcall(fn) if not ok then print("FAIL "..name..": "..tostring(err)) end end
