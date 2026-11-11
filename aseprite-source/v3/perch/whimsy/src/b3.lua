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
R.gold={"#fff29a","#ffd84a","#e8b02f","#b9802f","#7a5048"}
R.yakb={"#7a6068","#5a4452","#443244","#33263c","#241a30"}
R.yakf={"#d8c0b8","#b8a0a0","#98808c","#74606e","#4e4060"}
pal("pl-oliv-6",function()
  F(E(26,57,3,2,2),"green"); F(E(38,57,3,2,2),"green")
  F(E(47,40,3,4,2),"olive"); F(E(17,40,3,4,2),"olive")
  F(E(32,38,14,18,2.1),"olive")
  F(E(32,21,4,3,2),"red"); px(30,20,"#ff8a6a")
  L(32,17,34,14,1,R.olive[4]); F(E(38,13,4,2,2),"green"); F(E(28,14,3,2,2),"green")
  rect(22,26,23,31,"#e8f4a0"); px(22,25,"#fffbe8"); px(23,32,"#cfe07a")
  eye(25,33,4); eye(35,33,4); blush(23,39); blush(38,39); smile(29,40,5)
  -- golden oil drop
  F(P{{56,38},{53,45},{59,45}},"gold"); F(E(56,46,3,3,2),"gold"); px(55,45,"#fffbe8")
  save("pl-oliv-6",{32,60,14,2},{{8,16},{10,50},{55,22}})
end)
pal("pl-turt-6",function()
  F(E(14,48,5,3,2),"green"); F(E(50,48,5,3,2),"green")
  F(E(24,57,4,2,2),"green"); F(E(40,57,4,2,2),"green")
  F(E(32,33,15,13,2.2),"teal",function(i,x,y)
    local a=(x-32+.5)^2+(y-31+.5)^2; local b=(x-35+.5)^2+(y-30+.5)^2
    if a<=40 and b>30 then return R.yellow[math.min(5,i)] end
    if (x*2+y)%11==0 and i>=2 and i<5 then return R.teal[i+1] end end)
  px(21,25,"#fff29a"); px(43,38,"#fff29a"); px(24,42,"#fffbe8")
  F(E(32,49,8,7,2.1),"green")
  eye(27,45,3); eye(34,45,3); blush(25,51); blush(37,51); smile(30,52,4)
  F(P{{24,43},{25,38},{28,41},{30,37},{32,41},{35,37},{37,41},{39,38},{40,43}},"white")
  save("pl-turt-6",{32,60,15,2},{{8,18},{56,16},{8,54}})
end)
pal("pl-wfla-6",function()
  LR(33,32,26,24,4,"pink"); LR(26,24,30,16,4,"pink"); LR(30,16,35,12,4,"pink")
  F(E(33,38,12,10,2.2),"pink"); F(E(29,39,6,6,2),"pink",function(i,x,y) if (x+y)%4==0 and i>=2 and i<5 then return R.pink[i+1] end end)
  F(E(37,11,4,4,2),"pink")
  F(P{{40,9},{46,12},{40,14}},"cream"); px(45,12,"#2b1c26"); px(44,12,"#2b1c26")
  rect(37,9,38,11,"#2b1c26"); px(37,9,"#fff6e0")
  F(P{{33,6},{41,6},{42,8},{32,8}},"green")
  F(B(8,50,55,58,1),"wood",function(i,x,y) if x%9==0 and y>50 then return R.wood[5] end end)
  -- feather jar
  L(43,47,41,38,1,"#3fb0a8"); L(45,47,45,36,1,"#ffd84a"); L(47,47,50,39,1,"#b080d8")
  F(E(41,37,1,2,2),"teal"); F(E(45,35,1,2,2),"yellow"); F(E(50,38,1,2,2),"purple")
  F(B(41,46,49,51,1),"blue")
  L(13,49,23,47,1,"#ff9ec0"); L(14,48,22,46,1,"#e8503f")
  save("pl-wfla-6",{32,60,16,2},{{9,16},{54,22},{9,36}})
end)
pal("pl-wlig-6",function()
  for i=0,2 do local y=50+i*2
    L(21,y,12-i*2,y+2+i,2,R.red[3]); L(43,y,52+i*2,y+2+i,2,R.red[3]) end
  L(26,41,25,34,2,R.red[3]); L(38,41,39,34,2,R.red[3])
  L(22,43,15,35,3,R.red[3]); L(42,43,49,35,3,R.red[3])
  F(E(32,47,13,8,2.3),"red",function(i,x,y) if (x*3+y)%7==0 and i>=2 and i<5 then return R.red[i+1] end end)
  F(E(14,30,5,4,2),"red"); L(14,26,14,29,1,"#2b1c26")
  F(E(50,30,5,4,2),"red"); L(50,26,50,29,1,"#2b1c26")
  F(B(12,17,16,27,0),"cream"); rect(13,25,13,28,"#f6e0b4")
  F(B(48,17,52,27,0),"cream"); rect(49,25,49,28,"#f6e0b4")
  for _,cx in ipairs{14,50} do F(E(cx,13,2,3,2),"yellow"); px(cx,14,"#fffbe8"); px(cx,12,"#ff9a45") end
  reye(25,32,4,"white"); reye(39,32,4,"white")
  blush(24,45); blush(38,45); smile(29,44,5)
  save("pl-wlig-6",{32,60,17,2},{{6,10},{57,8},{32,10}})
end)
pal("pl-wpry-6",function()
  L(24,22,19,16,2,R.cream[2]); L(19,16,19,12,1,R.cream[1]); L(40,22,45,16,2,R.cream[2]); L(45,16,45,12,1,R.cream[1])
  for _,x in ipairs{20,26,36,42} do F(B(x,50,x+3,58,0),"yakb"); rect(x,57,x+3,58,"#d8c0b8") end
  F(E(32,41,15,11,2.2),"yakb")
  F(P{{16,46},{48,46},{48,52},{45,56},{42,52},{39,57},{36,52},{32,57},{29,52},{26,57},{23,52},{20,56},{16,52}},"yakb",function(i,x,y) if x%3==0 and i>=2 and i<5 then return R.yakb[i+1] end end)
  F(B(22,32,42,43,3),"red"); L(23,42,41,42,1,"#ffd84a"); L(23,34,41,34,1,"#ffd84a")
  for k,col in ipairs{"blue","green","yellow","pink"} do local x=22+(k-1)*6; F(P{{x,44},{x+4,44},{x+2,50}},col) end
  F(E(32,27,9,9,2.2),"yakb")
  for _,x in ipairs{23,28,33,38} do F(P{{x-1,21},{x+2,14},{x+5,21}},"yakb") end
  F(E(32,32,6,4,2),"yakf")
  eye(25,24,3); eye(36,24,3); px(30,32,"#4e4060"); px(34,32,"#4e4060"); smile(30,34,5)
  save("pl-wpry-6",{32,60,17,2},{{8,14},{56,14},{8,54}})
end)
